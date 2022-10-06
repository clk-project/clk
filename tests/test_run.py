#!/usr/bin/env python3
# -*- coding:utf-8 -*-


def test_can_edit_parameters(lib, pythondir):
    (pythondir / 'a.py').write_text("""
from clk.decorators import command
from clk import run

@command()
def a():
    run(["parameter", "set", "echo", "--style", "fg-yellow"])
    run(["parameter", "show", "echo"])
""")
    "--style fg-yellow" in lib.cmd('a')
