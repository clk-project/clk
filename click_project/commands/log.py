#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import logging

import click

from click_project.log import LOG_LEVELS
from click_project.decorators import command, argument, option

LOGGER = logging.getLogger(__name__)


@command(ignore_unknown_options=True, handle_dry_run=True)
@option('-l', '--level', default=None, type=click.Choice(LOG_LEVELS.keys()), help="Log level")
@argument(u'args', nargs=-1)
def log(level, args):
    u"""Log a message"""
    LOGGER.log(LOG_LEVELS[level], ' '.join(args))
