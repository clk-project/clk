#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import json
import functools
from collections import defaultdict
import collections
from copy import deepcopy
from contextlib import contextmanager
from functools import update_wrapper

import six
import click

from click_project.profile import iter_settings, ProfileFactory
from click_project.click_helpers import click_get_current_context_safe
from click_project.log import LOG_LEVELS, set_level, get_logger
from click_project.lib import updated_env, cd


LOGGER = get_logger(__name__)


def migrate_profiles():
    ctx = click_get_current_context_safe()
    for profile in config.profiles + list(config.all_recipes):
        if profile is not None:
            profile.migrate_if_needed(
                config.persist_migration and
                not (
                    ctx is not None and
                    ctx.resilient_parsing
                )
            )


def get_appdir(appname):
    config = os.environ.get("CLICKPROJECTCONFIGDIR")
    if config:
        return config
    return click.get_app_dir(appname)


def merge_settings(iter_settings):
    settings = collections.OrderedDict()
    settings2 = collections.OrderedDict()
    for s in iter_settings:
        for k, v in six.iteritems(s):
            if k == "_self":
                # self is not mergeable, for ot gives information about the file itself
                continue
            if k not in settings:
                settings[k] = deepcopy(v)
                settings2[k] = deepcopy(v)
            else:
                if isinstance(v, dict):
                    settings[k].update(v)
                    for k2, v2 in six.iteritems(v):
                        if isinstance(v2, list):
                            settings2[k][k2] = settings2[k].get(k2, []) + v2
                        elif isinstance(v2, dict):
                            s2v = settings2[k].get(k2)
                            if s2v is None:
                                settings2[k][k2] = deepcopy(v2)
                            else:
                                s2v.update(v2)
                        elif isinstance(v2, six.string_types):
                            settings2[k] = v2
                        else:
                            raise NotImplementedError("Please help us code this part")
                elif isinstance(v, list):
                    settings[k].extend(v)
                else:
                    raise NotImplementedError("Please help us code this part")
    return settings, settings2


