#!/bin/bash -eu
# [[id:8d9e97a5-dcf5-46ff-a584-7a38e680edb8::test][test]]
. ./sandboxing.sh

clk command create python eth --description "Play with ethereum" --group --body "
@eth.group()
@option('--abi-path', help='Where the abi description is located', required=True, type=Path)
@option('--address', help='The address of the contract', required=True)
def contract(abi_path, address):
    'Discuss with a smart contract'
    print(f'I would discuss with the contract whose address is {address} and abi path is {abi_path}')

@contract.command()
@argument('name', help='The function to call on the contract', type=click.Choice(['dosomething', 'dosomethingelse']))
def call(name):
    'Call a function'
    print(f'I would call the function {name}')
"


call_some_code () {
      clk eth contract --abi-path some.json --address 0xdeadbeef call dosomething
}

call_some_expected () {
      cat<<"EOEXPECTED"
I would discuss with the contract whose address is 0xdeadbeef and abi path is some.json
I would call the function dosomething
EOEXPECTED
}

echo 'Run call_some'

{ call_some_code || true ; } > "${TMP}/code.txt" 2>&1
call_some_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying call_some"
exit 1
}


clk alias set eth.mycontract eth contract --abi-path some.json --address 0xdeadbeef


call_alias_code () {
      clk eth mycontract call dosomething
}

call_alias_expected () {
      cat<<"EOEXPECTED"
I would discuss with the contract whose address is 0xdeadbeef and abi path is some.json
I would call the function dosomething
EOEXPECTED
}

echo 'Run call_alias'

{ call_alias_code || true ; } > "${TMP}/code.txt" 2>&1
call_alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying call_alias"
exit 1
}



try_completion_code () {
      clk completion try --remove-bash-formatting --last eth mycontract call do
}

try_completion_expected () {
      cat<<"EOEXPECTED"
dosomething
dosomethingelse
EOEXPECTED
}

echo 'Run try_completion'

{ try_completion_code || true ; } > "${TMP}/code.txt" 2>&1
try_completion_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try_completion"
exit 1
}


clk command create bash eth.deploy --description 'Deploy a new contract, save its address locally' --body '

# we simply want that each time this code is run, it returns something
# different. But for the sake of this example, we also want the code to return
# something reproducible

if test -e contract-address.txt
then
   prev="$(cat contract-address.txt)"
else
   prev=""
fi

echo ${prev} | md5sum | cut -f1 -d" " > contract-address.txt
clk log "Contract deployed at address: $(cat contract-address.txt)"
'


try_deploy_code () {
      clk eth deploy
      clk eth deploy
}

try_deploy_expected () {
      cat<<"EOEXPECTED"
Contract deployed at address: 68b329da9893e34099c7d8ad5cb9c940
Contract deployed at address: 223632c428784fecaaa3e2a6aaaf6d8e
EOEXPECTED
}

echo 'Run try_deploy'

{ try_deploy_code || true ; } > "${TMP}/code.txt" 2>&1
try_deploy_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try_deploy"
exit 1
}



get-address_code () {
      clk alias set eth.get-address exec cat contract-address.txt
      clk eth get-address
}

get-address_expected () {
      cat<<"EOEXPECTED"
New global alias for eth.get-address: exec cat contract-address.txt
223632c428784fecaaa3e2a6aaaf6d8e
EOEXPECTED
}

echo 'Run get-address'

{ get-address_code || true ; } > "${TMP}/code.txt" 2>&1
get-address_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying get-address"
exit 1
}


clk alias set eth.mycontract eth contract --abi-path some.json --address "noeval:eval:clk eth get-address"


try-command-with-eval_code () {
      clk eth mycontract call dosomething
      clk eth deploy
      clk eth mycontract call dosomething
}

try-command-with-eval_expected () {
      cat<<"EOEXPECTED"
I would discuss with the contract whose address is 223632c428784fecaaa3e2a6aaaf6d8e and abi path is some.json
I would call the function dosomething
Contract deployed at address: 47156ddb404b893cbbe9c85509710f64
I would discuss with the contract whose address is 47156ddb404b893cbbe9c85509710f64 and abi path is some.json
I would call the function dosomething
EOEXPECTED
}

