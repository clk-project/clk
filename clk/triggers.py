#!/usr/bin/env python

from clk.config import config
from clk.core import run
from clk.log import get_logger

LOGGER = get_logger(__name__)


def run_triggers(name, path, commands):
    if commands:
        LOGGER.debug(f"Running the {name} trigger for {path}")
    for command in commands:
        if isinstance(command, type(lambda x: x)):
            command()
        else:
            run(command)


class TriggerMixin:
    def invoke(self, *args, **kwargs):
        trigger = config.settings2.get("triggers", {}).get(self.path, {})
        pre = trigger.get("pre", [])
        post = trigger.get("post", [])
        onsuccess = trigger.get("onsuccess", [])
        onerror = trigger.get("onerror", [])
        run_triggers("pre", self.path, pre)
        try:
            res = super().invoke(*args, **kwargs)
        except:  # NOQA: E722
            run_triggers("onerror", self.path, onerror)
            run_triggers("post", self.path, post)
            raise
        run_triggers("onsuccess", self.path, onsuccess)
        run_triggers("post", self.path, post)
        return res
