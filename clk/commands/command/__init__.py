#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
from pathlib import Path

import click

from clk.colors import Colorer
from clk.config import config, merge_settings
from clk.core import DynamicChoiceType, cache_disk
from clk.customcommands import CustomCommandResolver
from clk.decorators import argument, flag, group, option, table_fields, table_format, use_settings
from clk.externalcommands import ExternalCommandResolver
from clk.flow import get_flow_commands_to_run
from clk.lib import TablePrinter, copy, createfile, makedirs, move, quote, rm
from clk.log import get_logger
from clk.overloads import Argument, CommandType, Group, Option, get_command
from clk.types import DirectoryProfile as DirectoryProfileType

LOGGER = get_logger(__name__)


class CustomCommandConfig:
    pass


@group(handle_dry_run=True)
@use_settings('customcommands', CustomCommandConfig, override=False)
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
                    LOGGER.warn('no help message in parameter %s' % param.name)
            if isinstance(sub_cmd, click.Group):
                if not hasattr(sub_cmd, 'original_command'):
                    display_subcommands(ctx, sub_cmd, indent + '  ')
        else:
            LOGGER.warn("Can't get " + sub_cmd_name)


def cmd_format(name, cmd_help, indent):
    cmd_help = cmd_help or ''
    end = len(indent) + len(name)
    spacer = ' ' * max(20 - end, 1)
    return indent + name + spacer + cmd_help


@command.command()
@argument('path', type=CommandType(), help='The command to resolve')
def resolve(path):
    """Resolve a command to help understanding where a command comes from"""
    cmd, resolver = get_command(path, True)
    click.echo(f'The command {path} is resolved by the resolver {resolver.name}')


class CustomCommandPathType(DynamicChoiceType):
    def __init__(self, type):
        self.type = type

    def choices(self):
        _, settings = merge_settings(config.iter_settings(explicit_only=True))
        return settings['customcommands'].get(self.type, [])


class CustomCommandNameType(DynamicChoiceType):
    def __init__(self, settings=None):
        self.resolvers = [
            ExternalCommandResolver(settings),
            CustomCommandResolver(settings),
        ]

    def choices(self):
        return sum([resolver._list_command_paths() for resolver in self.resolvers], [])


class CustomCommandType(CustomCommandNameType):
    def converter(self, path):
        for resolver in self.resolvers:
            if path in resolver._list_command_paths():
                return resolver._get_command(path)
        raise Exception(f'Could not find a resolver matching {path}')


def format_paths(path):
    return ' '.join(map(quote, path))


@command.group(default_command='show')
def path():
    """Manipulate paths where to find extra commands"""


@path.command()
@Colorer.color_options
@table_format(default='key_value')
@table_fields(choices=['name', 'paths'])
def show(fields, format, **kwargs):
    """Show all the custom commands paths"""
    with Colorer(kwargs) as colorer, TablePrinter(fields, format) as tp:
        values = {
            profile.name: format_paths(config.customcommands.all_settings.get(profile.name, {}).get('pythonpaths', []))
            for profile in config.all_enabled_profiles
        }
        args = colorer.colorize(values, config.customcommands.readprofile)
        tp.echo('pythonpaths', ' '.join(args))
        values = {
            profile.name:
            format_paths(config.customcommands.all_settings.get(profile.name, {}).get('executablepaths', []))
            for profile in config.all_enabled_profiles
        }
        args = colorer.colorize(values, config.customcommands.readprofile)
        tp.echo('executablepaths', ' '.join(args))


def custom_command_type():
    return option('--type',
                  help='What kind of object should I find at this locations',
                  type=click.Choice(['executable', 'python']),
                  default='executable')


@path.command()
@argument('paths', nargs=-1, type=Path, help='The paths to add to load custom commands')
@custom_command_type()
def add(paths, type):
    """Add custom command paths"""
    paths = [str(d) for d in paths]
    config.customcommands.writable[f'{type}paths'] = config.customcommands.writable.get(f'{type}paths',
                                                                                        []) + list(paths)
    config.customcommands.write()
    LOGGER.info(f'Added {format_paths(paths)} ({type}) to the profile {config.customcommands.writeprofile}')


@path.command()
@argument('paths', nargs=-1, type=CustomCommandPathType('pythonpaths'), help='The paths to remove from custom commands')
@custom_command_type()
def remove(paths, type):
    """Remove all the custom commands paths from the profile"""
    to_remove = set(config.customcommands.writable.get(f'{type}paths', [])).intersection(paths)
    if not to_remove:
        raise click.UsageError('None of the given path is present. This command would be a no-op.')
    config.customcommands.writable[f'{type}paths'] = [
        path for path in config.customcommands.writable.get(f'{type}paths', []) if path not in to_remove
    ]
    config.customcommands.write()
    LOGGER.info(f'Removed {format_paths(to_remove)} ({type}) from the profile {config.customcommands.writeprofile}')


@command.command()
@argument('customcommand', type=CustomCommandType(), help='The custom command to consider')
def which(customcommand):
    """Print the location of the given custom command"""
    print(customcommand.customcommand_path)


