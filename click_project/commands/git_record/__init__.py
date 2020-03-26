#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
from datetime import datetime
import dateutil.parser

import click

from click_project.config import config
from click_project.decorators import group, option, argument, use_settings,\
    pass_context, flag, table_format, table_fields
from click_project.lib import rm, copy, TablePrinter
from click_project.commands.git_store import _save, restore, current_remote,\
    GitRemoteType, push as git_store_push, fetch as git_store_fetch,\
    get_refs, remove as git_store_remove
from click_project.log import get_logger
from click_project.overloads import CommandSettingsKeyType

LOGGER = get_logger(__name__)


class GitRecordConfig(object):
    pass


def assert_file_in_level(files):
    for file in files:
        if file not in config.git_record.writable:
            raise click.UsageError(
                "{} not in level {}, try to use another level".format(
                    file, config.git_record.writeprofile
                )
            )


def assert_indices(files, index):
    for file in files:
        length = len(config.git_record.writable[file])
        if length <= index:
            raise click.UsageError(
                "The record {} does not have enough record ({})"
                " to be given the index {}".format(file, length, index)
            )


@group(default_command="show")
@use_settings("git_record", GitRecordConfig)
def git_record():
    """With git-record, you record data files in your project that will not be
    committed but still be available by anyone cloning the git repository. In
    addition, it records the location of the data so that you don't even need to
    copy/move anything manually.

    To record that the directory/file foo is data, run "git-record add
    foo". foo will be stored in git and recorded in the project configuration.
    This command may be run several times to record another
    version of foo.

    To see what files are currently recorded, run "git-record show". It will
    show the location of the recorded files as well as their unique name known
    in git. The later ensures that the file content is always the same: thus, a
    change implies a change in the content of the file.

    To upload all the files so that everyone can download them, run "git-record
    upload"

    To restore the files so that they become visible in your file system, run
    "git-record restore". This command may be run several times to reset the
    files in case of unwanted changes.

    RATIONALE:

    It is a well known fact that storing data files in a version control system
    (VCS), such as git or svn, is a bad idea. This is because once committed,
    you can never ask the VCS to forget the data, and accumulation of data may
    take a lot of space. At some point, you generally want to archive old data
    in some backup disk and don't want to here of it anymore.

    On another hand, the core of git is basically a file storage system. Hence,
    while committing data in git is a bad idea, storing data is worth the try.

    The main advantage of this solution is that you don't need to remember the
    credential/location of the data in some random nas. The second good point is
    that since git is a content addressable storage, you are ensured to always
    get the same data: there is no risk of someone else modifying the data
    without you being aware of it.

    """
    config.require_project()


@git_record.command()
@argument("file", help="The file to add.")
@option("--name", help=(
    "Name to use, instead of the computed one."
    " You should not need this option,"
    " unless in very specific advanced use cases"
))
@option("-m", "--message", help="Message to describe the record")
@flag("--create-hash-file/--dont-create-hash-file",
      default=True,
      help="Create a hash file, to be consumed by generated hash scripts")
@flag("--upload/--no-upload", help=(
    "Upload the content as soon as added."
    " People tend to forget to upload and think their data is safe on the remote."
    " The default value of True is then conservative."), default=True)
@pass_context
def add(ctx, file, name, message, create_hash_file, upload):
    """Add the data file/directory in the git record

    If a content was already associated to the file, add this one on top of the
    list, allowing to retrieve later old versions of the file.

    You can provide a message to describe the file, so that you remember why you
    stored it.

    """
    full = os.path.abspath(file)
    rel = os.path.relpath(full, config.project)
    name = _save(name, file, False, create_hash_file=create_hash_file)
    records = config.git_record.writable.get(rel, [])
    records.append({
        "name": name,
        "documentation": message,
        "date": datetime.now().isoformat(),
    })
    config.git_record.writable[rel] = records
    config.git_record.write()
    LOGGER.status("Successfully added {}".format(name))
    if upload:
        ctx.invoke(_upload, file=(rel,))


