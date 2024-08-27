#!/bin/bash -eu
# [[file:../../doc/use_cases/controlling_a_server_using_an_environment_variable.org::run][run]]
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

diff -uBw <(curl_code 2>&1) <(curl_expected) || {
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
New global alias for myserver: echo curl pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)
curl http://myserverip/sommecommand
EOEXPECTED
}

diff -uBw <(withpyeval_code 2>&1) <(withpyeval_expected) || {
echo "Something went wrong when trying withpyeval"
exit 1
}



witheval_code () {
      clk alias set myserver echo curl 'noeval:eval:sh -c "echo http://${MYSERVER}/sommecommand"'
      clk myserver
}

witheval_expected () {
      cat<<"EOEXPECTED"
Removing global alias of myserver: echo curl pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)
New global alias for myserver: echo curl eval:sh -c "echo http://${MYSERVER}/sommecommand"
curl http://myserverip/sommecommand
EOEXPECTED
}

diff -uBw <(witheval_code 2>&1) <(witheval_expected) || {
echo "Something went wrong when trying witheval"
exit 1
}



withtpl_code () {
      clk alias set myserver echo curl 'noeval:tpl:http://{MYSERVER}/sommecommand'
      clk myserver
}

withtpl_expected () {
      cat<<"EOEXPECTED"
Removing global alias of myserver: echo curl eval:sh -c "echo http://${MYSERVER}/sommecommand"
New global alias for myserver: echo curl tpl:http://{MYSERVER}/sommecommand
curl http://myserverip/sommecommand
EOEXPECTED
}

diff -uBw <(withtpl_code 2>&1) <(withtpl_expected) || {
echo "Something went wrong when trying withtpl"
exit 1
}
# run ends here
