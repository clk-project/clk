#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os

import click

from click_project.config import config
from click_project.decorators import group, argument, use_settings, flag, option, pass_context, table_format, table_fields
from click_project.lib import rm, get_option_choices, makedirs, createfile, \
    ln, glob_first, ParameterType, TablePrinter
from click_project.completion import startswith
from click_project.lib import ensure_unicode, call
from click_project.log import get_logger

LOGGER = get_logger(__name__)


def pip(command, args):
    return call([command] + args)


def get_plugin_from_remote(name):
    raise NotImplementedError("There is no remote plugin mechanism yet")


def list_plugins_from_remote(name):
    raise NotImplementedError("There is no remote plugin mechanism yet")


def plugin_file_name(plugin):
    if plugin.startswith("file://"):
        return os.path.basename(plugin[len("file://"):-3])
    elif plugin.startswith('/') or plugin.startswith('./') or plugin.endswith('.py'):
        return plugin
    else:
        return plugin.replace("/", "_")


def is_local_plugin(plugin):
    return plugin.startswith("file://") or plugin.startswith('/') or plugin.startswith('./') or plugin.endswith('.py')


def plugin_name(file_name):
    first_underscore_index = file_name.index("_")
    return file_name[:first_underscore_index] + "/" + file_name[1+first_underscore_index:]


class PluginsConfig(object):
    pass


class PluginsType(ParameterType):
    def __init__(self, enabled=False, disabled=False):
        self.disabled = disabled
        self.enabled = enabled
        super(PluginsType, self).__init__()

    def getchoice(self, ctx):
        from click_project.plugins import plugins
        choice = {
            plugin_name(plugin)
            for plugin in plugins.list_plugins()
        }
        if self.disabled:
            choice &= set(config.get_settings('plugins').get("disabled_plugins", []))
        if self.enabled:
            choice -= set(config.get_settings('plugins').get("disabled_plugins", []))
        return choice

    def complete(self, ctx, incomplete):
        choice = self.getchoice(ctx)
        return [(plugin, load_short_help(plugin))
                for plugin in choice
                if startswith(plugin, incomplete)]

    def convert(self, value, param, ctx):
        choice = self.getchoice(ctx)
        if value not in choice:
            self.fail('invalid choice: %s. (choose from %s)' %
                      (value, ', '.join(choice)), param, ctx)
        return value


def load_help(plugin):
    from click_project.plugins import plugins
    try:
        mod = plugins.load_plugin(plugin)
        if hasattr(mod, '__doc__'):
            return ensure_unicode(mod.__doc__)
    except Exception:
        pass
    return None


def load_short_help(plugin):
    doc = load_help(plugin)
    if doc:
        doc = doc.splitlines()[0]
    return doc


@group(default_command='show')
@use_settings("plugins", PluginsConfig, default_profile='global')
def plugins():
    """Manipulate the command plugins

    Plugins are single python files slightly changing the behavior of your
    application. They can add subcommands for example. They generally use so
    called hooks to trigger very specific behavior in very specific
    circumstances.

    """
    from click_project.plugins import plugins
    config.plugins.plugins = plugins


@plugins.command(handle_dry_run=True)
@table_format(default='simple')
@table_fields(choices=['plugin', 'status', 'description', 'location'])
@option('--remote/--no-remote', help="Display available plugins on the remote plugin store")
@flag("--location/--no-location", help="Show the location of the plugin")
def show(fields, format, remote, location):
    """List the plugins to be loaded at runtime"""
    disabled_plugins = config.plugins.readonly.get('disabled_plugins', [])
    if not fields and not location:
        fields = list(get_option_choices('fields'))
        fields.remove('location')
    if remote:
        plugins = list_plugins_from_remote()
    else:
        plugins = [
            plugin_name(ensure_unicode(plugin))
            for plugin in config.plugins.plugins.list_plugins()
            ]

        def plugin_location(plugin):
            name = plugin.replace("/", "_")
            for path in config.plugins.plugins.searchpath:
                candidate = glob_first(os.path.join(path, name + ".py*"))
                if candidate is not None:
                    return candidate

        vals = [
            [
                plugin,
                'disabled' if plugin in disabled_plugins else 'enabled',
                load_short_help(plugin.replace('/', '_')),
                plugin_location(plugin),
            ]
            for plugin in sorted(plugins)
            ]
    with TablePrinter(fields, format) as tp:
        tp.echos(vals)


@plugins.command(handle_dry_run=True)
@argument('plugin', type=PluginsType())
def help(plugin):
    """Show the plugin help"""
    doc = load_help(plugin_file_name(plugin))
    if doc:
        click.echo_via_pager(doc)


@plugins.command(handle_dry_run=True)
@flag("--all", help="Enable all plugins")
@argument("plugin", type=PluginsType(disabled=True), nargs=-1)
@pass_context
def enable(ctx, plugin, all):
    """Enable the given plugin"""
    plugins = config.plugins.writable.get("disabled_plugins", [])
    if all:
        plugin = PluginsType(disabled=True).getchoice(ctx)
    for cmd in plugin:
        while cmd in plugins:
            del plugins[plugins.index(cmd)]
    config.plugins.write()


@plugins.command(handle_dry_run=True)
@flag("--all", help="Disable all plugins")
@argument("plugin", type=PluginsType(enabled=True), nargs=-1)
@pass_context
def disable(ctx, plugin, all):
    """Prevent the use of this plugin"""
    if all:
        plugin = PluginsType(enabled=True).getchoice(ctx)
    disabled_plugins = config.plugins.writable.get('disabled_plugins', [])
    disabled_plugins.extend(plugin)
    config.plugins.writable["disabled_plugins"] = disabled_plugins
    config.plugins.write()


