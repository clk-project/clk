# [[file:bash_command.org::+BEGIN_SRC bash :exports none :tangle bash_command.sh :noweb yes][No heading:9]]
#!/bin/bash -eu

. ./sandboxing.sh

clk command create bash mycommand

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
# No heading:9 ends here
