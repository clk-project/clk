#!/bin/bash -eu
# [[file:using_a_project.org::run][run]]
. ./sandboxing.sh

mkdir myprojet && cd myprojet && mkdir .clk


usingaliases_code () {
      clk alias set somelocalcommand echo hello
}

usingaliases_expected () {
      cat<<EOEXPECTED
New local alias for somelocalcommand: echo hello
EOEXPECTED
}

diff -uw <(usingaliases_code 2>&1) <(usingaliases_expected)



callingthealias_code () {
      clk somelocalcommand
}

callingthealias_expected () {
      cat<<EOEXPECTED
hello
EOEXPECTED
}

diff -uw <(callingthealias_code 2>&1) <(callingthealias_expected)


cd ..


callingthealiasoutsideoftheproject_code () {
      clk somelocalcommand
}

callingthealiasoutsideoftheproject_expected () {
      cat<<EOEXPECTED
Usage: clk [OPTIONS] COMMAND [ARGS]...
error: No such command 'somelocalcommand'.
error:
error: Did you mean one of these?
error:     command
EOEXPECTED
}

diff -uw <(callingthealiasoutsideoftheproject_code 2>&1) <(callingthealiasoutsideoftheproject_expected)


cd myprojet


createaparameter_code () {
      clk parameter set echo hello
      clk echo world
}

createaparameter_expected () {
      cat<<EOEXPECTED
New local parameters for echo: hello
hello world
EOEXPECTED
}

diff -uw <(createaparameter_code 2>&1) <(createaparameter_expected)



callingparameteroutsideofproject_code () {
      cd .. && clk echo world
      cd myprojet && clk echo world
}

callingparameteroutsideofproject_expected () {
      cat<<EOEXPECTED
world
hello world
EOEXPECTED
}

diff -uw <(callingparameteroutsideofproject_code 2>&1) <(callingparameteroutsideofproject_expected)



projectprefix_code () {
      echo somecontent > somefile.txt
      clk exec cat project:somefile.txt
}

projectprefix_expected () {
      cat<<EOEXPECTED
somecontent
EOEXPECTED
}

diff -uw <(projectprefix_code 2>&1) <(projectprefix_expected)
# run ends here