def install_plugin(profile, force, plugin, login, password, develop, no_deps):
    """Install a plugin"""
    dest_dir = profile.pluginsdir

    def plugin_location(plugin):
        return os.path.join(
            dest_dir,
            "{}.py".format(plugin_file_name(plugin))
        )
    for _plugin in plugin:
        if not force and os.path.exists(plugin_location(_plugin)):
            raise click.UsageError(
                "{} already installed in profile {}."
                " If you really want to install it, use --force or"
                " run plugin uninstall --{} {}".format(
                    _plugin,
                    profile.name,
                    profile.name,
                    _plugin
                )
            )
    for _plugin in plugin:
        if is_local_plugin(_plugin):
            if _plugin.startswith("file://"):
                content = open(_plugin[len("file://"):], "rb").read().decode("utf-8")
                plugin_file = os.path.abspath(_plugin[len("file://"):])
            else:
                content = open(_plugin, "rb").read().decode("utf-8")
                plugin_file = os.path.abspath(_plugin)
            plugin_name = os.path.basename(plugin_file)[:-3]
            plugin_dir = os.path.dirname(plugin_file)
            if os.path.basename(plugin_dir) != "{}_plugins".format(config.app_name):
                raise click.UsageError("{} does not look like a plugin directory".format(plugin_dir))
            user_name = os.path.basename(os.path.dirname(plugin_dir))
            plugin_name = "{}/{}".format(user_name, plugin_name)
        else:
            content = get_plugin_from_remote(_plugin)
            plugin_name = _plugin

        def install_requirements():
            require_prefix = "# require: "
            requires = [
                line[len(require_prefix):]
                for line in content.splitlines()
                if line.startswith(require_prefix)
            ]
            for require in requires:
                LOGGER.status("Installing requirement {}".format(require))
                args = ['--upgrade', require]
                if force:
                    args.append("--force-reinstall")
                pip("install", args)
            plugin_require_prefix = "# plugin_require: "
            plugin_requires = [
                line[len(plugin_require_prefix):]
                for line in content.splitlines()
                if line.startswith(plugin_require_prefix)
            ]
            for plugin_require in plugin_requires:
                LOGGER.status("Installing plugin requirements {}".format(plugin_require))
                install_plugin(
                    profile=profile,
                    force=force,
                    login=login,
                    password=password,
                    plugin=[plugin_require],
                    develop=False,
                    no_deps=no_deps,
                )
        if not no_deps:
            install_requirements()
        LOGGER.status("Installing plugin {} in profile {}".format(plugin_name, profile.name))
        location = plugin_location(plugin_name)
        makedirs(os.path.dirname(location))

        if is_local_plugin(_plugin) and develop:
            LOGGER.debug("Installing {} in develop mode".format(plugin_name))
            if force and os.path.exists(location):
                rm(location)
            ln(plugin_file, location)
        else:
            createfile(location, content)


@plugins.command(handle_dry_run=True)
@flag("--force", '-f', help="Allow to overwrite a local plugin with the same name")
@option("--login", help="Login to use (instead of using the keyring)")
@flag("-e", "--develop", help=(
    "Install in develop mode."
    " It only makes sense with file install, and from a git clone."
    " It will be ignored in all other cases."
))
@flag("--no-deps", help="Don't install the dependencies")
@option("--password", help="Password to use (instead of using the keyring)")
@argument("plugin", nargs=-1)
def install(force, plugin, login, password, develop, no_deps):
    """Install a plugin"""
    profile = config.plugins.profile
    for plugin_ in plugin:
        if "/" not in plugin_:
            raise click.UsageError(
                "{} is not a valid plugin name to install."
                " Try plugins show --remote to"
                " see all the available plugins".format(plugin_)
            )
    return install_plugin(
        profile=profile,
        force=force,
        plugin=plugin,
        login=login,
        password=password,
        develop=develop,
        no_deps=no_deps,
    )


@plugins.command()
@argument("plugin", type=PluginsType(), nargs=-1)
@pass_context
def update(ctx, plugin):
    """Update the installed plugin"""
    ctx.invoke(install, force=True, plugin=plugin)


@plugins.command(handle_dry_run=True)
@argument("plugin", type=PluginsType(), nargs=-1)
def uninstall(plugin):
    """Uninstall a plugin"""
    profile = config.plugins.profile
    dest_dir = profile.pluginsdir

    def plugin_location(plugin):
        return os.path.join(
            dest_dir,
            "{}.py".format(plugin_file_name(plugin))
        )
    for _plugin in plugin:
        plugin_name = _plugin.replace('/', '_')
        from click_project.plugins import plugins
        plugin_mod = plugins.load_plugin(plugin_name)
        if hasattr(plugin_mod, "before_uninstall"):
            plugin_mod.before_uninstall()
        if not os.path.exists(plugin_location(_plugin)):
            LOGGER.warning(
                "Plugin {} does not exist in profile {}.".format(
                    _plugin,
                    profile.name,
                )
            )
            continue
        LOGGER.status(
            "Uninstalling plugin {} from profile {}".format(_plugin, profile.name)
        )
        pl = plugin_location(_plugin)
        rm(pl)
        if os.path.exists(pl + 'c'):
            rm(pl + 'c')
