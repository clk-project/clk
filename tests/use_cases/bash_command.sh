# [[file:bash_command.org::+BEGIN_SRC bash :exports none :tangle bash_command.sh :noweb yes][No heading:9]]
#!/bin/bash -eu

. ./sandboxing.sh

clk command create bash mycommand


try_code () {
      clk mycommand
}

try_expected () {
      cat<<EOEXPECTED
warning: The command 'mycommand' has no documentation
EOEXPECTED
}

diff -uw <(try_code 2>&1) <(try_expected)



see_code () {
      clk | grep mycommand
}

see_expected () {
      cat<<EOEXPECTED
mycommand   Description
EOEXPECTED
}

diff -uw <(see_code 2>&1) <(see_expected)


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


help_code () {
      clk mycommand --help
}

help_expected () {
      cat<<EOEXPECTED
Usage: clk mycommand [OPTIONS]

  This command shows something

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.
EOEXPECTED
}

diff -uw <(help_code 2>&1) <(help_expected)


test "$(clk mycommand)" = "something"
# No heading:9 ends here