echo 'Run try-command-with-eval'

{ try-command-with-eval_code || true ; } > "${TMP}/code.txt" 2>&1
try-command-with-eval_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-command-with-eval"
exit 1
}



issue-using-with-cache_code () {
      clk alias set eth.mycontract eth contract --abi-path some.json --address "noeval:eval(60):clk eth get-address"
      clk eth mycontract call dosomething
      clk eth deploy
      clk eth mycontract call dosomething
}

issue-using-with-cache_expected () {
      cat<<"EOEXPECTED"
Removing global alias of eth.mycontract: eth contract --abi-path some.json --address 'eval:clk eth get-address'
New global alias for eth.mycontract: eth contract --abi-path some.json --address 'eval(60):clk eth get-address'
I would discuss with the contract whose address is 47156ddb404b893cbbe9c85509710f64 and abi path is some.json
I would call the function dosomething
Contract deployed at address: ed5b4c043e36c30f31a158e8bda16e2b
I would discuss with the contract whose address is 47156ddb404b893cbbe9c85509710f64 and abi path is some.json
I would call the function dosomething
EOEXPECTED
}

echo 'Run issue-using-with-cache'

{ issue-using-with-cache_code || true ; } > "${TMP}/code.txt" 2>&1
issue-using-with-cache_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying issue-using-with-cache"
exit 1
}



dropping-the-cache-when-deploying_code () {
      clk eth mycontract call dosomething
      clk eth deploy && clk parameter drop-cache "clk eth get-address"
      clk eth mycontract call dosomething
}

dropping-the-cache-when-deploying_expected () {
      cat<<"EOEXPECTED"
I would discuss with the contract whose address is 47156ddb404b893cbbe9c85509710f64 and abi path is some.json
I would call the function dosomething
Contract deployed at address: 53303a8fa63a943a2591b8de2b026da6
I would discuss with the contract whose address is 53303a8fa63a943a2591b8de2b026da6 and abi path is some.json
I would call the function dosomething
EOEXPECTED
}

echo 'Run dropping-the-cache-when-deploying'

{ dropping-the-cache-when-deploying_code || true ; } > "${TMP}/code.txt" 2>&1
dropping-the-cache-when-deploying_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying dropping-the-cache-when-deploying"
exit 1
}


mkdir -p myproject/.clk
cd myproject


alias-with-project_code () {
      clk alias set eth.mycontract eth contract --abi-path noeval:project:some.json --address "noeval:eval:clk eth get-address"
}

alias-with-project_expected () {
      cat<<"EOEXPECTED"
New local alias for eth.mycontract: eth contract --abi-path project:some.json --address 'eval:clk eth get-address'
EOEXPECTED
}

echo 'Run alias-with-project'

{ alias-with-project_code || true ; } > "${TMP}/code.txt" 2>&1
alias-with-project_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying alias-with-project"
exit 1
}



deploy-again_code () {
      clk eth deploy
      clk eth get-address
}

deploy-again_expected () {
      cat<<"EOEXPECTED"
Contract deployed at address: 68b329da9893e34099c7d8ad5cb9c940
68b329da9893e34099c7d8ad5cb9c940
EOEXPECTED
}

echo 'Run deploy-again'

{ deploy-again_code || true ; } > "${TMP}/code.txt" 2>&1
deploy-again_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying deploy-again"
exit 1
}



run-with-project-abi_code () {
      clk eth mycontract call dosomething | sed "s|$(pwd)|absolute-path-to-here|"
}

run-with-project-abi_expected () {
      cat<<"EOEXPECTED"
I would discuss with the contract whose address is 68b329da9893e34099c7d8ad5cb9c940 and abi path is absolute-path-to-here/some.json
I would call the function dosomething
EOEXPECTED
}

echo 'Run run-with-project-abi'

{ run-with-project-abi_code || true ; } > "${TMP}/code.txt" 2>&1
run-with-project-abi_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-with-project-abi"
exit 1
}
# test ends here
