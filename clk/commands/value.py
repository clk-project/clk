#!/usr/bin/env python
# -*- coding: utf-8 -*-

from clk.decorators import group, use_settings
from clk.keyvaluestore import keyvaluestore_generic_commands
from clk.log import get_logger

LOGGER = get_logger(__name__)


class ValueConfig(object):
    pass


@group(default_command='show')
@use_settings('value', ValueConfig)
def value():
    """Manipulate the values

    Values is a very simple key/value store in which you put any values you
    like.

    Values can be used in other commands by using the value: prefix. For
    example, you can try `value set clk.is awesome` and run `echo
    value:clk.is`

    """


keyvaluestore_generic_commands(value, 'value')
