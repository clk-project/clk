#!/bin/bash -eu
# [[file:../../doc/use_cases/using_a_plugin.org::#listing-triggers-name-only][listing triggers with --name-only:3]]
. ./sandboxing.sh

mkdir -p "${CLKCONFIGDIR}/plugins"
cat <<'PLUGIN_EOF' > "${CLKCONFIGDIR}/plugins/trigger.py"
#!/usr/bin/env python3
# -*- coding:utf-8 -*-
"""Trigger plugin - run commands before/after other commands.

This plugin allows you to trigger the execution of commands around other commands.
It supports four trigger positions:
- pre: Run before the command
- post: Run after the command (always, even on error)
- success: Run only after successful execution
- error: Run only when the command fails

Example usage:
    # Run 'echo hello' before every 'mycommand' execution
    clk trigger set pre mycommand echo hello

    # Run cleanup after successful execution
    clk trigger set success build cleanup

This file serves as an example of how to create a clk plugin that:
1. Injects behavior into command execution via monkey-patching
2. Registers new commands with the CLI
3. Uses the settings system for persistence

To install this plugin, copy it to ~/.clk/plugins/clk_trigger.py
"""

import re

import click

from clk.colors import Colorer
from clk.config import config
from clk.core import run
from clk.decorators import argument, flag, group, use_settings
from clk.lib import echo_key_value, quote
from clk.log import get_logger
from clk.overloads import (
    Command,
    CommandSettingsKeyType,
    CommandType,
    Group,
    MainCommand,
)

LOGGER = get_logger(__name__)


# ---------------------------------------------------------------------------
# Trigger execution logic
# ---------------------------------------------------------------------------


def run_triggers(name, path, commands):
    """Execute a list of trigger commands."""
    if commands:
        LOGGER.debug(f"Running the {name} trigger for {path}")
    for command in commands:
        if isinstance(command, type(lambda x: x)):
            command()
        else:
            run(command)


def trigger_invoke_wrapper(original_invoke):
    """Create a wrapped invoke method that runs triggers around the original."""

    def invoke_with_triggers(self, *args, **kwargs):
        trigger = config.settings2.get("triggers", {}).get(self.path, {})
        pre = trigger.get("pre", [])
        post = trigger.get("post", [])
        success = trigger.get("success", [])
        error = trigger.get("error", [])
        run_triggers("pre", self.path, pre)
        try:
            res = original_invoke(self, *args, **kwargs)
        except:  # NOQA: E722
            run_triggers("error", self.path, error)
            run_triggers("post", self.path, post)
            raise
        run_triggers("success", self.path, success)
        run_triggers("post", self.path, post)
        return res

    return invoke_with_triggers


# ---------------------------------------------------------------------------
# CLI Commands for trigger management
# ---------------------------------------------------------------------------


def format_trigger(cmds):
    """Format the trigger command for display."""
    return " , ".join(" ".join(quote(arg) for arg in cmd) for cmd in cmds)


class TriggersConfig:
    pass


@group()
@use_settings("triggers", TriggersConfig, override=False)
def trigger():
    """Manipulate command triggers.

    Triggers allow you to automatically run commands before or after other commands.
    This is useful for working around issues in tools or adding consistent behaviors.

    To run command B before command A:

        clk trigger set pre A B

    To run command B only after successful execution of A:

        clk trigger set success A B
    """
    pass


@trigger.command(
    ignore_unknown_options=True, change_directory_options=False, handle_dry_run=True
)
@argument(
    "position",
    type=click.Choice(["pre", "post", "error", "success"]),
    help="The trigger position",
)
@argument(
    "cmd",
    type=CommandType(),
    help="The command to which the trigger is associated",
)
@argument("triggered-command", type=CommandType(), help="The command to trigger")
@argument("params", nargs=-1, help="The parameters passed to the triggered command")
def set(cmd, triggered_command, params, position):
    """Set a trigger."""
    if cmd.startswith("-"):
        raise click.UsageError("Triggers must not start with dashes (-)")
    if re.match(r"^\w", cmd) is None:
        raise click.ClickException("Invalid trigger name: " + cmd)
    commands = []
    text = [triggered_command] + list(params)
    sep = ","
    while sep in text:
        index = text.index(sep)
        commands.append(text[:index])
        del text[: index + 1]
    if text:
        commands.append(text)
    if cmd in config.triggers.writable:
        config.triggers.writable[cmd][position] = commands
    else:
        config.triggers.writable[cmd] = {position: commands}
    config.triggers.write()


@trigger.command(handle_dry_run=True)
@argument(
    "position",
    type=click.Choice(["pre", "post", "error", "success"]),
    help="The trigger position",
)
@argument(
    "cmds",
    nargs=-1,
    type=CommandSettingsKeyType("triggers"),
    help="The commands where the triggers will be unset",
)
def unset(cmds, position):
    """Unset some triggers."""
    for cmd in cmds:
        if cmd not in config.triggers.writable:
            raise click.ClickException(
                f"The {config.triggers.writeprofile} configuration has no '{cmd}' triggers registered. "
                "Try using another profile option (like --local or --global)"
            )
    for cmd in cmds:
        LOGGER.status(
            f"Erasing {cmd} triggers from {config.triggers.writeprofile} settings"
        )
        del config.triggers.writable[cmd]
    config.triggers.write()


