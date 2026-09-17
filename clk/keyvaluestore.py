#!/usr/bin/env python

import click

from clk.colors import Colorer
from clk.config import config
from clk.decorators import argument, table_fields, table_format
from clk.lib import TablePrinter
from clk.log import get_logger
from clk.overloads import CommandSettingsKeyType

LOGGER = get_logger(__name__)


def keyvaluestore_generic_commands(group, settings_name):
    def get_store():
        """Get the settings store for this key-value store."""
        return getattr(config, settings_name)

    @group.command(ignore_unknown_options=True)
    @argument("key", help="The key")
    @argument("value", help="The value")
    def _set(key, value):
        """Set a value"""
        store = get_store()
        store.writable[key] = {"value": value}
        store.write()

    @group.command(handle_dry_run=True)
    @argument(
        "keys",
        nargs=-1,
        type=CommandSettingsKeyType(settings_name),
        help="The keys to unset",
    )
    def unset(keys):
        """Unset some values"""
        store = get_store()
        for key in keys:
            if key not in store.writable:
                raise click.ClickException(
                    "The "
                    f"{Colorer.apply_color_profilename(store.writeprofile)}"
                    f" configuration has no '{key}' value registered."
                    "Try using another profile option (like --local or --global)"
                )
        for key in keys:
            LOGGER.status(
                f"Erasing {key} value from {Colorer.apply_color_profilename(store.writeprofile)} settings"
            )
            del store.writable[key]
        store.write()

    @group.command(handle_dry_run=True)
    @Colorer.color_options
    @table_format(default="key_value")
    @table_fields(choices=["key", "value"])
    @argument(
        "keys",
        nargs=-1,
        type=CommandSettingsKeyType(settings_name),
        help="The keys to show. When no keys are provided, all the keys are showed",
    )
    def show(fields, format, keys, **kwargs):
        """Show the values"""
        store = get_store()
        keys = keys or (
            sorted(config.settings.get(settings_name, {}))
            if all
            else sorted(store.readonly.keys())
        )
        with TablePrinter(fields, format) as tp, Colorer(kwargs) as colorer:
            for key in keys:
                if store.readprofile == "settings-file":
                    args = [format(store.readonly.get(key, {}).get("commands", []))]
                elif "/" in store.readprofile:
                    args = (
                        store.all_settings.get(store.readprofile, {})
                        .get(key, {})
                        .get("value")
                    )
                    if args is None:
                        continue
                else:
                    all_values = [
                        (
                            profile.name,
                            store.all_settings.get(profile.name, {}).get(key),
                        )
                        for profile in config.all_enabled_profiles
                    ]
                    all_values = [
                        (profile, value)
                        for profile, value in all_values
                        if value is not None
                    ]
                    if not all_values:
                        # noting to show for this key
                        continue
                    last_profile, last_value = all_values[-1]
                    value = last_value["value"]
                    args = colorer.apply_color(value, last_profile)
                tp.echo(key, args)
