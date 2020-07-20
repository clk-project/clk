#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
import json
import collections
import six
import re
from enum import Enum
from cached_property import cached_property

import click

from click_project.lib import json_dump_file, glob, rm, copy, makedirs, \
    ensure_unicode, part_of_day, createfile, move, json_file
from click_project.log import get_logger

LOGGER = get_logger(__name__)


class ActivationLevel(Enum):
    local = "local"
    global_ = "global"


class ProfileFactory:
    directory_profile_cls = None
    directory_profile_cache = {}

    preset_profile_cls = None
    preset_profile_used = False

    @classmethod
    def register_directory_profile(klass, cls):
        assert not klass.directory_profile_cache, (
            f"A new class ({cls}) was registered after the first instantiation"
            f" of a directory profile with class ({klass.directory_profile_cls})"
            f" This would cause unstable behavior"
        )
        klass.directory_profile_cls = cls
        return cls

    @classmethod
    def register_preset_profile(klass, cls):
        assert not klass.preset_profile_used, (
            f"A new class ({cls}) was registered after the first instantiation"
            f" of a preset profile with class ({klass.preset_profile_cls})"
            f" This would cause unstable behavior"
        )
        klass.preset_profile_cls = cls
        return cls

    @classmethod
    def create_or_get_by_location(klass, location, *args, **kwargs):
        if "name" not in kwargs:
            kwargs["name"] = "unnamed"
        if location not in klass.directory_profile_cache:
            profile = klass.directory_profile_cls(location, *args, **kwargs)
            klass.directory_profile_cache[location] = profile
        return klass.directory_profile_cache[location]

    @classmethod
    def create_preset_profile(
            klass, name,
            settings=None, explicit=True, isroot=True,
            activation_level=ActivationLevel.global_,
            default_color=None):
        return klass.preset_profile_cls(
            name, settings,
            explicit=explicit, isroot=isroot,
            activation_level=activation_level,
            default_color=default_color,
        )


def load_settings(path):
    if path is not None and os.path.exists(path):
        with open(path) as f:
            try:
                return json.load(f, object_pairs_hook=collections.OrderedDict)
            except ValueError:
                # just give up on the data in the file
                LOGGER.warning("Can't read settings from %s" % path)
    return {}


def write_settings(settings_path, settings, dry_run):
    if dry_run:
        return
    parent_dir = os.path.dirname(settings_path)
    if not os.path.exists(parent_dir):
        makedirs(parent_dir)
    json_dump_file(settings_path, settings, internal=True)


class Profile():
    def __repr__(self):
        return f"<{self.__class__.__name__}: {self.name}>"


