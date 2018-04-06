#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

from functools import partial

from click_project.log import get_logger
from click_project.config import config
from click_project.overloads import get_command_handlers


class add_trigger(object):
    def __init__(self, path, position):
        self.path = path
        self.position = position

    def __call__(self, function):
        triggers_ = triggers.get(self.path, {})
        position = triggers_.get(self.position, [])
        position.append(function)
        triggers_[self.position] = position
        triggers[self.path] = triggers_


before = partial(add_trigger, position="pre")
after = partial(add_trigger, position="post")
onsuccess = partial(add_trigger, position="onsuccess")
onerror = partial(add_trigger, position="onerror")

LOGGER = get_logger(__name__)

triggers = {}


def run_triggers(name, path, commands):
    if commands:
        LOGGER.debug("Running the {} trigger for {}".format(name, path))
    for command in commands:
        if isinstance(command, type(lambda x: x)):
            command()
        else:
            config.main_command(command)


def get_trigger_wrapper(path, function):
    settings_triggers = config.settings2.get("triggers", {}).get(path, {})
    if path in triggers:
        for key in settings_triggers:
            if key in triggers[path]:
                triggers[path][key].extend(settings_triggers[key])
            else:
                triggers[path][key] = settings_triggers[key]
    else:
        triggers[path] = settings_triggers
    if path not in triggers:
        return function

    def trigger_wrapper(*args, **kwargs):
        trigger = triggers[path]
        pre = trigger.get("pre", [])
        post = trigger.get("post", [])
        onsuccess = trigger.get("onsuccess", [])
        onerror = trigger.get("onerror", [])
        run_triggers("pre", path, pre)
        try:
            res = function(*args, **kwargs)
        except:  # NOQA: E722
            run_triggers("onerror", path, onerror)
            run_triggers("post", path, post)
            raise
        run_triggers("onsuccess", path, onsuccess)
        run_triggers("post", path, post)
        return res
    return trigger_wrapper


def get_command_handler(cmd):
    cmd.callback = get_trigger_wrapper(cmd.path, cmd.callback)
    return cmd


def setup():
    get_command_handlers[get_command_handler] = True
