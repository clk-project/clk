# [[id:8e7e1dba-e84b-4569-9701-be3a1e073505::sandboxing][sandboxing]]
export TQDM_NCOLS=60
# Clear bash hooks that may trigger X11 calls (notifications, xdotool, etc.)
preexec_functions=()
precmd_functions=()
unset DISPLAY
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
    TMP="$(mktemp -d -t clk-test.XXXXXXXXXX)"
fi
SANDBOX_CACHE="${TMP}/cache"
export XDG_CACHE_HOME="${TMP}/cache"
clean_cache( ){
    rm -rf "${SANDBOX_CACHE}"
}
mkdir -p "${TMP}/clk-root"
export CLK_BIN="$(readlink -f "$(which clk)")"
export SLEEP_BIN="$(which sleep)"
export DATE_BIN="$(which date)"
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
clk () {
    if test -n "${CLK_FAKED_TIME-}"
    then
        export CLK_FAKED_TIME_FILE="${TMP}/clk_faked_time"
        # the faketime program is useful to make cache_disk reproducible
        faketime "${CLK_FAKED_TIME}" "${CLK_COV}" "$@"
        _ret=$?
        if test -s "${CLK_FAKED_TIME_FILE}"; then
            CLK_FAKED_TIME=$(cat "${CLK_FAKED_TIME_FILE}")
        fi
        return $_ret
    else
        "${CLK_COV}" "$@"
    fi
}
cat <<EOF > "${TMP}/clk-root/clk.json"
{
    "parameters": {
        "clk": [
            "--keyring", "clk.keyrings.DummyFileKeyring",
            "--forced-width",
            "--reproducible-output"
        ],
        "command.create.python": [
            "--no-open",
            "--force"
        ],
        "extension.remove": [
            "--force"
        ],
        "completion.try": [
            "--call"
        ],
        "command.create.bash": [
            "--no-open",
            "--force"
        ]
    },
  "value": {
      "config.show.color": {
          "value": "false"
      }
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
export CLK_COVERAGE_TEST_ID="${CLK_COVERAGE_TEST_ID-}"
EOF
# source the env file to use it in automatic test
source "${TMP}/.envrc"
export TERM=dumb # to avoid possible issues with colors
echo "${TMP}"
# sandboxing ends here
