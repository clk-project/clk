#!/usr/bin/env python

import re
import shlex

import click

from clk.click_internals import was_explicitly_provided
from clk.commandresolver import CommandResolver
from clk.config import config
from clk.core import get_ctx, run
from clk.decorators import pass_context
from clk.flow import clean_flow_arguments, flowdeps
from clk.lib import ordered_unique, quote
from clk.log import get_logger
from clk.overloads import (
    AutomaticOption,
    Command,
    Group,
    command,
    get_command,
    get_command2,
    group,
    list_commands,
)

LOGGER = get_logger(__name__)


def parse(words):
    """Split a list of words into a list of commands"""
    sep = ","
    commands = []
    while sep in words:
        index = words.index(sep)
        commands.append(words[:index])
        del words[: index + 1]
    if words:
        commands.append(words)
    return commands


def format_commands(cmds, sep=" , "):
    """Format the alias command"""
    return sep.join(" ".join(quote(arg) for arg in cmd) for cmd in cmds)


def edit_alias_command_in_profile(path, profile):
    old_value = profile.settings.get("alias", {}).get(path)
    old_value = format_commands(old_value["commands"], sep="\n")
    value = click.edit(old_value, extension=f"_{path}.txt")
    if value == old_value or value is None:
        LOGGER.info("Nothing changed")
    elif value == "":
        LOGGER.info("Aboooooort !!")
    else:
        value = value.strip().replace("\n", " , ")
        LOGGER.status(
            f"Replacing alias {path} in {profile.name} from '{old_value}' to '{value}'"
        )
        profile.settings["alias"][path]["commands"] = parse(shlex.split(value))
        profile.write_settings()


def edit_alias_command(path):
    for profile in config.all_enabled_profiles:
        if profile.settings.get("alias", {}).get(path):
            edit_alias_command_in_profile(path, profile)
            break
    exit(0)


class AliasToGroupCommandResolver(CommandResolver):
    name = "alias to group"

    def _list_command_paths(self, parent, profile):
        try:
            original_command = parent.original_command
        except AttributeError:
            return []
        return [
            f"{parent.path}.{cmd_name}"
            for cmd_name in list_commands(original_command.path)
        ]

    def _get_command(self, path, parent, profile):
        cmd_name = path.split(".")[-1]
        parent = parent.original_command
        original_path = f"{parent.path}.{cmd_name}"
        return get_command(original_path)

    def add_edition_hint(self, ctx, command, formatter):
        ctx = ctx.parent
        group_, _ = get_command2(ctx.command.path)

        original_path = group_.original_command.path
        original, _ = get_command2(original_path)

        formatter.write_paragraph()

        original_command = re.sub(
            "^" + group_.path + r"\.", original.path + ".", command.path
        ).replace(".", " ")
        with formatter.indentation():
            formatter.write_text(
                f"This is a sub command of '{group_.path}' that is an alias towards '{original_path}'"
                " To edit it, try getting help from both of them or from the subcommand"
                f" of the original group (something like `clk {original_command}` --help)"
            )


