#!/usr/bin/env bash
# [[file:../../doc/use_cases/using_a_plugin.org::#the-day-one-stops-working][the day one stops working:3]]
set -eu
. ./sandboxing.sh

mkdir -p "${CLKCONFIGDIR}/plugins"
cp "${SRCDIR}/../../contrib/plugin/trigger.py" "${CLKCONFIGDIR}/plugins/trigger.py"


show-plugin_code () {
      clk plugin show
}

show-plugin_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[36m[2mtrigger[0m [2mTrigger plugin - run commands before/after other commands.[0m
[2m--------------[0m
Legend: [36m[2mglobal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-plugin'

{ show-plugin_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show-plugin"
else
    show-plugin_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-plugin"
        exit 1
    }
fi



verify_plugin_code () {
      clk trigger --help | head -15
}

verify_plugin_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk trigger [OPTIONS] COMMAND [ARGS]...

  Manipulate command triggers.

  Triggers allow you to automatically run commands before or after other commands. This is useful for working around
  issues in tools or adding consistent behaviors.

  To run command B before command A:

      clk trigger set pre A B

  To run command B only after successful execution of A:

      clk trigger set success A B

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run verify_plugin'

{ verify_plugin_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/verify_plugin"
else
    verify_plugin_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying verify_plugin"
        exit 1
    }
fi


clk alias set mycommand echo 'main command'

clk trigger set pre mycommand echo hello


show_trigger_code () {
      clk trigger show pre mycommand
}

show_trigger_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
mycommand [2m[36m[2mecho hello[0m[0m
[2m--------------[0m
Legend: [36m[2mglobal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show_trigger'

{ show_trigger_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show_trigger"
else
    show_trigger_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show_trigger"
        exit 1
    }
fi



run_with_pre_trigger_code () {
      clk mycommand
}

run_with_pre_trigger_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
hello
main command
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_with_pre_trigger'

{ run_with_pre_trigger_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run_with_pre_trigger"
else
    run_with_pre_trigger_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_with_pre_trigger"
        exit 1
    }
fi


clk alias set buildcmd echo 'build complete'
clk trigger set success buildcmd echo 'after success'


run_with_success_trigger_code () {
      clk buildcmd
}

run_with_success_trigger_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
build complete
after success
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_with_success_trigger'

{ run_with_success_trigger_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run_with_success_trigger"
else
    run_with_success_trigger_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_with_success_trigger"
        exit 1
    }
fi


clk trigger unset pre mycommand


run_after_unset_code () {
      clk mycommand
}

run_after_unset_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
main command
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_after_unset'

{ run_after_unset_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run_after_unset"
else
    run_after_unset_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_after_unset"
        exit 1
    }
fi


clk alias set cmd1 echo 'one'
clk alias set cmd2 echo 'two'
clk trigger set pre cmd1 echo 'trigger1'
clk trigger set pre cmd2 echo 'trigger2'


show_name_only_code () {
      clk trigger show pre --name-only
}

show_name_only_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
buildcmd
cmd1
cmd2
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show_name_only'

{ show_name_only_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show_name_only"
else
    show_name_only_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show_name_only"
        exit 1
    }
fi


clk plugin create global greet --description "Say hello on load"


which_plugin_code () {
      clk plugin which global greet
}

which_plugin_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./clk-root/plugins/greet.py
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run which_plugin'

{ which_plugin_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/which_plugin"
else
    which_plugin_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying which_plugin"
        exit 1
    }
fi



create_plugin_again_code () {
      clk plugin create global greet --description "Say hello on load"
}

create_plugin_again_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk plugin create [OPTIONS] PROFILE_SOURCE NEW_NAME
error: Won't overwrite ./clk-root/plugins/greet.py unless explicitly asked so with --force
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create_plugin_again'

{ create_plugin_again_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/create_plugin_again"
else
    create_plugin_again_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create_plugin_again"
        exit 1
    }
fi



try_plugin_completion_code () {
      clk completion try --last plugin which global g
}

try_plugin_completion_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
greet
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try_plugin_completion'

{ try_plugin_completion_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try_plugin_completion"
else
    try_plugin_completion_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try_plugin_completion"
        exit 1
    }
fi


clk plugin create global notifier --description "Say things out loud"
cat<<'EOF' > "$(clk plugin which global notifier)"
#!/usr/bin/env python3

import notify2


def load_plugin():
    "Nothing here, it never gets this far."
EOF


run_with_broken_plugin_code () {
      clk echo hello
}

run_with_broken_plugin_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[33mwarning: [0mError when loading plugin notifier (if the plugin is no more useful, consider uninstalling the plugins notifier): No module named 'notify2'
hello
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_with_broken_plugin'

{ run_with_broken_plugin_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run_with_broken_plugin"
else
    run_with_broken_plugin_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_with_broken_plugin"
        exit 1
    }
fi
# the day one stops working:3 ends here
