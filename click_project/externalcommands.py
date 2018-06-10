#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
import subprocess
import re

from click_project.commandresolver import CommandResolver
from click_project.config import config
from click_project.lib import which
from click_project.log import get_logger

LOGGER = get_logger(__name__)


def external_cmds_paths():
    paths = []
    if config.project:
        paths.extend(config.project_bin_dirs)
    paths.append(os.path.join(config.app_dir, "scripts"))
    paths.extend(os.environ["PATH"].split(os.pathsep))
    return paths


class ExternalCommandResolver(CommandResolver):

    def _list_command_paths(self, parent=None):
        prefix = config.app_name + "-"
        if not hasattr(self, "_external_cmds"):
            self._external_cmds = []
            paths = external_cmds_paths()
            for path in paths:
                if os.path.isdir(path):
                    for file in os.listdir(path):
                        if file.startswith(prefix):
                            for suffix in ".sh", ".py":
                                if file.endswith(suffix):
                                    self._external_cmds.append(file[len(prefix):-3] + suffix.replace(".", "@"))
                                    break
                            else:
                                self._external_cmds.append(file[len(prefix):].replace(".", "@"))
        return self._external_cmds

    def _get_command(self, path, parent=None):
        prefix = config.app_name + "-"
        name = path.replace("@", ".")
        cmdhelp = "external command"
        command_name = prefix + name
        paths = external_cmds_paths()
        command_path = which(command_name, os.pathsep.join(paths))
        try:
            process = subprocess.Popen([command_path, "--help"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, err = process.communicate()
            if process.returncode == 0:
                out = out.decode("utf-8")
                cmdhelp_lines = out.splitlines()
                try:
                    index_desc = cmdhelp_lines.index('') + 1
                except ValueError:
                    index_desc = None
                if index_desc is None:
                    cmdhelp = out
                else:
                    cmdhelp = cmdhelp_lines[index_desc]
                cmdhelp = cmdhelp.strip()
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

        from click_project.decorators import command, argument

        @command(name=name, help=cmdhelp, ignore_unknown_options=True,
                 add_help_option=False, short_help=cmdhelp.splitlines()[0],
                 handle_dry_run=True,
                 flowdepends=cmdflowdepends)
        @argument('args', nargs=-1)
        def external_command(args):
            from click_project.lib import call
            call([command_path] + list(args))
        return external_command
