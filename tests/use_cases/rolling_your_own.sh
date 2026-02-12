#!/bin/bash -eu
# [[file:../../doc/use_cases/tests/use_cases/rolling_your_own.sh :exports none :noweb yes :shebang "#!/bin/bash -eu"][No heading:10]]
. ./sandboxing.sh

clk fork mytool

CURRENT_CLK="$(clk python -c 'from pathlib import Path; import clk ; print(Path(clk.__path__[0]).parent)')"

python3 -m venv venv
./venv/bin/pip install ./mytool
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
        echo "No reinstalling clk. It should be brought in as dependency of mytool"
    fi
elif test "$from" = "build"
then
    ./venv/bin/pip install --force-reinstall /dist/*
else
    # fallback in assuming that I run this from my machine, where clk is
    # installed in editable mode
    ./venv/bin/pip install --force-reinstall --editable "${CURRENT_CLK}"
fi

mkdir -p "${TMP}/mytool-root"
cat <<EOF > "${TMP}/mytool-root/mytool.json"
{
    "parameters": {
        "mytool": [
            "--forced-width",
            "--reproducible-output"

        ],
        "command.create.python": [
            "--no-open"
        ],
        "command.create.bash": [
            "--no-open"
        ]
    }
}
EOF
echo "export MYTOOLCONFIGDIR=${TMP}/mytool-root" >> "${TMP}/.envrc" && direnv allow
source "${TMP}/.envrc"

mytool command create bash hello-world --description "Just say hello" --body 'echo "Hello world"'


call_code () {
      mytool hello-world
}

call_expected () {
      cat<<"EOEXPECTED"
Hello world
EOEXPECTED
}

echo 'Run call'

{ call_code || true ; } > "${TMP}/code.txt" 2>&1
call_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying call"
exit 1
}



help_code () {
      mytool 2>&1
}

help_expected () {
      cat<<"EOEXPECTED"
Usage: mytool [OPTIONS] COMMAND [ARGS]...

  The current parameters set for this command are: --forced-width --reproducible-output

Options:
  --env TEXT                      Add this custom environment variable
  --profiling                     Enable profiling the application code
  -u, --without-extension EXTENSION
                                  Disable this extension for the time of the command
  -e, --extension EXTENSION       Enable this extension for the time of the command
  --report-file TEXT              Create a report file to put with bug reports
  --reproducible-output           Ensure the output is reproducible by redacting the project location (used to have
                                  reproducible tests)
  --flow-progress / --no-flow-progress
                                  Show a progress bar when running flow dependencies
  --flow-verbose / --no-flow-verbose
                                  Show more precisely when a flow starts and when it ends
  --debug-on-command-load-error   Trigger a debugger whenever a command fails to load
  --post-mortem / --no-post-mortem
                                  Run a post-mortem debugger in case of exception
  -D, --develop / --no-develop    Same as --log-level develop
  -d, --debug / --no-debug        Same as --log-level debug
  -a, --action / --no-action      Same as --log-level action
  -q, --quiet / --no-quiet        Same as --log-level critical
  -L, --log-level [develop|debug|action|status|deprecated|info|warning|error|critical]
                                  Log level (default to 'deprecated')
  --ask-secret / --no-ask-secret  Interactively ask for the secret if the secret manager does not provide it
  --forced-width                  Force the width of the terminal (used to have reproducible tests)
  --alternate-style STYLE         Alternate style
  --plugin-dirs TEXT
  --persist-migration / --no-persist-migration
                                  Make the profile migration persistent, using --no-persist-migration will preserve the
                                  profiles, unless you explicitly write into them. This is useful if you want to use a
                                  razor edge version of the application without forcing peoples to move to it.
  -P, --project DIR               Project directory
  --flow-step / --no-flow-step    Make a pause in between the flow steps. Useful to make demonstrations. Implies --flow-
                                  verbose.
  --autoflow / --no-autoflow      Automatically trigger the --flow option in every command
  --no-cache / --cache            Deactivate the caching mechanism
  --keyring TEXT                  Use this keyring instead of the default one
  -n, --dry-run / --no-dry-run    Don't actually run anything
  --force-color / --no-force-color
                                  Force the color output, even if the output is not a terminal
  --help-all                      Show the full help message, automatic options included.
  --help                          Show this message and exit.

Commands:
  alias        Manipulate the command aliases
  command      Display all the available commands
  completion   Shell completion
  describe     Describe the given profile
  echo         Log a message
  exec         Run a program, like good old times.
  extension    Extension related commands
  flowdep      Manipulate command flow dependencies.
  fork         Create a brand new project, based on clk that can be used by itself.
  hello-world  Just say hello
  help         Display help information
  log          Log a message
  parameter    Manipulate command parameters
  pip          Run pip in the context of this installation of clk
  plugin       Manipulate plugins
  python       Run the python executable that is currently running clk
  secret       Manipulate your secrets
  update       Upgrade clk
  value        Manipulate the values

EOEXPECTED
}

echo 'Run help'

{ help_code || true ; } > "${TMP}/code.txt" 2>&1
help_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying help"
exit 1
}
# No heading:10 ends here
