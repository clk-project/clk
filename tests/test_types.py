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