@ProfileFactory.register_directory_profile
class DirectoryProfile(Profile):
    def __gt__(self, other):
        return self.name < other.name

    def recipe_location(self, name):
        name = self.recipe_short_name(name)
        return os.path.join(self.location, "recipes", name)

    def link_location(self, name):
        return self.recipe_location(name) + ".json"

    def create_recipe(self, name, mkdir=True):
        name = self.recipe_full_name(name)
        if not re.match(
            "^{}/[a-z0-9_]+$".format(self.name),
            name
        ):
            raise click.UsageError(
                "Invalid recipe name: %s. A recipe's name must contain only letters or _" % name
            )
        location = self.recipe_location(name)
        if os.path.exists(location):
            raise click.UsageError("{} already exists".format(location))
        p = ProfileFactory.create_or_get_by_location(
            location, name=name,
            app_name=self.app_name,
            explicit=True)
        if mkdir:
            p.write_settings()
        return p

    def recipe_full_name(self, name):
        if name.startswith(self.name + "/"):
            return name
        else:
            return self.name + "/" + name

    def recipe_short_name(self, name):
        if name.startswith(self.name + "/"):
            return name[len(self.name)+1:]
        else:
            return name

    def remove_recipe(self, name):
        r = self.get_recipe(name)
        rm(r.location)

    def has_recipe(self, name):
        name = self.recipe_full_name(name)
        candidates = [recipe for recipe in self.recipes if recipe.name == name]
        return candidates

    def has_recipe_link(self, name):
        return os.path.exists(self.link_location(name))

    def get_recipe(self, name):
        name = self.recipe_full_name(name)
        candidates = [recipe for recipe in self.recipes if recipe.name == name]
        if not candidates:
            return self.create_recipe(name, mkdir=False)
        else:
            return candidates[0]

    @cached_property
    def recipes(self):
        if self.isrecipe:
            return []
        recipes_dir = os.path.join(self.location, "recipes")
        if not os.path.exists(recipes_dir):
            return []
        res = sorted(
            [
                ProfileFactory.create_or_get_by_location(
                    location,
                    name=self.name + "/" + os.path.basename(location),
                    app_name=self.app_name,
                    explicit=True
                )
                for location in glob(os.path.join(recipes_dir, "*"))
                if not location.endswith(".json")
                and not location.endswith("_backup")
            ],
            key=lambda r: r.name)
        return res

    @property
    def recipe_links(self):
        res = [
            location
            for location in glob(os.path.join(self.location, "recipes", "*"))
            if location.endswith(".json")
        ]
        return res

    @property
    def recipe_link_names(self):
        return {
            os.path.splitext(os.path.basename(link))[0]
            for link in self.recipe_links
        }

    @property
    def recipe_names(self):
        return [r.name for r in self.recipes]

    @property
    def friendly_name(self):
        return self.name

    @property
    def short_name(self):
        if "/" in self.name:
            profile_name, recipe_name = self.name.split("/")
            return recipe_name
        else:
            return self.name

    @property
    def parent_name(self):
        if "/" in self.name:
            profile_name, recipe_name = self.name.split("/")
            return profile_name
        else:
            return None

    def __init__(self, location, app_name, dry_run=False, name=None,
                 explicit=True, isroot=True,
                 activation_level=ActivationLevel.global_,
                 readonly=False, default_color=None):
        self.app_name = app_name
        self.default_color = default_color
        self.readonly = readonly
        self.activation_level = activation_level
        self.explicit = explicit
        self.isroot = isroot
        self.migrate_from = [
            self.alias_has_documentation,
            self.stack_of_git_records,
            self.recipes_instead_of_settings_level,
            self.recipes_instead_of_profiles,
            self.remove_with_legend,
            self.hooks_to_trigger,
        ]
        self._version = None
        self.location = location
        self.settings_path = os.path.join(self.location, "{}.json".format(self.app_name))
        self.dry_run = dry_run
        self.name = name

        def file_name_if_exists(file_name):
            return os.path.exists(file_name) and file_name or None
        self.persist = True
        self.prevented_persistence = False
        self.pluginsdir = os.path.join(self.location, "plugins")
        self.frozen_during_migration = False
        self.old_version = self.version
        if self.version > self.max_version:
            LOGGER.error(
                "The profile at location {} is at version {}."
                " I can only manage till version {}."
                " It will be ignored."
                " Please upgrade {} and try again.".format(
                    self.location,
                    self.old_version,
                    self.max_version,
                    self.app_name,
                )
            )
            self.frozen_during_migration = True
        self.computed_location = None
        self.compute_settings()
        self.backup_location = self.location + "_backup"
        if os.path.exists(self.backup_location):
            LOGGER.warning(
                "The backup directory for profile"
                " in location {} already exist".format(self.location)
            )
        self.migration_impact = [
            os.path.basename(self.version_file_name),
        ] + [
            os.path.basename(f)
            for f in glob(self.location + "/{}*json".format(self.app_name))
        ] + [
            "recipes"
        ]

    def get_settings(self, section):
        assert self.settings_path is not None
        if section not in self.settings:
            self.settings[section] = {}
        return self.settings[section]

    @property
    def version_file_name(self):
        return os.path.join(self.location, "version.txt")

    @property
    def version(self):
        if self._version is not None:
            return self._version
        elif not os.path.exists(self.location) or not os.listdir(self.location):
            return self.max_version
        elif not os.path.exists(self.version_file_name):
            return 0
        else:
            return int(open(self.version_file_name, "rb").read().decode("utf-8"))

    @property
    def max_version(self):
        return len(self.migrate_from)

    def compute_settings(self):
        if self.location == self.computed_location:
            return
        if self.version > self.max_version:
            self.settings = {}
        else:
            self.settings = load_settings(self.settings_path) if os.path.exists(self.settings_path) else {}
        self.computed_location = self.location

    @property
    def isrecipe(self):
        return os.path.basename(os.path.dirname(self.location)) == "recipes"

    def recipe_link_order(self, recipe):
        if self.has_recipe_link(recipe):
            link_location = self.link_location(recipe)
            return json.load(open(link_location)).get("order", 100)
        return 100

    def recipeislinkenabled(self, recipe):
        if self.has_recipe_link(recipe):
            link_location = self.link_location(recipe)
            return json.load(open(link_location)).get("enabled")
        return None

    def alias_has_documentation(self):
        for settings_file in glob(self.location + "/{}*json".format(self.app_name)):
            with json_file(settings_file) as settings:
                if "alias" not in settings:
                    continue

                aliases = settings["alias"]
                new_aliases = {
                    alias: {
                        "commands": commands,
                        "documentation": None,
                    }
                    for alias, commands in six.iteritems(aliases)
                }
                settings["alias"] = new_aliases
        self.computed_location = None
        self.compute_settings()
        return True

    def stack_of_git_records(self):
        for settings_file in glob(self.location + "/{}*json".format(self.app_name)):
            with json_file(settings_file) as settings:
                if "git_record" not in settings:
                    continue

                git_records = settings["git_record"]
                new_git_records = {
                    key: [record]
                    for key, record in six.iteritems(git_records)
                }
                settings["git_record"] = new_git_records
        self.computed_location = None
        self.compute_settings()
        return True

    def recipes_instead_of_profiles(self):
        if self.isrecipe:
            return True
        recipes_dir = self.location + "/recipes/"
        warn = False
        for profile in glob(self.location + "/../.csm-*"):
            profile_name = re.sub("^.+csm-(.+)$", r"\1", profile)
            recipe_location = recipes_dir + "/" + profile_name + "_from_profile"
            move(profile, recipe_location)
            warn = True
        if warn:
            LOGGER.warning(
                "The profiles were migrated as recipes."
                " As we could not maintain backward compatibility,"
                " please see with SLO or GLE to understand how"
                " to make use of this new setup"
            )
        return True

    def recipes_instead_of_settings_level(self):
        if self.isrecipe:
            return True
        recipes_dir = self.location + "/recipes/"

        def migrate_settings_to_recipe(settings_level_file, name):
            if open(settings_level_file, "rb").read().decode("utf-8").strip() == "{}":
                return False
            makedirs(recipes_dir + "/" + name)
            enabled = not json.load(open(settings_level_file)).get("_self", {}).get("disabled", False)
            order = json.load(open(settings_level_file)).get("_self", {}).get("order", 100)
            move(settings_level_file, recipes_dir + "/" + name + "/{}.json".format(self.app_name))
            createfile(recipes_dir + "/" + name + "/version.txt", str(self.version + 1))
            createfile(recipes_dir + "/" + name + ".json", json.dumps(
                {
                    "enabled": enabled,
                    "order": order,
                }
            )
            )
            return True
        migrate_something = False
        for settings_level_file in glob(self.location + "/{}-*.json".format(self.app_name)):
            name = re.sub(".+{}-([a-zA-Z-]+).json$".format(self.app_name), r"\1", settings_level_file)
            name = name.replace("-", "_")
            if name == "private":
                continue
            migrate_something |= migrate_settings_to_recipe(
                settings_level_file,
                name + "_from_settings"
            )
        private = self.location + "/{}-private.json".format(self.app_name)
        local = self.location + "/{}.json".format(self.app_name)
        if os.path.exists(private):
            if open(private, "rb").read().decode("utf-8").strip() != "{}":
                migrate_something = True
            else:
                rm(private)
        if migrate_something is True:
            name = "migrated_local"
            if os.path.exists(local) and not open(local, "rb").read().decode("utf-8").strip() == "{}":
                migrate_settings_to_recipe(local, name)
            if os.path.exists(private):
                move(private, local)
            with json_file(local) as values:
                recipes = values.get("recipe", {})
                local_order = recipes.get(name, {})
                local_order["order"] = 0
                recipes[name] = local_order
                values["recipe"] = recipes
            self.computed_location = None
            self.compute_settings()
        return True

    def remove_with_legend(self):
        for settings_file in glob(self.location + "/{}*json".format(self.app_name)):
            content = open(settings_file, "rb").read().decode("utf-8")
            content = content.replace("--with-legend", "--legend")
            open(settings_file, "wb").write(content.encode("utf-8"))
        self.computed_location = None
        self.compute_settings()
        return True

    def hooks_to_trigger(self):
        with json_file(self.settings_path) as settings:
            if "hooks" in settings:
                settings["triggers"] = settings["hooks"]
                del settings["hooks"]
        self.computed_location = None
        self.compute_settings()
        return True

    def write_settings(self):
        if self.readonly:
            raise click.UsageError(
                f"Cannot write into {self.name}. It is read only."
            )
        if self.frozen_during_migration:
            raise click.UsageError(
                "You cannot edit the configuration if the migration is not persisted"
            )
        makedirs(self.location)
        self.write_version()
        return write_settings(self.settings_path, self.settings, self.dry_run)

    def write_version(self):
        if self.frozen_during_migration:
            raise click.UsageError(
                "You cannot edit the configuration if the migration is not persisted"
            )
        makedirs(self.location)
        version = self.version
        createfile(self.version_file_name, ensure_unicode(str(version)), internal=True)

    def migrate_if_needed(self, persist=True):
        self.persist = persist
        if (
                self.version < self.max_version or
                (
                    self.persist and
                    self.prevented_persistence
                )
        ):
            if self.persist:
                LOGGER.warning(
                    "Profile in {} is obsolete."
                    " It has the version {} and current version is {}."
                    " Migration started.".format(self.location, self.old_version, self.max_version)
                )
            if (
                    self.migrate(persist=self.persist) or
                    (
                        self.prevented_persistence and
                        self.persist
                    )
            ):
                if self.persist:
                    self.frozen_during_migration = False
                    self.prevented_persistence = False
                    self.write_settings()
                    self.write_version()
                else:
                    self.frozen_during_migration = True
                    self.prevented_persistence = True
                    LOGGER.debug("Migration not persisted")

    def migrate(self, persist=True):
        LOGGER.action("migrate profile in {}".format(self.location))
        if self.dry_run:
            return False
        if os.path.exists(self.backup_location):
            LOGGER.error(
                "{} already exists. Cannot migrate.".format(self.backup_location)
            )
            return False
        makedirs(self.backup_location)
        for name in self.migration_impact:
            if os.path.exists(os.path.join(self.location, name)):
                copy(
                    os.path.join(self.location, name),
                    os.path.join(self.backup_location, name),
                )
        try:
            res = self._migrate(persist)
        except Exception as e:
            import traceback
            LOGGER.error(e)
            LOGGER.develop(traceback.format_exc())
            res = False
        if res:
            rm(self.backup_location)
        else:
            if persist:
                LOGGER.warning(
                    "The migration of {} did not go well,"
                    " Restoring backup from {}".format(
                        self.location,
                        self.backup_location
                    )
                )
            for name in self.migration_impact:
                if os.path.exists(os.path.join(self.backup_location, name)):
                    if os.path.exists(os.path.join(self.location, name)):
                        rm(
                            os.path.join(self.location, name)
                        )
                    copy(
                        os.path.join(self.backup_location, name),
                        os.path.join(self.location, name),
                    )
            rm(self.backup_location)
        return res

    def _migrate(self, persist):
        for version, migrator in enumerate(self.migrate_from):
            if self.version == version:
                next_version = version + 1
                if persist:
                    LOGGER.info("Migrating from version {}"
                                " to version {}".format(version, next_version))
                if migrator():
                    self._version = next_version
                else:
                    LOGGER.error(
                        "Something went wrong"
                        " when migrating from "
                        "version {} to version {}".format(version, next_version)
                    )
                    return False
        if persist:
            LOGGER.status("Migration successful. Have a nice {} :-).".format(part_of_day()))
        return True


@ProfileFactory.register_preset_profile
class PresetProfile(Profile):
    def __init__(self, name, settings, explicit=True, isroot=True,
                 activation_level=ActivationLevel.global_, default_color=None):
        self.name = name
        self.default_color = default_color
        self.settings = settings
        self.recipes = []
        self.isroot = isroot
        self.explicit = explicit
        self.activation_level = activation_level
        self.isrecipe = False

    def get_settings(self, section):
        if (
                section not in self.settings
                and not isinstance(
                    self.settings,
                    collections.defaultdict
                )
        ):
            self.settings[section] = {}
        return self.settings[section]

    def set_settings(self, section, settings):
        self.settings[section] = settings

    def migrate_if_needed(self, persist=True):
        pass

    @property
    def recipe_link_names(self):
        return set()

    def has_recipe(self, name):
        return False

    def has_recipe_link(self, name):
        return False

    @property
    def friendly_name(self):
        return self.name

    def write_settings(self):
        click.UsageError("A preset profile cannot be written to")

    @property
    def short_name(self):
        return self.name

    def compute_settings(self):
        pass
