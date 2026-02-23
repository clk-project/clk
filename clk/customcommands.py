#!/usr/bin/env python

import click
from pluginbase import PluginBase

from clk.commandresolver import CommandResolver
from clk.core import run
from clk.log import get_logger
from clk.overloads import AutomaticOption

LOGGER = get_logger(__name__)


def edit_custom_command(path):
    click.edit(filename=path)
    exit(0)


class BadCustomCommandError(Exception):
    pass


def build_update_extension_callback(profile):
    def callback(ctx, param, value):
        if value and not ctx.resilient_parsing:
            run(["extension", "update", profile.name])
            exit(0)

    return callback


class CustomCommandResolver(CommandResolver):
    name = "customcommand"

    def add_edition_hint(self, ctx, command, formatter):
        formatter.write_paragraph()
        with formatter.indentation():
            formatter.write_text(
                f"Edit this custom command by running `clk command edit {command.path}`"
            )
            formatter.write_text(f"Or edit {command.customcommand_path} directly.")

    def __init__(self):
        self._base = None
        self._source_cache = {}

    @property
    def base(self):
        if self._base is None:
            self._base = PluginBase(package="clk.customcommands")
        return self._base

    def _get_python_paths_for_profile(self, profile):
        """Get python paths for a profile.

        For DirectoryProfiles, use python_paths directly.
        For PresetProfiles, look in settings["customcommands"]["pythonpaths"].
        """
        # First try direct python_paths (works for DirectoryProfile)
        if profile.python_paths:
            return profile.python_paths
        # For PresetProfiles, look in settings
        customcommands = profile.settings.get("customcommands", {})
        if isinstance(customcommands, dict):
            return customcommands.get("pythonpaths", [])
        return []

    def _get_source_for_profile(self, profile):
        profile_name = profile.name
        if profile_name not in self._source_cache:
            python_paths = self._get_python_paths_for_profile(profile)
            self._source_cache[profile_name] = self.base.make_plugin_source(
                searchpath=python_paths,
            )
        return self._source_cache[profile_name]

    def _list_command_paths(self, parent, profile):
        source = self._get_source_for_profile(profile)
        return [p.replace("_", "-") for p in source.list_plugins()]

    def _get_command(self, path, parent, profile):
        source = self._get_source_for_profile(profile)
        plugin_name = path.replace("-", "_")
        module = source.load_plugin(plugin_name)
        if plugin_name not in dir(module):
            raise BadCustomCommandError(
                f"The file {module.__file__} must contain a command or a group named {plugin_name}"
            )
        cmd = getattr(module, plugin_name)
        if not isinstance(cmd, click.BaseCommand):
            raise BadCustomCommandError(
                f"The file {module.__file__} must contain a click command or group named {plugin_name}, "
                f"but found a {type(cmd).__name__} instead. Did you forget the @command or @group decorator?"
            )
        cmd.customcommand_path = module.__file__
        if not any("--edit-command" in param.opts for param in cmd.params):
            cmd.params.append(
                AutomaticOption(
                    ["--edit-command"],
                    is_flag=True,
                    expose_value=False,
                    help="Edit this command",
                    callback=lambda ctx, param, value: (
                        edit_custom_command(cmd.customcommand_path)
                        if value is True
                        else None
                    ),
                )
            )
        if profile.explicit:
            if not any("--update-extension" in param.opts for param in cmd.params):
                cmd.params.append(
                    AutomaticOption(
                        ["--update-extension"],
                        is_flag=True,
                        expose_value=False,
                        help=(
                            "Update the extension"
                            " that contains this command"
                            f" ({profile.location if hasattr(profile, 'location') else profile.name})"
                        ),
                        callback=build_update_extension_callback(profile),
                    )
                )
        return cmd
