#!/bin/bash -eu
# [[file:dealing_with_secrets.org::test][test]]
. ./sandboxing.sh

clk command create python --group http --force
cat<<EOF >> "${CLKCONFIGDIR}/python/http.py"
class HTTPConfig:
    pass

@group()
@option("--bearer", help="The bearer token to request the API", prompt=True, confirmation_prompt=True, hide_input=True, expose_class=HTTPConfig)
@option("--base-url", help="The url of the site to play with", expose_class=HTTPConfig)
def http():
    "Commands to play with some OAuth 2 protected site"

@http.command()
@argument("path", help="The endpoint to call")
def get(path):
    "Perform a get request from the site"
    print(f"Calling {config.http.base_url}/{path} with bearer token {config.http.bearer}")

EOF



setsecretinparameter_code () {
      clk parameter set http --bearer mytoken
}

setsecretinparameter_expected () {
      cat<<EOEXPECTED
New global parameters for http: --bearer mytoken
EOEXPECTED
}

diff -u <(setsecretinparameter_code 2>&1) <(setsecretinparameter_expected)



usesecretinparameter_code () {
      clk http --base-url someurl get someendpoint
}

usesecretinparameter_expected () {
      cat<<EOEXPECTED
Calling someurl/someendpoint with bearer token mytoken
EOEXPECTED
}

diff -u <(usesecretinparameter_code 2>&1) <(usesecretinparameter_expected)



usethebearefromsecret_code () {
      clk parameter set http --bearer noeval:secret:http_bearer
}

usethebearefromsecret_expected () {
      cat<<EOEXPECTED
Removing global parameters of http: --bearer mytoken
New global parameters for http: --bearer secret:http_bearer
EOEXPECTED
}

diff -u <(usethebearefromsecret_code 2>&1) <(usethebearefromsecret_expected)



httpwithsecretfail_code () {
      clk http --base-url someurl get someendpoint
}

httpwithsecretfail_expected () {
      cat<<EOEXPECTED
error: Could not find the secret for http_bearer
EOEXPECTED
}

diff -u <(httpwithsecretfail_code 2>&1) <(httpwithsecretfail_expected)


clk secret set --set-parameter global --secret mytoken

clk secret set http_bearer


showsecret_code () {
      clk secret show http_bearer
}

showsecret_expected () {
      cat<<EOEXPECTED
http_bearer *****
EOEXPECTED
}

diff -u <(showsecret_code 2>&1) <(showsecret_expected)



reallyshowsecret_code () {
      clk secret show http_bearer --secret
}

reallyshowsecret_expected () {
      cat<<EOEXPECTED
http_bearer mytoken
EOEXPECTED
}

diff -u <(reallyshowsecret_code 2>&1) <(reallyshowsecret_expected)



reallyshowonlysecret_code () {
      clk secret show http_bearer --secret --field secret
}

reallyshowonlysecret_expected () {
      cat<<EOEXPECTED
mytoken
EOEXPECTED
}

diff -u <(reallyshowonlysecret_code 2>&1) <(reallyshowonlysecret_expected)



httpwithsecret_code () {
      clk http --base-url someurl get someendpoint
}

httpwithsecret_expected () {
      cat<<EOEXPECTED
Calling someurl/someendpoint with bearer token mytoken
EOEXPECTED
}

diff -u <(httpwithsecret_code 2>&1) <(httpwithsecret_expected)


clk parameter set secret.unset --force

clk secret unset http_bearer


checkthatthesecretisgone_code () {
      clk secret show http_bearer
}

checkthatthesecretisgone_expected () {
      cat<<EOEXPECTED
warning: No secret set
EOEXPECTED
}

diff -u <(checkthatthesecretisgone_code 2>&1) <(checkthatthesecretisgone_expected)
# test ends here
