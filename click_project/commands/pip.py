#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import sys

from click_project.decorators import command, argument
from click_project.lib import call


@command(ignore_unknown_options=True)
@argument("args", nargs=-1, help="The rest of the command line to provide to pip")
def pip(args):
    """Run pip in the context of this installation of click-project"""
    call(
        [
            sys.executable,
            "-m",
            "pip"
        ]
        + list(args)
    )
