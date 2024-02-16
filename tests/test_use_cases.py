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


def test_bash_command_built_in_lib():
    call_script('bash_command_built_in_lib.sh')


def test_3D_printing_flow():
    call_script('3D_printing_flow.sh')


def test_rolling_your_own():
    call_script('rolling_your_own.sh')


def test_dealing_with_secrets():
    call_script('dealing_with_secrets.sh')


def test_dynamic_parameters_and_exposed_class():
    call_script('dynamic_parameters_and_exposed_class.sh')


def test_using_a_project():
    call_script('using_a_project.sh')


def test_dynamic_parameters_advanced_use_cases():
    call_script('dynamic_parameters_advanced_use_cases.sh')


def test_bash_command_from_alias():
    call_script('bash_command_from_alias.sh')


def test_ethereum_local_environment_dev_tool():
    call_script('ethereum_local_environment_dev_tool.sh')


def test_scrapping_the_web():
    call_script('scrapping_the_web.sh')
