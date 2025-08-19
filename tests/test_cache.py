#!/usr/bin/env python3


def test_cache(pythondir, lib):
    # given a command that provides a value that changes at every call
    # and that allow to use a cached version
    (pythondir / "now.py").write_text("""
from clk.decorators import command, flag
from clk.core import cache_disk
from datetime import datetime


@cache_disk()
def cached_now():
    return datetime.now()


@command()
@flag("--cached")
@flag("--drop")
def now(cached, drop):
    ""
    handler = (cached_now if cached else datetime.now)
    if drop:
        cached_now.drop()
    print(handler())

""")
    # when I call the non cached version twice
    # then I can see they are different
    assert lib.cmd("now") != lib.cmd("now")
    # when I call the cached version twice
    # then I can see they are the same
    assert lib.cmd("now --cached") == lib.cmd("now --cached")
    # when I call the cached version twice while dropping the cache
    # then I can see they are different
    assert lib.cmd("now --cached --drop") != lib.cmd("now --cached --drop")
