#!/usr/bin/env python
# -*- coding: utf-8 -*-

import click

from clk.colors import ColorType
from clk.decorators import argument, command, flag, option


@command(ignore_unknown_options=True, handle_dry_run=True)
@option('-s', '--style', type=ColorType(), help='Style of the message')
@flag('-n', '--no-newline/--newline', help='Do not append a newline' ' (compatible with the bash version of echo -n)')
@argument(u'message', nargs=-1, help='The message to display')
def echo(message, style, no_newline):
    u"""Log a message"""
    style = style or {}
    click.echo(click.style(' '.join(message), **style), nl=not no_newline)
