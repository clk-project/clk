#!/usr/bin/env bash
# [[file:../../doc/use_cases/chaotic_simulator_manager.org::#using-a-launcher-in-the-simulate-command][using a launcher in the simulate command:7]]
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
# csm lives in its own venv, out of reach of the wrapper the sandbox uses for
# clk. Lend it alone to the python that measures clk, so that the lines it runs
# are the very ones the other tests count.
CSM_COV_DIR="$(dirname "${CLK_COV}")"
mkdir -p "${TMP}/csm-import"
ln -sfn "$("${TMP}/venv/bin/python" -c 'import csm, pathlib; print(pathlib.Path(csm.__file__).parent)')" "${TMP}/csm-import/csm"
CSM_COV_COUNT=0
csm () {
    CSM_COV_COUNT=$((CSM_COV_COUNT + 1))
    COVERAGE_FILE="${CSM_COV_DIR}/.coverage.csm.${CLK_COVERAGE_TEST_ID-}.${CSM_COV_COUNT}" \
        PYTHONPATH="${TMP}/csm-import" "${PYTHON}" -u -m coverage run --source clk \
        ${CLK_COVERAGE_CONTEXT:+--context="${CLK_COVERAGE_CONTEXT}"} \
        "${TMP}/venv/bin/csm" "$@"
}

cat<<'EOF' > csm/csm/commands/generate.py
from clk.decorators import command

@command()
def generate():
    """Generate source code from the model."""
    print("Generating code from model.xml")
EOF
cat<<'EOF' > csm/csm/commands/configure.py
from clk.decorators import command, flag, option
from clk.lib import format_options

@command(flowdepends=["generate"])
@flag("--coverage", help="Measure how much of the code the tests run")
@option("--build-type", help="The kind of build to configure")
@option("--define", multiple=True, help="A variable to hand over to the build system")
@flag("--python/--no-python", default=None, help="Activate the python wrappers")
@flag("--unity/--no-unity", default=None, help="Activate the unity build")
@flag("--doxygen/--no-doxygen", default=None, help="Build the documentation")
def configure(coverage, **cmake_opts):
    """Configure the build system (e.g. cmake)."""
    if coverage:
        cmake_opts["analysis"] = "coverage"
    flags = format_options(cmake_opts)
    print("Configuring build system" + (" with " + " ".join(flags) if flags else ""))
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
      local expected
      expected="$(cat<<"EOEXPECTED"
Generating code from model.xml
Configuring build system
Building simulator
Running ./build/simulator
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run csm-run-flow'

{ csm-run-flow_code || true ; } > "${TMP}/code.txt" 2>&1
csm-run-flow_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-run-flow"
exit 1
}



csm-configure-options_code () {
      csm configure --unity --build-type Debug --coverage
}

csm-configure-options_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Configuring build system with --unity --build-type Debug --analysis coverage
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run csm-configure-options'

{ csm-configure-options_code || true ; } > "${TMP}/code.txt" 2>&1
csm-configure-options_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-configure-options"
exit 1
}



csm-configure-defines_code () {
      csm configure --define WITH_MPI=ON --define CHAOS_SEED=42
}

csm-configure-defines_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Configuring build system with --define WITH_MPI=ON --define CHAOS_SEED=42
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run csm-configure-defines'

{ csm-configure-defines_code || true ; } > "${TMP}/code.txt" 2>&1
csm-configure-defines_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-configure-defines"
exit 1
}



csm-run-no-flow_code () {
      csm simulate
}

csm-run-no-flow_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running ./build/simulator
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
gdb
heaptrack
lldb
memcheck
perf-record
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
gdb gdb --quiet --args
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
Running gdb --quiet --args ./build/simulator
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
Running perf record -e cpu-clock --call-graph dwarf -F 99 ./build/simulator
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
Running ./build/simulator
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
Generating code from model.xml
Configuring build system
Building simulator
Running gdb --quiet --args ./build/simulator
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run csm-flow-with-launcher'

{ csm-flow-with-launcher_code || true ; } > "${TMP}/code.txt" 2>&1
csm-flow-with-launcher_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying csm-flow-with-launcher"
exit 1
}
# using a launcher in the simulate command:7 ends here
