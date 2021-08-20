#!/usr/bin/env python
# -*- coding: utf-8 -*-

import click
from pluginbase import PluginBase

from clk.commandresolver import CommandResolver
from clk.config import config
from clk.log import get_logger
from clk.overloads import AutomaticOption

LOGGER = get_logger(__name__)


def edit_custom_command(path):
    click.edit(filename=path)
    exit(0)


class BadCustomCommandError(Exception):
    pass


class CustomCommandResolver(CommandResolver):
    name = 'customcommand'

    def __init__(self, settings=None):
        self._base = None
        self._source = None
        self.settings = settings

    @property
    def customcommands(self):
        return (self.settings.get('customcommands') if self.settings else config.get_settings2('customcommands'))

    @property
    def base(self):
        if self._base is None:
            self._base = PluginBase(package='clk.customcommands')
        return self._base

    @property
    def source(self):
        if self._source is None:
            self._source = self.base.make_plugin_source(searchpath=list(
                reversed(self.customcommands.get('pythonpaths', []))), )
        return self._source

    def _list_command_paths(self, parent=None):
        return self.source.list_plugins()

    def _get_command(self, path, parent=None):
        module = self.source.load_plugin(path)
        if path not in dir(module):
            raise BadCustomCommandError(f'The file {module.__file__} must contain a command or a group named {path}')
        cmd = getattr(module, path)
        cmd.customcommand_path = module.__file__
        cmd.params.append(
            AutomaticOption(['--edit-command'],
                            is_flag=True,
                            expose_value=False,
                            help='Edit this command',
                            callback=lambda ctx, param, value: edit_custom_command(cmd.customcommand_path)
                            if value is True else None))
        return cmd
