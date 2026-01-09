#!/usr/bin/env python3

from clk.alias import AliasCommandResolver
from clk.commandresolver import CommandResolver
from clk.customcommands import CustomCommandResolver
from clk.externalcommands import ExternalCommandResolver
from clk.overloads import group


class IntermediateEphemeralGroupResolver(CommandResolver):
    name = "ephemeral group"

    def __init__(self):
        self.resolvers = [
            CustomCommandResolver(),
            ExternalCommandResolver(),
            AliasCommandResolver(),
        ]

    def choices(self, parent):
        return sum(
            [resolver._list_command_paths(parent) for resolver in self.resolvers], []
        )

    def _list_command_paths(self, parent):
        choices = self.choices(parent)
        if parent.path == "clk":
            return {choice.split(".")[0] for choice in choices}
        else:
            return {
                ".".join(choice.split(".")[: len(parent.path.split(".")) + 1])
                for choice in choices
                if choice.startswith(parent.path)
                and "." in choice[len(parent.path) + 1 :]
            }

    def _get_command(self, path, parent):
        return group(
            name=path.split(".")[-1],
            help=("Automatically created group to organize subcommands"),
        )(lambda: None)

    def add_edition_hint(self, ctx, command, formatter):
        formatter.write_paragraph()
        with formatter.indentation():
            formatter.write_text(
                "This is a built in created group. To remove it, simply remove"
                " all its subcommands (with `clk command remove SUBCMD`, or `clk alias unset SUBCMD`). To"
                " rename it, simply rename them (with `clk command rename SUBCMD` or `clk alias rename SUBCMD`)"
            )
