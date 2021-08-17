#!/usr/bin/env python
# -*- coding: utf-8 -*-

import click
import click_completion

import clk.completion
from clk.commands.parameter import get_choices
from clk.completion import CASE_INSENSITIVE_ENV
from clk.config import config
from clk.decorators import argument, flag, group, option
from clk.lib import DocumentedChoice, call_me, quote, updated_env
from clk.log import get_logger
from clk.overloads import CommandType

LOGGER = get_logger(__name__)


class CompletionConfig(object):
    def __init__(self):
        self.case_insensitive = False


cmd_help = """Shell completion

Available shell types:

\b
  %s

Default type: auto
""" % '\n  '.join('{:<12} {}'.format(k, click_completion.shells[k]) for k in sorted(click_completion.shells.keys()))


@group(help=cmd_help)
@option('-i', '--case-insensitive/--no-case-insensitive', help='Completion will be case insensitive')
def completion(case_insensitive):
    """Shell completion"""
    config.completion = CompletionConfig()
    config.completion.case_insensitive = case_insensitive


@completion.command(handle_dry_run=True)
@argument('shell', required=False, type=DocumentedChoice(click_completion.shells))
def show(shell):
    """Show the completion code"""
    extra_env = {CASE_INSENSITIVE_ENV: 'ON'} if config.completion.case_insensitive else {}
    click.echo(click_completion.get_code(shell, extra_env=extra_env))


@completion.command(handle_dry_run=True, ignore_unknown_options=True)
@option('--description/--no-description', help='Display the argument description')
@option('--last/--after', help='Complete the last argument')
@flag('--call/--no-call', help='Call in a new process.' ' --no-call is useful in combination with --post-mortem')
@argument('command', type=CommandType(recursive=False), help='The command about which to try the completion')
@argument('args', nargs=-1, help='The arguments to provide to the command')
def _try(description, last, command, args, call):
    """Try the completion"""
    if command == config.main_command.path:
        args = [config.main_command.path] + list(args)
    else:
        args = [config.main_command.path, command] + list(args)
    complete_envvar = '_{}_COMPLETE'.format(config.main_command.path.upper().replace('-', '_'))
    if description:
        extra_env = {
            'COMMANDLINE': ' '.join(quote(arg) for arg in args) + ('' if last else ' '),
            complete_envvar: 'complete-fish',
        }
    else:
        extra_env = {
            'COMP_WORDS': ' '.join(quote(arg) for arg in args),
            'COMP_CWORD': str(max(0,
                                  len(args) - (1 if last else 0))),
            complete_envvar: 'complete',
        }
    extra_env.update({CASE_INSENSITIVE_ENV: 'ON'} if config.completion.case_insensitive else {})
    with updated_env(**extra_env):
        if call:
            call_me()
        else:
            oldvalue = clk.completion.IN_COMPLETION
            clk.completion.IN_COMPLETION = True
            config.main_command()
            clk.completion.IN_COMPLETION = oldvalue


_try.get_choices = get_choices


@completion.command(handle_dry_run=True)
@option('--append/--overwrite', help='Append the completion code to the file', default=None)
@argument('shell', required=False, type=DocumentedChoice(click_completion.shells), help='The shell that will be used')
@argument('path', required=False, help='Where to install the completion')
def install(append, shell, path):
    """Install the completion"""
    extra_env = {CASE_INSENSITIVE_ENV: 'ON'} if config.completion.case_insensitive else {}
    if not config.dry_run:
        shell, path = click_completion.install(shell=shell, path=path, append=append, extra_env=extra_env)
        LOGGER.info('%s completion installed in %s' % (shell, path))
