#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
from pathlib import Path
from subprocess import PIPE, CalledProcessError

import pytest


def test_normal_use_case(lib, rootdir):
    location = Path(os.environ['CLKCONFIGDIR']) / 'plugins' / 'a.py'
    lib.cmd('''plugin create global a --no-open --body "print('loaded')"''')
    assert lib.cmd('echo foo') == 'loaded\nfoo'
    assert lib.cmd('plugin show --no-legend --field name') == 'loaded\na'
    assert lib.cmd('plugin which global a') == f'loaded\n{location}'
    lib.cmd('extension create a-b')
    lib.cmd('''plugin create global/a-b a --no-open --body "print('loaded2')"''')
    assert lib.cmd('echo foo') == 'loaded2\nloaded\nfoo'
    with pytest.raises(CalledProcessError) as e:
        lib.cmd('plugin move global a global/a-b', stderr=PIPE)
    assert re.match(".*I won't overwrite [/0-9a-zA-Z_-]+/plugins/a.py, unless.*", e.value.stderr)
    lib.cmd('plugin move --force global a global/a-b')
    assert lib.cmd('echo foo') == 'loaded\nfoo'
    lib.cmd('plugin rename global/a-b a b')
    lib.cmd('plugin remove global/a-b b', input='yes')
    assert lib.cmd('echo foo') == 'foo'
