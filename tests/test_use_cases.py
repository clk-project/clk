#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from pathlib import Path
from subprocess import check_call


def call_script(script):
    use_cases = Path(__file__).parent / "use_cases"
    check_call(["bash", "-e", "-u", str(use_cases / script)], cwd=str(use_cases))


def test_bash_command():
    call_script("bash_command.sh")


def test_bash_command_use_option():
    call_script("bash_command_use_option.sh")
