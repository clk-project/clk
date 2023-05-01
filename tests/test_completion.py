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
    assert lib.cmd('completion try a b --foo') == 'plain,a\nplain,b'
    assert lib.cmd('completion try a b --bar') == 'plain,c\nplain,d'
    assert lib.cmd('completion try --last a b --foo a --b') == 'plain,--bar'
    assert lib.cmd('completion try a b --foo a --bar') == 'plain,c\nplain,d'


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
    assert lib.cmd('completion try a b --foo') == 'plain,a\nplain,b'
    assert lib.cmd('completion try a b --bar') == 'plain,c\nplain,d'
    assert lib.cmd('completion try --last a b --foo a --b') == 'plain,--bar'
    assert lib.cmd('completion try a b --foo a --bar') == 'plain,c\nplain,d'


def test_dynamic_command(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.cmd('command which a')
    Path(path).write_text(
        Path(path).read_text() + """
from clk.decorators import option

class B:
    pass

@a.group()
@option(
    '--foo',
    expose_class=B,
    type=click.Choice(["a", "b"]),
    expose_value=True,
)
@option(
    '--bar',
    expose_class=B,
    type=click.Choice(["c", "d"]),
    expose_value=True,
)
def b(foo, bar):
    pass
""")
    assert lib.cmd('completion try a b --foo') == 'plain,a\nplain,b'
    assert lib.cmd('completion try a b --bar') == 'plain,c\nplain,d'
    assert lib.cmd('completion try --last a b --foo a --b') == 'plain,--bar'
    assert lib.cmd('completion try a b --foo a --bar') == 'plain,c\nplain,d'


def test_dynamic_group(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.cmd('command which a')
    Path(path).write_text(
        Path(path).read_text() + """
from clk.decorators import option
class B:
    pass

@a.group()
@option(
    '--foo',
    expose_class=B,
    type=click.Choice(["a", "b"]),
    expose_value=True,
)
@option(
    '--bar',
    expose_class=B,
    type=click.Choice(["c", "d"]),
    expose_value=True,
)
def b(foo, bar):
    pass

@b.command()
def c():
    pass
""")
    assert lib.cmd('completion try a b --foo') == 'plain,a\nplain,b'
    assert lib.cmd('completion try a b --bar') == 'plain,c\nplain,d'
    assert lib.cmd('completion try --last a b --foo a --b') == 'plain,--bar'
    assert lib.cmd('completion try a b --foo a --bar') == 'plain,c\nplain,d'


def test_exec(rootdir, lib):
    somebindir = Path(rootdir) / 'somebindir'
    os.makedirs(somebindir)
    somebinary = somebindir / 'somebinary'
    somebinary.write_text('''#!/bin/bash'
echo OK
''')
    somebinary.chmod(0o755)
    os.environ['PATH'] = os.environ['PATH'] + os.pathsep + str(somebindir)
    assert lib.cmd('completion try --last exec somebin') == 'plain,somebinary'
