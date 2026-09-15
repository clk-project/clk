#!/usr/bin/env bash
# [[file:../../README.org::hello-world][hello-world]]
set -eu
. ./sandboxing.sh

clk command create bash hello-world --description "Some simple hello world command" --body 'echo "Hello world"'


run_code () {
      clk hello-world
}

run_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Hello world
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run'

{ run_code || true ; } > "${TMP}/code.txt" 2>&1
run_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run"
exit 1
}
# hello-world ends here
