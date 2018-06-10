#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
import subprocess

import click

from click_project.decorators import group, option, argument, flag, table_format,\
    table_fields
from click_project.lib import which, check_output, call, createfile, ParameterType,\
    TablePrinter
from click_project.completion import startswith
from click_project.log import get_logger

LOGGER = get_logger(__name__)


def git():
    git = which("git")
    if not git:
        raise click.UsageError("Git is needed to use the git-store command")
    return git


def get_refs(remote=None):
    ref_command = ["ls-remote", remote] if remote else ["show-ref"]

    def split(ref):
        res = ref.split(" ")
        res[1] = res[1][len("refs/git-store/"):]
        return res

    return [
        split(line)
        for line in check_output(
                [git()] + ref_command,
                internal=True,
                nostderr=True,
        ).strip().replace("\t", " ").splitlines()
        if line.split(" ")[1].startswith("refs/git-store/")
    ]


def get_refs_names(remote=None):
    return [
        ref[1]
        for ref in get_refs(remote)
    ]


def get_refs_dict(remote=None):
    return {
        ref[1]: ref[0]
        for ref in get_refs(remote)
    }


def notes_command():
    return [git(), "notes", "--ref", "git-store"]


_note_ref = None


def note_ref():
    global _note_ref
    if _note_ref is None:
        _note_ref = check_output(notes_command() + ["get-ref"]).strip()
    return _note_ref


_current_remote = None


def current_remote():
    global _current_remote
    if _current_remote is None:
        try:
            _current_remote = check_output(
                [
                    git(), "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"
                ],
                internal=True,
                nostderr=True,
            ).strip().split("/")[0]
        except subprocess.CalledProcessError:
            pass
    return _current_remote


@group(default_command="show")
def git_store():
    """Store data in a git repository

    This is a low level command. If you want to manage data files of a project,
    consider using the higher level command gt-record.

    Guess your model depends on client data. You generally want those data to
    hang around your code to take advantage of them. But you you don't want to
    mix those data with your code because:

    1. data and code don't belong to the same intellectual property

    2. data will irreversibly increase the repository size even when you don't need the data anymore

    Generally, you put your data in some NAS but:

    1. it is not practical to have to fetch them every time

    2. you may be out of sync easily

    3. you need two credentials: one for git, one for the NAS

    4. people being able to change the data in the NAS, you cannot make sure of the reproducibility of your simulations

    Guess what? Git was designed as a file system. There is better: when you put
    a file or directory in git, it returns a so called hash value (remember the
    git sha1?) that identifies the file by its content. You can retrieve this
    file/directory later with its hash value. You will be sure to have the exact
    same content. This is particularly important in reproducible research when
    you want to make sure you always run the same simulation with the same
    input. Of course, to ease file retrieval, you can also provide fancy names
    to files stored in git.

    Technicaly, you save a file/directory foo by calling 'git-store save
    foo' will indicate in return the name of the object to retrieve it
    later. The name is composed of the original file name along with the first 8
    characters of its hash value. This name is more than enough to prevent name
    clashes even when saving other files with the same name. You can still
    provide your prefered name with 'git-store save --name "foo/v1" foo'.

    To see what files are saved in git, use 'git-store show'

    To restore the file content somewhere, use 'git-store restore foo/v1
    --file foo'

    To send the file to a git remote so that everyone can get access to it:
    'git-store push foo/v1'

    To see what files are saved in a git remote bar, use 'git-store show
    --remote bar'

    To fetch the file from the remote bar 'git-store fetch --from bar
    --name foo/v2'. Then you will be able to run 'git-store restore foo/v2
    --file foo'

    To add notes to files, try 'git-store notes --help'
    """
    if toplevel() is None:
        raise click.UsageError(
            "Using git store commands only makes sense in a git repository"
        )


_git_remotes = None


def git_remotes():
    global _git_remotes
    if _git_remotes is None:
        _git_remotes = check_output([git(), "remote"]).splitlines()
    return _git_remotes


class GitRemoteType(ParameterType):
    def complete(self, ctx, incomplete):
        return [
            clr
            for clr in git_remotes()
            if startswith(clr, incomplete)
        ]


class LocalReferenceType(ParameterType):
    def __init__(self, notinremote=False):
        self.notinremote = notinremote

    @property
    def refs(self):
        if self.notinremote and _remote is not None:
            return list(set(get_refs_names()) - set(get_refs_names(_remote)))
        else:
            return get_refs_names()

    def complete(self, ctx, incomplete):
        return [
            clr
            for clr in self.refs
            if startswith(clr, incomplete)
        ]

    def convert(self, value, param, ctx):
        choices = self.refs + ["*"]
        if value not in choices:
            self.fail('invalid choice: %s. (choose from %s)' %
                      (value, ', '.join(choices)), param, ctx)
        return "refs/git-store/{}".format(value)


