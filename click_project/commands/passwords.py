#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import json
import time
import os

import click

from click_project.decorators import group, option, flag, argument, table_format, table_fields
from click_project.lib import get_keyring
from click_project.lib import TablePrinter, get_authenticator_hints
from click_project.log import get_logger

LOGGER = get_logger(__name__)


@group()
def passwords():
    """Manipulate your passwords"""


class LazyChoice(click.Choice):
    def convert(self, value, param, ctx):
        return value


@passwords.command(ignore_unknown_options=True, change_directory_options=False)
@argument('machine', type=LazyChoice(get_authenticator_hints))
@argument('login')
@option('--password', prompt=True,
        hide_input=True,
        confirmation_prompt=True)
def set(machine, login, password):
    """Set the password"""
    try:
        get_keyring().set_password(
            "click_project",
            machine,
            json.dumps((login, password))
        )
    except:  # NOQA: E722
        LOGGER.error(
            "Could not save your password."
            " You might want to consider using `password netrc-set {}`".format(machine)
        )
        raise


@passwords.command(ignore_unknown_options=True, change_directory_options=False)
@argument('machine', type=LazyChoice(get_authenticator_hints))
def remove(machine):
    """Remove the password"""
    if click.confirm(
        "This will definitely remove the password for {}."
        " Are you sure?".format(machine)
    ):
        get_keyring().delete_password("click_project", machine)
    else:
        LOGGER.warning("Removing anyway!")
        time.sleep(1)
        LOGGER.info("...Just kidding! You password is safe :-)")


@passwords.command(ignore_unknown_options=True,
                       change_directory_options=False)
@table_format(default='key_value')
@table_fields(choices=['login', 'password'])
@argument('machine', type=LazyChoice(get_authenticator_hints))
@flag("--password/--no-password", help="Show the password")
def show(machine, fields, format, password):
    """Show the login/password"""
    res = get_keyring().get_password("click_project", machine)
    if res:
        login, password_ = json.loads(res)
        if not password:
            password_ = "*****"
        with TablePrinter(fields, format) as tp:
            tp.echo(login, password_)
    else:
        LOGGER.warn("No login/password set")


@passwords.command(ignore_unknown_options=True, change_directory_options=False)
@argument('machine', type=LazyChoice(get_authenticator_hints))
@argument('login')
@option('--password', prompt=True,
        hide_input=True,
        confirmation_prompt=True)
def netrc_set(machine, login, password):
    """Set the password in the netrc file"""
    if click.confirm(
            "The netrc file is an insecure way of storing passwords"
            " Do you confirm you want to store your password in it?"
    ):
        netrcfile = os.path.expanduser("~/.netrc")
        open(netrcfile, "ab").write(
            "\nmachine {} login {} password {}\n".format(machine, login, password).encode("utf-8")
        )
