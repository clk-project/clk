#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from pathlib import Path
from subprocess import check_call


def test_use_cases():
    use_cases = Path(__file__).parent / "use_cases"
    for script in use_cases.iterdir():
        if str(script).endswith(".sh"):
            check_call(["bash", "-e", "-u", str(script)], cwd=str(use_cases))
