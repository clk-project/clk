#!/usr/bin/env python
# -*- coding: utf-8 -*-

import shlex

from click.shell_completion import CompletionItem

from clk.completion import startswith
from clk.config import config
from clk.lib import ParameterType, quote
from clk.overloads import option


class LauncherCommandType(ParameterType):

    def shell_complete(self, ctx, param, incomplete):
        choices = [' '.join([quote(v) for v in value]) for value in config.settings.get('launchers', {}).values()]
        return [CompletionItem(launcher) for launcher in choices if startswith(launcher, incomplete)]

    def convert(self, value, param, ctx):
        if not isinstance(value, str):
            # already converted
            return value
        return shlex.split(value)


class LauncherType(ParameterType):

    def __init__(self, missing_ok=False):
        ParameterType.__init__(self)
        self.missing_ok = missing_ok

    def shell_complete(self, ctx, param, incomplete):
        choices = config.settings.get('launchers', {}).keys()
        return [CompletionItem(launcher) for launcher in choices if startswith(launcher, incomplete)]

    def convert(self, value, param, ctx):
        if self.missing_ok:
            return value
        choices = config.settings.get('launchers', {}).keys()
        if value not in choices:
            self.fail('invalid choice: %s. (choose from %s)' % (value, ', '.join(choices)), param, ctx)
        return value


def launcher(func):
    """Option decorator fer the commands using a launcher"""
    opts = [
        option('--launcher-command',
               help=('Extra arguments to prepend to the simulation command.'
                     ' Ignored if --launcher is given.'),
               type=LauncherCommandType(),
               group='launcher'),
        option('-l',
               '--launcher',
               help=('Name of the launcher to prepend to the simulation command.'
                     ' It overrides --launcher-command.'
                     ' See the launchers commands for more information'),
               type=LauncherType(),
               group='launcher')
    ]
    for opt in reversed(opts):
        func = opt(func)
    return func
