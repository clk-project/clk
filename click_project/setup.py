#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

from click_project.flow import setup as setup_flow
from click_project.overloads import CoreCommandResolver, MainCommand, entry_point
from click_project.externalcommands import ExternalCommandResolver
from click_project.alias import AliasCommandResolver, AliasToGroupResolver
from click_project.hook import HookCommandResolver, setup as setup_hook
from click_project.overloads import Group, GroupCommandResolver
from click_project.completion import init as completion_init
from click_project.config import setup_config_class, Config, config
from click_project.log import get_logger, basic_config
from click_project import lib
from click_project.core import main  # NOQA: F401
from click_project.lib import get_authenticator_hints

LOGGER = get_logger(__name__)


def classic_setup(main_module=None, config_cls=Config,
                  extra_command_packages=[], distribution_profile_location=None,
                  include_core_commands=None, exclude_core_commands=None,
                  authenticator_hints={}):
    get_authenticator_hints.update(authenticator_hints)
    lib.main_module = main_module
    completion_init()
    setup_config_class(config_cls)
    setup_flow()
    setup_hook()
    for package in extra_command_packages:
        basic_config(package)
    CoreCommandResolver.commands_packages = extra_command_packages + ["click_project.commands"]
    CoreCommandResolver.include_core_commands = include_core_commands
    CoreCommandResolver.exclude_core_commands = exclude_core_commands
    Group.commandresolvers = [
        ExternalCommandResolver(),
        AliasCommandResolver(),
        HookCommandResolver(),
        GroupCommandResolver(),
        AliasToGroupResolver(),
    ]
    MainCommand.commandresolvers = [
        ExternalCommandResolver(),
        AliasCommandResolver(),
        HookCommandResolver(),
        CoreCommandResolver(),
    ]
    config.distribution_profile_location = distribution_profile_location

    def decorator(command):
        config_cls.main_command = command
        return command
    return decorator


def basic_entry_point(main_module, extra_command_packages=[],
                      distribution_profile_location=None,
                      include_core_commands=None, exclude_core_commands=None,
                      authenticator_hints={}):
    def decorator(f):
        path = f.__name__
        config_cls = type(
            "{}Config".format(path),
            (Config,),
            {
                "app_dir_name": path,
                "app_name": path,
            }
        )
        return classic_setup(main_module, config_cls=config_cls,
                             extra_command_packages=extra_command_packages,
                             distribution_profile_location=distribution_profile_location,
                             include_core_commands=include_core_commands,
                             exclude_core_commands=exclude_core_commands,
                             authenticator_hints=authenticator_hints)(entry_point()(f))
    return decorator
