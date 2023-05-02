# [[file:sandboxing.org::tmpdir][tmpdir]]
SRCDIR="$(pwd)"
CLK_COV="$(readlink -f "$(dirname "$BASH_SOURCE")/../clk_coverage.sh")"
clk ( ) {
    "${CLK_COV}" "$@"
}
if test -n "${CLK_TEST_ROOT-}"
then
    TMP="${CLK_TEST_ROOT}"
else
    TMP="$(mktemp -d)"
fi
mkdir -p "${TMP}/clk-root"
cat <<EOF > "${TMP}/clk-root/clk.json"
{
    "parameters": {
        "clk": [
            "--keyring", "clk.keyrings.DummyFileKeyring"
        ],
        "command.create.python": [
            "--no-open"
        ],
        "command.create.bash": [
            "--no-open"
        ]
    }
}
EOF
cd "${TMP}"
eval "$(direnv hook bash)"
export CLKCONFIGDIR="${TMP}/clk-root"
export DUMMYFILEKEYRINGPATH="${TMP}/keyring.json"
cat<<EOF > "${TMP}/.envrc" && direnv allow
export CLKCONFIGDIR=${CLKCONFIGDIR}
export DUMMYFILEKEYRINGPATH="${DUMMYFILEKEYRINGPATH}"
EOF
echo "${TMP}"
# tmpdir ends here
