#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from click_project.setup import basic_entry_point, main


@basic_entry_point(
    __name__,
    extra_command_packages=["clk_commands", "clk_commands_perso"],
)
def clk(**kwargs):
    pass


if __name__ == "__main__":
    main()
