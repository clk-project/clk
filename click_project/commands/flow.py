#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import logging

from click_project.decorators import command, argument, pass_context
from click_project.completion import startswith, compute_choices
from click_project.overloads import Group, get_command
from click_project.flow import execute_flow, has_flow
from click_project.overloads import get_ctx
from click_project.lib import quote, ParameterType
from click_project.config import frozen_config, config

LOGGER = logging.getLogger(__name__)


class CommandType(ParameterType):
    def complete(self, ctx, incomplete):
        with frozen_config():
            return [
                (cmd, config.main_command.get_command_short_help(ctx, cmd))
                for cmd in config.main_command.list_commands(ctx)
                if startswith(cmd, incomplete)
                and
                (
                    has_flow(cmd)
                    or
                    isinstance(get_command(cmd), Group)
                    or
                    isinstance(get_command(cmd), config.main_command.__class__)
                )
            ]


def get_choices(ctx, args_, incomplete):
    args = ctx.command.raw_arguments[:]
    while args and args[0].startswith("-"):
        args.pop(0)
    if not args:
        choices = compute_choices(ctx, args_, incomplete)
    else:
        ctx = get_ctx(args)
        if ctx is None:
            LOGGER.warn("{} does not seem valid".format(" ".join(quote(arg) for arg in args)))
            choices = []
        else:
            choices = compute_choices(ctx, args, incomplete)
    for item, help in choices:
        yield (item, help)


@command(ignore_unknown_options=True, handle_dry_run=True)
@argument('command', default="build", type=CommandType())
@argument('params', nargs=-1)
@pass_context
def flow(ctx, command, params):
    """Build and run the CoSMo project"""
    execute_flow([command] + list(params))
