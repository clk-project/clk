#!/usr/bin/env python
# -*- coding:utf-8 -*-

import click
import six
import platform
import os
import subprocess
import pstats
import time
import logging
import re
import hashlib
import pickle
from datetime import datetime
import appdirs

from six import StringIO

from click_project import completion
from click_project import log
from click_project import startup_time
from click_project.log import LOG_LEVELS, get_logger
from click_project.atexit import trigger
from click_project.config import temp_config, config, Config, migrate_profiles
from click_project.click_helpers import click_get_current_context_safe
from click_project.lib import main_default, natural_delta, ParameterType, makedirs
from click_project.completion import startswith

LOGGER = get_logger(__name__)


settings_stores = {}


def run(cmd, *args, **kwargs):
    """Calls the main_command without polluting the calling config

    Directly calling the main_command has two drawbacks.

    1. A call to main_command redo a parsing of the arguments. This may result in
       rewritting things into the config.
    2. The calling side generally don't want to handle possible changes in
       the config made by the called command.

    This command runs main_command in a new config, avoiding the nasty side
    effects. It extends to call with its own main_command command line
    parameters, so that the new parsing step should have a similar default
    behavior.

    For instance, say the command `a` does `config.me = "a"`, and the command
    `b` does `config.me = "b"`, then calls `a`, and then echo
    config.me. Now, imagine you execute `clk --develop b`. I expect it to run b
    in develop mode, then run a in develop mode and still write b on the
    standard output. This is exactly what run is about.

    """
    cmd = config.commandline_profile.get_settings("parameters")[config.main_command.path] + cmd
    with temp_config():
        return config.main_command(cmd, *args, **kwargs)


def resolve_context_with_side_effects(path, resilient_parsing=True):
    from click_completion import resolve_ctx
    return resolve_ctx(
        config.main_command,
        config.main_command.__class__.path,
        path,
        resilient_parsing=resilient_parsing
    )


get_ctx_cache = {}


def rebuild_path(ctx):
    if ctx is None:
        return None
    path = ctx.command.name
    parent_path = rebuild_path(ctx.parent)
    if (
            parent_path is not None and
            not isinstance(ctx.parent.command, config.main_command.__class__)
    ):
        path = parent_path + "." + path
    return path


def get_ctx(path, side_effects=False, resilient_parsing=None):
    if resilient_parsing is None:
        ctx = click_get_current_context_safe()
        resilient_parsing = (ctx is not None and ctx.resilient_parsing) or False

    key = tuple(path)
    if key not in get_ctx_cache:
        if side_effects:
            res = resolve_context_with_side_effects(path, resilient_parsing=resilient_parsing)
        else:
            with temp_config():
                res = resolve_context_with_side_effects(path, resilient_parsing=resilient_parsing)
        assert res is not None, "Could not interpret the command {}".format(".".join(path))
        get_ctx_cache[key] = res
    else:
        res = get_ctx_cache[key]
    return res


main_command_parameters = set()


def main_command_options_callback(f):
    def decorator(ctx, attr, value):
        if config.frozen:
            return value
        if value is None:
            return value
        value = f(ctx, attr, value)
        return value
    return decorator


def main_command_option(*args, **kwargs):
    decorator = click.option(*args, **kwargs)

    def new_decorator(f):
        f = decorator(f)
        # we assume that the option is the last in the param list (click
        # implementation dependent)
        option = f.__click_params__[-1]
        main_command_parameters.add(option)
        return f
    return new_decorator


def main_command_arguments_to_dict(opts, resilient_parsing):
    pos = 0
    res = {}
    try:
        while opts and pos < len(opts):
            opt = opts[pos]
            matching_options = [
                option
                for option in main_command_parameters
                if opt in option.opts
             ]
            assert len(matching_options) < 2
            if len(matching_options) == 0:
                # we reached something we don't recognize, it must be the
                # beginning of a new subcommand
                break
            option = matching_options[0]
            assert option.nargs != 0
            nargs = None
            if option.nargs == 1:
                if option.is_flag:
                    res[option.name] = True
                    nargs = 1
                else:
                    res[option.name] = opts[pos+1]
                    nargs = 2
            else:
                res[option.name] = opts[pos+1:pos+1+option.nargs]
                nargs = option.nargs + 1
            pos += nargs
    except IndexError:
        if not resilient_parsing:
            raise click.UsageError("%s option requires an argument" % opts[pos])
    return res


