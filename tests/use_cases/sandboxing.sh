TMP="$(mktemp -d --suffix -clk-test)"
mkdir -p "${TMP}/clk-root"
cd "${TMP}"
eval "$(direnv hook bash)"
export CLKCONFIGDIR=${TMP}/clk-root
echo "export CLKCONFIGDIR=${TMP}/clk-root" > "${TMP}/.envrc" && direnv allow
echo "${TMP}"
