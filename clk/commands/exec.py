#!/usr/bin/env python

from clk.config import config
from clk.decorators import argument, command, flag, option
from clk.lib import call, updated_env
from clk.types import ExecutableType


@command(ignore_unknown_options=True, handle_dry_run=True)
@option("--stdout", help="File to which redirecting the standard output")
@option("--stderr", help="File to which redirecting the standard error")
@flag(
    "--no-environ/--with-environ",
    help="Disable the environment variables set automatically when running"
    " the exec command. Might be useful if it conflits with your internal stuff",
)
@argument(
    "command",
    nargs=-1,
    required=True,
    type=ExecutableType(),
    help="The command to execute",
)
def exec_(no_environ, command, stdout, stderr):
    """Run a program, like good old times.

    The situations where using clk exec is advised rather than simply calling
    the program is when you need to embed a command into an alias.
    """
    out = open(stdout, "wb") if stdout else None
    err = open(stderr, "wb") if stderr else None
    with updated_env(
        **({} if no_environ else config.external_commands_environ_variables)
    ):
        call(
            command,
            stdout=out,
            stderr=err,
        )
