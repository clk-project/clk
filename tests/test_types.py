#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path


def test_default_with_converter(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.cmd('command which a')
    Path(path).write_text(
        Path(path).read_text() + """

class Test(DynamicChoice):

    def choices(self):
        return ["foo", "bar"]

    def converter(self, value):
        return value.upper()


@a.command()
@option("--test", default="foo", type=Test())
def test(test):
    "Description"
    print(test)
""")
    assert lib.cmd('a test --test bar') == 'BAR'
    assert lib.cmd('a test') == 'FOO'


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


def test_complete_date(lib):
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
    assert lib.cmd('completion try --last a b --someday next\ da') == 'next\\ day'  # noqa: W605
    assert lib.cmd('completion try --last a b --someday last\ sun') == 'last\\ sunday'  # noqa: W605
    assert lib.cmd('completion try --last a b --someday in\ two\ mont') == 'in\\ two\\ months'  # noqa: W605
    assert lib.cmd('completion try --last a b --someday two\ days\ a') == 'two\\ days\\ ago'  # noqa: W605
