#!/bin/bash -eu
# [[file:../../doc/use_cases/using_a_plugin.org::#listing-triggers-name-only][listing triggers with --name-only:3]]
. ./sandboxing.sh

mkdir -p "${CLKCONFIGDIR}/plugins"
cp "${SRCDIR}/../../contrib/plugin/trigger.py" "${CLKCONFIGDIR}/plugins/trigger.py"


show-plugin_code () {
      clk plugin show
}

show-plugin_expected () {
      cat<<"EOEXPECTED"
trigger Trigger plugin - run commands before/after other commands.
EOEXPECTED
}

echo 'Run show-plugin'

{ show-plugin_code || true ; } > "${TMP}/code.txt" 2>&1
show-plugin_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-plugin"
exit 1
}



verify_plugin_code () {
      clk trigger --help | head -15
}

verify_plugin_expected () {
      cat<<"EOEXPECTED"
Usage: clk trigger [OPTIONS] COMMAND [ARGS]...

  Manipulate command triggers.

  Triggers allow you to automatically run commands before or after other commands. This is useful for working around
  issues in tools or adding consistent behaviors.

  To run command B before command A:

      clk trigger set pre A B

  To run command B only after successful execution of A:

      clk trigger set success A B

EOEXPECTED
}

echo 'Run verify_plugin'

{ verify_plugin_code || true ; } > "${TMP}/code.txt" 2>&1
verify_plugin_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying verify_plugin"
exit 1
}


clk alias set mycommand echo 'main command'

clk trigger set pre mycommand echo hello


show_trigger_code () {
      clk trigger show --no-color pre mycommand
}

show_trigger_expected () {
      cat<<"EOEXPECTED"
mycommand echo hello
EOEXPECTED
}

echo 'Run show_trigger'

{ show_trigger_code || true ; } > "${TMP}/code.txt" 2>&1
show_trigger_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show_trigger"
exit 1
}



run_with_pre_trigger_code () {
      clk mycommand
}

run_with_pre_trigger_expected () {
      cat<<"EOEXPECTED"
hello
main command
EOEXPECTED
}

echo 'Run run_with_pre_trigger'

{ run_with_pre_trigger_code || true ; } > "${TMP}/code.txt" 2>&1
run_with_pre_trigger_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_with_pre_trigger"
exit 1
}


clk alias set buildcmd echo 'build complete'
clk trigger set success buildcmd echo 'after success'


run_with_success_trigger_code () {
      clk buildcmd
}

run_with_success_trigger_expected () {
      cat<<"EOEXPECTED"
build complete
after success
EOEXPECTED
}

echo 'Run run_with_success_trigger'

{ run_with_success_trigger_code || true ; } > "${TMP}/code.txt" 2>&1
run_with_success_trigger_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_with_success_trigger"
exit 1
}


clk trigger unset pre mycommand


run_after_unset_code () {
      clk mycommand
}

run_after_unset_expected () {
      cat<<"EOEXPECTED"
main command
EOEXPECTED
}

echo 'Run run_after_unset'

{ run_after_unset_code || true ; } > "${TMP}/code.txt" 2>&1
run_after_unset_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_after_unset"
exit 1
}


clk alias set cmd1 echo 'one'
clk alias set cmd2 echo 'two'
clk trigger set pre cmd1 echo 'trigger1'
clk trigger set pre cmd2 echo 'trigger2'


show_name_only_code () {
      clk trigger show pre --name-only
}

show_name_only_expected () {
      cat<<"EOEXPECTED"
buildcmd
cmd1
cmd2
EOEXPECTED
}

echo 'Run show_name_only'

{ show_name_only_code || true ; } > "${TMP}/code.txt" 2>&1
show_name_only_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show_name_only"
exit 1
}
# listing triggers with --name-only:3 ends here
