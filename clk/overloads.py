#!/usr/bin/env python
# -*- coding: utf-8 -*-

import functools
import importlib
import pkgutil
import re
import shlex
import traceback
from collections import OrderedDict, defaultdict
from copy import copy, deepcopy

import click
import click_didyoumean
from click.exceptions import MissingParameter
from click.utils import make_default_short_help

import clk.completion
from clk.click_helpers import click_get_current_context_safe
from clk.commandresolver import CommandResolver
from clk.completion import startswith
from clk.config import config
from clk.core import cache_disk, get_ctx, main_command_decoration, rebuild_path, run, settings_stores
from clk.lib import ParameterType, cd, check_output
from clk.log import get_logger
from clk.plugin import load_plugins
from clk.triggers import TriggerMixin

LOGGER = get_logger(__name__)


class CommandNotFound(Exception):
    pass


def list_commands(parent_path):
    parent = get_command(parent_path)
    ctx = get_ctx([])
    return parent.list_commands(ctx)


commands_cache = {}
get_command_handlers = OrderedDict()


def get_command(path, with_resolver=False):
    """This deprecated wrapper is there till we migrate all the code to get_command2"""
    cmd, resolver = get_command2(path)
    if with_resolver:
        return cmd, resolver
    else:
        return cmd


def get_command2(path):
    if path in commands_cache:
        return commands_cache[path]
    if path == config.main_command.path:
        return config.main_command, None

    pathsplit = path.split('.')
    if pathsplit[0] == config.main_command.path:
        del pathsplit[0]
    if len(pathsplit) > 1:
        parent_path = '.'.join(pathsplit[:-1])
        parent, _ = get_command2(parent_path)
        if isinstance(parent, config.main_command.__class__):
            raise CommandNotFound('The command {} was asked for. '
                                  'Because it starts with an alias to the root command,'
                                  ' I deliberately chose to ignore it.'.format(path))
    else:
        parent = config.main_command
    cmd_name = pathsplit[-1]
    if cmd_name.startswith('_'):
        cmd_name = cmd_name[1:]
        resolvers = [CoreCommandResolver()]
    else:
        resolvers = parent.commandresolvers
    cmd, resolver = get_command_with_resolvers(
        resolvers,
        parent.path,
        cmd_name,
    )
    if cmd is None:
        for subcmd in list_commands_with_resolvers(resolvers, parent.path, True):
            if subcmd.startswith(cmd_name + '.'):
                cmd = group(name=cmd_name, help='Group of commands')(lambda: None)
    if cmd is None:
        raise CommandNotFound(cmd_name)
    # adjust the path
    if cmd.path is None:
        cmd.path = path
    if cmd.path != path:
        cmd = copy(cmd)
        cmd.path = path
    commands_cache[path] = cmd, resolver
    for handler in get_command_handlers:
        cmd = handler(cmd)
    if hasattr(parent, 'inherited_params'):
        inherited_params = parent.inherited_params
        cmd_param_names = [param.name for param in cmd.params]
        new_param_names = [
            param.name
            for param in parent.params
            if param.name in inherited_params and param.name not in cmd_param_names
        ]
        cmd.params.extend([param for param in parent.params if param.name in new_param_names])

        def get_wrapper(f):
            def wrapper(*args, **kwargs):
                for name in new_param_names:
                    if name in kwargs:
                        del kwargs[name]
                return f(*args, **kwargs)

            return wrapper

        cmd.callback = get_wrapper(cmd.callback)
    return cmd, resolver


def get_command_safe(path):
    try:
        return get_command(path)
    except Exception:
        LOGGER.debug('Failed to get the command {}'.format(path))
        LOGGER.develop(traceback.format_exc())
        on_command_loading_error()
        return None


def iter_commands(from_cmds=None, from_paths=None):
    ctx = get_ctx([])
    _commands_cache = set()
    if not from_paths and not from_cmds:
        commands_to_add = [config.main_command]
    else:
        commands_to_add = []
    if from_cmds:
        commands_to_add.extend(from_cmds)
    if from_paths:
        commands_to_add.extend([get_command(path) for path in from_paths])
    while commands_to_add:
        command = commands_to_add.pop(0)
        yield command
        if (hasattr(command, 'list_commands') and command.path not in _commands_cache):
            new_commands = [command.get_command(ctx, name) for name in command.list_commands(ctx)]
            if command is not config.main_command:
                # prevent infinite recursion with alias having self as
                # subcommand
                new_commands = [
                    subcommand for subcommand in new_commands
                    if not isinstance(subcommand, config.main_command.__class__)
                ]
            commands_to_add.extend(new_commands)
        _commands_cache.add(command.path)


def on_command_loading_error():
    LOGGER.develop(traceback.format_exc())
    if config.debug_on_command_load_error_callback:
        import sys

        import ipdb
        ipdb.post_mortem(sys.exc_info()[2])


