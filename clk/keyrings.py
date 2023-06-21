#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import os
from pathlib import Path

import click

from clk import netrc

try:
    import keyring.backend
except ModuleNotFoundError:
    raise click.UsageError('You have to install keyring `pip install keyring` for this to work')


class NetrcKeyring(netrc.Netrc, keyring.backend.KeyringBackend):
    priority = 1


class DummyFileKeyring(keyring.backend.KeyringBackend):
    """A dummy keyring used only for demonstration purpose.

    It stores data in a plain text unencrypted unsecure untrusted json file. The
    path of this file is read from the environment variable DUMMYFILEKEYRINGPATH.

    """

    priority = 1

    def __init__(self):
        path = os.environ['DUMMYFILEKEYRINGPATH']
        self.path = Path(path)

    @property
    def _content(self):
        if not self.path.exists():
            return {}
        else:
            return json.loads(self.path.read_text())

    def set_password(self, servicename, username, password):
        content = self._content
        service = content.get(servicename, {})
        service[username] = password
        content[servicename] = service
        self.path.write_text(json.dumps(content))

    def get_password(self, servicename, username):
        return self._content.get(servicename, {}).get(username)

    def delete_password(self, servicename, username):
        content = self._content
        service = content.get(servicename, {})
        try:
            del service[username]
        except KeyError:
            pass
        self.path.write_text(json.dumps(content))
