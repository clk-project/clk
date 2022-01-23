#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk import lib


def test_natural_time():
    assert lib.natural_time(5) == '5 seconds ago'


def test_which():
    assert lib.which('ls') == '/usr/bin/ls'
