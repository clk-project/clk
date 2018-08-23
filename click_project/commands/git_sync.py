#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

from click_project.decorators import command, option, argument
from click_project.lib import git_sync as git_sync_


@command(handle_dry_run=True)
@option('--commit-ish', default='master', help="Remote reference to checkout")
@option('--force/--no-force', default=False, help="Force the download of the repository")
@option('--last-tag/--no-last-tag', default=False, help="Check out the last tag found in the provided reference")
@option('--reset/--no-reset', default=False, help="Reset the checked out files")
@argument('url', help="The git repository URL")
@argument('directory', required=False, help="The destination directory")
def git_sync(commit_ish, force, last_tag, reset, url, directory):
    """Retrieve and/or update a git repository"""
    git_sync_(url, directory, commit_ish, force=force, last_tag=last_tag, reset=reset)