@git_record.command()
@argument('file', nargs=-1, type=CommandSettingsKeyType("git_record"))
def remove(file):
    """Remove the file from the git record

    Only the association between a git file and the given location is
    removed. To remove from git the unused files, use git-record prune.

    """
    for fil in file:
        del config.git_record.writable[fil]
        LOGGER.status("Successfully removed {}".format(fil))
    config.git_record.write()


@git_record.command()
@pass_context
def prune_git_files(ctx):
    """Remove all the git files not in the git-record

    It removes from git all the files that are no more references by git
    records. Use this command only if you know what you are doing.

    """
    for ref in [r[1] for r in get_refs()]:
        if ref not in [
                record["name"]
                for records in config.git_record.readonly.values()
                for record in records
        ]:
            ctx.invoke(git_store_remove, name="refs/git-store/" + ref)


@git_record.command()
@argument('file', nargs=-1, type=CommandSettingsKeyType("git_record"))
@pass_context
def prune_old_records(ctx, file):
    """Remove all the old records

Keeping only the last record.
"""
    file = file or config.git_record.writable.keys()
    assert_file_in_level(file)
    pruned = 0
    for fil in file:
        for name, records in config.git_record.writable.items():
            if len(records) > 1:
                pruned += len(records) - 1
                config.git_record.writable[name] = [records[-1]]
    config.git_record.write()
    if pruned:
        LOGGER.info(
            "Pruned {} records,"
            " you might want to run the prune-git-files also.".format(
                pruned
            )
        )


@git_record.command()
def clean():
    """Remove the files/directories known by git from your file system

    It makes the file system bare naked, like before the first restore call.

    """
    for rel in config.git_record.readonly.keys():
        full = os.path.join(config.project, rel)
        if os.path.exists(full):
            LOGGER.status("Removing {}".format(rel))
            rm(full)


@git_record.command()
@option("-f", "--from", "remote", default=current_remote, type=GitRemoteType(),
        help="The remote to download from")
@argument('file', nargs=-1, type=CommandSettingsKeyType("git_record"))
@pass_context
def _restore(ctx, file, remote):
    """Restore the files from git

    Make them appear in your file system. If the files already exist, reset them
    to the content they should have.

    """
    file = file or config.git_record.readonly.keys()
    ctx.invoke(download, file=file, remote=remote)
    for fil in file:
        values = config.git_record.readonly[fil]
        full = os.path.join(config.project, fil)
        name = values[-1]["name"]
        ctx.invoke(restore, file=full, name="refs/git-store/" + name)


@git_record.command(handle_dry_run=True)
@option("-i", "--index", help="Index of the record to take into account."
        " 1 is the most recent one.", type=int, default=1)
@argument('file', nargs=-1, type=CommandSettingsKeyType("git_record"))
def pop(file, index):
    """Pop the git records at index"""
    if not file:
        raise click.UsageError("You must precise at least one file to act upon")
    assert_indices(file, index)
    assert_file_in_level(file)
    for fil in file:
        records = config.git_record.writable[fil]
        LOGGER.status("Erasing record at index {} for file {}".format(index, fil))
        del records[-index]
        config.git_record.writable[fil] = records
    config.git_record.write()


@git_record.command(handle_dry_run=True)
@table_format(default='key_value')
@table_fields(choices=['key', 'details'])
@flag("-a", "--all", help="Show all the records for a given file")
@option("-i", "--index", help="Index of the record to take into account."
        " 1 is the most recent one.", type=int)
def show(format, all, fields, index):
    """Show the git records

    The first value is the path where the file/directory should be located. Ths
    second value is the name of the file in the git store. Since git is content
    addressable, a same git store name indicates a same content.

    """
    if index and all:
        raise click.UsageError("--index and --all are mutually exclusives")

    index = index or 1
    locally_avail_names = {
        r[1]
        for r in get_refs()
    }

    def format_records(records):
        def format_record(record):
            res = record["name"]
            if "documentation" in record and record["documentation"]:
                res += " '{}'".format(record["documentation"])
            if record["name"] in locally_avail_names:
                res += " (in here)"
            else:
                res += " (not in here)"
            if "date" in record:
                res += " (Recorded at {})".format(dateutil.parser.parse(record["date"]))
            return res

        top = records[-index]
        res = format_record(top)
        if len(records) > 1:
            res += " ({}/{})".format(index, len(records))
        if all and len(records) > 1:
            res += ". Other records: {}".format(
                ", ".join(
                    "{}: {}".format(index_ + 1, format_record(record))
                    for index_, record in enumerate(reversed(records[:-1]))
                )
            )
        return res

    with TablePrinter(fields, format) as tp:
        for key in sorted(config.git_record.readonly.keys()):
            tp.echo(key, format_records(config.git_record.readonly[key]))


