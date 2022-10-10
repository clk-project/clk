#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import flag, group
from clk.log import get_logger

LOGGER = get_logger(__name__)


@group()
@flag('--shuffle', help='Pick podcasts at random')
def podcast(shuffle):
    'Deal with podcasts'
    print(f'shuffle: {shuffle}')
