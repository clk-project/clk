#!/usr/bin/env python
# -*- coding: utf-8 -*-

from clk.decorators import argument, command
from clk.types import DirectoryProfile as DirectoryProfileType


@command()
@argument('profile', type=DirectoryProfileType(()), help='The profile to describe')
def describe(profile):
    """Describe the given profile"""
    profile.describe()
