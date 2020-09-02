#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from click_project.setup import basic_entry_point, main
from click_project.decorators import flag


def print_version(ctx, attr, value):
    if value:
        from click_project._version import get_versions
        print(get_versions()["version"])
        exit(0)


@basic_entry_point(
    __name__,
    extra_command_packages=["clk_commands", "clk_commands_perso"],
)
@flag("--version", help="Print the version of click-project and exits",
      callback=print_version)
def clk(**kwargs):
    pass


if __name__ == "__main__":
    main()
