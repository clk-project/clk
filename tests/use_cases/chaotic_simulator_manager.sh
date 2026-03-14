#!/usr/bin/env bash
# [[id:c777ac1b-8ed6-4cb0-909e-92ce2ce96a03][using a launcher in the simulate command:7]]
set -eu
. ./sandboxing.sh

clk fork csm

CURRENT_CLK="$(clk python -c 'from pathlib import Path; import clk ; print(Path(clk.__path__[0]).parent)')"

python3 -m venv venv
./venv/bin/pip install ./csm
echo "export PATH=$(pwd)/venv/bin/:${PATH}" >> "${TMP}/.envrc" && direnv allow
source "${TMP}/.envrc"

# this reproduces the logic in the INSTALLER function in the root Earthfile. It
# might be good to refactor this in the future.
from=${from-}
if test "$from" = "pypi"
then
    if test -n "${pypi_version}"
    then
        ./venv/bin/pip install --force-reinstall clk${pypi_version}
    else
        echo "No reinstalling clk. It should be brought in as dependency of csm"
    fi
elif test "$from" = "build"
then
    ./venv/bin/pip install --force-reinstall /dist/*
else
    # fallback in assuming that I run this from my machine, where clk is
    # installed in editable mode
    ./venv/bin/pip install --force-reinstall --editable "${CURRENT_CLK}"
fi

mkdir -p "${TMP}/csm-root"
cat <<EOF > "${TMP}/csm-root/csm.json"
{
    "parameters": {
        "csm": [
            "--forced-width",
            "--reproducible-output"
        ]
    }
}
EOF
echo "export CSMCONFIGDIR=${TMP}/csm-root" >> "${TMP}/.envrc" && direnv allow
source "${TMP}/.envrc"

cat<<'EOF' > csm/csm/commands/generate.py
from clk.decorators import command

@command()
def generate():
    """Generate source code from the model."""
    print("Generating code from model.xml")
EOF
cat<<'EOF' > csm/csm/commands/configure.py
from clk.decorators import command

@command(flowdepends=["generate"])
def configure():
    """Configure the build system (e.g. cmake)."""
    print("Configuring build system")
EOF
cat<<'EOF' > csm/csm/commands/build.py
from clk.decorators import command

@command(flowdepends=["configure"])
def build_():
    """Build the simulator binary."""
    print("Building simulator")
EOF
cat<<'EOF' > csm/csm/commands/simulate.py
from clk.decorators import command

@command(flowdepends=["build"])
def simulate():
    """Run the simulator."""
    print("Running ./build/simulator")
EOF
rm csm/csm/commands/somecommand.py
./venv/bin/pip install ./csm


csm-run-flow_code () {
      csm simulate --flow
}

csm-run-flow_expected () {
      cat<<"EOEXPECTED"
Generating code from model.xml
Configuring build system
Building simulator
Running ./build/simulator
EOEXPECTED
}

echo 'Run csm-run-flow'

{ csm-run-flow_code || true ; } > "${TMP}/code.txt" 2>&1
csm-run-flow_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-run-flow"
exit 1
}



csm-run-no-flow_code () {
      csm simulate
}

csm-run-no-flow_expected () {
      cat<<"EOEXPECTED"
Running ./build/simulator
EOEXPECTED
}

echo 'Run csm-run-no-flow'

{ csm-run-no-flow_code || true ; } > "${TMP}/code.txt" 2>&1
csm-run-no-flow_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-run-no-flow"
exit 1
}


cat<<'EOF' > csm/csm/launcher.py
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
EOF
cat<<'EOF' > csm/csm/commands/launcher.py
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
EOF
./venv/bin/pip install ./csm


csm-show-launchers_code () {
      csm launcher show --name-only
}

csm-show-launchers_expected () {
      cat<<"EOEXPECTED"
gdb
heaptrack
lldb
memcheck
perf-record
EOEXPECTED
}

echo 'Run csm-show-launchers'

{ csm-show-launchers_code || true ; } > "${TMP}/code.txt" 2>&1
csm-show-launchers_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-show-launchers"
exit 1
}



csm-show-gdb_code () {
      csm launcher show gdb
}

csm-show-gdb_expected () {
      cat<<"EOEXPECTED"
gdb gdb --quiet --args
EOEXPECTED
}

echo 'Run csm-show-gdb'

{ csm-show-gdb_code || true ; } > "${TMP}/code.txt" 2>&1
csm-show-gdb_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-show-gdb"
exit 1
}


cat<<'EOF' > csm/csm/commands/simulate.py
from clk.decorators import command
from csm.launcher import launcher_options, resolve_launcher

@command(flowdepends=["build"])
@launcher_options
def simulate(launcher):
    """Run the simulator."""
    prefix = resolve_launcher(launcher)
    cmd = prefix + ["./build/simulator"]
    print("Running " + " ".join(cmd))
EOF
./venv/bin/pip install ./csm


csm-simulate-with-gdb_code () {
      csm simulate --launcher gdb
}

csm-simulate-with-gdb_expected () {
      cat<<"EOEXPECTED"
Running gdb --quiet --args ./build/simulator
EOEXPECTED
}

echo 'Run csm-simulate-with-gdb'

{ csm-simulate-with-gdb_code || true ; } > "${TMP}/code.txt" 2>&1
csm-simulate-with-gdb_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-simulate-with-gdb"
exit 1
}



csm-simulate-with-perf_code () {
      csm simulate --launcher perf-record
}

csm-simulate-with-perf_expected () {
      cat<<"EOEXPECTED"
Running perf record -e cpu-clock --call-graph dwarf -F 99 ./build/simulator
EOEXPECTED
}

echo 'Run csm-simulate-with-perf'

{ csm-simulate-with-perf_code || true ; } > "${TMP}/code.txt" 2>&1
csm-simulate-with-perf_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-simulate-with-perf"
exit 1
}



csm-simulate-without-launcher_code () {
      csm simulate
}

csm-simulate-without-launcher_expected () {
      cat<<"EOEXPECTED"
Running ./build/simulator
EOEXPECTED
}

echo 'Run csm-simulate-without-launcher'

{ csm-simulate-without-launcher_code || true ; } > "${TMP}/code.txt" 2>&1
csm-simulate-without-launcher_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-simulate-without-launcher"
exit 1
}



csm-flow-with-launcher_code () {
      csm simulate --flow --launcher gdb
}

csm-flow-with-launcher_expected () {
      cat<<"EOEXPECTED"
Generating code from model.xml
Configuring build system
Building simulator
Running gdb --quiet --args ./build/simulator
EOEXPECTED
}

echo 'Run csm-flow-with-launcher'

{ csm-flow-with-launcher_code || true ; } > "${TMP}/code.txt" 2>&1
csm-flow-with-launcher_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-flow-with-launcher"
exit 1
}
# using a launcher in the simulate command:7 ends here
