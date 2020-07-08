#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import functools
import types

import click
import six
from click.utils import make_default_short_help

from click_project.lib import get_tabulate_formats, ParameterType
from click_project.config import config,  merge_settings
from click_project.completion import startswith
from click_project.log import get_logger
from click_project.overloads import command, group, option, flag, argument, flow_command, flow_option, flow_argument
from click_project.flow import flowdepends  # NOQA: F401
from click_project.core import settings_stores

LOGGER = get_logger(__name__)


def param_config(name, *args, **kwargs):
    typ = kwargs.pop("typ", object)
    kls = kwargs.pop("kls", option)
    cls = kwargs.get("cls", {
        option: click.core.Option,
        argument: click.core.Argument
    }[kls])

    class Conf(typ):
        pass
    init_callback = kwargs.get("callback")
    if not hasattr(config, name):
        setattr(config, name, Conf())

    def _subcommand_config_callback(ctx, attr, value):
        if not hasattr(config, name):
            setattr(config, name, Conf())
        setattr(getattr(config, name), attr.name, value)
        if init_callback is not None:
            value = init_callback(ctx, attr, value)
            setattr(getattr(config, name), attr.name, value)
        return value

    kwargs["expose_value"] = kwargs.get("expose_value", False)
    kwargs["callback"] = _subcommand_config_callback
    # find out the name of the param to setup the default value
    o = cls(args)
    default = kwargs.get("default")
    if callable(default):
        default = default()
    setattr(getattr(config, name), o.name, default)

    return kls(*args, **kwargs)


def use_settings(settings_name, settings_cls, override=True, default_profile='context'):
    def decorator(f):
        if settings_name not in settings_stores:
            settings_stores[settings_name] = settings_cls()
        settings_store = settings_stores[settings_name]
        settings_store.recipe = None

        def compute_settings(with_explicit=True):
            settings_store.all_settings = {
                profile.name: profile.get_settings(settings_name)
                for profile in config.all_enabled_profiles
                if with_explicit or not profile.explicit
            }

        def setup_settings(ctx):
            if ctx is not None and hasattr(ctx, "click_project_profile"):
                profile_name = ctx.click_project_profile
            else:
                profile_name = default_profile
            if ctx is not None and hasattr(ctx, "click_project_recipe"):
                recipe = ctx.click_project_recipe
            else:
                recipe = "main"
            if recipe == "main":
                recipe = None
            if profile_name == "context":
                compute_settings(False)
                s1, s2 = merge_settings(config.iter_settings(
                    recurse=True,
                    only_this_recipe=recipe,
                ))
                profile = config.local_profile or config.global_profile
                if recipe:
                    profile = profile.get_recipe(recipe)
                    for r in config.get_enabled_recipes_by_short_name(recipe):
                        settings_store.all_settings[r.name] = r.get_settings(settings_name)
                else:
                    compute_settings(True)
                settings_store.readprofile = profile_name
            else:
                compute_settings(False)
                profile = config.get_profile(profile_name)
                profile = profile.get_recipe(recipe) if recipe else profile
                settings_store.readprofile = profile_name
                settings_store.all_settings[profile_name] = profile.get_settings(settings_name)
                s1, s2 = merge_settings(config.load_settings_from_profile(
                    profile,
                    recurse=True,
                    only_this_recipe=recipe,
                ))
                for recipe in config.filter_enabled_profiles(profile.recipes):
                    settings_store.all_settings[recipe.name] = recipe.get_settings(settings_name)

            readonly = s1 if override else s2
            readonly = readonly.get(settings_name, {})

            settings_store.writeprofile = profile.name
            settings_store.writeprofilename = profile.friendly_name
            settings_store.profile = profile
            settings_store.readonly = readonly
            settings_store.writable = profile.get_settings(settings_name)
            settings_store.write = profile.write_settings

        def recipe_callback(ctx, attr, value):
            if value is not None:
                ctx.click_project_recipe = value
                setup_settings(ctx)
            return value

        class RecipeType(ParameterType):
            @property
            def choices(self):
                return [
                    r.short_name
                    for r in config.all_recipes
                ] + ["main"]

            def complete(self, ctx, incomplete):
                return [
                    candidate
                    for candidate in self.choices
                    if startswith(candidate, incomplete)
                ]

        def profile_name_to_commandline_name(name):
            return name.replace("/", "-")

        def commandline_name_to_profile_name(name):
            return name.replace("-", "/")

        def profile_callback(ctx, attr, value):
            if value:
                ctx.click_project_profile = commandline_name_to_profile_name(value)
                setup_settings(ctx)
            return value


        for profile in [profile_name_to_commandline_name(profile.name) for profile in config.root_profiles]:
            f = flag('--{}'.format(profile), "profile", flag_value=profile, help="Consider only the {} profile".format(profile), callback=profile_callback)(f)
        f = flag('--context', "profile", flag_value="context", help="Guess the profile", callback=profile_callback)(f)
        f = option('--recipe', type=RecipeType(), callback=recipe_callback, help="Use this recipe")(f)

        setup_settings(None)

        @functools.wraps(f)
        def wrapped(*args, **kwargs):
            setattr(config, settings_name, settings_store)
            del kwargs["recipe"]
            del kwargs["profile"]
            LOGGER.debug("Will use the settings at profile {}".format(
                settings_store.readprofile
            ))
            return f(*args, **kwargs)
        wrapped.inherited_params = ["recipe", "profile"]
        return wrapped
    return decorator


