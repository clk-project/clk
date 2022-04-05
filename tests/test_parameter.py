#!/usr/bin/env python3
# -*- coding: utf-8 -*-


def test_parameter_precedence(lib, project1):
    lib.cmd('parameter set echo global')
    lib.run(f'clk -P {project1} parameter set echo local')
    lib.cmd('extension create ext')
    lib.cmd('parameter set --global-ext echo ext')
    assert lib.out(f'clk -P {project1} echo') == 'global ext local'


def test_simple_parameter(lib):
    lib.cmd('parameter set echo foo')
    assert lib.cmd('echo') == 'foo'


def test_parameter_to_alias(lib):
    lib.cmd('alias set a echo')
    lib.cmd('parameter set a foo')
    lib.cmd('parameter set echo bar')
    assert lib.cmd('a') == 'bar foo'


def test_parameter_before_the_ignore_section(lib):
    """A command line stuff after the -- is not processed"""
    assert lib.cmd('exec echo -- foo --launcher-command echo') == 'foo --launcher-command echo'
    """But a command line stuff before the -- is processed"""
    assert lib.cmd('exec echo --launcher-command echo -- foo') == 'echo foo'
    """When setting a parameter without, I expect it to be processed"""
    lib.cmd('parameter set exec --launcher-command echo')
    assert lib.cmd('exec echo') == 'echo'
    """When setting a parameter without --, I expect it to be put in the
    processed even though the command contains -- in it"""
    assert lib.cmd('exec echo -- foo') == 'echo foo'
