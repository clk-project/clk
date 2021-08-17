#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
from subprocess import check_output


def test_command():
    output = check_output(['clk', 'command', 'display'], encoding='utf8')
    assert re.search(r'flowdep\s+Manipulate command flow dependencies\.', output)
