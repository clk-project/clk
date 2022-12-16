#!/bin/bash -eu

. ./sandboxing.sh

clk command create bash mycommand --no-open

clk mycommand

clk | grep mycommand

cat <<"EOH" > "$(clk command which mycommand)"
#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

This command shows something
--

EOF
}

clk_help_handler "$@"

echo something

EOH

test "$(clk mycommand)" = "something"
