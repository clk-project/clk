#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import netrc
import os


class Netrc():

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
