#!/usr/bin/env bash -eu
# [[file:../../doc/use_cases/alias_to_root.org::#tidying-up-as-the-aliases-pile-up][tidying up as the aliases pile up:12]]
. ./sandboxing.sh
mkdir -p billing-api/.clk
cd billing-api

alias-api-build_code () {
      clk alias set build echo "Building the API"
}

alias-api-build_expected () {
      cat<<"EOEXPECTED"
New local alias for build: echo 'Building the API'
EOEXPECTED
}

echo 'Run alias-api-build'

{ alias-api-build_code || true ; } > "${TMP}/code.txt" 2>&1
alias-api-build_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying alias-api-build"
exit 1
}


alias-api-test_code () {
      clk alias set test echo "Running API tests"
}

alias-api-test_expected () {
      cat<<"EOEXPECTED"
New local alias for test: echo 'Running API tests'
EOEXPECTED
}

echo 'Run alias-api-test'

{ alias-api-test_code || true ; } > "${TMP}/code.txt" 2>&1
alias-api-test_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying alias-api-test"
exit 1
}

cd ..
mkdir -p billing-app/.clk
cd billing-app

alias-app-build_code () {
      clk alias set build echo "Building the frontend"
}

alias-app-build_expected () {
      cat<<"EOEXPECTED"
New local alias for build: echo 'Building the frontend'
EOEXPECTED
}

echo 'Run alias-app-build'

{ alias-app-build_code || true ; } > "${TMP}/code.txt" 2>&1
alias-app-build_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying alias-app-build"
exit 1
}


alias-app-test_code () {
      clk alias set test echo "Running frontend tests"
}

alias-app-test_expected () {
      cat<<"EOEXPECTED"
New local alias for test: echo 'Running frontend tests'
EOEXPECTED
}

echo 'Run alias-app-test'

{ alias-app-test_code || true ; } > "${TMP}/code.txt" 2>&1
alias-app-test_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying alias-app-test"
exit 1
}


api-build-from-app_code () {
      clk build 2>/dev/null
}

api-build-from-app_expected () {
      cat<<"EOEXPECTED"
Building the frontend
EOEXPECTED
}

echo 'Run api-build-from-app'

{ api-build-from-app_code || true ; } > "${TMP}/code.txt" 2>&1
api-build-from-app_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying api-build-from-app"
exit 1
}


verbose-project_code () {
      clk --project ../billing-api build 2>/dev/null
}

verbose-project_expected () {
      cat<<"EOEXPECTED"
Building the API
EOEXPECTED
}

echo 'Run verbose-project'

{ verbose-project_code || true ; } > "${TMP}/code.txt" 2>&1
verbose-project_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying verbose-project"
exit 1
}

cd ..

create-api-alias_code () {
      clk alias set api clk --project ./billing-api
}

create-api-alias_expected () {
      cat<<"EOEXPECTED"
New global alias for api: clk --project ./billing-api
EOEXPECTED
}

echo 'Run create-api-alias'

{ create-api-alias_code || true ; } > "${TMP}/code.txt" 2>&1
create-api-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create-api-alias"
exit 1
}


create-app-alias_code () {
      clk alias set app clk --project ./billing-app
}

create-app-alias_expected () {
      cat<<"EOEXPECTED"
New global alias for app: clk --project ./billing-app
EOEXPECTED
}

echo 'Run create-app-alias'

{ create-app-alias_code || true ; } > "${TMP}/code.txt" 2>&1
create-app-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create-app-alias"
exit 1
}


api-build_code () {
      clk api build 2>/dev/null
}

api-build_expected () {
      cat<<"EOEXPECTED"
Building the API
EOEXPECTED
}

echo 'Run api-build'

{ api-build_code || true ; } > "${TMP}/code.txt" 2>&1
api-build_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying api-build"
exit 1
}


app-build_code () {
      clk app build 2>/dev/null
}

app-build_expected () {
      cat<<"EOEXPECTED"
Building the frontend
EOEXPECTED
}

echo 'Run app-build'

{ app-build_code || true ; } > "${TMP}/code.txt" 2>&1
app-build_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying app-build"
exit 1
}


api-test_code () {
      clk api test 2>/dev/null
}

api-test_expected () {
      cat<<"EOEXPECTED"
Running API tests
EOEXPECTED
}

echo 'Run api-test'

{ api-test_code || true ; } > "${TMP}/code.txt" 2>&1
api-test_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying api-test"
exit 1
}


app-test_code () {
      clk app test 2>/dev/null
}

app-test_expected () {
      cat<<"EOEXPECTED"
Running frontend tests
EOEXPECTED
}

