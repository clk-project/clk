#!/usr/bin/env bash
# [[file:../../doc/use_cases/controlling_a_server_using_an_environment_variable.org::run][run]]
set -eu
. ./sandboxing.sh


curl_code () {
      clk alias set myserver echo curl http://myserverip/somecommand
      clk myserver
}

curl_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m alias for myserver: echo curl http://myserverip/somecommand
curl http://myserverip/somecommand
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run curl'

{ curl_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/curl"
else
    curl_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying curl"
        exit 1
    }
fi


export MYSERVER=myserverip


withpyeval_code () {
      clk alias set myserver echo curl 'noeval:pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)'
      clk myserver
}

withpyeval_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Removing [36mglobal[0m alias of myserver: echo curl http://myserverip/somecommand
New [36mglobal[0m alias for myserver: echo curl 'pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)'
curl http://myserverip/sommecommand
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run withpyeval'

{ withpyeval_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/withpyeval"
else
    withpyeval_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying withpyeval"
        exit 1
    }
fi



witheval_code () {
      clk alias set myserver echo curl 'noeval:eval:sh -c "echo http://${MYSERVER}/sommecommand"'
      clk myserver
}

witheval_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Removing [36mglobal[0m alias of myserver: echo curl 'pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)'
New [36mglobal[0m alias for myserver: echo curl 'eval:sh -c "echo http://${MYSERVER}/sommecommand"'
curl http://myserverip/sommecommand
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run witheval'

{ witheval_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/witheval"
else
    witheval_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying witheval"
        exit 1
    }
fi



withtpl_code () {
      clk alias set myserver echo curl 'noeval:tpl:http://{MYSERVER}/sommecommand'
      clk myserver
}

withtpl_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Removing [36mglobal[0m alias of myserver: echo curl 'eval:sh -c "echo http://${MYSERVER}/sommecommand"'
New [36mglobal[0m alias for myserver: echo curl 'tpl:http://{MYSERVER}/sommecommand'
curl http://myserverip/sommecommand
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run withtpl'

{ withtpl_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/withtpl"
else
    withtpl_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying withtpl"
        exit 1
    }
fi
# run ends here
