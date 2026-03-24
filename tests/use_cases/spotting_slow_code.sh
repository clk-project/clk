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
      cat<<"EOEXPECTED"
done
EOEXPECTED
}

echo 'Run run-without-timestamp'

{ run-without-timestamp_code || true ; } > "${TMP}/code.txt" 2>&1
run-without-timestamp_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-without-timestamp"
exit 1
}


run-with-timestamp_code () {
      clk --timestamp slowcmd 2>&1
}

run-with-timestamp_expected () {
      cat<<"EOEXPECTED"
2024-02-14 23:00:06,000 done
EOEXPECTED
}

echo 'Run run-with-timestamp'

{ run-with-timestamp_code || true ; } > "${TMP}/code.txt" 2>&1
run-with-timestamp_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-with-timestamp"
exit 1
}


run-with-debug-timestamp_code () {
      clk --debug --timestamp slowcmd 2>&1
}

run-with-debug-timestamp_expected () {
      cat<<"EOEXPECTED"
2024-02-14 23:00:06,000 debug: starting step 1: fetch config
2024-02-14 23:00:06,000 debug: starting step 2: heavy computation
2024-02-14 23:00:09,000 debug: starting step 3: write results
2024-02-14 23:00:09,000 done
2024-02-14 23:00:09,000 debug: command `clk/__main__.py --debug --timestamp slowcmd` run in 3 seconds
EOEXPECTED
}

echo 'Run run-with-debug-timestamp'

{ run-with-debug-timestamp_code || true ; } > "${TMP}/code.txt" 2>&1
run-with-debug-timestamp_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-with-debug-timestamp"
exit 1
}


run-with-profiling_code () {
      clk --profiling slowcmd 2>&1 | grep sleep
}

run-with-profiling_expected () {
      cat<<"EOEXPECTED"
1    0.000    0.000    0.000    0.000 clk/core.py:0(_fake_sleep)
EOEXPECTED
}

echo 'Run run-with-profiling'

{ run-with-profiling_code || true ; } > "${TMP}/code.txt" 2>&1
run-with-profiling_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-with-profiling"
exit 1
}
# run ends here
