#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
import re
import click
import subprocess

from click_project.commandresolver import CommandResolver
from click_project.config import config
from click_project.log import get_logger

LOGGER = get_logger(__name__)


class ScriptCommandResolver(CommandResolver):

    @property
    def cmddirs(self):
        cmddirs = []
        if config.project:
            cmddirs.append(config.local_profile.location + '/scripts')
            for recipe in config.filter_enabled_recipes(config.local_profile.recipes):
                cmddirs.append(os.path.join(recipe.location, "scripts"))
            cmddirs.append(config.workgroup_profile.location + '/scripts')
            for recipe in config.filter_enabled_recipes(config.workgroup_profile.recipes):
                cmddirs.append(os.path.join(recipe.location, "scripts"))
        cmddirs.append(config.app_dir + "/scripts")
        for recipe in config.filter_enabled_recipes(config.global_profile.recipes):
            cmddirs.append(os.path.join(recipe.location, "scripts"))
        return cmddirs

    def _list_command_paths(self, parent=None):
        prefix = config.app_name + "-"
        cmddirs = self.cmddirs
        result = []
        for cmddir in cmddirs:
            if os.path.isdir(cmddir):
                for file in os.listdir(cmddir):
                    if not file.startswith(prefix):
                        if os.path.exists(
                                os.path.join(cmddir, prefix + file)
                        ):
                            raise click.UsageError(
                                "In the directory {},"
                                " the external script {}{} and the"
                                " the custom script {} are in conflict".format(
                                    cmddir,
                                    prefix,
                                    file,
                                    file,
                                )
                            )
                        if file.endswith(".sh"):
                            result.append(file[:-3] + "@sh")
                        else:
                            result.append(file.replace(".", "@"))
        return result

    def _get_command(self, path, parent=None):
        name = path.replace("@", ".")
        cmddirs = self.cmddirs
        for cmddir in cmddirs:
            command_path = cmddir + "/" + name
            if os.path.exists(command_path):
                break
        from click_project.decorators import command, argument

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

        @command(name=name,
                 help=cmdhelp,
                 ignore_unknown_options=True,
                 add_help_option=False,
                 handle_dry_run=True,
                 flowdepends=cmdflowdepends)
        @argument('args', nargs=-1)
        def external_command(args):
            from click_project.lib import call
            call([command_path] + list(args))

        return external_command
