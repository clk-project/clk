#!/bin/bash -eu
# [[id:85c8e385-7f24-48ac-9a85-30cfc354aebf::+BEGIN_SRC bash :exports none :tangle ../../tests/use_cases/bash_command.sh :noweb yes :shebang "#!/bin/bash -eu"][No heading:9]]
. ./sandboxing.sh

clk command create bash mycommand


show_it_code () {
      cat $(clk command which mycommand)
}

show_it_expected () {
      cat<<"EOEXPECTED"
#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Description
--

EOF
}

clk_help_handler "$@"

EOEXPECTED
}

echo 'Run show_it'

{ show_it_code || true ; } > "${TMP}/code.txt" 2>&1
show_it_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show_it"
exit 1
}



try_code () {
      clk mycommand
}

try_expected () {
      cat<<"EOEXPECTED"
warning: The command 'mycommand' has no documentation
EOEXPECTED
}

echo 'Run try'

{ try_code || true ; } > "${TMP}/code.txt" 2>&1
try_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try"
exit 1
}


sed -i 's/Description/Command that says something/g' "$(clk command which mycommand)"


help_code () {
      clk mycommand --help|sed "s|$(pwd)|.|"
}

help_expected () {
      cat<<"EOEXPECTED"
Usage: clk mycommand [OPTIONS]

  Command that says something

  Edit this external command by running `clk command edit mycommand`
  Or edit ./clk-root/bin/mycommand directly.

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.

EOEXPECTED
}

echo 'Run help'

{ help_code || true ; } > "${TMP}/code.txt" 2>&1
help_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying help"
exit 1
}


cat<<EOF >> "$(clk command which mycommand)"
echo something
EOF


use_it_code () {
      clk mycommand
}

use_it_expected () {
      cat<<"EOEXPECTED"
something
EOEXPECTED
}

echo 'Run use_it'

{ use_it_code || true ; } > "${TMP}/code.txt" 2>&1
use_it_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying use_it"
exit 1
}
# No heading:9 ends here