def main_command_arguments_from_dict(parameters):
    res = []
    for key, value in six.iteritems(parameters):
        matching_options = [
            option
            for option in main_command_parameters
            if key == option.name
        ]
        assert len(matching_options) == 1
        option = matching_options[0]
        opt = option.opts[0]
        if value is True:
            res.append(opt)
        elif isinstance(value, six.string_types):
            res.extend([opt, value])
        elif isinstance(value, list):
            res += [opt] + value
        else:
            raise NotImplementedError(
                "Cannot build a command line with {}: {}".format(key, value))
    return res


class RecipeType(ParameterType):
    envvar_list_splitter = ","

    @property
    def choices(self):
        return [
                recipe.short_name
                for recipe in config.all_recipes
            ]

    def complete(self, ctx, incomplete):
        return (
            choice
            for choice in self.choices
            if startswith(choice, incomplete)
        )

    def convert(self, value, param, ctx):
        if value not in self.choices:
            self.fail('invalid choice: %s. (choose from %s)' %
                      (value, ', '.join(self.choices)), param, ctx)
        return value


class ColorType(ParameterType):
    name = "color"
    colors = [
        "black",
        "red",
        "green",
        "yellow",
        "blue",
        "magenta",
        "cyan",
        "white",
    ]
    args = {
        "fg": colors,
        "bg": colors,
        "dim": [True, False],
        "bold": [True, False],
        "underline": [True, False],
        "blink": [True, False],
        "reverse": [True, False],
        "reset": [True, False],
    }
    converters = {
        "fg": lambda e: e,
        "bg": lambda e: e,
        "dim": lambda e: True if e == "True" else False,
        "bold": lambda e: True if e == "True" else False,
        "underline": lambda e: True if e == "True" else False,
        "blink": lambda e: True if e == "True" else False,
        "reverse": lambda e: True if e == "True" else False,
        "reset": lambda e: True if e == "True" else False,
    }

    @staticmethod
    def get_kwargs(color_name):
        def splitpart(part):
            parts = part.split("-")
            if len(parts) == 1:
                return ["fg", part]
            else:
                return parts

        return {
            key: value
            for key, value in [
                    splitpart(part)
                    for part in color_name.split(",")
            ]
        }

    def complete(self, ctx, incomplete):
        # got from click.termui.style
        if "," not in incomplete and ":" not in incomplete:
            candidates = self.colors + [key + "-" for key in self.args.keys()]
            candidates = [candidate for candidate in candidates if startswith(candidate, incomplete)]
            if len(candidates) == 1:
                incomplete = candidates[0]
            tested = incomplete
            prefix = ""
        valuematch = re.match("^(?P<prefix>.*?)(?P<key>[^,:]+)-(?P<value>[^,]*)$", incomplete)
        keymatch = re.match("^(?P<prefix>.*?),(?P<key>[^,:]*)$", incomplete)
        if valuematch:
            prefix, key, value = valuematch.groups()
            candidates = self.args.get(key, [])
            tested = value or ""
            prefix = "{}{}-".format(prefix, key)
        elif keymatch:
            prefix, key = keymatch.groups()
            candidates = [key_ + "-" for key_ in self.args.keys()]
            tested = key
            prefix = "{},".format(prefix)
        return [
            prefix + str(candidate)
            for candidate in candidates
            if startswith(str(candidate), tested)
        ]

    def convert(self, value, param, ctx):
        kwargs = {
            key: self.converters[key](value)
            for key, value in self.get_kwargs(value).items()
        }
        return kwargs


class DynamicChoiceType(ParameterType):
    """Meant to be inherited from, base class for providing computed choices

Very useful to get choices not available when defining the function but
available dynamically in the config.

class SomeChoices(DynamicChoiceType):
    def choices(self):
         return [config.something, config.somethingelse]

@option("--someoption", type=SomeChoices())

"""
    def choices(self):
        raise NotImplementedError

    def converter(self, value):
        return value

    def complete(self, ctx, incomplete):
        return [
            name
            for name in self.choices()
            if startswith(name, incomplete)
        ]

    def convert(self, value, param, ctx):
        if ctx.resilient_parsing:
            return value
        choices = self.choices()
        if value not in choices:
            self.fail('invalid choice: %s. (choose from %s)' %
                      (value, ', '.join(choices)), param, ctx)
        if isinstance(choices, dict):
            value = choices[value]
        value = self.converter(value)
        return value


