#!/usr/bin/env python

import click

from clk.colors import Colorer
from clk.config import config
from clk.decorators import (
    argument,
    flag,
    group,
    pass_context,
    table_fields,
    table_format,
    use_settings,
)
from clk.launcher import LauncherType
from clk.lib import TablePrinter, quote
from clk.log import get_logger

LOGGER = get_logger(__name__)


class LaunchersConfig:
    pass


@group(default_command="show")
@use_settings("launchers", LaunchersConfig, override=False)
def launcher():
    """Manipulate launchers

    Also called wrapper or runner, a launcher is a tool that runs other
    tools. There are plenty of categories of launchers: debuggers (gdb),
    memory/CPU profilers (valgrind), communication helpers (dbus-launch),
    graphical environment emulatord (Xvfb-run), etc.

    Generally, during the life time of a project one needs to calibrate
    launchers by a set of arguments. This commands gives you the possibility to
    record simple launchers so as to use them in several commands, like
    simulate. You give a name to each launcher so as to simply trigger them with
    a simple word.

    Some general purpose launchers are already available like gdb or valgrind.

    Generally, one sets a launcher with the set command giving the launcher name
    and command to run, for example: launcher set cow cowsay -T OO
    """
    pass


@launcher.command(
    ignore_unknown_options=True, change_directory_options=False, handle_dry_run=True
)
@argument("launcher", type=LauncherType(missing_ok=True), help="The launcher name")
@argument("command", nargs=-1, help="The launcher command")
def set(launcher, command):
    """Set a launcher"""
    config.launchers.writable[launcher] = command
    config.launchers.write()


@launcher.command(ignore_unknown_options=True, handle_dry_run=True)
@argument("launcher", type=LauncherType(), help="The launcher name")
@argument("params", nargs=-1, help="The parameters to append")
def append(launcher, params):
    """Add a parameters at the end of a launcher"""
    params = config.launchers.writable.get(launcher, []) + list(params)
    config.launchers.writable[launcher] = params
    config.launchers.write()


@launcher.command(handle_dry_run=True)
@argument("launchers", nargs=-1, type=LauncherType(), help="The launcher name")
def unset(launchers):
    """Unset a launcher"""
    for launcher in launchers:
        if launcher not in config.launchers.writable:
            raise click.ClickException(
                "The command %s has no parameter registered in the %s configuration."
                "Try using another profile option (like --local or --global)"
                % (launcher, config.launchers.writeprofile)
            )
    for launcher in launchers:
        LOGGER.status(
            "Erasing {} launchers from {} settings".format(
                launcher, config.launchers.writeprofile
            )
        )
        del config.launchers.writable[launcher]
    config.launchers.write()


@launcher.command(handle_dry_run=True)
@flag("--name-only/--no-name-only", help="Only display the command names")
@Colorer.color_options(full_default=True)
@table_format(default="key_value")
@table_fields(choices=["launcher", "command"])
@argument(
    "launchers", nargs=-1, default=None, type=LauncherType(), help="The launcher names"
)
@pass_context
def show(ctx, name_only, launchers, fields, format, **kwargs):
    """Show the launchers"""
    launchers = launchers or sorted(config.settings.get("launchers", {}))
    with TablePrinter(fields, format) as tp, Colorer(kwargs) as colorer:
        for launcher_name in launchers:
            if name_only:
                click.echo(launcher_name)
            else:
                if config.launchers.readprofile == "settings-file":
                    args = config.launchers.readonly.get(launcher_name, [])
                else:
                    values = {
                        profile.name: " ".join(
                            [
                                quote(p)
                                for p in config.launchers.all_settings[
                                    profile.name
                                ].get(launcher_name, [])
                            ]
                        )
                        for profile in config.all_enabled_profiles
                    }
                    args = colorer.colorize(values, config.launchers.readprofile)
                if any(args):
                    tp.echo(launcher_name, args)
