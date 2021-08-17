#!/usr/bin/env python
# -*- coding: utf-8 -*-

import netrc

import click

try:
    import keyring.backend
except ModuleNotFoundError:
    raise click.UsageError('You have to install keyring `pip install keyring` for this to work')
import json
import os


class NetrcKeyring(keyring.backend.KeyringBackend):
    priority = 1

    def set_password(self, servicename, username, password):
        raise NotImplementedError

    def get_password(self, servicename, username):
        try:
            authenticator = netrc.netrc(os.path.expanduser('~/.netrc')).authenticators(username)
            return json.dumps((authenticator[0], authenticator[2]))
        except:  # NOQA: E722
            return None

    def delete_password(self, servicename, username, password):
        raise NotImplementedError
