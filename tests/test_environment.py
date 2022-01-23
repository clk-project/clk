#!/usr/bin/env python3
# -*- coding: utf-8 -*-

show_a_command = 'exec --shell echo ${a}'


def test_can_use_evaluated_environments(lib):
    lib.cmd("env set a nexteval:'echo b'")
    assert lib.cmd(show_a_command) == 'b'


def test_can_manipulate_environments(lib):
    lib.cmd('env set a b')
    assert lib.cmd(show_a_command) == 'b'

    assert lib.cmd('env show --no-legend a') == 'a b'

    lib.cmd('env unset a')
    assert lib.cmd(show_a_command) == ''
