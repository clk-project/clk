#!/usr/bin/env bash
# [[file:../../doc/use_cases/wrapping_a_cloud_provider_cli.org::#preserving-env][preserving environment variables when no option is given:6]]
set -eu
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
      local expected
      expected="$(cat<<"EOEXPECTED"
[company-prod/eu-west-1] aws s3 ls s3://prod-bucket
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-explicit'

{ try-explicit_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-explicit"
else
    try-explicit_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-explicit"
        exit 1
    }
fi



set-parameters_code () {
      clk parameter set aws --profile company-prod --region eu-west-1
}

set-parameters_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global parameters for aws: --profile company-prod --region eu-west-1
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-parameters'

{ set-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/set-parameters"
else
    set-parameters_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-parameters"
        exit 1
    }
fi



try-with-defaults_code () {
      clk aws s3 ls s3://prod-bucket
      clk aws s3 cp backup.sql s3://prod-bucket/backups/
      clk aws ec2 describe-instances
}

try-with-defaults_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[company-prod/eu-west-1] aws s3 ls s3://prod-bucket
[company-prod/eu-west-1] aws s3 cp backup.sql s3://prod-bucket/backups/
[company-prod/eu-west-1] aws ec2 describe-instances
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-with-defaults'

{ try-with-defaults_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-with-defaults"
else
    try-with-defaults_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-with-defaults"
        exit 1
    }
fi



try-override_code () {
      clk aws --profile company-staging s3 ls s3://staging-bucket
}

try-override_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[company-staging/eu-west-1] aws s3 ls s3://staging-bucket
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-override'

{ try-override_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-override"
else
    try-override_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-override"
        exit 1
    }
fi



complete-parameter-command_code () {
      clk completion try --remove-bash-formatting --last parameter set aw
}

complete-parameter-command_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
aws
aws.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run complete-parameter-command'

{ complete-parameter-command_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/complete-parameter-command"
else
    complete-parameter-command_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying complete-parameter-command"
        exit 1
    }
fi



complete-parameter-subcommand_code () {
      clk completion try --remove-bash-formatting --last parameter set aws.
}

complete-parameter-subcommand_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
aws.ec2
aws.s3
aws.s3.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run complete-parameter-subcommand'

{ complete-parameter-subcommand_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/complete-parameter-subcommand"
else
    complete-parameter-subcommand_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying complete-parameter-subcommand"
        exit 1
    }
fi



show-parameters_code () {
      clk parameter show aws
}

show-parameters_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
aws --profile company-prod --region eu-west-1
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-parameters'

{ show-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/show-parameters"
else
    show-parameters_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-parameters"
        exit 1
    }
fi



unset-region_code () {
      clk parameter remove aws --region eu-west-1
      clk parameter show aws
}

unset-region_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Erasing aws parameters --region eu-west-1 from global settings
aws --profile company-prod
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unset-region'

{ unset-region_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/unset-region"
else
    unset-region_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying unset-region"
        exit 1
    }
fi



unset-all_code () {
      clk parameter unset aws
      clk aws s3 ls
}

unset-all_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Erasing global parameters of aws (was: --profile company-prod)
[default/us-east-1] aws s3 ls
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unset-all'

{ unset-all_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/unset-all"
else
    unset-all_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying unset-all"
        exit 1
    }
fi


editor_writes <<'EOF'
--profile company-prod --region eu-west-1
EOF


edit-parameters_code () {
      clk parameter edit aws
      clk aws s3 ls
}

edit-parameters_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global parameters for aws: --profile company-prod --region eu-west-1
[company-prod/eu-west-1] aws s3 ls
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run edit-parameters'

{ edit-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/edit-parameters"
else
    edit-parameters_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying edit-parameters"
        exit 1
    }
fi


export EDITOR=true
export VISUAL=true


edit-parameters-unchanged_code () {
      clk parameter edit aws
}

edit-parameters-unchanged_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Nothing changed
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run edit-parameters-unchanged'

{ edit-parameters-unchanged_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/edit-parameters-unchanged"
else
    edit-parameters-unchanged_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying edit-parameters-unchanged"
        exit 1
    }
fi


editor_writes </dev/null


