#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import click

from click_project.decorators import command, argument, option, flag
from click_project.colors import ColorType


@command(ignore_unknown_options=True, handle_dry_run=True)
@argument(u'args', nargs=-1)
@option("-s", "--style", type=ColorType(), help="Style of the message")
@flag("-n", "--no-newline/--newline", help="Do not append a newline"
      " (compatible with the bash version of echo -n)")
def echo(args, style, no_newline):
    u"""Log a message"""
    style = style or {}
    click.echo(click.style(' '.join(args), **style), nl=not no_newline)
