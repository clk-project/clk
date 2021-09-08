#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from lib import cmd, out, run


def test_parameter_precedence(project1):
    run('clk parameter set echo global')
    run(f'clk -P {project1} parameter set echo local')
    cmd('extension create ext')
    cmd('parameter set --global-ext echo ext')
    assert out(f'clk -P {project1} echo') == 'global ext local'


def test_simple_parameter():
    run('clk parameter set echo foo')
    assert out('clk echo') == 'foo'


def test_parameter_to_alias():
    run('clk alias set a echo')
    run('clk parameter set a foo')
    run('clk parameter set echo bar')
    assert out('clk a') == 'bar foo'


def test_parameter_before_the_ignore_section():
    """A command line stuff after the -- is not processed"""
    assert cmd('exec echo -- foo --launcher-command echo') == 'foo --launcher-command echo'
    """But a command line stuff before the -- is processed"""
    assert cmd('exec echo --launcher-command echo -- foo') == 'echo foo'
    """When setting a parameter without, I expect it to be processed"""
    cmd('parameter set exec --launcher-command echo')
    assert cmd('exec echo') == 'echo'
    """When setting a parameter without --, I expect it to be put in the
    processed even though the command contains -- in it"""
    assert cmd('exec echo -- foo') == 'echo foo'
