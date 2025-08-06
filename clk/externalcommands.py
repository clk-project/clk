#!/usr/bin/env python
# -*- coding: utf-8 -*-

import importlib
import json
import os
import re
import subprocess
from pathlib import Path

import click

from clk.commandresolver import CommandResolver
from clk.config import config, temp_config
from clk.customcommands import build_update_extension_callback
from clk.lib import call, quote, updated_env, value_to_string, which
from clk.log import get_logger
from clk.overloads import AutomaticOption
from clk.types import Date, Suggestion

LOGGER = get_logger(__name__)


def edit_external_command(command_path):
    click.edit(filename=command_path)
    exit(0)


class ExternalCommandResolver(CommandResolver):
    name = 'external'

    def __init__(self, settings=None):
        self.settings = settings

    @property
    def customcommands(self):
        return (self.settings.get('customcommands') if self.settings else config.get_settings2('customcommands'))

    @property
    def cmddirs(self):
        return (self.customcommands.get('executablepaths', []))

    def _list_command_paths(self, parent=None):
        if not hasattr(self, '_external_cmds'):
            self._external_cmds = []
            for path in reversed(self.cmddirs):
                if os.path.isdir(path):
                    for file in os.listdir(path):
                        abspath = os.path.join(path, file)
                        if os.path.isfile(abspath) and os.access(abspath, os.X_OK):
                            cmd_name, ext = os.path.splitext(file)
                            if ext in ('.sh', '.py'):
                                name = cmd_name + '@' + ext[1:]
                            else:
                                name = file
                            self._external_cmds.append(name)
        return self._external_cmds

    def _get_command(self, path, parent=None):
        name = path.replace('@', '.')
        cmdhelp = 'external command'
        command_name = name
        paths = reversed(self.cmddirs)
        command_path = os.path.abspath(which(command_name, os.pathsep.join(paths)))
        options = []
        arguments = []
        flags = []
        remaining_args = False
        ignore_unknown_options = False
        cmd_flowoptions = []

        def compute_env(kwargs={}):
            env = {('CLK___' + key).upper(): (value_to_string(value)) for key, value in kwargs.items()}
            env['CLK____JSON'] = json.dumps(kwargs, default=lambda o: str(o))
            try:
                ctx = click.get_current_context()
                if 'args' in ctx.params:
                    env[('CLK___ARGS').upper()] = ' '.join(map(quote, ctx.params['args']))
            except RuntimeError:
                pass

            env.update(config.external_commands_environ_variables)
            env['PATH'] = str(Path(__file__).parent / 'commands/command') + ':' + os.environ['PATH']
            return env

        try:

            with updated_env(**compute_env() | {
                    'COMP_WORDS': None,
                    'COMP_CWORD': None,
                    '_CLK_COMPLETE': None,
            }):
                process = subprocess.Popen([command_path, '--help'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                out, err = process.communicate()
            if process.returncode == 0:
                out = out.decode('utf-8')
                cmdhelp_lines = out.splitlines() + ['']
                try:
                    index_desc = cmdhelp_lines.index('') + 1
                except ValueError:
                    index_desc = 0
                try:
                    metadata_desc = cmdhelp_lines.index('--')
                except ValueError:
                    metadata_desc = -1
                    # then, we don't bother parsing the arguments. Let the
                    # remaining arguments and unknown options pass through
                    ignore_unknown_options = True
                    remaining_args = 'Remaining arguments'
                cmdhelp = '\n'.join(cmdhelp_lines[index_desc:metadata_desc])
                cmdhelp = cmdhelp.strip()
                metadata_out = out[metadata_desc:]
                for line in metadata_out.splitlines():
                    if line.startswith('O:'):
                        m = re.match('^O:(?P<name>[^:]+):(?P<type>[^:]+):(?P<help>[^:]+)(:(?P<default>[^:]+))?$', line)
                        if m is None:
                            raise click.UsageError('Expected format in {} is O:name:type:help[:defautl],'
                                                   ' got {}'.format(path, line))
                        options.append(m.groupdict())
                    if line.startswith('F:'):
                        m = re.match('^F:(?P<name>[^:]+):(?P<help>[^:]+)(:(?P<default>[^:]+))?$', line)
                        if m is None:
                            raise click.UsageError('Expected format in {} is F:name:help[:defautl],'
                                                   ' got {}'.format(path, line))
                        flags.append(m.groupdict())
                    if line.startswith('A:'):
                        m = re.match(
                            '^A:(?P<name>[^:]+):(?P<type>[^:]+):(?P<help>[^:]+)(:(?P<nargs>[^:]+))?(:(?P<default>[^:]+))?$',
                            line)
                        if m is None:
                            raise click.UsageError('Expected format in {} is A:name:type:help[:nargs[:default]],'
                                                   ' got {}'.format(path, line))
                        arguments.append(m.groupdict())
                    m = re.match('^N:(?P<help>[^:]+)$', line)
                    if m is not None:
                        remaining_args = m.group('help')
                    m = re.match('^M:(?P<meta>.+)$', line)
                    if m is not None:
                        meta = m.group('meta')
                        if 'I' in meta:
                            ignore_unknown_options = True
                    m = re.match('^flowoptions: *(?P<target>[^:]+):(?P<options>.+)$', line)
                    if m is not None:
                        target = m.group('target')
                        cmd_flowoptions.append((target, m.group('options').replace(' ', '').split(',')))
                cmdflowdepends = re.search('\nflowdep(end)?s: *(.+)\n', out)
                if cmdflowdepends:
                    cmdflowdepends = cmdflowdepends.group(2).replace(' ', '').split(',')
                else:
                    cmdflowdepends = []
            else:
                cmdflowdepends = []
                cmdhelp = 'No help found... (the command is most likely broken)'
            process.wait()
        except Exception as e:
            LOGGER.warning(f'When loading command {name} at path {command_path}: {e}')
            from clk.overloads import on_command_loading_error
            on_command_loading_error()
            raise

        from clk.decorators import argument, command, flag, option

        def external_command(**kwargs):
            ctx = click.get_current_context()
            config.merge_settings()
            args = ([command_path] + list(ctx.params.get('args', [])))

            with updated_env(**compute_env(kwargs)):
                call(
                    args,
                    internal=True,
                )

        types = {
            'int': int,
            'integer': int,
            'float': float,
            'str': str,
            'string': str,
            'date': Date(),
            'file': lambda s: Path(s).expanduser().absolute(),
        }

        def get_type(t):
            if t.startswith('['):
                if t.endswith('+'):
                    t = Suggestion(json.loads(t[:-1]))
                else:
                    t = click.Choice(json.loads(t))
            elif '.' in t:
                t = t.split('.')
                m = importlib.import_module('.'.join(t[:-1]))
                t = getattr(m, t[-1])
            elif t.startswith('date('):
                format = re.match(r'date\((?P<format>.+)\)', t).group('format')
                from clk.lib import parsedatetime
                t = lambda value: parsedatetime(value)[0].strftime(format)  # NOQA: E731
            else:
                t = types[t]
            return t

        if remaining_args:
            external_command = argument('args', nargs=-1, help=remaining_args)(external_command)
        for o in options:
            if 'type' in o:
                t = get_type(o['type'])
            t = t or str
            external_command = option(
                *(o['name'].split(',')),
                help=o['help'],
                type=t,
                default=t(o.get('default')) if o.get('default') is not None else None,
            )(external_command)
        for a in reversed(arguments):
            if 'type' in a:
                t = get_type(a['type'])
            external_command = argument(
                a['name'],
                help=a['help'],
                type=t or str,
                default=a['default'] or None,
                nargs=int(a['nargs'] or '1'),
            )(external_command)
        for f in flags:
            external_command = flag(
                *(f['name'].split(',')),
                help=f['help'],
                default=f['default'] == 'True',
            )(external_command)
        if cmd_flowoptions:
            from clk.overloads import flow_options, get_command2
            for target, options in cmd_flowoptions:
                with temp_config():
                    target_command = get_command2(target)[0]
                external_command = flow_options(options=options, target_command=target_command)(external_command)
        external_command = command(
            name=name,
            ignore_unknown_options=ignore_unknown_options,
            help=cmdhelp,
            short_help=cmdhelp.splitlines()[0] if cmdhelp else '',
            handle_dry_run=True,
            flowdepends=cmdflowdepends,
        )(external_command)
        external_command.params.append(
            AutomaticOption(['--edit-command'],
                            help='Edit the external command',
                            expose_value=False,
                            is_flag=True,
                            callback=lambda ctx, param, value: edit_external_command(command_path)
                            if value is True else None))
        external_command.customcommand_path = command_path
        profile = config.get_profile_that_contains(command_path)
        if profile is not None and profile.explicit:
            external_command.params.append(
                AutomaticOption(
                    ['--update-extension'],
                    is_flag=True,
                    expose_value=False,
                    help=('Update the extension'
                          ' that contains this command'
                          f' ({profile.location})'),
                    callback=build_update_extension_callback(profile),
                ))
        return external_command