@command.command()
@argument('customcommand', type=CustomCommandType(), help='The custom command to consider')
@flag('--force', help="Don't ask for confirmation")
def _remove(force, customcommand):
    """Remove the given custom command"""
    path = Path(customcommand.customcommand_path)
    if force or click.confirm(f'This will remove {path}, are you sure ?'):
        rm(path)


@command.command()
@argument('customcommand', type=CustomCommandType(), help='The custom command to consider')
def edit(customcommand):
    """Edit the given custom command"""
    path = Path(customcommand.customcommand_path)
    click.edit(filename=path)


class AliasesType(DynamicChoiceType):
    def choices(self):
        return list(config.settings['alias'].keys())


@command.group()
def create():
    """Create custom commands directly from the command line."""


@create.command()
@argument('file', help='Install this file as customcommand')
@option('--name', help='Name of the customcommand (default to the name of the file)')
@flag('--delete', help='Delete the source file when done')
@flag('--force', help='Overwrite a file if it already exists')
def from_file(file, name, delete, force):
    """Install the given file as a customcommand, infering its type.

It works only for python scripts or bash scripts.
"""
    import mimetypes
    type = mimetypes.guess_type(file)[0]
    name = name or Path(file).name
    if type == 'text/x-python':
        command = python
    elif type == 'text/x-sh':
        command = 'bash'
    else:
        raise click.UsageError('I can only install a python script or a bash script.'
                               f' This is a script of type {type}.'
                               " I don't know what to do with it.")
    ctx = click.get_current_context()
    ctx.invoke(command, name=name, from_file=file, force=force)
    if delete:
        rm(file)


@create.command()
@argument('name', help='The name of the new command')
@flag('--open/--no-open', help='Also open the file after its creation', default=True)
@flag('--force', help='Overwrite a file if it already exists')
@option('--body', help='The initial body to put', default='')
@option('--from-alias', help='The alias to use as base', type=AliasesType())
@option('--flowdeps', help='Add a flowdeps', multiple=True, type=CommandType())
@option('--description', help='The initial description to put', default='Description')
@option('--source-bash-helpers/--no-source-bash-helpers', help='Source the bash helpers', default=True)
@option('--from-file', help='Copy this file instead of using the template')
def bash(name, open, force, description, body, from_alias, flowdeps, source_bash_helpers, from_file):
    """Create a bash custom command"""
    if name.endswith('.sh'):
        LOGGER.warning("Removing the extra .sh so that clk won't confuse it" ' with a command name.')
        name = name[:len('.sh')]
    script_path = Path(config.customcommands.profile.location) / 'bin' / name
    makedirs(script_path.parent)
    if script_path.exists() and not force:
        raise click.UsageError(f"Won't overwrite {script_path} unless" ' explicitly asked so with --force')
    options = []
    arguments = []
    flags = []
    remaining = ''
    args = ''

    if from_alias:
        if body:
            body = body + '\n'
        body = body + '\n'.join(config.main_command.path + ' ' + ' '.join(map(quote, command))
                                for command in config.settings['alias'][from_alias]['commands'])
        flowdeps = list(flowdeps) + get_flow_commands_to_run(from_alias)
        alias_cmd = get_command(from_alias)
        if description:
            description = description + '\n'
        description = description + f'Converted from the alias {from_alias}'

        def guess_type(param):
            if type(param.type) == click.Choice:
                return json.dumps(list(param.type.choices))
            elif param.type == int:
                return 'int'
            elif param.type == float:
                return 'float'
            else:
                return 'str'

        for param in alias_cmd.params:
            if type(param) == Option:
                if param.is_flag:
                    flags.append(f"F:{','.join(param.opts)}:{param.help}:{param.default}")
                    args += f"""
if [ "${{{config.main_command.path.upper()}___{param.name.upper()}}}" == "True" ]
then
    args+=({param.opts[-1]})
fi"""
                else:
                    options.append(f"O:{','.join(param.opts)}:{guess_type(param)}:{param.help}")
                    args += f"""
if [ -n "${{{config.main_command.path.upper()}___{param.name.upper()}}}" ]
then
    args+=({param.opts[-1]} "${{{config.main_command.path.upper()}___{param.name.upper()}}}")
fi"""
            elif type(param) == Argument:
                if param.nargs == -1:
                    remaining = param.help
                else:
                    arguments.append(f"A:{','.join(param.opts)}:{guess_type(param)}:{param.help}")
                    args += f"""
args+=("${{{config.main_command.path.upper()}___{param.name.upper()}}}")
"""
        if args:
            args = """# Build the arguments of the last command of the alias
args=()""" + args
            body += ' "${args[@]}"'
        if remaining:
            body += ' "${@}"'

    if flowdeps:
        flowdeps_str = 'flowdepends: ' + ', '.join(flowdeps) + '\n'
    else:
        flowdeps_str = ''
    if options:
        options_str = '\n'.join(options) + '\n'
    else:
        options_str = ''
    if arguments:
        arguments_str = '\n'.join(arguments) + '\n'
    else:
        arguments_str = ''
    if flags:
        flags_str = '\n'.join(flags) + '\n'
    else:
        flags_str = ''
    if remaining:
        remaining_str = f'N:{remaining}\n'
    else:
        remaining_str = ''

    script_content = f"""#!/bin/bash -eu

source "_clk.sh"

clk_usage () {{
    cat<<EOF
$0

{description}
--
{flowdeps_str}{options_str}{flags_str}{arguments_str}{remaining_str}
EOF
}}

clk_help_handler "$@"

{args}
{body}
"""
    if from_file:
        script_content = Path(from_file).read_text()
    createfile(script_path, script_content, mode=0o755)
    if open:
        click.edit(filename=str(script_path))


