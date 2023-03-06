#!/usr/bin/env python
# -*- coding: utf-8 -*-

import fnmatch as fnmatchlib
import os

CASE_INSENSITIVE_ENV = '_CLK_CASE_INSENSITIVE_COMPLETION'
COMPLETE_OPTIONS = '_CLK_COMPLETE_OPTIONS'


def startswith(string, incomplete):
    if os.environ.get(CASE_INSENSITIVE_ENV):
        string = string.lower()
        incomplete = incomplete.lower()
    return string.startswith(incomplete)


def fnmatch(string, incomplete):
    if os.environ.get(CASE_INSENSITIVE_ENV):
        string = string.lower()
        incomplete = incomplete.lower()
    return fnmatchlib.fnmatch(string, incomplete)


IN_COMPLETION = None
