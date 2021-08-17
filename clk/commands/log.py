#!/usr/bin/env python
# -*- coding: utf-8 -*-

import click

from clk.decorators import argument, command, option
from clk.log import LOG_LEVELS, get_logger

LOGGER = get_logger(__name__)


@command(ignore_unknown_options=True, handle_dry_run=True)
@option('-l', '--level', default='info', type=click.Choice(LOG_LEVELS.keys()), help='Log level')
@argument(u'message', nargs=-1, help='The message to log')
def log(level, message):
    u"""Log a message"""
    LOGGER.log(LOG_LEVELS[level], ' '.join(message))
