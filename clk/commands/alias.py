#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re

import click

from clk.alias import edit_alias_command, format, parse
from clk.colors import Colorer
from clk.completion import compute_choices
from clk.config import config
from clk.decorators import argument, flag, group, option, table_fields, table_format, use_settings
from clk.lib import TablePrinter, quote
from clk.log import get_logger
from clk.overloads import CommandSettingsKeyType, CommandType, get_ctx
from clk.types import DirectoryProfile as DirectoryProfileType

LOGGER = get_logger(__name__)


class AliasConfig(object):
    pass


@group(default_command='show')
@use_settings('alias', AliasConfig)
def alias():
    """Manipulate the command aliases"""
    pass


def get_choices(ctx, args_, incomplete):
    args = config.commandline_profile.get_settings('parameters')[ctx.command.path][:]
    while args and args[0].startswith('-'):
        a = args.pop(0)
        if args and (a == '-e' or a == '--extension'):
            args.pop(0)
    if not args:
        choices = compute_choices(ctx, args_, incomplete)
    else:
        args.pop(0)
        while ',' in args:
            args = args[args.index(',') + 1:]
        ctx = get_ctx(args, side_effects=True)
        choices = compute_choices(ctx, args, incomplete)
    for item, help in choices:
        yield (item, help)


@alias.command(ignore_unknown_options=True, change_directory_options=False, handle_dry_run=True)
@option('--documentation', help='Documentation to display')
@argument('alias', help='The alias name')
@argument('command', type=CommandType(), help='The alias command')
@argument('params', nargs=-1, help='The command parameters')
def _set(alias, command, documentation, params):
    """Set an alias"""
    if alias.startswith('-'):
        raise click.UsageError('Aliases must not start with dashes (-)')
    if re.match(r'^\w', alias) is None:
        raise click.ClickException('Invalid alias name: ' + alias)
    text = [command] + list(params)
    commands = parse(text)
    data = {
        'documentation': documentation,
        'commands': commands,
    }
    old = config.alias.writable.get(alias)
    if old is not None:
        LOGGER.status('Removing {} alias of {}: {}'.format(config.alias.writeprofilename, alias,
                                                           format(old['commands'])))
    LOGGER.status('New {} alias for {}: {}'.format(config.alias.writeprofilename, alias, format(data['commands'])))
    config.alias.writable[alias] = data
    config.alias.write()


_set.get_choices = get_choices


@alias.command(ignore_unknown_options=True, change_directory_options=False, handle_dry_run=True)
@argument('alias', help='The alias name', type=CommandSettingsKeyType('alias'))
def edit(alias):
    """Set an alias"""
    edit_alias_command(alias)


edit.get_choices = get_choices


@alias.command()
@argument('alias', type=CommandSettingsKeyType('alias'), help='The alias name')
@argument('documentation', help='The alias documentation')
def set_documentation(alias, documentation):
    """Set the documentation of the alias"""
    if alias not in config.alias.writable:
        raise click.ClickException("The %s configuration has no '%s' alias registered."
                                   'Try using another profile option (like --local or --global)' %
                                   (config.alias.writeprofile, alias))
    config.alias.writable[alias]['documentation'] = documentation
    config.alias.write()


@alias.command(handle_dry_run=True)
@argument('aliases', nargs=-1, type=CommandSettingsKeyType('alias'), help='The aliases to unset')
def unset(aliases):
    """Unset some aliases"""
    for cmd in aliases:
        if cmd not in config.alias.writable:
            raise click.ClickException("The %s configuration has no '%s' alias registered."
                                       ' And removing an alias being a destructive command, please'
                                       ' provide the profile option explicitely (like --local or --global).' %
                                       (config.alias.writeprofile, cmd))
    for cmd in aliases:
        LOGGER.status('Erasing {} alias from {} settings'.format(cmd, config.alias.writeprofile))
        del config.alias.writable[cmd]
    config.alias.write()


config.globalpreset_profile.settings['alias']['alias.rm'] = {
    'commands': [
        ['alias', 'unset'],
    ],
    'documentation': 'Alias to alias rm, because we eat our own dog food.'
}


@alias.command(handle_dry_run=True)
@argument('aliases',
          nargs=-1,
          type=CommandSettingsKeyType('alias'),
          help='The aliases where the documentation will be removed')
def unset_documentation(aliases):
    """Unset the documentation of some aliases"""
    for cmd in aliases:
        if cmd not in config.alias.writable:
            raise click.ClickException("The %s configuration has no '%s' alias registered."
                                       ' Try using another profile option (like --local or --global)' %
                                       (config.alias.writeprofile, cmd))
    for cmd in aliases:
        LOGGER.status('Erasing the documentation of {} alias from {} settings'.format(cmd, config.alias.writeprofile))
        config.alias.writable[cmd]['documentation'] = None
    config.alias.write()


