#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import re

import click
import six

from click_project.config import config
from click_project.decorators import group, flag, argument, use_settings, option, table_format, table_fields
from click_project.lib import TablePrinter
from click_project.lib import quote
from click_project.completion import compute_choices
from click_project.log import get_logger
from click_project.overloads import get_ctx, CommandSettingsKeyType, CommandType
from click_project.colors import Colorer

LOGGER = get_logger(__name__)


class AliasConfig(object):
    pass


def format(cmds):
    """Format the alias command"""
    return " , ".join(" ".join(cmd) for cmd in cmds)


@group(default_command='show')
@use_settings("alias", AliasConfig)
def alias():
    """Manipulate the command aliases"""
    pass


def get_choices(ctx, args_, incomplete):
    args = config.command_line_settings["parameters"][ctx.command.path][:]
    while args and args[0].startswith("-"):
        a = args.pop(0)
        if args and (a == "-r" or a == "--recipe"):
            args.pop(0)
    if not args:
        choices = compute_choices(ctx, args_, incomplete)
    else:
        args.pop(0)
        while ',' in args:
            args = args[args.index(',')+1:]
        ctx = get_ctx(args, side_effects=True)
        choices = compute_choices(ctx, args, incomplete)
    for item, help in choices:
        yield (item, help)


@alias.command(ignore_unknown_options=True, change_directory_options=False, handle_dry_run=True)
@option("--documentation", help="Documentation to display")
@argument('alias', help="The alias name")
@argument('command', type=CommandType(), help="The alias command")
@argument('params', nargs=-1, help="The command parameters")
def set(alias, command, documentation, params):
    """Set an alias"""
    if alias.startswith("-"):
        raise click.UsageError("Aliases must not start with dashes (-)")
    if re.match('^\w', alias) is None:
        raise click.ClickException("Invalid alias name: " + alias)
    commands = []
    text = [command] + list(params)
    sep = ','
    while sep in text:
        index = text.index(sep)
        commands.append(text[:index])
        del text[:index + 1]
    if text:
        commands.append(text)
    data = {
        "documentation": documentation,
        "commands": commands,
    }
    old = config.alias.writable.get(alias)
    if old is not None:
        LOGGER.status(
            "Removing {} alias of {}: {}".format(
                config.alias.writelevelname,
                alias,
                " , ".join(
                    " ".join(command)
                    for command in old["commands"]
                )
            )
        )
    LOGGER.status(
        "New {} alias for {}: {}".format(
            config.alias.writelevelname,
            alias,
                " , ".join(
                    " ".join(command)
                    for command in data["commands"]
                )
        )
    )
    config.alias.writable[alias] = data
    config.alias.write()


set.get_choices = get_choices


@alias.command()
@argument('alias', type=CommandSettingsKeyType("alias"), help="The alias name")
@argument('documentation', help="The alias documentation")
def set_documentation(alias, documentation):
    """Set the documentation of the alias"""
    if alias not in config.alias.writable:
        raise click.ClickException("The %s configuration has no '%s' alias registered."
                                   "Try using another level option (like --local, --workgroup or --global)"
                                   % (config.alias.writelevel, alias))
    config.alias.writable[alias]["documentation"] = documentation
    config.alias.write()


@alias.command(handle_dry_run=True)
@argument('aliases', nargs=-1, type=CommandSettingsKeyType("alias"), help="The aliases to unset")
def unset(aliases):
    """Unset some aliases"""
    for cmd in aliases:
        if cmd not in config.alias.writable:
            raise click.ClickException("The %s configuration has no '%s' alias registered."
                                       "Try using another level option (like --local, --workgroup or --global)"
                                       % (config.alias.writelevel, cmd))
    for cmd in aliases:
        LOGGER.status("Erasing {} alias from {} settings".format(cmd, config.alias.writelevel))
        del config.alias.writable[cmd]
    config.alias.write()


@alias.command(handle_dry_run=True)
@argument('aliases', nargs=-1, type=CommandSettingsKeyType("alias"),
          help="The aliases where the documentation will be removed")
