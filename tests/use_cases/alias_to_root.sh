#!/usr/bin/env bash -eu
# [[file:../../doc/use_cases/alias_to_root.org::#tidying-up-as-the-aliases-pile-up][tidying up as the aliases pile up:17]]
. ./sandboxing.sh
mkdir -p billing-api/.clk
cd billing-api

alias-api-build_code () {
      clk alias set build echo "Building the API"
}

alias-api-build_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [32mlocal[0m alias for build: echo 'Building the API'
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run alias-api-build'

{ alias-api-build_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/alias-api-build"
else
    alias-api-build_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying alias-api-build"
        exit 1
    }
fi


alias-api-test_code () {
      clk alias set test echo "Running API tests"
}

alias-api-test_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [32mlocal[0m alias for test: echo 'Running API tests'
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run alias-api-test'

{ alias-api-test_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/alias-api-test"
else
    alias-api-test_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying alias-api-test"
        exit 1
    }
fi

cd ..
mkdir -p billing-app/.clk
cd billing-app

alias-app-build_code () {
      clk alias set build echo "Building the frontend"
}

alias-app-build_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [32mlocal[0m alias for build: echo 'Building the frontend'
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run alias-app-build'

{ alias-app-build_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/alias-app-build"
else
    alias-app-build_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying alias-app-build"
        exit 1
    }
fi


alias-app-test_code () {
      clk alias set test echo "Running frontend tests"
}

alias-app-test_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [32mlocal[0m alias for test: echo 'Running frontend tests'
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run alias-app-test'

{ alias-app-test_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/alias-app-test"
else
    alias-app-test_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying alias-app-test"
        exit 1
    }
fi


api-build-from-app_code () {
      clk build 2>/dev/null
}

api-build-from-app_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building the frontend
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run api-build-from-app'

{ api-build-from-app_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/api-build-from-app"
else
    api-build-from-app_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying api-build-from-app"
        exit 1
    }
fi


verbose-project_code () {
      clk --project ../billing-api build 2>/dev/null
}

verbose-project_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building the API
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run verbose-project'

{ verbose-project_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/verbose-project"
else
    verbose-project_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying verbose-project"
        exit 1
    }
fi

cd ..

create-api-alias_code () {
      clk alias set api clk --project ./billing-api
}

create-api-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m alias for api: clk --project ./billing-api
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create-api-alias'

{ create-api-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/create-api-alias"
else
    create-api-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create-api-alias"
        exit 1
    }
fi


create-app-alias_code () {
      clk alias set app clk --project ./billing-app
}

create-app-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m alias for app: clk --project ./billing-app
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create-app-alias'

{ create-app-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/create-app-alias"
else
    create-app-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create-app-alias"
        exit 1
    }
fi


api-build_code () {
      clk api build 2>/dev/null
}

api-build_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building the API
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run api-build'

{ api-build_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/api-build"
else
    api-build_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying api-build"
        exit 1
    }
fi


app-build_code () {
      clk app build 2>/dev/null
}

app-build_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building the frontend
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run app-build'

{ app-build_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/app-build"
else
    app-build_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying app-build"
        exit 1
    }
fi


api-test_code () {
      clk api test 2>/dev/null
}

api-test_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running API tests
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run api-test'

{ api-test_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/api-test"
else
    api-test_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying api-test"
        exit 1
    }
fi


app-test_code () {
      clk app test 2>/dev/null
}

app-test_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running frontend tests
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run app-test'

{ app-test_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/app-test"
else
    app-test_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying app-test"
        exit 1
    }
fi


show-api-alias_code () {
      clk api alias show build 2>/dev/null
}

show-api-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
build [2m[32m[2mecho Building the API[0m[0m
[2m-------------[0m
Legend: [32m[2mlocal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-api-alias'

{ show-api-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show-api-alias"
else
    show-api-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-api-alias"
        exit 1
    }
fi



help-through-the-alias_code () {
      clk api build --help 2>/dev/null | grep -A1 "This is a sub command"
}

help-through-the-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
  This is a sub command of 'api' that is an alias towards 'clk'. To edit it, try getting help from both of them or from
  the subcommand of the original group (something like `clk build --help`)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run help-through-the-alias'

{ help-through-the-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/help-through-the-alias"
else
    help-through-the-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying help-through-the-alias"
        exit 1
    }
fi


remove-global-api-alias_code () {
      clk alias unset api
}

remove-global-api-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Erasing api alias from [36mglobal[0m settings
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run remove-global-api-alias'

{ remove-global-api-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/remove-global-api-alias"
else
    remove-global-api-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying remove-global-api-alias"
        exit 1
    }
fi


remove-global-app-alias_code () {
      clk alias unset app
}

remove-global-app-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Erasing app alias from [36mglobal[0m settings
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run remove-global-app-alias'

{ remove-global-app-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/remove-global-app-alias"
else
    remove-global-app-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying remove-global-app-alias"
        exit 1
    }
fi

cd billing-api

local-api-app-alias_code () {
      clk alias set app clk --project ../billing-app
}

local-api-app-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [32mlocal[0m alias for app: clk --project ../billing-app
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run local-api-app-alias'

{ local-api-app-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/local-api-app-alias"
else
    local-api-app-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying local-api-app-alias"
        exit 1
    }
fi

cd ..
cd billing-app

local-app-api-alias_code () {
      clk alias set api clk --project ../billing-api
}

local-app-api-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [32mlocal[0m alias for api: clk --project ../billing-api
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run local-app-api-alias'

{ local-app-api-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/local-app-api-alias"
else
    local-app-api-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying local-app-api-alias"
        exit 1
    }
fi


local-api-build_code () {
      clk api build 2>/dev/null
}

local-api-build_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building the API
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run local-api-build'

{ local-api-build_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/local-api-build"
else
    local-api-build_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying local-api-build"
        exit 1
    }
fi


local-api-test_code () {
      clk api test 2>/dev/null
}

local-api-test_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running API tests
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run local-api-test'

{ local-api-test_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/local-api-test"
else
    local-api-test_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying local-api-test"
        exit 1
    }
fi

cd ..
cd billing-api

local-app-build_code () {
      clk app build 2>/dev/null
}

local-app-build_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building the frontend
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run local-app-build'

{ local-app-build_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/local-app-build"
else
    local-app-build_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying local-app-build"
        exit 1
    }
fi


local-app-test_code () {
      clk app test 2>/dev/null
}

local-app-test_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running frontend tests
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run local-app-test'

{ local-app-test_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/local-app-test"
else
    local-app-test_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying local-app-test"
        exit 1
    }
fi


promote-build_code () {
      clk alias move build global
}

promote-build_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Moved alias build, [32mlocal[0m -> [36mglobal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run promote-build'

{ promote-build_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/promote-build"
else
    promote-build_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying promote-build"
        exit 1
    }
fi


promoted-build_code () {
      clk build
}

promoted-build_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building the API
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run promoted-build'

{ promoted-build_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/promoted-build"
else
    promoted-build_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying promoted-build"
        exit 1
    }
fi

cd ../billing-app

shadowed-build_code () {
      clk build
}

shadowed-build_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building the frontend
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run shadowed-build'

{ shadowed-build_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/shadowed-build"
else
    shadowed-build_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying shadowed-build"
        exit 1
    }
fi


ship_code () {
      clk alias set ship build , test
}

ship_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [32mlocal[0m alias for ship: build , test
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run ship'

{ ship_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/ship"
else
    ship_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying ship"
        exit 1
    }
fi


quiet-ship_code () {
      clk --quiet alias set ship-nightly build , test
      clk alias show ship-nightly
}

quiet-ship_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
ship-nightly [2m[32m[2mbuild, test[0m[0m
[2m-------------[0m
Legend: [32m[2mlocal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run quiet-ship'

{ quiet-ship_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/quiet-ship"
else
    quiet-ship_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying quiet-ship"
        exit 1
    }
fi


ship-help-before_code () {
      clk ship --help | head -3
}

ship-help-before_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk ship [OPTIONS] [MESSAGE]...

  Alias for: build , test
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run ship-help-before'

{ ship-help-before_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/ship-help-before"
else
    ship-help-before_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying ship-help-before"
        exit 1
    }
fi

clk alias set-documentation ship "Build and test the frontend"

ship-help-after_code () {
      clk ship --help | head -3
}

ship-help-after_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk ship [OPTIONS] [MESSAGE]...

  Build and test the frontend
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run ship-help-after'

{ ship-help-after_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/ship-help-after"
else
    ship-help-after_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying ship-help-after"
        exit 1
    }
fi


copy-ship_code () {
      clk alias copy ship ship-all
}

copy-ship_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Copied alias ship -> ship-all in local
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run copy-ship'

{ copy-ship_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/copy-ship"
else
    copy-ship_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying copy-ship"
        exit 1
    }
fi

clk alias append ship-all api build , api test

dry-run-rename_code () {
      clk --dry-run alias rename test test-front
}

dry-run-rename_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Would have moved alias test -> test-front in local
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run dry-run-rename'

{ dry-run-rename_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/dry-run-rename"
else
    dry-run-rename_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying dry-run-rename"
        exit 1
    }
fi


show-before-rename_code () {
      clk alias show
}

show-before-rename_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
api [2m[32m[2mclk --project ../billing-api[0m[0m
build [2m[32m[2mecho Building the frontend[0m[0m
ship [2m[32m[2mbuild, test[0m[0m
ship-all [2m[32m[2mbuild, test, api build, api test[0m[0m
ship-nightly [2m[32m[2mbuild, test[0m[0m
test [2m[32m[2mecho Running frontend tests[0m[0m
[2m-------------[0m
Legend: [32m[2mlocal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-before-rename'

{ show-before-rename_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show-before-rename"
else
    show-before-rename_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-before-rename"
        exit 1
    }
fi


rename-test_code () {
      clk alias rename test test-front
}

rename-test_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Moved alias test -> test-front in local
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run rename-test'

{ rename-test_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/rename-test"
else
    rename-test_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying rename-test"
        exit 1
    }
fi


show-after-rename_code () {
      clk alias show
}

show-after-rename_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
api [2m[32m[2mclk --project ../billing-api[0m[0m
build [2m[32m[2mecho Building the frontend[0m[0m
ship [2m[32m[2mbuild, test-front[0m[0m
ship-all [2m[32m[2mbuild, test-front, api build, api test[0m[0m
ship-nightly [2m[32m[2mbuild, test-front[0m[0m
test-front [2m[32m[2mecho Running frontend tests[0m[0m
[2m-------------[0m
Legend: [32m[2mlocal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-after-rename'

{ show-after-rename_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/show-after-rename"
else
    show-after-rename_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-after-rename"
        exit 1
    }
fi


dash-alias_code () {
      clk alias set -ship build
}

dash-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk alias set [OPTIONS] ALIAS COMMAND [PARAMS]...
error: Aliases must not start with dashes (-)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run dash-alias'

{ dash-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/dash-alias"
else
    dash-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying dash-alias"
        exit 1
    }
fi


punctuation-alias_code () {
      clk alias set ,ship build
}

punctuation-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: Invalid alias name: ,ship. An alias must start with a letter, a digit or an underscore
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run punctuation-alias'

{ punctuation-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/punctuation-alias"
else
    punctuation-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying punctuation-alias"
        exit 1
    }
fi

clk alias --global set deploy-prod echo Deploying to production

document-elsewhere_code () {
      clk alias set-documentation deploy-prod "Ship to production"
}

document-elsewhere_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: The profile local has no 'deploy-prod' alias registered. Try using another profile option (like --local or --global)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run document-elsewhere'

{ document-elsewhere_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/document-elsewhere"
else
    document-elsewhere_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying document-elsewhere"
        exit 1
    }
fi


unset-elsewhere_code () {
      clk alias unset deploy-prod
}

unset-elsewhere_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: The profile local has no alias named 'deploy-prod'. Try using another profile option (like --local or --global)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unset-elsewhere'

{ unset-elsewhere_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/unset-elsewhere"
else
    unset-elsewhere_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying unset-elsewhere"
        exit 1
    }
fi
# tidying up as the aliases pile up:17 ends here
