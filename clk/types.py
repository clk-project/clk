#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
from datetime import datetime
from itertools import product

import click

from clk.completion import startswith
from clk.config import config
from clk.core import ColorType as Color  # NOQA: just expose the object
from clk.core import DynamicChoiceType as DynamicChoice  # NOQA: just expose the object
from clk.core import ExtensionType as Extension  # NOQA: just expose the object
from clk.core import ExtensionTypeSuggestion as ExtensionSuggestion  # NOQA: just expose the object
from clk.core import cache_disk
from clk.launcher import LauncherCommandType as LauncherCommand  # NOQA: just expose the object
from clk.launcher import LauncherType as launcher  # NOQA: just expose the object
from clk.lib import ParameterType as Parameter  # NOQA: just expose the object
from clk.log import get_logger
from clk.overloads import CommandSettingsKeyType, CommandType  # NOQA: just expose the object

LOGGER = get_logger(__name__)


class Suggestion(click.Choice):
    name = 'Suggestion'

    def convert(self, value, param, ctx):
        return value

    def get_metavar(self, param):
        return '[{}|...]'.format('|'.join(self.choices))


class Date(DynamicChoice):
    name = 'date'

    def choices(self):
        number = ['one', 'two', 'three', 'four', 'five']
        period = ['day', 'week', 'month', 'year']
        weekday = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
        return [
            'today',
            'yesterday',
            'tomorrow',
        ] + [f'{a} {b}' for a, b in product(
            ['next', 'last'],
            period + weekday,
        )] + [f"{a} {b}{'' if a == 'one' else 's'} ago" for a, b in product(
            number,
            period + weekday,
        )] + [f"in {a} {b}{'' if a == 'one' else 's'}" for a, b in product(
            number,
            period + weekday,
        )] + [f"{a} {b}{'' if a == 'one' else 's'}" for a, b in product(
            number,
            period + weekday,
        )]

    def convert(self, value, param, ctx):
        if not isinstance(value, str):
            # already converted
            return value
        from dateutil.parser import ParserError, parse
        try:
            date = parse(value)
        except ParserError:
            from clk.lib import parsedatetime
            date = parsedatetime(value)[0]
        date = datetime(date.year, date.month, date.day)
        LOGGER.develop(f'Got date {param.name if param is not None else "NA"}={date}')
        return date


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


class ExecutableType(Parameter):

    def shell_complete(self, ctx, param, incomplete):
        completion = set()
        for path in self.path(ctx):
            for file in os.listdir(path):
                if startswith(file, incomplete):
                    completion.add(click.shell_completion.CompletionItem(file))
        return completion

    @cache_disk(expire=600)
    def path(self, ctx):
        return [path for path in os.environ['PATH'].split(os.pathsep) if os.path.exists(path)]