echo 'Run app-test'

{ app-test_code || true ; } > "${TMP}/code.txt" 2>&1
app-test_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying app-test"
exit 1
}


show-api-alias_code () {
      clk api alias show build 2>/dev/null
}

show-api-alias_expected () {
      cat<<"EOEXPECTED"
build echo Building the API
EOEXPECTED
}

echo 'Run show-api-alias'

{ show-api-alias_code || true ; } > "${TMP}/code.txt" 2>&1
show-api-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-api-alias"
exit 1
}



help-through-the-alias_code () {
      clk api build --help 2>/dev/null | grep -A1 "This is a sub command"
}

help-through-the-alias_expected () {
      cat<<"EOEXPECTED"
  This is a sub command of 'api' that is an alias towards 'clk'. To edit it, try getting help from both of them or from
  the subcommand of the original group (something like `clk build --help`)
EOEXPECTED
}

echo 'Run help-through-the-alias'

{ help-through-the-alias_code || true ; } > "${TMP}/code.txt" 2>&1
help-through-the-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying help-through-the-alias"
exit 1
}


remove-global-api-alias_code () {
      clk alias unset api
}

remove-global-api-alias_expected () {
      cat<<"EOEXPECTED"
Erasing api alias from global settings
EOEXPECTED
}

echo 'Run remove-global-api-alias'

{ remove-global-api-alias_code || true ; } > "${TMP}/code.txt" 2>&1
remove-global-api-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying remove-global-api-alias"
exit 1
}


remove-global-app-alias_code () {
      clk alias unset app
}

remove-global-app-alias_expected () {
      cat<<"EOEXPECTED"
Erasing app alias from global settings
EOEXPECTED
}

echo 'Run remove-global-app-alias'

{ remove-global-app-alias_code || true ; } > "${TMP}/code.txt" 2>&1
remove-global-app-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying remove-global-app-alias"
exit 1
}

cd billing-api

local-api-app-alias_code () {
      clk alias set app clk --project ../billing-app
}

local-api-app-alias_expected () {
      cat<<"EOEXPECTED"
New local alias for app: clk --project ../billing-app
EOEXPECTED
}

echo 'Run local-api-app-alias'

{ local-api-app-alias_code || true ; } > "${TMP}/code.txt" 2>&1
local-api-app-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying local-api-app-alias"
exit 1
}

cd ..
cd billing-app

local-app-api-alias_code () {
      clk alias set api clk --project ../billing-api
}

local-app-api-alias_expected () {
      cat<<"EOEXPECTED"
New local alias for api: clk --project ../billing-api
EOEXPECTED
}

echo 'Run local-app-api-alias'

{ local-app-api-alias_code || true ; } > "${TMP}/code.txt" 2>&1
local-app-api-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying local-app-api-alias"
exit 1
}


local-api-build_code () {
      clk api build 2>/dev/null
}

local-api-build_expected () {
      cat<<"EOEXPECTED"
Building the API
EOEXPECTED
}

echo 'Run local-api-build'

{ local-api-build_code || true ; } > "${TMP}/code.txt" 2>&1
local-api-build_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying local-api-build"
exit 1
}


local-api-test_code () {
      clk api test 2>/dev/null
}

local-api-test_expected () {
      cat<<"EOEXPECTED"
Running API tests
EOEXPECTED
}

echo 'Run local-api-test'

{ local-api-test_code || true ; } > "${TMP}/code.txt" 2>&1
local-api-test_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying local-api-test"
exit 1
}

cd ..
cd billing-api

local-app-build_code () {
      clk app build 2>/dev/null
}

local-app-build_expected () {
      cat<<"EOEXPECTED"
Building the frontend
EOEXPECTED
}

echo 'Run local-app-build'

{ local-app-build_code || true ; } > "${TMP}/code.txt" 2>&1
local-app-build_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying local-app-build"
exit 1
}


local-app-test_code () {
      clk app test 2>/dev/null
}

local-app-test_expected () {
      cat<<"EOEXPECTED"
Running frontend tests
EOEXPECTED
}

echo 'Run local-app-test'

{ local-app-test_code || true ; } > "${TMP}/code.txt" 2>&1
local-app-test_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying local-app-test"
exit 1
}


promote-build_code () {
      clk alias move build global
}

promote-build_expected () {
      cat<<"EOEXPECTED"
Moved alias build, local -> global
EOEXPECTED
}

echo 'Run promote-build'

{ promote-build_code || true ; } > "${TMP}/code.txt" 2>&1
promote-build_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying promote-build"
exit 1
}


