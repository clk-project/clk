#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import absolute_import, print_function

from clk.decorators import argument, command
from clk.types import DirectoryProfileType


@command()
@argument("profile", type=DirectoryProfileType(()), help="The profile to describe")
def describe(profile):
    """Describe the given profile"""
    profile.describe()
