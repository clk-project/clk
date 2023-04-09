# [[file:sandboxing.org::tmpdir][tmpdir]]
SRCDIR="$(pwd)"
CLK_COV="$(readlink -f "$(dirname "$BASH_SOURCE")/../clk_coverage.sh")"
clk ( ) {
    "${CLK_COV}" "$@"
}
TMP="$(mktemp -d)"
mkdir -p "${TMP}/clk-root"
cat <<EOF > "${TMP}/clk-root/clk.json"
{
    "parameters": {
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
export CLKCONFIGDIR=${TMP}/clk-root
echo "export CLKCONFIGDIR=${TMP}/clk-root" > "${TMP}/.envrc" && direnv allow
echo "${TMP}"
# tmpdir ends here
