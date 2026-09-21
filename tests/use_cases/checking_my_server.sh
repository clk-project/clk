#!/usr/bin/env bash
# [[file:../../doc/use_cases/checking_my_server.org::#when-i-break-it][when I break it:3]]
set -eu
. ./sandboxing.sh

clk command create bash server.check


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
      cat $(clk command which server.check)
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
      clk server check
}

try_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: The command 'server.check' has no documentation
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
sed -i 's/Description/Say whether my server answers/g' "${1}"
EOF
chmod +x myeditor
VISUAL=./myeditor clk command edit server.check


help_code () {
      clk server check --help|sed "s|$(pwd)|.|"
}

help_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk server check [OPTIONS]

  Say whether my server answers

  Edit this external command by running `clk command edit server.check`
  Or edit ./clk-root/bin/server.check directly.

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


cat<<EOF >> "$(clk command which server.check)"
echo "no answer from myserver"
exit 7
EOF


use_it_code () {
      clk server check
}

use_it_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
no answer from myserver
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



exit-7_code () {
      clk server check || echo $?
}

exit-7_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
no answer from myserver
7
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run exit-7'

{ exit-7_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/exit-7"
else
    exit-7_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying exit-7"
        exit 1
    }
fi


  clk command create bash --body "
  close_tunnel () {
echo 'closing the tunnel'
}
trap close_tunnel EXIT
echo 'watching the server'
sleep 3600
  " --description "Watch the server through a tunnel" server.watch

cat<<EOF > pass.exp
#!/usr/bin/env -S expect -f

set timeout -1
spawn clk server watch
match_max 100000
expect -exact "watching the server\r"
sleep 0.1
send "\x03"
expect -exact "closing the tunnel"
expect -exact "\r"
expect -exact "\r"
expect -exact "\r"
expect -exact "Aborted!"
expect eof
EOF


watch-expect_code () {
      expect pass.exp |tail -n+2
}

watch-expect_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
watching the server
^Cclosing the tunnel


Aborted!
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run watch-expect'

{ watch-expect_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/watch-expect"
else
    watch-expect_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying watch-expect"
        exit 1
    }
fi


check="$(clk command which server.check)"
cat<<'EOF' > "${check}"
#!/usr/bin/env bash
set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOS
$0

Say whether my server answers
--
A:host
EOS
}

clk_help_handler "$@"

echo "no answer from ${CLK___HOST}"
EOF


run-bad-usage_code () {
      clk server check myserver 2>&1 | head -1
}

run-bad-usage_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: When loading command server.check at path ./clk-root/bin/server.check: Expected format in server.check is A:name:type:help[:{someextrajsondata}], got A:host
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


sed -i 's/^A:host$/A:host:str:The server to ask/' "${check}"


run-good-usage_code () {
      clk server check myserver
}

run-good-usage_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
no answer from myserver
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-good-usage'

{ run-good-usage_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-good-usage"
else
    run-good-usage_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-good-usage"
        exit 1
    }
fi


sed -i 's/^echo /clk echo --style bold-True,fg-red /' "${check}"


run-styled-check_code () {
      clk server check myserver
}

run-styled-check_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
no answer from myserver
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-styled-check'

{ run-styled-check_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-styled-check"
else
    run-styled-check_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-styled-check"
        exit 1
    }
fi



complete-style_code () {
      clk completion try --remove-bash-formatting --last echo --style fg-
}

complete-style_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
fg-black
fg-red
fg-green
fg-yellow
fg-blue
fg-magenta
fg-cyan
fg-white
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run complete-style'

{ complete-style_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/complete-style"
else
    complete-style_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying complete-style"
        exit 1
    }
fi



run-bad-style_code () {
      clk echo --style pink hello 2>&1
}

run-bad-style_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk echo [OPTIONS] [MESSAGE]...
error: Invalid value for '-s' / '--style': invalid style: pink. (Unknown color 'pink')
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-bad-style'

{ run-bad-style_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-bad-style"
else
    run-bad-style_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-bad-style"
        exit 1
    }
fi


cat<<'EOF' > "${check}"
#!/usr/bin/env bash
exit 1
EOF


run-broken-command_code () {
      clk server check --help | head -3
}

run-broken-command_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk server check [OPTIONS]

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
# when I break it:3 ends here
