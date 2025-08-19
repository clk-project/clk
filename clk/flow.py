#!/usr/bin/env python

from collections import defaultdict

import click

from clk import overloads
from clk.config import config, temp_config
from clk.core import run
from clk.lib import flat_map, ordered_unique
from clk.log import get_logger
from clk.overloads import (
    AutomaticOption,
    CommandNotFound,
    FlowArgument,
    FlowOption,
    get_command,
    get_command_handlers,
)

flowdeps = defaultdict(list)
LOGGER = get_logger(__name__)


def setup_flow_params(cmd):
    # remove the --flow params if already there
    cmd.params = [
        param
        for param in cmd.params
        if "--flow" not in param.opts
        and "--flow-from" not in param.opts
        and "--flow-after" not in param.opts
    ]
    flow_default = cmd.clk_flow if hasattr(cmd, "clk_flow") else None
    flowfrom_default = cmd.clk_flowfrom if hasattr(cmd, "clk_flowfrom") else None
    flowafter_default = cmd.clk_flowafter if hasattr(cmd, "clk_flowafter") else None
    cmd.params.extend(
        get_flow_params(cmd.path, flow_default, flowfrom_default, flowafter_default)
    )


def clean_flow_arguments(arguments):
    arguments = arguments[:]
    while "--flow" in arguments:
        del arguments[arguments.index("--flow")]
    while "--flow-from" in arguments:
        del arguments[arguments.index("--flow-from") + 1]
        del arguments[arguments.index("--flow-from")]
    to_remove = [i for i, arg in enumerate(arguments) if arg.startswith("--flow-from=")]
    for i in reversed(to_remove):
        del arguments[i]
    while "--flow-after" in arguments:
        del arguments[arguments.index("--flow-after") + 1]
        del arguments[arguments.index("--flow-after")]
    to_remove = [
        i for i, arg in enumerate(arguments) if arg.startswith("--flow-after=")
    ]
    for i in reversed(to_remove):
        del arguments[i]
    return arguments


def get_command_handler(cmd):
    if hasattr(cmd, "clk_flow_already_setup"):
        return cmd
    if hasattr(cmd.callback, "clk_flowdepends"):
        LOGGER.warn(
            "Using the decorator @flowdepends is deprecated"
            " and will be removed in the future."
            " Please specify the flow dependencies in the"
            " flowdepends keyword argument of @command or @group."
        )
        flowdeps[cmd.path] = cmd.callback.clk_flowdepends
    if hasattr(cmd, "clk_flowdepends"):
        flowdeps[cmd.path] = cmd.clk_flowdepends
    flowdeps_settings = config.settings.get("flowdeps")
    if flowdeps_settings and cmd.path in flowdeps_settings:
        LOGGER.debug(
            f"Overriding flow dependencies of {cmd.path} with {flowdeps_settings[cmd.path]}"
        )
        new_flow = flowdeps_settings[cmd.path]
        if "[self]" in new_flow:
            self_index = new_flow.index("[self]")
            new_flow = (
                new_flow[:self_index] + flowdeps[cmd.path] + new_flow[self_index + 1 :]
            )
        flowdeps[cmd.path] = new_flow
    try:
        cmd_has_flow = has_flow(cmd.path)
    except CommandNotFound as e:
        LOGGER.error(f"The flow of {cmd.path} could not be resolved. {e}")
        cmd_has_flow = None
    if cmd_has_flow:
        setup_flow_params(cmd)
        cmd.callback = get_flow_wrapper(cmd.name, cmd.callback)
        cmd.clk_flow_already_setup = True
    return cmd


def get_flow_commands_to_run(
    cmd_path, flow_from=None, flow_after=None, flow_truncation_safe=False
):
    torun = []

    def populate_torun(cmd_path):
        if "." in cmd_path:
            parent_path = ".".join(cmd_path.split(".")[:-1])
            deps = reversed(get_flow_commands_to_run(parent_path))
        else:
            deps = []
        if cmd_path.startswith("["):
            return
        # force the loading of cmd_path to fill flowdeps
        with temp_config():
            get_command(cmd_path)
        deps = list(reversed(flowdeps[cmd_path])) + list(deps)
        for dep in deps:
            torun.insert(0, dep)
            populate_torun(dep)

    populate_torun(cmd_path)
    torun = ordered_unique(torun)
    if "[STOP]" in torun:
        torun = torun[torun.index("[STOP]") + 1 :]
    if flow_from is not None:
        if flow_from in torun:
            torun = torun[torun.index(flow_from) :]
        else:
            assert flow_truncation_safe, (
                "Use flow_truncation_safe=True to allow flow_from when no part of the flow"
            )
    if flow_after is not None:
        if flow_after in torun:
            torun = torun[torun.index(flow_after) + 1 :]
        else:
            assert flow_truncation_safe, (
                "Use flow_truncation_safe=True to allow flow_after when no part of the flow"
            )
    return torun


def execute_flow_step(cmd, args=None):
    cmd.extend(args or [])
    if config.flow_verbose:
        # LOGGER.info('--------------')
        LOGGER.info(
            f"{'About to run' if config.flowstep else 'Running'} step '{' '.join(cmd)}'"
        )
    if config.flowstep:
        click.prompt(
            "Press Enter to start this step",
            default="",
            show_default=False,
        )
        if config.flow_verbose:
            LOGGER.info("Here we go!")
    old_allow = overloads.allow_dotted_commands
    overloads.allow_dotted_commands = True
    try:
        run(cmd)
    except Exception:
        overloads.allow_dotted_commands = old_allow
        raise
    if config.flow_verbose:
        LOGGER.debug("End of step '{}'".format(" ".join(cmd)))


