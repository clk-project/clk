#!/usr/bin/env bash
# [[file:../../doc/use_cases/reading_later_from_qutebrowser.org::#letting-clk-use-its-own-libraries][letting clk use its own libraries:4]]
set -eu
. ./sandboxing.sh

clk command create python read-later --description "Keep a page to read it later" --body "
@command()
@argument('url', help='The page to read later')
def read_later(url):
    'Keep a page to read it later'
    print(f'I will read {url} later')
"


try_read_later_code () {
      clk read-later https://clk-project.org/
}

try_read_later_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
I will read https://clk-project.org/ later
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try_read_later'

{ try_read_later_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/try_read_later"
else
    try_read_later_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try_read_later"
        exit 1
    }
fi


mkdir -p "${TMP}/qutebrowser/lib/click" "${TMP}/qutebrowser/userscripts"
echo 'raise ImportError("clk cannot work with the click of qutebrowser")' > "${TMP}/qutebrowser/lib/click/__init__.py"
# what qutebrowser does when I press the key
press_the_key () {
    (
        export PYTHONPATH="${TMP}/qutebrowser/lib"
        export QUTE_URL="https://clk-project.org/"
        . "${TMP}/qutebrowser/userscripts/read-later"
    )
}

cat <<"EOF" > "${TMP}/qutebrowser/userscripts/read-later"
#!/usr/bin/env bash
clk read-later "${QUTE_URL}"
EOF


press_the_key_code () {
      press_the_key 2>&1 | tail -1
}

press_the_key_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
ImportError: clk cannot work with the click of qutebrowser
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run press_the_key'

{ press_the_key_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/press_the_key"
else
    press_the_key_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying press_the_key"
        exit 1
    }
fi


cat <<"EOF" > "${TMP}/qutebrowser/userscripts/read-later"
#!/usr/bin/env bash
export CLK_FORCE_DEPS=1
clk read-later "${QUTE_URL}"
EOF


press_the_key_again_code () {
      press_the_key
}

press_the_key_again_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
I will read https://clk-project.org/ later
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run press_the_key_again'

{ press_the_key_again_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/press_the_key_again"
else
    press_the_key_again_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying press_the_key_again"
        exit 1
    }
fi
# letting clk use its own libraries:4 ends here
