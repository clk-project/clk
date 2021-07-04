# noqa: D300,D400
# Copyright (c) 2016, Aaron Christianson
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'''
Monkey patch setuptools to write a simple bash script that run the entry point


From the work of Aaron Christianson in http://github.com/ninjaaron/fast-entry_points
'''
import sys
from setuptools.command import easy_install


@classmethod
def get_args(cls, dist, header=None):  # noqa: D205,D400
    """
    Yield write_script() argument tuples for a distribution's
    console_scripts and gui_scripts entry points.
    """
    for type_ in 'console', 'gui':
        group = type_ + '_scripts'
        for name, ep in dist.get_entry_map(group).items():
            # pylint: disable=E1101
            args = cls._get_script_args(
                type_,
                name,
                "#!/bin/bash\n",
                f"""exec {sys.executable} -m click_project.main "$@" """.rstrip()
            )
            for res in args:
                yield res


# pylint: disable=E1101
easy_install.ScriptWriter.get_args = get_args
