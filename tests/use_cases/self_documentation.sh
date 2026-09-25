#!/usr/bin/env bash
# [[file:../../doc/use_cases/self_documentation.org::run][run]]
set -eu
. ./sandboxing.sh


setup-global_code () {
      clk alias set hello echo Hello
      clk parameter set echo --no-newline
}

setup-global_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m alias for hello: echo Hello
New [36mglobal[0m parameters for echo: --no-newline
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run setup-global'

{ setup-global_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/setup-global"
else
    setup-global_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying setup-global"
        exit 1
    }
fi



describe-global_code () {
      clk describe global
}

describe-global_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
The extension global is located at ./clk-root . Let's try to see what it has to offer.
##########
I found some alias:
  hello: echo Hello
I found some parameter:
  echo: --no-newline
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run describe-global'

{ describe-global_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/describe-global"
else
    describe-global_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying describe-global"
        exit 1
    }
fi



show-global-alias_code () {
      clk alias --global show
}

show-global-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
hello [2m[36m[2mecho Hello[0m[0m
[2m--------------[0m
Legend: [36m[2mglobal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-global-alias'

{ show-global-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show-global-alias"
else
    show-global-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-global-alias"
        exit 1
    }
fi



show-global-params_code () {
      clk parameter --global show | grep echo
}

show-global-params_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
echo [2m[36m[2m--no-newline[0m[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-global-params'

{ show-global-params_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show-global-params"
else
    show-global-params_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-global-params"
        exit 1
    }
fi


mkdir myproject && cd myproject && mkdir .clk


setup-local_code () {
      clk alias set build echo Building the project
      clk alias set test echo Running tests
      clk parameter set build --verbose
}

setup-local_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [32mlocal[0m alias for build: echo Building the project
New [32mlocal[0m alias for test: echo Running tests
New [32mlocal[0m parameters for build: --verbose
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run setup-local'

{ setup-local_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/setup-local"
else
    setup-local_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying setup-local"
        exit 1
    }
fi



describe-local_code () {
      clk describe local
}

describe-local_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
The extension local is located at ./.clk . Let's try to see what it has to offer.
##########
I found some alias:
  build: echo Building the project
  test: echo Running tests
I found some parameter:
  build: --verbose
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run describe-local'

{ describe-local_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/describe-local"
else
    describe-local_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying describe-local"
        exit 1
    }
fi



show-local-alias_code () {
      clk alias --local show
}

show-local-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
build [2m[32m[2mecho Building the project[0m[0m
test [2m[32m[2mecho Running tests[0m[0m
[2m-------------[0m
Legend: [32m[2mlocal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-local-alias'

{ show-local-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show-local-alias"
else
    show-local-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-local-alias"
        exit 1
    }
fi



create-extension_code () {
      clk extension create mytools
      clk alias set --extension mytools greet echo Greetings
}

create-extension_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [35m[1mlocal/mytools[0m alias for greet: echo Greetings
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create-extension'

{ create-extension_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/create-extension"
else
    create-extension_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create-extension"
        exit 1
    }
fi


clk command create --extension mytools bash --description "Show current date and time" --body 'date' now


describe-extension_code () {
      clk describe local/mytools
}

describe-extension_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
The extension local/mytools is located at ./.clk/extensions/mytools . Let's try to see what it has to offer.
##########
I found some alias:
  greet: echo Greetings
I found some commands:
  now
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run describe-extension'

{ describe-extension_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/describe-extension"
else
    describe-extension_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying describe-extension"
        exit 1
    }
fi


clk command create bash --description "Deploy the application" --body 'echo Deploying...' deploy


describe-with-commands_code () {
      clk describe local
}

describe-with-commands_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
The extension local is located at ./.clk . Let's try to see what it has to offer.
##########
I found some alias:
  build: echo Building the project
  test: echo Running tests
I found some parameter:
  build: --verbose
I found some commands:
  deploy
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run describe-with-commands'

{ describe-with-commands_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/describe-with-commands"
else
    describe-with-commands_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying describe-with-commands"
        exit 1
    }
fi



list-commands_code () {
      clk command --local list
}

list-commands_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./.clk/bin/deploy
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run list-commands'

{ list-commands_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/list-commands"
else
    list-commands_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying list-commands"
        exit 1
    }
fi



setup-value_code () {
      clk value set deploy-target staging
      clk extension disable mytools
}

setup-value_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run setup-value'

{ setup-value_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/setup-value"
else
    setup-value_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying setup-value"
        exit 1
    }
fi



describe-values_code () {
      clk describe local
}

describe-values_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
The extension local is located at ./.clk . Let's try to see what it has to offer.
##########
I found some alias:
  build: echo Building the project
  test: echo Running tests
I found some parameter:
  build: --verbose
I found some value:
  deploy-target: staging
I found some extension:
  mytools: disabled
I found some commands:
  deploy
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run describe-values'

{ describe-values_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/describe-values"
else
    describe-values_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying describe-values"
        exit 1
    }
fi


sed -i '1a\    "weather": {"today": "rainy"},' .clk/clk.json5


describe-unknown-setting_code () {
      clk describe local | tail -2
}

describe-unknown-setting_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
  deploy
I also found some settings that I cannot explain: weather. They might have been set by other plugins, custom commands or extensions.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run describe-unknown-setting'

{ describe-unknown-setting_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/describe-unknown-setting"
else
    describe-unknown-setting_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying describe-unknown-setting"
        exit 1
    }
fi
# run ends here
