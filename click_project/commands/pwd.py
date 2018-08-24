#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os

from click_project.decorators import command, argument, table_format, table_fields, option
from click_project.lib import ParameterType, TablePrinter
from click_project.config import config
from click_project.completion import startswith


class PWDType(ParameterType):
    def complete(self, ctx, incomplete):
        return [
            key
            for key in self.values.keys()
            if startswith(key, incomplete)
        ]

    def convert(self, value, param, ctx):
        choices = self.values.keys()
        if value not in choices:
            self.fail('invalid choice: %s. (choose from %s)' %
                      (value, ', '.join(choices)), param, ctx)
        return value

    @property
    def values(self):
        res = self.basic_values
        res.update(self.project_values)
        return res

    @property
    def basic_values(self):
        values = {
            'css-home': config.css.home if config.css else 'None',
            'project': config.project if config.project else 'None',
            'generated': config.generated if config.generated else 'None',
            'current': os.getcwd(),
        }
        if config.midas is not None:
            values["midas-home"] = config.midas.home
        return values

    @property
    def project_values(self):
        values = {
        }
        if config.local_profile:
            values["local"] = config.local_profile.location
        if config.workgroup_profile:
            values["workgroup"] = config.workgroup_profile.location
        if config.global_profile:
            values["global"] = config.global_profile.location
        for recipe in config.all_enabled_recipes:
            values[recipe.name] = recipe.location
        return values


@command(handle_dry_run=True)
@table_format(default='key_value')
@table_fields(choices=['type', 'directory'])
@option('--project/--no-project', help="Also display the directories used by project")
@argument("keys", type=PWDType(), nargs=-1,
          help="Only display these key values. If no key is provided, all the key values are displayed")
def pwd(format, fields, project, keys):
    """Print the working directories"""
    values = PWDType().values if project or keys else PWDType().basic_values
    keys = keys or sorted(values.keys())
    with TablePrinter(fields, format) as tp:
        for k in keys:
            tp.echo(k, values[k])
