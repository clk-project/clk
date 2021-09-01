#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from lib import out, run


def test_simple_parameter():
    run('clk parameter set echo foo')
    assert out('clk echo') == 'foo'


def test_parameter_to_alias():
    run('clk alias set a echo')
    run('clk parameter set a foo')
    run('clk parameter set echo bar')
    assert out('clk a') == 'bar foo'


def test_local_parameter_take_precedence(project1):
    run(f'clk -P {project1} parameter set echo foo')
    run('clk parameter set echo bar')
    assert out('clk echo') == 'bar'
    assert out(f'clk -P {project1} echo') == 'bar foo'
