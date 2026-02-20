#!/usr/bin/env python3
"""Sanitize coverage report markdown files for reproducibility.

Removes timestamps and version numbers that would cause spurious diffs.
"""

import re
import sys
from pathlib import Path


def sanitize_testiq_md(content):
    """Remove timestamp and version from TestIQ markdown."""
    # Remove "**Generated:** 2026-02-16 22:46:29" line
    content = re.sub(
        r"\*\*Generated:\*\* \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\n", "", content
    )
    # Remove "**TestIQ Version:** 0.2.2" line
    content = re.sub(r"\*\*TestIQ Version:\*\* [\d.]+\n", "", content)
    return content


def sanitize_file(filepath):
    """Sanitize a markdown file in place."""
    path = Path(filepath)
    if not path.exists():
        print(f"Warning: {filepath} not found, skipping")
        return False

    content = path.read_text()
    original = content

    # Apply sanitization based on filename
    if "testiq" in path.name.lower():
        content = sanitize_testiq_md(content)

    # Only write if changed
    if content != original:
        path.write_text(content)
        print(f"Sanitized: {filepath}")
        return True
    else:
        print(f"No changes: {filepath}")
        return False


def main():
    if len(sys.argv) < 2:
        print("Usage: sanitize_coverage_reports.py <file1.md> [file2.md ...]")
        sys.exit(1)

    for filepath in sys.argv[1:]:
        sanitize_file(filepath)


if __name__ == "__main__":
    main()
