#!/usr/bin/env python

import os
import subprocess
import tempfile
import webbrowser
from collections import defaultdict
from shlex import join as shlexjoin

import click

from clk.colors import Colorer
from clk.config import config
from clk.core import get_ctx
from clk.decorators import (
    argument,
    flag,
    group,
    option,
    pass_context,
    table_fields,
    table_format,
    use_settings,
)
from clk.flow import flowdeps as _flowdeps
from clk.flow import get_flow_commands_to_run
from clk.lib import TablePrinter, quote, which
from clk.log import get_logger
from clk.overloads import CommandSettingsKeyType, CommandType, iter_commands

LOGGER = get_logger(__name__)


class FlowdepsConfig:
    pass


@group(default_command="show")
@use_settings("flowdeps", FlowdepsConfig)
def flowdep():
    """Manipulate command flow dependencies.

    It is mostly useful if you want to run a flow and still add a custom command
    inside the flow.

    Say you want to run the command dosomething in between configure and build
    in the flow, you simply issue the command 'flowdep set build
    dosomething configure'. This indicates that the flow to build will issue
    first dosomething and then configure.

    If you feel lost about what commands will be run in a flow, for instance the
    flow to the command ipython, run the command 'flowdep show --all
    ipython'. This will show you all the command that would be run with the
    command 'ipython --flow'.

    This would cause the command dosomething to be run between configure and
    build.

    """
    pass


class FlowDependencies(CommandType):
    def convert(self, value, param, ctx):
        if value == "[self]":
            return value
        else:
            return super().convert(value, param, ctx)


@flowdep.command(handle_dry_run=True)
@argument(
    "cmd", type=CommandType(), help="The command to which set the flow dependencies"
)
@argument(
    "dependencies",
    nargs=-1,
    type=FlowDependencies(),
    help=(
        "The flow dependencies (use [self] to capture the one on the initial command)"
    ),
)
def _set(cmd, dependencies):
    """Set the flow dependencies of a command"""
    if cmd in config.flowdeps.writable:
        LOGGER.info(
            "Removing old {} flowdep for {}: {}".format(
                Colorer.apply_color_profilename(config.flowdeps.writeprofilename),
                cmd,
                ", ".join(config.flowdeps.writable[cmd]),
            )
        )

    config.flowdeps.writable[cmd] = dependencies
    LOGGER.info(
        "New {} flowdep for {}: {}".format(
            Colorer.apply_color_profilename(config.flowdeps.writeprofilename),
            cmd,
            ", ".join(dependencies),
        )
    )
    config.flowdeps.write()


@flowdep.command(ignore_unknown_options=True, handle_dry_run=True)
@argument(
    "cmd", type=CommandType(), help="The command to which append the flow dependencies"
)
@argument(
    "dependencies",
    nargs=-1,
    type=CommandType(),
    help="The additional flow dependencies",
)
def append(cmd, dependencies):
    """Add a flow dependency after the flowdep of a command"""
    dependencies = config.flowdeps.writable.get(cmd, []) + list(dependencies)
    config.flowdeps.writable[cmd] = dependencies
    config.flowdeps.write()


@flowdep.command(handle_dry_run=True)
@argument(
    "cmd",
    type=CommandSettingsKeyType("flowdeps"),
    help="The command to which insert the flow dependencies",
)
@argument(
    "dependencies",
    type=CommandType(),
    nargs=-1,
    help="The additional flow dependencies",
)
def insert(cmd, dependencies):
    """Add a flow dependency before the flowdep of a command"""
    dependencies = list(dependencies) + config.flowdeps.readonly.get(cmd, [])
    config.flowdeps.writable[cmd] = dependencies
    config.flowdeps.write()


@flowdep.command(handle_dry_run=True)
@argument(
    "cmd",
    type=CommandSettingsKeyType("flowdeps"),
    help="The command to which remove the flow dependencies",
)
@argument(
    "dependencies",
    type=CommandType(),
    nargs=-1,
    help="The flow flow dependencies to remove",
)
def remove(cmd, dependencies):
    """Remove some flow dependencies of a command"""
    for param in dependencies:
        try:
            config.flowdeps.writable[cmd].remove(param)
        except ValueError:
            raise click.ClickException(f"{param} is not in the flowdeps of {cmd}")
    config.flowdeps.write()


