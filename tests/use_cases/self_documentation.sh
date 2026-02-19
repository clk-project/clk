#!/bin/bash -eu
# [[file:../../doc/use_cases/self_documentation.org::run][run]]
. ./sandboxing.sh


setup-global_code () {
      clk alias set hello echo Hello
      clk parameter set echo --no-newline
}

setup-global_expected () {
      cat<<"EOEXPECTED"
New global alias for hello: echo Hello
New global parameters for echo: --no-newline
EOEXPECTED
}

echo 'Run setup-global'

{ setup-global_code || true ; } > "${TMP}/code.txt" 2>&1
setup-global_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying setup-global"
exit 1
}



describe-global_code () {
      clk describe global
}

describe-global_expected () {
      cat<<"EOEXPECTED"
The extension global is located at ./clk-root . Let's try to see what it has to offer.
##########
I found some alias, try running `clk alias --global show` to know more.
I found some parameter, try running `clk parameter --global show` to know more.
I found some value, try running `clk value --global show` to know more.
EOEXPECTED
}

echo 'Run describe-global'

{ describe-global_code || true ; } > "${TMP}/code.txt" 2>&1
describe-global_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying describe-global"
exit 1
}



show-global-alias_code () {
      clk alias --global show
}

show-global-alias_expected () {
      cat<<"EOEXPECTED"
hello echo Hello
EOEXPECTED
}

echo 'Run show-global-alias'

{ show-global-alias_code || true ; } > "${TMP}/code.txt" 2>&1
show-global-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-global-alias"
exit 1
}



show-global-params_code () {
      clk parameter --global show | grep echo
}

show-global-params_expected () {
      cat<<"EOEXPECTED"
echo --no-newline
EOEXPECTED
}

echo 'Run show-global-params'

{ show-global-params_code || true ; } > "${TMP}/code.txt" 2>&1
show-global-params_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-global-params"
exit 1
}


mkdir myproject && cd myproject && mkdir .clk


setup-local_code () {
      clk alias set build echo Building the project
      clk alias set test echo Running tests
      clk parameter set build --verbose
}

setup-local_expected () {
      cat<<"EOEXPECTED"
New local alias for build: echo Building the project
New local alias for test: echo Running tests
New local parameters for build: --verbose
EOEXPECTED
}

echo 'Run setup-local'

{ setup-local_code || true ; } > "${TMP}/code.txt" 2>&1
setup-local_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying setup-local"
exit 1
}



describe-local_code () {
      clk describe local
}

describe-local_expected () {
      cat<<"EOEXPECTED"
The extension local is located at ./.clk . Let's try to see what it has to offer.
##########
I found some alias, try running `clk alias --local show` to know more.
I found some parameter, try running `clk parameter --local show` to know more.
EOEXPECTED
}

echo 'Run describe-local'

{ describe-local_code || true ; } > "${TMP}/code.txt" 2>&1
describe-local_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying describe-local"
exit 1
}



show-local-alias_code () {
      clk alias --local show
}

show-local-alias_expected () {
      cat<<"EOEXPECTED"
build echo Building the project
test echo Running tests
EOEXPECTED
}

echo 'Run show-local-alias'

{ show-local-alias_code || true ; } > "${TMP}/code.txt" 2>&1
show-local-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-local-alias"
exit 1
}



create-extension_code () {
      clk extension create mytools
      clk alias set --extension mytools greet echo Greetings
}

create-extension_expected () {
      cat<<"EOEXPECTED"
New local/mytools alias for greet: echo Greetings
EOEXPECTED
}

echo 'Run create-extension'

{ create-extension_code || true ; } > "${TMP}/code.txt" 2>&1
create-extension_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create-extension"
exit 1
}


clk command create --extension mytools bash --description "Show current date and time" --body 'date' now


describe-extension_code () {
      clk describe local/mytools
}

describe-extension_expected () {
      cat<<"EOEXPECTED"
The extension local/mytools is located at ./.clk/extensions/mytools . Let's try to see what it has to offer.
##########
I found some alias, try running `clk --extension mytools alias --local --extension mytools show` to know more.
I found some executable commands, try running `clk --extension mytools command --local --extension mytools list` to know more.
EOEXPECTED
}

echo 'Run describe-extension'

{ describe-extension_code || true ; } > "${TMP}/code.txt" 2>&1
describe-extension_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying describe-extension"
exit 1
}


clk command create bash --description "Deploy the application" --body 'echo Deploying...' deploy


describe-with-commands_code () {
      clk describe local
}

describe-with-commands_expected () {
      cat<<"EOEXPECTED"
The extension local is located at ./.clk . Let's try to see what it has to offer.
##########
I found some alias, try running `clk alias --local show` to know more.
I found some parameter, try running `clk parameter --local show` to know more.
I found some executable commands, try running `clk command --local list` to know more.
EOEXPECTED
}

echo 'Run describe-with-commands'

{ describe-with-commands_code || true ; } > "${TMP}/code.txt" 2>&1
describe-with-commands_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying describe-with-commands"
exit 1
}



list-commands_code () {
      clk command --local list
}

list-commands_expected () {
      cat<<"EOEXPECTED"
./.clk/bin/deploy
EOEXPECTED
}

echo 'Run list-commands'

{ list-commands_code || true ; } > "${TMP}/code.txt" 2>&1
list-commands_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying list-commands"
exit 1
}
# run ends here
