#!/bin/bash -eu
# [[file:../../README.org::hellp-world][hellp-world]]
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

diff -u <(run_code) <(run_expected)
# hellp-world ends here
