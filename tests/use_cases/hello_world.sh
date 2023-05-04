#!/bin/bash -eu
# [[file:../../README.org::hello-world][hello-world]]
. ./sandboxing.sh

clk command create bash hello-world --description "Some simple hello world command" --body 'echo "Hello world"'


run_code () {
      clk hello-world
}

run_expected () {
      cat<<EOEXPECTED
Hello world
EOEXPECTED
}

diff -uw <(run_code 2>&1) <(run_expected)
# hello-world ends here
