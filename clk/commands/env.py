#!/usr/bin/env python

import os

import click

from clk.config import config
from clk.decorators import group, pass_context, table_fields, table_format, use_settings
from clk.keyvaluestore import keyvaluestore_generic_commands
from clk.lib import TablePrinter, double_quote


class EnvConfig:
    pass


@group(default_command="dump")
@use_settings("environment", EnvConfig)
def env():
    """Show the environment"""
    pass


@env.command(handle_dry_run=True)
@table_format(default="key_value")
@table_fields(choices=["variable", "value"])
def dump(fields, format):
    """Show all the environment variables"""
    with TablePrinter(fields, format) as tp:
        for k in sorted(os.environ.keys()):
            tp.echo(k, os.environ[k])


@env.command(handle_dry_run=True)
@table_format(default="key_value")
@table_fields(choices=["variable", "value"])
def altered(fields, format):
    """Show the altered environment"""
    with TablePrinter(fields, format) as tp:
        for k in sorted(config.env.keys()):
            tp.echo(k, os.environ[k])
        for k in sorted(config.override_env.keys()):
            tp.echo(k, os.environ[k])


@env.command(handle_dry_run=True)
@table_format(default="key_value")
@table_fields(choices=["variable", "value"])
def overriden(fields, format):
    """Show the overriden environment variables"""
    with TablePrinter(fields, format) as tp:
        for k in sorted(config.override_env.keys()):
            tp.echo(k, os.environ[k])


@env.command(handle_dry_run=True)
@table_format(default="key_value")
@table_fields(choices=["variable", "value"])
def extended(fields, format):
    """Show the extended environment variables"""
    with TablePrinter(fields, format) as tp:
        for k in sorted(config.env.keys()):
            tp.echo(k, os.environ[k])


@env.command(handle_dry_run=True)
@pass_context
def sh(ctx):
    """Show how to set the environment in the Bourne shell"""
    for k, v in sorted(config.env.items()):
        click.echo(f"{k}={double_quote(v)}:${k}")
    for k, v in sorted(config.override_env.items()):
        click.echo(f"{k}={double_quote(v)}")
    for k in sorted(list(config.env.keys()) + list(config.override_env.keys())):
        click.echo(f"export {k}")
    click.echo("# Run this command to configure your shell:")
    click.echo(f"# eval $({ctx.command_path})")


@env.command(handle_dry_run=True)
@pass_context
def bash(ctx):
    """Show how to set the environment in the Bourne again shell"""
    for k, v in sorted(config.env.items()):
        click.echo(f"export {k}={double_quote(v)}:${k}")
    for k, v in sorted(config.override_env.items()):
        click.echo(f"export {k}={double_quote(v)}")
    click.echo("# Run this command to configure your shell:")
    click.echo(f"# eval $({ctx.command_path})")


@env.command(handle_dry_run=True)
@pass_context
def zsh(ctx):
    """Show how to set the environment in the Z shell"""
    for k, v in sorted(config.env.items()):
        click.echo(f"export {k}={double_quote(v)}:${k}")
    for k, v in sorted(config.override_env.items()):
        click.echo(f"export {k}={double_quote(v)}")
    click.echo("# Run this command to configure your shell:")
    click.echo(f"# eval $({ctx.command_path})")


@env.command(handle_dry_run=True)
@pass_context
def fish(ctx):
    """Show how to set the environment in the Friendly interactive shell"""
    for k, v in sorted(config.env.items()):
        v = v.replace(os.pathsep, " ") if k == "PATH" else v
        click.echo(f"set -x {k} {double_quote(v)} ${k};")
    for k, v in sorted(config.override_env.items()):
        click.echo(f"set -x {k} {double_quote(v)};")
    click.echo("# Run this command to configure your shell:")
    click.echo(f"# eval ({ctx.command_path})")


@env.command(handle_dry_run=True)
@pass_context
def cmd(ctx):
    """Show how to set the environment in the Windows Command Prompt"""
    for k, v in sorted(config.env.items()):
        click.echo(f"SET {k}={v};%{k}%")
    for k, v in sorted(config.override_env.items()):
        click.echo(f"SET {k}={v}")
    click.echo("REM Run this command to configure your shell:")
    click.echo(f"REM FOR /f \"tokens=*\" %i IN ('{ctx.command_path}') DO %i")


@env.command(handle_dry_run=True)
@pass_context
def powershell(ctx):
    """Show how to set the environment in the Windows PowerShell"""
    for k, v in sorted(config.env.items()):
        click.echo(f'$Env:{k} = "{double_quote(v)};" + $Env:{k}')
    for k, v in sorted(config.override_env.items()):
        click.echo(f'$Env:{k} = "{double_quote(v)}"')
    click.echo("# Run this command to configure your shell:")
    click.echo(f"# & {ctx.command_path} | Invoke-Expression")


keyvaluestore_generic_commands(env, "environment")
