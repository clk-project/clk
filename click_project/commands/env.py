#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os

import click
import six

from click_project.config import config
from click_project.decorators import group, pass_context, table_format, table_fields, use_settings
from click_project.lib import double_quote, TablePrinter
from click_project.keyvaluestore import keyvaluestore_generic_commands


class EnvConfig(object):
    pass


@group(default_command='dump')
@use_settings("environment", EnvConfig)
def env():
    """Show the environment"""
    pass


@env.command(handle_dry_run=True)
@table_format(default='key_value')
@table_fields(choices=['variable', 'value'])
def dump(fields, format):
    """Show all the environment variables"""
    with TablePrinter(fields, format) as tp:
        for k in sorted(os.environ.keys()):
            tp.echo(k, os.environ[k])


@env.command(handle_dry_run=True)
@table_format(default='key_value')
@table_fields(choices=['variable', 'value'])
def altered(fields, format):
    """Show the altered environment"""
    with TablePrinter(fields, format) as tp:
        for k in sorted(config.env.keys()):
            tp.echo(k, os.environ[k])
        for k in sorted(config.override_env.keys()):
            tp.echo(k, os.environ[k])


@env.command(handle_dry_run=True)
@table_format(default='key_value')
@table_fields(choices=['variable', 'value'])
def overriden(fields, format):
    """Show the overriden environment variables"""
    with TablePrinter(fields, format) as tp:
        for k in sorted(config.override_env.keys()):
            tp.echo(k, os.environ[k])


@env.command(handle_dry_run=True)
@table_format(default='key_value')
@table_fields(choices=['variable', 'value'])
def extended(fields, format):
    """Show the extended environment variables"""
    with TablePrinter(fields, format) as tp:
        for k in sorted(config.env.keys()):
            tp.echo(k, os.environ[k])


@env.command(handle_dry_run=True)
@pass_context
def sh(ctx):
    """Show how to set the environment in the Bourne shell"""
    for k, v in sorted(six.iteritems(config.env)):
        click.echo('{k}={v}:${k}'.format(k=k, v=double_quote(v)))
    for k, v in sorted(six.iteritems(config.override_env)):
        click.echo('{k}={v}'.format(k=k, v=double_quote(v)))
    for k in sorted(list(config.env.keys()) + list(config.override_env.keys())):
        click.echo('export {k}'.format(k=k))
    click.echo('# Run this command to configure your shell:')
    click.echo('# eval $({command})'.format(command=ctx.command_path))


@env.command(handle_dry_run=True)
@pass_context
def bash(ctx):
    """Show how to set the environment in the Bourne again shell"""
    for k, v in sorted(six.iteritems(config.env)):
        click.echo('export {k}={v}:${k}'.format(k=k, v=double_quote(v)))
    for k, v in sorted(six.iteritems(config.override_env)):
        click.echo('export {k}={v}'.format(k=k, v=double_quote(v)))
    click.echo('# Run this command to configure your shell:')
    click.echo('# eval $({command})'.format(command=ctx.command_path))


@env.command(handle_dry_run=True)
@pass_context
def zsh(ctx):
    """Show how to set the environment in the Z shell"""
    for k, v in sorted(six.iteritems(config.env)):
        click.echo('export {k}={v}:${k}'.format(k=k, v=double_quote(v)))
    for k, v in sorted(six.iteritems(config.override_env)):
        click.echo('export {k}={v}'.format(k=k, v=double_quote(v)))
    click.echo('# Run this command to configure your shell:')
    click.echo('# eval $({command})'.format(command=ctx.command_path))


@env.command(handle_dry_run=True)
@pass_context
def fish(ctx):
    """Show how to set the environment in the Friendly interactive shell"""
    for k, v in sorted(six.iteritems(config.env)):
        v = v.replace(os.pathsep, ' ') if k == 'PATH' else v
        click.echo('set -x {k} {v} ${k};'.format(k=k, v=double_quote(v)))
    for k, v in sorted(six.iteritems(config.override_env)):
        click.echo('set -x {k} {v};'.format(k=k, v=double_quote(v)))
    click.echo('# Run this command to configure your shell:')
    click.echo('# eval ({command})'.format(command=ctx.command_path))


@env.command(handle_dry_run=True)
@pass_context
def cmd(ctx):
    """Show how to set the environment in the Windows Command Prompt"""
    for k, v in sorted(six.iteritems(config.env)):
        click.echo('SET {k}={v};%{k}%'.format(k=k, v=v))
    for k, v in sorted(six.iteritems(config.override_env)):
        click.echo('SET {k}={v}'.format(k=k, v=v))
    click.echo('REM Run this command to configure your shell:')
    click.echo('REM FOR /f "tokens=*" %i IN (\'{command}\') DO %i'.format(
        command=ctx.command_path))


@env.command(handle_dry_run=True)
@pass_context
def powershell(ctx):
    """Show how to set the environment in the Windows PowerShell"""
    for k, v in sorted(six.iteritems(config.env)):
        click.echo('$Env:{k} = "{v};" + $Env:{k}'.format(k=k, v=double_quote(v)))
    for k, v in sorted(six.iteritems(config.override_env)):
        click.echo('$Env:{k} = "{v}"'.format(k=k, v=double_quote(v)))
    click.echo('# Run this command to configure your shell:')
    click.echo('# & {command} | Invoke-Expression'.format(command=ctx.command_path))


keyvaluestore_generic_commands(env, "environment")
