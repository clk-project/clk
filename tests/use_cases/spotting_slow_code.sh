#!/usr/bin/env bash
# [[id:fdbd665d-0fe5-4380-92f6-c32a02633dde::run][run]]
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
  check-result(run-without-timestamp)
  check-result(run-with-timestamp)
  check-result(run-with-debug-timestamp)
  check-result(run-with-profiling)
# run ends here
