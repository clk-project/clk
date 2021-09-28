#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
from subprocess import check_output


def test_param_config_default_value_callback_that_depends_on_another_param(pythondir, lib):
    # given a command to perform http request with a default url lazily computed
    # that depends on some other value
    (pythondir / 'http.py').write_text("""
from clk.config import config
from clk.decorators import group, param_config

def default():
    if config.http.api:
        return f"http://{config.http.api}"

@group()
@param_config('http', '--api')
@param_config('http', '--url', default=default)
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)
""")
    # when I use the command without providing the first value, then I get the
    # appropriate default value
    assert lib.cmd('http --api myapi get') == 'Getting http://myapi'


def test_param_config_default_value_callback(pythondir, lib):
    # given a command to perform http request with a default url lazily computed
    (pythondir / 'http.py').write_text("""
from clk.config import config
from clk.decorators import group, param_config

def default():
    return 'http://myapi'

@group()
@param_config('http', '--url', default=default)
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)
""")
    # when I use the command without providing a value, then I get the default value
    assert lib.cmd('http get') == 'Getting http://myapi'


def test_param_config_default_value(pythondir, lib):
    # given a command to perform http request with a default url
    (pythondir / 'http.py').write_text("""
from clk.config import config
from clk.decorators import group, param_config
@group()
@param_config('http', '--url', default='http://myapi')
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)
""")
    # when I use the command without providing a value, then I get the default value
    assert lib.cmd('http get') == 'Getting http://myapi'


def test_command():
    output = check_output(['clk', 'command', 'display'], encoding='utf8')
    assert re.search(r'flowdep\s+Manipulate command flow dependencies\.', output)
