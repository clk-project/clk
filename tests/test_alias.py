#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from shlex import split
from subprocess import check_call, check_output


def test_simple_alias_command():
    check_call(split('clk alias set test echo a , echo b , echo c'), encoding='utf8')
    assert check_output(split('clk test'), encoding='utf-8') == 'a\nb\nc\n'
