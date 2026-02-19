#!/usr/bin/env python3

import os
from pathlib import Path
from subprocess import check_call


def call_script(script):
    use_cases = Path(__file__).parent / "use_cases"
    # Pass coverage environment variables to the shell script
    env = os.environ.copy()
    check_call(
        ["bash", "-e", "-u", str(use_cases / script)], cwd=str(use_cases), env=env
    )


def test_bash_command(rootdir):
    call_script("bash_command.sh")


def test_bash_command_use_option(rootdir):
    call_script("bash_command_use_option.sh")


def test_bash_command_import(rootdir):
    call_script("bash_command_import.sh")


def test_bash_command_built_in_lib(rootdir):
    call_script("bash_command_built_in_lib.sh")


def test_3D_printing_flow(rootdir):
    call_script("3D_printing_flow.sh")


def test_rolling_your_own(rootdir):
    call_script("rolling_your_own.sh")


def test_dealing_with_secrets(rootdir):
    call_script("dealing_with_secrets.sh")


def test_dynamic_parameters_and_exposed_class(rootdir):
    call_script("dynamic_parameters_and_exposed_class.sh")


def test_using_a_project(rootdir):
    call_script("using_a_project.sh")


def test_dynamic_parameters_advanced_use_cases(rootdir):
    call_script("dynamic_parameters_advanced_use_cases.sh")


def test_bash_command_from_alias(rootdir):
    call_script("bash_command_from_alias.sh")


def test_ethereum_local_environment_dev_tool(rootdir):
    call_script("ethereum_local_environment_dev_tool.sh")


def test_scrapping_the_web(rootdir):
    call_script("scrapping_the_web.sh")


def test_controlling_a_server_using_an_environment_variable(rootdir):
    call_script("controlling_a_server_using_an_environment_variable.sh")


def test_choices(rootdir):
    call_script("choices.sh")


def test_ipfs_name_publish(rootdir):
    call_script("ipfs_name_publish.sh")


def test_send_sms(rootdir):
    call_script("send_sms.sh")


def test_creating_extensions(rootdir):
    call_script("creating_extensions.sh")


def test_podcast_automation(rootdir):
    call_script("podcast_automation.sh")


def test_hello_world(rootdir):
    call_script("hello_world.sh")


def test_python_command(rootdir):
    call_script("python_command.sh")


def test_multi_environment_deployment_tool(rootdir):
    call_script("multi_environment_deployment_tool.sh")


def test_wrapping_a_cloud_provider_cli(rootdir):
    call_script("wrapping_a_cloud_provider_cli.sh")


def test_using_a_plugin(rootdir):
    call_script("using_a_plugin.sh")


def test_setting_default_values(rootdir):
    call_script("setting_default_values.sh")


def test_environment_deployment(rootdir):
    call_script("environment_deployment.sh")


def test_fetching_and_displaying_json_data(rootdir):
    call_script("fetching_and_displaying_json_data.sh")


def test_self_documentation(rootdir):
    call_script("self_documentation.sh")
