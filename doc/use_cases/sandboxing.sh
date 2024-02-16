# [[file:sandboxing.org::+BEGIN_SRC bash :exports none :tangle ./sandboxing.sh :noweb yes][No heading:2]]
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
mkdir -p "${TMP}/clk-root"
mkdir "${TMP}/bin"
export CLK_BIN="$(readlink -f "$(which clk)")"
cat<<EOF > "${TMP}/bin/clk"
#!/bin/bash -eu

"${CLK_COV}" "\$@"
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
            "--no-open"
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