promoted-build_code () {
      clk build
}

promoted-build_expected () {
      cat<<"EOEXPECTED"
Building the API
EOEXPECTED
}

echo 'Run promoted-build'

{ promoted-build_code || true ; } > "${TMP}/code.txt" 2>&1
promoted-build_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying promoted-build"
exit 1
}

cd ../billing-app

shadowed-build_code () {
      clk build
}

shadowed-build_expected () {
      cat<<"EOEXPECTED"
Building the frontend
EOEXPECTED
}

echo 'Run shadowed-build'

{ shadowed-build_code || true ; } > "${TMP}/code.txt" 2>&1
shadowed-build_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying shadowed-build"
exit 1
}


ship_code () {
      clk alias set ship build , test
}

ship_expected () {
      cat<<"EOEXPECTED"
New local alias for ship: build , test
EOEXPECTED
}

echo 'Run ship'

{ ship_code || true ; } > "${TMP}/code.txt" 2>&1
ship_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying ship"
exit 1
}


quiet-ship_code () {
      clk --quiet alias set ship-nightly build , test
      clk alias show ship-nightly
}

quiet-ship_expected () {
      cat<<"EOEXPECTED"
ship-nightly build, test
EOEXPECTED
}

echo 'Run quiet-ship'

{ quiet-ship_code || true ; } > "${TMP}/code.txt" 2>&1
quiet-ship_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying quiet-ship"
exit 1
}


ship-help-before_code () {
      clk ship --help | head -3
}

ship-help-before_expected () {
      cat<<"EOEXPECTED"
Usage: clk ship [OPTIONS] [MESSAGE]...

  Alias for: build , test
EOEXPECTED
}

echo 'Run ship-help-before'

{ ship-help-before_code || true ; } > "${TMP}/code.txt" 2>&1
ship-help-before_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying ship-help-before"
exit 1
}

clk alias set-documentation ship "Build and test the frontend"

ship-help-after_code () {
      clk ship --help | head -3
}

ship-help-after_expected () {
      cat<<"EOEXPECTED"
Usage: clk ship [OPTIONS] [MESSAGE]...

  Build and test the frontend
EOEXPECTED
}

echo 'Run ship-help-after'

{ ship-help-after_code || true ; } > "${TMP}/code.txt" 2>&1
ship-help-after_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying ship-help-after"
exit 1
}


copy-ship_code () {
      clk alias copy ship ship-all
}

copy-ship_expected () {
      cat<<"EOEXPECTED"
Copied alias ship -> ship-all in local
EOEXPECTED
}

echo 'Run copy-ship'

{ copy-ship_code || true ; } > "${TMP}/code.txt" 2>&1
copy-ship_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying copy-ship"
exit 1
}

clk alias append ship-all api build , api test

dry-run-rename_code () {
      clk --dry-run alias rename test test-front
}

dry-run-rename_expected () {
      cat<<"EOEXPECTED"
Would have moved alias test -> test-front in local
EOEXPECTED
}

echo 'Run dry-run-rename'

{ dry-run-rename_code || true ; } > "${TMP}/code.txt" 2>&1
dry-run-rename_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying dry-run-rename"
exit 1
}


show-before-rename_code () {
      clk alias show
}

show-before-rename_expected () {
      cat<<"EOEXPECTED"
api clk --project ../billing-api
build echo Building the frontend
ship build, test
ship-all build, test, api build, api test
ship-nightly build, test
test echo Running frontend tests
EOEXPECTED
}

echo 'Run show-before-rename'

{ show-before-rename_code || true ; } > "${TMP}/code.txt" 2>&1
show-before-rename_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-before-rename"
exit 1
}


rename-test_code () {
      clk alias rename test test-front
}

rename-test_expected () {
      cat<<"EOEXPECTED"
Moved alias test -> test-front in local
EOEXPECTED
}

echo 'Run rename-test'

{ rename-test_code || true ; } > "${TMP}/code.txt" 2>&1
rename-test_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying rename-test"
exit 1
}


show-after-rename_code () {
      clk alias show
}

show-after-rename_expected () {
      cat<<"EOEXPECTED"
api clk --project ../billing-api
build echo Building the frontend
ship build, test-front
ship-all build, test-front, api build, api test
ship-nightly build, test-front
test-front echo Running frontend tests
EOEXPECTED
}

echo 'Run show-after-rename'

{ show-after-rename_code || true ; } > "${TMP}/code.txt" 2>&1
show-after-rename_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-after-rename"
exit 1
}
# tidying up as the aliases pile up:12 ends here
