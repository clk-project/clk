#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

from click_project.overloads import MainCommand
from click_project.core import main, main_command
from click_project.log import get_logger
from click_project.setup import classic_setup

LOGGER = get_logger(__name__)


@classic_setup(__name__)
@main_command(MainCommand)
def click_project(**kwargs):
    pass


if __name__ == "__main__":
    main()
