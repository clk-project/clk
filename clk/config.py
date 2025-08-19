#!/usr/bin/env python

import json
import os
import shlex
from collections import defaultdict
from contextlib import contextmanager
from copy import deepcopy
from pathlib import Path

import click
from cached_property import cached_property

from clk.click_helpers import click_get_current_context_safe
from clk.lib import quote, updated_env, value_to_string
from clk.log import LOG_LEVELS, get_logger, set_level
from clk.profile import ActivationLevel, DirectoryProfile, ProfileFactory

LOGGER = get_logger(__name__)


class Value:
    def __getattr__(self, name):
        try:
            return config.settings2["value"][name]["value"]
        except Exception:
            return getattr(super(), name)

    def __getitem__(self, name):
        return self.__getattr__(name)

    def __dir__(self):
        return list(config.settings2["value"].keys())


class DynamicConfigBase:
    """Base class meant to be inherited from and used in callbacks

    Define the subclass as

    class SomeConfig(DynamicConfigBase):
        name = 'thenameintheconfig'

    Then declare some option like

    @option("--someoption", callback=SomeConfig.get_callback())

    Then, get the option with config.thenameintheconfig.someoption. Because it uses
    callbacks, the value is available very early, even before running the
    command. Hence the name dynamic
    """

    @classmethod
    def get_callback(klass):
        def cb(ctx, attr, value):
            if not hasattr(config, klass.name):
                inst = klass()
                setattr(config, klass.name, inst)
            else:
                inst = getattr(config, klass.name)
            setattr(inst, attr.name, value)
            return value

        return cb


def migrate_profiles():
    ctx = click_get_current_context_safe()
    for profile in config.root_profiles + list(config.all_extensions):
        if profile is not None:
            profile.migrate_if_needed(
                config.persist_migration
                and not (ctx is not None and ctx.resilient_parsing)
            )


def get_appdir(appname):
    config = os.environ.get(f"{appname.upper()}CONFIGDIR")
    if config:
        return config
    return click.get_app_dir(appname)


def merge_settings(settings):
    computed_settings = {}
    computed_settings2 = {}
    for s in settings:
        for k, v in s.items():
            if k == "_self":
                # self is not mergeable, for ot gives information about the file itself
                continue
            if k not in computed_settings:
                computed_settings[k] = deepcopy(v)
                computed_settings2[k] = deepcopy(v)
            else:
                if isinstance(v, dict):
                    computed_settings[k].update(v)
                    for k2, v2 in v.items():
                        if isinstance(v2, list):
                            computed_settings2[k][k2] = (
                                computed_settings2[k].get(k2, []) + v2
                            )
                        elif isinstance(v2, dict):
                            s2v = computed_settings2[k].get(k2)
                            if s2v is None:
                                computed_settings2[k][k2] = deepcopy(v2)
                            else:
                                s2v.update(v2)
                        elif isinstance(v2, str):
                            computed_settings2[k] = v2
                        else:
                            raise NotImplementedError("Please help us code this part")
                elif isinstance(v, list):
                    computed_settings[k].extend(v)
                else:
                    raise NotImplementedError("Please help us code this part")
    return computed_settings, computed_settings2


