#!/usr/bin/env python3

from subprocess import STDOUT


def test_action(lib):
    lib.cmd(
        'command create bash a --description "some command" --no-open --body "clk log --level action a"'
    )
    assert lib.cmd("a", stderr=STDOUT) == ""
    assert "action: a" in lib.cmd("--log-level action a", stderr=STDOUT).splitlines()
    lib.cmd(
        'command create bash a --description "some command" --force --no-open --body "clk log --level debug a"'
    )
    assert lib.cmd("a", stderr=STDOUT) == ""
    assert (
        "action: a" not in lib.cmd("--log-level action a", stderr=STDOUT).splitlines()
    )
    assert "debug: a" in lib.cmd("--log-level debug a", stderr=STDOUT).splitlines()
    lib.cmd(
        'command create bash a --description "some command" --force --no-open --body "clk log --level develop a"'
    )
    assert lib.cmd("a", stderr=STDOUT) == ""
    assert (
        "action: a" not in lib.cmd("--log-level action a", stderr=STDOUT).splitlines()
    )
    assert "debug: a" not in lib.cmd("--log-level debug a", stderr=STDOUT).splitlines()
    assert (
        "develop: a" not in lib.cmd("--log-level develop a", stderr=STDOUT).splitlines()
    )
