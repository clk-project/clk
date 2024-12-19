#!/bin/bash -eu
# [[file:../../doc/use_cases/ipfs_name_publish.org::run][run]]
. ./sandboxing.sh

clk command create bash ipfs.key.list --description "List the available keys" --body "
cat<<EOF
alice
bob
charly
EOF
"


call-ipfs-key-list_code () {
      clk ipfs key list
}

call-ipfs-key-list_expected () {
      cat<<"EOEXPECTED"
alice
bob
charly
EOEXPECTED
}

diff -uBw <(call-ipfs-key-list_code 2>&1) <(call-ipfs-key-list_expected) || {
echo "Something went wrong when trying call-ipfs-key-list"
exit 1
}


clk command create bash ipfs.name.publish --no-open
cat <<"EOH" > "$(clk command which ipfs.name.publish)"
#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Publish another cid to the given key id
--
A:cid:str:The cid to Publish
A:key:$(clk ipfs key list|clk_list_to_choice):The key to publish to
EOF
}

clk_help_handler "$@"
# here, I simply echo because this is a mock command
echo "ipfs name publish --key=$(clk_value key) $(clk_value cid)"
EOH


try-completion_code () {
      clk completion try --remove-bash-formatting --last ipfs name publish somecontent al
}

try-completion_expected () {
      cat<<"EOEXPECTED"
alice
EOEXPECTED
}

diff -uBw <(try-completion_code 2>&1) <(try-completion_expected) || {
echo "Something went wrong when trying try-completion"
exit 1
}



call-publish_code () {
      clk ipfs name publish somecid alice
}

call-publish_expected () {
      cat<<"EOEXPECTED"
ipfs name publish --key=alice somecid
EOEXPECTED
}

diff -uBw <(call-publish_code 2>&1) <(call-publish_expected) || {
echo "Something went wrong when trying call-publish"
exit 1
}
# run ends here
