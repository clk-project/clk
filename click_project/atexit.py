#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

atexit_hooks = []


def register(function, *args, **kwargs):
    atexit_hooks.append(
        (function, args, kwargs)
    )


def trigger():
    for function, args, kwargs in atexit_hooks:
        function(*args, **kwargs)
