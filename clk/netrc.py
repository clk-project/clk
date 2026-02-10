#!/usr/bin/env python

import netrc
import os
from pathlib import Path


class Netrc:
    def set_password(self, servicename, username, password):
        raise NotImplementedError

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
        raise NotImplementedError