def main_command_decoration(f, cls, **kwargs):
    f = main_command_option('--force-color/--no-force-color', is_flag=True, callback=force_color_callback,
                            help="Force the color output, even if the output is not a terminal")(f)
    f = main_command_option('-n', '--dry-run/--no-dry-run', is_flag=True, callback=dry_run_callback,
                            help="Don't actually run anything")(f)
    f = main_command_option('--no-cache/--cache', is_flag=True, callback=no_cache_callback,
                            help="Deactivate the caching mechanism")(f)
    f = main_command_option('--autoflow/--no-autoflow', help="Automatically trigger the --flow option in"
                            " every command", is_flag=True, callback=autoflow_callback, default=None)(f)
    f = main_command_option('-P', '--project', metavar="DIR", help="Project directory", callback=project_callback)(f)
    f = main_command_option('--persist-migration/--no-persist-migration', help=(
        "Make the profile migration persistent,"
        " using --no-persist-migration will preserve the profiles,"
        " unless you explicitly write into them."
        " This is useful if you want to use a razor edge version of the application"
        " without forcing peoples to move to it."),
                            is_flag=True,
                            default=True,
                            callback=persist_migration_callback,)(f)
    f = main_command_option('--plugin-dirs', help="", callback=plugin_dirs_callback, multiple=True)(f)
    f = main_command_option('--alternate-style', metavar="STYLE", help="Alternate style",
                            callback=alternate_style_callback,
                            default='fg-cyan' if platform.system() == 'Windows' else 'dim-True',
                            type=ColorType())(f)
    f = main_command_option('-L', '--log-level', default=None, type=click.Choice(LOG_LEVELS.keys()), callback=log_level_callback,
                            help="Log level (default to 'status')")(f)
    f = main_command_option('-q', '--quiet/--no-quiet', help="Same as --log-level critical", callback=quiet_callback, is_eager=True,
                            default=None)(f)
    f = main_command_option('-a', '--action/--no-action', help="Same as --log-level action", callback=action_callback, is_eager=True,
                            default=None)(f)
    f = main_command_option('-d', '--debug/--no-debug', help="Same as --log-level debug", callback=debug_callback, is_eager=True,
                            default=None)(f)
    f = main_command_option('-D', '--develop/--no-develop', help="Same as --log-level develop", callback=develop_callback, is_eager=True,
                            default=None)(f)
    f = main_command_option('--exit-on-log-level', default=None, type=click.Choice(LOG_LEVELS.keys()), callback=exit_on_log_level_callback,
                            help="Exit when one log of this level is issued."
                            " Useful to reproduce the -Werror behavior of gcc")(f)
    f = main_command_option('--post-mortem/--no-post-mortem', help="Run a post-mortem debugger in case of exception",
                            callback=post_mortem_callback, is_eager=True, default=None)(f)
    f = main_command_option('--debug-on-command-load-error', is_flag=True,
                            help="Trigger a debugger whenever a command fails to load",
                            callback=debug_on_command_load_error_callback)(f)
    f = main_command_option("--report-file",
                            help="Create a report file to put with bug reports",
                            callback=report_file_callback,
                            is_eager=True)(f)
    f = main_command_option('-r', '--recipe', callback=recipe_callback,
                            help="Enable this recipe for the time of the command", type=RecipeType(), multiple=True)(f)
    f = main_command_option('-u', '--without-recipe', callback=without_recipe_callback,
                            help="Disable this recipe for the time of the command", type=RecipeType(), multiple=True)(f)
    f = main_command_option('--profiling', is_flag=True, callback=enable_profiling_callback,
                            help="Enable profiling the application code")(f)
    f = main_command_option('--env', callback=add_custom_env,
                            help="Add this custom environment variable",
                            multiple=True)(f)
    f = click.group(cls=cls, invoke_without_command=True)(f)
    prog_name = cls.path
    env_name = '_%s_COMPLETE' % prog_name.upper().replace('-', '_')
    if env_name in os.environ:
        completion.IN_COMPLETION = True
    command = main_default(
        prog_name=cls.path,
        standalone_mode=False,
        **kwargs)(f)
    Config.main_command = command
    old_callback = command.callback

    def new_callback(*args, **kwargs):
        migrate_profiles()
        LOGGER.develop("Global profile: {}".format(config.global_profile.location))
        if config.local_profile:
            LOGGER.develop("Local profile: {}".format(config.local_profile.location))
        ctx = click.get_current_context()
        if kwargs.get("help") or not ctx.has_subcommands:
            click.echo(ctx.get_help(), color=ctx.color)
            ctx.exit()
        return old_callback(*args, **kwargs)
    command.callback = new_callback
    return command


