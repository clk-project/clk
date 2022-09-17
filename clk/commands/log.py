#!/usr/bin/env python
# -*- coding: utf-8 -*-

import click

from clk.decorators import argument, command, flag, option
from clk.lib import call
from clk.log import LOG_LEVELS, get_logger

LOGGER = get_logger(__name__)


@command(ignore_unknown_options=True, handle_dry_run=True)
@option('-l', '--level', default='info', type=click.Choice(LOG_LEVELS.keys()), help='Log level')
@flag('--notify', help='Also send the log into notify-send')
@argument(u'message', nargs=-1, help='The message to log')
def log(level, message, notify):
    u'''Log a message'''
    message = ' '.join(message)
    LOGGER.log(LOG_LEVELS[level], message)
    if notify:
        call(['notify-send', message])
