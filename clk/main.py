#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from clk.setup import basic_entry_point, main
from clk.decorators import flag
from importlib.abc import MetaPathFinder, Loader
import sys


class DeprecatedLoader(Loader):
    def create_module(self, spec):
        from importlib import import_module
        assert spec.name.startswith(
            "click_project"), f"This loader is only meant to load click-project modules, {spec.name} was given"
        name = "clk" + spec.name[len("click_project"):]
        module = import_module(name)
        return module

    def exec_module(self, module):
        return


class DeprecatedFinder(MetaPathFinder):
    def find_spec(self, fullname, path, target=None):
        if fullname.startswith("click_project"):
            from importlib.machinery import ModuleSpec
            return ModuleSpec(fullname, DeprecatedLoader())
        else:
            return None


sys.meta_path.insert(0, DeprecatedFinder())


def print_version(ctx, attr, value):
    if value:
        from clk._version import get_versions
        print(get_versions()["version"])
        exit(0)


@basic_entry_point(
    __name__,
    extra_command_packages=["clk_commands", "clk_commands_perso"],
)
@flag("--version", help="Print the version of clk and exits", callback=print_version)
def clk(**kwargs):
    """This is the click project (a.k.a. clk) entry point.

clk is a tool that help you create your own command line workflow.

It was born out of the frustration of seeing so many command line tools that do
not provide a good user experience, with the bad excuses that, well, those
are command line interfaces and them are bad experience by default.

We truly believe that command line usage should be fast, intuitive and grow
organically.

clk comes with a very powerful completion mechanism, automatic command line
configuration, aliases, custom commands, plugins, project based configuration
and many more useful stuff we should see more often in command line interfaces.

If you are new to clk, I warmly suggest you first try `clk learn` so that you
can learn the concepts and the tooling around them.

    """


if __name__ == "__main__":
    main()
