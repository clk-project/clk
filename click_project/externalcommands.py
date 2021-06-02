#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
import subprocess
import json
import re
import importlib

import click

from click_project.commandresolver import CommandResolver
from click_project.config import config
from click_project.lib import which, updated_env, quote, call, value_to_string
from click_project.log import get_logger
from click_project.overloads import AutomaticOption

LOGGER = get_logger(__name__)


def edit_external_command(command_path):
    click.edit(filename=command_path)
    exit(0)


class ExternalCommandResolver(CommandResolver):
    name = "external"

    def __init__(self, settings=None):
        self.settings = settings

    @property
    def customcommands(self):
        return (
            self.settings.get("customcommands")
            if self.settings
            else config.get_settings2("customcommands")
        )

    @property
    def cmddirs(self):
        return (
            self.customcommands.get(
                "executablepaths", []
            )
        )

    def _list_command_paths(self, parent=None):
        if not hasattr(self, "_external_cmds"):
            self._external_cmds = []
            for path in reversed(self.cmddirs):
                if os.path.isdir(path):
                    for file in os.listdir(path):
                        abspath = os.path.join(path, file)
                        if os.path.isfile(abspath) and os.access(abspath, os.X_OK):
                            cmd_name, ext = os.path.splitext(file)
                            if ext in (".sh", ".py"):
                                name = cmd_name + "@" + ext[1:]
                            else:
                                name = file
                            self._external_cmds.append(name)
        return self._external_cmds

    def _get_command(self, path, parent=None):
        name = path.replace("@", ".")
        cmdhelp = "external command"
        command_name = name
        paths = reversed(self.cmddirs)
        command_path = os.path.abspath(which(command_name, os.pathsep.join(paths)))
        options = []
        arguments = []
        flags = []
        remaining_args = False
        ignore_unknown_options = False
        try:
            process = subprocess.Popen([command_path, "--help"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, err = process.communicate()
            if process.returncode == 0:
                out = out.decode("utf-8")
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
                    remaining_args = "Remaining arguments"
                cmdhelp = "\n".join(cmdhelp_lines[index_desc:metadata_desc])
                cmdhelp = cmdhelp.strip()
                metadata_out = out[metadata_desc:]
                for l in metadata_out.splitlines():
                    if l.startswith("O:"):
                        m = re.match(
                            "^O:(?P<name>[^:]+):(?P<type>[^:]+):(?P<help>[^:]+)(:(?P<default>[^:]+))?$",
                            l)
                        if m is None:
                            raise click.UsageError(
                                "Expected format in {} is O:name:type:help[:defautl],"
                                " got {}".format(path, l))
                        options.append(
                            m.groupdict()
                        )
                    if l.startswith("F:"):
                        m = re.match("^F:(?P<name>[^:]+):(?P<help>[^:]+)(:(?P<default>[^:]+))?$", l)
                        if m is None:
                            raise click.UsageError(
                                "Expected format in {} is F:name:help[:defautl],"
                                " got {}".format(path, l))
                        flags.append(
                            m.groupdict()
                        )
                    if l.startswith("A:"):
                        m = re.match("^A:(?P<name>[^:]+):(?P<type>[^:]+):(?P<help>[^:]+)(:(?P<nargs>[^:]+))?$", l)
                        if m is None:
                            raise click.UsageError(
                                "Expected format in {} is A:name:type:help[:nargs],"
                                " got {}".format(path, l))
                        arguments.append(
                            m.groupdict()
                        )
                    m = re.match("^N:(?P<help>[^:]+)$", l)
                    if m is not None:
                        remaining_args = m.group("help")
                    m = re.match("^M:(?P<meta>.+)$", l)
                    if m is not None:
                        meta = m.group("meta")
                        if "I" in meta:
                            ignore_unknown_options = True
                cmdflowdepends = re.search('flowdepends: (.+)', out)
                if cmdflowdepends:
                    cmdflowdepends = cmdflowdepends.group(1).split(', ')
                else:
                    cmdflowdepends = []
            else:
                cmdflowdepends = []
                cmdhelp = "No help found... (the command is most likely broken)"
            process.wait()
        except Exception as e:
            LOGGER.warning("When loading command {}: {}".format(name, e))
            from click_project.overloads import on_command_loading_error
            on_command_loading_error()
            raise

        from click_project.decorators import command, argument, option, flag

        def external_command(**kwargs):
            from click_project.lib import call
            ctx = click.get_current_context()
            config.merge_settings()
            args = (
                [command_path]
                + list(ctx.params.get("args", []))
            )

            env = {
                ("CLK___" + key).upper(): (
                    value_to_string(value)
                )
                for key, value in kwargs.items()
            }
            env[("CLK___PATH").upper()] = (
                ctx.command_path.replace(" ", "_").upper()
            )
            if "args" in ctx.params:
                env[("CLK___ARGS").upper()] = " ".join(map(quote, ctx.params["args"]))

            env.update(config.external_commands_environ_variables)
            env[("CLK___CMD_OPTIND").upper()] = (
                str(len(config.commandline_profile.get_settings("parameters")[path]))
            )
            env[("CLK___CMD_ARGS").upper()] = (
                " ".join(quote(a) for a in config.commandline_profile.get_settings("parameters")[path])
            )
            env[("CLK___OPTIND").upper()] = (
                str(len(args[1:]))
            )
            env[("CLK___ALL").upper()] = (
                " ".join(quote(a) for a in args[1:])
            )
            with updated_env(**env):
                call(
                    args,
                    internal=True,
                )
        types = {
            "int": int,
            "float": float,
            "str": str,
        }

        def get_type(t):
            if t.startswith("["):
                t = click.Choice(json.loads(t))
            elif "." in t:
                t = t.split(".")
                m = importlib.import_module(".".join(t[:-1]))
                t = getattr(m, t[-1])
            elif t.startswith("date("):
                format = re.match("date\((?P<format>.+)\)", t).group("format")
                from click_project.lib import parsedatetime
                t = lambda value: parsedatetime(value)[0].strftime(format)
            else:
                t = types[t]
            return t

        if remaining_args:
            external_command = argument('args', nargs=-1, help=remaining_args)(external_command)
        for o in options:
            if "type" in o:
                t = get_type(o["type"])
            external_command = option(
                *(o["name"].split(",")),
                help=o["help"],
                type=t or str,
                default=o.get("default"),
            )(external_command)
        for a in reversed(arguments):
            if "type" in a:
                t = get_type(a["type"])
            external_command = argument(
                a["name"],
                help=a["help"],
                type=t or str,
                nargs=int(a["nargs"] or "1"),
            )(external_command)
        for f in flags:
            external_command = flag(
                *(f["name"].split(",")),
                help=f["help"],
                default=f["default"] == "True",
            )(external_command)

        external_command = command(
            name=name,
            ignore_unknown_options=ignore_unknown_options,
            help=cmdhelp,
            short_help=cmdhelp.splitlines()[0] if cmdhelp else "",
            handle_dry_run=True,
            flowdepends=cmdflowdepends)(
                external_command
            )
        external_command.params.append(
            AutomaticOption(
                ["--edit-customcommand"],
                help="Edit the external command",
                expose_value=False,
                is_flag=True,
                callback=lambda ctx, param, value: edit_external_command(command_path) if value is True else None
            )
        )
        external_command.customcommand_path = command_path
        return external_command
