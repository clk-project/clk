#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import click
import re

import six

from click_project.config import config
from click_project.decorators import group, flag, argument, use_settings
from click_project.lib import quote, echo_key_value
from click_project.log import get_logger
from click_project.overloads import CommandType, CommandSettingsKeyType
from click_project.commands.alias import get_choices
from click_project.colors import Colorer

LOGGER = get_logger(__name__)


def format(cmds):
    """Format the trigger command"""
    return " , ".join(" ".join(quote(arg) for arg in cmd) for cmd in cmds)


class TriggersConfig(object):
    pass


@group()
@use_settings("triggers", TriggersConfig, override=False)
def triggers():
    """Manipulate command triggers

    It is mostly useful if you want to trigger specific behaviors around usual
    commands, generally to work around issues in tools you are forced to use.

    To trigger the execution of a command B each time a command A is executed,
    and just before, run:

    triggers pre set A B

    To trigger the execution of a command B only after a successful execution of A:

    triggers onsuccess set A B

    To add the trigger of the execution of a command C after a successful
    execution of A (hence a successful execution of A would run B, and then C):

    triggers onsuccess append A C
    """
    pass


@triggers.command(ignore_unknown_options=True, change_directory_options=False, handle_dry_run=True)
@argument('position', type=click.Choice(["pre", "post", "error", "success"]), help="The trigger position")
@argument('cmd', type=CommandType(), help="The command to which the trigger is associated command")
@argument('triggered-command', type=CommandType(), help="The command to trigger")
@argument('params', nargs=-1, help="The parameters passed to the triggered command")
def set(cmd, triggered_command, params, position):
    """Set a triggers"""
    if cmd.startswith("-"):
        raise click.UsageError("triggers must not start with dashes (-)")
    if re.match('^\w', cmd) is None:
        raise click.ClickException("Invalid triggers name: " + cmd)
    commands = []
    text = [triggered_command] + list(params)
    sep = ','
    while sep in text:
        index = text.index(sep)
        commands.append(text[:index])
        del text[:index + 1]
    if text:
        commands.append(text)
    if cmd in config.triggers.writable:
        config.triggers.writable[cmd][position] = commands
    else:
        config.triggers.writable[cmd] = {position: commands}
    config.triggers.write()


set.get_choices = get_choices


@triggers.command(handle_dry_run=True)
@argument('position', type=click.Choice(["pre", "post", "error", "success"]), help="The trigger position")
@argument('cmds', nargs=-1, type=CommandSettingsKeyType("triggers"),
          help="The commands where the triggers will be unset")
def unset(cmds, position):
    """Unset some triggers"""
    for cmd in cmds:
        if cmd not in config.triggers.writable:
            raise click.ClickException("The %s configuration has no '%s' triggers registered."
                                       "Try using another profile option (like --local or --global)"
                                       % (config.triggers.writeprofile, cmd))
    for cmd in cmds:
        LOGGER.status("Erasing {} triggers from {} settings".format(cmd, config.triggers.writeprofile))
        del config.triggers.writable[cmd]
    config.triggers.write()


@triggers.command(handle_dry_run=True)
@flag('--name-only/--no-name-only', help="Only display the triggers names",)
@Colorer.color_options
@argument('position', type=click.Choice(["pre", "post", "error", "success"]), help="The trigger position")
@argument('triggers', nargs=-1, type=CommandSettingsKeyType("triggers"), help="The commands to show")
def show(name_only, triggers, position, **kwargs):
    """Show the triggers"""
    show_triggers = triggers or sorted(config.triggers.readonly.keys())
    with Colorer(kwargs) as colorer:
        for triggers_ in show_triggers:
            if name_only:
                click.echo(triggers_)
            else:
                values = {
                    profile.name: format(
                        config.triggers.all_settings[profile.name].get(
                            triggers_, {}
                        ).get(position, []))
                    for profile in config.all_enabled_profiles
                }
                args = colorer.colorize(values, config.triggers.readprofile)
                echo_key_value(triggers_, " , ".join(args), config.alt_style)


@triggers.command(handle_dry_run=True)
@argument('origin', type=CommandSettingsKeyType("triggers"), help="The current trigger")
@argument('destination', help="The new trigger")
@argument('position', type=click.Choice(["pre", "post", "error", "success"]), help="The trigger position")
def rename(origin, destination, position):
    """Rename a triggers"""
    config.triggers.writable[destination] = config.triggers.readonly[origin]
    if origin in config.triggers.writable:
        del config.triggers.writable[origin]
    # rename the triggers when used in the other triggers
    from six.moves.builtins import set
    renamed_in = set()
    for a, data in six.iteritems(config.triggers.writable):
        cmds = data[position]
        for cmd in cmds:
            if cmd[0] == origin:
                LOGGER.debug("%s renamed in %s" % (origin, a))
                cmd[0] = destination
                renamed_in.add(a)
    # warn the user if the triggers is used at other profile, and thus has not been renamed there
    for a, cmds in six.iteritems(config.triggers.readonly):
        cmds = data[position]
        for cmd in cmds:
            if cmd[0] == origin and a not in renamed_in:
                LOGGER.warning("%s is still used in %s at another configuration profile."
                               " You may want to correct this manually." % (origin, a))
    config.triggers.write()


@triggers.command(ignore_unknown_options=True, handle_dry_run=True)
@argument('cmd', type=CommandType(), help="The command to modify")
@argument('params', nargs=-1, required=True, help="The extra parameters")
@argument('position', type=click.Choice(["pre", "post", "error", "success"]), help="The trigger position")
def append(cmd, params, position):
    """Add some commands at the end of the triggers"""
    commands = []
    text = list(params)
    sep = ','
    while sep in text:
        index = text.index(sep)
        commands.append(text[:index])
        del text[:index + 1]
    if text:
        commands.append(text)
    data = config.triggers.readonly.get(cmd, {})
    data[position] = data.get(position, []) + commands
    config.triggers.writable[cmd] = data
    config.triggers.write()
append.get_choices = get_choices
