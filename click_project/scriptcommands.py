#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
import click

from click_project.config import config
from click_project.log import get_logger
from click_project.externalcommands import ExternalCommandResolver

LOGGER = get_logger(__name__)


class ScriptCommandResolver(ExternalCommandResolver):

    @property
    def cmddirs(self):
        cmddirs = []
        if config.project:
            cmddirs.append(config.project + '/scripts')
            cmddirs.append(config.local_profile.location + '/scripts')
            for recipe in config.filter_enabled_profiles(config.local_profile.recipes):
                cmddirs.append(os.path.join(recipe.location, "scripts"))
            cmddirs.append(config.workgroup_profile.location + '/scripts')
            for recipe in config.filter_enabled_profiles(config.workgroup_profile.recipes):
                cmddirs.append(os.path.join(recipe.location, "scripts"))
        cmddirs.append(config.app_dir + "/scripts")
        for recipe in config.filter_enabled_profiles(config.global_profile.recipes):
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
