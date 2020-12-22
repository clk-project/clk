#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import


import traceback
from datetime import datetime

from pluginbase import PluginBase

from click_project.click_helpers import click_get_current_context_safe
from click_project.config import config
from click_project.log import get_logger

plugin_base = PluginBase(package='click_project.plugins')
plugins = None
plugins_cache = set()

LOGGER = get_logger(__name__)


def on_command_loading_error():
    LOGGER.develop(traceback.format_exc())

    if config.debug_on_command_load_error_callback:
        import sys
        import ipdb
        ipdb.post_mortem(sys.exc_info()[2])


afterloads = []
afterloads_cache = set()


def load_plugins():
    plugindirs = []
    if config.local_profile and config.local_profile.pluginsdir:
        plugindirs.append(config.local_profile.pluginsdir)
    if config.global_profile.pluginsdir:
        plugindirs.append(config.global_profile.pluginsdir)
    for recipe in config.all_enabled_recipes:
        plugindirs.append(recipe.pluginsdir)
    plugindirs.extend(config.plugindirs)
    global plugins
    if plugins is None:
        plugins = plugin_base.make_plugin_source(
            searchpath=plugindirs
        )
    disabled_plugins = {
        plugin.replace("/", "_")
        for plugin in
        config.get_settings('plugins').get("disabled_plugins", [])
    }
    plugins.persist = True
    for plugin in set(plugins.list_plugins()) - disabled_plugins - plugins_cache:
        try:
            before = datetime.now()
            mod = plugins.load_plugin(plugin)
            if hasattr(mod, 'load_plugin'):
                mod.load_plugin()
            after = datetime.now()
            spent_time = (after-before).total_seconds()
            LOGGER.develop("Plugin {} loaded in {} seconds".format(plugin, spent_time))
            threshold = 0.1
            if spent_time > threshold:
                LOGGER.debug(
                    "Plugin {} took more than {} seconds to load ({})."
                    " You might consider disabling the plugin when you don't use it."
                    " Or contribute to its dev to make it load faster.".format(
                        plugin,
                        threshold,
                        spent_time,
                    )
                )
        except Exception as e:
            ctx = click_get_current_context_safe()
            if ctx is None or not ctx.resilient_parsing:
                plugin_name = plugin.replace("_", "/")
                LOGGER.warning(
                    "Error when loading plugin {}"
                    " (if the plugin is no more useful,"
                    " consider uninstalling the plugins {}): {}".format(
                        plugin_name,
                        plugin_name,
                        e,
                    ))
                on_command_loading_error()
        plugins_cache.add(plugin)
    for hook in afterloads:
        if hook not in afterloads_cache:
            hook()
            afterloads_cache.add(hook)
