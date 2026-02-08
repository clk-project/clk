#!/bin/bash -eu
# [[file:../../doc/use_cases/python_command.org::#forgetting-the-decorator][possible mistake: forgetting the decorator:5]]
. ./sandboxing.sh

clk command create python mycommand


help-create_code () {
      clk command create python --help
}

help-create_expected () {
      cat<<"EOEXPECTED"
Usage: clk command create python [OPTIONS] NAME

  Create a bash custom command

  The current parameters set for this command are: --no-open --force

  This is a built-in command.

Arguments:
  NAME  The name of the new command

Options:
  --open / --no-open   Also open the file after its creation  [default: True]
  --force              Overwrite a file if it already exists  [default: False]
  --group / --command  Bootstrap a command or a group of commands  [default: False]
  --with-data          Create a directory module instead of a single file. So that you can ship data with it  [default:
                       False]
  --body TEXT          The initial body to put  [default: ]
  --description TEXT   The initial description to put  [default: Description]
  --from-file TEXT     Copy this file instead of using the template
  --help-all           Show the full help message, automatic options included.
  --help               Show this message and exit.

EOEXPECTED
}

echo 'Run help-create'

{ help-create_code || true ; } > "${TMP}/code.txt" 2>&1
help-create_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying help-create"
exit 1
}



show_it_code () {
      cat $(clk command which mycommand)
}

show_it_expected () {
      cat<<"EOEXPECTED"
#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from pathlib import Path

import click

from clk.decorators import (
    argument,
    flag,
    option,
    command,
    use_settings,
    table_format,
    table_fields,
)
from clk.lib import (
    TablePrinter,
    call,
)
from clk.config import config
from clk.log import get_logger
from clk.types import DynamicChoice


LOGGER = get_logger(__name__)


@command()
def mycommand():
    "Description"

EOEXPECTED
}

echo 'Run show_it'

{ show_it_code || true ; } > "${TMP}/code.txt" 2>&1
show_it_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show_it"
exit 1
}



try_code () {
      clk mycommand
}

try_expected () {
      cat<<"EOEXPECTED"
warning: The command 'mycommand' has no documentation
EOEXPECTED
}

echo 'Run try'

{ try_code || true ; } > "${TMP}/code.txt" 2>&1
try_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try"
exit 1
}


sed -i 's/"Description"/"Command that says something"/g' "$(clk command which mycommand)"


help_code () {
      clk mycommand --help | head -10
}

help_expected () {
      cat<<"EOEXPECTED"
Usage: clk mycommand [OPTIONS]

  Command that says something

  Edit this custom command by running `clk command edit mycommand`
  Or edit ./clk-root/python/mycommand.py directly.

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.

EOEXPECTED
}

echo 'Run help'

{ help_code || true ; } > "${TMP}/code.txt" 2>&1
help_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying help"
exit 1
}


cat<<'EOF' > "$(clk command which mycommand)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import command


@command()
def mycommand():
    "Command that says something"
    print("something")
EOF


use_it_code () {
      clk mycommand
}

use_it_expected () {
      cat<<"EOEXPECTED"
something
EOEXPECTED
}

echo 'Run use_it'

{ use_it_code || true ; } > "${TMP}/code.txt" 2>&1
use_it_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying use_it"
exit 1
}


cat<<'EOF' > "$(clk command which mycommand)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.decorators import command, option, argument


@command()
@option("--name", default="world", help="Name to greet")
@argument("greeting", default="Hello")
def mycommand(name, greeting):
    "A greeting command"
    print(f"{greeting}, {name}!")
EOF


use_with_options_code () {
      clk mycommand
}

use_with_options_expected () {
      cat<<"EOEXPECTED"
warning: The parameter 'greeting' in the command 'mycommand' has no documentation
Hello, world!
EOEXPECTED
}

echo 'Run use_with_options'

{ use_with_options_code || true ; } > "${TMP}/code.txt" 2>&1
use_with_options_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying use_with_options"
exit 1
}



use_with_options2_code () {
      clk mycommand --name clk Goodbye
}

use_with_options2_expected () {
      cat<<"EOEXPECTED"
warning: The parameter 'greeting' in the command 'mycommand' has no documentation
Goodbye, clk!
EOEXPECTED
}

echo 'Run use_with_options2'

{ use_with_options2_code || true ; } > "${TMP}/code.txt" 2>&1
use_with_options2_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying use_with_options2"
exit 1
}


cat <<'EOF' > "${CLKCONFIGDIR}/python/myenv.py"
def myenv():
    """My environment command"""
    print("hello")
EOF


try-bad-command_code () {
      clk myenv 2>&1|sed "s|$(pwd)|.|"
}

try-bad-command_expected () {
      cat<<"EOEXPECTED"
error: Found the command myenv in the resolver customcommand but could not load it.
warning: Failed to get the command myenv: The file ./clk-root/python/myenv.py must contain a click command or group named myenv, but found a function instead. Did you forget the @command or @group decorator?
error: clk.myenv could not be loaded. Re run with clk --develop to see the stacktrace or clk --debug-on-command-load-error to debug the load error
EOEXPECTED
}

echo 'Run try-bad-command'

{ try-bad-command_code || true ; } > "${TMP}/code.txt" 2>&1
try-bad-command_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-bad-command"
exit 1
}


cat <<'EOF' > "${CLKCONFIGDIR}/python/myenv.py"
from clk.decorators import command

@command()
def myenv():
    """My environment command"""
    print("hello")
EOF


try-fixed-command_code () {
      clk myenv
}

try-fixed-command_expected () {
      cat<<"EOEXPECTED"
hello
EOEXPECTED
}

echo 'Run try-fixed-command'

{ try-fixed-command_code || true ; } > "${TMP}/code.txt" 2>&1
try-fixed-command_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-fixed-command"
exit 1
}
# possible mistake: forgetting the decorator:5 ends here
