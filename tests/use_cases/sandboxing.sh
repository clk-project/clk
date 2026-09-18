# [[file:../../doc/use_cases/sandboxing.org::sandboxing][sandboxing]]
export TQDM_NCOLS=60
# Clear bash hooks that may trigger X11 calls (notifications, xdotool, etc.)
preexec_functions=()
precmd_functions=()
unset DISPLAY
export TZ=UTC
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
export PYTHON="$(${CLK_BIN} python -c 'import sys; print(sys.executable)')"
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
editor_writes () {
    cat > "${TMP}/editor-content"
    cat > "${TMP}/editor" <<EOS
#!/usr/bin/env bash
cat "${TMP}/editor-content" > "\$1"
EOS
    chmod +x "${TMP}/editor"
    export EDITOR="${TMP}/editor"
    export VISUAL="${TMP}/editor"
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
# what the sandbox needs to behave, kept out of the profiles the reader sees
mkdir -p "${TMP}/clk-distribution"
echo 8 > "${TMP}/clk-distribution/version.txt"
cat <<EOF > "${TMP}/clk-distribution/clk.json"
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
        ],
        "plugin.create": [
            "--no-open"
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
export CLK_DISTRIBUTION_PROFILE="${TMP}/clk-distribution"
export DUMMYFILEKEYRINGPATH="${TMP}/keyring.json"
export CLK_NETRC_LOCATION="${TMP}/netrc"
export CLK_BIN="${CLK_BIN}"
export CLK_COVERAGE_TEST_ID="${CLK_COVERAGE_TEST_ID-}"
EOF
# source the env file to use it in automatic test
source "${TMP}/.envrc"
if test -n "${CLK_COVERAGE_TEST_ID-}"
then
    cat <<EOF > "${TMP}/coveragerc"
[run]
source = clk
parallel = true
data_file = $(dirname "${CLK_COV}")/.coverage.sub
EOF
    export PYTHONUSERBASE="${TMP}/pyuser"
    SUBCOV_SITE="$("${PYTHON}" -c 'import site; print(site.getusersitepackages())')"
    mkdir -p "${SUBCOV_SITE}"
    echo 'import coverage; coverage.process_startup()' > "${SUBCOV_SITE}/subcoverage.pth"
    export COVERAGE_PROCESS_START="${TMP}/coveragerc"
fi
export TERM=dumb # to avoid possible issues with colors
echo "${TMP}"
# sandboxing ends here
