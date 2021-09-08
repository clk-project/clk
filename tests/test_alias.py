#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from shlex import split
from subprocess import check_call, check_output

from lib import cmd, out, run


def test_alias_overrides_parameters(pythondir):
    # given a group of commands that allows playing with http, using
    # param_config for very reactive completion
    (pythondir / 'http.py').write_text("""
from clk.config import config
from clk.decorators import group, param_config
@group()
@param_config('http', '--url')
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)
""")
    assert cmd('http --url http://a.com get') == 'Getting http://a.com'
    # and the url being saved in the parameters
    cmd('parameter set http --url http://a.com')
    assert cmd('http get') == 'Getting http://a.com'
    # when I create an alias called h to shorten the call to http
    cmd('alias set h http')
    # and save another url as parameter of the alias
    cmd('parameter set h --url http://b.com')
    # then I can call h without parameters and still see it use http://b.com
    assert cmd('h get') == 'Getting http://b.com'
    # when I create an alias called h.g to shorten even more the call to http get
    cmd('alias set h.g h get')
    # then I can call h g without parameters and still see it use http://b.com
    assert cmd('h g') == 'Getting http://b.com'


def test_alias_conserves_parameters_of_group_with_param_config(pythondir):
    # given a group of commands that allows playing with http, using
    # param_config for very reactive completion
    (pythondir / 'http.py').write_text("""
from clk.config import config
from clk.decorators import group, param_config
@group()
@param_config('http', '--url')
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)
""")
    assert cmd('http --url http://a.com get') == 'Getting http://a.com'
    # and the url being saved in the parameters
    cmd('parameter set http --url http://a.com')
    assert cmd('http get') == 'Getting http://a.com'
    # when I create an alias called h to shorten the call to http
    cmd('alias set h http')
    # then I can call h without parameters and still see it use http://a.com
    assert cmd('h get') == 'Getting http://a.com'
    # when I create an alias called h.g to shorten even more the call to http get
    cmd('alias set h.g h get')
    # then I can call h g without parameters and still see it use http://a.com
    assert cmd('h g') == 'Getting http://a.com'


def test_simple_alias_command():
    check_call(split('clk alias set test echo a , echo b , echo c'), encoding='utf8')
    assert check_output(split('clk test'), encoding='utf-8') == 'a\nb\nc\n'


def test_alias_to_clk(project1):
    run(f'clk -P {project1} alias set a echo bou')
    run(f'clk alias set b clk -P {project1} a')
    assert out('clk b') == 'bou'


def test_alias_conserves_parameters():
    cmd('alias set a echo')
    cmd('parameter set echo foo')
    assert cmd('a') == 'foo'


def test_alias_conserves_parameters_of_group(pythondir):
    # given a group of commands that allows playing with http
    (pythondir / 'http.py').write_text("""
from clk.config import config
from clk.decorators import group, option
@group()
@option('--url')
def http(url):
    config.url = url

@http.command()
def get():
    print("Getting " + config.url)
""")
    assert cmd('http --url http://a.com get') == 'Getting http://a.com'
    # and the url being saved in the parameters
    cmd('parameter set http --url http://a.com')
    assert cmd('http get') == 'Getting http://a.com'
    # when I create an alias called h to shorten the call to http
    cmd('alias set h http')
    # then I can call h without parameters and still see it use http://a.com
    assert cmd('h get') == 'Getting http://a.com'
    # when I create an alias called h.g to shorten even more the call to http get
    cmd('alias set h.g h get')
    # then I can call h g without parameters and still see it use http://a.com
    assert cmd('h g') == 'Getting http://a.com'


def test_alias_preserves_ignored_section_in_the_command_line():
    # given an alias that contains an ignored section (meaning with -- in the
    # command line)
    cmd('alias set foo exec -- -- foo')
    # when I run the alias with a command line stuff to be processed
    # then the stuff given to the alias is actually processed
    assert cmd('foo --launcher-command echo') == 'foo'
