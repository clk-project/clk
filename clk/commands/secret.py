#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time

import click

from clk.decorators import argument, flag, group, option, table_fields, table_format
from clk.lib import TablePrinter, get_keyring
from clk.log import get_logger

LOGGER = get_logger(__name__)


@group()
def secret():
    """Manipulate your secrets"""


@secret.command(ignore_unknown_options=True, change_directory_options=False)
@argument('key', help='The key associated to the secret')
@option('--secret',
        prompt=True,
        hide_input=True,
        confirmation_prompt=True,
        help='The secret to record. The secret will be interactively prompted if not provided. The interactive'
        " prompt is the prefered way to set the secret, because it ensures that the secret won't remain in"
        ' the shell history')
def _set(key, secret):
    """Set the secret"""
    try:
        get_keyring().set_password('clk', key, secret)
    except:  # NOQA: E722
        LOGGER.error('Could not save your secret.')
        raise


@secret.command(ignore_unknown_options=True, change_directory_options=False)
@argument('key', help='The secret to remove')
@flag('--force', help="Don't ask before removing it")
def unset(key, force):
    """Remove the secret"""
    if force or click.confirm('This will definitely remove the secret for {}.'
                              ' Are you sure?'.format(key)):
        get_keyring().delete_password('clk', key)
    else:
        LOGGER.warning('Removing anyway!')
        time.sleep(1)
        LOGGER.info('...Just kidding! You secret is safe :-)')


@secret.command(ignore_unknown_options=True, change_directory_options=False)
@table_format(default='key_value')
@table_fields(choices=['key', 'secret'])
@argument('key', help='The secret to show')
@flag('--secret/--no-secret', help='Show the secret')
def show(key, fields, format, secret):
    """Show the secret"""
    secret_ = get_keyring().get_password('clk', key)
    if secret_:
        if not secret:
            secret_ = '*****'
        with TablePrinter(fields, format) as tp:
            tp.echo(key, secret_)
    else:
        LOGGER.warn('No secret set')
