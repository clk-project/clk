#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path

from lib import cmd, out, run


def test_simple_bash():
    run('clk command create bash a --no-open')
    path = out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
echo foo""")
    assert out('clk a') == 'foo'


def test_simple_python():
    run('clk command create python a --no-open')
    path = out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
    print("foo")""")
    assert out('clk a') == 'foo'


def test_group_python():
    run('clk command create python a --no-open --group')
    path = out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
@a.command()
def b():
    print("b")
""")
    assert cmd('a b') == 'b'
