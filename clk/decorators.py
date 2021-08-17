#!/usr/bin/env python
# -*- coding: utf-8 -*-

import functools
import types

import click
from click.utils import make_default_short_help

from clk.completion import startswith
from clk.config import config, merge_settings
from clk.core import ExtensionType, settings_stores
from clk.flow import flowdepends  # NOQA: F401
from clk.lib import ParameterType, get_tabulate_formats
from clk.log import get_logger
from clk.overloads import argument, command, flag, flow_argument, flow_command, flow_option, group, option
from clk.profile import commandline_name_to_profile_name, profile_name_to_commandline_name

LOGGER = get_logger(__name__)


def param_config(name, *args, **kwargs):
    typ = kwargs.pop('typ', object)
    kls = kwargs.pop('kls', option)
    cls = kwargs.get('cls', {
        option: click.core.Option,
        argument: click.core.Argument,
        flag: click.core.Option,
    }[kls])

    class Conf(typ):
        pass

    init_callback = kwargs.get('callback')
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

    kwargs['expose_value'] = kwargs.get('expose_value', False)
    kwargs['callback'] = _subcommand_config_callback
    # find out the name of the param to setup the default value
    o = cls(args)
    default = kwargs.get('default')
    if callable(default):
        default = default()
    setattr(getattr(config, name), o.name, default)

    return kls(*args, **kwargs)


def use_settings(settings_name, settings_cls, override=True, default_profile='context'):
    def decorator(f):
        if settings_name not in settings_stores:
            settings_stores[settings_name] = settings_cls()
        settings_store = settings_stores[settings_name]
        settings_store.extension = None

        def compute_settings(with_explicit=True):
            settings_store.all_settings = {
                profile.name: profile.get_settings(settings_name)
                for profile in config.all_enabled_profiles
                if with_explicit or not profile.explicit
            }

        def setup_settings(ctx):
            if ctx is not None and hasattr(ctx, 'clk_profile'):
                profile_name = ctx.clk_profile
            else:
                profile_name = default_profile
            if ctx is not None and hasattr(ctx, 'clk_extension'):
                extension = ctx.clk_extension
            else:
                extension = None
            if profile_name == 'context':
                compute_settings(False)
                s1, s2 = merge_settings(config.iter_settings(
                    recurse=True,
                    only_this_extension=extension,
                ))
                profile = config.local_profile or config.global_profile
                if extension:
                    profile = profile.get_extension(extension)
                    for r in config.get_enabled_extensions_by_short_name(extension):
                        settings_store.all_settings[r.name] = r.get_settings(settings_name)
                else:
                    compute_settings(True)
                settings_store.readprofile = profile_name
            else:
                compute_settings(False)
                profile = config.get_profile(profile_name)
                profile = profile.get_extension(extension) if extension else profile
                settings_store.readprofile = profile_name
                settings_store.all_settings[profile_name] = profile.get_settings(settings_name)
                s1, s2 = merge_settings(
                    config.load_settings_from_profile(
                        profile,
                        recurse=True,
                        only_this_extension=extension,
                    ))
                for extension in config.filter_enabled_profiles(profile.extensions):
                    settings_store.all_settings[extension.name] = extension.get_settings(settings_name)

            readonly = s1 if override else s2
            readonly = readonly.get(settings_name, {})

            settings_store.writeprofile = profile.name
            settings_store.writeprofilename = profile.friendly_name
            settings_store.profile = profile
            settings_store.readonly = readonly
            settings_store.writable = profile.get_settings(settings_name)
            settings_store.write = profile.write_settings

        def extension_callback(ctx, attr, value):
            if value is not None:
                ctx.clk_extension = value
                setup_settings(ctx)
            return value

        def profile_callback(ctx, attr, value):
            if value:
                ctx.clk_profile = commandline_name_to_profile_name(value)
                setup_settings(ctx)
            return value

        for profile in [profile_name_to_commandline_name(profile.name) for profile in config.root_profiles]:
            f = flag('--{}'.format(profile),
                     'profile',
                     flag_value=profile,
                     help='Consider only the {} profile'.format(profile),
                     callback=profile_callback)(f)
        f = flag('--context', 'profile', flag_value='context', help='Guess the profile', callback=profile_callback)(f)
        f = option('--extension', type=ExtensionType(), callback=extension_callback, help='Use this extension')(f)

        setup_settings(None)

        @functools.wraps(f)
        def wrapped(*args, **kwargs):
            setattr(config, settings_name, settings_store)
            del kwargs['extension']
            del kwargs['profile']
            LOGGER.debug('Will use the settings at profile {}'.format(settings_store.readprofile))
            return f(*args, **kwargs)

        wrapped.inherited_params = ['extension', 'profile']
        return wrapped

    return decorator


pass_context = click.pass_context


def deprecated(version=None, message=None):
    def deprecated_decorator(command):
        deprecated_suffix = ' (deprecated)'
        help = command.help.splitlines()[0] if command.help else ''
        ref_short_help = make_default_short_help(help)
        if command.short_help == ref_short_help:
            command.short_help = make_default_short_help(command.help.splitlines()[0],
                                                         max_length=90 - len(deprecated_suffix)) + deprecated_suffix
        command.deprecated = {'version': version, 'message': message}
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
            option('--field',
                   'fields',
                   multiple=True,
                   type=fields_type,
                   default=default,
                   help='Only display the following fields in the output',
                   callback=callback)
        ]
        for opt in reversed(opts):
            func = opt(func)
        return func

    return decorator(func) if func else decorator


# don't export the modules, so we can safely import all the decorators
__all__ = [
    'get_tabulate_formats', 'startswith', 'settings_stores', 'option', 'argument', 'param_config', 'pass_context',
    'table_fields', 'ParameterType', 'group', 'table_format', 'deprecated', 'flag', 'merge_settings', 'command',
    'use_settings', 'flow_argument', 'flow_option', 'flow_command'
]

if __name__ == '__main__':
    # generate the __all__ content for this file
    symbols = [k for k, v in dict(globals()).items() if not isinstance(v, types.ModuleType)]
    symbols = [k for k in symbols if not k.startswith('_')]
    symbols = [k for k in symbols if k not in ['print_function', 'absolute_import']]
    print('__all__ = %s' % repr(symbols))
