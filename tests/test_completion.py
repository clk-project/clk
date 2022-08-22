#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from pathlib import Path


def test_command(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.cmd('command which a')
    Path(path).write_text(
        Path(path).read_text() + """
@a.command()
@option("--foo", type=click.Choice(["a", "b"]))
@option("--bar", type=click.Choice(["c", "d"]))
def b(foo, bar):
    pass
""")
    assert lib.cmd('completion try a b --foo') == 'a\tb'
    assert lib.cmd('completion try a b --bar') == 'c\td'
    assert lib.cmd('completion try --last a b --foo a --b') == '--bar'
    assert lib.cmd('completion try a b --foo a --bar') == 'c\td'


def test_group(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.cmd('command which a')
    Path(path).write_text(
        Path(path).read_text() + """
@a.group()
@option("--foo", type=click.Choice(["a", "b"]))
@option("--bar", type=click.Choice(["c", "d"]))
def b(foo, bar):
    pass

@b.command()
def c():
    pass
""")
    assert lib.cmd('completion try a b --foo') == 'a\tb'
    assert lib.cmd('completion try a b --bar') == 'c\td'
    assert lib.cmd('completion try --last a b --foo a --b') == '--bar'
    assert lib.cmd('completion try a b --foo a --bar') == 'c\td'


def test_dynamic_command(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.cmd('command which a')
    Path(path).write_text(
        Path(path).read_text() + """
from clk.decorators import param_config

@a.group()
@param_config(
    'b',
    '--foo',
    type=click.Choice(["a", "b"]),
    expose_value=True,
)
@param_config(
    'b',
    '--bar',
    type=click.Choice(["c", "d"]),
    expose_value=True,
)
def b(foo, bar):
    pass
""")
    assert lib.cmd('completion try a b --foo') == 'a\tb'
    assert lib.cmd('completion try a b --bar') == 'c\td'
    assert lib.cmd('completion try --last a b --foo a --b') == '--bar'
    assert lib.cmd('completion try a b --foo a --bar') == 'c\td'


def test_dynamic_group(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.cmd('command which a')
    Path(path).write_text(
        Path(path).read_text() + """
from clk.decorators import param_config

@a.group()
@param_config(
    'b',
    '--foo',
    type=click.Choice(["a", "b"]),
    expose_value=True,
)
@param_config(
    'b',
    '--bar',
    type=click.Choice(["c", "d"]),
    expose_value=True,
)
def b(foo, bar):
    pass

@b.command()
def c():
    pass
""")
    assert lib.cmd('completion try a b --foo') == 'a\tb'
    assert lib.cmd('completion try a b --bar') == 'c\td'
    assert lib.cmd('completion try --last a b --foo a --b') == '--bar'
    assert lib.cmd('completion try a b --foo a --bar') == 'c\td'


def test_exec(rootdir, lib):
    somebindir = Path(rootdir) / 'somebindir'
    os.makedirs(somebindir)
    somebinary = somebindir / 'somebinary'
    somebinary.write_text('''#!/bin/bash'
echo OK
''')
    somebinary.chmod(0o755)
    os.environ['PATH'] = os.environ['PATH'] + os.pathsep + str(somebindir)
    assert lib.cmd('completion try --last exec somebin') == 'somebinary'
