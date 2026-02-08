#!/bin/bash -eu
# [[file:../../README.org::hello-world][hello-world]]
. ./sandboxing.sh

clk command create bash hello-world --description "Some simple hello world command" --body 'echo "Hello world"'


run_code () {
      clk hello-world
}

run_expected () {
      cat<<"EOEXPECTED"
Hello world
EOEXPECTED
}

echo 'Run run'

{ run_code || true ; } > "${TMP}/code.txt" 2>&1
run_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run"
exit 1
}
# hello-world ends here
