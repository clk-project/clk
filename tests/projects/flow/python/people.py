#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.config import config
from clk.decorators import argument, group, option
from clk.log import get_logger

LOGGER = get_logger(__name__)


@group()
@option('--person', multiple=True, help='Use this person')
def people(person):
    'Do things with people'
    config.people = person


@people.command()
@argument('message', help='Some message to say', nargs=-1)
def say(message):
    """Make them talk"""
    print(f"{', '.join(config.people)}: {' '.join(message)}")