class CoreCommandResolver(CommandResolver):
    name = 'core command'
    commands_packages = ['clk.commands']
    include_core_commands = None
    exclude_core_commands = None

    def _list_command_paths(self, parent=None):
        res = []
        for i, commands_package in enumerate(self.commands_packages):
            # last iteration -> core package
            core_package = (i + 1 == len(self.commands_packages))
            try:
                cmddir = list(importlib.import_module(commands_package).__path__)[0]
                tmp_res = sorted(m.replace('_', '-').strip('-') for _, m, _ in pkgutil.iter_modules([cmddir]))
                if core_package:
                    tmp_res = [
                        r for r in tmp_res
                        if ((self.include_core_commands is None and self.exclude_core_commands is None) or (
                            self.include_core_commands is not None and r in self.include_core_commands) or (
                                self.exclude_core_commands is not None and r not in self.exclude_core_commands))
                    ]
                res += tmp_res
            except ImportError:
                if core_package:
                    raise
        return res

    def _get_command(self, path, parent=None):
        name = path.split('.')[-1]
        attrname = name.replace('-', '_')
        for i, package in enumerate(self.commands_packages):
            # last iteration -> core package
            core_package = (i + 1 == len(self.commands_packages))
            try:
                cmddir = list(importlib.import_module(package).__path__)[0]
                modules_names = sorted(m for _, m, _ in pkgutil.iter_modules([cmddir]))
            except ImportError:
                if core_package:
                    raise
            else:
                if attrname in modules_names:
                    try:
                        mod = importlib.import_module('{}.{}'.format(package, attrname))
                    except Exception as e:
                        LOGGER.warning('When loading command {}: {}'.format(name, e))
                        on_command_loading_error()
                        raise
                    if mod is not None:
                        if hasattr(mod, attrname + '_') and not hasattr(mod, attrname):
                            return getattr(mod, attrname + '_')
                        else:
                            return getattr(mod, attrname)
        raise CommandNotFound(path)


class ProfileChoice(click.Choice):
    name = 'profile'

    def __init__(self, extra=None, case_sensitive=True):
        self.case_sensitive = case_sensitive
        if extra is None:
            self.extra = []
        else:
            self.extra = extra

    @property
    def choices(self):
        profile_names = [p.name for p in config.all_profiles]
        profile_shortnames = [p.short_name for p in config.all_profiles]
        res = []
        res.extend(profile_names)
        uniq_shortnames = [name for name in profile_shortnames if profile_shortnames.count(name) == 1]
        res.extend(uniq_shortnames)
        res.extend(self.extra)
        return res


class ExtraParametersMixin(object):
    def __init__(self, *args, **kwargs):
        super(ExtraParametersMixin, self).__init__(*args, **kwargs)
        set_param_opt = AutomaticOption(['--set-parameter'],
                                        expose_value=False,
                                        callback=self.set_parameter_callback,
                                        group='parameters',
                                        help='Set the parameters for this command',
                                        type=ProfileChoice())
        append_param_opt = AutomaticOption(['--append-parameter'],
                                           expose_value=False,
                                           callback=self.append_parameter_callback,
                                           group='parameters',
                                           help='append the parameters for this command',
                                           type=ProfileChoice())
        remove_param_opt = AutomaticOption(['--remove-parameter'],
                                           expose_value=False,
                                           callback=self.remove_parameter_callback,
                                           group='parameters',
                                           help='remove the parameters for this command',
                                           type=ProfileChoice())
        unset_param_opt = AutomaticOption(['--unset-parameter'],
                                          expose_value=False,
                                          callback=self.unset_parameter_callback,
                                          group='parameters',
                                          help='Unset the parameters for this command',
                                          type=ProfileChoice())
        show_param_opt = AutomaticOption(['--show-parameter'],
                                         expose_value=False,
                                         callback=self.show_parameter_callback,
                                         group='parameters',
                                         help='Show the parameters for this command',
                                         type=ProfileChoice(extra=['context']))
        edit_param_opt = AutomaticOption(['--edit-parameter'],
                                         expose_value=False,
                                         callback=self.edit_parameter_callback,
                                         group='parameters',
                                         help='Edit the parameters for this command',
                                         type=ProfileChoice(extra=['context']))
        no_param_opt = AutomaticOption(['--no-parameter'],
                                       expose_value=False,
                                       is_flag=True,
                                       is_eager=True,
                                       group='parameters',
                                       help="Don't use the parameters settings for this commands")
        self.params.append(set_param_opt)
        self.params.append(append_param_opt)
        self.params.append(remove_param_opt)
        self.params.append(show_param_opt)
        self.params.append(unset_param_opt)
        self.params.append(edit_param_opt)
        self.params.append(no_param_opt)

    def get_extra_args(self, implicit_only=False):
        return config.get_parameters(self.path, implicit_only=implicit_only)

    def format_help_text(self, ctx, formatter):
        super(ExtraParametersMixin, self).format_help_text(ctx, formatter)
        extra_args = self.get_extra_args()
        if extra_args:
            formatter.write_paragraph()
            with formatter.indentation():
                parameters_help = ('The current parameters set for this command are: {}').format(' '.join(extra_args))
                formatter.write_text(parameters_help)

    def parameters_callback_split_value(self, value):
        profile = value
        extension = None
        if value != 'context':
            p = config.get_profile(value)
            if p.isextension:
                profile = p.parent_name
                extension = p.short_name
        res = ['--{}'.format(profile)]
        if extension is not None:
            res += ['--extension', extension]
        return res

    def unset_parameter_callback(self, ctx, param, value):
        if value and not ctx.resilient_parsing:
            raw_args = config.commandline_profile.get_settings('parameters')[self.path]
            index = raw_args.index('--unset-parameter')
            raw_args = raw_args[:index] + raw_args[index + 2:]
            config.commandline_profile.get_settings('parameters')[self.path] = raw_args
            config.merge_settings()
            run(['parameter'] + self.parameters_callback_split_value(value) + ['unset', self.path])
            exit(0)

    def set_parameter_callback(self, ctx, param, value):
        if value and not ctx.resilient_parsing:
            raw_args = config.commandline_profile.get_settings('parameters')[self.path]
            index = raw_args.index('--set-parameter')
            raw_args = raw_args[:index] + raw_args[index + 2:]
            config.commandline_profile.get_settings('parameters')[self.path] = raw_args
            config.merge_settings()
            run(['parameter'] + self.parameters_callback_split_value(value) + ['set', self.path] + ['--'] + raw_args)
            exit(0)

    def append_parameter_callback(self, ctx, param, value):
        if value and not ctx.resilient_parsing:
            raw_args = config.commandline_profile.get_settings('parameters')[self.path]
            index = raw_args.index('--append-parameter')
            raw_args = raw_args[:index] + raw_args[index + 2:]
            config.commandline_profile.get_settings('parameters')[self.path] = raw_args
            config.merge_settings()
            run(['parameter'] + self.parameters_callback_split_value(value) + ['append', self.path] + ['--'] + raw_args)
            exit(0)

    def remove_parameter_callback(self, ctx, param, value):
        if value and not ctx.resilient_parsing:
            raw_args = config.commandline_profile.get_settings('parameters')[self.path]
            index = raw_args.index('--remove-parameter')
            raw_args = raw_args[:index] + raw_args[index + 2:]
            config.commandline_profile.get_settings('parameters')[self.path] = raw_args
            config.merge_settings()
            run(['parameter'] + self.parameters_callback_split_value(value) + ['remove', self.path] + ['--'] + raw_args)
            exit(0)

    def show_parameter_callback(self, ctx, param, value):
        if value and not ctx.resilient_parsing:
            raw_args = config.commandline_profile.get_settings('parameters')[self.path]
            index = raw_args.index('--show-parameter')
            raw_args = raw_args[:index] + raw_args[index + 2:]
            config.commandline_profile.get_settings('parameters')[self.path] = raw_args
            config.merge_settings()
            run(['parameter'] + self.parameters_callback_split_value(value) + ['show', self.path])
            exit(0)

    def edit_parameter_callback(self, ctx, param, value):
        if value and not ctx.resilient_parsing:
            raw_args = config.commandline_profile.get_settings('parameters')[self.path]
            index = raw_args.index('--edit-parameter')
            raw_args = raw_args[:index] + raw_args[index + 2:]
            config.commandline_profile.get_settings('parameters')[self.path] = raw_args
            config.merge_settings()
            run(['parameter'] + self.parameters_callback_split_value(value) + ['edit', self.path])
            exit(0)


