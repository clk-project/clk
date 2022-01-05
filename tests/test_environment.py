#!/usr/bin/env python3
# -*- coding: utf-8 -*-


def test_can_use_evaluated_environments(lib):
    lib.cmd("env set a nexteval:'echo b'")
    assert lib.cmd('exec --shell echo ${a}') == 'b'


def test_can_manipulate_environments(lib):
    lib.cmd('env set a b')
    assert lib.cmd('exec --shell echo ${a}') == 'b'

    assert lib.cmd('env show --no-legend a') == 'a b'

    lib.cmd('env unset a')
    assert lib.cmd('exec --shell echo ${a}') == ''
