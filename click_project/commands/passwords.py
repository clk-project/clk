#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import json
import logging
import time
import os

import click

from click_project.decorators import group, option, flag, argument, table_format, table_fields
from click_project.lib import get_keyring
from click_project.lib import TablePrinter, get_authenticator_hints

LOGGER = logging.getLogger(__name__)


@group()
def passwords():
    """Manipulate your passwords"""


def create_password_command(machine):

    @passwords.group(
        default_command='show',
        name=machine,
        help="Manipulate the password for %s" % machine)
    def machine_group():
        pass

    @machine_group.command(ignore_unknown_options=True, change_directory_options=False)
    @argument('login')
    @option('--password', prompt=True,
            hide_input=True,
            confirmation_prompt=True)
    def set(login, password):
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
                " You might want to consider using `password {} netrc-set`".format(machine)
            )
            raise

    @machine_group.command(ignore_unknown_options=True, change_directory_options=False)
    def remove():
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

    @machine_group.command(ignore_unknown_options=True,
                           change_directory_options=False)
    @table_format(default='key_value')
    @table_fields(choices=['login', 'password'])
    @flag("--password/--no-password", help="Show the password")
    def show(fields, format, password):
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

    @machine_group.command(ignore_unknown_options=True, change_directory_options=False)
    @argument('login')
    @option('--password', prompt=True,
            hide_input=True,
            confirmation_prompt=True)
    def netrc_set(login, password):
        """Set the password in the netrc file"""
        if click.confirm(
                "The netrc file is an insecure way of storing passwords"
                " Do you confirm you want to store your password in it?"
        ):
            netrcfile = os.path.expanduser("~/.netrc")
            open(netrcfile, "ab").write(
                "\nmachine {} login {} password {}\n".format(machine, login, password).encode("utf-8")
            )


for password_name in get_authenticator_hints:
    create_password_command(password_name)
