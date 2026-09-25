#!/usr/bin/env python

import json
import os
from pathlib import Path

import keyring.backend
from keyring.compat import properties

from clk import netrc


class NetrcKeyring(netrc.Netrc, keyring.backend.KeyringBackend):
    priority = 1


class DummyFileKeyring(keyring.backend.KeyringBackend):
    """A dummy keyring used only for demonstration purpose.

    It stores data in a plain text unencrypted unsecure untrusted json file. The
    path of this file is read from the environment variable DUMMYFILEKEYRINGPATH.

    """

    @properties.classproperty
    def priority(cls):
        if "DUMMYFILEKEYRINGPATH" not in os.environ:
            raise RuntimeError("DUMMYFILEKEYRINGPATH is not set")
        return 1

    @property
    def path(self):
        return Path(os.environ["DUMMYFILEKEYRINGPATH"])

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
        content.get(servicename, {}).pop(username, None)
        self.path.write_text(json.dumps(content))
