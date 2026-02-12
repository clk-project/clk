#!/usr/bin/env python3

import os


def test_replacing_parameters(lib):
    lib.cmd("parameter set echo foo")
    lib.cmd("parameter set echo bar")
    assert lib.cmd("echo") == "bar"


def test_appending_parameters(lib):
    lib.cmd("parameter set echo foo")
    lib.cmd("parameter append echo bar")
    assert lib.cmd("echo") == "foo bar"


def test_removing_parameters(lib):
    lib.cmd("parameter set echo foo bar")
    lib.cmd("parameter remove echo foo")
    assert lib.cmd("echo") == "bar"
    lib.cmd("parameter unset echo")
    assert lib.cmd("echo") == ""


def test_using_automatic_options(lib):
    lib.cmd("echo --set-parameter global foo")
    assert lib.cmd("echo") == "foo"
    lib.cmd("echo --append-parameter global bar")
    assert lib.cmd("echo") == "foo bar"
    lib.cmd("echo --remove-parameter global foo")
    assert lib.cmd("echo") == "bar"
    lib.cmd("echo --unset-parameter global")
    assert lib.cmd("echo") == ""


def test_editing_parameters(lib):
    lib.create_bash_command(
        "editor",
        """#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Dummy editor
--
A:content:str:The content to set
A:filename:str:The file whose content to set
EOF
}

clk_help_handler "$@"

cat<<EOF > "${CLK___FILENAME}"
${CLK___CONTENT}
EOF
""",
    )
    env = os.environ.copy()
    env["EDITOR"] = "clk editor foo"
    env["VISUAL"] = env["EDITOR"]
    lib.cmd("parameter edit echo", env=env)
    assert lib.cmd("echo") == "foo"
    env["EDITOR"] = "clk editor bar"
    env["VISUAL"] = env["EDITOR"]
    lib.cmd("parameter edit echo", env=env)
    assert lib.cmd("echo") == "bar"


def test_parameter_precedence(lib, project1):
    lib.cmd("parameter set echo global")
    lib.cmd(f"-P {project1} parameter set echo local")
    lib.cmd("extension create ext")
    lib.cmd("parameter set --global --extension ext echo ext")
    assert lib.cmd(f"-P {project1} echo") == "ext global local"


def test_simple_parameter(lib):
    lib.cmd("parameter set echo foo")
    assert lib.cmd("echo") == "foo"


def test_parameter_to_alias(lib):
    lib.cmd("alias set a echo")
    lib.cmd("parameter set a foo")
    lib.cmd("parameter set echo bar")
    assert lib.cmd("a") == "bar foo"
