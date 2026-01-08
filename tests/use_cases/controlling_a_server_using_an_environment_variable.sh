#!/bin/bash -eu
# [[id:3a3f2856-a1c4-4be6-9521-00a39e0f728d::run][run]]
. ./sandboxing.sh


curl_code () {
      clk alias set myserver echo curl http://myserverip/somecommand
      clk myserver
}

curl_expected () {
      cat<<"EOEXPECTED"
New global alias for myserver: echo curl http://myserverip/somecommand
curl http://myserverip/somecommand
EOEXPECTED
}

echo 'Run curl'

{ curl_code || true ; } > "${TMP}/code.txt" 2>&1
curl_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying curl"
exit 1
}


export MYSERVER=myserverip


withpyeval_code () {
      clk alias set myserver echo curl 'noeval:pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)'
      clk myserver
}

withpyeval_expected () {
      cat<<"EOEXPECTED"
Removing global alias of myserver: echo curl http://myserverip/somecommand
New global alias for myserver: echo curl 'pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)'
curl http://myserverip/sommecommand
EOEXPECTED
}

echo 'Run withpyeval'

{ withpyeval_code || true ; } > "${TMP}/code.txt" 2>&1
withpyeval_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying withpyeval"
exit 1
}



witheval_code () {
      clk alias set myserver echo curl 'noeval:eval:sh -c "echo http://${MYSERVER}/sommecommand"'
      clk myserver
}

witheval_expected () {
      cat<<"EOEXPECTED"
Removing global alias of myserver: echo curl 'pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)'
New global alias for myserver: echo curl 'eval:sh -c "echo http://${MYSERVER}/sommecommand"'
curl http://myserverip/sommecommand
EOEXPECTED
}

echo 'Run witheval'

{ witheval_code || true ; } > "${TMP}/code.txt" 2>&1
witheval_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying witheval"
exit 1
}



withtpl_code () {
      clk alias set myserver echo curl 'noeval:tpl:http://{MYSERVER}/sommecommand'
      clk myserver
}

withtpl_expected () {
      cat<<"EOEXPECTED"
Removing global alias of myserver: echo curl 'eval:sh -c "echo http://${MYSERVER}/sommecommand"'
New global alias for myserver: echo curl 'tpl:http://{MYSERVER}/sommecommand'
curl http://myserverip/sommecommand
EOEXPECTED
}

echo 'Run withtpl'

{ withtpl_code || true ; } > "${TMP}/code.txt" 2>&1
withtpl_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying withtpl"
exit 1
}
# run ends here
