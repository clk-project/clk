#!/bin/bash -eu
# [[file:../../doc/use_cases/tests/use_cases/multi_environment_deployment_tool.sh :noweb yes :shebang "#!/bin/bash -eu"][No heading:10]]
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
      cat<<"EOEXPECTED"
Environment: dev
URL: https://dev.example.com
Checking status...
Status: OK
EOEXPECTED
}

echo 'Run test-status-dev'

{ test-status-dev_code || true ; } > "${TMP}/code.txt" 2>&1
test-status-dev_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying test-status-dev"
exit 1
}



test-status-prod_code () {
      clk myenv --env prod status
}

test-status-prod_expected () {
      cat<<"EOEXPECTED"
Environment: prod
URL: https://prod.example.com
Checking status...
Status: OK
EOEXPECTED
}

echo 'Run test-status-prod'

{ test-status-prod_code || true ; } > "${TMP}/code.txt" 2>&1
test-status-prod_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying test-status-prod"
exit 1
}


clk command create bash myenv.deploy --description "Deploy to the current environment" --body '
echo "Deploying to ${MYENV_NAME} at ${MYENV_URL}..."
# In real life: kubectl --context "${MYENV_NAME}" apply -f manifests/
echo "Deployment complete!"
'


test-deploy-staging_code () {
      clk myenv --env staging deploy
}

test-deploy-staging_expected () {
      cat<<"EOEXPECTED"
Deploying to staging at https://staging.example.com...
Deployment complete!
EOEXPECTED
}

echo 'Run test-deploy-staging'

{ test-deploy-staging_code || true ; } > "${TMP}/code.txt" 2>&1
test-deploy-staging_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying test-deploy-staging"
exit 1
}
# No heading:10 ends here