def unset_documentation(aliases):
    """Unset the documentation of some aliases"""
    for cmd in aliases:
        if cmd not in config.alias.writable:
            raise click.ClickException("The %s configuration has no '%s' alias registered."
                                       " Try using another level option (like --local, --workgroup or --global)"
                                       % (config.alias.writelevel, cmd))
    for cmd in aliases:
        LOGGER.status("Erasing the documentation of {} alias from {} settings".format(cmd, config.alias.writelevel))
        config.alias.writable[cmd]["documentation"] = None
    config.alias.write()


@alias.command(handle_dry_run=True)
@flag('--name-only/--no-name-only', help="Only display the alias names",
      deprecated="please use '--field alias' instead")
@Colorer.color_options
@option("--under", help="Limit the scope to the commands under the given namespace",
        type=CommandSettingsKeyType("alias", silent_fail=True))
@table_format(default='key_value')
@table_fields(choices=['alias', 'commands'])
@argument('aliases', nargs=-1, type=CommandSettingsKeyType("alias"), help="The aliases to show. All the aliases are"
          " showed when no alias is provided")
def show(name_only, aliases, under, fields, format, **kwargs):
    """Show the aliases"""
    if name_only:
        fields = ['alias']
    aliases = aliases or sorted(config.alias.readonly.keys())
    if under:
        aliases = [alias for alias in aliases if alias.startswith(under)]
    with TablePrinter(fields, format, separator=' , ') as tp, Colorer(kwargs) as colorer:
        for alias in aliases:
            if config.alias.readlevel == "settings-file":
                args = [format(config.alias.readonly.get(alias, {}).get("commands", []))]
            elif "/" in config.alias.readlevel:
                args = [
                    " ".join(command)
                    for command in
                    config.alias.all_settings.get(
                        config.alias.readlevel,
                        {}).get(alias)["commands"]
                ]
            else:
                all_values = [
                    (level, config.alias.all_settings.get(level, {}).get(alias))
                    for level in colorer.level_to_color.keys()
                ]
                all_values = [(level, value) for level, value in all_values
                              if value is not None]
                last_level, last_value = all_values[-1]
                last_command = last_value["commands"]
                args = [colorer.apply_color(" ".join(map(quote, token)), last_level) for token in last_command]
            tp.echo(alias, args)


@alias.command(handle_dry_run=True)
@argument('source', type=CommandSettingsKeyType("alias"), help="The alias to rename")
@argument('destination', help="The new name of the alias")
def rename(source, destination):
    """Rename an alias"""
    config.alias.writable[destination] = config.alias.readonly[source]
    if source in config.alias.writable:
        del config.alias.writable[source]
    # rename the alias when used in the other aliases
    from six.moves.builtins import set
    renamed_in = set()
    for a, data in six.iteritems(config.alias.writable):
        cmds = data["commands"]
        for cmd in cmds:
            if cmd[0] == source:
                LOGGER.debug("%s renamed in %s" % (source, a))
                cmd[0] = destination
                renamed_in.add(a)
    # warn the user if the alias is used at other level, and thus has not been renamed there
    for a, cmds in six.iteritems(config.alias.readonly):
        cmds = data["commands"]
        for cmd in cmds:
            if cmd[0] == source and a not in renamed_in:
                LOGGER.warning("%s is still used in %s at another configuration level."
                               " You may want to correct this manually." % (source, a))
    config.alias.write()


@alias.command(ignore_unknown_options=True, handle_dry_run=True)
@argument('alias', type=CommandType(), help="The alias to modify")
@argument('params', nargs=-1, required=True, help="The command parameters to append to the alias command")
def append(alias, params):
    """Add some commands at the end of the alias"""
    commands = []
    text = list(params)
    sep = ','
    while sep in text:
        index = text.index(sep)
        commands.append(text[:index])
        del text[:index + 1]
    if text:
        commands.append(text)
    data = config.alias.readonly.get(alias, {})
    data["commands"] = data.get("commands", []) + commands
    config.alias.writable[alias] = data
    config.alias.write()


append.get_choices = get_choices