@create.command()
@argument('name', help='The name of the new command')
@flag('--open/--no-open', help='Also open the file after its creation', default=True)
@flag('--force', help='Overwrite a file if it already exists')
@flag('--with-data', help='Create a directory module instead of a single file.' ' So that you can ship data with it')
@option('--body', help='The initial body to put', default='')
@option('--description', help='The initial description to put', default='Description')
@option('--from-file', help='Copy this file instead of using the template')
def python(name, open, force, description, body, with_data, from_file):
    """Create a bash custom command"""
    script_path = Path(config.customcommands.profile.location) / 'python'
    if with_data:
        if name.endswith('.py'):
            name = name[:-len('.py')]
        script_path /= name
        command_name = name
        name = '__init__.py'
    else:
        if not name.endswith('.py'):
            name += '.py'
        command_name = name[:-len('.py')]
    script_path /= name
    makedirs(script_path.parent)
    if script_path.exists() and not force:
        raise click.UsageError(f"Won't overwrite {script_path} unless" ' explicitly asked so with --force')
    script_text = """#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from pathlib import Path

import click

from clk.decorators import (
    argument,
    flag,
    option,
    command,
    group,
    use_settings,
    table_format,
    table_fields,
)
from clk.lib import (
    TablePrinter,
    call,
)
from clk.config import config
from clk.log import get_logger
from clk.types import DynamicChoice


LOGGER = get_logger(__name__)

"""
    if with_data:
        script_text += """
def data_file(name):
    return Path(__file__).parent / name

"""
    script_text += f"""
@command()
def {command_name}():
    "{description}"
    {body}
"""
    if from_file:
        script_text = Path(from_file).read_text()
    createfile(script_path, script_text)
    if open:
        click.edit(filename=str(script_path))


@command.command()
@argument('customcommand', type=CustomCommandType(), help='The custom command to consider')
@argument('new-name', help='The new name to use for the custom command')
@flag('--force', help='Overwrite destination')
def rename(customcommand, new_name, force):
    """Rename a custom commands"""
    ext = os.path.splitext(customcommand.customcommand_path)[1]
    if ext in {'.sh', '.py'} and not new_name.endswith(ext):
        new_name += ext
    new_path = Path(customcommand.customcommand_path).parent / new_name
    if new_path.exists() and not force:
        raise click.UsageError(f"I won't overwrite {new_path}," ' unless called with --force')
    Path(customcommand.customcommand_path).rename(new_path)
    LOGGER.status(f'Renamed {customcommand.customcommand_path} into {new_path}')


@command.command()
@argument('customcommand', type=CustomCommandType(), help='The custom command to move')
@argument('profile', type=DirectoryProfileType(), help='The profile where to move the command')
@flag('--force', help='Overwrite destination')
def _move(customcommand, profile, force):
    """Move a custom commands"""
    directory = ('python' if customcommand.customcommand_path.endswith('.py') else 'bin')
    new_location = Path(profile.location) / directory / Path(customcommand.customcommand_path).name
    if new_location.exists() and not force:
        raise click.UsageError(f"I won't overwrite {new_location}," ' unless called with --force')
    makedirs(new_location.parent)
    move(customcommand.customcommand_path, new_location)
    LOGGER.status(f'Moved {customcommand.customcommand_path} into {new_location}')


@command.command()
@argument('customcommand', type=CustomCommandType(), help='The custom command to copy')
@argument('profile', type=DirectoryProfileType(), help='The profile where to copy the command')
@argument('name', help='The new name')
@flag('--force', help='Overwrite destination')
def _copy(customcommand, profile, force, name):
    """copy a custom commands"""
    directory = ('python' if customcommand.customcommand_path.endswith('.py') else 'bin')
    new_location = Path(profile.location) / directory / name
    if new_location.exists() and not force:
        raise click.UsageError(f"I won't overwrite {new_location}," ' unless called with --force')
    makedirs(new_location.parent)
    copy(customcommand.customcommand_path, new_location)
    LOGGER.status(f'copied {customcommand.customcommand_path} into {new_location}')


@command.command()
def _list():
    """List the path of all custom commands."""
    settings = (None if config.customcommands.readprofile == 'context' else config.customcommands.profile.settings)
    type = CustomCommandType(settings)

    @cache_disk(expire=600)
    def customcommand_path(command_path):
        return type.converter(command_path).customcommand_path

    for path in type.choices():
        print(customcommand_path(path))
