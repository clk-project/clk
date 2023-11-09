#!/usr/bin/env python
# -*- coding: utf-8 -*-

import shlex

import click

from clk.colors import Colorer
from clk.config import config
from clk.decorators import argument, flag, group, option, pass_context, table_fields, table_format, use_settings
from clk.lib import TablePrinter, quote
from clk.log import get_logger
from clk.overloads import CommandSettingsKeyType, CommandType, get_cached_evaluator, get_command_safe

LOGGER = get_logger(__name__)


class ParametersConfig(object):
    pass


def format_parameters(params):
    return ' '.join(map(quote, params))


@group(default_command='show')
@use_settings('parameters', ParametersConfig, override=False)
def parameter():
    """Manipulate command parameters"""
    pass


@parameter.command(ignore_unknown_options=True, change_directory_options=False, handle_dry_run=True)
@argument('cmd', type=CommandType(), help='The command to set')
@argument('params', nargs=-1, help='The command parameters')
def set(cmd, params):
    """Set the parameters of a command"""
    old = config.parameters.writable.get(cmd)
    config.parameters.writable[cmd] = list(params)
    if old is not None:
        LOGGER.info('Removing {} parameters of {}: {}'.format(
            Colorer.apply_color_profilename(config.parameters.writeprofilename),
            cmd,
            format_parameters(old),
        ))
    LOGGER.info('New {} parameters for {}: {}'.format(
        Colorer.apply_color_profilename(config.parameters.writeprofilename),
        cmd,
        format_parameters(params),
    ))
    config.parameters.write()


@parameter.command(ignore_unknown_options=True, change_directory_options=False, handle_dry_run=True)
@argument('cmd', type=CommandType(), help='The command to set')
def edit(cmd):
    """Set the parameters of a command"""
    old = config.parameters.writable.get(cmd) or []
    oldcontent = format_parameters(old)
    content = click.edit(oldcontent, extension=f'_{config.parameters.writeprofilename.replace("/", "_")}.txt')
    if content == oldcontent or content is None:
        LOGGER.info('Nothing changed')
    elif content == '':
        LOGGER.info('Aboooooort !!')
    else:
        if old:
            LOGGER.info('Removing {} parameters of {}: {}'.format(
                Colorer.apply_color_profilename(config.parameters.writeprofilename),
                cmd,
                format_parameters(old),
            ))
        params = shlex.split(content)
        LOGGER.info('New {} parameters for {}: {}'.format(
            Colorer.apply_color_profilename(config.parameters.writeprofilename),
            cmd,
            format_parameters(params),
        ))
        config.parameters.writable[cmd] = params
        config.parameters.write()


@parameter.command(ignore_unknown_options=True, handle_dry_run=True)
@argument('cmd', type=CommandType(), help='The command to which the parameters will be appended')
@argument('params', nargs=-1, help='The parameters to append')
def append(cmd, params):
    """Add a parameter after the parameters of a command"""
    old = config.parameters.writable.get(cmd, [])
    new = old + list(params)
    if old:
        LOGGER.info('New {} parameters for {}: {} (old parameters) + {}'.format(
            Colorer.apply_color_profilename(config.parameters.writeprofilename),
            cmd,
            format_parameters(old),
            format_parameters(params),
        ))
    else:
        LOGGER.info('New {} parameters for {}: {}'.format(
            Colorer.apply_color_profilename(config.parameters.writeprofilename),
            cmd,
            format_parameters(params),
        ))
    config.parameters.writable[cmd] = new
    config.parameters.write()


@parameter.command(ignore_unknown_options=True, handle_dry_run=True)
@argument('cmd', type=CommandSettingsKeyType('parameters'), help='The command to which the parameters will be inserted')
@argument('params', nargs=-1, help='The parameters to insert')
def insert(cmd, params):
    """Add a parameter before the parameters of a command"""
    params = list(params) + config.parameters.readonly.get(cmd, [])
    config.parameters.writable[cmd] = params
    config.parameters.write()


