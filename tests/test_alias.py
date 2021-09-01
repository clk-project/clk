#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from shlex import split
from subprocess import check_call, check_output

from lib import out, run


def test_simple_alias_command():
    check_call(split('clk alias set test echo a , echo b , echo c'), encoding='utf8')
    assert check_output(split('clk test'), encoding='utf-8') == 'a\nb\nc\n'


def test_alias_to_clk(project1):
    run(f'clk -P {project1} alias set a echo bou')
    run(f'clk alias set b clk -P {project1} a')
    assert out('clk b') == 'bou'
