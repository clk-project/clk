#!/usr/bin/env python3
"""Convert coverage.py JSON (with contexts) to TestIQ format.

Input format (coverage.py --show-contexts):
{
  "files": {
    "clk/core.py": {
      "contexts": {
        "42": ["test1", "test2"],
        "43": ["test1"]
      }
    }
  }
}

Output format (TestIQ):
{
  "test1": {"clk/core.py": [42, 43]},
  "test2": {"clk/core.py": [42]}
}
"""

import json
import sys
from collections import defaultdict
from pathlib import Path


def convert_coverage_to_testiq(coverage_json_path, output_path):
    """Convert coverage.py JSON to TestIQ format."""
    with open(coverage_json_path) as f:
        data = json.load(f)

    # Build inverted index: test_name -> {filename -> [lines]}
    test_coverages = defaultdict(lambda: defaultdict(list))

    for filename, file_data in data.get("files", {}).items():
        contexts = file_data.get("contexts", {})
        for line_str, test_names in contexts.items():
            line = int(line_str)
            # TestIQ requires line numbers >= 1
            if line < 1:
                continue
            for test_name in test_names:
                # Skip empty context (global coverage)
                if not test_name:
                    continue
                test_coverages[test_name][filename].append(line)

    # Sort lines and convert to regular dicts
    result = {}
    for test_name, files in sorted(test_coverages.items()):
        result[test_name] = {
            filename: sorted(lines) for filename, lines in sorted(files.items())
        }

    with open(output_path, "w") as f:
        json.dump(result, f, indent=2)

    print(f"Converted {len(result)} tests to TestIQ format: {output_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <coverage-contexts.json> <output.json>")
        sys.exit(1)

    convert_coverage_to_testiq(Path(sys.argv[1]), Path(sys.argv[2]))