edit-parameters-emptied_code () {
      clk parameter edit aws
}

edit-parameters-emptied_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Aboooooort !!
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run edit-parameters-emptied'

{ edit-parameters-emptied_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/edit-parameters-emptied"
else
    edit-parameters-emptied_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying edit-parameters-emptied"
        exit 1
    }
fi


clk parameter unset aws


shoot-myself-in-the-foot_code () {
      clk parameter set parameter set
}

shoot-myself-in-the-foot_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global parameters for parameter: set
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run shoot-myself-in-the-foot'

{ shoot-myself-in-the-foot_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/shoot-myself-in-the-foot"
else
    shoot-myself-in-the-foot_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying shoot-myself-in-the-foot"
        exit 1
    }
fi



cannot-unset_code () {
      clk parameter unset parameter 2>&1
}

cannot-unset_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: Failed to get the command unset: Command unset not found
Usage: clk parameter set [OPTIONS] CMD [PARAMS]...
error: Invalid value for 'CMD': invalid choice: unset. (choose from alias, aws, command, completion, describe, echo, exec, extension, flowdep, fork, help, log, parameter, pip, plugin, python, secret, update, value)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run cannot-unset'

{ cannot-unset_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/cannot-unset"
else
    cannot-unset_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying cannot-unset"
        exit 1
    }
fi



no-parameter-to-the-rescue_code () {
      clk --no-parameter parameter unset parameter
}

no-parameter-to-the-rescue_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Erasing global parameters of parameter (was: set)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run no-parameter-to-the-rescue'

{ no-parameter-to-the-rescue_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/no-parameter-to-the-rescue"
else
    no-parameter-to-the-rescue_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying no-parameter-to-the-rescue"
        exit 1
    }
fi



set-ec2-parameter_code () {
      clk parameter set aws.ec2 describe-instances
      clk aws ec2
}

set-ec2-parameter_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global parameters for aws.ec2: describe-instances
[default/us-east-1] aws ec2 describe-instances
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-ec2-parameter'

{ set-ec2-parameter_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/set-ec2-parameter"
else
    set-ec2-parameter_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-ec2-parameter"
        exit 1
    }
fi



remove-command-with-parameters_code () {
      clk command remove aws.ec2 --force
      clk parameter show aws.ec2 2>&1
}

remove-command-with-parameters_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: Failed to get the command aws.ec2: Command aws.ec2 not found
warning: You should know that the command aws.ec2 does not exist
aws.ec2 describe-instances
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run remove-command-with-parameters'

{ remove-command-with-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/remove-command-with-parameters"
else
    remove-command-with-parameters_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying remove-command-with-parameters"
        exit 1
    }
fi



unset-orphan-parameters_code () {
      clk parameter unset aws.ec2
}

unset-orphan-parameters_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Erasing global parameters of aws.ec2 (was: describe-instances)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unset-orphan-parameters'

{ unset-orphan-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/unset-orphan-parameters"
else
    unset-orphan-parameters_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying unset-orphan-parameters"
        exit 1
    }
fi


mkdir -p webapp-project
cd webapp-project
mkdir .clk


set-project-parameters_code () {
      clk --project . parameter set aws --profile webapp-prod --region ap-southeast-1
      clk parameter show aws
}

set-project-parameters_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New local parameters for aws: --profile webapp-prod --region ap-southeast-1
aws --profile webapp-prod --region ap-southeast-1
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-project-parameters'

{ set-project-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/set-project-parameters"
else
    set-project-parameters_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-project-parameters"
        exit 1
    }
fi



try-project-parameters_code () {
      clk aws s3 ls s3://webapp-assets
}

try-project-parameters_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[webapp-prod/ap-southeast-1] aws s3 ls s3://webapp-assets
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-project-parameters'

{ try-project-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-project-parameters"
else
    try-project-parameters_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-project-parameters"
        exit 1
    }
fi



leave-project_code () {
      cd ..
      clk aws s3 ls
}

leave-project_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[default/us-east-1] aws s3 ls
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


cd "${TMP}"


set-global-prod_code () {
      clk parameter set aws --profile company-prod --region eu-west-1
}

