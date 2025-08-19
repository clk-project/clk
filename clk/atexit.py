#!/usr/bin/env python

atexit_hooks = []


def register(function, *args, **kwargs):
    atexit_hooks.append((function, args, kwargs))


def trigger():
    for function, args, kwargs in atexit_hooks:
        function(*args, **kwargs)
