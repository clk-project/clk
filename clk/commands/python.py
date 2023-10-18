#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys

from clk.decorators import argument, command
from clk.lib import call


@command(ignore_unknown_options=True)
@argument('args', nargs=-1, help='The rest of the command line to provide to python')
def python(args):
    """Run the python executable that is currently running clk"""
    call([sys.executable] + list(args))
