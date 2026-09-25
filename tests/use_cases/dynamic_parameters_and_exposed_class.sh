#!/usr/bin/env bash
# [[file:../../doc/use_cases/dynamic_parameters_and_exposed_class.org::final][final]]
set -eu
. ./sandboxing.sh

clk command create python --group http

cat<<EOF >> "${CLKCONFIGDIR}/python/http.py"
class HTTPConfig:

    def get(self, path):
        print("Would run the get code")

    def post(self, path, body):
        print("Would run the post code")

class HttpPathType(DynamicChoice):
    def choices(self):
        if config.http.base_url == "http://url":
            return ["/a", "/b", "/c"]
        elif config.http.base_url == "http://otherurl":
            return ["/d", "/e", "/f"]
        return []

    def convert(self, value, param, ctx):
        return value

@group()
@option("--base-url", help="The url to use as a basis for all commands", expose_class=HTTPConfig, required=True)
def http():
    "Commands to make http requests"

@http.command()
@argument("path", help="The path to GET", type=HttpPathType())
def get(path):
    "Perform a GET request"
    LOGGER.info(f"GET {config.http.base_url}/{path}")
    res = config.http.get(path)
    LOGGER.info(f"res = {res}")

@http.command()
@argument("path", help="The path to POST to", type=HttpPathType())
@option("--body", help="The body to send")
def post(path, body):
    "Perform a POST request"
    LOGGER.info(f"POST {config.http.base_url}/{path} with body {body}")
    res = config.http.post(path, body)
    LOGGER.info(f"res = {res}")
EOF


help_code () {
      clk http --help | head -10
}

help_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk http [OPTIONS] COMMAND [ARGS]...

  Commands to make http requests

  Edit this custom command by running `clk command edit http`
  Or edit ./clk-root/python/http.py directly.

Options:
  --base-url TEXT  The url to use as a basis for all commands  [required]
  --help-all       Show the full help message, automatic options included.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run help'

{ help_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/help"
else
    help_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying help"
        exit 1
    }
fi



which_code () {
      clk command which http
}

which_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./clk-root/python/http.py
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run which'

{ which_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/which"
else
    which_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying which"
        exit 1
    }
fi



simpleget_code () {
      clk http --base-url http://url get /path
}

simpleget_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
GET http://url//path
Would run the get code
res = None
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run simpleget'

{ simpleget_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/simpleget"
else
    simpleget_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying simpleget"
        exit 1
    }
fi



simplepost_code () {
      clk http --base-url http://url post /path --body somebody
}

simplepost_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
POST http://url//path with body somebody
Would run the post code
res = None
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run simplepost'

{ simplepost_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/simplepost"
else
    simplepost_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying simplepost"
        exit 1
    }
fi



completion1_code () {
      clk completion try http --base-url "http://url" get
}

completion1_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
/a
/b
/c
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run completion1'

{ completion1_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/completion1"
else
    completion1_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying completion1"
        exit 1
    }
fi



completion2_code () {
      clk completion try http --base-url "http://otherurl" get
}

completion2_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
/d
/e
/f
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run completion2'

{ completion2_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/completion2"
else
    completion2_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying completion2"
        exit 1
    }
fi



try-somesite_code () {
      clk alias set somesite http --base-url http://url
      clk somesite get something
      clk somesite post something --body bodyoftherequest
}

try-somesite_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m alias for somesite: http --base-url http://url
GET http://url/something
Would run the get code
res = None
POST http://url/something with body bodyoftherequest
Would run the post code
res = None
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-somesite'

{ try-somesite_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try-somesite"
else
    try-somesite_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-somesite"
        exit 1
    }
fi
# final ends here
