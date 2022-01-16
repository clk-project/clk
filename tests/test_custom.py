#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path


def test_complete_remove(lib):
    lib.run('clk command create bash a --no-open')
    candidates = lib.out('clk completion try command remove')
    assert 'a' == candidates


def test_simple_bash(lib):
    lib.run('clk command create bash a --no-open')
    path = lib.out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
echo foo""")
    assert lib.out('clk a') == 'foo'


def test_default_help_message_triggers_a_warning(lib):
    lib.run('clk command create bash a --no-open')
    lib.run('clk command create python b --no-open')
    output = lib.out('clk a', with_err=True)
    assert output == "warning: The command 'a' has no documentation"
    output = lib.out('clk b', with_err=True)
    assert output == "warning: The command 'b' has no documentation"


def test_simple_python(lib):
    lib.run('clk command create python a --no-open')
    path = lib.out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
    print("foo")""")
    assert lib.out('clk a') == 'foo'


def test_group_python(lib):
    lib.run('clk command create python a --no-open --group')
    path = lib.out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
@a.command()
def b():
    print("b")
""")
    assert lib.cmd('a b') == 'b'
