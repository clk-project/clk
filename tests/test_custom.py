#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path


def test_simple_bash(lib):
    lib.run('clk command create bash a --no-open')
    path = lib.out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
echo foo""")
    assert lib.out('clk a') == 'foo'


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
