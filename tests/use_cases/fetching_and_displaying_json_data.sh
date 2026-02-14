#!/bin/bash -eu
# [[file:../../doc/use_cases/fetching_and_displaying_json_data.org::script][script]]
. ./sandboxing.sh

clk command create python --group holidays --description "Fetch and display school holidays"

  cat<<EOF >> "${CLKCONFIGDIR}/python/holidays.py"
import json
from pathlib import Path
from clk.lib import download, echo_json, temporary_file

def fetch_holidays():
    """Download and parse the holidays JSON file."""
    url = "https://github.com/clk-project/clk/raw/main/tests/holidays.json"
    with temporary_file(suffix=".json") as f:
        download(url, outdir=Path(f.name).parent, outfilename=Path(f.name).name)
        return json.loads(Path(f.name).read_text())

@holidays.command()
def cat():
    """Dump the holidays data as JSON."""
    echo_json(fetch_holidays())
EOF


run_cat_code () {
      clk holidays cat 2>/dev/null | head -19
}

run_cat_expected () {
      cat<<"EOEXPECTED"
[
    {
        "description": "Vacances de No\u00ebl",
        "end_date": "2025-01-06",
        "location": "Zone A",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2024-12-21"
    },
    {
        "description": "Vacances de No\u00ebl",
        "end_date": "2025-01-06",
        "location": "Zone B",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2024-12-21"
    },
    {
        "description": "Vacances d'hiver",
        "end_date": "2025-02-24",
        "location": "Zone A",

EOEXPECTED
}

echo 'Run run_cat'

{ run_cat_code || true ; } > "${TMP}/code.txt" 2>&1
run_cat_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_cat"
exit 1
}


  cat<<EOF >> "${CLKCONFIGDIR}/python/holidays.py"

@holidays.command()
@argument("location", help="Location to filter by (e.g., 'Zone A')")
def show(location):
    """Show holidays for a specific location."""
    data = fetch_holidays()
    filtered = [h for h in data if h["location"] == location]
    echo_json(filtered)
EOF


run_filter_code () {
      clk holidays show "Zone A" 2>/dev/null
}

run_filter_expected () {
      cat<<"EOEXPECTED"
[
    {
        "description": "Vacances de No\u00ebl",
        "end_date": "2025-01-06",
        "location": "Zone A",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2024-12-21"
    },
    {
        "description": "Vacances d'hiver",
        "end_date": "2025-02-24",
        "location": "Zone A",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2025-02-08"
    },
    {
        "description": "Vacances de printemps",
        "end_date": "2025-04-22",
        "location": "Zone A",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2025-04-05"
    }
]

EOEXPECTED
}

echo 'Run run_filter'

{ run_filter_code || true ; } > "${TMP}/code.txt" 2>&1
run_filter_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_filter"
exit 1
}
# script ends here
