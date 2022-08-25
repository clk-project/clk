#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path

from clk.lib import cd


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


def test_custom_types_in_command(lib):
    lib.create_bash_command(
        'a', """#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Test custom types
--
O:--someday:date:Some date
O:--somefile:file:Some file
EOF
}

clk_help_handler "$@"

if ! clk_is_null someday
then
   echo ${CLK___SOMEDAY}
fi
if ! clk_is_null somefile
then
   echo ${CLK___SOMEFILE}
fi

""")
    assert lib.cmd('completion try --last a --someday next\ da') == 'next\\ day'  # noqa: W605
    assert lib.cmd('completion try --last a --someday last\ sun') == 'last\\ sunday'  # noqa: W605
    assert lib.cmd('completion try --last a --someday in\ two\ mont') == 'in\\ two\\ months'  # noqa: W605
    assert lib.cmd('completion try --last a --someday two\ days\ a') == 'two\\ days\\ ago'  # noqa: W605
    assert lib.cmd('a --someday "2022/08/30"') == '2022-08-30T00:00:00'
    # only deals with dates, not time
    assert lib.cmd('a --someday "2022/08/30 18:12"') == '2022-08-30T00:00:00'
    with cd('/tmp'):
        assert lib.cmd('a --somefile .') == '/tmp'
