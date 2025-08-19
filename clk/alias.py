#!/usr/bin/env python

import shlex

import click
from click.core import ParameterSource

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


def format(cmds, sep=" , "):
    """Format the alias command"""
    return sep.join(" ".join(cmd) for cmd in cmds)


def edit_alias_command_in_profile(path, profile):
    old_value = profile.settings.get("alias", {}).get(path)
    old_value = format(old_value["commands"], sep="\n")
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


class AliasToGroupResolver(CommandResolver):
    name = "alias to group"

    def _list_command_paths(self, parent):
        try:
            original_command = parent.original_command
        except AttributeError:
            return []
        return [
            "{}.{}".format(parent.path, cmd_name)
            for cmd_name in list_commands(original_command.path)
        ]

    def _get_command(self, path, parent):
        cmd_name = path.split(".")[-1]
        parent = parent.original_command
        original_path = "{}.{}".format(parent.path, cmd_name)
        return get_command(original_path)


class AliasCommandResolver(CommandResolver):
    name = "alias"

    def _list_command_paths(self, parent):
        if isinstance(parent, config.main_command.__class__):
            return [a for a in config.get_settings("alias").keys()]
        else:
            return [
                a
                for a in config.get_settings("alias").keys()
                if a.startswith(parent.path + ".") and a[len(parent.path) + 1 :] != 0
            ]

    def _get_command(self, path, parent=None):
        name = path.split(".")[-1]
        commands_to_run = config.get_settings("alias")[path]["commands"]
        cmdhelp = config.get_settings("alias")[path]["documentation"]
        cmdhelp = cmdhelp or "Alias for: {}".format(
            " , ".join(" ".join(quote(arg) for arg in cmd) for cmd in commands_to_run)
        )
        short_help = cmdhelp.splitlines()[0]
        if len(cmdhelp) > 55:
            short_help = cmdhelp[:52] + "..."
        deps = []

        for cmd in commands_to_run[:-1]:
            # get the contexts of the commands to capture the flow. I don't want
            # to allow side effects because they are only supposed to be run,
            # not to impact how the alias will behave in completion, parameters
            # etc.
            cmdctx = get_ctx(cmd, resilient_parsing=True, side_effects=False)
            # I capture the flow only if it has not already been consumed by the
            # command itself
            if not any(
                cmdctx.params.get(o) for o in ("flow", "flow_after", "flow_from")
            ):
                deps += flowdeps[cmdctx.command.path]

        # also get the context of the last command to capture its flow. In that
        # case, I wan't to allow side effects because I want this command to
        # impact the behavior of the generated alias. Its parameters, completion
        # or whatever should transpire in the aliased command. The parsing must
        # be resilient though because the aliased command might be incomplete
        # (like it might be missing an argument)
        c = get_ctx(commands_to_run[-1], side_effects=True, resilient_parsing=True)
        deps += flowdeps[c.command.path]
        deps = ordered_unique(deps)

        kind = None

        def create_cls(cls):
            return cls(
                name=name,
                help=cmdhelp,
                short_help=short_help,
                ignore_unknown_options=c is not None and c.ignore_unknown_options,
            )

        if c is not None:
            if isinstance(c.command, Group):
                cls = create_cls(group)
                kind = "group"
            elif isinstance(c.command, Command):
                cls = create_cls(command)
                kind = "command"
            elif isinstance(c.command, config.main_command.__class__):
                cls = click.group(
                    cls=config.main_command.__class__,
                    name=name,
                    help=cmdhelp,
                    short_help=short_help,
                )
                kind = config.main_command.path
            else:
                raise NotImplementedError()
        elif commands_to_run[-1][0] == config.main_command.path:
            cls = click.group(
                cls=config.main_command.__class__,
                name=name,
                help=cmdhelp,
                short_help=short_help,
            )
            del commands_to_run[-1][0]
            c = get_ctx(commands_to_run[-1])
            kind = config.main_command.path
        else:
            cls = create_cls(command)

        def alias_command(ctx, *args, **kwargs):
            if "config" in kwargs:
                del kwargs["config"]
            commands = list(commands_to_run)

            for command_ in commands[:-1]:
                LOGGER.debug(
                    "Running command: {}".format(" ".join(quote(c) for c in command_))
                )
                run(command_)
            arguments = ctx.complete_arguments[:]
            arguments = clean_flow_arguments(arguments)
            if "--" in commands[-1]:
                separator_index = commands[-1].index("--")
                processed_part = commands[-1][:separator_index]
                ignored_part = commands[-1][separator_index + 1 :]
                whole_command = processed_part + arguments + ["--"] + ignored_part
            else:
                whole_command = commands[-1] + arguments
            original_command_ctx = get_ctx(whole_command, side_effects=True)
            cur_ctx = original_command_ctx
            ctxs = []
            # if the resolution of the context brought too many commands, we
            # must not call the call back of the children of the original_command
            while cur_ctx and ctx.command.original_command != cur_ctx.command:
                cur_ctx = cur_ctx.parent

            while cur_ctx:
                ctxs.insert(0, cur_ctx)
                cur_ctx = cur_ctx.parent
            LOGGER.develop(
                "Running command: {}".format(" ".join(quote(c) for c in commands[-1]))
            )

            def run_callback(_ctx):
                LOGGER.develop(
                    "Running callback of {} with args {}, params {}".format(
                        _ctx.command.path,
                        config.commandline_profile.get_settings("parameters")[
                            _ctx.command.path
                        ],
                        _ctx.params,
                    )
                )
                # this alias already captured the complete flow, hence we should
                # not trigger any flow behavior of the aliased commands
                for flow_param in "flow", "flow_from", "flow_after":
                    if flow_param in _ctx.params:
                        _ctx.params[flow_param] = None
                with _ctx:
                    old_resilient_parsing = _ctx.resilient_parsing
                    _ctx.resilient_parsing = ctx.resilient_parsing
                    _ctx.command.callback(**_ctx.params)
                    _ctx.resilient_parsing = old_resilient_parsing

            for cur_ctx in ctxs:
                run_callback(cur_ctx)

        alias_command = pass_context(alias_command)
        alias_command = cls(alias_command)
        alias_command.params.append(
            AutomaticOption(
                ["--edit-alias"],
                help="Edit the alias",
                expose_value=False,
                is_flag=True,
                callback=lambda ctx, param, value: edit_alias_command(path)
                if value is True
                else None,
            )
        )
        if deps:
            alias_command.clk_flowdepends = deps
            alias_command.clk_flow = c.params.get("flow")
            alias_command.clk_flowfrom = c.params.get("flow_from")
            alias_command.clk_flowafter = c.params.get("flow_after")

        alias_command.commands_to_run = commands_to_run
        if c is not None:
            alias_command.original_command = c.command
            if kind == "group":
                if c.command.default_cmd_name is not None:
                    alias_command.set_default_command(c.command.default_cmd_name)
            elif kind == "command":
                alias_command.handle_dry_run = c.command.handle_dry_run
            alias_param_names = list(map(lambda c: c.name, alias_command.params))

            def was_given(param):
                return c.get_parameter_source(param.name) != ParameterSource.DEFAULT

            alias_command.params = [
                param
                for param in c.command.params
                if param.name not in alias_param_names
                and param.name not in ("flow", "flow_from", "flow_after")
                and (
                    # options may be given several times
                    isinstance(param, click.Option)
                    or (
                        # it is an argument then!
                        not was_given(param)
                        or
                        # may be given, but may be given again
                        param.multiple
                        or
                        # may be given, but may be given again
                        param.nargs == -1
                    )
                )
            ] + alias_command.params
            # any option required that was already given should be no more
            # required
            for param in alias_command.params:
                if param.required and was_given(param):
                    param.required = False
        return alias_command
