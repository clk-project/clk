#!/usr/bin/env python3


def test_can_use_a_flow_in_an_alias(lib):
    lib.use_config("flow")
    lib.cmd("alias set a conclusion --flow , echo ok")
    assert (
        lib.cmd("a")
        == """alice: something
bob: something else
done
ok"""
    )


def test_composite_alias(lib):
    lib.cmd("alias set a echo a , echo b")
    assert (
        lib.cmd("a")
        == """a
b"""
    )


def test_capture_flow_command(pythondir, lib):
    # given a group of commands that allows playing with 3D printing, with a
    # flow between them and a final command flow
    (pythondir / "threed.py").write_text("""
from clk.decorators import group


@group()
def threed():
    ""


@threed.command()
def slicer():
    print("slicer")


@threed.command(flowdepends=["threed.slicer"])
def feed():
    print("feed")


@threed.command(flowdepends=["threed.feed"])
def calib():
    print("calib")


@threed.command(flowdepends=["threed.calib"])
def upload():
    print("upload")


@threed.command(flowdepends=["threed.upload"])
def _print():
    print("print")



@threed.flow_command(flowdepends=["threed.print"])
def flow():
    print("done")



""")
    # I can run the complete flow
    assert (
        lib.cmd("threed flow")
        == """slicer
feed
calib
upload
print
done"""
    )
    # when a create an alias to that flow command
    lib.cmd("alias set flow threed flow")
    # then, calling this alias runs the flow
    assert (
        lib.cmd("flow")
        == """slicer
feed
calib
upload
print
done"""
    )


def test_alias_overrides_parameters(pythondir, lib):
    # given a group of commands that allows playing with http, using
    # exposed class for very reactive completion
    (pythondir / "http.py").write_text("""
from clk.config import config
from clk.decorators import group, option
class Http:
    pass

@group()
@option('--url', expose_class=Http)
def http():
    ""

@http.command()
def get():
    print("Getting " + config.http.url)
""")
    assert lib.cmd("http --url http://a.com get") == "Getting http://a.com"
    # and the url being saved in the parameters
    lib.cmd("parameter set http --url http://a.com")
    assert lib.cmd("http get") == "Getting http://a.com"
    # when I create an alias called h to shorten the call to http
    lib.cmd("alias set h http")
    # and save another url as parameter of the alias
    lib.cmd("parameter set h --url http://b.com")
    # then I can call h without parameters and still see it use http://b.com
    assert lib.cmd("h get") == "Getting http://b.com"
    # when I create an alias called h.g to shorten even more the call to http get
    lib.cmd("alias set h.g h get")
    # then I can call h g without parameters and still see it use http://b.com
    assert lib.cmd("h g") == "Getting http://b.com"
    # and I can call h --url http://c.com and it will be taken into account
    assert lib.cmd("h --url http://c.com g") == "Getting http://c.com"


def test_capture_partial_flow(pythondir, lib):
    # given a group of commands that allows playing with threed printing, with a
    # flow between them
    (pythondir / "threed.py").write_text("""
from clk.decorators import group


@group()
def threed():
    ""


@threed.command()
def slicer():
    print("slicer")


@threed.command(flowdepends=["threed.slicer"])
def feed():
    print("feed")


@threed.command(flowdepends=["threed.feed"])
def calib():
    print("calib")


@threed.command(flowdepends=["threed.calib"])
def upload():
    print("upload")


@threed.command(flowdepends=["threed.upload"])
def _print():
    print("print")
""")
    # I can run the complete flow
    assert (
        lib.cmd("threed print --flow")
        == """slicer
feed
calib
upload
print"""
    )
    # I can run a partial flow
    assert (
        lib.cmd("threed print --flow-from threed.upload")
        == """upload
print"""
    )
    # when I create an alias that capture the partial flow can run a partial flow
    lib.cmd("alias set threed.uprint threed print --flow-from threed.upload")
    # then, calling this alias run only the partial flow
    assert (
        lib.cmd("threed uprint")
        == """upload
print"""
    )


def test_alias_conserves_parameters_of_group_with_exposed_class(pythondir, lib):
    # given a group of commands that allows playing with http, using
    # expose_class for very reactive completion
    (pythondir / "http.py").write_text("""
from clk.config import config
from clk.decorators import group, option, flag
from clk.overloads import flag
class Http:
    pass

@group()
@option('--url', expose_class=Http)
@flag('--verify', expose_class=Http, expose_value=True)
def http(verify):
    ""

@http.command()
def get():
    print(f"Getting {config.http.url} with {config.http.verify}")
""")
    assert (
        lib.cmd("http --url http://a.com --verify get")
        == "Getting http://a.com with True"
    )
    # and the url being saved in the parameters
    lib.cmd("parameter set http --url http://a.com --verify")
    assert lib.cmd("http get") == "Getting http://a.com with True"
    # when I create an alias called h to shorten the call to http
    lib.cmd("alias set h http")
    # then I can call h without parameters and still see it use http://a.com
    assert lib.cmd("h get") == "Getting http://a.com with True"
    # when I create an alias called h.g to shorten even more the call to http get
    lib.cmd("alias set h.g h get")
    # then I can call h g without parameters and still see it use http://a.com
    assert lib.cmd("h g") == "Getting http://a.com with True"


def test_simple_alias_command(lib):
    lib.cmd("alias set test echo a , echo b , echo c")
    assert lib.cmd("test") == "a\nb\nc"


def test_alias_to_clk(project1, lib):
    lib.cmd(f"-P {project1} alias set a echo bou")
    lib.cmd(f"alias set b clk -P {project1} a")
    assert lib.cmd("b") == "bou"


def test_alias_conserves_parameters(lib):
    lib.cmd("alias set a echo")
    lib.cmd("parameter set echo foo")
    assert lib.cmd("a") == "foo"


def test_alias_conserves_parameters_of_group(pythondir, lib):
    # given a group of commands that allows playing with http
    (pythondir / "http.py").write_text("""
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
    assert lib.cmd("http --url http://a.com get") == "Getting http://a.com"
    # and the url being saved in the parameters
    lib.cmd("parameter set http --url http://a.com")
    assert lib.cmd("http get") == "Getting http://a.com"
    # when I create an alias called h to shorten the call to http
    lib.cmd("alias set h http")
    # then I can call h without parameters and still see it use http://a.com
    assert lib.cmd("h get") == "Getting http://a.com"
    # when I create an alias called h.g to shorten even more the call to http get
    lib.cmd("alias set h.g h get")
    # then I can call h g without parameters and still see it use http://a.com
    assert lib.cmd("h g") == "Getting http://a.com"


def test_alias_preserves_ignored_section_in_the_command_line(lib):
    # given an alias that contains an ignored section (meaning with -- in the
    # command line)
    lib.cmd("alias set foo exec -- -- foo")
    # when I run the alias with a command line stuff to be processed
    # then the stuff given to the alias is actually processed
    assert lib.cmd("foo --launcher-command echo") == "foo"
