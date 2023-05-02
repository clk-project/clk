#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path
from subprocess import check_call


def call_script(script):
    use_cases = Path(__file__).parent / 'use_cases'
    check_call(['bash', '-e', '-u', str(use_cases / script)], cwd=str(use_cases))


def test_bash_command():
    call_script('bash_command.sh')


def test_bash_command_use_option():
    call_script('bash_command_use_option.sh')


def test_bash_command_import():
    call_script('bash_command_import.sh')


def test_flow_options():
    call_script('flow_options.sh')


def test_rolling_your_own():
    call_script('rolling_your_own.sh')


def test_dealing_with_secrets():
    call_script('dealing_with_secrets.sh')


def test_dynamic_parameters_and_exposed_class():
    call_script('dynamic_parameters_and_exposed_class.sh')
