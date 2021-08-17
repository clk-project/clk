#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk import lib
from clk.alias import AliasCommandResolver, AliasToGroupResolver
from clk.completion import init as completion_init
from clk.config import Config, config, setup_config_class
from clk.core import main  # NOQA: F401
from clk.customcommands import CustomCommandResolver
from clk.externalcommands import ExternalCommandResolver
from clk.flow import setup as setup_flow
from clk.hook import HookCommandResolver
from clk.hook import setup as setup_hook
from clk.lib import get_authenticator_hints
from clk.log import basic_config, get_logger
from clk.overloads import CoreCommandResolver, Group, GroupCommandResolver, MainCommand, entry_point

LOGGER = get_logger(__name__)


def classic_setup(main_module=None,
                  config_cls=Config,
                  extra_command_packages=[],
                  distribution_profile_location=None,
                  include_core_commands=None,
                  exclude_core_commands=None,
                  authenticator_hints={}):
    get_authenticator_hints.update(authenticator_hints)
    lib.main_module = main_module
    completion_init()
    setup_config_class(config_cls)
    setup_flow()
    setup_hook()
    for package in extra_command_packages:
        basic_config(package)
    CoreCommandResolver.commands_packages = extra_command_packages + ['clk.commands']
    CoreCommandResolver.include_core_commands = include_core_commands
    CoreCommandResolver.exclude_core_commands = exclude_core_commands
    Group.commandresolvers = [
        AliasCommandResolver(),
        ExternalCommandResolver(),
        HookCommandResolver(),
        GroupCommandResolver(),
        AliasToGroupResolver(),
    ]
    MainCommand.commandresolvers = [
        AliasCommandResolver(),
        ExternalCommandResolver(),
        HookCommandResolver(),
        CustomCommandResolver(),
        CoreCommandResolver(),
    ]
    config.distribution_profile_location = distribution_profile_location

    def decorator(command):
        config_cls.main_command = command
        return command

    return decorator


def basic_entry_point(main_module,
                      extra_command_packages=[],
                      distribution_profile_location=None,
                      include_core_commands=None,
                      exclude_core_commands=None,
                      authenticator_hints={}):
    def decorator(f):
        path = f.__name__
        config_cls = type('{}Config'.format(path), (Config, ), {
            'app_dir_name': path,
            'app_name': path,
        })
        return classic_setup(main_module,
                             config_cls=config_cls,
                             extra_command_packages=extra_command_packages,
                             distribution_profile_location=distribution_profile_location,
                             include_core_commands=include_core_commands,
                             exclude_core_commands=exclude_core_commands,
                             authenticator_hints=authenticator_hints)(entry_point()(f))

    return decorator