@trigger.command(handle_dry_run=True)
@flag(
    "--name-only/--no-name-only",
    help="Only display the trigger names",
)
@Colorer.color_options
@argument(
    "position",
    type=click.Choice(["pre", "post", "error", "success"]),
    help="The trigger position",
)
@argument(
    "triggers",
    nargs=-1,
    type=CommandSettingsKeyType("triggers"),
    help="The commands to show",
)
def show(name_only, triggers, position, **kwargs):
    """Show the triggers."""
    show_triggers = triggers or sorted(config.triggers.readonly.keys())
    with Colorer(kwargs) as colorer:
        for triggers_ in show_triggers:
            if name_only:
                click.echo(triggers_)
            else:
                values = {
                    profile.name: format_trigger(
                        config.triggers.all_settings[profile.name]
                        .get(triggers_, {})
                        .get(position, [])
                    )
                    for profile in config.all_enabled_profiles
                }
                args = colorer.colorize(values, config.triggers.readprofile)
                echo_key_value(triggers_, " , ".join(args), config.alt_style)

# ---------------------------------------------------------------------------
# Plugin entry point
# ---------------------------------------------------------------------------


def load_plugin():
    """Initialize the trigger plugin.

    This function is called by clk when the plugin is loaded.
    It monkey-patches the Command, Group, and MainCommand classes
    to inject trigger execution around command invocation.
    """
    # Wrap the invoke methods of Command, Group, and MainCommand
    # to add trigger execution
    Command.invoke = trigger_invoke_wrapper(Command.invoke)
    Group.invoke = trigger_invoke_wrapper(Group.invoke)
    MainCommand.invoke = trigger_invoke_wrapper(MainCommand.invoke)

    # Register the trigger command group with the main command
    config.main_command.add_command(trigger)

    LOGGER.develop("Trigger plugin loaded")
PLUGIN_EOF


verify_plugin_code () {
      clk trigger --help | head -15
}

verify_plugin_expected () {
      cat<<"EOEXPECTED"
Usage: clk trigger [OPTIONS] COMMAND [ARGS]...

  Manipulate command triggers.

  Triggers allow you to automatically run commands before or after other commands. This is useful for working around
  issues in tools or adding consistent behaviors.

  To run command B before command A:

      clk trigger set pre A B

  To run command B only after successful execution of A:

      clk trigger set success A B

EOEXPECTED
}

echo 'Run verify_plugin'

{ verify_plugin_code || true ; } > "${TMP}/code.txt" 2>&1
verify_plugin_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying verify_plugin"
exit 1
}


clk alias set mycommand echo 'main command'

clk trigger set pre mycommand echo hello


show_trigger_code () {
      clk trigger show --no-color pre mycommand
}

show_trigger_expected () {
      cat<<"EOEXPECTED"
mycommand echo hello
EOEXPECTED
}

echo 'Run show_trigger'

{ show_trigger_code || true ; } > "${TMP}/code.txt" 2>&1
show_trigger_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show_trigger"
exit 1
}



run_with_pre_trigger_code () {
      clk mycommand
}

run_with_pre_trigger_expected () {
      cat<<"EOEXPECTED"
hello
main command
EOEXPECTED
}

echo 'Run run_with_pre_trigger'

{ run_with_pre_trigger_code || true ; } > "${TMP}/code.txt" 2>&1
run_with_pre_trigger_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_with_pre_trigger"
exit 1
}


clk alias set buildcmd echo 'build complete'
clk trigger set success buildcmd echo 'after success'


run_with_success_trigger_code () {
      clk buildcmd
}

run_with_success_trigger_expected () {
      cat<<"EOEXPECTED"
build complete
after success
EOEXPECTED
}

echo 'Run run_with_success_trigger'

{ run_with_success_trigger_code || true ; } > "${TMP}/code.txt" 2>&1
run_with_success_trigger_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_with_success_trigger"
exit 1
}


clk trigger unset pre mycommand


run_after_unset_code () {
      clk mycommand
}

run_after_unset_expected () {
      cat<<"EOEXPECTED"
main command
EOEXPECTED
}

echo 'Run run_after_unset'

{ run_after_unset_code || true ; } > "${TMP}/code.txt" 2>&1
run_after_unset_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_after_unset"
exit 1
}


clk alias set cmd1 echo 'one'
clk alias set cmd2 echo 'two'
clk trigger set pre cmd1 echo 'trigger1'
clk trigger set pre cmd2 echo 'trigger2'


show_name_only_code () {
      clk trigger show pre --name-only
}

show_name_only_expected () {
      cat<<"EOEXPECTED"
buildcmd
cmd1
cmd2
EOEXPECTED
}

echo 'Run show_name_only'

{ show_name_only_code || true ; } > "${TMP}/code.txt" 2>&1
show_name_only_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show_name_only"
exit 1
}
# listing triggers with --name-only:3 ends here
