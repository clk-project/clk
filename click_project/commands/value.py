#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import


from click_project.decorators import group, use_settings
from click_project.keyvaluestore import keyvaluestore_generic_commands
from click_project.log import get_logger

LOGGER = get_logger(__name__)


class ValueConfig(object):
    pass


@group(default_command='show')
@use_settings("value", ValueConfig)
def value():
    """Manipulate the values

    Values is a very simple key/value store in which you put any values you
    like.

    Values can be used in other commands by using the value: prefix. For
    example, you can try `value set click_project.is awesome` and run `echo
    value:click_project.is`

    """


keyvaluestore_generic_commands(value, "value")