@parameter.command(ignore_unknown_options=True, handle_dry_run=True)
@argument('cmd', type=CommandSettingsKeyType('parameters'), help='The command to which the parameters will be removed')
@argument('params', nargs=-1, help='The parameters to remove')
def remove(cmd, params):
    """Remove some parameters of a command"""
    # first try to remove the parameters as a block. This way the user can do parameters remove generate -G foo
    # and be sure the parameter order will still be consistent
    current_params = config.parameters.writable[cmd]
    for i in range(len(current_params) - len(params)):
        if current_params[i:i + len(params)] == list(params):
            new_params = current_params[:i] + current_params[i + len(params):]
            while len(current_params):
                current_params.pop()
            current_params.extend(new_params)
            config.parameters.write()
            return

    # can't remove the params as a block - lets try one by one
    for param in params:
        try:
            config.parameters.writable[cmd].remove(param)
        except ValueError:
            raise click.ClickException('%s is not in the parameters of %s' % (param, cmd))
    LOGGER.info('Erasing {} parameters {} from {} settings'.format(
        cmd, ' '.join(params), Colorer.apply_color_profilename(config.parameters.writeprofilename)))
    config.parameters.write()


@parameter.command(handle_dry_run=True)
@argument('cmds',
          nargs=-1,
          type=CommandSettingsKeyType('parameters'),
          help='The commands to which the parameters will be unset')
def unset(cmds):
    """Unset the parameters of a command"""
    for cmd in cmds:
        if cmd not in config.parameters.writable:
            raise click.ClickException('The command %s has no parameter registered in the %s configuration.'
                                       ' Try using another profile option (like --local or --global)' %
                                       (cmd, Colorer.apply_color_profilename(config.parameters.writeprofilename)))
    for cmd in cmds:
        LOGGER.info('Erasing {} parameters of {} (was: {})'.format(
            Colorer.apply_color_profilename(config.parameters.writeprofilename), cmd,
            format_parameters(config.parameters.writable[cmd])))
        del config.parameters.writable[cmd]
    config.parameters.write()


@parameter.command(handle_dry_run=True)
@flag('--name-only/--no-name-only', help='Only display the command names')
@Colorer.color_options
@option('--under', help='Limit the scope to the commands under the given namespace', type=CommandType())
@table_format(default='key_value')
@table_fields(choices=['command', 'parameters'])
@argument('cmds', nargs=-1, default=None, type=CommandType(), help='The commands to show')
@pass_context
def show(ctx, name_only, cmds, under, fields, format, **kwargs):
    """Show the parameters of a command"""
    cmds = cmds or sorted(config.parameters.readonly.keys())
    if under:
        cmds = [cmd for cmd in cmds if cmd.startswith(under)]
    with TablePrinter(fields, format) as tp, Colorer(kwargs) as colorer:
        for cmd_name in cmds:
            if name_only:
                click.echo(cmd_name)
            else:
                cmd = get_command_safe(cmd_name)

                def get_line(profile_name):
                    return ' '.join(
                        [quote(p) for p in config.parameters.all_settings.get(profile_name, {}).get(cmd_name, [])])

                if config.parameters.readprofile == 'settings-file':
                    args = config.parameters.readonly.get(cmd_name, [])
                else:
                    values = {profile.name: get_line(profile.name) for profile in config.all_enabled_profiles}
                    args = colorer.colorize(values, config.parameters.readprofile)
                if args == ['']:
                    # the command most likely has implicit settings and only
                    # explicit values are asked for. Skip it
                    continue
                if cmd is None:
                    LOGGER.warning('You should know that the command {} does not exist'.format(cmd_name))
                args = args or 'None'
                tp.echo(cmd_name, args)


@parameter.command()
@argument('command', help='The command whose cache to drop')
def drop_cache(command):
    'Drop the cache for some command that was put as eval:command'
    evaluator = get_cached_evaluator()
    evaluator.drop(config.project, command)
