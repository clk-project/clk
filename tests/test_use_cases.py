#!/usr/bin/env python3

import os
from pathlib import Path
from subprocess import check_call

import pytest

USE_CASES = Path(__file__).parent / "use_cases"
EXCLUDED = {"sandboxing.sh"}

scripts = sorted(p.name for p in USE_CASES.glob("*.sh") if p.name not in EXCLUDED)


@pytest.mark.parametrize(
    "script", scripts, ids=[s.removesuffix(".sh") for s in scripts]
)
def test_use_case(rootdir, script):
    env = os.environ.copy()
    check_call(
        ["bash", "-e", "-u", str(USE_CASES / script)], cwd=str(USE_CASES), env=env
    )