@git_record.command()
@option("-m", "--message", help="Message to describe the record")
@argument('file', nargs=-1, type=CommandSettingsKeyType("git_record"))
@option("-i", "--index", help="Index of the record to take into account."
        " 1 is the most recent one.", type=int, default=1)
def set_documentation(file, message, index):
    """Set the documentation of the given file"""
    # starting from the end, the index starts at 1
    file = set(file or config.git_record.writable.keys())
    assert_indices(file, index)
    assert_file_in_level(file)
    for fil in file:
        record = config.git_record.writable[fil][-index]
        if message:
            documentation = message
        else:
            documentation = click.prompt("Message")
        record["documentation"] = documentation
    config.git_record.write()


@git_record.command()
@option("-t", "--to", "remote", default=current_remote, type=GitRemoteType(),
        help="The remote to upload to")
@flag("--force", help="Force transferring the file even if it looks useless")
@argument('file', nargs=-1, type=CommandSettingsKeyType("git_record"))
@pass_context
def _upload(ctx, file, remote, force):
    """Upload the files/directorie

    So that anyone can download them.
"""
    file = set(file or config.git_record.readonly.keys())
    remote_names = {
        r[1]
        for r in get_refs(remote)
    }
    local_names = {
        config.git_record.readonly[fil][-1]["name"]
        for fil in file
    }
    locally_avail_names = {
        r[1]
        for r in get_refs()
    }
    names = local_names.copy()
    for name in local_names - locally_avail_names:
        local_file = {
            fil
            for fil in file
            if config.git_record.readonly[fil][-1]["name"] == name
        }
        names.remove(name)
        for fil in local_file:
            file.remove(fil)
            LOGGER.error(
                "{} is not there"
                " because the git file {} is not available."
                " It won't be uploaded to {}".format(
                    fil,
                    name,
                    remote,
                ))
    local_names = names.copy()
    if not force:
        for name in local_names & remote_names:
            local_file = {
                fil
                for fil in file
                if config.git_record.readonly[fil][-1]["name"] == name
            }
            names.remove(name)
            for fil in local_file:
                file.remove(fil)
                LOGGER.info(
                    "{} is already in"
                    " {} because the git file {} is already there"
                    " (use --force to still upload)".format(
                        fil,
                        remote,
                        name,
                    ))
    if file:
        ctx.invoke(
            git_store_push,
            remote=remote,
            name=["refs/git-store/" + name for name in names],
        )
        LOGGER.status("Uploaded {}".format(
            ", ".join(file)
        ))


@git_record.command()
@option("-f", "--from", "remote", default=current_remote, type=GitRemoteType(),
        help="The remote to download from")
