#!/usr/bin/env bash
# [[file:../../doc/use_cases/spotting_slow_code.org::run][run]]
set -eu
. ./sandboxing.sh
init_faked_time
cat > "${TMP}/slowcmd.py" <<'EOF'
import time

from clk.decorators import command
from clk.log import get_logger

LOGGER = get_logger(__name__)


@command()
def slowcmd():
    """A command with several steps."""
    LOGGER.debug("starting step 1: fetch config")
    LOGGER.debug("starting step 2: heavy computation")
    time.sleep(3)
    LOGGER.debug("starting step 3: write results")
    LOGGER.info("done")
EOF
clk command create python slowcmd --force --from-file "${TMP}/slowcmd.py"

run-without-timestamp_code () {
      clk slowcmd 2>&1
}

run-without-timestamp_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
done
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-without-timestamp'

{ run-without-timestamp_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run-without-timestamp"
else
    run-without-timestamp_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-without-timestamp"
        exit 1
    }
fi


run-with-timestamp_code () {
      clk --timestamp slowcmd 2>&1
}

run-with-timestamp_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
2024-02-14 23:00:06,000 done
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-with-timestamp'

{ run-with-timestamp_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run-with-timestamp"
else
    run-with-timestamp_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-with-timestamp"
        exit 1
    }
fi


run-with-debug-timestamp_code () {
      clk --debug --timestamp slowcmd 2>&1
}

run-with-debug-timestamp_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
2024-02-14 23:00:06,000 [34mdebug: [0mstarting step 1: fetch config
2024-02-14 23:00:06,000 [34mdebug: [0mstarting step 2: heavy computation
2024-02-14 23:00:09,000 [34mdebug: [0mstarting step 3: write results
2024-02-14 23:00:09,000 done
2024-02-14 23:00:09,000 debug: command `clk/__main__.py --debug --timestamp slowcmd` run in 3 seconds
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-with-debug-timestamp'

{ run-with-debug-timestamp_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run-with-debug-timestamp"
else
    run-with-debug-timestamp_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-with-debug-timestamp"
        exit 1
    }
fi


run-with-profiling_code () {
      clk --profiling slowcmd 2>&1 | grep sleep
}

run-with-profiling_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
        1    0.000    0.000    0.000    0.000 clk/core.py:0(_fake_sleep)
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-with-profiling'

{ run-with-profiling_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run-with-profiling"
else
    run-with-profiling_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-with-profiling"
        exit 1
    }
fi

stop_faked_time
{
    echo '{'
    echo '    "alias": {'
    for i in $(seq -w 0 299)
    do
        echo "        \"a${i}\": {\"commands\": [[\"echo\", \"a${i}\"]]},"
    done
    echo '    }'
    echo '}'
} > "${CLKCONFIGDIR}/clk.json5"

complete-a29_code () {
      clk completion try --last clk a29
}

complete-a29_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
a290
a291
a292
a293
a294
a295
a296
a297
a298
a299
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run complete-a29'

{ complete-a29_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/complete-a29"
else
    complete-a29_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying complete-a29"
        exit 1
    }
fi


time-completion_code () {
      fastest () {
          local best=999999 start elapsed
          for _ in 1 2 3
          do
              start=$(date +%s%N)
              "$@" > /dev/null 2>&1
              elapsed=$(( ($(date +%s%N) - start) / 1000000 ))
              test "${elapsed}" -lt "${best}" && best="${elapsed}"
          done
          echo "${best}"
      }
      mine=$(fastest clk completion try --last clk a29)
      bare=$(CLKCONFIGDIR="$(mktemp -d)" fastest clk completion try --last clk a29)
      test "${mine}" -lt "$(( bare * 2 ))" \
          && echo "my three hundred aliases cost less than starting clk at all"
}

time-completion_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
my three hundred aliases cost less than starting clk at all
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run time-completion'

{ time-completion_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/time-completion"
else
    time-completion_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying time-completion"
        exit 1
    }
fi
# run ends here
