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
@argument('machine', type=LazyChoice(get_authenticator_hints),
          help="The machine on which the username and password may be used")
@argument('username', help="The login to record")
@option('--password', prompt=True,  hide_input=True, confirmation_prompt=True,
        help="The password to record. The password will be interactively prompted if not provided. The interactive"
             " prompt is the prefered way to set the password, because it ensures that the password won't remain in"
             " the shell history")
def set(machine, username, password):
    """Set the password"""
    try:
        get_keyring().set_password(
            "click_project",
            machine,
            json.dumps((username, password))
        )
    except:  # NOQA: E722
        LOGGER.error(
            "Could not save your password."
            " You might want to consider using `password netrc-set {}`".format(machine)
        )
        raise


@passwords.command(ignore_unknown_options=True, change_directory_options=False)
@argument('machine', type=LazyChoice(get_authenticator_hints),
          help="The machine for which the username and password will be removed")
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


@passwords.command(ignore_unknown_options=True, change_directory_options=False)
@table_format(default='key_value')
@table_fields(choices=['login', 'password'])
@argument('machine', type=LazyChoice(get_authenticator_hints), help="The machine to show")
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
@argument('machine', type=LazyChoice(get_authenticator_hints),
          help="The machine on which the username and password may be used")
@argument('username', help="The username to record")
@option('--password', prompt=True, hide_input=True, confirmation_prompt=True,
        help="The password to record. The password will be interactively prompted if not provided. The interactive"
             " prompt is the prefered way to set the password, because it ensures that the password won't remain in"
             " the shell history")
def netrc_set(machine, username, password):
    """Set the password in the netrc file"""
    if click.confirm(
            "The netrc file is an insecure way of storing passwords"
            " Do you confirm you want to store your password in it?"
    ):
        netrcfile = os.path.expanduser("~/.netrc")
        open(netrcfile, "ab").write(
            "\nmachine {} login {} password {}\n".format(machine, username, password).encode("utf-8")
        )
