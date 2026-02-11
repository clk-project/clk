- [installing a plugin](#installing-a-plugin)
- [the trigger plugin code](#the-trigger-plugin-code)
- [using triggers](#using-triggers)
  - [setting and showing a trigger](#setting-and-showing-a-trigger)
  - [pre-trigger execution](#pre-trigger-execution)
  - [success triggers](#success-triggers)
  - [unsetting a trigger](#unsetting-a-trigger)
  - [listing triggers with &#x2013;name-only](#listing-triggers-name-only)

In the past, clk contained a command used to add hooks before and after other commands. This was highly advanced stuff and eventually was barely used. It was removed from clk. But, with the plugin mechanism, you actually can put this feature back into clk.


<a id="installing-a-plugin"></a>

# installing a plugin

To install a plugin in clk, you need to place the plugin file in the `plugins` directory of your clk configuration folder. By default, this is `~/.config/clk/plugins/`.

For example, to install the trigger plugin shown below, you would:

1.  Create the plugins directory if it doesn't exist:

```bash
mkdir -p ~/.config/clk/plugins
```

1.  Copy or create the plugin file:

```bash
cp myplugin.py ~/.config/clk/plugins/
```

The plugin will be automatically loaded the next time you run clk.

Note that plugins must have a `load_plugin()` function that will be called when clk loads them. This function is responsible for initializing the plugin, registering commands, and performing any necessary setup.

Let's test this with the trigger plugin.


<a id="the-trigger-plugin-code"></a>

# the trigger plugin code

Let's first take a look at the whole plugin, then we will take a deeper look at it.

```python
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
```

Once copied in the plugin directory, you should be able to use the injected command like any other.

```bash
clk trigger --help | head -15
```

```
Usage: clk trigger [OPTIONS] COMMAND [ARGS]...

  Manipulate command triggers.

  Triggers allow you to automatically run commands before or after other commands. This is useful for working around
  issues in tools or adding consistent behaviors.

  To run command B before command A:

      clk trigger set pre A B

  To run command B only after successful execution of A:

      clk trigger set success A B
```


<a id="using-triggers"></a>

# using triggers

Now that the plugin is installed, let's explore how to use triggers effectively. Triggers allow you to automatically run commands before or after other commands, which is useful for adding consistent behaviors or working around issues in tools.


<a id="setting-and-showing-a-trigger"></a>

## setting and showing a trigger

Let's start by creating a simple command and setting a pre-trigger on it. First, we'll create an alias that we can attach a trigger to:

```bash
clk alias set mycommand echo 'main command'
```

Now let's set a pre-trigger that will run before `mycommand`:

```bash
clk trigger set pre mycommand echo hello
```

We can verify that the trigger was set by showing it:

```bash
clk trigger show --no-color pre mycommand
```

    mycommand echo hello


<a id="pre-trigger-execution"></a>

## pre-trigger execution

When we run `mycommand`, the pre-trigger executes first, followed by the main command:

```bash
clk mycommand
```

    hello
    main command

As you can see, "hello" appears before "main command", demonstrating that the pre-trigger runs before the actual command.


<a id="success-triggers"></a>

## success triggers

You can also set triggers that only run after a command succeeds. Let's create a new command and add a success trigger:

```bash
clk alias set buildcmd echo 'build complete'
clk trigger set success buildcmd echo 'after success'
```

```bash
clk buildcmd
```

    build complete
    after success


<a id="unsetting-a-trigger"></a>

## unsetting a trigger

To remove a trigger, use the `unset` command:

```bash
clk trigger unset pre mycommand
```

After unsetting, only the main command runs:

```bash
clk mycommand
```

    main command


<a id="listing-triggers-name-only"></a>

## listing triggers with &#x2013;name-only

When you have many triggers, you can list just the command names that have triggers:

```bash
clk alias set cmd1 echo 'one'
clk alias set cmd2 echo 'two'
clk trigger set pre cmd1 echo 'trigger1'
clk trigger set pre cmd2 echo 'trigger2'
```

```bash
clk trigger show pre --name-only
```

    buildcmd
    cmd1
    cmd2
