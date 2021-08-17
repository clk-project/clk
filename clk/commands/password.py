#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import os
import time

import click

from clk.decorators import argument, flag, group, option, table_fields, table_format
from clk.lib import TablePrinter, get_authenticator_hints, get_keyring
from clk.log import get_logger

LOGGER = get_logger(__name__)


@group()
def password():
    """Manipulate your passwords"""


class LazyChoice(click.Choice):
    def convert(self, value, param, ctx):
        return value


@password.command(ignore_unknown_options=True, change_directory_options=False)
@argument('machine',
          type=LazyChoice(get_authenticator_hints),
          help='The machine on which the username and password may be used')
@argument('username', help='The login to record')
@option('--password',
        prompt=True,
        hide_input=True,
        confirmation_prompt=True,
        help='The password to record. The password will be interactively prompted if not provided. The interactive'
        " prompt is the prefered way to set the password, because it ensures that the password won't remain in"
        ' the shell history')
def set(machine, username, password):
    """Set the password"""
    try:
        get_keyring().set_password('clk', machine, json.dumps((username, password)))
    except:  # NOQA: E722
        LOGGER.error('Could not save your password.'
                     ' You might want to consider using `password netrc-set {}`'.format(machine))
        raise


@password.command(ignore_unknown_options=True, change_directory_options=False)
@argument('machine',
          type=LazyChoice(get_authenticator_hints),
          help='The machine for which the username and password will be removed')
def remove(machine):
    """Remove the password"""
    if click.confirm('This will definitely remove the password for {}.' ' Are you sure?'.format(machine)):
        get_keyring().delete_password('clk', machine)
    else:
        LOGGER.warning('Removing anyway!')
        time.sleep(1)
        LOGGER.info('...Just kidding! You password is safe :-)')


@password.command(ignore_unknown_options=True, change_directory_options=False)
@table_format(default='key_value')
@table_fields(choices=['login', 'password'])
@argument('machine', type=LazyChoice(get_authenticator_hints), help='The machine to show')
@flag('--password/--no-password', help='Show the password')
def show(machine, fields, format, password):
    """Show the login/password"""
    res = get_keyring().get_password('clk', machine)
    if res:
        login, password_ = json.loads(res)
        if not password:
            password_ = '*****'
        with TablePrinter(fields, format) as tp:
            tp.echo(login, password_)
    else:
        LOGGER.warn('No login/password set')


@password.command(ignore_unknown_options=True, change_directory_options=False)
@argument('machine',
          type=LazyChoice(get_authenticator_hints),
          help='The machine on which the username and password may be used')
@argument('username', help='The username to record')
@option('--password',
        prompt=True,
        hide_input=True,
        confirmation_prompt=True,
        help='The password to record. The password will be interactively prompted if not provided. The interactive'
        " prompt is the prefered way to set the password, because it ensures that the password won't remain in"
        ' the shell history')
def netrc_set(machine, username, password):
    """Set the password in the netrc file"""
    if click.confirm('The netrc file is an insecure way of storing passwords'
                     ' Do you confirm you want to store your password in it?'):
        netrcfile = os.path.expanduser('~/.netrc')
        open(netrcfile, 'ab').write('\nmachine {} login {} password {}\n'.format(machine, username,
                                                                                 password).encode('utf-8'))
