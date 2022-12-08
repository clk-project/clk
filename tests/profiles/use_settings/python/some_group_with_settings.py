#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.config import config
from clk.decorators import argument, flag, group, use_settings
from clk.log import get_logger
from clk.types import CommandSettingsKeyType

LOGGER = get_logger(__name__)


class MySettings:
    pass


@group()
@use_settings('some_settings', MySettings)
def some_group_with_settings():
    """Commands of this group have access to the settings called some_settings"""


@some_group_with_settings.command()
def set():
    """Put some default values"""
    config.some_settings.writable['some-key'] = ['some', 'list']
    config.some_settings.writable['some-other-key'] = {'some': 'dict'}
    config.some_settings.write()


@some_group_with_settings.command()
@argument('key', type=CommandSettingsKeyType('some_settings'), help='Chose your key')
@flag('--use-settings', help='Use settings instead of the standard way')
@flag('--use-settings2', help='Use settings2 instead of the standard way')
def show(key, use_settings, use_settings2):
    """Simply print the settings"""
    if use_settings:
        print(config.settings['some_settings'][key])
    elif use_settings2:
        print(config.settings2['some_settings'][key])
    else:
        print(config.some_settings.readonly[key])
