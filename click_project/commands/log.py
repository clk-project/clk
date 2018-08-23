#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import click

from click_project.log import LOG_LEVELS, get_logger
from click_project.decorators import command, argument, option

LOGGER = get_logger(__name__)


@command(ignore_unknown_options=True, handle_dry_run=True)
@option('-l', '--level', default=None, type=click.Choice(LOG_LEVELS.keys()), help="Log level")
@argument(u'message', nargs=-1, help="The message to log")
def log(level, message):
    u"""Log a message"""
    LOGGER.log(LOG_LEVELS[level], ' '.join(message))
