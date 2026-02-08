#!/bin/bash -eu
# [[file:../../doc/use_cases/wrapping_a_cloud_provider_cli.org::#per-project][per-project configuration:5]]
. ./sandboxing.sh

clk command create python aws --group --description "AWS CLI wrapper"

cat <<'EOF' > "$(clk command which aws)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.config import config
from clk.decorators import group, option


@group()
@option("--profile", "-p", default="default", help="The AWS profile to use")
@option("--region", "-r", default="us-east-1", help="The AWS region")
def aws(profile, region):
    "AWS CLI wrapper with persistent configuration"
    config.override_env["AWS_PROFILE"] = profile
    config.override_env["AWS_REGION"] = region
    config.init()


@aws.group()
def s3():
    "S3 operations"
EOF

clk command create bash aws.s3.ls --description "List S3 buckets or objects" \
    --argument 'path:str:S3 path to list:{"required": false}' \
    --body 'echo "[${AWS_PROFILE}/${AWS_REGION}] aws s3 ls ${CLK___PATH:-}"'

clk command create bash aws.s3.cp --description "Copy files to/from S3" \
    --argument 'source:str:Source path' \
    --argument 'destination:str:Destination path' \
    --body 'echo "[${AWS_PROFILE}/${AWS_REGION}] aws s3 cp ${CLK___SOURCE} ${CLK___DESTINATION}"'

clk command create bash aws.ec2 --description "EC2 operations" \
    --argument 'args:str:EC2 command arguments:{"nargs": -1}' \
    --body 'echo "[${AWS_PROFILE}/${AWS_REGION}] aws ec2 ${CLK___ARGS}"'


try-explicit_code () {
      clk aws --profile company-prod --region eu-west-1 s3 ls s3://prod-bucket
}

try-explicit_expected () {
      cat<<"EOEXPECTED"
[company-prod/eu-west-1] aws s3 ls s3://prod-bucket
EOEXPECTED
}

echo 'Run try-explicit'

{ try-explicit_code || true ; } > "${TMP}/code.txt" 2>&1
try-explicit_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-explicit"
exit 1
}



set-parameters_code () {
      clk parameter set aws --profile company-prod --region eu-west-1
}

set-parameters_expected () {
      cat<<"EOEXPECTED"
New global parameters for aws: --profile company-prod --region eu-west-1
EOEXPECTED
}

echo 'Run set-parameters'

{ set-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
set-parameters_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying set-parameters"
exit 1
}



try-with-defaults_code () {
      clk aws s3 ls s3://prod-bucket
      clk aws s3 cp backup.sql s3://prod-bucket/backups/
      clk aws ec2 describe-instances
}

try-with-defaults_expected () {
      cat<<"EOEXPECTED"
[company-prod/eu-west-1] aws s3 ls s3://prod-bucket
[company-prod/eu-west-1] aws s3 cp backup.sql s3://prod-bucket/backups/
[company-prod/eu-west-1] aws ec2 describe-instances
EOEXPECTED
}

echo 'Run try-with-defaults'

{ try-with-defaults_code || true ; } > "${TMP}/code.txt" 2>&1
try-with-defaults_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-with-defaults"
exit 1
}



try-override_code () {
      clk aws --profile company-staging s3 ls s3://staging-bucket
}

try-override_expected () {
      cat<<"EOEXPECTED"
[company-staging/eu-west-1] aws s3 ls s3://staging-bucket
EOEXPECTED
}

echo 'Run try-override'

{ try-override_code || true ; } > "${TMP}/code.txt" 2>&1
try-override_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-override"
exit 1
}



show-parameters_code () {
      clk parameter show aws
}

show-parameters_expected () {
      cat<<"EOEXPECTED"
aws --profile company-prod --region eu-west-1
EOEXPECTED
}

echo 'Run show-parameters'

{ show-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
show-parameters_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-parameters"
exit 1
}



unset-region_code () {
      clk parameter remove aws --region eu-west-1
      clk parameter show aws
}

unset-region_expected () {
      cat<<"EOEXPECTED"
Erasing aws parameters --region eu-west-1 from global settings
aws --profile company-prod
EOEXPECTED
}

echo 'Run unset-region'

{ unset-region_code || true ; } > "${TMP}/code.txt" 2>&1
unset-region_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying unset-region"
exit 1
}



unset-all_code () {
      clk parameter unset aws
      clk aws s3 ls
}

unset-all_expected () {
      cat<<"EOEXPECTED"
Erasing global parameters of aws (was: --profile company-prod)
[default/us-east-1] aws s3 ls
EOEXPECTED
}

echo 'Run unset-all'

{ unset-all_code || true ; } > "${TMP}/code.txt" 2>&1
unset-all_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying unset-all"
exit 1
}


mkdir -p webapp-project
cd webapp-project
mkdir .clk


set-project-parameters_code () {
      clk --project . parameter set aws --profile webapp-prod --region ap-southeast-1
      clk parameter show aws
}

set-project-parameters_expected () {
      cat<<"EOEXPECTED"
New local parameters for aws: --profile webapp-prod --region ap-southeast-1
aws --profile webapp-prod --region ap-southeast-1
EOEXPECTED
}

echo 'Run set-project-parameters'

{ set-project-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
set-project-parameters_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying set-project-parameters"
exit 1
}



try-project-parameters_code () {
      clk aws s3 ls s3://webapp-assets
}

try-project-parameters_expected () {
      cat<<"EOEXPECTED"
[webapp-prod/ap-southeast-1] aws s3 ls s3://webapp-assets
EOEXPECTED
}

echo 'Run try-project-parameters'

{ try-project-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
try-project-parameters_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-project-parameters"
exit 1
}



leave-project_code () {
      cd ..
      clk aws s3 ls
}

leave-project_expected () {
      cat<<"EOEXPECTED"
[default/us-east-1] aws s3 ls
EOEXPECTED
}

echo 'Run leave-project'

{ leave-project_code || true ; } > "${TMP}/code.txt" 2>&1
leave-project_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying leave-project"
exit 1
}
# per-project configuration:5 ends here
