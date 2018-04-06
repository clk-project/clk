#!/usr/bin/env python

import os
import subprocess
import shlex
import argparse

parser = argparse.ArgumentParser(
    description="""Save a file or directory in git and upload it.

    It leaves behind a file with the name of the saved file plus ".hash". This hash
    file is what you commit into git and share with your collabrators.

    Other people can retrieve the file by running the script
    git-record_reset.py, providing the hash file.
    """
)

parser.add_argument('-r', '--remote',
                    help="""The remote to upload the data to (default: origin)""",
                    type=str,
                    required=False,
                    default="origin")
parser.add_argument('file_or_directory',
                    help='The file or directory to update')


def run(cmd):
    print("+ {}".format(cmd))
    return subprocess.check_output(shlex.split(cmd.strip())).decode("utf-8").strip()


if __name__ == "__main__":
    args = parser.parse_args()
    full = os.path.abspath(args.file_or_directory)
    if full.endswith(".hash"):
        full = full[:-len(".hash")]

    dir = os.path.dirname(full)
    name = os.path.basename(full)
    normname = name.replace(".", "_").replace(" ", "_")
    os.chdir(dir)

    prefix = run("git rev-parse --show-prefix")
    run("""git reset "{}" """.format(name))
    if os.path.isdir(full):
        run("""git add -f -- "{}" """.format(name))
        blob = run("""git write-tree --prefix "{}{}" """.format(prefix, name))
    else:
        blob = run("""git hash-object -w -- "{}" """.format(full))
    version = blob[:8]
    ref = "refs/git-store/{}-{}".format(normname, version)
    run("git update-ref {} {}".format(ref, blob))
    run("git push {} {}".format(args.remote, ref))
    hash_file = name + ".hash"
    open(hash_file, "wb").write(ref.encode("utf-8"))
    run("""git reset "{}" """.format(name))
