CLK_COV="$(readlink -f "$(dirname "$BASH_SOURCE")/../clk_coverage.sh")"
clk ( ) {
    "${CLK_COV}" "$@"
}
TMP="$(mktemp -d --suffix -clk-test)"
mkdir -p "${TMP}/clk-root"
cd "${TMP}"
eval "$(direnv hook bash)"
export CLKCONFIGDIR=${TMP}/clk-root
echo "export CLKCONFIGDIR=${TMP}/clk-root" > "${TMP}/.envrc" && direnv allow
echo "${TMP}"