class Config(object):
    app_dir_name = "click-project"
    app_name = "click-project"
    main_command = None

    def __init__(self):
        self._workgroup_profile = None
        self.settings2 = None
        self.debug_on_command_load_error_callback = False
        self.frozen = False
        self.settings = None
        self._local_profile = None
        self.command_line_settings = defaultdict(lambda: defaultdict(list))
        self.flow_settings = defaultdict(lambda: defaultdict(list))
        self._global_profile = None
        self.app_dir = get_appdir(self.app_dir_name)
        self.autoflow = None
        self.plugindirs = []
        self.env_settings = defaultdict(lambda: defaultdict(list))
        self._dry_run = None
        self._project = None
        self.alt_style = None
        self.persist_migration = False
        # environment values
        self.env = None
        self.override_env = None
        self.old_env = os.environ.copy()

    def init(self):
        if self.frozen:
            return
        self.settings = None
        self.merge_settings()
        self.reset_env()
        self.log_level = self.log_level or 'status'
        self.env = defaultdict(list)
        self.override_env = {}

    @property
    def global_context_settings(self):
        return {
            "recipe": {
                name: json.loads(open(self.global_profile.link_location(name), "rb").read().decode("utf-8"))
                for name in self.global_profile.recipe_link_names
            }
        }

    def get_settings(self, section):
        if self.settings is None:
            self.merge_settings()
        if section not in self.settings:
            self.settings[section] = collections.OrderedDict()
        return self.settings[section]

    def get_settings2(self, section):
        if self.settings2 is None:
            self.merge_settings()
        if section not in self.settings2:
            self.settings2[section] = collections.OrderedDict()
        return self.settings2[section]

    def reset_env(self):
        if self.old_env:
            os.environ.clear()
            os.environ.update(self.old_env)

    def setup_environ(self):
        """Put the values of self.env and self.override_env into environment variables"""
        for k, v in six.iteritems(self.override_env):
            os.environ[k] = v
        self.env = dict((k, os.pathsep.join(os.path.normpath(p) for p in ps if p)) for k, ps in six.iteritems(self.env))
        for k, v in six.iteritems(self.env):
            sep = os.pathsep if (k.endswith("PATH") or
                                 k.endswith("DIR") or
                                 k.endswith("DIRS")) else " "
            if k in os.environ:
                os.environ[k] = v + sep + os.environ[k]
            else:
                os.environ[k] = v

    def get_profile(self, name):
        for profile in self.profiles:
            if profile.name == name:
                return profile
            for recipe in profile.recipes:
                if recipe.name == name:
                    return recipe
        # fallback on uniq shortnames
        recipes = list(self.all_recipes)
        shortnames = list(map(lambda r: r.short_name, recipes))
        uniq_shortnames = [
            nam
            for nam in shortnames
            if shortnames.count(nam) == 1
        ]
        if name in uniq_shortnames:
            return [
                r for r in recipes
                if r.short_name == name
            ][0]
        raise ValueError("Could not find recipe {}".format(name))

    def sorted_recipes(self, recipes):
        return sorted(
            recipes,
            key=lambda r: self.get_recipe_order(r.short_name))

    def get_recipe_order(self, recipe):
        if self.settings is None:
            return 0
        return self.settings.get("recipe", {}).get(recipe, {}).get("order", 1000)

    def get_profile_containing_recipe(self, name):
        profile_level = name.split("/")[0]
        profile = self.profiles_per_level[profile_level]
        return profile

    def recipe_location(self, name):
        profile = self.get_profile_containing_recipe(name)
        return profile.recipe_location(name)

    def get_recipe(self, name):
        name, profile_level = name.split("/")
        profile = self.profiles_per_level[profile_level]
        return profile.get_recipe(name)

    def require_project(self):
        """Check that a project is set and is valid"""
        if not self.project:
            raise click.UsageError("No project provided")

    def is_recipe_enabled(self, shortname):
        return (self.settings2 or {}).get("recipe", {}).get(shortname, {}).get("enabled")

    def filter_enabled_recipes(self, recipes):
        return [
            recipe
            for recipe in recipes
            if self.is_recipe_enabled(recipe.short_name)
        ]

    def filter_unset_recipes(self, recipes):
        return [
            recipe
            for recipe in recipes
            if self.is_recipe_enabled(recipe.short_name) is None
        ]

    def filter_disabled_recipes(self, recipes):
        return [
            recipe
            for recipe in recipes
            if self.is_recipe_enabled(recipe.short_name) is False
        ]

    def load_settings_from_profile(self, profile, with_recipes, recipe_short_name=None):
        if profile is not None and with_recipes:
            for recipe in self.filter_enabled_recipes(profile.recipes):
                if not recipe_short_name or recipe_short_name == recipe.short_name:
                    for settings in self.load_settings_from_profile(recipe, with_recipes):
                        yield settings
        if profile is not None and (
                not recipe_short_name
                or profile.short_name == recipe_short_name
        ):
            settings, path = profile.settings, profile.settings_path
            for _settings in iter_settings(settings, path):
                yield _settings

    def iter_recipes(self, short_name):
        for profile in self.profiles:
            for recipe in self.filter_enabled_recipes(profile.recipes):
                if recipe.short_name == short_name:
                    yield recipe

    def get_profile_settings(self, section):
        return merge_settings(self.iter_settings(profiles_only=True))[0].get(section, {})

    def get_profile_settings2(self, section):
        return merge_settings(self.iter_settings(profiles_only=True))[1].get(section, {})

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
                self.merge_settings()
            else:
                self._project = value
                LOGGER.critical("{} does not exist. It will be ignored.".format(value))

    @property
    def profiles_per_level(self):
        res = collections.OrderedDict()
        res["global"] = config.global_profile
        if config.project is not None:
            res["workgroup"] = config.workgroup_profile
            res["local"] = config.local_profile
        return res

    @property
    def global_profile(self):
        if self._global_profile is None:
            self._global_profile = ProfileFactory.get(
                self.app_dir,
                name="global",
                app_name=self.app_name
            )
        return self._global_profile

    @property
    def all_disabled_recipes(self):
        for profile in self.profiles:
            for recipe in self.sorted_recipes(self.filter_disabled_recipes(profile.recipes)):
                yield recipe

    @property
    def all_unset_recipes(self):
        for profile in self.profiles:
            for recipe in self.sorted_recipes(self.filter_unset_recipes(profile.recipes)):
                yield recipe

    @property
    def all_recipes(self):
        for profile in self.profiles:
            for recipe in self.sorted_recipes(profile.recipes):
                yield recipe

    @property
    def workgroup_context_settings(self):
        if self.workgroup_profile:
            res = {
                "recipe": {
                    name: json.loads(open(self.workgroup_profile.link_location(name), "rb").read().decode("utf-8"))
                    for name in self.workgroup_profile.recipe_link_names
                }
            }
        else:
            res = {}
        return res

    @property
    def workgroup_profile(self):
        if not self._workgroup_profile:
            name = self.main_command.path
            self._workgroup_profile = ProfileFactory.get(
                os.path.dirname(self.project) + '/.{}'.format(name),
                name="workgroup",
                app_name=self.app_name,
            ) if self.project else None
        return self._workgroup_profile

    @property
    def workgroup(self):
        if self.project:
            return os.path.dirname(self.project)
        else:
            return None

    @property
    def local_profile(self):
        if not self._local_profile:
            self._local_profile = ProfileFactory.get(
                os.path.join(
                    self.project,
                    "." + self.main_command.path
                ),
                name="local",
                app_name=self.app_name,
            ) if self.project else None
        return self._local_profile

    @property
    def debug(self):
        if self.log_level is None:
            return False
        return LOG_LEVELS[self.log_level] <= LOG_LEVELS["debug"]

    @property
    def all_profiles(self):
        res = [
            self.global_profile,
        ]
        if self.project is not None:
            res.append(self.workgroup_profile)
            res.append(self.local_profile)
        return res

    @property
    def all_enabled_recipes(self):
        for profile in self.profiles:
            for recipe in self.sorted_recipes(self.filter_enabled_recipes(profile.recipes)):
                yield recipe

    @property
    def all_enabled_profiles_and_recipes(self):
        for profile in self.profiles:
            for recipe in self.sorted_recipes(self.filter_enabled_recipes(profile.recipes)):
                yield recipe
            yield profile

    @property
    def profiles(self):
        return [
            self.profiles_per_level[level]
            for level in self.levels
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
    def dry_run(self):
        return self._dry_run

    @dry_run.setter
    def dry_run(self, value):
        self._dry_run = value
        self.global_profile.dry_run = value
        if self.local_profile:
            self.local_profile.dry_run = value
        if self.workgroup_profile:
            self.workgroup_profile.dry_run = value
        from click_project import lib
        lib.dry_run = value

    @property
    def levels(self):
        candidates = ["global"]
        if self.local_profile:
            candidates.extend(["workgroup", "local"])
        return candidates

    @property
    def local_context_settings(self):
        return defaultdict(lambda: defaultdict(list))

    def iter_settings(self, profiles_only=False, with_recipes=True, recipe_short_name=None):
        profiles_only = profiles_only or recipe_short_name
        if not profiles_only:
            yield self.global_context_settings
        for settings in self.load_settings_from_profile(self.global_profile,
                                                        with_recipes,
                                                        recipe_short_name=recipe_short_name):
            yield settings
        if not profiles_only:
            yield self.workgroup_context_settings
        for settings in self.load_settings_from_profile(self.workgroup_profile,
                                                        with_recipes,
                                                        recipe_short_name=recipe_short_name):
            yield settings
        if not profiles_only:
            yield self.local_context_settings
        for settings in self.load_settings_from_profile(
                self.local_profile, with_recipes, recipe_short_name=recipe_short_name):
            yield settings
        if not profiles_only:
            yield self.env_settings
            yield self.command_line_settings
            yield self.flow_settings

    def merge_settings(self):
        if self.local_profile:
            self.local_profile.compute_settings()
        if self.workgroup_profile:
            self.workgroup_profile.compute_settings()
        migrate_profiles()
        # first step to get the initial settings
        self.settings, self.settings2 = merge_settings(self.iter_settings(with_recipes=False))
        # second step now that the we have enough settings to decide which
        # recipes to enable
        self.settings, self.settings2 = merge_settings(self.iter_settings(with_recipes=True))

    def get_value(self, path):
        return self.get_settings("value").get(path, {"value": None})["value"]


configs = []
config_cls = None


def setup_config_class(cls=Config):
    from click_project import completion
    completion.CASE_INSENSITIVE_ENV = "_{}_CASE_INSENSITIVE_COMPLETION".format(
        cls.app_name.upper().replace("-", "_")
    )
    global configs, config_cls
    config_cls = cls
    del configs[:]
    configs.append(config_cls())


setup_config_class()


class ConfigProxy(object):
    def __getattr__(self, k):
        return getattr(configs[-1], k)

    def __setattr__(self, k, v):
        return setattr(configs[-1], k, v)

    def __dir__(self):
        return dir(configs[-1])


config = ConfigProxy()


@contextmanager
def temp_config():
    with updated_env():
        configs.append(deepcopy(configs[-1]))
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


def get_settings(section):
    """Helper function to retrieve the settings"""
    return config.get_settings(section)


def get_settings2(section):
    """Helper function to retrieve the settings"""
    return config.get_settings2(section)


def pass_config(f):
    def new_func(*args, **kwargs):
        ctx = click.get_current_context()
        return ctx.invoke(f, config, *args[1:], **kwargs)
    return update_wrapper(new_func, f)


def in_project(command):
    from click_project.overloads import AutomaticOption
    options = [
        AutomaticOption(['--in-project/--no-in-project'], group='working directory', is_flag=True,
                        help="Run the command in the project directory"),
        AutomaticOption(['--cwd'], group='working directory',
                        help="Run the command in this directory. It can be used with --in-project to change to a"
                             " directory relative to the project directory")
    ]
    callback = command.callback

    @functools.wraps(callback)
    def launcher(*args, **kwargs):
        in_project = kwargs["in_project"]
        cwd = kwargs["cwd"]
        del kwargs["in_project"]
        del kwargs["cwd"]

        def run_in_cwd():
            if cwd:
                with cd(cwd):
                    return callback(*args, **kwargs)
            else:
                return callback(*args, **kwargs)

        if in_project:
            config.require_project()
            with cd(config.project):
                res = run_in_cwd()
        else:
            res = run_in_cwd()
        return res
    command.callback = launcher
    command.params.extend(options)
    return command
