#!/usr/bin/env bash
# [[file:../../doc/use_cases/tests/use_cases/controlling_the_audio.sh :noweb yes :shebang "#!/usr/bin/env bash"][No heading:7]]
set -eu
. ./sandboxing.sh

echo speakers > routing.txt

clk command create python record --description "Record what the music player plays"
cat<<'EOF' > "$(clk command which record)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from pathlib import Path

import click

from clk.atexit import register
from clk.decorators import command, flag

ROUTING = Path("routing.txt")
PROXY = Path("proxy-sink.txt")


def tear_down(sink):
    ROUTING.write_text(f"{sink}\n")
    PROXY.unlink()


@command()
@flag("--disk-full", help="Pretend the disk fills up while recording")
def record(disk_full):
    "Record what the music player plays"
    sink = ROUTING.read_text().strip()
    PROXY.write_text("loaded\n")
    ROUTING.write_text("proxy\n")
    register(tear_down, sink)
    print(f"recording the music from the {ROUTING.read_text().strip()} sink")
    if disk_full:
        raise click.ClickException("no space left on device")
EOF


run-record_code () {
      clk record
      cat routing.txt
      ls proxy-sink.txt 2>&1
}

run-record_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
recording the music from the proxy sink
speakers
ls: cannot access 'proxy-sink.txt': No such file or directory
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-record'

{ run-record_code || true ; } > "${TMP}/code.txt" 2>&1
run-record_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-record"
exit 1
}



run-record-disk-full_code () {
      clk record --disk-full 2>&1
      cat routing.txt
      ls proxy-sink.txt 2>&1
}

run-record-disk-full_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
recording the music from the proxy sink
error: no space left on device
speakers
ls: cannot access 'proxy-sink.txt': No such file or directory
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-record-disk-full'

{ run-record-disk-full_code || true ; } > "${TMP}/code.txt" 2>&1
run-record-disk-full_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-record-disk-full"
exit 1
}
# No heading:7 ends here
