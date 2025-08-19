#!/usr/bin/env python3

import re
from pathlib import Path
from subprocess import PIPE, CalledProcessError

import pytest

create_a_command = "command create bash a --no-open"
create_b_command = "command create bash b --no-open"


def test_capture_flow_option(lib):
    lib.create_bash_command(
        "a",
        """#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Some command to say something
--
F:--shouting:Shout the message
O:--message:str:Message to say:something
EOF
}

clk_help_handler "$@"

echo "$(clk_value message)"|{
if clk_true shouting
then
    tr '[:lower:]' '[:upper:]'
else
    cat
fi
}
""",
    )
    lib.create_bash_command(
        "b",
        """#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Some command to say say nothing
--
flowdeps: a
flowoptions: a:--shouting
EOF
}

clk_help_handler "$@"

""",
    )
    assert lib.cmd("b --shouting --flow") == "SOMETHING"


def test_capture_alias(lib):
    lib.cmd("alias set a echo a")
    # cannot replace and copy from an alias at the same time
    with pytest.raises(CalledProcessError) as e:
        lib.cmd("command create bash --replace-alias a --from-alias a", stderr=PIPE)
    assert re.match(".*can only set --from-alias or --replace-alias.*", e.value.stderr)
    lib.cmd("command create bash --from-alias a b --no-open")
    assert lib.cmd("b") == "a"
    assert lib.cmd("a") == "a"
    lib.cmd("command remove --force b")
    lib.cmd("command create bash --replace-alias a --no-open")
    assert lib.cmd("a") == "a"
    assert lib.cmd("alias show") == ""


def test_cannot_remove_existing_command(lib):
    lib.cmd(create_a_command)
    path = lib.cmd("command which a")
    Path(path).write_text(
        Path(path).read_text()
        + """
echo a"""
    )
    lib.cmd(create_b_command)
    path = lib.cmd("command which b")
    Path(path).write_text(
        Path(path).read_text()
        + """
echo b"""
    )
    lib.cmd("extension create ext")
    lib.cmd("command create --global --extension ext bash a --no-open")
    # creating onto another one
    with pytest.raises(CalledProcessError) as e:
        lib.cmd(create_a_command, stderr=PIPE)
    assert re.match(
        ".*I won't overwrite [/0-9a-zA-Z_-]+/bin/a unless explicitly.*", e.value.stderr
    )
    # copying onto another one
    with pytest.raises(CalledProcessError) as e:
        lib.cmd("command copy a global/ext a", stderr=PIPE)
    assert re.match(
        ".*I won't overwrite [/0-9a-zA-Z_-]+/extensions/ext/bin/a unless explicitly.*",
        e.value.stderr,
    )
    # moving onto another one
    with pytest.raises(CalledProcessError) as e:
        lib.cmd("command move a global/ext", stderr=PIPE)
    assert re.match(
        ".*I won't overwrite [/0-9a-zA-Z_-]+/extensions/ext/bin/a unless explicitly.*",
        e.value.stderr,
    )
    # renaming onto another one
    with pytest.raises(CalledProcessError) as e:
        lib.cmd("command rename b a", stderr=PIPE)
    assert re.match(
        ".*I won't overwrite [/0-9a-zA-Z_-]+/bin/a unless explicitly.*", e.value.stderr
    )


def test_complete_remove(lib):
    lib.cmd(create_a_command)
    candidates = lib.cmd("completion try command remove")
    assert "plain,a" == candidates


def test_simple_bash(lib):
    lib.cmd(create_a_command)
    path = lib.cmd("command which a")
    Path(path).write_text(
        Path(path).read_text()
        + """
echo foo"""
    )
    assert lib.cmd("a") == "foo"

    lib.cmd("command create bash b.sh --no-open")
    path = lib.cmd("command which b")
    Path(path).write_text(
        Path(path).read_text()
        + """
echo foo"""
    )
    assert lib.cmd("b") == "foo"


def test_default_help_message_triggers_a_warning(lib):
    lib.cmd(create_a_command)
    lib.cmd("command create python b --no-open")
    output = lib.cmd("a", with_err=True)
    assert output == "warning: The command 'a' has no documentation"
    output = lib.cmd("b", with_err=True)
    assert output == "warning: The command 'b' has no documentation"


def test_simple_python(lib):
    lib.cmd("command create python a --no-open")
    path = lib.cmd("command which a")
    Path(path).write_text(
        Path(path).read_text()
        + """
    print("foo")"""
    )
    assert lib.cmd("a") == "foo"
    lib.cmd("command create python b.py --no-open")
    path = lib.cmd("command which b")
    Path(path).write_text(
        Path(path).read_text()
        + """
    print("foo")"""
    )
    assert lib.cmd("b") == "foo"
    with pytest.raises(CalledProcessError) as e:
        lib.cmd("command create python a --no-open", stderr=PIPE)
    assert re.match(
        ".*I won.t overwrite.+unless explicitly asked so with --force*", e.value.stderr
    )


def test_group_python(lib):
    lib.cmd("command create python a-b --no-open --group")
    path = lib.cmd("command which a-b")
    Path(path).write_text(
        Path(path).read_text()
        + """
@a_b.command()
def b():
    print("b")
"""
    )
    assert lib.cmd("a-b b") == "b"
