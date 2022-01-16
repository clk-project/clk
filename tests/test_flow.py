# -*- coding: utf-8 -*-


def test_dump_flowdeps(lib):
    lib.cmd('flowdep graph --alias-links --format dot')


def test_extend_flow(pythondir, lib):
    # given a group of commands that allows playing with 3D printing, with a
    # flow between them and a final command flow
    (pythondir / 'threed.py').write_text("""
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
    lib.cmd('alias set threed.check echo check')
    # and I put it in the flow of the print command using the extension placeholder
    lib.cmd("flowdep set threed.print '[self]' threed.check")
    # and I run the full flow
    # then I can see that the check command has actually replaced the flow of print
    assert lib.cmd('threed flow') == '''slicer
feed
calib
upload
check
print
done'''


def test_overwrite_flow(pythondir, lib):
    # given a group of commands that allows playing with 3D printing, with a
    # flow between them and a final command flow
    (pythondir / 'threed.py').write_text("""
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
    lib.cmd('alias set threed.check echo check')
    # and I put it in the flow of the print command
    lib.cmd('flowdep set threed.print threed.check')
    # and I run the full flow
    # then I can see that the check command has actually replaced the flow of print
    assert lib.cmd('threed flow') == '''check
print
done'''
