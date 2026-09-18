#!/usr/bin/env bash
# [[file:../../doc/use_cases/bash_command.org::#when-clk-cannot-read-what-you-wrote][when clk cannot read what you wrote:5]]
set -eu
. ./sandboxing.sh

clk command create bash mycommand


help-create_code () {
      clk command create --help
}

help-create_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk command create [OPTIONS] COMMAND [ARGS]...

  Create custom commands directly from the command line.

  This is a built-in command.

Options:
  --help-all             Show the full help message, automatic options included.
  --extension EXTENSION  Use this extension
  --context              Guess the profile
  --global               Consider only the global profile
  --help                 Show this message and exit.

Commands:
  bash    Create a bash custom command
  python  Create a bash custom command

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run help-create'

{ help-create_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/help-create"
else
    help-create_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying help-create"
        exit 1
    }
fi



show_it_code () {
      cat $(clk command which mycommand)
}

show_it_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
#!/usr/bin/env bash
  set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Description
--

EOF
}

clk_help_handler "$@"

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show_it'

{ show_it_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/show_it"
else
    show_it_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show_it"
        exit 1
    }
fi



try_code () {
      clk mycommand
}

try_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: The command 'mycommand' has no documentation
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try'

{ try_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try"
else
    try_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try"
        exit 1
    }
fi


cat<<'EOF' > myeditor
#!/usr/bin/env bash
  set -eu
sed -i 's/Description/Command that says something/g' "${1}"
EOF
chmod +x myeditor
VISUAL=./myeditor clk command edit mycommand


help_code () {
      clk mycommand --help|sed "s|$(pwd)|.|"
}

help_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk mycommand [OPTIONS]

  Command that says something

  Edit this external command by running `clk command edit mycommand`
  Or edit ./clk-root/bin/mycommand directly.

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run help'

{ help_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/help"
else
    help_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying help"
        exit 1
    }
fi


cat<<EOF >> "$(clk command which mycommand)"
echo something
EOF


use_it_code () {
      clk mycommand
}

use_it_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
something
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run use_it'

{ use_it_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/use_it"
else
    use_it_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying use_it"
        exit 1
    }
fi


clk command create bash --body "exit 5" --description "Simply exiting with the code 5" exit5


exit-5_code () {
      clk exit5 || echo $?
}

exit-5_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
5
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run exit-5'

{ exit-5_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/exit-5"
else
    exit-5_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying exit-5"
        exit 1
    }
fi


  clk command create bash --body "
  clean () {
echo 'cleaning'
}
trap clean EXIT
echo 'starting'
sleep 3600
  " --description "Simply wait but clean before exiting" clean-test

cat<<EOF > pass.exp
#!/usr/bin/env -S expect -f

set timeout -1
spawn clk clean-test
match_max 100000
expect -exact "starting\r"
sleep 0.1
send "\x03"
expect -exact "cleaning"
expect -exact "\r"
expect -exact "\r"
expect -exact "\r"
expect -exact "Aborted!"
expect eof
EOF


clean-test-expect_code () {
      expect pass.exp |tail -n+2
}

clean-test-expect_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
starting
^Ccleaning

Aborted!
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run clean-test-expect'

{ clean-test-expect_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/clean-test-expect"
else
    clean-test-expect_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying clean-test-expect"
        exit 1
    }
fi


clk command create bash greet --description "Greet someone"
cat<<'EOF' > "$(clk command which greet)"
#!/usr/bin/env bash
set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOS
$0

Greet someone
--
A:name
EOS
}

clk_help_handler "$@"

echo "Hello ${CLK___NAME}"
EOF


run-bad-usage_code () {
      clk greet World 2>&1 | head -1
}

run-bad-usage_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: When loading command greet at path ./clk-root/bin/greet: Expected format in greet is A:name:type:help[:{someextrajsondata}], got A:name
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-bad-usage'

{ run-bad-usage_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-bad-usage"
else
    run-bad-usage_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-bad-usage"
        exit 1
    }
fi


clk command create bash broken --body "exit 1" --description "Broken"
cat<<'EOF' > "$(clk command which broken)"
#!/usr/bin/env bash
exit 1
EOF


run-broken-command_code () {
      clk broken --help | head -3
}

run-broken-command_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk broken [OPTIONS]

  No help found... (the command is most likely broken)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-broken-command'

{ run-broken-command_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-broken-command"
else
    run-broken-command_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-broken-command"
        exit 1
    }
fi
# when clk cannot read what you wrote:5 ends here
