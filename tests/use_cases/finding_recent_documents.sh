#!/usr/bin/env bash
# [[file:../../doc/use_cases/tests/use_cases/finding_recent_documents.sh :noweb yes :shebang "#!/usr/bin/env bash"][No heading:8]]
set -eu
. ./sandboxing.sh
init_faked_time

mkdir documents && cd documents
touch -d 2024-02-01 minutes.txt
touch -d 2024-02-12 invoice.txt
touch -d 2024-02-14 receipt.txt

clk command create bash find-new-documents
cat <<"EOH" > "$(clk command which find-new-documents)"
#!/usr/bin/env bash
  set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Find the documents touched since a day
--
A:since:date:The day to look back to
EOF
}

clk_help_handler "$@"

find . -maxdepth 1 -type f -newermt "$(date -d"$(clk_value since)" "+%Y-%m-%d")" -printf "%f\n" | sort

EOH


since-a-written-day_code () {
      clk find-new-documents 2024-02-10
}

since-a-written-day_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
invoice.txt
receipt.txt
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run since-a-written-day'

{ since-a-written-day_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/since-a-written-day"
else
    since-a-written-day_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying since-a-written-day"
        exit 1
    }
fi



since-yesterday_code () {
      clk find-new-documents yesterday
}

since-yesterday_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
receipt.txt
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run since-yesterday'

{ since-yesterday_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/since-yesterday"
else
    since-yesterday_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying since-yesterday"
        exit 1
    }
fi
# No heading:8 ends here
