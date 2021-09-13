#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import flag
from clk.setup import basic_entry_point, main


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
