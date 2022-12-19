#!/bin/bash -eu

set -e
set -u

. ./sandboxing.sh

  mkdir -p "${CLKCONFIGDIR}/bin/lib"
  cat<<EOF > "${CLKCONFIGDIR}/bin/lib/mylib"
shout () {
   tr '[:lower:]' '[:upper:]'
}
EOF

clk command create bash somecommand --no-open
cat <<"EOH" > "$(clk command which somecommand)"
#!/bin/bash -eu

source "_clk.sh"

clk_import mylib

clk_usage () {
    cat<<EOF
$0

This command does something
--

EOF
}

clk_help_handler "$@"

echo something | shout

EOH



test "$(clk somecommand)" = "SOMETHING"