def main_command(cls, **kwargs):
    def decorator(f):
        return main_command_decoration(f, cls, *kwargs)
    return decorator


################################
# Handling of the core options #
################################


@main_command_options_callback
def show_version_callback(ctx, param, value):
    pass


@main_command_options_callback
def project_callback(ctx, attr, value):
    config.project = value
    return value


@main_command_options_callback
def recipe_callback(ctx, attr, values):
    recipes = config.commandline_profile.get_settings("recipe")
    for value in values:
        recipe = recipes.get(value, {})
        recipe["enabled"] = True
        recipes[value] = recipe
    config.commandline_profile.set_settings("recipe", recipes)
    return values


def without_recipe_callback(ctx, attr, values):
    recipes = config.commandline_profile.get_settings("recipe")
    for value in values:
        recipe = recipes.get(value, {})
        recipe["enabled"] = False
        recipes[value] = recipe
    config.commandline_profile.set_settings("recipe", recipes)
    return values


profiling = None


def enable_profiling_callback(ctx, attr, value):
    if value:
        import cProfile
        global profiling
        profiling = cProfile.Profile()
        profiling.enable()
    return value


@main_command_options_callback
def add_custom_env(ctx, attr, values):
    if values is not None:
        for value in values:
            key, *rest = value.split("=")
            rest = "=".join(rest)
            config.override_env[key] = rest
    return values


@main_command_options_callback
def log_level_callback(ctx, attr, value):
    if value is not None:
        config.log_level = value
        if value == 'develop':
            log.default_handler.formatter = log.DevelopColorFormatter()
    return value


@main_command_options_callback
def exit_on_log_level_callback(ctx, attr, value):
    log.exit_on_log_level = value


@main_command_options_callback
def debug_callback(ctx, attr, value):
    if value:
        config.log_level = 'debug'
    elif value is not None and config.debug:
        config.log_level = 'status'
    return value


@main_command_options_callback
def develop_callback(ctx, attr, value):
    if value:
        config.log_level = 'develop'
        log.default_handler.formatter = log.DevelopColorFormatter()
    elif value is not None and config.debug:
        config.log_level = 'status'
    return value


@main_command_options_callback
def action_callback(ctx, attr, value):
    if value:
        config.log_level = 'action'
    elif value is not None and config.debug:
        config.log_level = 'status'
    return value


@main_command_options_callback
def dry_run_callback(ctx, attr, value):
    if value:
        config.dry_run = True
    return value


@main_command_options_callback
def force_color_callback(ctx, attr, value):
    if value:
        config.force_color = True
        ctx.color = value
    return value


@main_command_options_callback
def no_cache_callback(ctx, attr, value):
    global cache_disk_deactivate
    if value is not None:
        cache_disk_deactivate = value
    return value


@main_command_options_callback
def quiet_callback(ctx, attr, value):
    if value:
        config.log_level = 'critical'
    elif value is not None and config.log_level == "critical":
        config.log_level = "command"
    return value


_post_mortem = None


@main_command_options_callback
def post_mortem_callback(ctx, attr, value):
    global _post_mortem
    _post_mortem = value


@main_command_options_callback
def autoflow_callback(ctx, attr, value):
    config.autoflow = value


@main_command_options_callback
def alternate_style_callback(ctx, attr, value):
    config.alt_style = value


@main_command_options_callback
def persist_migration_callback(ctx, attr, value):
    config.persist_migration = value


@main_command_options_callback
def plugin_dirs_callback(ctx, attr, value):
    config.plugindirs = list(value)


@main_command_options_callback
def debug_on_command_load_error_callback(ctx, attr, value):
    config.debug_on_command_load_error_callback = value


