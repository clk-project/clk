#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
from subprocess import PIPE, CalledProcessError

import pytest


def test_can_use_settings(lib):
    lib.use_config('use_settings')
    assert lib.cmd('some-group-with-settings show some-key') == "['some', 'default', 'value']"
    lib.cmd('some-group-with-settings set')
    assert lib.cmd('some-group-with-settings show some-key') == "['some', 'list']"
    assert lib.cmd('some-group-with-settings show some-other-key') == "{'some': 'dict'}"
    assert lib.cmd('some-group-with-settings show --use-settings some-key') == "['some', 'list']"
    assert lib.cmd(
        'some-group-with-settings show --use-settings2 some-key') == "['some', 'default', 'value', 'some', 'list']"
    assert lib.cmd('some-group-with-settings show another-key') == "['some', 'default', 'value']"
    lib.cmd('extension disable settings')
    with pytest.raises(CalledProcessError) as e:
        lib.cmd('some-group-with-settings show another-key', stderr=PIPE)
    assert re.match('.*invalid choice: another-key. .choose from some-key, some-other-key.*', e.value.stderr)


def test_install_extension(lib):
    lib.cmd('extension install hello')
    lib.cmd('hello')


def test_install_extension_with_github_syntax(lib):
    lib.cmd('extension install clk-project/hello')
    lib.cmd('hello')


def test_update_extension(lib):
    lib.cmd('extension install hello')
    lib.cmd('extension update hello')
    lib.cmd('hello --update-extension')


def test_copy_extension(lib):
    lib.cmd('extension create someext')
    lib.cmd('parameter --global --extension someext set echo test')
    assert lib.cmd('echo') == 'test'
    lib.cmd('extension disable someext')
    assert lib.cmd('echo') == ''
    lib.cmd('extension copy someext someext2')
    assert lib.cmd('echo') == 'test'
    lib.cmd('extension disable someext2')
    assert lib.cmd('echo') == ''


def test_move_extension(lib):
    lib.cmd('extension create someext')
    lib.cmd('parameter --global --extension someext set echo test')
    assert lib.cmd('echo') == 'test'
    lib.cmd('extension disable someext')
    assert lib.cmd('echo') == ''
    lib.cmd('extension rename someext someext2')
    assert lib.cmd('echo') == 'test'
    lib.cmd('extension disable someext2')
    assert lib.cmd('echo') == ''
    lib.cmd('extension enable someext')
    assert lib.cmd('echo') == ''