class RemoteReferenceType(ParameterType):
    def __init__(self, notinlocal=False):
        super(RemoteReferenceType, self).__init__()
        self.notinlocal = notinlocal

    @property
    def refs(self):
        if self.notinlocal:
            return list(set(get_refs_names(_remote)) - set(get_refs_names()))
        else:
            return get_refs_names(_remote)

    def complete(self, ctx, incomplete):
        if _remote:
            return [
                clr
                for clr in self.refs
                if startswith(clr, incomplete)
            ]
        else:
            return []

    def convert(self, value, param, ctx):
        choices = self.refs + ["*"]
        if value not in choices:
            self.fail('invalid choice: %s. (choose from %s)' %
                      (value, ', '.join(choices)), param, ctx)
        return "refs/git-store/{}".format(value)


@git_store.command()
@argument('file', required=True)
@option('--name', help=(
    "Name of the saved file."
    " Its default value is generally a good choice,"
    " thus use this option only if you know what you are doing"))
@flag("--force", help=(
    "Force the insertion of the file in git,"
    " even though a file with the same name already exists."
    " Use this only if you understand what it does."
))
@flag("--create-hash-file/--dont-create-hash-file",
      help="Create a hash file, to be consumed by generated hash scripts")
def save(name, file, force, create_hash_file):
    """Save the file or directory into git

    If a different file associated to the same name already exists, it means you
    are probably trying to shoot yourself in the foot: the command will fail.
    You can bypass this security with --force.

    """
    name = _save(name, file, force, create_hash_file=create_hash_file)
    click.echo("Saved {} with the git name {}".format(file, name))


_toplevel = None


def toplevel():
    global _toplevel
    if _toplevel is None:
        try:
            _toplevel = check_output(
                [git(), "rev-parse", "--show-toplevel"],
                nostderr=True,
                internal=True,
            ).strip()
        except subprocess.CalledProcessError:
            pass
    return _toplevel


def _save(name, file, force, create_hash_file=False):
    full = os.path.abspath(file)
    hash_file = full + ".hash"
    dir = os.path.dirname(full)
    file = os.path.basename(full)
    tl = toplevel()
    prefixfile = os.path.relpath(full, tl)
    if os.path.isdir(full):
        call([git(), "add", "-f", "--", file], cwd=dir)
        blob = check_output([git(), "write-tree", "--prefix", prefixfile]).strip()
        check_output([git(), "reset", "--", file], nostderr=True)
    else:
        blob = check_output([git(), "hash-object", "-w", "--", full]).strip()
    name = name or (file + "-" + blob[:8])
    name = name.replace(".", "_").replace(" ", "_")
    if create_hash_file:
        createfile(hash_file, name)
    refs_dict = get_refs_dict()
    if not force and name in refs_dict:
        other_blob = refs_dict[name]
        if blob == other_blob:
            LOGGER.warning("The git name {} already exists"
                           " and is associated to the same content".format(
                               name,
                               blob,
                           ))
            return name
        else:
            raise click.UsageError(
                "The git name {} already exists with hash {}."
                " You are willing to associate it with the hash {}."
                " Either choose another name or use --force"
                " if you know what you are doing".format(
                    name,
                    other_blob,
                    blob,
                ))
    ref = "refs/git-store/{}".format(name)
    check_output([git(), "update-ref", ref, blob])
    return name


@git_store.command()
@option("-r", "--remote", type=GitRemoteType(),
        help=(
            "Instead of showing the file available locally,"
            " list those available to be fetched from the remote"
        ))
@table_fields(choices=['ref', 'details'])
@table_format(default='key_value')
@flag("--with-notes", help=(
    "Show the first line of notes on the file."
    " See git-store notes --help for more info"
))
@argument("name", type=LocalReferenceType(), nargs=-1)
def show(remote, format, fields, with_notes, name):
    """Show the available files

    It also show some low level information about the file, like its hash value.

    If you want to list the files of a remote, use the --remote option.
    """
    refs = [
        r
        for r in get_refs(remote)
        if not name or "refs/git-store/" + r[1] in name
    ]

    def get(blob_ref):
        ref = "refs/git-store/" + blob_ref[1]
        res = "Hash: {}".format(blob_ref[0][:8])
        try:
            typ = check_output(
                [git(), "cat-file", "-t", ref],
                nostderr=True,
                internal=True,
            ).strip()
        except subprocess.CalledProcessError:
            typ = "unknown"
        res += " , Type: {}".format(typ)
        if with_notes:
            try:
                note = check_output(notes_command() + ["show", ref], nostderr=True).strip()
            except subprocess.CalledProcessError:
                note = None
            if note:
                res += " , Note: {}".format(note.splitlines()[0])
        return res

    with TablePrinter(fields, format) as tp:
        for ref in refs:
            tp.echo(ref[1], get(ref))