class HelpMixin(object):
    def __init__(self, *args, **kwargs):
        super(HelpMixin, self).__init__(*args, **kwargs)
        if self.help and 'short_help' not in kwargs.keys():
            # just keep the first line of the help in the short help
            self.short_help = make_default_short_help(self.help.splitlines()[0], max_length=90)

        def show_help(ctx, param, value):
            if value and not ctx.resilient_parsing:
                click.echo(self.get_help_all(ctx), color=ctx.color)
                ctx.exit()

        self.params.append(
            AutomaticOption(['--help-all'],
                            is_flag=True,
                            group=None,
                            show_default=False,
                            is_eager=True,
                            expose_value=False,
                            callback=show_help,
                            help='Show the full help message, automatic options included.'))

    def format_options(self, ctx, formatter, include_auto_opts=False):
        """Writes all the options into the formatter if they exist."""
        opts = defaultdict(list)
        args = []
        for param in self.get_params(ctx):
            if isinstance(param, Option):
                if include_auto_opts or not isinstance(param, AutomaticOption) or '--help-all' in param.opts:
                    rv = param.get_help_record(ctx)
                    if rv is not None:
                        opts[param.group].append(rv)
            elif isinstance(param, click.Option):
                rv = param.get_help_record(ctx)
                if rv is not None:
                    opts[None].append(rv)
            elif isinstance(param, click.Argument):
                rv = param.get_help_record(ctx)
                if rv is not None:
                    args.append(rv)

        if args:
            with formatter.section('Arguments'):
                formatter.write_dl(args)
        if opts[None]:
            with formatter.section('Options'):
                formatter.write_dl(opts[None])
        for group in sorted(group for group in opts.keys() if group is not None):
            with formatter.section('%s options' % group.capitalize()):
                formatter.write_dl(opts[group])

    def get_help_all(self, ctx):
        """Formats the help into a string and returns it.  This creates a
        formatter and will call into the following formatting methods:
        """
        formatter = ctx.make_formatter()
        self.format_help_all(ctx, formatter)
        return formatter.getvalue().rstrip('\n')

    def format_help_all(self, ctx, formatter):
        """Writes the help into the formatter if it exists.

        This calls into the following methods:

        -   :meth:`format_usage`
        -   :meth:`format_help_text`
        -   :meth:`format_options`
        -   :meth:`format_epilog`
        """
        self.format_usage(ctx, formatter)
        self.format_help_text(ctx, formatter)
        self.format_options(ctx, formatter, True)
        self.format_epilog(ctx, formatter)


class RememberParametersMixin(object):
    """Mixin to use a parser that remembers the given parameters.

    Use split_args_remaining to find out what part of the command line is really
    to be saved. The use set_commandline_settings to save whatever needs to be
    saved.

    It is needed to append the parameters instead of setting them to allow
    complicated alias and flow scenarios. For instance, if you have group of
    commands called something and you want to create an alias
    something.complicatedstuff to `clk something a , clk something b`, you'd
    want clk something --someoption complicatedstuff to pass --someoption to the
    something call of each part of the alias. This is possible because the calls
    to something in the alias don't erase the call of something in the
    alias. But this logic breaks simple commands when they are parsed several
    time (like completion does) and they have arguments. Indeed, in such cases,
    every call to parse_args would add the argument, resulting in a messy
    commandline_profile with several times the same arguments.

    In brief, use append_commandline_settings for group stuff and
    set_commandline_settings for commands.

    It would be theoretically better to rescan the args and the command line
    args, to remove the argument part of the args before appending, but
    pragmatically, doing so sounds to do the job well.

    """
    def split_args_remaining(self, ctx, args):
        """Reconstruct parameters equivalent to those initially given to the command line"""
        parser = self.make_parser(ctx)
        opts, remaining, param_order = parser.parse_args(args=copy(args))
        threshold = len(remaining)
        if threshold == 0:
            return args, []
        else:
            return args[:-threshold], remaining

    def set_commandline_settings(self, ctx, args):
        config.commandline_profile.get_settings('parameters')[self.path] = args
        config.merge_settings()

    def append_commandline_settings(self, ctx, args):
        config.commandline_profile.get_settings('parameters')[self.path] += args
        config.merge_settings()


