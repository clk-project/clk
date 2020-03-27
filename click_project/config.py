#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import json
from collections import defaultdict
import collections
from copy import deepcopy
from contextlib import contextmanager

import six
import click

from click_project.profile import ProfileFactory, ActivationLevel
from click_project.click_helpers import click_get_current_context_safe
from click_project.log import LOG_LEVELS, set_level, get_logger
from click_project.lib import updated_env


LOGGER = get_logger(__name__)


def migrate_profiles():
    ctx = click_get_current_context_safe()
    for profile in config.root_profiles + list(config.all_recipes):
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


def merge_settings(settings):
    computed_settings = collections.OrderedDict()
    computed_settings2 = collections.OrderedDict()
    for s in settings:
        for k, v in six.iteritems(s):
            if k == "_self":
                # self is not mergeable, for ot gives information about the file itself
                continue
            if k not in computed_settings:
                computed_settings[k] = deepcopy(v)
                computed_settings2[k] = deepcopy(v)
            else:
                if isinstance(v, dict):
                    computed_settings[k].update(v)
                    for k2, v2 in six.iteritems(v):
                        if isinstance(v2, list):
                            computed_settings2[k][k2] = computed_settings2[k].get(k2, []) + v2
                        elif isinstance(v2, dict):
                            s2v = computed_settings2[k].get(k2)
                            if s2v is None:
                                computed_settings2[k][k2] = deepcopy(v2)
                            else:
                                s2v.update(v2)
                        elif isinstance(v2, six.string_types):
                            computed_settings2[k] = v2
                        else:
                            raise NotImplementedError("Please help us code this part")
                elif isinstance(v, list):
                    computed_settings[k].extend(v)
                else:
                    raise NotImplementedError("Please help us code this part")
    return computed_settings, computed_settings2


