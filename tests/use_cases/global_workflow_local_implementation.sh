#!/bin/bash -eu
# [[file:../../doc/use_cases/global_workflow_local_implementation.org::*summary][summary:1]]
. ./sandboxing.sh


create-global-test_code () {
      clk alias set test echo "No tests configured" , exec false
}

create-global-test_expected () {
      cat<<"EOEXPECTED"
New global alias for test: echo 'No tests configured' , exec false
EOEXPECTED
}

echo 'Run create-global-test'

{ create-global-test_code || true ; } > "${TMP}/code.txt" 2>&1
create-global-test_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create-global-test"
exit 1
}



create-test-n-push_code () {
      clk alias set test-n-push test , echo "git push"
}

create-test-n-push_expected () {
      cat<<"EOEXPECTED"
New global alias for test-n-push: test , echo 'git push'
EOEXPECTED
}

echo 'Run create-test-n-push'

{ create-test-n-push_code || true ; } > "${TMP}/code.txt" 2>&1
create-test-n-push_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create-test-n-push"
exit 1
}



run-test-n-push-global_code () {
      clk test-n-push
}

run-test-n-push-global_expected () {
      cat<<"EOEXPECTED"
No tests configured
EOEXPECTED
}

echo 'Run run-test-n-push-global'

{ run-test-n-push-global_code || true ; } > "${TMP}/code.txt" 2>&1
run-test-n-push-global_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-test-n-push-global"
exit 1
}


mkdir myproject && cd myproject && mkdir .clk

clk command create bash test --description "Run the project tests" --body '
echo "Running pytest..."
echo "All 42 tests passed!"
'


run-test-n-push-local_code () {
      clk test-n-push
}

run-test-n-push-local_expected () {
      cat<<"EOEXPECTED"
Running pytest...
All 42 tests passed!
git push
EOEXPECTED
}

echo 'Run run-test-n-push-local'

{ run-test-n-push-local_code || true ; } > "${TMP}/code.txt" 2>&1
run-test-n-push-local_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-test-n-push-local"
exit 1
}



leave-project_code () {
      cd ..
      clk test-n-push
}

leave-project_expected () {
      cat<<"EOEXPECTED"
No tests configured
EOEXPECTED
}

echo 'Run leave-project'

{ leave-project_code || true ; } > "${TMP}/code.txt" 2>&1
leave-project_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying leave-project"
exit 1
}


cd myproject


create-local-alias_code () {
      clk alias set deploy echo "Deploying to production..."
}

create-local-alias_expected () {
      cat<<"EOEXPECTED"
New local alias for deploy: echo 'Deploying to production...'
EOEXPECTED
}

echo 'Run create-local-alias'

{ create-local-alias_code || true ; } > "${TMP}/code.txt" 2>&1
create-local-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create-local-alias"
exit 1
}



run-deploy_code () {
      clk deploy
}

run-deploy_expected () {
      cat<<"EOEXPECTED"
Deploying to production...
EOEXPECTED
}

echo 'Run run-deploy'

{ run-deploy_code || true ; } > "${TMP}/code.txt" 2>&1
run-deploy_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-deploy"
exit 1
}



deploy-outside_code () {
      cd ..
      clk deploy
}

deploy-outside_expected () {
      cat<<"EOEXPECTED"
warning: Failed to get the command deploy: Command deploy not found
Usage: clk [OPTIONS] COMMAND [ARGS]...
error: No such command 'deploy'.
EOEXPECTED
}

echo 'Run deploy-outside'

{ deploy-outside_code || true ; } > "${TMP}/code.txt" 2>&1
deploy-outside_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying deploy-outside"
exit 1
}
# summary:1 ends here
