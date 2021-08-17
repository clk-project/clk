#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path

import click

from clk.colors import Colorer
from clk.config import config
from clk.decorators import argument, flag, group, option, param_config, table_fields, table_format, use_settings
from clk.lib import TablePrinter, makedirs, move, rm
from clk.log import get_logger
from clk.profile import DirectoryProfile
from clk.types import DirectoryProfile as DirectoryProfileType
from clk.types import DynamicChoice

LOGGER = get_logger(__name__)


class PluginConfig:
    pass


@group(default_command='show')
@use_settings('plugin', PluginConfig, override=False)
def plugin():
    """Manipulate plugins"""


class PluginType(DynamicChoice):
    def choices(self):
        profile = config.plugin.profile_source
        if profile is None:
            return []
        if not isinstance(profile, DirectoryProfile):
            profile = config.get_profile(profile)
        return profile.plugin_source.list_plugins()


@plugin.command()
@param_config(
    'plugin',
    'profile-source',
    kls=argument,
    type=DirectoryProfileType(),
    help='The profile containing the plugin to move',
    expose_value=True,
)
@param_config(
    'plugin',
    'plugin',
    kls=argument,
    type=PluginType(),
    help='The plugin to move',
    expose_value=True,
)
@param_config(
    'plugin',
    'profile-destination',
    kls=argument,
    type=DirectoryProfileType(),
    help='The profile where to move the plugin',
    expose_value=True,
)
@flag('--force', help='Overwrite destination')
def _move(profile_source, plugin, profile_destination, force):
    """Move a custom commands"""
    old_location = Path(profile_source.location) / 'plugins' / (plugin + '.py')
    new_location = Path(profile_destination.location) / 'plugins' / (plugin + '.py')
    if new_location.exists() and not force:
        raise click.UsageError(f"I won't overwrite {new_location}," ' unless called with --force')
    makedirs(new_location.parent)
    move(old_location, new_location)
    LOGGER.status(f'Moved {old_location} into {new_location}')


@plugin.command()
@param_config(
    'plugin',
    'profile-source',
    kls=argument,
    type=DirectoryProfileType(),
    help='The profile containing the plugin to rename',
    expose_value=True,
)
@param_config(
    'plugin',
    'plugin',
    kls=argument,
    type=PluginType(),
    help='The plugin to rename',
    expose_value=True,
)
@argument(
    'new-name',
    help='The new name to give it',
    expose_value=True,
)
def rename(profile_source, plugin, new_name):
    """Rename the plugin"""
    old_location = Path(profile_source.location) / 'plugins' / (plugin + '.py')
    new_location = Path(profile_source.location) / 'plugins' / (new_name + '.py')
    move(old_location, new_location)
    LOGGER.status(f'Moved {old_location} into {new_location}')


@plugin.command()
@param_config(
    'plugin',
    'profile-source',
    kls=argument,
    type=DirectoryProfileType(),
    help='The profile containing the plugin to edit',
    expose_value=True,
)
@param_config(
    'plugin',
    'plugin',
    kls=argument,
    type=PluginType(),
    help='The plugin to rename',
    expose_value=True,
)
def edit(profile_source, plugin):
    """Rename the plugin"""
    path = Path(profile_source.location) / 'plugins' / (plugin + '.py')
    click.edit(filename=path)


@plugin.command()
@param_config(
    'plugin',
    'profile-source',
    kls=argument,
    type=DirectoryProfileType(),
    help='The profile containing the plugin to remove',
    expose_value=True,
)
@param_config(
    'plugin',
    'plugin',
    kls=argument,
    type=PluginType(),
    help='The plugin to rename',
    expose_value=True,
)
@flag('--force', help="Don't ask for confirmation")
def remove(force, profile_source, plugin):
    """Remove the given custom command"""
    path = Path(profile_source.location) / 'plugins' / (plugin + '.py')
    if force or click.confirm(f'This will remove {path}, are you sure ?'):
        rm(path)


@plugin.command()
@param_config(
    'plugin',
    'profile-source',
    kls=argument,
    type=DirectoryProfileType(),
    help='The profile containing the plugin to find',
    expose_value=True,
)
@param_config(
    'plugin',
    'plugin',
    kls=argument,
    type=PluginType(),
    help='The plugin to rename',
    expose_value=True,
)
def which(profile_source, plugin):
    """Find the given plugin"""
    path = Path(profile_source.location) / 'plugins' / (plugin + '.py')
    print(path)


@plugin.command()
@param_config(
    'plugin',
    'profile-source',
    kls=argument,
    type=DirectoryProfileType(),
    help='The profile where to create a new plugin',
    expose_value=True,
)
@argument(
    'new-name',
    help='The name of the new plugin',
    expose_value=True,
)
@flag('--open/--no-open', help='Also open the file after its creation', default=True)
@flag('--force', help='Overwrite a file if it already exists')
@option('--body', help='The initial body to put', default='')
@option('--description', help='The initial description to put', default='Description')
def create(profile_source, new_name, open, force, body, description):
    """Rename the plugin"""
    script_path = Path(profile_source.location) / 'plugins' / (new_name + '.py')
    makedirs(script_path.parent)
    if script_path.exists() and not force:
        raise click.UsageError(f"Won't overwrite {script_path} unless" ' explicitly asked so with --force')
    script_path.write_text(f"""#!/usr/bin/env python3
# -*- coding:utf-8 -*-

"{description}"

from pathlib import Path

from clk.config import config


def load_plugin():
    "Put here the entrypoint of the plugin."
    {body}
""")
    if open:
        click.edit(filename=str(script_path))


@plugin.command()
@Colorer.color_options
@table_format(default='key_value')
@table_fields(choices=['name', 'doc'])
def show(fields, format, **kwargs):
    """List the path of all custom commands."""
    with TablePrinter(fields, format) as tp, Colorer(kwargs) as colorer:
        for profile in config.all_directory_profiles:
            for plugin in profile.plugin_source.list_plugins():
                tp.echo(colorer.apply_color(plugin, profile.name), profile.plugin_short_doc(plugin) or '')
