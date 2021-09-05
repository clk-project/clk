#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from shlex import split
from subprocess import check_call, check_output

from lib import cmd, out, run


def test_simple_alias_command():
    check_call(split('clk alias set test echo a , echo b , echo c'), encoding='utf8')
    assert check_output(split('clk test'), encoding='utf-8') == 'a\nb\nc\n'


def test_alias_to_clk(project1):
    run(f'clk -P {project1} alias set a echo bou')
    run(f'clk alias set b clk -P {project1} a')
    assert out('clk b') == 'bou'


def test_alias_conserves_parameters():
    cmd('alias set a echo')
    cmd('parameter set echo foo')
    assert cmd('a') == 'foo'


def test_alias_conserves_parameters_of_group(pythondir):
    (pythondir / 'a.py').write_text("""
from clk.config import config
from clk.decorators import group, option
@group()
@option('-a')
def a(a):
    config.a = a

@a.command()
def b():
    print(config.a)
    print("b")""")
    assert cmd('a -a a b') == 'a\nb'
    cmd('parameter set a -a a')
    assert cmd('a b') == 'a\nb'
    cmd('alias set b a')
    assert cmd('b b') == 'a\nb'
    cmd('alias set a.c a b')
    assert cmd('a c') == 'a\nb'
