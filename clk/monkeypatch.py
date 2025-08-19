#!/usr/bin/env python

from click import Context

old_lookup_default = Context.lookup_default


def context_lookup_default(self, name, **kwargs):
    if not hasattr(self, "clk_default_catch"):
        self.clk_default_catch = set()
    self.clk_default_catch.add(name)
    return old_lookup_default(self, name, **kwargs)


def do():
    Context.lookup_default = context_lookup_default
