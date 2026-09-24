#!/usr/bin/env python3

import json
from pathlib import Path

import click

from clk.config import config
from clk.decorators import argument, flag, group, option


def ranges(lines):
    """Say 3, 4, 5, 9 as 3-5, 9"""
    result = []
    for line in sorted(lines):
        if result and result[-1][1] == line - 1:
            result[-1][1] = line
        else:
            result.append([line, line])
    return ", ".join(str(a) if a == b else f"{a}-{b}" for a, b in result)


@group()
def coverage():
    "Read the coverage the last clk test run left behind"


@coverage.command()
@option(
    "--contexts-file",
    default="project:output/coverage-contexts.json",
    help="The coverage json that clk test saved",
)
@flag("--show-code", help="Print each missing line with its code")
@argument(
    "patterns",
    nargs=-1,
    required=True,
    help="Parts of the paths of the files to look at",
)
def missing(contexts_file, show_code, patterns):
    "Tell which lines of the files matching the patterns no test ran"
    project = Path(config.project)
    data = json.loads(Path(contexts_file).read_text())
    for name, info in sorted(data["files"].items()):
        if not any(pattern in name for pattern in patterns):
            continue
        lines = info["missing_lines"]
        # the test runs in a container where the project is in /app
        local = project / name.removeprefix("/app/")
        click.echo(f"{local.relative_to(project)}: {ranges(lines) or 'fully covered'}")
        if show_code and lines and local.exists():
            source = local.read_text().splitlines()
            for line in lines:
                click.echo(f"  {line}: {source[line - 1]}")
