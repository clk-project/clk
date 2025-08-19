#!/usr/bin/env python3

import re


def test_invoked_commands_still_work_even_though_they_are_no_customizable(
    lib, pythondir
):
    # given a command that is calling another using ctx.invoke
    (pythondir / "mygroup.py").write_text("""
import click
from clk.decorators import group, flag

@group()
def mygroup():
    pass

@mygroup.command()
@flag("--shout")
def invokedcommand(shout):
    message = "invokedcommand"
    if shout:
        message = message.upper()
    print(message)

@mygroup.command()
def invokingcommand():
    ctx = click.get_current_context()
    ctx.invoke(invokedcommand)
""")
    # and I customize the invokedcommand
    lib.cmd("parameter set mygroup.invokedcommand --shout")
    # when I call the customized command alone
    output = lib.cmd("mygroup invokedcommand")
    # then I can see the customization in action
    assert output == "INVOKEDCOMMAND"
    # when I call the invoking command
    output = lib.cmd("mygroup invokingcommand")
    # then I can see the output of the invokedcommand but without the
    # customization (because it was not called using a path, hence the notion of
    # path itself does not make sense in this context).
    assert output == "invokedcommand"


def test_broken_command_dont_make_clk_crash(lib, pythondir):
    # given a command that is poorly written
    (pythondir / "a.py").write_text("""
raise Exception("test")
""")
    # when I create an alias to that command
    output = lib.cmd("alias set b a", with_err=True)
    # then the output indicates the command could not be loaded
    assert (
        "error: Found the command a in the resolver customcommand but could not load it."
        in output
    )


def test_dynamic_default_value_callback_that_depends_on_another_param(pythondir, lib):
    # given a command to perform http request with a default url lazily computed
    # that depends on some other value
    (pythondir / "http.py").write_text("""
from clk.config import config
from clk.decorators import group, option
class Http:
    pass

def default():
    if config.http.api:
        return f"http://{config.http.api}"

@group()
@option('--api', expose_class=Http)
@option('--url', expose_class=Http, default=default)
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)
""")
    # when I use the command without providing the first value, then I get the
    # appropriate default value
    assert lib.cmd("http --api myapi get") == "Getting http://myapi"


def test_dynamic_option(pythondir, lib):
    # given a command to perform http request with a default url lazily computed
    # that depends on some other value
    (pythondir / "http.py").write_text("""
from clk.config import config
from clk.decorators import group, option

class Http:
    def dump(self):
        print(self.url)

def default():
    if config.http.api:
        return f"http://{config.http.api}"

@group()
@option('--api', expose_class=Http)
@option('--url', expose_class=Http, default=default)
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)

@http.command()
def dump():
    config.http.dump()
""")
    # when I use the command without providing the first value, then I get the
    # appropriate default value
    assert lib.cmd("http --api myapi get") == "Getting http://myapi"
    assert lib.cmd("http --api myapi dump") == "http://myapi"


def test_dynamic_default_value_callback(pythondir, lib):
    # given a command to perform http request with a default url lazily computed
    (pythondir / "http.py").write_text("""
from clk.config import config
from clk.decorators import group, option

class Http:
    pass

def default():
    return 'http://myapi'

@group()
@option('--url', expose_class=Http, default=default)
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)
""")
    # when I use the command without providing a value, then I get the default value
    assert lib.cmd("http get") == "Getting http://myapi"


def test_dynamic_default_value(pythondir, lib):
    # given a command to perform http request with a default url
    (pythondir / "http.py").write_text("""
from clk.config import config
from clk.decorators import group, option
class Http:
    pass
@group()
@option('--url', expose_class=Http, default='http://myapi')
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)
""")
    # when I use the command without providing a value, then I get the default value
    assert lib.cmd("http get") == "Getting http://myapi"


def test_command(lib):
    output = lib.cmd("command display")
    assert re.search(r"flowdep\s+Manipulate command flow dependencies\.", output)