def report_file_callback(ctx, attr, value):
    if value and not ctx.resilient_parsing:
        filepath = os.path.abspath(value)
        handler = logging.FileHandler(filepath)
        handler.setLevel(1)
        from click_project import LOGGERS
        for logger in LOGGERS:
            logger.addHandler(handler)


def log_trace():
    import traceback
    log = LOGGER.error if os.environ.get('CLICK_PROJECT_LOG_TRACE') is not None else LOGGER.develop
    log(traceback.format_exc())


def post_mortem():
    if _post_mortem:
        import sys
        import ipdb
        ipdb.post_mortem(sys.exc_info()[2])


def main():
    exitcode = 0
    try:
        try:
            config.main_command()
        except:  # NOQA: E722
            log.exit_on_log_level = None
            raise
    except click.exceptions.Abort:
        LOGGER.debug("Abooooooooort!!")
        exitcode = 1
    except click.ClickException as e:
        if isinstance(e, click.UsageError) and e.ctx is not None:
            click.echo(e.ctx.get_usage())
        log_trace()
        LOGGER.error(e.format_message())
        if isinstance(e, click.exceptions.NoSuchOption):
            click.echo(
                "Hint: If you don't know where this option comes from,"
                " try checking the parameters (with {} --no-parameters"
                " parameters show).".format(config.main_command.path)
            )
        post_mortem()
        exitcode = e.exit_code
    except subprocess.CalledProcessError as e:
        if e.returncode < 0 and e.returncode != -2:
            LOGGER.error(str(e))
        log_trace()
        post_mortem()
        exitcode = e.returncode
    except NotImplementedError as e:
        log_trace()
        click.echo(
            "This command reached a part of the code yet to implement. "
            "Please help us by either submitting patches or "
            "sending report files to us. ({} --report-file .../somefile RESTOFCOMMAND, "
            "then send .../somefile to us)".format(config.main_command.path)
        )
        LOGGER.error(str(e))
        post_mortem()
        exitcode = 2
    except EnvironmentError as e:
        log_trace()
        LOGGER.error(str(e))
        post_mortem()
        exitcode = 1
    except (Exception, log.LogLevelExitException) as e:
        log_trace()
        LOGGER.exception(str(e))
        LOGGER.error(
            "{} reached an error that was not properly caught."
            " Please tell us.".format(
                config.main_command.path)
        )
        post_mortem()
        exitcode = 1
    finally:
        if profiling is not None:
            profiling.disable()
            sortby = 'cumulative'
            s = StringIO()
            ps = pstats.Stats(profiling, stream=s).sort_stats(sortby)
            ps.print_stats()
            print(s.getvalue())
        trigger()
        end_time = datetime.now()
        LOGGER.debug("command run in %s" % natural_delta(end_time - startup_time))
    exit(exitcode)


cache_disk_deactivate = False


def cache_disk(f=None, expire=int(os.environ.get(u'CLICK_PROJECT_CACHE_EXPIRE', 24 * 60 * 60)),
               cache_folder_name=None):
    u"""A decorator that cache a method result to disk"""
    if cache_disk_deactivate:
        return lambda f: f

    cache_folder = appdirs.user_cache_dir(config.app_name)

    def decorator(f):
        if expire == -1:
            return f

        def inner_function(*args, **kwargs):
            # calculate a cache key based on the decorated method signature
            key = u"{}{}{}{}".format(
                re.sub(
                    "pluginbase\._internalspace.[^\.]+\.",
                    "click_project.plugins.", f.__module__),
                f.__name__,
                args,
                kwargs).encode(u"utf-8")
            # print(key)
            key = hashlib.sha1(key).hexdigest()
            if not os.path.exists(cache_folder):
                makedirs(cache_folder)
            filepath = os.path.join(cache_folder, key)
            # verify that the cached object exists and is less than $seconds old
            if os.path.exists(filepath):
                modified = os.path.getmtime(filepath)
                age_seconds = time.time() - modified
                if expire is None or age_seconds < expire:
                    return pickle.load(open(filepath, u"rb"))
            # call the decorated function...
            result = f(*args, **kwargs)
            # ... and save the cached object for next time
            pickle.dump(result, open(filepath, u"wb"))
            return result
        return inner_function

    return decorator(f) if f else decorator
