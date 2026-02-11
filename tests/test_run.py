#!/usr/bin/env python3


def test_can_edit_parameters(lib, pythondir):
    (pythondir / "a.py").write_text("""
from clk.decorators import group
from clk import run

@group()
def a():
    pass

@a.command()
def b():
    run(["parameter", "set", "echo", "--style", "fg-yellow"])

@a.command()
def c():
    run(["parameter", "show", "echo"])
""")
    lib.cmd("a b")
    "--style fg-yellow" in lib.cmd("a c")
