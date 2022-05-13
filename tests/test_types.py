#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path


def test_suggestion(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.cmd('command which a')
    Path(path).write_text(
        Path(path).read_text() + """
from clk.types import Suggestion
@a.command()
@option("--something", type=Suggestion(['a', 'b']))
def b(something):
    print(something)
""")
    assert lib.cmd('a b --something c') == 'c'
    assert lib.cmd('completion try a b --something') == 'a\tb'


def test_date(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.cmd('command which a')
    Path(path).write_text(
        Path(path).read_text() + """
from clk.types import Date
@a.command()
@option("--someday", type=Date())
def b(someday):
    print(f"{someday:%Y-%m-%d}")
""")
    assert lib.cmd('a b --someday "May 4th 2022"') == '2022-05-04'
    assert lib.cmd('a b --someday "2022-05-04"') == '2022-05-04'
