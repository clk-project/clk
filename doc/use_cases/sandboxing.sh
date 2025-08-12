# [[id:8e7e1dba-e84b-4569-9701-be3a1e073505::+BEGIN_SRC bash :exports none :tangle ./sandboxing.sh :noweb yes][No heading:2]]
SRCDIR="$(pwd)"
CLK_COV="$(readlink -f "$(dirname "$BASH_SOURCE")/../clk_coverage.sh")"
if ! test -e "${CLK_COV}"
then
    # in case it is run directly from the org file
    CLK_COV="$(readlink -f "$(dirname "$BASH_SOURCE")/../../tests/clk_coverage.sh")"
fi
if test -n "${CLK_TEST_ROOT-}"
then
    TMP="${CLK_TEST_ROOT}"
else
    TMP="$(mktemp -d)"
fi
SANDBOX_CACHE="${TMP}/cache"
export XDG_CACHE_HOME="${TMP}/cache"
clean_cache( ){
    rm -rf "${SANDBOX_CACHE}"
}
mkdir -p "${TMP}/clk-root"
mkdir "${TMP}/bin"
export CLK_BIN="$(readlink -f "$(which clk)")"
export SLEEP_BIN="$(readlink -f "$(which sleep)")"
export DATE_BIN="$(readlink -f "$(which date)")"
init_faked_time () {
    export CLK_FAKED_TIME="2024-02-15T00:00:00+01:00"
}
stop_faked_time () {
    unset CLK_FAKED_TIME
}
sleep ( ) {
    if test -n "${CLK_FAKED_TIME-}"
    then
        export CLK_FAKED_TIME="$(${DATE_BIN} -Is -d "${CLK_FAKED_TIME} + $1 second")"
    else
        "${SLEEP_BIN}" "${@}"
    fi
}
date ( ) {
    if test -n "${CLK_FAKED_TIME-}"
    then
        "${DATE_BIN}" -d "${CLK_FAKED_TIME}" "${@}"
    else
        "${DATE_BIN}" "${@}"
    fi
}
say_now () {
    echo "now: ${CLK_FAKED_TIME}"
}
cat<<EOF > "${TMP}/bin/clk"
#!/bin/bash -eu

if test -n "\${CLK_FAKED_TIME-}"
then
    faketime "\${CLK_FAKED_TIME}" "${CLK_COV}" "\$@"
else
    "${CLK_COV}" "\$@"
fi
EOF
chmod +x "${TMP}/bin/clk"
cat <<EOF > "${TMP}/clk-root/clk.json"
{
    "parameters": {
        "clk": [
            "--keyring", "clk.keyrings.DummyFileKeyring"
        ],
        "command.create.python": [
            "--no-open"
        ],
        "completion.try": [
            "--call"
        ],
        "command.create.bash": [
            "--no-open",
            "--force"
        ]
    }
}
EOF
cd "${TMP}"
eval "$(direnv hook bash)"
cat<<EOF > "${TMP}/.envrc" && direnv allow
export CLKCONFIGDIR="${TMP}/clk-root"
export DUMMYFILEKEYRINGPATH="${TMP}/keyring.json"
export CLK_NETRC_LOCATION="${TMP}/netrc"
export CLK_BIN="${CLK_BIN}"
export PATH="${TMP}/bin:${PATH}"
EOF
# source the env file to use it in automatic test
source "${TMP}/.envrc"
export TERM=dumb # to avoid possible issues with colors
echo "${TMP}"
# No heading:2 ends here