class Config:
    app_dir_name = "clk"
    app_name = "clk"
    main_command = None
    log_level_default = "deprecated"

    def __init__(self):
        self.ask_secret_callback = None
        self.settings2 = None
        self.debug_on_command_load_error_callback = False
        self.frozen = False
        self.settings = None
        self.app_dir = get_appdir(self.app_dir_name)
        self.autoflow = None
        self.flowstep = None
        self.plugindirs = []
        self._dry_run = None
        self._project = None
        self.alt_style = None
        self.persist_migration = False
        # environment values
        self.env = None
        self.override_env = {"CLK_INSTALL_LOCATION": str(Path(__file__).parent)}
        self.old_env = os.environ.copy()
        self.distribution_profile_location = None
        self._all_profiles_cache = None
        self.value = Value()
        self.groups = {"clk"}
        self.flow_verbose = False
        self.level_settings = {}

    @cached_property
    def commandline_profile(self):
        return ProfileFactory.create_preset_profile(
            "commandline",
            settings=defaultdict(lambda: defaultdict(list)),
            explicit=False,
            isroot=True,
            activation_level=ActivationLevel.global_,
        )

    @cached_property
    def flow_profile(self):
        return ProfileFactory.create_preset_profile(
            "flow",
            settings=defaultdict(lambda: defaultdict(list)),
            explicit=False,
            isroot=True,
            activation_level=ActivationLevel.global_,
        )

    @cached_property
    def env_profile(self):
        profile = ProfileFactory.create_preset_profile(
            "env",
            settings=defaultdict(lambda: defaultdict(list)),
            explicit=True,
            isroot=True,
            activation_level=ActivationLevel.global_,
            default_color="bold-True",
        )
        parameters_prefix = f"{self.app_name}_P_".upper()
        profile.settings["parameters"] = {
            key[len(parameters_prefix) :]
            .replace("__", "-")
            .replace("_", ".")
            .lower(): shlex.split(value)
            for key, value in os.environ.items()
            if key.startswith(parameters_prefix)
        }
        extensions_prefix = f"{self.app_name}_E_".upper()
        profile.settings["recipe"] = {
            key[len(extensions_prefix) :]: {"enabled": json.loads(value)}
            for key, value in os.environ.items()
            if key.startswith(extensions_prefix)
        }
        return profile

    @property
    def context_parameters_as_environ_variables(self):
        try:
            ctx = click.get_current_context()
        except RuntimeError:
            return {}
        env = {}

        while ctx:
            env.update(
                {
                    (ctx.command_path.replace(" ", "_") + "__" + key).upper(): (
                        value_to_string(value)
                    )
                    for key, value in ctx.params.items()
                }
            )
            ctx = ctx.parent
        return env

    @property
    def group_command_line_parameters_as_environ_variables(self):
        return {
            ("CLK_P_" + path.replace("-", "__").replace(".", "_")).upper(): " ".join(
                map(quote, parameters)
            )
            for path, parameters in self.commandline_profile.settings[
                "parameters"
            ].items()
            if path in self.groups and parameters
        }

    @property
    def external_commands_environ_variables(self):
        return {
            **self.context_parameters_as_environ_variables,
            **self.group_command_line_parameters_as_environ_variables,
            **{
                "CLK_APPNAME": self.app_name,
                "CLK_APPNAME_UPPER": self.app_name.upper(),
            },
        }

    @property
    def project(self):
        if self._project and os.path.exists(self._project):
            return self._project

    @project.setter
    def project(self, value):
        if value and value != self._project:
            if os.path.exists(value):
                value = os.path.abspath(value)
                self._project = value
                # clean the profiles cache to make sure the new profile is taken
                # into account
                self._all_profiles_cache = None
                self.merge_settings()
            else:
                self._project = value
                LOGGER.critical(f"{value} does not exist. It will be ignored.")

    def guess_project(self):
        if self.project:
            return self.project
        else:
            candidate = self.find_project()
            if candidate:
                LOGGER.develop(f"Guessing project {candidate} from the local context")
            return candidate

    def find_project(self):
        """Find the current project directory"""
        dir = os.getcwd()
        prevdir = None
        localprofilename = "." + self.main_command.path
        while dir != prevdir:
            if os.path.exists(os.path.join(dir, localprofilename)):
                return dir
            prevdir = dir
            dir = os.path.dirname(dir)
        return None

    def require_project(self):
        """Check that a project is set and is valid"""
        if not self.project:
            raise click.UsageError("No project provided")

    def init(self):
        self._all_profiles_cache = None
        if self.frozen:
            return
        self.settings = None
        self.merge_settings()
        self.log_level = self.log_level or self.log_level_default
        self.reset_env()
        self.env = defaultdict(list)
        self.setup_environ()

    def reset_env(self):
        if self.old_env:
            os.environ.clear()
            os.environ.update(self.old_env)

    def setup_environ(self):
        """Put the values of self.env and self.override_env into environment variables"""
        for k, v in self.override_env.items():
            os.environ[k] = v
        self.env = {
            k: os.pathsep.join(os.path.normpath(p) for p in ps if p)
            for k, ps in self.env.items()
        }
        for k, v in self.env.items():
            sep = (
                os.pathsep
                if (k.endswith("PATH") or k.endswith("DIR") or k.endswith("DIRS"))
                else " "
            )
            if k in os.environ:
                os.environ[k] = v + sep + os.environ[k]
            else:
                os.environ[k] = v
        for k, v in self.get_settings("environment").items():
            from clk.overloads import eval_arg

            os.environ[k] = eval_arg(v["value"])

    def get_settings(self, section):
        if self.settings is None:
            self.merge_settings()
        if section not in self.settings:
            self.settings[section] = {}
        return self.settings[section]

    def get_settings2(self, section):
        if self.settings2 is None:
            self.merge_settings()
        if section not in self.settings2:
            self.settings2[section] = {}
        return self.settings2[section]

    def iter_settings(self, explicit_only=False, only_this_extension=None):
        explicit_only = explicit_only or only_this_extension
        for profile in self.all_enabled_profiles:
            if not explicit_only or profile.explicit:
                yield from self.load_settings_from_profile(
                    profile, only_this_extension=only_this_extension
                )

    def merge_settings(self):
        for profile in self.all_enabled_profiles:
            profile.compute_settings()
        migrate_profiles()
        # first step to get the initial settings
        self.settings, self.settings2 = merge_settings(self.iter_settings())
        # second step now that the we have enough settings to decide which
        # extensions to enable
        self.settings, self.settings2 = merge_settings(self.iter_settings())

    def get_profile_that_contains(self, path):
        """Among all profiles that contain the path, return the one with the
        longest path.

        This ensure that the path
        ~/.config/clk/extension/someext/python/somecommand.py will return
        ~/.config/clk/extension/someext and never ~/.config/clk/."""
        candidates = [
            profile for profile in self.all_enabled_profiles if profile.contains(path)
        ]
        if candidates:
            return max(candidates, key=lambda profile: profile.location)
        else:
            return None

    def load_settings_from_profile(self, profile, only_this_extension=None):
        if profile is not None and (
            not only_this_extension or profile.short_name == only_this_extension
        ):
            yield profile.settings

    def get_profile(self, name):
        for profile in self.all_profiles:
            if profile.name == name:
                return profile
        # fallback on uniq shortnames
        extensions = list(self.all_extensions)
        shortnames = list(map(lambda r: r.short_name, extensions))
        uniq_shortnames = [nam for nam in shortnames if shortnames.count(nam) == 1]
        if name in uniq_shortnames:
            return [r for r in extensions if r.short_name == name][0]
        raise ValueError(f"Could not find profile {name}")

    @property
    def workspace(self):
        if self.project:
            return os.path.dirname(self.project)
        else:
            return None

    @property
    def local_profile(self):
        if self.project:
            return ProfileFactory.create_or_get_by_location(
                os.path.join(self.project, "." + self.main_command.path),
                name="local",
                app_name=self.app_name,
                explicit=True,
                isroot=True,
                activation_level=ActivationLevel.local,
                default_color="fg-green",
            )
        else:
            return None

    @cached_property
    def currentdirectorypreset_profile(self):
        settings = {}
        proj = self.guess_project()
        if proj:
            settings["parameters"] = {self.main_command.path: ["--project", proj]}
        return ProfileFactory.create_preset_profile(
            "currentdirectorypreset",
            settings=settings,
            explicit=False,
            isroot=True,
            activation_level=ActivationLevel.global_,
        )

    @property
    def localpreset_profile(self):
        if self.project:
            return ProfileFactory.create_preset_profile(
                "localpreset",
                settings={"customcommands": self.local_profile.custom_command_paths},
                explicit=False,
                isroot=True,
                activation_level=ActivationLevel.local,
            )
        else:
            return None

    @property
    def workspace_profile(self):
        if self.project:
            return ProfileFactory.create_or_get_by_location(
                os.path.dirname(self.project) + f"/.{self.main_command.path}",
                name="workspace",
                app_name=self.app_name,
                explicit=True,
                isroot=True,
                activation_level=ActivationLevel.local,
                default_color="fg-magenta",
            )
        else:
            return None

    @cached_property
    def workspacepreset_profile(self):
        if self.project:
            return ProfileFactory.create_preset_profile(
                "workspacepreset",
                settings={},
                explicit=False,
                isroot=True,
                activation_level=ActivationLevel.local,
            )
        else:
            return None

    @property
    def global_profile(self):
        return ProfileFactory.create_or_get_by_location(
            self.app_dir,
            name="global",
            app_name=self.app_name,
            explicit=True,
            isroot=True,
            activation_level=ActivationLevel.global_,
            default_color="fg-cyan",
        )

    @cached_property
    def globalpreset_profile(self):
        return ProfileFactory.create_preset_profile(
            "globalpreset",
            settings={
                "launchers": {
                    "gdb": ["gdb", "--quiet", "--args"],
                    "dlvdebug": ["dlv", "debug"],
                    "gorun": ["go", "run"],
                    "gdb-jvm": [
                        "gdb",
                        "--quiet",
                        "--eval-command=handle SIGSEGV nostop noprint pass",
                        "--args",
                    ],
                    "lldb": ["lldb", "--"],
                    "memcheck": ["valgrind", "--tool=memcheck", "--leak-check=full"],
                    "callgrind": [
                        "valgrind",
                        "--tool=callgrind",
                        "--separate-callers=2",
                    ],
                    "massif": ["valgrind", "--tool=massif"],
                    "heaptrack": ["heaptrack"],
                    "perf-record": [
                        "perf",
                        "record",
                        "-e",
                        "cpu-clock",
                        "--call-graph",
                        "dwarf",
                        "-F",
                        "99",
                    ],
                    "xvfb": [
                        "xvfb-run",
                        "-a",
                        "--server-args",
                        "-screen 0 1024x768x24 -extension RANDR",
                    ],
                    "time": ["time", "-v"],
                    "gdbserver": ["gdbserver", "localhost:9999"],
                },
                "customcommands": self.global_profile.custom_command_paths,
                "alias": {},
            },
            explicit=False,
            isroot=True,
            activation_level=ActivationLevel.global_,
        )

    @property
    def distribution_profile(self):
        if self.distribution_profile_location is not None:
            return ProfileFactory.create_or_get_by_location(
                self.distribution_profile_location,
                name="distribution",
                app_name=self.app_name,
                explicit=False,
                isroot=True,
                activation_level=ActivationLevel.global_,
                readonly=True,
            )
        else:
            return None

    @property
    def all_enabled_profiles(self):
        return self.filter_enabled_profiles(self.all_profiles)

    def filter_enabled_profiles(self, profiles):
        return (
            profile
            for profile in profiles
            if (
                not profile.isextension or self.is_extension_enabled(profile.short_name)
            )
        )

    @property
    def all_directory_profiles(self):
        return [
            profile
            for profile in self.all_profiles
            if isinstance(profile, DirectoryProfile)
        ]

    @property
    def all_profiles(self):
        if self._all_profiles_cache is None:
            res = []

            def add_profile(profile, explicit=True):
                if profile is None:
                    return
                for extension in self.sorted_extensions(profile.extensions):
                    res.append(
                        ProfileFactory.create_preset_profile(
                            f"{extension.name}preset",
                            settings={"customcommands": extension.custom_command_paths},
                            explicit=False,
                            isroot=False,
                            isextension=True,
                            activation_level=ActivationLevel.global_,
                        )
                    )
                    res.append(extension)
                res.append(profile)

            add_profile(self.distribution_profile)
            add_profile(self.globalpreset_profile)
            add_profile(self.global_profile)
            add_profile(self.currentdirectorypreset_profile)
            add_profile(self.workspacepreset_profile)
            add_profile(self.workspace_profile)
            add_profile(self.localpreset_profile)
            add_profile(self.local_profile)
            add_profile(self.env_profile)
            add_profile(self.commandline_profile)
            add_profile(self.flow_profile)
            self._all_profiles_cache = res
        return self._all_profiles_cache

    @property
    def implicit_profiles(self):
        return [
            profile for profile in self.all_enabled_profiles if not profile.explicit
        ]

    @property
    def root_profiles(self):
        return [profile for profile in self.all_enabled_profiles if profile.isroot]

    @property
    def all_extensions(self):
        for profile in self.root_profiles:
            yield from self.sorted_extensions(profile.extensions)

    def get_enabled_extensions_by_short_name(self, short_name):
        return (
            extension
            for extension in self.all_enabled_extensions
            if extension.short_name == short_name
        )

    @property
    def all_disabled_extensions(self):
        return self.filter_disabled_extensions(self.all_extensions)

    @property
    def all_unset_extensions(self):
        return self.filter_unset_extensions(self.all_extensions)

    @property
    def all_enabled_extensions(self):
        return self.filter_enabled_profiles(self.all_extensions)

    def sorted_extensions(self, extensions):
        return sorted(extensions, key=lambda r: self.get_extension_order(r.short_name))

    def get_extension_order(self, extension):
        if self.settings is None:
            return 0
        return self.settings.get("recipe", {}).get(extension, {}).get("order", 1000)

    def get_profile_containing_extension(self, name):
        profile_name = name.split("/")[0]
        profile = self.get_profile(profile_name)
        return profile

    def extension_location(self, name):
        profile = self.get_profile_containing_extension(name)
        return profile.extension_location(name)

    def get_extension(self, name):
        name, profile_name = name.split("/")
        profile = self.get_profile(profile_name)
        return profile.get_extension(name)

    def is_extension_enabled(self, shortname):
        if shortname.endswith("preset"):
            # the preset profile associated to a extension must have the same
            # enabling than the extension itself
            shortname = shortname[: -len("preset")]
        return (
            (self.settings2 or {})
            .get("recipe", {})
            .get(shortname, {})
            .get("enabled", True)
        )

    def filter_unset_extensions(self, extensions):
        return [
            extension
            for extension in extensions
            if self.is_extension_enabled(extension.short_name) is None
        ]

    def filter_disabled_extensions(self, extensions):
        return [
            extension
            for extension in extensions
            if self.is_extension_enabled(extension.short_name) is False
        ]

    @property
    def log_level(self):
        if hasattr(self, "_log_level"):
            return self._log_level
        else:
            return None

    @log_level.setter
    def log_level(self, value):
        if value is not None:
            self._log_level = value
            set_level(LOG_LEVELS[value])

    @property
    def develop(self):
        if self.log_level is None:
            return False
        return LOG_LEVELS[self.log_level] <= LOG_LEVELS["develop"]

    @property
    def debug(self):
        if self.log_level is None:
            return False
        return LOG_LEVELS[self.log_level] <= LOG_LEVELS["debug"]

    @property
    def dry_run(self):
        return self._dry_run

    @dry_run.setter
    def dry_run(self, value):
        self._dry_run = value
        for profile in self.all_profiles:
            profile.dry_run = value
        from clk import lib, liblp

        lib.dry_run = value
        liblp.dry_run = value

    def get_value(self, path, default=None):
        return self.get_settings("value").get(path, {"value": default})["value"]

    def get_parameters(self, path, implicit_only=False):
        return [
            setting
            for profile in self.all_enabled_profiles
            if implicit_only is False or not profile.explicit
            for setting in profile.get_settings("parameters").get(path, [])
        ]


configs = []
config_cls = None


def setup_config_class(cls=Config):
    from clk import completion

    completion.CASE_INSENSITIVE_ENV = "_{}_CASE_INSENSITIVE_COMPLETION".format(
        cls.app_name.upper().replace("-", "_")
    )
    global config_cls
    config_cls = cls
    del configs[:]
    configs.append(config_cls())


setup_config_class()


class ConfigProxy:
    def __getattr__(self, k):
        return getattr(configs[-1], k)

    def __setattr__(self, k, v):
        return setattr(configs[-1], k, v)

    def __dir__(self):
        return dir(configs[-1])


config: Config = ConfigProxy()


@contextmanager
def temp_config():
    with updated_env():
        configs.append(deepcopy(configs[-1]))
        config.level_settings = {}
        try:
            yield
        finally:
            configs.pop()


@contextmanager
def frozen_config():
    old_frozen_status = config.frozen
    config.frozen = True
    yield
    config.frozen = old_frozen_status
