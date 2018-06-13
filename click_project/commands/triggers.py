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


def set_sub_commands(position):

    @triggers.group(default_command='show', name=position, help="Manipulate %s command triggers" % position)
    def trigger_group():
        pass
    trigger_group.inherited_params = triggers.inherited_params

    @trigger_group.command(ignore_unknown_options=True, change_directory_options=False, handle_dry_run=True)
    @argument('cmd', type=CommandType())
    @argument('subcommand', type=CommandType())
    @argument('params', nargs=-1)
    def set(cmd, subcommand, params):
        """Set an triggers"""
        if cmd.startswith("-"):
            raise click.UsageError("triggers must not start with dashes (-)")
        if re.match('^\w', cmd) is None:
            raise click.ClickException("Invalid triggers name: " + cmd)
        commands = []
        text = [subcommand] + list(params)
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

    @trigger_group.command(handle_dry_run=True)
    @argument('cmds', nargs=-1, type=CommandSettingsKeyType("triggers"))
    def unset(cmds):
        """Unset some triggers"""
        for cmd in cmds:
            if cmd not in config.triggers.writable:
                raise click.ClickException("The %s configuration has no '%s' triggers registered."
                                           "Try using another level option (like --local, --workgroup or --global)"
                                           % (config.triggers.writelevel, cmd))
        for cmd in cmds:
            LOGGER.status("Erasing {} triggers from {} settings".format(cmd, config.triggers.writelevel))
            del config.triggers.writable[cmd]
        config.triggers.write()

    @trigger_group.command(handle_dry_run=True)
    @flag('--name-only/--no-name-only', help="Only display the triggers names")
    @Colorer.color_options
    @argument('triggers', nargs=-1, type=CommandSettingsKeyType("triggers"))
    def show(name_only, triggers, **kwargs):
        """Show the triggers"""
        show_triggers = triggers or sorted(config.triggers.readonly.keys())
        with Colorer(kwargs) as colorer:
            for triggers_ in show_triggers:
                if name_only:
                    click.echo(triggers_)
                else:
                    values = {
                        level_name: format(
                            config.triggers.all_settings[level_name].get(
                                triggers_, {}
                            ).get(position, []))
                        for level_name in colorer.level_to_color
                    }
                    args = colorer.colorize(values, config.triggers.readlevel)
                    if not args[0]:
                        if triggers_ in triggers:
                            args = ["None"]
                        else:
                            args = None
                    if args:
                        echo_key_value(triggers_, " , ".join(args), config.alt_style)

    @trigger_group.command(handle_dry_run=True)
    @argument('origin', type=CommandSettingsKeyType("triggers"))
    @argument('destination')
    def rename(origin, destination):
        """Rename an triggers"""
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
        # warn the user if the triggers is used at other level, and thus has not been renamed there
        for a, cmds in six.iteritems(config.triggers.readonly):
            cmds = data[position]
            for cmd in cmds:
                if cmd[0] == origin and a not in renamed_in:
                    LOGGER.warning("%s is still used in %s at another configuration level."
                                   " You may want to correct this manually." % (origin, a))
        config.triggers.write()

    @trigger_group.command(ignore_unknown_options=True, handle_dry_run=True)
    @argument('cmd', type=CommandType())
    @argument('params', nargs=-1, required=True)
    def append(cmd, params):
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


set_sub_commands("pre")
set_sub_commands("post")
set_sub_commands("onerror")
set_sub_commands("onsuccess")
