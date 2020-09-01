#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from pathlib import Path

import click

from click_project.decorators import (
    argument,
    group,
    use_settings,
    table_format,
    table_fields,
)
from click_project.config import config, merge_settings
from click_project.lib import quote, TablePrinter
from click_project.colors import Colorer
from click_project.log import get_logger
from click_project.core import DynamicChoiceType


LOGGER = get_logger(__name__)


class CustomCommandType(DynamicChoiceType):
    def __init__(self, type):
        self.type = type

    def choices(self):
        _, settings = merge_settings(config.iter_settings(explicit_only=True))
        return settings["customcommands"].get(self.type, [])


class CustomCommandConfig:
    pass


def format_paths(path):
    return " ".join(map(quote, path))


@group(default_command="show")
@use_settings("customcommands", CustomCommandConfig, override=False)
def customcommands():
    """Manipulate paths where to find extra commands"""


@customcommands.command()
@Colorer.color_options
@table_format(default='key_value')
@table_fields(choices=['name', 'paths'])
def show(fields, format, **kwargs):
    """Show all the custom commands paths"""
    with Colorer(kwargs) as colorer, TablePrinter(fields, format) as tp:
        values = {
            profile.name: format_paths(
                config.customcommands.all_settings.get(
                    profile.name, {}
                ).get(
                    "pythonpaths", []
                )
            )
            for profile in config.all_enabled_profiles
        }
        args = colorer.colorize(values, config.customcommands.readprofile)
        tp.echo("pythonpaths", " ".join(args))
        values = {
            profile.name: format_paths(
                config.customcommands.all_settings.get(
                    profile.name, {}
                ).get(
                    "externalpaths", []
                )
            )
            for profile in config.all_enabled_profiles
        }
        args = colorer.colorize(values, config.customcommands.readprofile)
        tp.echo("externalpaths", " ".join(args))


@customcommands.command()
@argument("paths", nargs=-1, type=Path, help="The paths to add to load custom commands")
def add_python_path(paths):
    """Show all the custom commands paths"""
    paths = [str(d) for d in paths]
    config.customcommands.writable["pythonpaths"] = config.customcommands.writable.get("pythonpaths", []) + list(paths)
    config.customcommands.write()
    LOGGER.info(f"Added {format_paths(paths)} to the profile {config.customcommands.writeprofile}")


@customcommands.command()
@argument("paths", nargs=-1, type=CustomCommandType("pythonpaths"), help="The paths to remove from custom commands")
def remove_python_path(paths):
    """Remove all the custom commands paths from the profile"""
    to_remove = set(config.customcommands.writable.get("pythonpaths", [])).intersection(paths)
    if not to_remove:
        raise click.UsageError(
            "None of the given path is present. This command would be a no-op."
        )
    config.customcommands.writable["pythonpaths"] = [
        path for path in config.customcommands.writable.get("pythonpaths", [])
        if path not in to_remove
    ]
    config.customcommands.write()
    LOGGER.info(f"Removed {format_paths(to_remove)} from the profile {config.customcommands.writeprofile}")


@customcommands.command()
@argument("paths", nargs=-1, type=Path, help="The paths to add to load custom commands")
def add_external_path(paths):
    """Show all the custom commands paths"""
    paths = [str(d) for d in paths]
    config.customcommands.writable["externalpaths"] = config.customcommands.writable.get("externalpaths", []) + list(paths)
    config.customcommands.write()
    LOGGER.info(f"Added {format_paths(paths)} to the profile {config.customcommands.writeprofile}")


@customcommands.command()
@argument("paths", nargs=-1, type=CustomCommandType("externalpaths"), help="The paths to remove from custom commands")
def remove_external_path(paths):
    """Remove all the custom commands paths from the profile"""
    paths = [str(d) for d in paths]
    to_remove = set(config.customcommands.writable.get("externalpaths", [])).intersection(paths)
    if not to_remove:
        raise click.UsageError(
            "None of the given path is present. This command would be a no-op."
        )
    config.customcommands.writable["externalpaths"] = [
        path for path in config.customcommands.writable.get("externalpaths", [])
        if path not in to_remove
    ]
    config.customcommands.write()
    LOGGER.info(f"Removed {format_paths(to_remove)} from the profile {config.customcommands.writeprofile}")
