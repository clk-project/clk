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
New global parameters for agentcore: --password mytoken
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run setsecretinparameter'

{ setsecretinparameter_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/setsecretinparameter"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/usesecretinparameter"
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
Removing global parameters of agentcore: --password mytoken
New global parameters for agentcore: --password secret:demo-buyer-password
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run usethebearefromsecret'

{ usethebearefromsecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/usethebearefromsecret"
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
error: Could not find the secret for demo-buyer-password
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run httpwithsecretfail'

{ httpwithsecretfail_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/httpwithsecretfail"
else
    httpwithsecretfail_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying httpwithsecretfail"
        exit 1
    }
fi


cat<<"EOEXPECT" > "pass.exp"
#!/usr/bin/env -S expect -f
set timeout -1
spawn clk --ask-secret agentcore token
match_max 100000
expect -exact "warning: Could not find the secret for demo-buyer-password\r
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
warning: Could not find the secret for demo-buyer-password
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/call_ask_for_real"
else
    call_ask_for_real_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying call_ask_for_real"
        exit 1
    }
fi


cat<<"EOEXPECT" > "passerror.exp"
#!/usr/bin/env -S expect -f
set timeout -1
spawn clk --ask-secret agentcore token
match_max 100000
expect -exact "warning: Could not find the secret for demo-buyer-password\r
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
warning: Could not find the secret for demo-buyer-password
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/call_ask_for_real_error"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-completion"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-completion-without-ask-secret"
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
demo-buyer-password *****
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run showsecret'

{ showsecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/showsecret"
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
demo-buyer-password mytoken
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run reallyshowsecret'

{ reallyshowsecret_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/reallyshowsecret"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/reallyshowonlysecret"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/httpwithsecret"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/runbashcall"
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
demo-buyer-password  set       agentcore buyer-token
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run listsecrets'

{ listsecrets_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/listsecrets"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/showgetsecret"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/refusingtheremoval"
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
demo-buyer-password *****
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run stillthere'

{ stillthere_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/stillthere"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/checkthatthesecretisgone"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/unsetmissingsecret"
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
demo-buyer-password  missing   agentcore buyer-token
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run listmissingsecrets'

{ listmissingsecrets_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/listmissingsecrets"
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
demo-buyer-password thevalue
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run nokeyring_show'

{ nokeyring_show_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/nokeyring_show"
else
    nokeyring_show_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying nokeyring_show"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/nokeyring_named"
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
demo-buyer-password thevalue
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run netrc_fallback'

{ netrc_fallback_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/netrc_fallback"
else
    netrc_fallback_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying netrc_fallback"
        exit 1
    }
fi



using_netrc_code () {
      clk --keyring clk.keyrings.NetrcKeyring secret show demo-buyer-password --secret
}

using_netrc_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
demo-buyer-password thevalue
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run using_netrc'

{ using_netrc_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/using_netrc"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/netrc_missing"
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
error: Could not save your secret.
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/netrc_readonly"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/netrc_readonly_unset"
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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/readonly_keyring_set"
else
    readonly_keyring_set_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying readonly_keyring_set"
        exit 1
    }
fi


clk parameter unset agentcore
clk alias unset buyer-token


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
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/listnosecret"
else
    listnosecret_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying listnosecret"
        exit 1
    }
fi
# test ends here
