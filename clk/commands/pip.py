#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys

from clk.decorators import argument, command
from clk.lib import call


@command(ignore_unknown_options=True)
@argument('args', nargs=-1, help='The rest of the command line to provide to pip')
def pip(args):
    """Run pip in the context of this installation of clk"""
    call([sys.executable, '-m', 'pip'] + list(args))
