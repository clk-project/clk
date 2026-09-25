#!/usr/bin/env python

from collections import defaultdict

import click

from clk.colors import Colorer
from clk.config import config
from clk.decorators import argument, flag, group, option, table_fields, table_format
from clk.lib import TablePrinter, get_keyring
from clk.log import get_logger

LOGGER = get_logger(__name__)

SECRET_PREFIX = "secret:"


def backend_name(backend):
    return f"{type(backend).__module__}.{type(backend).__name__}"


@group()
def secret():
    """Manipulate your secrets"""


@secret.command(ignore_unknown_options=True, change_directory_options=False)
@argument("key", help="The key associated to the secret")
@option(
    "--secret",
    prompt=True,
    hide_input=True,
    confirmation_prompt=True,
    help="The secret to record. The secret will be interactively prompted if not provided. The interactive"
    " prompt is the prefered way to set the secret, because it ensures that the secret won't remain in"
    " the shell history",
)
def _set(key, secret):
    """Set the secret"""
    keyring = get_keyring()
    try:
        keyring.set_password("clk", key, secret)
    except NotImplementedError:
        raise click.ClickException(
            f"The keyring {backend_name(keyring)} cannot store secrets."
            " Store it with the tool of that password manager,"
            " or pick another keyring with --keyring."
        )
    except:  # NOQA: E722
        LOGGER.error("Could not save your secret.")
        raise


@secret.command(ignore_unknown_options=True, change_directory_options=False)
@argument("key", help="The secret to remove")
@flag("--force/--no-force", help="Don't ask before removing it")
def unset(key, force):
    """Remove the secret"""
    keyring = get_keyring()
    if not keyring.get_password("clk", key):
        raise click.ClickException("No secret set")
    if not force and not click.confirm(
        f"This will definitely remove the secret for {key}. Are you sure?"
    ):
        LOGGER.info(f"Kept the secret for {key}")
        return
    keyring.delete_password("clk", key)


@secret.command(change_directory_options=False)
@table_fields(choices=["key", "status", "commands"])
@table_format(default="simple")
@Colorer.color_options
def _list(fields, format, **kwargs):
    """List the secrets your parameters and aliases refer to, telling whether each is set

    The keyring cannot tell which secrets it holds, so only the ones mentioned
    as secret:key in the parameters and the aliases are listed, each command
    in the color of the profile that refers to it.
    """
    users = defaultdict(set)
    for profile in config.all_enabled_profiles:
        uses = [
            (cmd, param)
            for cmd, params in profile.get_settings("parameters").items()
            for param in params
        ] + [
            (alias, arg)
            for alias, definition in profile.get_settings("alias").items()
            for command in definition.get("commands", [])
            for arg in command
        ]
        for cmd, arg in uses:
            if str(arg).startswith(SECRET_PREFIX):
                users[arg[len(SECRET_PREFIX) :]].add((cmd, profile.name))
    if not users:
        LOGGER.info("No parameter or alias refers to a secret")
        return
    keyring = get_keyring()
    with Colorer(kwargs) as colorer, TablePrinter(fields, format) as tp:
        for key in sorted(users):
            is_set = keyring.get_password("clk", key)
            tp.echo(
                key,
                click.style(
                    "set" if is_set else "missing", fg="green" if is_set else "red"
                ),
                " ".join(
                    click.style(cmd, **colorer.get_style(profile))
                    for cmd, profile in sorted(users[key])
                ),
            )


@secret.command(ignore_unknown_options=True, change_directory_options=False)
@table_format(default="key_value")
@table_fields(choices=["key", "secret"])
@argument("key", help="The secret to show")
@flag("--secret/--no-secret", help="Show the secret")
def show(key, fields, format, secret):
    """Show the secret"""
    secret_ = get_keyring().get_password("clk", key)
    if not secret_:
        raise click.ClickException("No secret set")
    if not secret:
        secret_ = "*****"
    with TablePrinter(fields, format) as tp:
        tp.echo(key, secret_)
