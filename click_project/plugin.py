#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import


from click_project.config import config
from click_project.log import get_logger
from click_project.profile import DirectoryProfile

LOGGER = get_logger(__name__)


afterloads = []
afterloads_cache = set()


def load_plugins():
    directory_profiles = [
        profile for profile in config.all_profiles
        if isinstance(profile, DirectoryProfile)
    ]
    for profile in directory_profiles:
        profile.load_plugins()

    for hook in afterloads:
        if hook not in afterloads_cache:
            hook()
            afterloads_cache.add(hook)
    config.init()
