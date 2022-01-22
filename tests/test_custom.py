#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
from pathlib import Path
from subprocess import PIPE, CalledProcessError

import pytest


def test_cannot_remove_existing_command(lib):
    lib.cmd('command create bash a --no-open')
    path = lib.out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
echo a""")
    lib.cmd('command create bash b --no-open')
    path = lib.out('clk command which b')
    Path(path).write_text(Path(path).read_text() + """
echo b""")
    lib.cmd('extension create ext')
    lib.cmd('command create --global-ext bash a --no-open')
    # creating onto another one
    with pytest.raises(CalledProcessError) as e:
        lib.cmd('command create bash a --no-open', stderr=PIPE)
    assert re.match(".*I won't overwrite [/0-9a-zA-Z_-]+/clk/bin/a unless explicitly.*", e.value.stderr)
    # copying onto another one
    with pytest.raises(CalledProcessError) as e:
        lib.cmd('command copy a global/ext a', stderr=PIPE)
    assert re.match(".*I won't overwrite [/0-9a-zA-Z_-]+/clk/extensions/ext/bin/a unless explicitly.*", e.value.stderr)
    # moving onto another one
    with pytest.raises(CalledProcessError) as e:
        lib.cmd('command move a global/ext', stderr=PIPE)
    assert re.match(".*I won't overwrite [/0-9a-zA-Z_-]+/clk/extensions/ext/bin/a unless explicitly.*", e.value.stderr)
    # renaming onto another one
    with pytest.raises(CalledProcessError) as e:
        lib.cmd('command rename b a', stderr=PIPE)
    assert re.match(".*I won't overwrite [/0-9a-zA-Z_-]+/clk/bin/a unless explicitly.*", e.value.stderr)


def test_complete_remove(lib):
    lib.cmd('command create bash a --no-open')
    candidates = lib.out('clk completion try command remove')
    assert 'a' == candidates


def test_simple_bash(lib):
    lib.cmd('command create bash a --no-open')
    path = lib.out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
echo foo""")
    assert lib.out('clk a') == 'foo'


def test_default_help_message_triggers_a_warning(lib):
    lib.cmd('command create bash a --no-open')
    lib.cmd('command create python b --no-open')
    output = lib.out('clk a', with_err=True)
    assert output == "warning: The command 'a' has no documentation"
    output = lib.out('clk b', with_err=True)
    assert output == "warning: The command 'b' has no documentation"


def test_simple_python(lib):
    lib.cmd('command create python a --no-open')
    path = lib.out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
    print("foo")""")
    assert lib.out('clk a') == 'foo'


def test_group_python(lib):
    lib.cmd('command create python a --no-open --group')
    path = lib.out('clk command which a')
    Path(path).write_text(Path(path).read_text() + """
@a.command()
def b():
    print("b")
""")
    assert lib.cmd('a b') == 'b'