class MissingDocumentationMixin(object):
    """A mixin to use to display a waring when running a command that miss some documentation, either on the command
    itself or on its parameters
    """
    def invoke(self, ctx):
        if not ctx.resilient_parsing:
            if not self.help:
                LOGGER.warn("The command '%s' has no documentation" % self.path)
            for param in self.params:
                if not param.help:
                    LOGGER.warn("The parameter '%s' in the command '%s' has no documentation" % (param.name, self.path))
        super(MissingDocumentationMixin, self).invoke(ctx)


class DeprecatedMixin(object):
    def init_deprecated(self):
        self.deprecated = None

    def invoke_handle_deprecated(self, ctx, *args, **kwargs):
        if self.deprecated:
            msg = "'%s' is deprecated" % self.path.replace('.', ' ')
            version = self.deprecated.get('version')
            message = self.deprecated.get('message')
            if version:
                msg += ' since version %s' % version
            if message:
                msg += '. ' + message
            LOGGER.deprecated(msg)


class Command(MissingDocumentationMixin, DeprecatedMixin, TriggerMixin, HelpMixin, ExtraParametersMixin,
              RememberParametersMixin, click.Command):
    def __init__(self, *args, **kwargs):
        super(Command, self).__init__(*args, **kwargs)
        super(Command, self).init_deprecated()
        self.path = None

    def parse_args(self, ctx, args):
        # cannot call append_commandline_settings because the parameters can be
        # arguments. In case the parsing is called several times, the arguments
        # would be appended each time.
        self.set_commandline_settings(ctx, args)
        args = self.get_extra_args(implicit_only=('--no-parameter' in args))

        ctx.complete_arguments = list(args)
        LOGGER.develop("In the {} '{}', parsing the args {}".format(
            self.__class__.__name__,
            ctx.command.path,
            args,
        ))
        click.Command.parse_args(self, ctx, args)

    def invoke(self, ctx, *args, **kwargs):
        super(Command, self).invoke_handle_deprecated(ctx, *args, **kwargs)
        if config.dry_run and not self.handle_dry_run:
            LOGGER.warning("'{}' does not support dry-run mode: I won't call it".format(ctx.command_path))
            raise SystemExit()
        return super(Command, self).invoke(ctx, *args, **kwargs)

    def flow_option(self, *args, **kwargs):
        return flow_option(*args, target_command=self, **kwargs)

    def flow_options(self, *args, **kwargs):
        return flow_options(*args, target_command=self, **kwargs)

    def flow_argument(self, *args, **kwargs):
        return flow_argument(*args, target_command=self, **kwargs)


def _list_matching_commands_from_resolver(resolver, parent_path, include_subcommands=False):
    parent = get_command(parent_path)
    if isinstance(parent, config.main_command.__class__):
        res = {command for command in resolver._list_command_paths(parent) if include_subcommands or '.' not in command}
    else:
        res = {
            command[len(parent_path) + 1:]
            for command in resolver._list_command_paths(parent)
            if command.startswith(parent_path +
                                  '.') and (include_subcommands or '.' not in command[len(parent_path) + 1:])
        }
    return res


def list_commands_with_resolvers(resolvers, parent_path, include_subcommands=False):
    load_plugins()
    res = set()
    for resolver in resolvers:
        res |= set(_list_matching_commands_from_resolver(resolver, parent_path,
                                                         include_subcommands=include_subcommands))
    return sorted(res)


def get_command_with_resolvers(resolvers, parent_path, name):
    load_plugins()
    cmd = None
    if parent_path == config.main_command.path:
        parent = config.main_command
        cmd_path = name
    else:
        parent = get_command(parent_path)
        cmd_path = parent_path + '.' + name
    for resolver in resolvers:
        if name in _list_matching_commands_from_resolver(resolver, parent_path):
            try:
                cmd = resolver._get_command(cmd_path, parent)
            except BaseException:
                LOGGER.error(f'Found the command {cmd_path} in the resolver {resolver.name}' ' but could not load it.')
                raise
            break
    return cmd, resolver


class GroupCommandResolver(CommandResolver):
    name = 'group'

    def _list_command_paths(self, parent):
        ctx = click_get_current_context_safe()
        res = {parent.path + '.' + cmd for cmd in super(Group, parent).list_commands(ctx)}
        return res

    def _get_command(self, path, parent):
        path = path.split('.')
        cmd_name = path[-1]
        ctx = click_get_current_context_safe()
        return super(Group, parent).get_command(ctx, cmd_name)


allow_dotted_commands = False


