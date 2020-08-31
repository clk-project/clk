#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from pathlib import Path

import click

from click_project.decorators import (
    argument,
    group,
    use_settings
)
from click_project.config import config
from click_project.lib import quote
from click_project.colors import Colorer
from click_project.log import get_logger


LOGGER = get_logger(__name__)


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
def show(**kwargs):
    """Show all the custom commands paths"""
    with Colorer(kwargs) as colorer:
        values = {
            profile.name: format_paths(
                config.customcommands.all_settings.get(
                    profile.name, {}
                ).get(
                    "paths", []
                )
            )
            for profile in config.all_enabled_profiles
        }
        args = colorer.colorize(values, config.customcommands.readprofile)
        click.echo(" ".join(args))


@customcommands.command()
@argument("paths", nargs=-1, type=Path, help="The paths to add to load custom commands")
def add(paths):
    """Show all the custom commands paths"""
    paths = [str(d) for d in paths]
    config.customcommands.writable["paths"] = config.customcommands.writable.get("paths", []) + list(paths)
    config.customcommands.write()
    LOGGER.info(f"Added {format_paths(paths)} to the profile {config.customcommands.writeprofile}")


@customcommands.command()
@argument("paths", nargs=-1, type=Path, help="The paths to remove from custom commands")
def remove(paths):
    """Remove all the custom commands paths from the profile"""
    paths = [str(d) for d in paths]
    config.customcommands.writable["paths"] = [
        path for path in config.customcommands.writable["paths"]
        if path not in paths
    ]
    config.customcommands.write()
    LOGGER.info(f"Removed {format_paths(paths)} from the profile {config.customcommands.writeprofile}")
