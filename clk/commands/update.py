#!/usr/bin/env python3


from clk import run
from clk.decorators import command, flag


@command()
@flag("--silent", help="Try to be as silent as possible")
def update(silent):
    """Upgrade clk"""
    pip_args = ["pip", "install", "--upgrade"]
    if silent:
        pip_args.append("--quiet")
    pip_args.append("clk")
    run(pip_args)
