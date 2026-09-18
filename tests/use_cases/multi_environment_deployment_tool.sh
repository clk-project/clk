#!/usr/bin/env bash
# [[file:../../doc/use_cases/tests/use_cases/multi_environment_deployment_tool.sh :noweb yes :shebang "#!/usr/bin/env bash"][No heading:10]]
set -eu
. ./sandboxing.sh

clk command create python myenv --group --description "Commands that work with a specific environment"

cat <<'EOF' > "$(clk command which myenv)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import click

from clk.config import config
from clk.decorators import group, option


@group()
@option("--env", "-e", type=click.Choice(["dev", "staging", "prod"]), default="dev", help="The environment to use")
def myenv(env):
    "Commands that work with a specific environment"
    config.override_env["MYENV_NAME"] = env
    config.override_env["MYENV_URL"] = f"https://{env}.example.com"
    config.init()
EOF

clk command create bash myenv.status --description "Show the current environment status" --body '
echo "Environment: ${MYENV_NAME}"
echo "URL: ${MYENV_URL}"
echo "Checking status..."
# In real life, you might do: curl -s "${MYENV_URL}/health"
echo "Status: OK"
'


test-status-dev_code () {
      clk myenv status
}

test-status-dev_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Environment: dev
URL: https://dev.example.com
Checking status...
Status: OK
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run test-status-dev'

{ test-status-dev_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/test-status-dev"
else
    test-status-dev_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying test-status-dev"
        exit 1
    }
fi



test-status-prod_code () {
      clk myenv --env prod status
}

test-status-prod_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Environment: prod
URL: https://prod.example.com
Checking status...
Status: OK
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run test-status-prod'

{ test-status-prod_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/test-status-prod"
else
    test-status-prod_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying test-status-prod"
        exit 1
    }
fi


clk command create bash myenv.deploy --description "Deploy to the current environment" --body '
echo "Deploying to ${MYENV_NAME} at ${MYENV_URL}..."
# In real life: kubectl --context "${MYENV_NAME}" apply -f manifests/
echo "Deployment complete!"
'


test-deploy-staging_code () {
      clk myenv --env staging deploy
}

test-deploy-staging_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Deploying to staging at https://staging.example.com...
Deployment complete!
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run test-deploy-staging'

{ test-deploy-staging_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/test-deploy-staging"
else
    test-deploy-staging_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying test-deploy-staging"
        exit 1
    }
fi
# No heading:10 ends here
