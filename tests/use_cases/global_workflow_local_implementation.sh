#!/usr/bin/env bash
# [[file:../../doc/use_cases/global_workflow_local_implementation.org::#summary][summary:1]]
set -eu
. ./sandboxing.sh


create-global-test_code () {
      clk alias set test echo "No tests configured" , exec false
}

create-global-test_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global alias for test: echo 'No tests configured' , exec false
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create-global-test'

{ create-global-test_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/create-global-test"
else
    create-global-test_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create-global-test"
        exit 1
    }
fi



create-test-n-push_code () {
      clk alias set test-n-push test , echo "git push"
}

create-test-n-push_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global alias for test-n-push: test , echo 'git push'
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create-test-n-push'

{ create-test-n-push_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/create-test-n-push"
else
    create-test-n-push_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create-test-n-push"
        exit 1
    }
fi



run-test-n-push-global_code () {
      clk test-n-push
}

run-test-n-push-global_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
No tests configured
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-test-n-push-global'

{ run-test-n-push-global_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-test-n-push-global"
else
    run-test-n-push-global_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-test-n-push-global"
        exit 1
    }
fi


mkdir myproject && cd myproject && mkdir .clk

clk command create bash test --description "Run the project tests" --body '
echo "Running pytest..."
echo "All 42 tests passed!"
'


run-test-n-push-local_code () {
      clk test-n-push
}

run-test-n-push-local_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running pytest...
All 42 tests passed!
git push
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-test-n-push-local'

{ run-test-n-push-local_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-test-n-push-local"
else
    run-test-n-push-local_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-test-n-push-local"
        exit 1
    }
fi



leave-project_code () {
      cd ..
      clk test-n-push
}

leave-project_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
No tests configured
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run leave-project'

{ leave-project_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/leave-project"
else
    leave-project_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying leave-project"
        exit 1
    }
fi


cd myproject


create-local-alias_code () {
      clk alias set deploy echo "Deploying to production..."
}

create-local-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New local alias for deploy: echo 'Deploying to production...'
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create-local-alias'

{ create-local-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/create-local-alias"
else
    create-local-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create-local-alias"
        exit 1
    }
fi



run-deploy_code () {
      clk deploy
}

run-deploy_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Deploying to production...
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-deploy'

{ run-deploy_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-deploy"
else
    run-deploy_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-deploy"
        exit 1
    }
fi



deploy-outside_code () {
      cd ..
      clk deploy
}

deploy-outside_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: Failed to get the command deploy: Command deploy not found
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: No such command 'deploy'.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run deploy-outside'

{ deploy-outside_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/deploy-outside"
else
    deploy-outside_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying deploy-outside"
        exit 1
    }
fi
# summary:1 ends here