class Group(click_didyoumean.DYMMixin, MissingDocumentationMixin, DeprecatedMixin, TriggerMixin, HelpMixin,
            ExtraParametersMixin, RememberParametersMixin, click.Group):
    commandresolvers = [
        GroupCommandResolver(),
    ]

    def __init__(self, *args, **kwargs):
        # default command management
        default_command = kwargs.pop('default_command', None)
        self.default_cmd_name = None
        if default_command is not None:
            self.set_default_command(default_command)

        super(Group, self).__init__(*args, **kwargs)
        super(Group, self).init_deprecated()

        self.path = None
        if self.help and self.short_help.endswith('...') and 'short_help' not in kwargs.keys():
            # just keep the first line of the help in the short help
            self.short_help = self.help.splitlines()[0]

    def format_help_text(self, ctx, formatter):
        super(Group, self).format_help_text(ctx, formatter)
        if self.default_cmd_name is not None:
            formatter.write_paragraph()
            with formatter.indentation():
                formatter.write_text('When run without sub-command,'
                                     " the sub-command '{}' is implicitly run".format(self.default_cmd_name))

    def set_default_command(self, command):
        if isinstance(command, str):
            cmd_name = command
        else:
            cmd_name = command.name
            self.add_command(command)
        self.default_cmd_name = cmd_name

    def invoke(self, ctx, *args, **kwargs):
        super(Group, self).invoke_handle_deprecated(ctx, *args, **kwargs)
        return super(Group, self).invoke(ctx, *args, **kwargs)

    def parse_args(self, ctx, args):
        res, remaining = self.split_args_remaining(ctx, args)
        self.append_commandline_settings(ctx, res)

        args = self.get_extra_args(implicit_only=('--no-parameter' in args)) + list(remaining)
        ctx.complete_arguments = args[:]
        LOGGER.develop("In the {} '{}', parsing the args {}".format(
            self.__class__.__name__,
            ctx.command.path,
            args,
        ))
        if self.default_cmd_name is not None and not ctx.resilient_parsing:
            # this must be done before calling the super class to avoid the help message
            args = args or [self.default_cmd_name]
        newargs = click.Group.parse_args(self, ctx, args)
        if ctx.protected_args and ctx.protected_args[0] in ctx.complete_arguments:
            # we want to record the complete arguments given to the command, except
            # for the part that starts a new subcommand. After parse_args, the
            # ctx.protected_args informs us of the part to keep away
            index_first_subcommand = ctx.complete_arguments.index(ctx.protected_args[0])
            ctx.complete_arguments = ctx.complete_arguments[:index_first_subcommand]
        if self.default_cmd_name is not None and not ctx.resilient_parsing:
            # and this must be done here in case option where passed to the group
            ctx.protected_args = ctx.protected_args or [self.default_cmd_name]
        return newargs

    def format_options(self, ctx, formatter, include_auto_opts=False):
        # manually overide the HelpMixin in order to add the commands section
        HelpMixin.format_options(self, ctx, formatter, include_auto_opts)
        self.format_commands(ctx, formatter)

    def command(self, *args, **kwargs):
        def decorator(f):
            cmd = command(*args, **kwargs)(f)
            self.add_command(cmd)
            return cmd

        return decorator

    def flow_command(self, *args, **kwargs):
        def decorator(f):
            cmd = flow_command(*args, **kwargs)(f)
            self.add_command(cmd)
            return cmd

        return decorator

    def group(self, *args, **kwargs):
        def decorator(f):
            cmd = group(*args, **kwargs)(f)
            self.add_command(cmd)
            return cmd

        return decorator

    def list_commands(self, ctx):
        # type: (click.Context) -> [Command]
        res = list_commands_with_resolvers(self.commandresolvers, self.path, include_subcommands=True)
        if hasattr(self, 'original_command'):
            res += self.original_command.list_commands(ctx)
        res = [(c.split('.')[0] if '.' in c else c) for c in res]
        return sorted(set(res))

    def get_command(self, ctx, cmd_name):
        # type: (click.Context, str) -> Command
        if '.' in cmd_name and not allow_dotted_commands:
            raise click.UsageError('{} is not a valid command name,'
                                   " did you mean '{}'?".format(cmd_name, ' '.join(cmd_name.split('.'))))
        cmd = get_command_safe(self.path + '.' + cmd_name)
        if cmd is None and cmd_name in self.list_commands(ctx):
            raise click.ClickException(f'{self.path}.{cmd_name} could not be loaded.'
                                       f' Re run with {config.main_command.path} --develop'
                                       f' to see the stacktrace or {config.main_command.path}'
                                       ' --debug-on-command-load-error to debug the load error ')
        return cmd


def eval_arg(arg):
    if not isinstance(arg, str):
        return arg
    eval_match = re.match(r'eval(\(\d+\)|):(.+)', arg)
    nexteval_match = re.match(r'nexteval(\(\d+\)|):(.+)', arg)
    if arg.startswith('noeval:'):
        arg = arg[len('noeval:'):]
    elif nexteval_match:
        arg = 'eval%s:%s' % (
            ('(%s)' % nexteval_match.group(1) if nexteval_match.group(1) else ''), nexteval_match.group(2))
    elif arg.startswith('value:'):
        key = arg[len('value:'):]
        arg = config.get_settings('value').get(key, {'value': None})['value']
    elif arg.startswith('pyeval:'):
        try:
            evaluated_arg = str(eval(arg[len('pyeval:'):]))
            LOGGER.develop('%s evaluated to %s' % (arg, evaluated_arg))
            arg = evaluated_arg
        except Exception:
            LOGGER.develop(traceback.format_exc())
            LOGGER.error('Something went wrong when evaluating {}.'
                         ' If you did not want it to be evaluated'
                         ' please use the following syntax: noeval:{}'.format(arg, arg))
            exit(1)
    elif eval_match:
        try:

            @cache_disk(expire=int(eval_match.group(1) or '600'))
            def evaluate(project, expr):
                return check_output(shlex.split(expr)).strip()

            evaluated_arg = evaluate(config.project, eval_match.group(2))
            LOGGER.develop('%s evaluated to %s' % (arg, evaluated_arg))
            arg = evaluated_arg
        except Exception:
            LOGGER.develop(traceback.format_exc())
            LOGGER.error('Something went wrong when evaluating {}.'
                         ' If you did not want it to be evaluated'
                         ' please use the following syntax: noeval:{}'.format(arg, arg))
            exit(1)
    return arg


