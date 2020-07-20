#!/usr/bin/env python
# -*- coding:utf-8 -*-

import click

from click_project.config import config
from click_project.decorators import argument, flag, table_fields, table_format
from click_project.lib import TablePrinter
from click_project.log import get_logger
from click_project.overloads import CommandSettingsKeyType
from click_project.colors import Colorer

LOGGER = get_logger(__name__)


def keyvaluestore_generic_commands(group, settings_name):
    @group.command(ignore_unknown_options=True)
    @argument('key', help="The key")
    @argument('value', help="The value")
    def _set(key, value):
        """Set a value"""
        getattr(config, settings_name).writable[key] = {"value": value}
        getattr(config, settings_name).write()

    @group.command(handle_dry_run=True)
    @argument('src', type=CommandSettingsKeyType("value"), help="The current key")
    @argument('dst', help="The new key")
    @flag("--overwrite/--no-overwrite", help="̂Rename even if the destination already exists")
    def rename(src, dst, overwrite):
        """Rename a key"""
        if src not in getattr(config, settings_name).writable:
            raise click.ClickException("The %s configuration has no '%s' values registered."
                                       "Try using another profile option (like --local or --global)"
                                       % (getattr(config, settings_name).writeprofile, src))
        if dst in getattr(config, settings_name).writable and not overwrite:
            LOGGER.error(
                "{} already exists at profile {}"
                " use --overwrite to perform the renaming anyway".format(
                    dst,
                    getattr(config, settings_name).writeprofile))
            exit(1)
        getattr(config, settings_name).writable[dst] = getattr(config, settings_name).writable[src]
        del getattr(config, settings_name).writable[src]
        LOGGER.status("Rename {} -> {} in profile {}".format(src, dst, getattr(config, settings_name).writeprofile))
        getattr(config, settings_name).write()

    @group.command(handle_dry_run=True)
    @argument('keys', nargs=-1, type=CommandSettingsKeyType("value"), help="The keys to unset")
    def unset(keys):
        """Unset some values"""
        for key in keys:
            if key not in getattr(config, settings_name).writable:
                raise click.ClickException("The %s configuration has no '%s' value registered."
                                           "Try using another profile option (like --local or --global)"
                                           % (getattr(config, settings_name).writeprofile, key))
        for key in keys:
            LOGGER.status("Erasing {} value from {} settings".format(key, getattr(config, settings_name).writeprofile))
            del getattr(config, settings_name).writable[key]
        getattr(config, settings_name).write()

    @group.command(handle_dry_run=True)
    @Colorer.color_options
    @table_format(default='key_value')
    @table_fields(choices=['key', 'value'])
    @argument('keys', nargs=-1, type=CommandSettingsKeyType("value"),
              help="The keys to show. When no keys are provided, all the keys are showed")
    def show(fields, format, keys, all, **kwargs):
        """Show the values"""
        keys = keys or (
            sorted(config.settings.get(settings_name, {}))
            if all
            else sorted(getattr(config, settings_name).readonly.keys())
        )
        with TablePrinter(fields, format) as tp, Colorer(kwargs) as colorer:
            for key in keys:
                if getattr(config, settings_name).readprofile == "settings-file":
                    args = [format(getattr(config, settings_name).readonly.get(key, {}).get("commands", []))]
                elif "/" in getattr(config, settings_name).readprofile:
                    args = getattr(config, settings_name).all_settings.get(
                        getattr(config, settings_name).readprofile,
                        {}
                    ).get(
                        key,
                        {}
                    ).get("value")
                    if args is None:
                        continue
                else:
                    all_values = [
                        (profile.name, getattr(config, settings_name).all_settings.get(profile.name, {}).get(key))
                        for profile in config.all_enabled_profiles
                    ]
                    all_values = [(profile, value) for profile, value in all_values
                                  if value is not None]
                    if not all_values:
                        # noting to show for this key
                        continue
                    last_profile, last_value = all_values[-1]
                    value = last_value["value"]
                    args = colorer.apply_color(value, last_profile)
                tp.echo(key, args)
