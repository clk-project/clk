#!/usr/bin/env python
# -*- coding: utf-8 -*-

from clk.config import config
from clk.decorators import argument, command, flag, option
from clk.launcher import launcher
from clk.lib import call, double_quote, updated_env
from clk.types import ExecutableType


@command(ignore_unknown_options=True, handle_dry_run=True)
@option('--shell/--no-shell', help='Execute the command through the shell')
@option('--stdout', help='File to which redirecting the standard output')
@option('--stderr', help='File to which redirecting the standard error')
@flag('--no-environ/--with-environ',
      help='Disable the environment variables set automatically when running'
      ' the exec command. Might be useful if it conflits with your internal stuff')
@launcher
@argument('command', nargs=-1, required=True, type=ExecutableType(), help='The command to execute')
def exec_(launcher_command, no_environ, launcher, shell, command, stdout, stderr):
    """Run a program, like good old times.

    The situations where using clk exec is advised rather than simply calling
    the program is when you need to embed a command into an alias, or when you
    want your command to take advantage of the parameters, dry-run or launchers.
    """
    if launcher:
        launcher_command = config.settings2['launchers'][launcher]
    if shell:
        command = [' '.join([command[0]] + [double_quote(arg) for arg in command[1:]])]
    out = open(stdout, 'wb') if stdout else None
    err = open(stderr, 'wb') if stderr else None
    with updated_env(**({} if no_environ else config.external_commands_environ_variables)):
        call(command, shell=shell, stdout=out, stderr=err, launcher_command=launcher_command)