class Config(object):
    app_dir_name = "click-project"
    app_name = "click-project"
    main_command = None

    def __init__(self):
        self.settings2 = None
        self.debug_on_command_load_error_callback = False
        self.frozen = False
        self.settings = None
        self.command_line_profile = ProfileFactory.create_or_get_preset_profile(
            "commandline",
            settings=defaultdict(lambda: defaultdict(list)),
            explicit=False,
            isroot=True,
            activation_level=ActivationLevel.global_,
            )
        self.flow_profile = ProfileFactory.create_or_get_preset_profile(
            "flow",
            settings=defaultdict(lambda: defaultdict(list)),
            explicit=False,
            isroot=True,
            activation_level=ActivationLevel.global_,
        )
        self.app_dir = get_appdir(self.app_dir_name)
        self.autoflow = None
        self.plugindirs = []
        self.env_profile = ProfileFactory.create_or_get_preset_profile(
            "env",
            settings=defaultdict(lambda: defaultdict(list)),
            explicit=False,
            isroot=True,
            activation_level=ActivationLevel.global_,
            default_color="bold-True"
            )
        self._dry_run = None
        self._project = None
        self.alt_style = None
        self.persist_migration = False
        # environment values
        self.env = None
        self.custom_env = {}
        self.override_env = {}
        self.old_env = os.environ.copy()
        self.distribution_profile_location = None

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

    def guess_project(self):
        candidate = None
        if not self.project:
            candidate = self.find_project()
            if candidate:
                self._project = candidate
                LOGGER.develop(
                    "Guessing project {} from the local context".format(candidate)
                )
        return candidate

    def find_project(self):
        """Find the current project directory"""
        dir = os.getcwd()
        prevdir = None
        prefix = "." + self.main_command.path
        while dir != prevdir:
            if (
                    os.path.exists(dir + '/project.' + prefix)
                    or os.path.exists(prefix)
            ):
                return dir
            prevdir = dir
            dir = os.path.dirname(dir)
        return None
    def require_project(self):
        """Check that a project is set and is valid"""
        if not self.project:
            raise click.UsageError("No project provided")

    def init(self):
        if self.frozen:
            return
        self.settings = None
        self.merge_settings()
        self.reset_env()
        self.log_level = self.log_level or 'status'
        self.env = defaultdict(list)

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

    def iter_settings(self, explicit_only=False, recurse=True, only_this_recipe=None):
        explicit_only = explicit_only or only_this_recipe
        for profile in self.all_enabled_profiles:
            if not explicit_only or profile.explicit:
                yield from self.load_settings_from_profile(
                        profile,
                        recurse,
                        only_this_recipe=only_this_recipe
                )

    def merge_settings(self):
        if self.local_profile:
            self.local_profile.compute_settings()
        if self.workgroup_profile:
            self.workgroup_profile.compute_settings()
        migrate_profiles()
        # first step to get the initial settings
        self.settings, self.settings2 = merge_settings(self.iter_settings(recurse=False))
        # second step now that the we have enough settings to decide which
        # recipes to enable
        self.settings, self.settings2 = merge_settings(self.iter_settings(recurse=True))

    @property
    def project_bin_dirs(self):
        return [
            os.path.join(self.project, bin_dir)
            for bin_dir in {
                    "script",
                    "bin",
                    "scripts",
                    "Scripts",
                    "Bin",
                    "Script",
                    os.path.join(f".{self.main_command.path}", "scripts")
            }
        ] + [os.path.join(self.workgroup_profile.location, "scripts")]

    def load_settings_from_profile(self, profile, recurse, only_this_recipe=None):
        if profile is not None and (
                not only_this_recipe
                or profile.short_name == only_this_recipe
        ):
            yield profile.settings
        if profile is not None and recurse:
            for recipe in self.filter_enabled_profiles(profile.recipes):
                if not only_this_recipe or only_this_recipe == recipe.short_name:
                    for settings in self.load_settings_from_profile(recipe, recurse):
                        yield settings

    def get_profile(self, name):
        for profile in self.all_enabled_profiles:
            if profile.name == name:
                return profile
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
        raise ValueError("Could not find profile {}".format(name))

    @property
    def workgroup(self):
        if self.project:
            return os.path.dirname(self.project)
        else:
            return None

    @property
    def local_profile(self):
        self.guess_project()
        if self.project:
            return ProfileFactory.create_or_get_by_location(
                os.path.join(
                    self.project,
                    "." + self.main_command.path
                ),
                name="local",
                app_name=self.app_name,
                explicit=True,
                isroot=True,
                activation_level=ActivationLevel.local,
                default_color="fg-green",
            )
        else:
            return None

    @property
    def local_preset_profile(self):
        self.guess_project()
        if self.project:
            return ProfileFactory.create_or_get_preset_profile(
                "localpreset",
                settings={
                    "parameters": {
                        self.main_command.path: ["--project", self.project]
                    }
                },
                explicit=False,
                isroot=True,
                activation_level=ActivationLevel.local,
            )
        else:
            return None

    @property
    def workgroup_profile(self):
        self.guess_project()
        if self.project:
            return ProfileFactory.create_or_get_by_location(
                os.path.dirname(self.project) + '/.{}'.format(self.main_command.path),
                name="workgroup",
                app_name=self.app_name,
                explicit=True,
                isroot=True,
                activation_level=ActivationLevel.local,
                default_color="fg-magenta",
            )
        else:
            return None

    @property
    def workgroup_preset_profile(self):
        self.guess_project()
        if self.project:
            return ProfileFactory.create_or_get_preset_profile(
                "workgrouppreset",
                settings={
                    "recipe": {
                        name: json.loads(open(self.workgroup_profile.link_location(name), "rb").read().decode("utf-8"))
                        for name in self.workgroup_profile.recipe_link_names
                    }
                },
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

    @property
    def global_preset_profile(self):
        return ProfileFactory.create_or_get_preset_profile(
            "globalpreset",
            settings={
                "recipe": {
                    name: json.loads(open(self.global_profile.link_location(name), "rb").read().decode("utf-8"))
                    for name in self.global_profile.recipe_link_names
                }
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
            profile for profile in profiles
            if (
                    not profile.isrecipe
                    or
                    self.is_recipe_enabled(profile.short_name)
            )
        )

    @property
    def all_profiles(self):
        res = []

        def add_profile(profile, explicit=True):
            if profile is None:
                return
            res.append(profile)
            res.extend(self.sorted_recipes(profile.recipes))

        add_profile(self.distribution_profile)
        add_profile(self.global_preset_profile)
        add_profile(self.global_profile)
        add_profile(self.workgroup_preset_profile)
        add_profile(self.workgroup_profile)
        add_profile(self.local_preset_profile)
        add_profile(self.local_profile)
        add_profile(self.env_profile)
        add_profile(self.command_line_profile)
        return res

    @property
    def implicit_profiles(self):
        return [
            profile for profile in self.all_enabled_profiles
            if not profile.explicit
        ]

    @property
    def root_profiles(self):
        return [
            profile for profile in self.all_enabled_profiles
            if profile.isroot
        ]

    @property
    def all_recipes(self):
        for profile in self.root_profiles:
            for recipe in self.sorted_recipes(profile.recipes):
                yield recipe

    def get_enabled_recipes_by_short_name(self, short_name):
        return (
            recipe
            for recipe in self.all_enabled_recipes
            if recipe.short_name == short_name
        )

    @property
    def all_disabled_recipes(self):
        return self.filter_disabled_recipes(self.all_recipes)

    @property
    def all_unset_recipes(self):
        return self.filter_unset_recipes(self.all_recipes)

    @property
    def all_enabled_recipes(self):
        return self.filter_enabled_profiles(self.all_recipes)

    def sorted_recipes(self, recipes):
        return sorted(
            recipes,
            key=lambda r: self.get_recipe_order(r.short_name))

    def get_recipe_order(self, recipe):
        if self.settings is None:
            return 0
        return self.settings.get("recipe", {}).get(recipe, {}).get("order", 1000)

    def get_profile_containing_recipe(self, name):
        profile_name = name.split("/")[0]
        profile = self.get_profile(profile_name)
        return profile

    def recipe_location(self, name):
        profile = self.get_profile_containing_recipe(name)
        return profile.recipe_location(name)

    def get_recipe(self, name):
        name, profile_name = name.split("/")
        profile = self.get_profile(profile_name)
        return profile.get_recipe(name)

    def is_recipe_enabled(self, shortname):
        return (self.settings2 or {}).get("recipe", {}).get(shortname, {}).get("enabled")

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
        self.global_profile.dry_run = value
        if self.local_profile:
            self.local_profile.dry_run = value
        if self.workgroup_profile:
            self.workgroup_profile.dry_run = value
        from click_project import lib
        lib.dry_run = value

    def get_value(self, path):
        return self.get_settings("value").get(path, {"value": None})["value"]

    def get_parameters(self, path, implicit=False):
        section = "parameters"
        if implicit:
            return (
                self.global_preset_profile.get_settings(section).get(path, []) +
                self.local_context_profile.get_settings(section).get(path, []) +
                self.env_profile.get_settings(section).get(path, []) +
                self.command_line_profile.get_settings(section).get(path, [])
            )
        else:
            return self.get_settings2(section).get(path, [])


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
