#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import logging

import click

from click_project.config import get_settings, temp_config, config
from click_project.lib import quote
from click_project.commandresolver import CommandResolver
from click_project.overloads import Group,\
    list_commands, get_command, command, group, get_ctx, Command
from click_project.core import resolve_context_with_side_effects
from click_project.decorators import pass_context
from click_project.flow import get_flow_commands_to_run

LOGGER = logging.getLogger(__name__)


class AliasToGroupResolver(CommandResolver):

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


class DottedAliasResolver(CommandResolver):

    def _list_command_paths(self, parent):
        for alias in [a for a in get_settings('alias').keys() if "." in a]:
            split = alias.split(".")[:-1]
            if isinstance(parent, config.main_command.__class__):
                yield split[0]
            elif alias.startswith(parent.path):
                next_part = alias[len(parent.path)+1:].split(".")[0]
                yield "{}.{}".format(parent.path, next_part)

    def _get_command(self, path, parent=None):
        split = path.split(".")
        name = split[-1]

        @group(name=name)
        def alias_group():
            """Group of several aliases."""
        return alias_group


class AliasCommandResolver(CommandResolver):

    def _list_command_paths(self, parent):
        if isinstance(parent, config.main_command.__class__):
            return [
                a
                for a in get_settings('alias').keys()
                if "." not in a
            ]
        else:
            return [
                a
                for a in get_settings('alias').keys()
                if a.startswith(parent.path + ".")
                and "." not in a[len(parent.path)+1:]
                and a[len(parent.path)+1:] != 0
            ]

    def _get_command(self, path, parent=None):
        name = path.split(".")[-1]
        commands_to_run = get_settings('alias')[path]["commands"]
        cmdhelp = get_settings('alias')[path]["documentation"]
        cmdhelp = cmdhelp or "Alias for: {}".format(' , '.join(' '.join(quote(arg) for arg in cmd) for cmd in commands_to_run))
        short_help = cmdhelp.splitlines()[0]
        if len(cmdhelp) > 55:
            short_help = cmdhelp[:52] + '...'
        deps = []

        for cmd in commands_to_run:
            cmdctx = get_ctx(cmd)
            # capture the flow of the aliased command only if it is not called
            # with an explicit flow
            if (
                    not cmdctx.params.get("flow") and
                    not cmdctx.params.get("flow_from") and
                    not cmdctx.params.get("flow_after")
            ):
                deps += get_flow_commands_to_run(cmdctx.command.path)
        c = resolve_context_with_side_effects(commands_to_run[-1])
        kind = None

        def create_cls(cls):
            return cls(
                name=name,
                help=cmdhelp,
                short_help=short_help,
                ignore_unknown_options=c is not None and c.ignore_unknown_options)
        if c is not None:
            if isinstance(c.command, Group):
                cls = create_cls(group)
                kind = "group"
            elif isinstance(c.command, Command):
                cls = create_cls(command)
                kind = "command"
            elif isinstance(c.command, config.main_command.__class__):
                cls = click.group(cls=config.main_command.__class__, name=name, help=cmdhelp, short_help=short_help)
                kind = config.main_command.path
            else:
                raise NotImplementedError()
        elif commands_to_run[-1][0] == config.main_command.path:
            cls = click.group(cls=config.main_command.__class__, name=name, help=cmdhelp, short_help=short_help)
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
                LOGGER.debug("Running command: {}".format(" ".join(quote(c) for c in command_)))
                with temp_config():
                    config.main_command(command_)
            arguments = ctx.command.complete_arguments[:]
            while "--flow" in arguments:
                del arguments[arguments.index("--flow")]
            while "--flow-from" in arguments:
                del arguments[arguments.index("--flow-from")+1]
                del arguments[arguments.index("--flow-from")]
            to_remove = [i for i, arg in enumerate(arguments) if arg.startswith('--flow-from=')]
            for i in reversed(to_remove):
                del arguments[i]
            while "--flow-after" in arguments:
                del arguments[arguments.index("--flow-after")+1]
                del arguments[arguments.index("--flow-after")]
            to_remove = [i for i, arg in enumerate(arguments) if arg.startswith('--flow-after=')]
            for i in reversed(to_remove):
                del arguments[i]
            whole_command = commands[-1] + arguments
            if whole_command[0] == config.main_command.path:
                whole_command = whole_command[1:]
            original_command_ctx = resolve_context_with_side_effects(whole_command)

            cur_ctx = original_command_ctx
            ctxs = []
            # if the resolution of the context brought too many commands, we
            # must not call the call back of the children of the original_command
            while cur_ctx and ctx.command.original_command != cur_ctx.command:
                cur_ctx = cur_ctx.parent

            while cur_ctx:
                ctxs.insert(0, cur_ctx)
                cur_ctx = cur_ctx.parent
            LOGGER.develop("Running command: {}".format(" ".join(quote(c) for c in commands[-1])))

            def run_callback(_ctx):
                LOGGER.develop("Running callback of {} with args {}, params {}".format(
                    _ctx.command.path,
                    _ctx.command.raw_arguments,
                    _ctx.params,
                ))
                with _ctx:
                    old_resilient_parsing = _ctx.resilient_parsing
                    _ctx.resilient_parsing = ctx.resilient_parsing
                    _ctx.command.callback(
                        **_ctx.params
                    )
                    _ctx.resilient_parsing = old_resilient_parsing
            for cur_ctx in ctxs[:-1]:
                run_callback(cur_ctx)
            cur_ctx = ctxs[-1]
            run_callback(cur_ctx)
        alias_command = pass_context(alias_command)
        alias_command = cls(alias_command)
        if deps:
            alias_command.clickproject_flowdepends = deps

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
                return not (
                    # catched the default value only because it was not
                    # given to the command line
                    param.name in c.click_project_default_catch
                    or
                    # not given for sure
                    c.params.get(param.name) is None
                )
            alias_command.params = [
                param
                for param in c.command.params
                if param.name not in alias_param_names
                and param.name not in ("flow", "flow_from", "flow_after")
                and (
                    # options may be given several times
                    isinstance(param, click.Option)
                    or
                    (
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
            # any option required with nargs=-1 that was already given should be
            # no more required
            for param in alias_command.params:
                if param.nargs == -1 and param.required and was_given(param):
                    param.required = False
        return alias_command
