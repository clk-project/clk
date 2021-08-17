#!/usr/bin/env python
# -*- coding: utf-8 -*-

import fnmatch as fnmatchlib
import os

import click_completion
from click import Argument, MultiCommand, Option

from clk.lib import to_bool

CASE_INSENSITIVE_ENV = '_CLK_CASE_INSENSITIVE_COMPLETION'
COMPLETE_OPTIONS = '_CLK_COMPLETE_OPTIONS'


def startswith(string, incomplete):
    if os.environ.get(CASE_INSENSITIVE_ENV):
        string = string.lower()
        incomplete = incomplete.lower()
    return string.startswith(incomplete)


def fnmatch(string, incomplete):
    if os.environ.get(CASE_INSENSITIVE_ENV):
        string = string.lower()
        incomplete = incomplete.lower()
    return fnmatchlib.fnmatch(string, incomplete)


IN_COMPLETION = None
_get_choices = click_completion.get_choices


def get_choices(cli, prog_name, args, incomplete):
    from click_completion import resolve_ctx
    ctx = resolve_ctx(cli, prog_name, args)
    if ctx is None:
        return
    if hasattr(ctx.command, 'get_choices'):
        choices = ctx.command.get_choices(ctx, args, incomplete)
    else:
        choices = _get_choices(cli, prog_name, args, incomplete)
    for item, help in choices:
        yield (item, help)


def compute_choices(ctx, args, incomplete):
    optctx = None
    if args:
        for param in ctx.command.get_params(ctx):
            if isinstance(param, Option) and not param.is_flag and args[-1] in param.opts + param.secondary_opts:
                optctx = param

    choices = []
    if optctx:
        choices += [c if isinstance(c, tuple) else (c, None) for c in optctx.type.complete(ctx, incomplete)]
    elif incomplete and not incomplete[:1].isalnum():
        for param in ctx.command.get_params(ctx):
            if not isinstance(param, Option):
                continue
            for opt in param.opts:
                if startswith(opt, incomplete):
                    choices.append((opt, param.help))
            for opt in param.secondary_opts:
                if startswith(opt, incomplete):
                    # don't put the doc so fish won't group the primary and
                    # and secondary options
                    choices.append((opt, None))
    elif isinstance(ctx.command, MultiCommand):
        for name in ctx.command.list_commands(ctx):
            if startswith(name, incomplete):
                choices.append((name, ctx.command.get_command_short_help(ctx, name)))
    else:
        for param in ctx.command.get_params(ctx):
            if isinstance(param, Argument):
                choices += [c if isinstance(c, tuple) else (c, None) for c in param.type.complete(ctx, incomplete)]
    return choices


def init():
    click_completion.core.get_choices = get_choices
    click_completion.init(complete_options=to_bool(os.environ.get(COMPLETE_OPTIONS, 'off')),
                          match_incomplete=startswith)
