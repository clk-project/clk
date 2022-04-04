#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path
from shlex import split
from subprocess import check_call

import pytest

from clk import lib


def test_ln():
    Path('a').write_text('a')
    lib.ln('a', Path('b'))
    assert Path('b').read_text() == 'a'
    Path('a').write_text('b')
    assert Path('b').read_text() == 'b'
    with pytest.raises(FileExistsError):
        lib.ln(Path('a'), 'b')
    lib.dry_run = True
    lib.ln(Path('a'), 'b')
    lib.dry_run = None
    lib.rm('a')
    with pytest.raises(FileNotFoundError):
        Path('b').read_text()


def test_link():
    Path('a').write_text('a')
    lib.link('a', Path('b'))
    assert Path('b').read_text() == 'a'
    Path('a').write_text('b')
    assert Path('b').read_text() == 'b'
    with pytest.raises(FileExistsError):
        lib.link(Path('a'), 'b')
    lib.dry_run = True
    lib.link(Path('a'), 'b')
    lib.dry_run = None
    lib.rm('a')
    assert Path('b').read_text() == 'b'


def test_natural_time():
    assert lib.natural_time(5) == '5 seconds ago'


def test_which():
    assert lib.which('ls') in ('/usr/bin/ls', '/bin/ls')


def test_extract():
    lib.extract(
        'https://github.com/clk-project/clk/raw/main/tests/zipfile.zip',
        '.',
    )
    assert Path('readme').read_text() == 'hello from some zip file\n'


def test_download():
    zipfile = lib.download('https://github.com/clk-project/clk/raw/main/tests/zipfile.zip',
                           sha256='702bb46372dfad9632c8dc3d8b5bbe945f9efd2f5575723bf66a0128486b7fb5')
    assert zipfile.exists()


def test_safe_check_output():
    assert lib.safe_check_output('something_crazy') == ''


def test_git_sync():

    def git_add_and_commit(message):
        path = 'a'
        content = message
        (Path('a') / path).write_text(content)
        check_call(split('git -C a add ' + path))
        check_call(split(f'git -C a commit {path} -m {message}'))

    # when a repository is available, a fresh git sync will clone this repository
    check_call(split('git init a'))
    check_call(split('git -C a config user.email a@a.a1'))
    git_add_and_commit('1')
    lib.git_sync('a', 'b')
    assert Path('b/a').read_text() == '1'
    # when a git sync is already done, a new git sync will update the url and
    # sync the branch
    git_add_and_commit('2')
    lib.git_sync('../a', 'b')
    assert Path('b/a').read_text() == '2'
    git_add_and_commit('3')
    lib.git_sync('../a', 'b')
    assert Path('b/a').read_text() == '3'
