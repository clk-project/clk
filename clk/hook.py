#!/usr/bin/env python

from collections import defaultdict

from clk import plugin
from clk.commandresolver import CommandResolver
from clk.config import config
from clk.decorators import command as deco_command
from clk.decorators import group as deco_group
from clk.log import get_logger
from clk.overloads import get_command_handlers

LOGGER = get_logger(__name__)

command_loaders = defaultdict(dict)


def command(parent=None, *args, **kwargs):
    parent = parent or config.main_command.path

    def deco(command):
        return register_command(parent)(deco_command(*args, **kwargs)(command))

    return deco


def group(parent=None, *args, **kwargs):
    parent = parent or config.main_command.path

    def deco(group):
        return register_command(parent)(deco_group(*args, **kwargs)(group))

    return deco


def register_command(parent=None):
    parent = parent or config.main_command.path

    def decorator(command):
        assert not parent.startswith(config.main_command.path + "."), (
            f"The command {command.name} is trying to register as subcommand of '{parent}'."
            " Since this is not a valid command path,"
            f" it won't do anything, try using '{parent[len(config.main_command.path) + 1 :]}' instead :-)."
        )

        def load_command():
            return command

        command_loaders[parent][command.name] = load_command
        return command

    return decorator


class command_loader:
    def __init__(self, name, parent=None):
        self.name = name
        self.parent = parent or config.main_command.path

    def __call__(self, function):
        command_loaders[self.parent][self.name] = function


command_hooks = defaultdict(list)


class command_hook:
    def __init__(self, name):
        self.name = name

    def __call__(self, function):
        command_hooks[self.name].append(function)


class HookCommandResolver(CommandResolver):
    name = "hook"

    def _list_command_paths(self, parent):
        res = {
            parent_path + "." + cmd
            if parent_path is not config.main_command.path
            else cmd
            for (parent_path, cmds) in command_loaders.items()
            for cmd in cmds.keys()
        }
        return res

    def _get_command(self, path, parent):
        parts = path.split(".")
        parent_path = parent.path
        cmd = parts[-1]
        return command_loaders.get(parent_path, {}).get(cmd, None)()


def afterloadplugins(function):
    plugin.afterloads.append(function)


def get_command_handler(cmd):
    if cmd.path in command_hooks:
        for hook in command_hooks[cmd.path]:
            hook(cmd)
    return cmd


def setup():
    get_command_handlers[get_command_handler] = True
