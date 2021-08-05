#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from shlex import split
from subprocess import check_call


def test_simple_extension():
    check_call(split("clk extension install hello"), encoding='utf8')
    check_call(split("clk hello"), encoding="utf-8")
