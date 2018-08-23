#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

from click_project.config import config
from click_project.decorators import command, argument
from click_project.overloads import CommandType


@command(handle_dry_run=True)
@argument('args', nargs=-1, type=CommandType(), help="The command for which the help will be displayed")
def help(args):
    """Display help information"""
    config.main_command(list(args) + ['--help'])
