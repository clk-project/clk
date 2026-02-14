- [the problem with parameters](#the-problem-with-parameters)
- [values: semantic configuration](#values-semantic-configuration)
- [other shared values](#other-shared-values)
- [you can still override](#override-values)
- [per-option defaults with default.](#per-option-defaults)
- [syntax vs semantics: choosing the right tool](#syntax-vs-semantics)
- [using values in your own commands](#using-values-in-commands)
- [a familiar pattern: git config](#git-comparison)

Parameters are a powerful way to persist options for specific commands (see [the cloud provider CLI wrapper example](wrapping_a_cloud_provider_cli.md)). But sometimes, you want to set the same kind of option across many different commands. That's where the `value` command shines.


<a id="the-problem-with-parameters"></a>

# the problem with parameters

Many built-in clk commands display information with colors. For example, `alias show`, `parameter show`, `value show`, `extension show`, and `command show` all have a `--color/--no-color` option.

If you want to disable colors everywhere (maybe you're piping to a file or your terminal doesn't support them), you could use parameters:

```bash
clk parameter set alias.show --no-color
clk parameter set parameter.show --no-color
clk parameter set value.show --no-color
clk parameter set extension.show --no-color
```

    New global parameters for alias.show: --no-color
    New global parameters for parameter.show: --no-color
    New global parameters for value.show: --no-color
    New global parameters for extension.show: --no-color

This works, but it's tedious. You have to remember every command that has a `--color` option. And when a new command is added, you need to set its parameter too. Parameters work at the **syntactic** level: you're saying "for this specific command, add these specific flags".


<a id="values-semantic-configuration"></a>

# values: semantic configuration

The `value` command provides a different approach. Instead of configuring each command's syntax, you configure the **meaning** of an option across all commands that care about it.

First, let's clean up those parameters:

```bash
clk parameter unset alias.show
clk parameter unset parameter.show
clk parameter unset value.show
clk parameter unset extension.show
```

Now, here's the magic: all the built-in "show" commands read their color default from a single value called `config.show.color`. Set it once, and it applies everywhere:

```bash
clk value set config.show.color false
```

Let's create an alias and some parameters to see this in action:

```bash
clk alias set hello echo Hello
clk parameter set hello --some-option
```

Now all show commands respect this setting. We can verify by checking the help to see that color defaults to false:

```bash
clk alias show --help 2>&1 | grep -- "--color"
```

    --color / --no-color            Show profiles in color  [default: false]

The default is now `false` instead of `True`. This applies to all show commands with a single configuration.


<a id="other-shared-values"></a>

# other shared values

The same pattern applies to other display options. The built-in show commands also share:

-   `config.show.legend`: whether to display a color legend at the bottom
-   `config.show.full`: whether to show all profiles or only explicit ones

```bash
clk value set config.show.legend false
clk value show
```

    config.show.color false
    config.show.legend false


<a id="override-values"></a>

# you can still override

The value just sets the default. You can always override it on the command line.

Even though the default is false, passing `--color` on the command line will enable colors for a specific invocation.


<a id="per-option-defaults"></a>

# per-option defaults with default.

The `config.show.*` values are special because the built-in commands explicitly read them. But you can also set defaults for any option using the `default.<command>.<option>` pattern:

```bash
clk value set default.alias.show.format plain
clk alias show --help 2>&1 | grep -A1 -- "--format" | tail -1 | sed -r 's|^.+(default: [a-zA-Z-]+).+$|\1|'
```

    default: plain

When an option's default comes from a value, clk tells you in the help output.


<a id="syntax-vs-semantics"></a>

# syntax vs semantics: choosing the right tool

Both `parameter` and `value` let you configure defaults, but they work at different levels:

| Feature  | parameter                 | value                             |
|-------- |------------------------- |--------------------------------- |
| Scope    | One specific command      | All commands reading that value   |
| Level    | Syntactic (raw flags)     | Semantic (option meaning)         |
| Use case | "Always pass these flags" | "This option should default to X" |
| Override | Prepended to command line | Becomes the option's default      |

Use `parameter` when you want to configure a whole command's behavior with multiple related options. Use `value` when you want to set a default that applies across many commands sharing the same concept (like "show colors").


<a id="using-values-in-commands"></a>

# using values in your own commands

You can use the same pattern in your own Python commands. Here's an example of a command that reads from `config.show.color`, just like the built-in commands do:

```python
import click

from clk.decorators import command, option
from clk.config import config


@command()
@option(
    "--color/--no-color",
    default=config.get_value("config.show.color", True),
    help="Show output in color",
)
def show_items(color):
    "Display some items"
    items = ["apple", "banana", "cherry"]
    for item in items:
        if color:
            click.secho(item, fg="green")
        else:
            click.echo(item)
```

The key is using `config.get_value("config.show.color", True)` as the default. The second argument (`True`) is the fallback if the value is not set.

Now this command shares the same color setting as all the built-in show commands:

```bash
clk show-items --help 2>&1 | grep -- "--color"
```

    --color / --no-color  Show output in color  [default: false]

Because we set `config.show.color` to `false` earlier, this new command also defaults to no color.

Now let's change the value back to `true` and see how it affects all commands:

```bash
clk value set config.show.color true
clk show-items --help 2>&1 | grep -- "--color"
clk alias show --help 2>&1 | grep -- "--color"
```

    --color / --no-color  Show output in color  [default: true]
    --color / --no-color            Show profiles in color  [default: true]

One value controls them all.


<a id="git-comparison"></a>

# a familiar pattern: git config

If you've used git, this pattern might feel familiar. Git has `git config` which lets you set defaults that affect many commands:

```bash
# Git's approach
git config --global user.name "Your Name"
git config --global core.editor vim
git config --global color.ui false
```

Similarly, clk uses `clk value` to configure defaults:

```bash
# clk's approach
clk value set config.show.color false
clk value set config.show.legend false
```

Both tools recognize that some settings are too pervasive to configure per-command. They provide a central place to declare "this is how I want things to work" and let individual invocations override when needed.

The key insight is that good CLI tools need both:

-   **Syntactic configuration** (parameters, git aliases) for "run this command with these exact flags"
-   **Semantic configuration** (values, git config) for "this setting should apply everywhere"

clk gives you both, so you can choose the right tool for each situation.
