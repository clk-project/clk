#!/usr/bin/env python

import netrc
import os
from pathlib import Path

import click


class Netrc:
    def set_password(self, servicename, username, password):
        raise click.UsageError(
            "The netrc keyring only reads secrets."
            " Write this one in your netrc file to use it."
        )

    def get_password(self, servicename, username):
        try:
            netrc_path = Path(
                os.environ.get("CLK_NETRC_LOCATION", "~/.netrc")
            ).expanduser()
            authenticator = netrc.netrc(str(netrc_path)).authenticators(username)
            return authenticator[2]
        except:  # NOQA: E722
            return None

    def delete_password(self, servicename, username, password):
        raise click.UsageError(
            "The netrc keyring only reads secrets."
            " Remove this one from your netrc file to get rid of it."
        )