def all_part(path):
    split = path.split(".")
    for i in range(len(split)):
        yield (
            ".".join(split[: i + 1]),
            split[i + 1 :],
        )


def execute_flow_dependencies(cmd, flow_from=None, flow_after=None):
    torun = get_flow_commands_to_run(cmd, flow_from=flow_from, flow_after=flow_after)
    for dep in torun:
        cmd = dep.split(".")
        execute_flow_step(cmd)


def has_flow(cmd):
    with temp_config():
        return get_flow_commands_to_run(cmd) != []


def build_show_flow_callback(cmd):
    def callback(ctx, param, value):
        if value and not ctx.resilient_parsing:
            run(["flowdep", "show", "--all", cmd])
            exit(0)

    return callback


def build_show_flowgraph_callback(cmd):
    def callback(ctx, param, value):
        if value and not ctx.resilient_parsing:
            run(["flowdep", "graph", cmd])
            exit(0)

    return callback


def get_flow_params(
    cmd, flow_default=None, flowfrom_default=None, flowafter_default=None
):
    deps = get_flow_commands_to_run(cmd)
    return [
        AutomaticOption(
            ["--flow/--no-flow"],
            group="flow",
            default=flow_default,
            help="Trigger the dependency flow ({})".format(", ".join(deps)),
        ),
        AutomaticOption(
            ["--flow-from"],
            group="flow",
            default=flowfrom_default,
            type=click.Choice(deps),
            help="Trigger the dependency flow from the given step"
            " (ignored if --flow-after is given)",
        ),
        AutomaticOption(
            ["--flow-after"],
            group="flow",
            default=flowafter_default,
            type=click.Choice(deps),
            help="Trigger the dependency flow after the given step (overrides --flow-from)",
        ),
        AutomaticOption(
            ["--show-flow"],
            group="flow",
            help="Show the flow toward this command instead of running it",
            expose_value=False,
            is_flag=True,
            callback=build_show_flow_callback(cmd),
        ),
        AutomaticOption(
            ["--show-flow-graph"],
            group="flow",
            help="Show the flow graph toward this command instead of running it",
            expose_value=False,
            is_flag=True,
            callback=build_show_flowgraph_callback(cmd),
        ),
    ]


_in_a_flow = False


def in_a_flow(ctx):
    return (
        _in_a_flow
        or ctx.params.get("flow")
        or ctx.params.get("flow_from")
        or ctx.params.get("flow_after")
    )


def get_flow_wrapper(name, function):
    def flow_wrapper(*args, **kwargs):
        flow = kwargs["flow"]
        del kwargs["flow"]
        flow_from = kwargs["flow_from"]
        del kwargs["flow_from"]
        flow_after = kwargs.pop("flow_after")
        ctx = click.get_current_context()
        flow = flow if flow is not None else config.autoflow
        global _in_a_flow
        if not _in_a_flow and (flow or flow_from or flow_after):
            # forward the parameter values the the other commands in the flow
            for param in ctx.command.params:
                if isinstance(param, FlowOption):
                    value = kwargs[param.target_parameter.name]
                    # don't forward anything if the option was not explicitly used
                    if value is not None:
                        if param.target_parameter.is_flag:
                            if value:
                                config.flow_profile.get_settings("parameters")[
                                    param.target_command.path
                                ].extend([param.target_parameter.opts[0]])
                            else:
                                config.flow_profile.get_settings("parameters")[
                                    param.target_command.path
                                ].extend([param.target_parameter.secondary_opts[0]])
                        elif param.target_parameter.multiple:
                            config.flow_profile.get_settings("parameters")[
                                param.target_command.path
                            ].extend(
                                flat_map(
                                    (param.target_parameter.opts[0], str(v))
                                    for v in value
                                )
                            )
                        else:
                            config.flow_profile.get_settings("parameters")[
                                param.target_command.path
                            ].extend([param.target_parameter.opts[0], str(value)])
                if isinstance(param, FlowArgument):
                    value = kwargs[param.target_parameter.name]
                    # don't forward anything if the option was not explicitly used
                    if value is not None:
                        if param.target_parameter.nargs == 1:
                            config.flow_profile.get_settings("parameters")[
                                param.target_command.path
                            ].append(str(value))
                        else:
                            config.flow_profile.get_settings("parameters")[
                                param.target_command.path
                            ].extend(str(v) for v in value)
            # run the flow
            _in_a_flow = True
            config.autoflow = False
            subpath = ctx.command.path
            execute_flow_dependencies(
                subpath, flow_from=flow_from, flow_after=flow_after
            )
            _in_a_flow = False
            # restore the flow settings
            config.flow_profile.get_settings("parameters").clear()
            if config.flow_verbose:
                LOGGER.debug(
                    f"Ended executing the flow dependencies, back to the command '{name}'"
                )
        res = function(*args, **kwargs)
        return res

    return flow_wrapper


class flowdepends:
    def __init__(self, depends, name=None):
        self.depends = depends
        self.name = name

    def __call__(self, function):
        flowdeps[self.name or function.__name__].extend(self.depends)
        function.clk_flowdepends = self.depends
        return function


def setup():
    get_command_handlers[get_command_handler] = True
