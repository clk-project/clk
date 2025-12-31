import re
from subprocess import PIPE, STDOUT, CalledProcessError

import pytest


def test_flow_not_captured_if_consumed(lib):
    lib.use_config("flow")
    lib.cmd("whole-story") == """alice: something
bob: something else
alice: something
bob: something else
done
The End"""
    with pytest.raises(CalledProcessError) as e:
        lib.cmd("whole-story --flow", stderr=PIPE)
    assert re.match(".*No such option: --flow.*", e.value.stderr)


def test_flow_does_not_mess_up_with_options(lib):
    lib.use_config("podcast")
    # the shuffle option is only True in the alias setting it to true
    assert (
        lib.cmd("podcast play --wanted-duration 100 --flow")
        == """shuffle: False
shuffle: False
shuffle: True
picking 100 episodes
shuffle: False
downloading some episodes
Playing the episodes"""
    )


def test_flow_in_aliases(lib):
    lib.use_config("flow")
    assert (
        lib.cmd("conclusion --flow")
        == """alice: something
bob: something else
done"""
    )
    assert (
        lib.cmd("story")
        == """done
The End"""
    )
    assert (
        lib.cmd("story --flow")
        == """alice: something
bob: something else
done
The End"""
    )


def test_dump_flowdeps(lib, pythondir):
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
    # when I ask to get the flow of those
    content = lib.cmd("flowdep graph threed --format dot --output -")
    # then it shows the links and only the links of the commands
    reference = [
        '"threed.print" -> "threed.flow"',
        '"threed.upload" -> "threed.print"',
        '"threed.calib" -> "threed.upload"',
        '"threed.feed" -> "threed.calib"',
        '"threed.slicer" -> "threed.feed"',
    ]
    assert len([line for line in content.splitlines() if "->" in line]) == len(
        reference
    )
    for line in reference:
        assert line in content
    # given I have an alias to one of those commands
    lib.cmd("alias set reprap threed print")
    # when I ask for the flowdep graph with alias link enabled
    content = lib.cmd("flowdep graph --format dot --alias-links --output - reprap")
    # then I see that the alias has got the associated flow
    # and I don't see that the remaining part of the flow pointed toward the
    # alias
    reference = [
        '"threed.upload" -> "reprap"',
        '"threed.calib" -> "threed.upload"',
        '"threed.feed" -> "threed.calib"',
        '"threed.slicer" -> "threed.feed"',
        '"reprap" -> "threed.print" [label="threed print", style=dashed,',
    ]
    assert len([line for line in content.splitlines() if "->" in line]) == len(
        reference
    )
    for line in reference:
        assert line in content


def test_extend_flow(pythondir, lib):
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
    # when I create a new command to check that everything is ok before printing
    lib.cmd("alias set threed.check echo check")
    # and I put it in the flow of the print command using the extension placeholder
    lib.cmd("flowdep set threed.print '[self]' threed.check")
    # and I run the full flow
    # then I can see that the check command has actually replaced the flow of print
    assert (
        lib.cmd("threed flow")
        == """slicer
feed
calib
upload
check
print
done"""
    )


def test_verbose_flow(pythondir, lib):
    # given a group of commands that allows playing with 3D printing, with a
    # flow between them and a final command flow
    (pythondir / "threed.py").write_text("""
from clk.decorators import group


@group()
def threed():
    "3D printing stuff"


@threed.command()
def slicer():
    "Run the slicer"
    print("slicer")


@threed.command(flowdepends=["threed.slicer"])
def feed():
    "Feed the printer"
    print("feed")


@threed.command(flowdepends=["threed.feed"])
def calib():
    "Calibrate the printer"
    print("calib")


@threed.command(flowdepends=["threed.calib"])
def upload():
    "Send the gcode to the printer"
    print("upload")


@threed.command(flowdepends=["threed.upload"])
def _print():
    "Do the actual printing"
    print("print")


@threed.flow_command(flowdepends=["threed.print"])
def flow():
    "Run the whole stufff"
    print("done")
""")
    # when I run the flow in verbose mode
    # then I can see the succession of commands
    assert (
        lib.cmd(" --flow-verbose threed flow", stderr=STDOUT).splitlines()
        == """1/5 Running step 'threed slicer'
slicer
2/5 Running step 'threed feed'
feed
3/5 Running step 'threed calib'
calib
4/5 Running step 'threed upload'
upload
5/5 Running step 'threed print'
print
done
""".splitlines()
    )


def test_overwrite_flow(pythondir, lib):
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
    # when I create a new command to check that everything is ok before printing
    lib.cmd("alias set threed.check echo check")
    # and I put it in the flow of the print command
    lib.cmd("flowdep set threed.print threed.check")
    # and I run the full flow
    # then I can see that the check command has actually replaced the flow of print
    assert (
        lib.cmd("threed flow")
        == """check
print
done"""
    )


def test_reuse_flow_parameters(pythondir, lib):
    (pythondir / "somegroup.py").write_text("""
from clk.decorators import group, option
from clk.config import config

@group()
@option("--someoption")
def somegroup(someoption):
    ""
    config.someoption = someoption


@somegroup.command()
def somecommand():
    print(config.someoption)

@somegroup.command(flowdepends=["somegroup.somecommand"])
def someothercommand():
    print(config.someoption)

""")
    assert lib.cmd("somegroup somecommand") == "None"
    assert lib.cmd("somegroup --someoption something somecommand") == "something"
    assert lib.cmd("somegroup --someoption something someothercommand") == "something"
    assert (
        lib.cmd("somegroup --someoption something someothercommand --flow")
        == "something\nsomething"
    )
