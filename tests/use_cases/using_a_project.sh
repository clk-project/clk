#!/bin/bash -eu
# [[file:../../doc/use_cases/using_a_project.org::run][run]]
. ./sandboxing.sh

mkdir myprojet && cd myprojet && mkdir .clk


usingaliases_code () {
      clk alias set somelocalcommand echo hello
}

usingaliases_expected () {
      cat<<"EOEXPECTED"
New local alias for somelocalcommand: echo hello
EOEXPECTED
}

diff -uBw <(usingaliases_code 2>&1) <(usingaliases_expected) || {
echo "Something went wrong when trying usingaliases"
exit 1
}



callingthealias_code () {
      clk somelocalcommand
}

callingthealias_expected () {
      cat<<"EOEXPECTED"
hello
EOEXPECTED
}

diff -uBw <(callingthealias_code 2>&1) <(callingthealias_expected) || {
echo "Something went wrong when trying callingthealias"
exit 1
}


cd ..


callingthealiasoutsideoftheproject_code () {
      clk somelocalcommand
}

callingthealiasoutsideoftheproject_expected () {
      cat<<"EOEXPECTED"
Usage: clk [OPTIONS] COMMAND [ARGS]...
error: No such command 'somelocalcommand'.
error:
error: Did you mean one of these?
error:     command
EOEXPECTED
}

diff -uBw <(callingthealiasoutsideoftheproject_code 2>&1) <(callingthealiasoutsideoftheproject_expected) || {
echo "Something went wrong when trying callingthealiasoutsideoftheproject"
exit 1
}


cd myprojet


createaparameter_code () {
      clk parameter set echo hello
      clk echo world
}

createaparameter_expected () {
      cat<<"EOEXPECTED"
New local parameters for echo: hello
hello world
EOEXPECTED
}

diff -uBw <(createaparameter_code 2>&1) <(createaparameter_expected) || {
echo "Something went wrong when trying createaparameter"
exit 1
}



callingparameteroutsideofproject_code () {
      cd .. && clk echo world
      cd myprojet && clk echo world
}

callingparameteroutsideofproject_expected () {
      cat<<"EOEXPECTED"
world
hello world
EOEXPECTED
}

diff -uBw <(callingparameteroutsideofproject_code 2>&1) <(callingparameteroutsideofproject_expected) || {
echo "Something went wrong when trying callingparameteroutsideofproject"
exit 1
}



projectprefix_code () {
      echo somecontent > somefile.txt
      clk exec cat project:somefile.txt
}

projectprefix_expected () {
      cat<<"EOEXPECTED"
somecontent
EOEXPECTED
}

diff -uBw <(projectprefix_code 2>&1) <(projectprefix_expected) || {
echo "Something went wrong when trying projectprefix"
exit 1
}
# run ends here
