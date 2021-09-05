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