@alias.command(handle_dry_run=True)
@flag('--name-only/--no-name-only',
      help='Only display the alias names',
      deprecated="please use '--field alias' instead")
@Colorer.color_options
@option('--under',
        help='Limit the scope to the commands under the given namespace',
        type=CommandSettingsKeyType('alias', silent_fail=True))
@table_format(default='key_value')
@table_fields(choices=['alias', 'commands'])
@argument('aliases',
          nargs=-1,
          type=CommandSettingsKeyType('alias'),
          help='The aliases to show. All the aliases are'
          ' showed when no alias is provided')
def show(name_only, aliases, under, fields, format, **kwargs):
    """Show the aliases"""
    if name_only:
        fields = ['alias']
    aliases = aliases or sorted(config.alias.readonly.keys())
    if under:
        aliases = [alias for alias in aliases if alias.startswith(under)]
    with TablePrinter(fields, format, separator=' , ') as tp, Colorer(kwargs) as colorer:
        for alias in aliases:
            if config.alias.readprofile == 'settings-file':
                args = [format(config.alias.readonly.get(alias, {}).get('commands', []))]
            elif '/' in config.alias.readprofile:
                args = [
                    ' '.join(command)
                    for command in config.alias.all_settings.get(config.alias.readprofile, {}).get(alias)['commands']
                ]
            else:
                all_values = [(profile.name, config.alias.all_settings.get(profile.name, {}).get(alias))
                              for profile in config.all_enabled_profiles]
                all_values = [(profile, value) for profile, value in all_values if value is not None]
                last_profile, last_value = all_values[-1]
                last_command = last_value['commands']
                args = [colorer.apply_color(' '.join(map(quote, token)), last_profile) for token in last_command]
            tp.echo(alias, args)


@alias.command(handle_dry_run=True)
@argument('source', type=CommandSettingsKeyType('alias'), help='The alias to rename')
@argument('destination', help='The new name of the alias')
def rename(source, destination):
    """Move an alias, put the new alias in the profile indicated in the command"""
    for profile in reversed(list(config.all_enabled_profiles)):
        if source in profile.settings.get('alias', {}):
            break
    else:
        raise Exception(f'{source} not found')
    profile.settings['alias'][destination] = profile.settings['alias'][source]
    del profile.settings['alias'][source]
    # rename the alias when used in the other aliases
    renamed_in = set()
    for a, data in config.alias.writable.items():
        cmds = data['commands']
        for cmd in cmds:
            if cmd[0] == source:
                LOGGER.debug('%s renamed in %s' % (source, a))
                cmd[0] = destination
                renamed_in.add(a)
    # warn the user if the alias is used at other profile, and thus has not been renamed there
    for a, cmds in config.alias.readonly.items():
        cmds = data['commands']
        for cmd in cmds:
            if cmd[0] == source and a not in renamed_in:
                LOGGER.warning('%s is still used in %s at another configuration profile.'
                               ' You may want to correct this manually.' % (source, a))
    LOGGER.status(f'Moved alias {source} -> {destination} in {profile.name}')
    profile.write_settings()


@alias.command(handle_dry_run=True)
@argument('source', type=CommandSettingsKeyType('alias'), help='The alias to move')
@argument('destination', help='The profile wher to put the new alias', type=DirectoryProfileType())
def move(source, destination):
    """Move an alias, put the new alias in the profile indicated in the command"""
    for profile in reversed(list(config.all_enabled_profiles)):
        if source in profile.settings.get('alias', {}):
            break
    else:
        raise Exception(f'{source} not found')
    destination_store = destination.settings.get('alias', {})
    destination_store[source] = profile.settings['alias'][source]
    destination.settings['alias'] = destination_store
    del profile.settings['alias'][source]
    LOGGER.status(f'Moved alias {source}, {profile.name} -> {destination.name}')
    destination.write_settings()
    profile.write_settings()


@alias.command(handle_dry_run=True)
@argument('source', type=CommandSettingsKeyType('alias'), help='The alias to copy')
@argument('destination', help='The name of the new alias')
def copy(source, destination):
    """Copy an alias"""
    for profile in reversed(list(config.all_enabled_profiles)):
        if source in profile.settings.get('alias', {}):
            break
    else:
        raise Exception(f'{source} not found')
    profile.settings['alias'][destination] = profile.settings['alias'][source]
    profile.write_settings()
    LOGGER.status(f'Copied alias {source} -> {destination} in {profile.name}')


@alias.command(ignore_unknown_options=True, handle_dry_run=True)
@argument('alias', type=CommandType(), help='The alias to modify')
@argument('params', nargs=-1, required=True, help='The command parameters to append to the alias command')
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
    data['commands'] = data.get('commands', []) + commands
    config.alias.writable[alias] = data
    config.alias.write()


append.get_choices = get_choices