class AliasCommandResolver(CommandResolver):
    name = "alias"

    def add_edition_hint(self, ctx, command, formatter):
        formatter.write_paragraph()
        with formatter.indentation():
            formatter.write_text(
                f"Edit this alias by running `clk alias edit {command.path}`"
            )
            formatter.write_text(
                f"Or adjust this command `clk alias set {command.path}"
                f" {format_commands(config.get_settings('alias')[command.path]['commands'])}`"
            )

    def _list_command_paths(self, parent, profile):
        aliases = profile.settings.get("alias", {})
        if isinstance(parent, config.main_command.__class__):
            return list(aliases.keys())
        else:
            return [
                a
                for a in aliases.keys()
                if a.startswith(parent.path + ".") and a[len(parent.path) + 1 :] != 0
            ]

    def _collect_flow_dependencies(self, commands_to_run):
        """Collect flow dependencies from the commands in the alias."""
        deps = []
        for cmd in commands_to_run[:-1]:
            # Get contexts without side effects - these commands are only run,
            # not meant to impact alias behavior in completion, parameters, etc.
            cmdctx = get_ctx(cmd, resilient_parsing=True, side_effects=False)
            # Capture flow only if not already consumed by the command itself
            if not any(
                cmdctx.params.get(o) for o in ("flow", "flow_after", "flow_from")
            ):
                deps += flowdeps[cmdctx.command.path]
        return deps

    def _get_last_command_context(self, commands_to_run):
        """Get context of the last command with side effects enabled.

        Side effects are enabled because we want this command to impact
        the behavior of the generated alias (parameters, completion, etc.).
        Parsing is resilient because the aliased command might be incomplete.
        """
        return get_ctx(commands_to_run[-1], side_effects=True, resilient_parsing=True)

    def _determine_command_kind(self, name, cmdhelp, short_help, c, commands_to_run):
        """Determine the kind of command (group, command, or main) and create decorator."""

        def create_cls(cls):
            return cls(
                name=name,
                help=cmdhelp,
                short_help=short_help,
                ignore_unknown_options=c is not None and c.ignore_unknown_options,
            )

        if c is not None:
            if isinstance(c.command, Group):
                return create_cls(group), "group", c, commands_to_run
            elif isinstance(c.command, Command):
                return create_cls(command), "command", c, commands_to_run
            elif isinstance(c.command, config.main_command.__class__):
                cls = click.group(
                    cls=config.main_command.__class__,
                    name=name,
                    help=cmdhelp,
                    short_help=short_help,
                )
                return cls, config.main_command.path, c, commands_to_run
            else:
                raise NotImplementedError()
        elif commands_to_run[-1][0] == config.main_command.path:
            cls = click.group(
                cls=config.main_command.__class__,
                name=name,
                help=cmdhelp,
                short_help=short_help,
            )
            commands_to_run = commands_to_run[:-1] + [commands_to_run[-1][1:]]
            c = get_ctx(commands_to_run[-1])
            return cls, config.main_command.path, c, commands_to_run
        else:
            return create_cls(command), None, c, commands_to_run

    def _create_alias_callback(self, commands_to_run):
        """Create the callback function that executes when the alias is invoked."""

        def alias_command(ctx, *args, **kwargs):
            if "config" in kwargs:
                del kwargs["config"]
            commands = list(commands_to_run)

            # Run all commands except the last one
            for command_ in commands[:-1]:
                LOGGER.debug(
                    "Running command: {}".format(" ".join(quote(c) for c in command_))
                )
                run(command_)

            # Build the final command with arguments
            arguments = clean_flow_arguments(ctx.complete_arguments[:])
            whole_command = commands[-1] + arguments

            # Resolve context chain
            original_command_ctx = get_ctx(whole_command, side_effects=True)
            cur_ctx = original_command_ctx
            ctxs = []
            # Don't call callbacks of children of original_command
            while cur_ctx and ctx.command.original_command != cur_ctx.command:
                cur_ctx = cur_ctx.parent
            while cur_ctx:
                ctxs.insert(0, cur_ctx)
                cur_ctx = cur_ctx.parent

            LOGGER.develop(
                "Running command: {}".format(" ".join(quote(c) for c in commands[-1]))
            )

            # Execute callbacks
            for cur_ctx in ctxs:
                self._run_aliased_callback(cur_ctx, ctx)

        return alias_command

    def _run_aliased_callback(self, _ctx, parent_ctx):
        """Run the callback of an aliased command context."""
        LOGGER.develop(
            "Running callback of {} with args {}, params {}".format(
                _ctx.command.path,
                config.commandline_profile.get_settings("parameters")[
                    _ctx.command.path
                ],
                _ctx.params,
            )
        )
        # Disable flow behavior since alias already captured the complete flow
        for flow_param in ("flow", "flow_from", "flow_after"):
            if flow_param in _ctx.params:
                _ctx.params[flow_param] = None
        with _ctx:
            old_resilient_parsing = _ctx.resilient_parsing
            _ctx.resilient_parsing = parent_ctx.resilient_parsing
            _ctx.command.callback(**_ctx.params)
            _ctx.resilient_parsing = old_resilient_parsing

    def _configure_alias_params(self, alias_command, c, kind):
        """Configure parameters from the original command on the alias."""
        if c is None:
            return

        alias_command.original_command = c.command
        if kind == "group":
            if c.command.default_cmd_name is not None:
                alias_command.set_default_command(c.command.default_cmd_name)
        elif kind == "command":
            alias_command.handle_dry_run = c.command.handle_dry_run

        alias_param_names = [p.name for p in alias_command.params]

        def was_given(param):
            return was_explicitly_provided(c, param.name)

        # Add params from original command that aren't already on alias
        alias_command.params = [
            param
            for param in c.command.params
            if param.name not in alias_param_names
            and param.name not in ("flow", "flow_from", "flow_after")
            and (
                isinstance(param, click.Option)  # options may be given several times
                or not was_given(param)  # argument not yet given
                or param.multiple  # may be given again
                or param.nargs == -1  # may be given again
            )
        ] + alias_command.params

        # Mark already-given required params as no longer required
        for param in alias_command.params:
            if param.required and was_given(param):
                param.required = False

    def _get_command(self, path, parent, profile):
        name = path.split(".")[-1]
        alias_settings = profile.settings["alias"][path]
        commands_to_run = alias_settings["commands"]
        cmdhelp = alias_settings["documentation"]
        cmdhelp = cmdhelp or f"Alias for: {format_commands(commands_to_run)}"
        short_help = cmdhelp.splitlines()[0]
        if len(cmdhelp) > 55:
            short_help = cmdhelp[:52] + "..."

        # Collect flow dependencies from all commands
        deps = self._collect_flow_dependencies(commands_to_run)
        c = self._get_last_command_context(commands_to_run)
        deps += flowdeps[c.command.path]
        deps = ordered_unique(deps)

        # Determine command type and get decorator
        cls, kind, c, commands_to_run = self._determine_command_kind(
            name, cmdhelp, short_help, c, commands_to_run
        )

        # Create and decorate the alias callback
        alias_callback = self._create_alias_callback(commands_to_run)
        alias_callback = pass_context(alias_callback)
        alias_command = cls(alias_callback)

        # Add edit option
        alias_command.params.append(
            AutomaticOption(
                ["--edit-alias"],
                help="Edit the alias",
                expose_value=False,
                is_flag=True,
                callback=lambda ctx, param, value: (
                    edit_alias_command(path) if value is True else None
                ),
            )
        )

        # Set flow dependencies if any
        if deps:
            alias_command.clk_flowdepends = deps
            alias_command.clk_flow = c.params.get("flow")
            alias_command.clk_flowfrom = c.params.get("flow_from")
            alias_command.clk_flowafter = c.params.get("flow_after")

        alias_command.commands_to_run = commands_to_run
        self._configure_alias_params(alias_command, c, kind)

        return alias_command
