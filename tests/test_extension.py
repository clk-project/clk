#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from shlex import split
from subprocess import check_call


def test_install_extension():
    check_call(split('clk extension install hello'))
    check_call(split('clk hello'))


def test_copy_extension(lib):
    lib.cmd('extension create someext')
    lib.cmd('parameter --global-someext set echo test')
    assert lib.cmd('echo') == 'test'
    lib.cmd('extension disable someext')
    assert lib.cmd('echo') == ''
    lib.cmd('extension copy someext someext2')
    assert lib.cmd('echo') == 'test'
    lib.cmd('extension disable someext2')
    assert lib.cmd('echo') == ''


def test_move_extension(lib):
    lib.cmd('extension create someext')
    lib.cmd('parameter --global-someext set echo test')
    assert lib.cmd('echo') == 'test'
    lib.cmd('extension disable someext')
    assert lib.cmd('echo') == ''
    lib.cmd('extension rename someext someext2')
    assert lib.cmd('echo') == 'test'
    lib.cmd('extension disable someext2')
    assert lib.cmd('echo') == ''
    lib.cmd('extension enable someext')
    assert lib.cmd('echo') == ''
