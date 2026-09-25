#!/usr/bin/env python

import json
import os
import subprocess
from pathlib import Path

import click
import keyring.backend
from keyring.compat import properties

from clk import netrc


class NetrcKeyring(netrc.Netrc, keyring.backend.KeyringBackend):
    priority = 1


class GpgKeyring(keyring.backend.KeyringBackend):
    """Keeps each secret in its own gpg encrypted file, next to the settings.

    The secrets go in the secrets directory of the profile, or extension, whose
    settings pick this keyring, else of the local profile, or of the global one
    outside of a project. They are encrypted to the gpg ids listed one per line
    in the .gpg-id file of that directory.

    """

    priority = 1

    @property
    def directory(self):
        from clk.config import config
        from clk.lib import keyring_settings_profile

        profile = keyring_settings_profile()
        if profile is None or profile.get_settings("keyring")["backend"] != (
            f"{type(self).__module__}.{type(self).__name__}"
        ):
            profile = config.local_profile or config.global_profile
        return Path(profile.location) / "secrets"

    def _path(self, username):
        return self.directory / f"{username}.gpg"

    def set_password(self, servicename, username, password):
        ids = self.directory / ".gpg-id"
        if not ids.exists():
            raise click.UsageError(
                f"Write in {ids} the gpg ids to encrypt the secrets to, one per line."
                " gpg --list-secret-keys shows yours."
            )
        command = ["gpg", "--batch", "--yes", "--encrypt"]
        for id in ids.read_text().split():
            command += ["--recipient", id]
        command += ["--output", str(self._path(username))]
        subprocess.run(command, input=password.encode("utf-8"), check=True)

    def get_password(self, servicename, username):
        path = self._path(username)
        if not path.exists():
            return None
        return subprocess.run(
            ["gpg", "--batch", "--quiet", "--decrypt", str(path)],
            capture_output=True,
            check=True,
        ).stdout.decode("utf-8")

    def delete_password(self, servicename, username):
        self._path(username).unlink()


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
