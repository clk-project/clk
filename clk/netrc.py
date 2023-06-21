#!/usr/bin/env python
# -*- coding: utf-8 -*-

import netrc
import os


class Netrc():

    def set_password(self, servicename, username, password):
        raise NotImplementedError

    def get_password(self, servicename, username):
        try:
            authenticator = netrc.netrc(os.path.expanduser(os.environ.get('CLK_NETRC_LOCATION',
                                                                          ('~/.netrc')))).authenticators(username)
            return authenticator[2]
        except:  # NOQA: E722
            return None

    def delete_password(self, servicename, username, password):
        raise NotImplementedError