@flowdep.command(handle_dry_run=True)
@argument(
    "cmds",
    nargs=-1,
    type=CommandSettingsKeyType("flowdeps"),
    help="The command to which unset the flow dependencies",
)
def unset(cmds):
    """Unset the flow dependencies of a command"""
    for cmd in cmds:
        if cmd not in config.flowdeps.writable:
            raise click.ClickException(
                "The "
                f"{Colorer.apply_color_profilename(config.flowdeps.writeprofilename)}"
                f" configuration has no '{cmd}' flow dependency registered."
                "Try using another profile option (like --local, --global)"
            )
    for cmd in cmds:
        LOGGER.info(
            f"Erasing {cmd} flow dependencies from {Colorer.apply_color_profilename(config.flowdeps.writeprofilename)} settings"
        )
        del config.flowdeps.writable[cmd]
    config.flowdeps.write()


@flowdep.command(handle_dry_run=True)
@flag("--name-only/--no-name-only", help="Only display the command names")
@flag("--all", help="Show all the flowdeps, even those guessed from the context")
@Colorer.color_options
@table_format(default="key_value")
@table_fields(choices=["command", "dependencies"])
@argument("cmds", nargs=-1, type=CommandType(), help="The commands to show")
@pass_context
def show(ctx, name_only, cmds, all, fields, format, **kwargs):
    """Show the flow dependencies of a command"""
    show_empty = len(cmds) > 0
    if all:
        cmds = cmds or sorted(get_sub_commands(ctx, config.main_command))
    else:
        cmds = cmds or sorted(config.flowdeps.readonly.keys())
    with TablePrinter(fields, format) as tp, Colorer(kwargs) as colorer:
        for cmd in cmds:
            if name_only:
                click.echo(cmd)
            else:
                if all:
                    deps = get_flow_commands_to_run(cmd)
                    formatted = " ".join(quote(p) for p in deps)
                else:
                    values = {
                        profile.name: " ".join(
                            [
                                quote(p)
                                for p in config.flowdeps.all_settings.get(
                                    profile.name, {}
                                ).get(cmd, [])
                            ]
                        )
                        for profile in config.all_enabled_profiles
                    }
                    args = colorer.colorize(values, config.flowdeps.readprofile)
                    formatted = " ".join(args)
                if show_empty:
                    formatted = formatted or "None"
                if formatted:
                    tp.echo(cmd, formatted)


def compute_dot(
    cmds=None,
    strict=False,
    cluster=True,
    left_right=False,
    lonely=False,
    display_aliases=False,
    display_parameters=False,
    alias_links=False,
):
    import networkx

    g = networkx.digraph.DiGraph()

    def cluster_replace(str):
        return str.replace(".", "_").replace("-", "_")

    dot = """digraph {\n"""
    if left_right:
        dot += """  rankdir = LR;\n"""
    clusters = defaultdict(set)

    def register_cluster(cmd_path):
        if "." in cmd_path:
            parent_path = ".".join([part for part in cmd_path.split(".")[:-1]])
            clusters[parent_path].add(cmd_path)

    aliases = {}

    def fill_graph(cmds):
        for cmd in iter_commands(from_paths=cmds):
            if hasattr(cmd, "commands_to_run"):
                aliases[cmd.path] = cmd.commands_to_run
            LOGGER.develop(f"Looking at {cmd.path}")
            if strict:
                deps = config.flowdeps.readonly.get(cmd.path, [])
            else:
                path = cmd.path
                deps = list(_flowdeps[path])
                while "." in path:
                    path = ".".join(path.split(".")[:-1])
                    deps += _flowdeps[path]
            for dep in deps:
                g.add_node(dep)
                g.add_node(cmd.path)
                try:
                    networkx.shortest_path(g, dep, cmd.path)
                except networkx.NetworkXNoPath:
                    pass
                else:
                    continue
                g.add_edge(dep, cmd.path)
                register_cluster(dep)
                register_cluster(cmd.path)
                if not dep.startswith("["):
                    fill_graph([dep])
            if lonely:
                g.add_node(cmd.path)
            register_cluster(cmd.path)

    fill_graph(cmds)
    nodes = g.nodes()
    adjacency = g.edges()
    if not adjacency:
        return None
    if cluster:
        for parent_path, cmds in clusters.items():
            if lonely or len(cmds.intersection(nodes)) > 1:
                dot += f"""  subgraph cluster_{cluster_replace(parent_path)} {{\n"""
                dot += f"""    label="{parent_path}";\n"""
                for cmd in cmds:
                    if (lonely or cmd in nodes) and cmd not in clusters.keys():
                        dot += f"""    "{cmd}";\n"""
                dot += "  }\n"
    for node in nodes:
        if node not in clusters.keys():
            dot += """  "{}" [label= "{}{}{}", fillcolor = {}, style = filled];\n""".format(
                node,
                node,
                "\n -> {}".format(
                    " , ".join(
                        " ".join(quote(arg) for arg in cmd) for cmd in aliases[node]
                    )
                )
                if (display_aliases and node in aliases)
                else "",
                "\n : {}".format(shlexjoin(config.settings["parameters"].get(node, [])))
                if (display_parameters and config.settings["parameters"].get(node))
                else "",
                "greenyellow" if (display_aliases and node in aliases) else "skyblue",
            )
    if alias_links:
        for source, destination in aliases.items():
            destination_context = get_ctx(
                destination[-1], side_effects=False, resilient_parsing=True
            )
            label = 'label="{}", '.format(
                " , ".join(" ".join(quote(arg) for arg in cmd) for cmd in destination)
            )
            dot += f"""  "{source}" -> "{destination_context.command.path}" [{label}style=dashed, color=grey]
"""
    source_order = defaultdict(int)
    for src, dst in adjacency:
        source_order[dst] = source_order[dst] + 1
        dot += f"""  "{src}" -> "{dst}" [headlabel="{source_order[dst]}"];\n"""
    dot += "}"
    LOGGER.develop(dot)
    return dot


