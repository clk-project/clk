#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re

from clk.config import config
from clk.decorators import argument, command, option
from clk.lib import call, cd


@command(ignore_unknown_options=True, handle_dry_run=True)
@option('--revision', default='HEAD', help='Revision to checkout')
@option('--username', default=None, help='The user name')
@option('--password', default=None, help='The user password')
@option('--auth-cache/--no-auth-cache', default=False, help='Cache authentication')
@option('--interactive/--no-interactive', default=False, help='Interactive prompting')
@option('--trust-server-cert/--no-trust-server-cert', default=True, help='Accept unknown certificates')
@argument('url', help='The repository URL')
@argument('directory', required=False, help='The destination directory')
@argument('args', nargs=-1, help='Extra arguments to pass to the svn program')
def svn_sync(revision, username, password, url, auth_cache, interactive, trust_server_cert, directory, args):
    """Retrieve and/or update a svn repository"""
    directory = directory or re.split('[:/]', url)[-1]
    args = list(args)
    if username is not None:
        args += ['--username', username]
    if password is not None:
        args += ['--password', password]
    if not auth_cache:
        args += ['--no-auth-cache']
    if not interactive:
        args += ['--non-interactive']
    if trust_server_cert:
        args += ['--trust-server-cert']
    if os.path.exists(directory):
        with cd(directory):
            call(['svn', 'up', '--revision', revision] + args, env=config.old_env)
    else:
        call(['svn', 'checkout', '--revision', revision] + args + [url, directory], env=config.old_env)
