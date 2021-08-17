#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import click

from clk.config import config
from clk.core import ColorType as Color  # NOQA: just expose the object
from clk.core import DynamicChoiceType as DynamicChoice  # NOQA: just expose the object
from clk.core import ExtensionType as Extension  # NOQA: just expose the object
from clk.core import ExtensionTypeSuggestion as ExtensionSuggestion  # NOQA: just expose the object
from clk.launcher import LauncherCommandType as LauncherCommand  # NOQA: just expose the object
from clk.launcher import LauncherType as launcher  # NOQA: just expose the object
from clk.lib import ParameterType as Parameter  # NOQA: just expose the object
from clk.overloads import CommandSettingsKeyType, CommandType  # NOQA: just expose the object


class Suggestion(click.Choice):
    name = 'Suggestion'

    def convert(self, value, param, ctx):
        return value

    def get_metavar(self, param):
        return '[{}|...]'.format('|'.join(self.choices))

    def get_missing_message(self, param):
        return ('Either choose from:\n\t{}.' ' or provide a new one'.format(',\n\t'.join(self.choices)))


class Profile(DynamicChoice):
    name = 'ProfileType'

    def choices(self):
        return self.profiles.keys()

    @property
    def profiles(self):
        return {profile.name: profile for profile in config.all_profiles}

    def converter(self, value):
        return self.profiles[value]


class DirectoryProfile(Profile):
    name = 'DirectoryProfileType'

    def __init__(self, root_only=False):
        self.root_only = root_only

    @property
    def profiles(self):
        from clk.profile import DirectoryProfile
        return {
            name: profile
            for name, profile in super().profiles.items()
            if isinstance(profile, DirectoryProfile) and (not self.root_only or profile.isroot)
        }