set-global-prod_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global parameters for aws: --profile company-prod --region eu-west-1
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-global-prod'

{ set-global-prod_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/set-global-prod"
else
    set-global-prod_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-global-prod"
        exit 1
    }
fi


clk extension create config-staging
clk extension enable config-staging


set-staging-params_code () {
      clk parameter --extension config-staging set aws --profile company-staging
}

set-staging-params_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global/config-staging parameters for aws: --profile company-staging
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-staging-params'

{ set-staging-params_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/set-staging-params"
else
    set-staging-params_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-staging-params"
        exit 1
    }
fi



try-staging_code () {
      clk aws s3 ls s3://staging-bucket
}

try-staging_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[company-staging/eu-west-1] aws s3 ls s3://staging-bucket
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-staging'

{ try-staging_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-staging"
else
    try-staging_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-staging"
        exit 1
    }
fi



try-staging-override_code () {
      clk aws --profile company-dev s3 ls s3://dev-bucket
}

try-staging-override_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[company-dev/eu-west-1] aws s3 ls s3://dev-bucket
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-staging-override'

{ try-staging-override_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-staging-override"
else
    try-staging-override_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-staging-override"
        exit 1
    }
fi



disable-staging_code () {
      clk extension disable config-staging
      clk aws s3 ls s3://prod-bucket
}

disable-staging_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[company-prod/eu-west-1] aws s3 ls s3://prod-bucket
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run disable-staging'

{ disable-staging_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/disable-staging"
else
    disable-staging_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying disable-staging"
        exit 1
    }
fi


clk extension remove config-staging <<< y
clk parameter unset aws


env-parameters_code () {
      export CLK_P_AWS="--profile env-prod --region us-west-2"
      clk aws s3 ls s3://env-bucket
}

env-parameters_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[env-prod/us-west-2] aws s3 ls s3://env-bucket
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run env-parameters'

{ env-parameters_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/env-parameters"
else
    env-parameters_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying env-parameters"
        exit 1
    }
fi



env-help_code () {
      clk aws --help 2>&1 | grep "current parameters"
}

env-help_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
The current parameters set for this command are: --profile env-prod --region us-west-2
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run env-help'

{ env-help_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/env-help"
else
    env-help_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying env-help"
        exit 1
    }
fi



env-show_code () {
      clk parameter show aws
}

env-show_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
aws --profile env-prod --region us-west-2
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run env-show'

{ env-show_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/env-show"
else
    env-show_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying env-show"
        exit 1
    }
fi



env-unset_code () {
      unset CLK_P_AWS
      clk aws s3 ls
}

env-unset_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[default/us-east-1] aws s3 ls
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run env-unset'

{ env-unset_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/env-unset"
else
    env-unset_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying env-unset"
        exit 1
    }
fi


cat <<'EOF' > "$(clk command which aws)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.config import config
from clk.decorators import group, option


class AwsProfile:
    pass


@group()
@option("--profile", "-p", expose_class=AwsProfile, help="The AWS profile to use")
@option("--region", "-r", help="The AWS region")
def aws(region):
    "AWS CLI wrapper with persistent configuration"
    config.override_env["AWS_PROFILE"] = config.awsprofile.profile
    config.override_env["AWS_REGION"] = region
    config.init()


@aws.group()
def s3():
    "S3 operations"
EOF


no-default-env-preserved_code () {
      export AWS_PROFILE=from-ci
      export AWS_REGION=eu-west-1
      clk aws s3 ls
}

no-default-env-preserved_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[from-ci/eu-west-1] aws s3 ls
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run no-default-env-preserved'

{ no-default-env-preserved_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/no-default-env-preserved"
else
    no-default-env-preserved_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying no-default-env-preserved"
        exit 1
    }
fi



no-default-explicit_code () {
      clk aws --profile company-prod --region ap-southeast-1 s3 ls
}

no-default-explicit_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[company-prod/ap-southeast-1] aws s3 ls
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run no-default-explicit'

{ no-default-explicit_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/no-default-explicit"
else
    no-default-explicit_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying no-default-explicit"
        exit 1
    }
fi


unset AWS_PROFILE
unset AWS_REGION
# preserving environment variables when no option is given:6 ends here