pass_context = click.pass_context


def deprecated(version=None, message=None):
    def deprecated_decorator(command):
        deprecated_suffix = " (deprecated)"
        help = command.help.splitlines()[0] if command.help else ""
        ref_short_help = make_default_short_help(help)
        if command.short_help == ref_short_help:
            command.short_help = make_default_short_help(command.help.splitlines()[0], max_length=90 - len(deprecated_suffix)) + deprecated_suffix
        command.deprecated = {"version": version, "message": message}
        return command

    return deprecated_decorator


def table_format(func=None, default=None, config_name='config.table.format'):
    def decorator(func):
        # not sure why, but python can't access the default value with a closure in a statement of this kind
        #     default = default
        # so we have to use another name
        actual_default = config.get_settings('values').get(config_name, {}).get('value') or default or 'simple'
        opts = [
            option('--format', default=actual_default, help='Table format', type=get_tabulate_formats()),
        ]
        for opt in reversed(opts):
            func = opt(func)
        return func
    return decorator(func) if func else decorator


def table_fields(func=None, choices=(), default=None):
    def callback(ctx, attr, value):
        if not value:
            value = list(choices)
        return value

    def decorator(func):
        fields_type = click.Choice(choices) if choices else None
        opts = [
            option('--field', 'fields', multiple=True, type=fields_type, default=default,
                   help="Only display the following fields in the output", callback=callback)
        ]
        for opt in reversed(opts):
            func = opt(func)
        return func
    return decorator(func) if func else decorator


# don't export the modules, so we can safely import all the decorators
__all__ = ['get_tabulate_formats', 'startswith', 'settings_stores', 'option',
           'argument', 'param_config', 'pass_context', 'table_fields',
           'ParameterType', 'group', 'table_format', 'deprecated', 'flag',
           'merge_settings', 'command', 'use_settings', 'flow_argument',
           'flow_option', 'flow_command']


if __name__ == '__main__':
    # generate the __all__ content for this file
    symbols = [k for k, v in six.iteritems(dict(globals())) if not isinstance(v, types.ModuleType)]
    symbols = [k for k in symbols if not k.startswith('_')]
    symbols = [k for k in symbols if k not in ['print_function', 'absolute_import']]
    print('__all__ = %s' % repr(symbols))
