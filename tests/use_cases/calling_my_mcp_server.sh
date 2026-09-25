#!/usr/bin/env bash
# [[file:../../doc/use_cases/calling_my_mcp_server.org::test][test]]
set -eu
. ./sandboxing.sh

cat > "${TMP}/agentcore.py" <<'EOF'
from clk.config import config
from clk.decorators import group, option


class AgentcoreConfig:
    pass


@group()
@option("--user", default="demo-buyer", help="The Cognito user to log in as", expose_class=AgentcoreConfig)
@option(
    "--password",
    help="The password of that user",
    prompt=True,
    confirmation_prompt=True,
    hide_input=True,
    expose_class=AgentcoreConfig,
)
def agentcore():
    "Talk to my MCP server on Bedrock AgentCore"


@agentcore.command()
def token():
    "Get a fresh access token from Cognito"
    print(f"Logging in as {config.agentcore.user} with password {config.agentcore.password}")
EOF
clk command create python agentcore --group --force --from-file "${TMP}/agentcore.py"


setsecretinparameter_code () {
      clk parameter set agentcore --password mytoken
}

setsecretinparameter_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m parameters for agentcore: --password mytoken
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run setsecretinparameter'

{ setsecretinparameter_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/setsecretinparameter"
else
    setsecretinparameter_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying setsecretinparameter"
        exit 1
    }
fi



usesecretinparameter_code () {
      clk agentcore token
}

usesecretinparameter_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Logging in as demo-buyer with password mytoken
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run usesecretinparameter'

{ usesecretinparameter_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/usesecretinparameter"
else
    usesecretinparameter_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying usesecretinparameter"
        exit 1
    }
fi



usethebearefromsecret_code () {
      clk parameter set agentcore --password noeval:secret:demo-buyer-password
}

