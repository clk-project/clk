#!/usr/bin/env bash
# [[file:../../doc/use_cases/ipfs_name_publish.org::run][run]]
set -eu
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
      local expected
      expected="$(cat<<"EOEXPECTED"
alice
bob
charly
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run call-ipfs-key-list'

{ call-ipfs-key-list_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/call-ipfs-key-list"
else
    call-ipfs-key-list_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying call-ipfs-key-list"
        exit 1
    }
fi



call-ipfs_code () {
      clk ipfs --help
      clk ipfs key --help
}

call-ipfs_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk ipfs [OPTIONS] COMMAND [ARGS]...

  Automatically created group to organize subcommands

  This is a built in created group. To remove it, simply remove all its subcommands (with `clk command remove SUBCMD`,
  or `clk alias unset SUBCMD`). To rename it, simply rename them (with `clk command rename SUBCMD` or `clk alias rename
  SUBCMD`)

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.

Commands:
  key  Automatically created group to organize subcommands
Usage: clk ipfs key [OPTIONS] COMMAND [ARGS]...

  Automatically created group to organize subcommands

  This is a built in created group. To remove it, simply remove all its subcommands (with `clk command remove SUBCMD`,
  or `clk alias unset SUBCMD`). To rename it, simply rename them (with `clk command rename SUBCMD` or `clk alias rename
  SUBCMD`)

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.

Commands:
  list  List the available keys
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run call-ipfs'

{ call-ipfs_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/call-ipfs"
else
    call-ipfs_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying call-ipfs"
        exit 1
    }
fi


clk command create bash ipfs.name.publish --no-open
cat <<"EOH" > "$(clk command which ipfs.name.publish)"
#!/usr/bin/env bash
set -eu

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
      local expected
      expected="$(cat<<"EOEXPECTED"
alice
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



call-publish_code () {
      clk ipfs name publish somecid alice
}

call-publish_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
ipfs name publish --key=alice somecid
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run call-publish'

{ call-publish_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/call-publish"
else
    call-publish_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying call-publish"
        exit 1
    }
fi
# run ends here
