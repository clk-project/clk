#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

from clk.types import DirectoryProfileType
from clk.decorators import (
    command,
    argument,
)


@command()
@argument("profile", type=DirectoryProfileType(()), help="The profile to describe")
def describe(profile):
    """Describe the given profile"""
    profile.describe()
