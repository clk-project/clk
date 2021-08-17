#!/usr/bin/env python
# -*- coding: utf-8 -*-

from clk.config import config
from clk.decorators import argument, command
from clk.overloads import CommandType


@command(handle_dry_run=True)
@argument('args', nargs=-1, type=CommandType(), help='The command for which the help will be displayed')
def help(args):
    """Display help information"""
    config.main_command(list(args) + ['--help'])
