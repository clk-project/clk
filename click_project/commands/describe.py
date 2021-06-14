#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

from click_project.types import DirectoryProfileType
from click_project.decorators import (
    command,
    argument,
)


@command()
@argument("profile", type=DirectoryProfileType(()), help="The profile to describe")
def describe(profile):
    """Describe the given profile"""
    profile.describe()
