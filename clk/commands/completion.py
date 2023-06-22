#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from pathlib import Path

import click

import clk.completion
from clk.completion import CASE_INSENSITIVE_ENV
from clk.config import config
from clk.decorators import argument, flag, group, option
from clk.lib import call_me, check_my_output, check_output, quote, updated_env
from clk.log import get_logger
from clk.overloads import CommandType

LOGGER = get_logger(__name__)


class CompletionConfig(object):

    def __init__(self):
        self.case_insensitive = False

    def content(self, shell):
        if shell != 'bash':
            raise NotImplementedError
        res = check_output([sys.executable, '-m', 'clk'], env={'_CLK_COMPLETE': 'bash_source'})
        if config.completion.case_insensitive:
            res = res.replace('env COMP_WORDS', f'env {CASE_INSENSITIVE_ENV}=ON COMP_WORDS')

        return res


@group()
@option('-i', '--case-insensitive/--no-case-insensitive', help='Completion will be case insensitive')
def completion(case_insensitive):
    """Shell completion"""
    config.completion = CompletionConfig()
    config.completion.case_insensitive = case_insensitive


@completion.command(handle_dry_run=True)
@argument('shell',
          help='What shell to show the completion for (only bash supported for now)',
          required=False,
          default='bash',
          type=click.Choice(['bash']))
def show(shell):
    """Show the completion code"""
    click.echo(config.completion.content(shell))


@completion.command(handle_dry_run=True, ignore_unknown_options=True)
@option('--description/--no-description', help='Display the argument description')
@option('--last/--after', help='Complete the last argument')
@flag('--remove-bash-formatting/--no-remove-bash-formatting',
      help='Remove the bash formatting, only has effect in bash and with --call',
      default=True)
@flag('--call/--no-call', help='Call in a new process.'
      ' --no-call is useful in combination with --post-mortem')
@argument('command', type=CommandType(recursive=False), help='The command about which to try the completion')
@argument('args', nargs=-1, help='The arguments to provide to the command')
def _try(remove_bash_formatting, description, last, command, args, call):
    """Try the completion"""
    if command == config.main_command.path:
        args = [config.main_command.path] + list(args)
    else:
        args = [config.main_command.path, command] + list(args)
    complete_envvar = '_{}_COMPLETE'.format(config.main_command.path.upper().replace('-', '_'))
    if description:
        extra_env = {
            'COMMANDLINE': ' '.join(quote(arg) for arg in args) + ('' if last else ' '),
            complete_envvar: 'fish_complete',
        }
    else:
        extra_env = {
            'COMP_WORDS': ' '.join(quote(arg) for arg in args),
            'COMP_CWORD': str(max(0,
                                  len(args) - (1 if last else 0))),
            complete_envvar: 'bash_complete',
        }
    extra_env.update({CASE_INSENSITIVE_ENV: 'ON'} if config.completion.case_insensitive else {})
    with updated_env(**extra_env):
        if call:
            if remove_bash_formatting:
                result = check_my_output()
                result = '\n'.join([','.join(line.split(',')[1:]) for line in result.splitlines()])
                click.echo(result)
            else:
                call_me()
        else:
            oldvalue = clk.completion.IN_COMPLETION
            clk.completion.IN_COMPLETION = True
            config.main_command()
            clk.completion.IN_COMPLETION = oldvalue


@completion.command(handle_dry_run=True)
@option('--append/--overwrite', help='Append the completion code to the file', default=None)
@argument('shell',
          default='bash',
          type=click.Choice(['bash']),
          help='The shell that will be used (for now, only bash supported)')
@argument('path', required=False, help='Where to install the completion')
def install(append, shell, path):
    """Install the completion"""
    if not config.dry_run:
        comp_file = Path('~/.bash_completion').expanduser()
        completion_content = config.completion.content(shell)
        comp_file.open('a').write(completion_content)
        LOGGER.info('%s completion installed in %s' % (shell, comp_file))