class ParameterMixin(click.Parameter):
    def __init__(self, *args, **kwargs):
        self.deprecated = kwargs.pop('deprecated', None)
        super(ParameterMixin, self).__init__(*args, **kwargs)

    def __process_value(self, ctx, value):
        if value is None:
            value = self.get_default(ctx)
        if value is not None:
            if isinstance(value, tuple):
                value = tuple(eval_arg(v) for v in value)
            else:
                value = eval_arg(value)
        return value

    def full_process_value(self, ctx, value):
        try:
            value = super(ParameterMixin, self).full_process_value(ctx, value)
        except MissingParameter:
            if clk.completion.IN_COMPLETION:
                value = self.get_default(ctx)
            else:
                raise
        value = self.__process_value(ctx, value)
        return value

    def get_path(self, ctx):
        path = ctx.command.path or rebuild_path(ctx)
        return path + '.' + self.name.replace('_', '-')

    def _get_default_from_values(self, ctx):
        return config.get_settings('value').get('default.' + self.get_path(ctx), {}).get('value')

    def get_default(self, ctx):
        value = self._get_default_from_values(ctx)
        if value is None:
            value = super(ParameterMixin, self).get_default(ctx)
        else:
            LOGGER.develop('Getting default value {}={}'.format(self.get_path(ctx), value))
            value = self.__process_value(ctx, value)
            value = self.type_cast_value(ctx, value)
        return value

    def get_help_record(self, ctx):
        show_default = self.show_default
        self.show_default = False
        res = super(ParameterMixin, self).get_help_record(ctx)
        self.show_default = show_default
        if res is None:
            metavar = self.type.get_metavar(ctx)
            if metavar:
                metavar = '%s %s' % (self.human_readable_name, metavar)
            else:
                metavar = self.human_readable_name
            res = (metavar, self.help)
        default = self._get_default_from_values(ctx)
        canon_default = self.default
        if isinstance(canon_default, (list, tuple)):
            canon_default = ', '.join('%s' % d for d in self.default)
        elif callable(canon_default):
            canon_default = canon_default()
        canon_default = str(canon_default)

        if self.default is not None and self.show_default:
            res1 = res[1]
            res1 += '  [default: '
            if default:
                res1 += default + ' (computed from value.default.{}'.format(self.get_path(ctx))
                if self.default:
                    res1 += ' and overriding static one: ' + canon_default
                res1 += ')'
            elif isinstance(canon_default, str) and canon_default.startswith('value:'):
                res1 += config.get_settings('value').get(canon_default[len('value:'):], {'value': 'None'}).get('value')
                res1 += ' (computed from {})'.format(canon_default)
            else:
                res1 += canon_default
            res1 += ']'
            res = (
                res[0],
                res1,
            )
        if self.deprecated:
            res = (
                res[0],
                res[1] + ' (deprecated: {})'.format(self.deprecated),
            )
        return res


class Option(ParameterMixin, click.Option):
    def __init__(self, *args, **kwargs):
        self.group = kwargs.pop('group', None)
        kwargs.setdefault('show_default', True)
        super(Option, self).__init__(*args, **kwargs)


class AutomaticOption(Option):
    def __init__(self, *args, **kwargs):
        kwargs.setdefault('group', 'automatic')
        super(AutomaticOption, self).__init__(*args, **kwargs)


class Argument(ParameterMixin, click.Argument):
    def __init__(self, *args, **kwargs):
        self.help = kwargs.pop('help', '')
        self.show_default = kwargs.pop('show_default', True)
        super(Argument, self).__init__(*args, **kwargs)


def in_project(command):
    options = [
        AutomaticOption(['--in-project/--no-in-project'],
                        group='working directory',
                        is_flag=True,
                        help='Run the command in the project directory'),
        AutomaticOption(['--cwd'],
                        group='working directory',
                        help='Run the command in this directory. It can be used with --in-project to change to a'
                        ' directory relative to the project directory')
    ]
    callback = command.callback

    @functools.wraps(callback)
    def launcher(*args, **kwargs):
        in_project = kwargs['in_project']
        cwd = kwargs['cwd']
        del kwargs['in_project']
        del kwargs['cwd']

        def run_in_cwd():
            if cwd:
                with cd(cwd):
                    return callback(*args, **kwargs)
            else:
                return callback(*args, **kwargs)

        if in_project:
            config.require_project()
            with cd(config.project):
                res = run_in_cwd()
        else:
            res = run_in_cwd()
        return res

    command.callback = launcher
    command.params.extend(options)
    return command


def command(ignore_unknown_options=False,
            change_directory_options=True,
            handle_dry_run=None,
            flowdepends=None,
            *args,
            **attrs):
    """Create a new Command and automatically pass the config"""
    context_settings = attrs.get('context_settings', {})
    context_settings.setdefault('max_content_width', 120)
    if ignore_unknown_options is not None:
        context_settings['ignore_unknown_options'] = ignore_unknown_options
    attrs['context_settings'] = context_settings
    attrs.setdefault('cls', Command)

    def decorator(f):
        attrs.setdefault('name', f.__name__.replace('_', '-').strip('-'))
        click_command = click.command(*args, **attrs)
        f = click_command(f)
        if change_directory_options:
            f = in_project(f)
        if hasattr(f.callback, 'inherited_params'):
            f.inherited_params = f.callback.inherited_params
        if flowdepends is not None:
            f.clickproject_flowdepends = flowdepends
        f.handle_dry_run = handle_dry_run
        return f

    return decorator


def group(*args, **kwargs):
    """Create a new Group and automatically pass the config"""
    kwargs.setdefault('cls', Group)
    return command(*args, **kwargs)


def option(*args, **kwargs):
    """Declare on new option"""
    deprecated = kwargs.get('deprecated')
    callback = kwargs.get('callback')
    if deprecated:

        def new_callback(ctx, attr, value):
            if attr.name not in ctx.clk_default_catch:
                LOGGER.warning('{} is deprecated: {}'.format(attr.opts[0], deprecated))
            if callback:
                return callback(ctx, attr, value)
            else:
                return value

        kwargs['callback'] = new_callback
    kwargs.setdefault('cls', Option)
    return click.option(*args, **kwargs)


