#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import click

from click_project.config import config
from click_project.decorators import (
    group,
    argument,
)
from click_project.log import get_logger
from click_project.overloads import Group, CommandType, get_command

LOGGER = get_logger(__name__)


@group(handle_dry_run=True, default_command="display")
def command():
    """Display all the available commands"""


@command.command()
def display():
    ctx = click.get_current_context()
    display_subcommands(ctx, config.main_command)


def display_subcommands(ctx, cmd, indent=''):
    # type: (click.Context, Group, str) -> None
    for sub_cmd_name in cmd.list_commands(ctx):
        sub_cmd = cmd.get_command(ctx, sub_cmd_name)
        if sub_cmd:
            click.echo(cmd_format(sub_cmd_name, sub_cmd.short_help, indent))
            for param in sub_cmd.params:
                if not hasattr(param, 'help') or not param.help:
                    LOGGER.warn("no help message in parameter %s" % param.name)
            if isinstance(sub_cmd, click.Group):
                if not hasattr(sub_cmd, "original_command"):
                    display_subcommands(ctx, sub_cmd, indent + '  ')
        else:
            LOGGER.warn("Can't get " + sub_cmd_name)


def cmd_format(name, cmd_help, indent):
    cmd_help = cmd_help or ''
    end = len(indent) + len(name)
    spacer = ' ' * max(20 - end, 1)
    return indent + name + spacer + cmd_help


@command.command()
@argument("path", type=CommandType(), help="The command to resolve")
def resolve(path):
    """Resolve a command to help understanding where a command comes from"""
    cmd, resolver = get_command(path, True)
    click.echo(
        f"The command {path} is resolved by the resolver {resolver.name}"
    )
