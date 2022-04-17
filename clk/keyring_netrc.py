#!/usr/bin/env python
# -*- coding: utf-8 -*-

import click

from clk import netrc

try:
    import keyring.backend
except ModuleNotFoundError:
    raise click.UsageError('You have to install keyring `pip install keyring` for this to work')


class NetrcKeyring(netrc.Netrc, keyring.backend.KeyringBackend):
    pass
