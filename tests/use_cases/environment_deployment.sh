#!/bin/bash -eu
# [[file:../../doc/use_cases/environment_deployment.org::run][run]]
. ./sandboxing.sh

clk command create python app --group --force
cat<<'EOF' >> "${CLKCONFIGDIR}/python/app.py"
@group()
def app():
    "Application management"

@app.command()
@option('--environment', '-e', default='staging', help='Target environment')
def deploy(environment):
    "Deploy the application"
    import click
    ctx = click.get_current_context()
    source = ctx.get_parameter_source('environment')

    if source.name == 'DEFAULT':
        print(f"No environment specified, auto-detecting...")
        print(f"Detected: production (from git branch)")
        print(f"Deploying to production")
    else:
        print(f"Environment explicitly set to: {environment}")
        print(f"Deploying to {environment}")
EOF


deploy_default_code () {
      clk app deploy
}

deploy_default_expected () {
      cat<<"EOEXPECTED"
No environment specified, auto-detecting...
Detected: production (from git branch)
Deploying to production
EOEXPECTED
}

echo 'Run deploy_default'

{ deploy_default_code || true ; } > "${TMP}/code.txt" 2>&1
deploy_default_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying deploy_default"
exit 1
}



deploy_explicit_code () {
      clk app deploy --environment staging
}

deploy_explicit_expected () {
      cat<<"EOEXPECTED"
Environment explicitly set to: staging
Deploying to staging
EOEXPECTED
}

echo 'Run deploy_explicit'

{ deploy_explicit_code || true ; } > "${TMP}/code.txt" 2>&1
deploy_explicit_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying deploy_explicit"
exit 1
}



create_aliases_code () {
      clk alias set app.deploy-prod app deploy --environment production
      clk alias set app.deploy-staging app deploy --environment staging
}

create_aliases_expected () {
      cat<<"EOEXPECTED"
New global alias for app.deploy-prod: app deploy --environment production
New global alias for app.deploy-staging: app deploy --environment staging
EOEXPECTED
}

echo 'Run create_aliases'

{ create_aliases_code || true ; } > "${TMP}/code.txt" 2>&1
create_aliases_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create_aliases"
exit 1
}



deploy_via_alias_code () {
      clk app deploy-prod
}

deploy_via_alias_expected () {
      cat<<"EOEXPECTED"
Environment explicitly set to: production
Deploying to production
EOEXPECTED
}

echo 'Run deploy_via_alias'

{ deploy_via_alias_code || true ; } > "${TMP}/code.txt" 2>&1
deploy_via_alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying deploy_via_alias"
exit 1
}
# run ends here
