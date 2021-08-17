#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
from importlib.abc import Loader, MetaPathFinder

from clk.decorators import flag
from clk.setup import basic_entry_point, main

warned_cache = []


def warn_about_bad_import():
    import os
    if not os.environ.get('CLK_WARN_ABOUT_BAD_IMPORT'):
        return
    ignore_value = 'idontcarefornowbutishoulddefinitelyfixthoseimportssomeday'
    if os.environ.get('CLK_IGNORE_IMPORT_WARNINGS') == ignore_value:
        return
    from traceback import extract_stack
    stack = extract_stack()
    from clk.log import get_logger
    LOGGER = get_logger('clk.BADIMPORT')
    warning_number = 0
    for frame in reversed(stack):
        if 'click_project' in frame.line:
            if frame in warned_cache:
                continue
            else:
                warned_cache.append(frame)
                warning_number += 1
            LOGGER.deprecated(
                f"""BAD IMPORT in file {frame.filename} at line {frame.lineno}: You should fix the line from
      {frame.line}
to
      {frame.line.replace('click_project', 'clk')}
""")
    if warning_number > 0:
        LOGGER.deprecated(f"To silence {'this' if warning_number == 1 else 'those'}"
                          f" warning{'' if warning_number == 1 else 's'}, fix the problem!..."
                          ' or set the environment variable'
                          ' CLK_IGNORE_IMPORT_WARNINGS to the value'
                          f" '{ignore_value}'")


class DeprecatedLoader(Loader):
    def create_module(self, spec):
        from importlib import import_module
        assert spec.name.startswith(
            'click_project'), f'This loader is only meant to load click-project modules, {spec.name} was given'
        warn_about_bad_import()
        name = 'clk' + spec.name[len('click_project'):]
        module = import_module(name)
        return module

    def exec_module(self, module):
        return


class DeprecatedFinder(MetaPathFinder):
    def find_spec(self, fullname, path, target=None):
        if fullname.startswith('click_project'):
            from importlib.machinery import ModuleSpec
            return ModuleSpec(fullname, DeprecatedLoader())
        else:
            return None


sys.meta_path.insert(0, DeprecatedFinder())


def print_version(ctx, attr, value):
    if value:
        from clk._version import get_versions
        print(get_versions()['version'])
        exit(0)


@basic_entry_point(__name__)
@flag('--version', help='Print the version of clk and exits', callback=print_version)
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


if __name__ == '__main__':
    main()
