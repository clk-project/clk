#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os

from click_project.decorators import command, option, argument
from click_project.core import cache_disk
from click_project.lib import call, double_quote, ParameterType
from click_project.completion import startswith
from click_project.launcher import launcher
from click_project.config import config


class ExecutableType(ParameterType):
    def complete(self, ctx, incomplete):
        completion = set()
        for path in self.path(ctx):
            for file in os.listdir(path):
                if startswith(file, incomplete):
                    completion.add(file)
        return completion

    @cache_disk(expire=600)
    def path(self, ctx):
        return [
            path for path in
            os.environ["PATH"].split(os.pathsep)
            if os.path.exists(path)
        ]


@command(ignore_unknown_options=True, handle_dry_run=True)
@option('--shell/--no-shell', help="Execute the command through the shell")
@option('--stdout', help="File to which redirecting the standard output")
@option('--stderr', help="File to which redirecting the standard error")
@launcher
@argument('command', nargs=-1, required=True, type=ExecutableType(), help="The command to execute")
def exec_(launcher_command, launcher, shell, command, stdout, stderr):
    """Run a command."""
    if launcher:
        launcher_command = config.settings2["launchers"][launcher]
    if shell:
        command = [' '.join([command[0]] + [double_quote(arg) for arg in command[1:]])]
    out = open(stdout, "wb") if stdout else None
    err = open(stderr, "wb") if stderr else None
    call(command, shell=shell, stdout=out, stderr=err, launcher_command=launcher_command)