@flag("--force", help="Force transferring the file even if it looks useless")
@argument('file', nargs=-1, type=CommandSettingsKeyType("git_record"))
@pass_context
def download(ctx, file, remote, force):
    """Download the files/directories

    This command is generally not needed, since the restore command implies
    downloading.

    """
    file = set(file or config.git_record.readonly.keys())
    remote_names = {
        r[1]
        for r in get_refs(remote)
    }
    local_names = {
        config.git_record.readonly[fil][-1]["name"]
        for fil in file
    }
    locally_avail_names = {
        r[1]
        for r in get_refs()
    }
    names = local_names.copy()
    if not force:
        for name in local_names & locally_avail_names:
            local_file = {
                fil
                for fil in file
                if config.git_record.readonly[fil][-1]["name"] == name
            }
            names.remove(name)
            for fil in local_file:
                file.remove(fil)
                LOGGER.info(
                    "{} is already there"
                    " because the git file {} is available"
                    " (use --force to still download it)".format(
                        fil,
                        name,
                    ))
    local_names = names.copy()
    for name in local_names - remote_names:
        local_file = {
            fil
            for fil in file
            if config.git_record.readonly[fil][-1]["name"] == name
        }
        names.remove(name)
        for fil in local_file:
            file.remove(fil)
            LOGGER.error(
                "{} is not available in"
                " {} because the git file {} is missing".format(
                    fil,
                    remote,
                    name,
                ))
    if file:
        ctx.invoke(
            git_store_fetch,
            remote=remote,
            name=["refs/git-store/" + name for name in names],
        )
        LOGGER.status("Downloaded {}".format(
            ", ".join(file)
        ))


@git_record.command()
def generate_scripts():
    """Generate scripts to reset and update a git record without using git-record

    It create two file, git-record_save.py and git-record_reset.py in the
    current directory. Those files are pure standalone python programs that yàu
    can commit to record files in git without using git-record.

    The script git-record_save.py saves/updates a file/directory (given as
    parameter) in git and records its hash into a hash file with the same name
    and ending with ".hash".

    You need to commit the hash file only. People can retrieve the file by
    running the script git-records_reset.py with the hash file as parameter.

    Those scripts give you the freedom to use a feature close enough to
    git-record without forcing you and your team to use git-record.

    """
    dir = os.path.dirname(os.path.abspath(__file__))
    dst = os.getcwd()
    for file in ["git-record_reset.py", "git-record_save.py"]:
        copy(os.path.join(dir, file), dst)
    click.echo("To add/update a data dir/file FOO, run 'python git-record_save.py FOO'")
    click.echo("To restore a data dir/file FOO, run 'python git-record_reset.py FOO'")


@git_record.command()
@argument("file", nargs=-1)
@pass_context
def hash_restore(ctx, file):
    """For each file, restore it using its hash file

    One of the two commands used to collaborate with people not using git-record,
    but still store files in git.

    This commands restores a file from git, reading its hash from a hash file
    with the same name and ending with ".hash".

    This file must have been stored by issuing the commend `git-store
    hash-save FILE`.

    To collaborate with users that don't want to use git-record, generate the
    git helpers scripts with `git-record generate-scripts`, commit them and say
    to your friends to run `python git-record_update.py FILE` to save file so
    that you can retrieve them.

    The file name or the hash file name can be given

    """
    for fil in file:
        if fil.endswith(".hash"):
            fil = fil[:-len(".hash")]
        full = os.path.abspath(fil)
        basename = os.path.basename(full)
        hash_file = os.path.join(
            os.path.dirname(full),
            basename + ".hash"
        )
        ref = open(hash_file, "rb").read().decode("utf-8")
        ctx.invoke(restore, file=fil, name=ref)


@git_record.command()
@argument("file", nargs=-1)
@flag("--force", help=(
    "Force the insertion of the file in git,"
    " even though a file with the same name already exists."
    " Use this only if you understand what it does."
))
@pass_context
def hash_save(ctx, file, force):
    """For each file, save it using its hash file

    One of the two commands used to collaborate with people not using git-record,
    but still store files in git.

    This commands saves a file in git and records its hash into a hash file with
    the same name and ending with ".hash".

    This file can be retrieved by issuing the commend `git-store
    hash-restore FILE`.

    To collaborate with people not using git-record, generate the git helpers scripts with
    `git-record generate-scripts`, commit them and say to your friends to
    run `python git-record_reset.py FILE`

    The file name or the hash file name can be given

    """
    for fil in file:
        if fil.endswith(".hash"):
            fil = fil[:-len(".hash")]
        full = os.path.abspath(fil)
        basename = os.path.basename(full)
        hash_file = os.path.join(
            os.path.dirname(full),
            basename + ".hash"
        )
        name = _save(name=None, file=fil, force=force)
        ref = "refs/git-store/" + name
        open(hash_file, "wb").write(ref.encode("utf-8"))