def flag(*args, **kwargs):
    """Declare on new flag. This is a shortcut for @option(is_flag=True)"""
    kwargs.setdefault('is_flag', True)
    return option(*args, **kwargs)


def argument(*args, **kwargs):
    """Declare on new argument"""
    deprecated = kwargs.get('deprecated')
    callback = kwargs.get('callback')
    if deprecated:

        def new_callback(ctx, attr, value):
            if attr.name not in ctx.clk_default_catch:
                LOGGER.warning('{} is deprecated: {}'.format(attr.opts[0], deprecated))
            if callback:
                return callback(ctx, attr, value)
            else:
                return value

        kwargs['callback'] = new_callback
    kwargs.setdefault('cls', Argument)
    return click.argument(*args, **kwargs)


def flow_command(flowdepends=(), flow_from=None, flow_after=None, **kwargs):
    def decorator(f):
        try:
            params = list(f.__click_params__)
            params.reverse()
        except AttributeError:
            params = []
        flowdepends_set = set(flowdepends)
        for p in params:
            if isinstance(p, (FlowOption, FlowArgument)):
                flowdepends_set.add(p.target_command.path)
        c = command(flowdepends=list(flowdepends_set), **kwargs)(f)
        c.clickproject_flow = (not flow_from and not flow_after) or None
        c.clickproject_flowfrom = flow_from
        c.clickproject_flowafter = flow_after
        return c

    return decorator


def flow_option(*args, **kwargs):
    return option(*args, cls=FlowOption, **kwargs)


def flow_options(options=None, target_command=None, **kwargs):
    if options is None:
        options = [
            p.name for p in target_command.params if isinstance(p, click.Option) and not isinstance(p, AutomaticOption)
        ]

    def decorator(f):
        for name in reversed(options):
            f = option(name, target_command=target_command, cls=FlowOption, **kwargs)(f)
        return f

    return decorator


def flow_argument(*args, **kwargs):
    return argument(*args, cls=FlowArgument, **kwargs)


class CommandType(ParameterType):
    def __init__(self, recursive=True):
        super(CommandType, self).__init__()
        self.recursive = recursive

    def complete(self, ctx, incomplete):
        @cache_disk(expire=600)
        def get_candidates(parent_path):
            if parent_path != config.main_command.path:
                candidates = [
                    (parent_path + '.' + cmd,
                     (get_command_safe(parent_path + '.' +
                                       cmd).short_help if get_command_safe(parent_path + '.' +
                                                                           cmd) is not None else 'Broken command'))
                    for cmd in list_commands(parent_path)
                ]
            else:
                candidates = [
                    (cmd, (get_command_safe(cmd).short_help if get_command_safe(cmd) is not None else 'Broken command'))
                    for cmd in list_commands(config.main_command.path)
                ] + [(config.main_command.path, 'Main parameters')]
            period_candidates = [(elem[0] + '.', None)
                                 for elem in candidates
                                 if isinstance(get_command_safe(elem[0]), Group)]
            candidates += period_candidates
            return candidates

        if '.' in incomplete:
            split = incomplete.split('.')
            parent_path = '.'.join(split[:-1])
        else:
            parent_path = config.main_command.path
        candidates = get_candidates(parent_path)
        return [(cmd, cmd_help)
                for cmd, cmd_help in candidates
                if startswith(cmd, incomplete) and (self.recursive or '.' not in cmd)]

    def convert(self, value, param, ctx):
        if get_command_safe(value) is None:
            if '.' in value:
                parent_path = '.'.join(value.split('.')[:-1])
            else:
                parent_path = config.main_command.path
            choices = list_commands(parent_path)
            if value not in choices:
                self.fail('invalid choice: %s. (choose from %s)' % (value, ', '.join(choices)), param, ctx)
            return value
        return value


class CommandSettingsKeyType(ParameterType):
    def __init__(self, name, silent_fail=False):
        self.name = name
        self.silent_fail = silent_fail

    def settings(self, ctx):
        return settings_stores[self.name].readonly

    def complete(self, ctx, incomplete):
        @cache_disk(expire=600)
        def get_shortdoc(path):
            cmd = get_command_safe(path)
            if cmd is None:
                return 'Broken command'
            else:
                return cmd.short_help

        choices = [(path, get_shortdoc(path)) for path in self.settings(ctx).keys()]
        return [(cmd, cmd_help) for cmd, cmd_help in choices if startswith(cmd, incomplete)]

    def convert(self, value, param, ctx):
        choices = self.settings(ctx).keys()
        if value not in choices and not self.silent_fail:
            self.fail('invalid choice: %s. (choose from %s)' % (value, ', '.join(choices)), param, ctx)
        return value


