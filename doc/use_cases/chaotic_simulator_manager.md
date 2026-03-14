- [bootstrapping csm](#org85197ae)
- [creating the simulator commands](#orgee49b3c)
- [the simulator crashes — time to debug](#org4de1703)
- [adding launcher support](#org5004a1c)
- [using a launcher in the simulate command](#orgff62c46)

When installed, clk comes with an executable that may be used for all your workflows.

But you may want to run your own project without prefixing stuffs with `clk...`.

But first, two things:

1.  we assume you want to create a tool that contains subcommands, like **git**, not a single command, like **find**. This is because we will automatically create some subcommands to deal with aliases, parameters etc.
2.  we assume you don't mind creating a full python project and not a single ".py" file.

Let's say you are working on an embedded project. The development cycle looks like this: generate some code from a model, configure the build system, build, then run the simulator. Each step is its own command, and most of the time you chain them together. Let's build a standalone tool called `csm` to manage that workflow.


<a id="org85197ae"></a>

# bootstrapping csm

clk provides out of the box a command to bootstrap your own tool.

```bash
clk fork csm
```

    Now, install csm with either `pipx install ./csm` or `python3 -m venv venv && ./venv/bin/pip install ./csm` followed by `export PATH="$(pwd)/venv/bin/:${PATH}"`. Then, enable its completion with `csm completion install` and don't forget to have fun

Now, simply install this tool, like suggested.

```bash
python3 -m venv venv
./venv/bin/pip install ./csm
echo "export PATH=$(pwd)/venv/bin/:${PATH}" >> "${TMP}/.envrc" && direnv allow
source "${TMP}/.envrc"
```


<a id="orgee49b3c"></a>

# creating the simulator commands

The development cycle is generate, configure, build, simulate. Each step is a command. We write them as internal commands in the csm project — any `.py` file placed in `csm/csm/commands/` is auto-discovered as a command.

Each command declares which step it depends on using `flowdepends` (see [flows](3D_printing_flow.md)). This way, `csm simulate --flow` chains the whole pipeline automatically.

```python
from clk.decorators import command

@command()
def generate():
    """Generate source code from the model."""
    print("Generating code from model.xml")
```

```python
from clk.decorators import command

@command(flowdepends=["generate"])
def configure():
    """Configure the build system (e.g. cmake)."""
    print("Configuring build system")
```

```python
from clk.decorators import command

@command(flowdepends=["configure"])
def build_():
    """Build the simulator binary."""
    print("Building simulator")
```

```python
from clk.decorators import command

@command(flowdepends=["build"])
def simulate():
    """Run the simulator."""
    print("Running ./build/simulator")
```

Running the full pipeline is a single command.

```bash
csm simulate --flow
```

    Generating code from model.xml
    Configuring build system
    Building simulator
    Running ./build/simulator

Without `--flow`, only the simulate step runs.

```bash
csm simulate
```

    Running ./build/simulator


<a id="org4de1703"></a>

# the simulator crashes — time to debug

The simulator crashes on a corner case. You want to run it under gdb to inspect the state. Without any tooling, you would type something like:

```bash
gdb --quiet --args ./build/simulator
```

That works, but it is tedious. You need to remember the exact flags every time, and it does not compose with the rest of the workflow. What if you also want to profile with perf, or check for memory leaks with valgrind? Each tool has its own incantation and you end up copy-pasting long commands.


<a id="org5004a1c"></a>

# adding launcher support

A launcher is a tool that runs other tools: a debugger, a profiler, an environment wrapper. Since csm is our own project, we can add launcher support as an internal part of it rather than relying on an external plugin.

First, the library module that defines the available launchers and provides a decorator and a resolver.

```python
import click
from clk.overloads import option

LAUNCHERS = {
    "gdb": ["gdb", "--quiet", "--args"],
    "lldb": ["lldb", "--"],
    "memcheck": ["valgrind", "--tool=memcheck", "--leak-check=full"],
    "perf-record": [
        "perf", "record", "-e", "cpu-clock",
        "--call-graph", "dwarf", "-F", "99",
    ],
    "heaptrack": ["heaptrack"],
}


def resolve_launcher(launcher_name=None):
    """Return the command prefix for a launcher, or an empty list."""
    if launcher_name:
        if launcher_name not in LAUNCHERS:
            raise click.ClickException(f"Unknown launcher: {launcher_name}")
        return list(LAUNCHERS[launcher_name])
    return []


def launcher_options(func):
    """Add a --launcher option to a command."""
    return option(
        "-l", "--launcher",
        type=click.Choice(sorted(LAUNCHERS)),
        help="Wrap the command with this launcher (e.g. gdb, perf-record).",
    )(func)
```

Then, the CLI command that lets you inspect the available launchers.

```python
import click
from clk.decorators import command, argument, group, flag
from csm.launcher import LAUNCHERS

@group(default_command="show")
def launcher():
    """Inspect available launchers."""

@launcher.command()
@flag("--name-only/--no-name-only", help="Only display the launcher names")
@argument("launchers", nargs=-1, required=False, help="Launchers to show")
def show(name_only, launchers):
    """Show the launchers."""
    names = launchers or sorted(LAUNCHERS)
    for name in names:
        if name_only:
            click.echo(name)
        else:
            cmd = " ".join(LAUNCHERS.get(name, []))
            if cmd:
                click.echo(f"{name} {cmd}")
```

Several launchers are available out of the box.

```bash
csm launcher show --name-only
```

    gdb
    heaptrack
    lldb
    memcheck
    perf-record

You can inspect what a launcher expands to.

```bash
csm launcher show gdb
```

    gdb gdb --quiet --args


<a id="orgff62c46"></a>

# using a launcher in the simulate command

To make the simulate command support `--launcher`, we use the `launcher_options` decorator and resolve the launcher before calling the external program.

```python
from clk.decorators import command
from csm.launcher import launcher_options, resolve_launcher

@command(flowdepends=["build"])
@launcher_options
def simulate(launcher):
    """Run the simulator."""
    prefix = resolve_launcher(launcher)
    cmd = prefix + ["./build/simulator"]
    print("Running " + " ".join(cmd))
```

Now the simulate command accepts `--launcher`.

```bash
csm simulate --launcher gdb
```

    Running gdb --quiet --args ./build/simulator

Switching to another tool is just changing the launcher name.

```bash
csm simulate --launcher perf-record
```

    Running perf record -e cpu-clock --call-graph dwarf -F 99 ./build/simulator

And without `--launcher`, the command runs the simulator directly.

```bash
csm simulate
```

    Running ./build/simulator

Since we kept the `flowdepends` from earlier, `--flow` and `--launcher` compose naturally: the full pipeline runs, with the launcher wrapping only the final simulate step.

```bash
csm simulate --flow --launcher gdb
```

    Generating code from model.xml
    Configuring build system
    Building simulator
    Running gdb --quiet --args ./build/simulator