usethebearefromsecret_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Removing [36mglobal[0m parameters of agentcore: --password mytoken
New [36mglobal[0m parameters for agentcore: --password secret:demo-buyer-password
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run usethebearefromsecret'

{ usethebearefromsecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/usethebearefromsecret"
else
    usethebearefromsecret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying usethebearefromsecret"
        exit 1
    }
fi



httpwithsecretfail_code () {
      clk agentcore token
}

httpwithsecretfail_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[31merror: [0mCould not find the secret for demo-buyer-password
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run httpwithsecretfail'

{ httpwithsecretfail_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/httpwithsecretfail"
else
    httpwithsecretfail_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying httpwithsecretfail"
        exit 1
    }
fi


cat<<"EOEXPECT" > "pass.exp"
#!/usr/bin/env -S expect -f
set timeout 30
spawn clk --ask-secret agentcore token
expect_after timeout { puts "timed out"; exit 1 }
match_max 100000
expect -exact "Could not find the secret for demo-buyer-password\r
Please provide the secret demo-buyer-password: "
send -- "test\r"
expect -exact "\r
Repeat for confirmation: "
send -- "test\r"
expect eof
EOEXPECT


call_ask_for_real_code () {
      expect pass.exp |tail -n+2
}

call_ask_for_real_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[33mwarning: [0mCould not find the secret for demo-buyer-password
Please provide the secret demo-buyer-password:
Repeat for confirmation:
Logging in as demo-buyer with password test
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run call_ask_for_real'

{ call_ask_for_real_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/call_ask_for_real"
else
    call_ask_for_real_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying call_ask_for_real"
        exit 1
    }
fi


cat<<"EOEXPECT" > "passerror.exp"
#!/usr/bin/env -S expect -f
set timeout 30
spawn clk --ask-secret agentcore token
expect_after timeout { puts "timed out"; exit 1 }
match_max 100000
expect -exact "Could not find the secret for demo-buyer-password\r
Please provide the secret demo-buyer-password: "
send -- "something\r"
expect -exact "\r
Repeat for confirmation: "
send -- "somethingelse\r"
expect -exact "Error: The two entered values do not match.\r"
expect -exact "Please provide the secret demo-buyer-password:"
EOEXPECT


call_ask_for_real_error_code () {
      expect passerror.exp |tail -n+2
}

call_ask_for_real_error_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[33mwarning: [0mCould not find the secret for demo-buyer-password
Please provide the secret demo-buyer-password:
Repeat for confirmation:
Error: The two entered values do not match.
Please provide the secret demo-buyer-password:
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run call_ask_for_real_error'

{ call_ask_for_real_error_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/call_ask_for_real_error"
else
    call_ask_for_real_error_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying call_ask_for_real_error"
        exit 1
    }
fi



try-completion_code () {
      clk completion try --remove-bash-formatting --last agentcore --us
}

try-completion_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
--user
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-completion'

{ try-completion_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-completion"
else
    try-completion_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-completion"
        exit 1
    }
fi



try-completion-without-ask-secret_code () {
      clk --ask-secret completion try --remove-bash-formatting --last agentcore --us
}

try-completion-without-ask-secret_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
--user
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-completion-without-ask-secret'

{ try-completion-without-ask-secret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-completion-without-ask-secret"
else
    try-completion-without-ask-secret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-completion-without-ask-secret"
        exit 1
    }
fi


clk secret set --set-parameter global --secret mytoken

clk secret set demo-buyer-password


showsecret_code () {
      clk secret show demo-buyer-password
}

showsecret_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password [2m*****[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run showsecret'

{ showsecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/showsecret"
else
    showsecret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying showsecret"
        exit 1
    }
fi



reallyshowsecret_code () {
      clk secret show demo-buyer-password --secret
}

reallyshowsecret_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password [2mmytoken[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run reallyshowsecret'

{ reallyshowsecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/reallyshowsecret"
else
    reallyshowsecret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying reallyshowsecret"
        exit 1
    }
fi



reallyshowonlysecret_code () {
      clk secret show demo-buyer-password --secret --field secret
}

reallyshowonlysecret_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
mytoken
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run reallyshowonlysecret'

{ reallyshowonlysecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/reallyshowonlysecret"
else
    reallyshowonlysecret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying reallyshowonlysecret"
        exit 1
    }
fi



httpwithsecret_code () {
      clk agentcore token
}

httpwithsecret_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Logging in as demo-buyer with password mytoken
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run httpwithsecret'

{ httpwithsecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/httpwithsecret"
else
    httpwithsecret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying httpwithsecret"
        exit 1
    }
fi


clk command create bash mcp-call --description "Call a tool of my MCP server" \
    --option '--password:str:The password of demo-buyer:{"default": "secret:demo-buyer-password"}' \
    --argument 'tool:str:The tool to call' \
    --body 'echo "Calling ${CLK___TOOL} as demo-buyer with password ${CLK___PASSWORD}"'


runbashcall_code () {
      clk mcp-call get_account_info
}

runbashcall_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Calling get_account_info as demo-buyer with password mytoken
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run runbashcall'

{ runbashcall_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/runbashcall"
else
    runbashcall_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying runbashcall"
        exit 1
    }
fi


clk alias set buyer-token agentcore --user demo-buyer --password noeval:secret:demo-buyer-password token


listsecrets_code () {
      clk secret list
}

listsecrets_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
key                  status    commands
-------------------  --------  ---------------------
demo-buyer-password  [32mset[0m       [36m[2magentcore[0m [36m[2mbuyer-token[0m
[2m--------------[0m
Legend: [36m[2mglobal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run listsecrets'

{ listsecrets_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/listsecrets"
else
    listsecrets_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying listsecrets"
        exit 1
    }
fi


clk command create python dosomething --force
cat<<EOF >> "${CLKCONFIGDIR}/python/dosomething.py"
from clk import get_secret

@command()
def dosomething():
    'Log in with my own client'
    click.echo(get_secret('demo-buyer-password'))
EOF


showgetsecret_code () {
      clk dosomething
}

showgetsecret_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
mytoken
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run showgetsecret'

{ showgetsecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/showgetsecret"
else
    showgetsecret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying showgetsecret"
        exit 1
    }
fi



refusingtheremoval_code () {
      clk secret unset demo-buyer-password <<< n
}

refusingtheremoval_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
This will definitely remove the secret for demo-buyer-password. Are you sure? [y/N]: Kept the secret for demo-buyer-password
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run refusingtheremoval'

{ refusingtheremoval_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/refusingtheremoval"
else
    refusingtheremoval_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying refusingtheremoval"
        exit 1
    }
fi



stillthere_code () {
      clk secret show demo-buyer-password
}

stillthere_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password [2m*****[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run stillthere'

{ stillthere_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/stillthere"
else
    stillthere_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying stillthere"
        exit 1
    }
fi


clk parameter set secret.unset --force

clk secret unset demo-buyer-password


checkthatthesecretisgone_code () {
      clk secret show demo-buyer-password
}

checkthatthesecretisgone_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: No secret set
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run checkthatthesecretisgone'

{ checkthatthesecretisgone_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/checkthatthesecretisgone"
else
    checkthatthesecretisgone_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying checkthatthesecretisgone"
        exit 1
    }
fi



unsetmissingsecret_code () {
      clk secret unset demo-buyer-password
}

unsetmissingsecret_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: No secret set
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unsetmissingsecret'

{ unsetmissingsecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/unsetmissingsecret"
else
    unsetmissingsecret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying unsetmissingsecret"
        exit 1
    }
fi



listmissingsecrets_code () {
      clk secret list
}

listmissingsecrets_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
key                  status    commands
-------------------  --------  ---------------------
demo-buyer-password  [31mmissing[0m   [36m[2magentcore[0m [36m[2mbuyer-token[0m
[2m--------------[0m
Legend: [36m[2mglobal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run listmissingsecrets'

{ listmissingsecrets_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/listmissingsecrets"
else
    listmissingsecrets_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying listmissingsecrets"
        exit 1
    }
fi


cat <<EOF > "${CLK_NETRC_LOCATION}"
machine demo-buyer-password
password thevalue
EOF

mkdir -p "${TMP}/nokeyring/keyring"
echo "raise ModuleNotFoundError(\"No module named 'keyring'\")" > "${TMP}/nokeyring/keyring/__init__.py"
OLDPYTHONPATH="${PYTHONPATH-}"
export PYTHONPATH="${TMP}/nokeyring${PYTHONPATH:+:${PYTHONPATH}}"


nokeyring_show_code () {
      clk secret show demo-buyer-password --secret
}

nokeyring_show_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password [2mthevalue[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run nokeyring_show'

{ nokeyring_show_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/nokeyring_show"
else
    nokeyring_show_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying nokeyring_show"
        exit 1
    }
fi



nokeyring_backend_code () {
      clk secret backend which
}

nokeyring_backend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk keeps your secrets in clk.netrc.Netrc, because the python library keyring is not installed.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run nokeyring_backend'

{ nokeyring_backend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/nokeyring_backend"
else
    nokeyring_backend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying nokeyring_backend"
        exit 1
    }
fi



nokeyring_backends_code () {
      clk secret backend show
}

nokeyring_backends_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
backend          configuration      priority  status
---------------  ---------------  ----------  --------
[32mclk.netrc.Netrc[0m  Unset                     1  in use
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run nokeyring_backends'

{ nokeyring_backends_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/nokeyring_backends"
else
    nokeyring_backends_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying nokeyring_backends"
        exit 1
    }
fi



nokeyring_named_code () {
      clk --keyring clk.keyrings.NetrcKeyring secret show demo-buyer-password
}

nokeyring_named_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: You need to install keyring in order to manipulate secrets. Hint: python3 -m pip install keyring
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run nokeyring_named'

{ nokeyring_named_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/nokeyring_named"
else
    nokeyring_named_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying nokeyring_named"
        exit 1
    }
fi


export PYTHONPATH="${OLDPYTHONPATH}"

clk parameter set clk --keyring keyring.backends.fail.Keyring


netrc_fallback_code () {
      clk secret show demo-buyer-password --secret
}

netrc_fallback_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password [2mthevalue[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run netrc_fallback'

{ netrc_fallback_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/netrc_fallback"
else
    netrc_fallback_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying netrc_fallback"
        exit 1
    }
fi


unset DUMMYFILEKEYRINGPATH


whichbackend_code () {
      clk secret backend which
}

whichbackend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk keeps your secrets in clk.keyrings.NetrcKeyring, because the python library keyring found no password manager on this machine.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run whichbackend'

{ whichbackend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/whichbackend"
else
    whichbackend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying whichbackend"
        exit 1
    }
fi



showbackends_code () {
      clk secret backend show
}

showbackends_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
backend                                  configuration      priority  status
---------------------------------------  ---------------  ----------  --------
[31mkeyring.backends.chainer.ChainerBackend[0m  Unset                    10
[31mclk.keyrings.GpgKeyring[0m                  Unset                     1
[32mclk.keyrings.NetrcKeyring[0m                Unset                     1  in use
[31mkeyring.backends.fail.Keyring[0m            Unset                     0
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run showbackends'

{ showbackends_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/showbackends"
else
    showbackends_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying showbackends"
        exit 1
    }
fi



using_netrc_code () {
      clk --keyring clk.keyrings.NetrcKeyring secret show demo-buyer-password --secret
}

using_netrc_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password [2mthevalue[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run using_netrc'

{ using_netrc_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/using_netrc"
else
    using_netrc_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying using_netrc"
        exit 1
    }
fi



netrc_missing_code () {
      clk --keyring clk.keyrings.NetrcKeyring secret show other_token --secret
}

netrc_missing_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: No secret set
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run netrc_missing'

{ netrc_missing_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/netrc_missing"
else
    netrc_missing_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying netrc_missing"
        exit 1
    }
fi



netrc_readonly_code () {
      clk --keyring clk.keyrings.NetrcKeyring secret set other_token
}

netrc_readonly_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[31merror: [0mCould not save your secret.
Usage: clk secret set [OPTIONS] KEY
error: The netrc keyring only reads secrets. Write this one in your netrc file to use it.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run netrc_readonly'

{ netrc_readonly_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/netrc_readonly"
else
    netrc_readonly_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying netrc_readonly"
        exit 1
    }
fi



netrc_readonly_unset_code () {
      clk --keyring clk.keyrings.NetrcKeyring secret unset demo-buyer-password
}

netrc_readonly_unset_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk secret unset [OPTIONS] KEY
error: The netrc keyring only reads secrets. Remove this one from your netrc file to get rid of it.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run netrc_readonly_unset'

{ netrc_readonly_unset_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/netrc_readonly_unset"
else
    netrc_readonly_unset_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying netrc_readonly_unset"
        exit 1
    }
fi


mkdir -p "${TMP}/pylib"
cat <<'EOF' > "${TMP}/pylib/team_keyring.py"
import keyring.backend


class SecretsManagerKeyring(keyring.backend.KeyringBackend):
    priority = 6

    def get_password(self, service, username):
        return None

    def set_password(self, service, username, password):
        raise NotImplementedError

    def delete_password(self, service, username):
        raise NotImplementedError
EOF
export PYTHONPATH="${TMP}/pylib${PYTHONPATH:+:${PYTHONPATH}}"


readonly_keyring_set_code () {
      clk --keyring team_keyring.SecretsManagerKeyring secret set demo-buyer-password
}

readonly_keyring_set_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: The keyring team_keyring.SecretsManagerKeyring cannot store secrets. Store it with the tool of that password manager, or pick another keyring with --keyring.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run readonly_keyring_set'

{ readonly_keyring_set_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/readonly_keyring_set"
else
    readonly_keyring_set_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying readonly_keyring_set"
        exit 1
    }
fi



teambackend_code () {
      clk --keyring team_keyring.SecretsManagerKeyring secret backend which
}

teambackend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk keeps your secrets in team_keyring.SecretsManagerKeyring, because --keyring names it.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run teambackend'

{ teambackend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/teambackend"
else
    teambackend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying teambackend"
        exit 1
    }
fi


clk parameter unset clk


useteambackend_code () {
      clk secret backend use team_keyring.SecretsManagerKeyring
}

useteambackend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk now keeps your secrets in team_keyring.SecretsManagerKeyring ([36mglobal[0m settings)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run useteambackend'

{ useteambackend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/useteambackend"
else
    useteambackend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying useteambackend"
        exit 1
    }
fi



showteambackend_code () {
      clk secret backend which
}

showteambackend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk keeps your secrets in team_keyring.SecretsManagerKeyring, because the [36mglobal[0m settings name it.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run showteambackend'

{ showteambackend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/showteambackend"
else
    showteambackend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying showteambackend"
        exit 1
    }
fi



showteambackends_code () {
      clk secret backend show
}

showteambackends_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
backend                                  configuration      priority  status
---------------------------------------  ---------------  ----------  --------
[32mteam_keyring.SecretsManagerKeyring[0m       [36m[2mglobal[0m                    6  in use
[31mkeyring.backends.fail.Keyring[0m            Unset                     0
[31mkeyring.backends.chainer.ChainerBackend[0m  Unset                    -1
[2m--------------[0m
Legend: [36m[2mglobal[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run showteambackends'

{ showteambackends_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/showteambackends"
else
    showteambackends_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying showteambackends"
        exit 1
    }
fi


export GNUPGHOME="${TMP}/gnupg"
mkdir -m 700 "${GNUPGHOME}"
gpg --batch --quiet --passphrase '' --quick-gen-key me@example.com default default never 2>/dev/null
mkdir -p "${TMP}/mcp-server/.clk"
cd "${TMP}/mcp-server"


gpgnoid_code () {
      clk --keyring clk.keyrings.GpgKeyring secret set demo-buyer-password
}

gpgnoid_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
[31merror: [0mCould not save your secret.
Usage: clk secret set [OPTIONS] KEY
error: Write in ./.clk/secrets/.gpg-id the gpg ids to encrypt the secrets to, one per line. gpg --list-secret-keys shows yours.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run gpgnoid'

{ gpgnoid_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/gpgnoid"
else
    gpgnoid_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying gpgnoid"
        exit 1
    }
fi


mkdir -p .clk/secrets
echo me@example.com > .clk/secrets/.gpg-id


completegpg_code () {
      clk completion try --remove-bash-formatting --last secret backend --local use clk.keyrings.
}

completegpg_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk.keyrings.GpgKeyring
clk.keyrings.NetrcKeyring
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run completegpg'

{ completegpg_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/completegpg"
else
    completegpg_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying completegpg"
        exit 1
    }
fi



usegpg_code () {
      clk secret backend --local use clk.keyrings.GpgKeyring
}

usegpg_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk now keeps your secrets in clk.keyrings.GpgKeyring ([32mlocal[0m settings)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run usegpg'

{ usegpg_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/usegpg"
else
    usegpg_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying usegpg"
        exit 1
    }
fi


clk secret set demo-buyer-password


gpgfiles_code () {
      ls .clk/secrets
}

gpgfiles_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password.gpg
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run gpgfiles'

{ gpgfiles_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/gpgfiles"
else
    gpgfiles_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying gpgfiles"
        exit 1
    }
fi



gpgshow_code () {
      clk secret show demo-buyer-password --secret
}

gpgshow_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password [2mmytoken[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run gpgshow'

{ gpgshow_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/gpgshow"
else
    gpgshow_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying gpgshow"
        exit 1
    }
fi



gpgunset_code () {
      clk secret unset demo-buyer-password
      ls .clk/secrets
      clk secret show demo-buyer-password
}

gpgunset_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: No secret set
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run gpgunset'

{ gpgunset_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/gpgunset"
else
    gpgunset_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying gpgunset"
        exit 1
    }
fi



unusegpg_code () {
      clk secret backend --local unuse
}

unusegpg_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk no longer picks a keyring
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unusegpg'

{ unusegpg_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/unusegpg"
else
    unusegpg_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying unusegpg"
        exit 1
    }
fi


export DBUS_SESSION_BUS_ADDRESS="$(dbus-daemon --session --fork --print-address)"
echo -n desktop | gnome-keyring-daemon --unlock --components=secrets > /dev/null


usesecretservice_code () {
      clk secret backend --local use keyring.backends.SecretService.Keyring
}

usesecretservice_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk now keeps your secrets in keyring.backends.SecretService.Keyring ([32mlocal[0m settings)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run usesecretservice'

{ usesecretservice_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/usesecretservice"
else
    usesecretservice_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying usesecretservice"
        exit 1
    }
fi


clk secret set demo-buyer-password


secretserviceshow_code () {
      clk secret show demo-buyer-password --secret
      clk secret backend which
}

secretserviceshow_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password [2mmytoken[0m
clk keeps your secrets in keyring.backends.SecretService.Keyring, because the [32mlocal[0m settings name it.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run secretserviceshow'

{ secretserviceshow_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/secretserviceshow"
else
    secretserviceshow_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying secretserviceshow"
        exit 1
    }
fi


clk secret unset demo-buyer-password
clk secret backend --local unuse

cd "${TMP}"

clk parameter unset agentcore
clk alias unset buyer-token


unuseteambackend_code () {
      clk secret backend unuse
}

unuseteambackend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk no longer picks a keyring
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unuseteambackend'

{ unuseteambackend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/unuseteambackend"
else
    unuseteambackend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying unuseteambackend"
        exit 1
    }
fi




unuseagain_code () {
      clk secret backend unuse
}

unuseagain_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: The global settings pick no keyring
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unuseagain'

{ unuseagain_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/unuseagain"
else
    unuseagain_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying unuseagain"
        exit 1
    }
fi



envbackend_code () {
      PYTHON_KEYRING_BACKEND=clk.keyrings.NetrcKeyring clk secret backend which
}

envbackend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk keeps your secrets in clk.keyrings.NetrcKeyring, because the environment variable PYTHON_KEYRING_BACKEND names it.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run envbackend'

{ envbackend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/envbackend"
else
    envbackend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying envbackend"
        exit 1
    }
fi


unset PYTHON_KEYRING_BACKEND

mkdir -p "${XDG_CONFIG_HOME}/python_keyring"
cat <<EOF > "${XDG_CONFIG_HOME}/python_keyring/keyringrc.cfg"
[backend]
default-keyring=clk.keyrings.NetrcKeyring
EOF


rcbackend_code () {
      clk secret backend which
}

rcbackend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk keeps your secrets in clk.keyrings.NetrcKeyring, because ./config/python_keyring/keyringrc.cfg names it.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run rcbackend'

{ rcbackend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/rcbackend"
else
    rcbackend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying rcbackend"
        exit 1
    }
fi



prioritybackend_code () {
      rm "${XDG_CONFIG_HOME}/python_keyring/keyringrc.cfg"
      clk secret backend which
}

prioritybackend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk keeps your secrets in keyring.backends.SecretService.Keyring, because it has the highest priority of the backends the python library keyring found.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run prioritybackend'

{ prioritybackend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/prioritybackend"
else
    prioritybackend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying prioritybackend"
        exit 1
    }
fi


mkdir -p "${TMP}/pylib/team_keyring-1.0.dist-info"
cat <<EOF > "${TMP}/pylib/team_keyring-1.0.dist-info/METADATA"
Metadata-Version: 2.1
Name: team-keyring
Version: 1.0
EOF
cat <<EOF > "${TMP}/pylib/team_keyring-1.0.dist-info/entry_points.txt"
[keyring.backends]
team = team_keyring
EOF


packagedbackend_code () {
      clk secret backend which
}

packagedbackend_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
clk keeps your secrets in keyring.backends.chainer.ChainerBackend, because it has the highest priority of the backends the python library keyring found.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run packagedbackend'

{ packagedbackend_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/packagedbackend"
else
    packagedbackend_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying packagedbackend"
        exit 1
    }
fi



listnosecret_code () {
      clk secret list
}

listnosecret_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
No parameter or alias refers to a secret
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run listnosecret'

{ listnosecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/listnosecret"
else
    listnosecret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying listnosecret"
        exit 1
    }
fi
# test ends here