@git_store.command()
@argument("name", type=LocalReferenceType())
def cat(name):
    """Display the file content

    If it is a file, show its content. If it is a directory, show its files
listing.

    """
    call([git(), "cat-file", "-p", name])


@git_store.command()
@option("-f", "--from", "remote", type=GitRemoteType(),
        help="Remove from this remote")
@argument("name", type=LocalReferenceType())
def remove(remote, name):
    """Remove the file

    The file is removed locally. If --from is used, the file is removed
    from this remote instead (i.e. without removing locally)

    """
    call([git()] +
         (["push", "-d", remote] if remote else ["update-ref", "-d"]) +
         [name])
    LOGGER.status("Removed {}".format(name))


_remote = None


def remote_callback(ctx, attr, value):
    global _remote
    if value:
        _remote = value
    return value


@git_store.command(handle_dry_run=True)
@option("-f", "--from", "remote", required=True, default=current_remote, is_eager=True,
        type=GitRemoteType(), callback=remote_callback,
        help="The remote to fetch from")
@option("--name", default="*", type=RemoteReferenceType(notinlocal=True), multiple=True)
def fetch(remote, name):
    """Fetch those files from the remote

    Once fetched, you can cat or restore them

    """
    for ref_ in name:
        call([git(), "fetch", remote, "{}:{}".format(ref_, ref_)])


@git_store.command()
@option("-t", "--to", "remote", default=current_remote, type=GitRemoteType(),
        help="The remote to push to", callback=remote_callback)
@option("--name", default="*", type=LocalReferenceType(notinremote=True),
        multiple=True)
@flag("--force/--no-force",
      help="Force the push (you probably won't want to do that)")
def push(remote, name, force):
    """Send the file to the given remote"""
    args = [git(), "push", remote]
    if force:
        args.append("--force")
    for ref_ in name:
        call(args + [ref_])


@git_store.command()
@argument("name", type=LocalReferenceType())
@option("--file", help="Location where to put the content")
def restore(file, name):
    """Put the content of name into file

    By default, put the content of name on a file/directory with the same
    name. You can provide a different location with --file

    """
    file = file or name[len("refs/git-store/"):]
    file = os.path.abspath(file)
    tl = toplevel()
    prefixfile = os.path.relpath(file, tl)
    if check_output([git(), "cat-file", "-t", name]).strip() == "tree":
        call([git(), "read-tree", name, "--prefix", prefixfile])
        call([git(), "checkout", "--", file])
        check_output([git(), "reset", "--", file])
    else:
        call([git(), "cat-file", "blob", name], stdout=open(file, "w"))
    LOGGER.info(
        "Restored git name {} in location {}".format(
            name[len("refs/git-store/"):],
            prefixfile
        ))


@git_store.group()
def notes():
    """Manipulate notes on files

    Sometimes, one wants to store some information to explain what the file is
    and why it is important. Git allows to store notes associated to file for
    exactly this purpose.

    Generally, you just need to call 'git-store notes set -m "some
    information" foo/v1' to set the note.

    To send the note for everyone to see it, just run 'git-store notes
    push'.

    To fetch the notes written by someone else, run 'git-store notes fetch'
"""
    pass


@notes.command()
@option("-m", "--message", required=True, help="The message to set as note")
@argument("name", type=LocalReferenceType())
def _set(message, name):
    """Set a message as note of the file"""
    call(
        notes_command() + [
            "add", "-f",
            "-m", message,
            name
        ]
    )


@notes.command()
@option("-m", "--message", required=True, help="The message to append as note")
@argument("name", type=LocalReferenceType())
def append(message, name):
    """Append the message to the note associated to the file"""
    call(
        notes_command() + [
            "append",
            "-m", message,
            name
        ]
    )


@notes.command()
@argument("name", type=LocalReferenceType())
def edit(name):
    """Edit the note of the file"""
    call(
        notes_command() + [
            "edit",
            name
        ]
    )


@notes.command()
@argument("name", type=LocalReferenceType())
def _remove(name):
    """Remove the note associated to the file"""
    call(
        notes_command() + [
            "remove",
            name
        ]
    )


@notes.command()
@argument("name", type=LocalReferenceType())
def _show(name):
    """Show the note associated to the file"""
    call(
        notes_command() + [
            "show",
            name
        ]
    )


@notes.command()
@argument("remote", type=GitRemoteType())
def _push(remote):
    """Send all the notes to the git remote"""
    call(
        [
            "git", "push",
            remote, "{}:{}".format(note_ref(), note_ref())
        ]
    )


@notes.command()
@argument("remote", type=GitRemoteType())
def _fetch(remote):
    """Fetch all the notes from the git remote"""
    call(
        [
            "git", "fetch",
            remote, "{}:{}".format(note_ref(), note_ref())
        ]
    )
