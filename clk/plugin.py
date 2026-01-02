#!/usr/bin/env python

from clk.config import config
from clk.log import get_logger
from clk.profile import DirectoryProfile

LOGGER = get_logger(__name__)

afterloads = []
afterloads_cache = set()


def load_plugins():
    directory_profiles = [
        profile
        for profile in config.all_profiles
        if isinstance(profile, DirectoryProfile)
    ]
    for profile in directory_profiles:
        profile.load_plugins()

    config.init()