class MainCommand(click_didyoumean.DYMMixin, DeprecatedMixin, TriggerMixin, HelpMixin, ExtraParametersMixin,
                  RememberParametersMixin, click.MultiCommand):
    auto_envvar_prefix = 'CLK'
    path = 'clk'
    commandresolvers = [CoreCommandResolver()]

    def __init__(self, *args, **kwargs):
        context_settings = kwargs.get('context_settings', {})
        context_settings.setdefault('max_content_width', 120)
        kwargs['context_settings'] = context_settings
        super(MainCommand, self).__init__(*args, **kwargs)
        super(MainCommand, self).init_deprecated()

    def get_command_short_help(self, ctx, cmd_name):
        @cache_disk
        def short_help(cmd_path, name):
            cmd = self.get_command(ctx, name)
            return cmd.short_help if cmd else None

        return short_help(ctx.command_path, cmd_name)

    def get_command_hidden(self, ctx, cmd_name):
        @cache_disk
        def hidden(cmd_path, name):
            cmd = self.get_command(ctx, name)
            return cmd.hidden if cmd else False

        return hidden(ctx.command_path, cmd_name)

    def invoke(self, ctx, *args, **kwargs):
        super(MainCommand, self).invoke_handle_deprecated(ctx, *args, **kwargs)
        return super(MainCommand, self).invoke(ctx, *args, **kwargs)

    def parse_args(self, ctx, args):
        res, remaining = self.split_args_remaining(ctx, args)
        self.append_commandline_settings(ctx, res)
        ctx.auto_envvar_prefix = self.auto_envvar_prefix
        # parse the args, injecting the extra args, till the extra args are stable
        old_extra_args = []
        if '--no-parameter' in args:
            new_extra_args = self.get_extra_args(implicit_only=True)
            res = click.MultiCommand.parse_args(self, ctx, new_extra_args + args)
            ctx.complete_arguments = list(args)
        else:
            new_extra_args = self.get_extra_args()
            if new_extra_args == old_extra_args:
                res = click.MultiCommand.parse_args(self, ctx, new_extra_args + args)
                new_extra_args = self.get_extra_args()
            while new_extra_args != old_extra_args:
                old_extra_args = new_extra_args[:]
                config.reset_env()
                res = click.MultiCommand.parse_args(self, ctx, new_extra_args + args)
                new_extra_args = self.get_extra_args()
            LOGGER.develop(
                "In the {} '{}', parsing args {} (initial args: {})".format(self.__class__.__name__, ctx.command.path,
                                                                            new_extra_args, args), )
            ctx.complete_arguments = list(new_extra_args)

        if not hasattr(ctx, 'has_subcommands'):
            ctx.has_subcommands = True
        if not ctx.resilient_parsing:
            if ctx.protected_args:
                ctx.has_subcommands = True
            else:
                ctx.has_subcommands = False
        config.init()
        return res

    def format_options(self, ctx, formatter, include_auto_opts=False):
        # manually overide the HelpMixin in order to add the commands section
        HelpMixin.format_options(self, ctx, formatter, include_auto_opts)
        self.format_commands(ctx, formatter)

    def list_commands(self, ctx):
        return sorted(
            set([(c.split('.')[0] if '.' in c else c)
                 for c in list_commands_with_resolvers(self.commandresolvers, self.path, include_subcommands=True)]))

    def get_command(self, ctx, name):
        if '.' in name and not allow_dotted_commands:
            raise click.UsageError('{} is not a valid command name,'
                                   " did you mean '{}'?".format(name, ' '.join(name.split('.'))))
        cmd = get_command_safe(name)
        if cmd is None and name in self.list_commands(ctx):
            raise click.ClickException(f'{self.path}.{name} could not be loaded.'
                                       f' Re run with {config.main_command.path} --develop'
                                       f' to see the stacktrace or {config.main_command.path}'
                                       ' --debug-on-command-load-error to debug the load error ')
        return cmd


class FlowOption(Option):
    def __init__(self, param_decls, target_command, target_option=None, **kwargs):
        name, opts, secondary_opts = self._parse_decls(param_decls or (), kwargs.get('expose_value'))
        target_option = target_option or name
        o = [p for p in target_command.params if p.name == target_option]
        if o:
            o = o[0]
        else:
            raise Exception("No '%s' option in the '%s' command" % (target_option, target_command.name))
        self.target_command = target_command
        self.target_parameter = o
        okwargs = deepcopy(o.__dict__)
        del okwargs['name']
        del okwargs['opts']
        del okwargs['secondary_opts']
        del okwargs['is_bool_flag']
        if okwargs['is_flag'] and isinstance(okwargs['flag_value'], bool):
            # required to properly set he is_bool_flag, because of a bug in click.Option.__init__
            del okwargs['type']
        if not opts and not secondary_opts:
            zipped_options = ['/'.join(c) for c in zip(o.opts, o.secondary_opts)]
            param_decls = [target_option
                           ] + zipped_options + o.opts[len(zipped_options):] + o.secondary_opts[len(zipped_options):]
        # change the default value to None in order to detect when the value should be passed to the previous commands
        # in the flow
        okwargs['default'] = None
        Option.__init__(self, param_decls, **okwargs)

    def _parse_decls(self, decls, expose_value):
        try:
            name, opts, secondary_opts = Option._parse_decls(self, decls, expose_value)
        except TypeError as e:
            message = e.args[0]
            re_match = re.match(r'No options defined but a name was passed \((\S+)\)\.', message)
            if re_match:
                name = re_match.group(1)
                opts = []
                secondary_opts = []
            else:
                raise
        return name, opts, secondary_opts


class FlowArgument(Argument):
    def __init__(self, param_decls, target_command, target_argument=None, **kwargs):
        name, opts, secondary_opts = self._parse_decls(param_decls or (), kwargs.get('expose_value'))
        target_argument = target_argument or name
        o = [p for p in target_command.params if p.name == target_argument]
        if o:
            o = o[0]
        else:
            raise Exception("No '%s' argument in the '%s' command" % (target_argument, target_command.name))
        self.target_command = target_command
        self.target_parameter = o
        okwargs = deepcopy(o.__dict__)
        del okwargs['name']
        del okwargs['opts']
        del okwargs['secondary_opts']
        del okwargs['multiple']
        # change the default value to None in order to detect when the value should be passed to the previous commands
        # in the flow
        okwargs['default'] = None
        Argument.__init__(self, param_decls, **okwargs)


def entry_point(cls=None, **kwargs):
    def decorator(f):
        if cls is None:
            path = f.__name__
            _cls = type('{}Main'.format(path), (MainCommand, ), {
                'path': path,
                'auto_envvar_prefix': path.upper(),
            })
        else:
            _cls = cls
        return main_command_decoration(f, _cls, **kwargs)

    return decorator