@flowdep.command()
@option(
    "--output",
    help="Output file instead of showing it in a web browser - not relevant with format x11",
)
@option(
    "--format",
    type=click.Choice(["png", "svg", "x11", "pdf", "dot"]),
    help="Format to use",
    default="svg",
)
@flag(
    "--strict/--all",
    help="Show the all dependency graph or only the explicitly configured flowdep",
)
@flag(
    "--display-aliases/--hide-aliases",
    help="Show the details of the aliases instead of making them look like other nodes",
)
@flag("--alias-links/--no-alias-link", help="Show a link when there are aliases")
@flag(
    "--display-parameters/--hide-parameters",
    help="Show the details of the parameters as well",
)
@flag("--left-right/--top-bottom", help="Show from left to right")
@flag(
    "--lonely/--no-lonely",
    help="Show lonely nodes also (it generally pollutes unnecessarily the graph)",
)
@flag(
    "--cluster/--independent",
    help="Show all commands independently or cluster groups",
    default=True,
)
@argument("cmds", nargs=-1, type=CommandType(), help="The commands to display")
def graph(
    output,
    format,
    cmds,
    display_aliases,
    alias_links,
    display_parameters,
    strict,
    cluster,
    left_right,
    lonely,
):
    """Display the flow dependencies as a graph"""
    dot = compute_dot(
        cmds=cmds,
        strict=strict,
        cluster=cluster,
        left_right=left_right,
        lonely=lonely,
        display_aliases=display_aliases,
        display_parameters=display_parameters,
        alias_links=alias_links,
    )
    if dot is None:
        LOGGER.info("Nothing to show")
        exit(0)
    if format != "dot":
        dotpath = which("dot")
        if dotpath is None:
            raise click.UsageError(
                "You don't have graphviz installed."
                " Therefore you cannot use this command."
                " Hint: sudo apt install graphviz"
            )
        args = [dotpath, f"-T{format}"]
        p = subprocess.Popen(
            args,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
        )
        out, _ = p.communicate(dot.encode("utf-8"))
    else:
        out = dot.encode("utf-8")
    if output == "-":
        click.echo(out)
    elif output:
        open(output, "wb").write(out)
    elif format not in ["x11"]:
        path = os.path.join(tempfile.gettempdir(), f"flow.{format}")
        with open(path, "wb") as f:
            f.write(out)
        webbrowser.open("file://" + path)


def get_sub_commands(ctx, cmd, prefix=""):
    res = []
    for sub_cmd_name in cmd.list_commands(ctx):
        res.append(prefix + sub_cmd_name)
        sub_cmd = cmd.get_command(ctx, sub_cmd_name)
        if sub_cmd:
            if isinstance(sub_cmd, click.Group):
                if not hasattr(sub_cmd, "original_command"):
                    res += get_sub_commands(
                        ctx, sub_cmd, prefix=f"{prefix}{sub_cmd_name}."
                    )
        else:
            LOGGER.warn("Can't get " + sub_cmd_name)
    return res
