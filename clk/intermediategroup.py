#!/usr/bin/env python3

from clk.alias import AliasCommandResolver
from clk.commandresolver import CommandResolver
from clk.customcommands import CustomCommandResolver
from clk.externalcommands import ExternalCommandResolver
from clk.overloads import group


class IntermediateEphemeralGroupResolver(CommandResolver):
    name = "ephemeral group"
    deferred = True  # Run after all profiles checked for real commands

    def __init__(self):
        self.resolvers = [
            CustomCommandResolver(),
            ExternalCommandResolver(),
            AliasCommandResolver(),
        ]

    def choices(self, parent, profile):
        return sum(
            [
                resolver._list_command_paths(parent, profile)
                for resolver in self.resolvers
            ],
            [],
        )

    def _get_direct_commands(self, parent, profile):
        """Get direct (non-nested) commands for this profile.

        Note: Cross-profile shadowing is handled by the resolver ordering -
        this resolver is deferred, so real commands in ANY profile are found
        before this resolver runs.
        """
        direct = set()
        for resolver in self.resolvers:
            for cmd in resolver._list_command_paths(parent, profile):
                if parent.path == "clk":
                    if "." not in cmd:
                        direct.add(cmd)
                else:
                    if not cmd.startswith(parent.path + "."):
                        continue
                    suffix = cmd[len(parent.path) + 1 :]
                    if "." not in suffix:
                        direct.add(suffix)
        return direct

    def _list_command_paths(self, parent, profile):
        choices = self.choices(parent, profile)
        direct_commands = self._get_direct_commands(parent, profile)

        if parent.path == "clk":
            intermediate = {choice.split(".")[0] for choice in choices if "." in choice}
            return intermediate - direct_commands
        else:
            intermediate = set()
            for choice in choices:
                if choice.startswith(parent.path + "."):
                    suffix = choice[len(parent.path) + 1 :]
                    if "." in suffix:
                        intermediate.add(parent.path + "." + suffix.split(".")[0])
            return {
                cmd for cmd in intermediate if cmd.split(".")[-1] not in direct_commands
            }

    def _get_command(self, path, parent, profile):
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
