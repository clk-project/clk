#!/usr/bin/env python

import os
import subprocess
import shlex
import shutil
import argparse

parser = argparse.ArgumentParser(
    description="""Donwload and reset a file or directory from git.

    See the documentation of the associated script git-record_save.py.

    A previous run of the script git-record_save.py gave you a hash file.

    You just need to run git-record_reset.py with this hash file as parameter to
    download and recreate the file. The file name will be the name of the hash
    file, without the trailing ".hash".

    """
)

parser.add_argument('-r', '--remote',
                    help="""The remote containing the data (default: origin)""",
                    type=str,
                    required=False,
                    default="origin")
parser.add_argument('file_or_directory',
                    help='The file or directory to reset')


def run(cmd, strip=True):
    print("+ {}".format(cmd))
    res = subprocess.check_output(shlex.split(cmd.strip())).decode("utf-8")
    if strip:
        return res.strip()
    else:
        return res


if __name__ == "__main__":
    args = parser.parse_args()
    full = os.path.abspath(args.file_or_directory)
    if full.endswith(".hash"):
        full = full[:-len(".hash")]
    dir = os.path.dirname(full)
    name = os.path.basename(full)
    os.chdir(dir)

    prefix = run("git rev-parse --show-prefix")
    hash_file = name + ".hash"
    hash = open(hash_file, "rb").read().decode("utf-8").strip()
    run("git fetch -f {} {}:{}".format(args.remote, hash, hash))
    if os.path.isdir(name):
        shutil.rmtree(name)
    elif os.path.exists(name):
        os.unlink(name)
    if run("""git cat-file -t "{}" """.format(hash)) == "tree":
        run("""git read-tree "{}" --prefix "{}{}" """.format(hash, prefix, name))
        run("""git checkout "{}" """.format(name))
        run("""git reset "{}" """.format(name))
    else:
        open(name, "wb").write(
            run(
                """git cat-file blob "{}" """.format(hash),
                strip=False).encode("utf-8"),
        )
