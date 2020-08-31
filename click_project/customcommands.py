#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
import subprocess
import json
import re
import importlib

import click
from pluginbase import PluginBase

from click_project.commandresolver import CommandResolver
from click_project.config import config
from click_project.lib import which, updated_env, quote
from click_project.log import get_logger

LOGGER = get_logger(__name__)


class BadCustomCommandError(Exception):
    pass


class CustomCommandResolver(CommandResolver):
    name = "customcommand"

    def __init__(self):
        self._base = None
        self._source = None

    @property
    def base(self):
        if self._base is None:
            self._base = PluginBase(package='click_project.customcommands')
        return self._base

    @property
    def source(self):
        if self._source is None:
            self._source = self.base.make_plugin_source(
                searchpath=config.get_settings2("customcommands").get("pythonpaths", []),
            )
        return self._source

    def _list_command_paths(self, parent=None):
        return self.source.list_plugins()

    def _get_command(self, path, parent=None):
        module = self.source.load_plugin(path)
        if path not in dir(module):
            raise BadCustomCommandError(
                f"The file {module.__file__} must contain a command or a group named {path}"
            )
        return getattr(module, path)
