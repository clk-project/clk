#!/usr/bin/env python
# -*- coding:utf-8 -*-

"""General purpose functions, not directly linked to click-project"""

from __future__ import print_function, absolute_import

import difflib
import functools
import hashlib
import heapq
import itertools
import time
import json
import getpass
import os
import platform
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import traceback
from pathlib import Path
from copy import deepcopy
from contextlib import contextmanager

import click
import colorama
import glob2
import six
from six.moves.urllib.request import urlopen
from click._termui_impl import ProgressBar as ProgressBar_

from click_project.click_helpers import click_get_current_context_safe
from click_completion import DocumentedChoice

from click_project.log import get_logger

LOGGER = get_logger(__name__)
dry_run = None
main_module = None


if six.PY3:
    unicode_ = str
else:
    unicode_ = unicode  # NOQA: F821 undefined name 'unicode': Needed for python3 compatibility


DocumentedChoice = DocumentedChoice


def read_properties_file(file_name):
    return dict([
        line.strip().split("=")
        for line in open(file_name, "r").readlines()
        if "=" in line
    ])


def ensure_unicode(value):
    """Convert a string in unicode"""
    if not isinstance(value, unicode_):
        return value.decode("utf-8")
    else:
        return value


def ln(src, dst):
    """Create a symbolink link src -> dst"""
    LOGGER.action("create symlink {} -> {}".format(src, dst))
    if not dry_run:
        os.symlink(src, dst)


def makedirs(dir):
    """Ensure a directory is created.

    Possibly create the parent directories. If the directory already exists, do
    nothing.

    """
    if not os.path.exists(dir):
        LOGGER.action("create directory {}".format(dir))
        if not dry_run:
            os.makedirs(dir)
    return Path(dir)


_makedirs = makedirs


def chmod(file, mode):
    """Change the mode bits of a file"""
    LOGGER.action("chmod {} to {}".format(file, oct(mode)))
    if not dry_run:
        os.chmod(file, mode)


def move(src, dst):
    """Rename src into dst

    See shutil.move

    """
    LOGGER.action(
        "Move {} to {}".format(src, dst))
    if not dry_run:
        shutil.move(src, dst)


def createfile(name, content, append=False, internal=False, force=False, makedirs=False):
    if os.path.exists(name) and not force:
        click.UsageError(f"{name} already exists")
    if makedirs:
        _makedirs(Path(name).parent)
    if internal:
        logger = LOGGER.develop
    else:
        logger = LOGGER.action
    if append:
        logger("appending to the file {}".format(name))
    else:
        logger("writing to the file {}".format(name))
    if dry_run:
        logger("with content {}".format(content))
    else:
        flag = "a" if append else "w"
        flag += "b"
        open(name, flag).write(content.encode("utf-8"))
    return Path(name)


def copy(src, dst):
    LOGGER.action("copy {} to {}".format(src, dst))
    if dry_run:
        return
    if os.path.isdir(src):
        shutil.copytree(src, dst)
    else:
        shutil.copy(src, dst)


def link(src, dst):
    if platform.system() == 'Windows':
        return copy(src, dst)
    LOGGER.action("hard link {} to {}".format(src, dst))
    if dry_run:
        return
    os.link(src, dst)


def rm(*file_or_tree):
    LOGGER.action("remove {}".format(' '.join(map(str, file_or_tree))))
    if dry_run:
        return
    for f in file_or_tree:
        if os.path.isdir(f):
            shutil.rmtree(f)
        else:
            os.unlink(f)


# expose find_executable as which
def which(executable, path=None):
    """Tries to find 'executable' in the directories listed in 'path'.

    A string listing directories separated by 'os.pathsep'; defaults to
    os.environ['PATH'].  Returns the complete filename or None if not found.
    """
    if path is None:
        path = os.environ['PATH']
    paths = path.split(os.pathsep)
    base, ext = os.path.splitext(executable)

    exts = ['']
    if (sys.platform == 'win32' or os.name == 'os2') and (ext != '.exe'):
        exts = [".cmd", ".bat", ".exe", ".com"] + exts

    for ext in exts:
        e = executable + ext
        if os.path.isfile(e):
            return e
        else:
            for p in paths:
                f = os.path.join(p, e)
                if os.path.isfile(f):
                    # the file exists, we have a shot at spawn working
                    return f

    return None


# expose glob
@functools.wraps(glob2.glob)
def glob(pathname, *args, **kwargs):
    if isinstance(pathname, Path):
        pathname = str(pathname)
    return glob2.glob(pathname, *args, **kwargs)


def glob_first(expr, default=None):
    """Return the first result of the globbing expression or 'default'"""
    res = glob(expr)
    return res[0] if res else default


def main_default(**default_options):
    u"""Change the default values of the main method of a Command"""

    def decorator(f):
        oldmain = f.main

        def main(*args, **options):
            LOGGER.develop("Calling with args: {}".format(args))
            newopts = dict(default_options)
            newopts.update(options)
            oldmain(*args, **newopts)
        f.main = main
        return f

    return decorator


def get_all_files_recursive(dir, exclude):
    for dir, subdirs, files in os.walk(dir):
        for excluded in set(exclude) & set(subdirs):
            del subdirs[subdirs.index(excluded)]
        for file in files:
            yield os.path.join(dir, file)


def check_uptodate(src, dst, src_exclude=[], dst_exclude=[]):
    assert os.path.exists(src), u"{} must exist".format(src)
    if not os.path.exists(dst):
        return False
    if os.path.isfile(src):
        src_mtime = os.stat(src).st_mtime
        src_f = src
    elif os.path.isdir(src):
        src_mtime, src_f = max(
            map(
                lambda f: (os.stat(f).st_mtime, f),
                get_all_files_recursive(src, src_exclude)
            ),
            key=lambda e: e[0]
        )
    else:
        raise NotImplemented
    if os.path.isfile(dst):
        dst_mtime = os.stat(dst).st_mtime
        dst_f = dst
    elif os.path.isdir(dst):
        dst_mtime, dst_f = min(
            map(
                lambda f: (os.stat(f).st_mtime, f),
                get_all_files_recursive(dst, dst_exclude)
            ),
            key=lambda e: e[0]
        )
    else:
        raise NotImplemented
    LOGGER.debug(
        u"Comparing mtimes of {} ({}) with {} ({})".format(
            src_f,
            src_mtime,
            dst_f,
            dst_mtime,
        )
    )
    return src_mtime < dst_mtime


def call(args, **kwargs):
    u"""Run a program and deal with debugging and signals"""
    internal = kwargs.get('internal')
    if 'internal' in kwargs.keys():
        del kwargs['internal']
    # deal with backward compatibility
    if 'force' in kwargs.keys():
        LOGGER.deprecated("'force' argument is deprecated since version 0.9.0, use 'internal' instead.")
        internal = kwargs['force']
        del kwargs['force']
    launcher = kwargs.get('launcher_command')
    if 'launcher_command' in kwargs.keys():
        del kwargs['launcher_command']
    args = [str(arg) for arg in args]
    if launcher:
        args = launcher + args
    args = [str(arg) for arg in args]
    message = ' '.join(quote(arg) for arg in args)
    action_message = "run: {}".format(message)
    cwd = kwargs.get('cwd')
    if cwd:
        action_message = "in %s, %s" % (cwd, action_message)
    if internal:
        LOGGER.develop(action_message)
    else:
        LOGGER.action(action_message)
    if not dry_run or internal:
        _call(args, kwargs)


call_capture_stdout = False
call_merge_stdout_and_stderr = False


def _call(args, kwargs):
    signal_hook = kwargs.pop("signal_hook", None)

    def signal_handler(num, stack):
        if signal_hook:
            signal_hook(p, num, stack)
        else:
            os.kill(p.pid, num)
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    if call_merge_stdout_and_stderr:
        kwargs["stderr"] = subprocess.STDOUT
    if kwargs.pop("to_stderr", False):
        kwargs["stdout"] = subprocess.PIPE
    if call_capture_stdout:
        kwargs["stdout"] = subprocess.PIPE
    try:
        if call_capture_stdout:
            p = subprocess.Popen(args, **kwargs)
            stdout = []
            while True:
                line = p.stdout.readline().decode("utf-8")
                print(line[:-1])
                stdout.append(line)
                if line == u'' and p.poll() is not None:
                    break
            p.wait()
            if p.returncode != 0:
                raise subprocess.CalledProcessError(
                    p.returncode, args,
                    output=stdout)
        else:
            p = subprocess.Popen(args, **kwargs)
            p.wait()
            if p.returncode:
                raise subprocess.CalledProcessError(p.returncode, args)
    except OSError as e:
        raise click.ClickException(u"Failed to call %s: %s" % (args[0], e.strerror))
    finally:
        signal.signal(signal.SIGINT, signal.SIG_DFL)
        signal.signal(signal.SIGTERM, signal.SIG_DFL)


def popen(args, internal=False, **kwargs):
    """Run a program and deal with debugging and signals"""
    args = [str(arg) for arg in args]
    message = ' '.join(quote(arg) for arg in args)
    action_message = "run: {}".format(message)
    if internal:
        LOGGER.develop(action_message)
    else:
        LOGGER.action(action_message)
    if not dry_run or internal:
        return subprocess.Popen(args, **kwargs)


@contextmanager
def tempdir(dir=None):
    u"""Create a temporary to use be in a with statement"""
    d = tempfile.mkdtemp(dir=dir)
    try:
        yield d
    except Exception:
        rm(d)
        raise
    rm(d)


@contextmanager
def temporary_file(dir=None, suffix=None):
    u"""Create a temporary file to use in a with statement"""
    d = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
    try:
        yield d
    except Exception:
        os.unlink(d.name)
        raise
    os.unlink(d.name)


@contextmanager
def cd(dir, internal=False, makedirs=False):
    u"""Change to a directory temporarily. To be used in a with statement"""
    if makedirs:
        _makedirs(dir)
    if internal:
        logger = LOGGER.develop
    else:
        logger = LOGGER.action
    prevdir = os.getcwd()
    logger(u"go to directory {}".format(dir))
    if not dry_run:
        os.chdir(dir)
        LOGGER.debug(u"In directory {}".format(dir))
    yield os.path.realpath(dir)
    logger(u"go back into directory {}".format(prevdir))
    if not dry_run:
        LOGGER.debug("Back to directory {}".format(prevdir))
    os.chdir(prevdir)


def ccd(dir):
    """Create and change to a directory temporarily. To be used in a with statement"""
    LOGGER.deprecated("`ccd(dir)` is deprecated, use `cd(dir, makedirs=True)` instead")
    return cd(dir, makedirs=True)


@contextmanager
def updated_env(**kwargs):
    u"""Temporarily update the environment. To be used in a with statement"""
    oldenv = dict(os.environ)
    for k, v in six.iteritems(kwargs):
        if v is None and k in os.environ:
            LOGGER.debug('environment %s removed' % k)
            del os.environ[k]
        else:
            LOGGER.debug('environment %s="%s"' % (k, v))
            os.environ[k] = v
    yield
    os.environ.clear()
    os.environ.update(oldenv)


@contextmanager
def env(**kwargs):
    u"""Temporarily override the environment. To be used in a with statement"""
    oldenv = dict(os.environ)
    os.environ.clear()
    os.environ.update(kwargs)
    yield
    os.environ.clear()
    os.environ.update(oldenv)


def format_opt(opt):
    return u'--%s' % opt.replace(u'_', u'-')


def format_options(options, glue=False):
    """Transform the dictionary in a list of options usable in call"""
    cmd = []
    for opt, value in six.iteritems(options):
        if value is True:
            cmd.append(format_opt(opt))
        elif isinstance(value, list) or isinstance(value, tuple):
            # this is a multi value option
            for v in value:
                if glue:
                    cmd.append("{}={}".format(format_opt(opt), v))
                else:
                    cmd.extend([format_opt(opt), v])
        elif value:
            if glue:
                cmd.append("{}={}".format(format_opt(opt), value))
            else:
                cmd.extend([format_opt(opt), value])
    return cmd


def cpu_count():
    try:
        import psutil
        return psutil.cpu_count(logical=False)
    except ImportError:
        import multiprocessing
        return multiprocessing.cpu_count()


component_re = re.compile(r'(\d+ | [a-z]+ | \.| -)', re.VERBOSE)
replace = {'pre': 'c', 'preview': 'c', '-': 'final-', 'rc': 'c', 'dev': '@'}.get


def _parse_version_parts(s):
    for part in component_re.split(s):
        part = replace(part, part)
        if not part or part == '.':
            continue
        if part[:1] in '0123456789':
            yield part.zfill(8)    # pad for numeric comparison
        else:
            yield '*' + part

    yield '*final'  # ensure that alpha/beta/candidate are before final


def parse_version(s):
    """Convert a version string to a chronologically-sortable key

    This is a rough cross between distutils' StrictVersion and LooseVersion;
    if you give it versions that would work with StrictVersion, then it behaves
    the same; otherwise it acts like a slightly-smarter LooseVersion. It is
    *possible* to create pathological version coding schemes that will fool
    this parser, but they should be very rare in practice.

    The returned value will be a tuple of strings.  Numeric portions of the
    version are padded to 8 digits so they will compare numerically, but
    without relying on how numbers compare relative to strings.  Dots are
    dropped, but dashes are retained.  Trailing zeros between alpha segments
    or dashes are suppressed, so that e.g. "2.4.0" is considered the same as
    "2.4". Alphanumeric parts are lower-cased.

    The algorithm assumes that strings like "-" and any alpha string that
    alphabetically follows "final"  represents a "patch level".  So, "2.4-1"
    is assumed to be a branch or patch of "2.4", and therefore "2.4.1" is
    considered newer than "2.4-1", which in turn is newer than "2.4".

    Strings like "a", "b", "c", "alpha", "beta", "candidate" and so on (that
    come before "final" alphabetically) are assumed to be pre-release versions,
    so that the version "2.4" is considered newer than "2.4a1".

    Finally, to handle miscellaneous cases, the strings "pre", "preview", and
    "rc" are treated as if they were "c", i.e. as though they were release
    candidates, and therefore are not as new as a version string that does not
    contain them, and "dev" is replaced with an '@' so that it sorts lower than
    than any other pre-release tag.
    """
    parts = []
    for part in _parse_version_parts(s.lower()):
        if part.startswith('*'):
            if part == "*c":
                part = "*g"  # caf is greater than final
            if part < '*final':   # remove '-' before a prerelease tag
                while parts and parts[-1] == '*final-':
                    parts.pop()
            # remove trailing zeros from each series of numeric parts
            while parts and parts[-1] == '00000000':
                parts.pop()
        parts.append(part)
    return tuple(parts)


def safe_check_output(*args, **kwargs):
    """Return the process output or an empty string when the process fail and never raise"""
    if 'stdout' in kwargs:
        raise ValueError('stdout argument not allowed, it will be overridden.')
    if 'stderr' not in kwargs:
        kwargs['stderr'] = subprocess.PIPE
    internal = kwargs.get("internal")
    if 'internal' in kwargs:
        del kwargs['internal']
    # deal with backward compatibility
    if 'force' in kwargs.keys():
        LOGGER.deprecated("'force' argument is deprecated since version 0.9.0, use 'internal' instead.")
        internal = kwargs['force']
        del kwargs['force']
    action_message = "run: {}".format(" ".join(args[0]))
    if internal:
        LOGGER.develop(action_message)
    else:
        LOGGER.action(action_message)
    if dry_run and not internal:
        return ""
    try:
        process = subprocess.Popen(stdout=subprocess.PIPE, *args, **kwargs)
        output, _ = process.communicate()
        if process.poll():
            return ""
        else:
            return output.decode('utf-8')
    except:
        return ""


def communicate(command, *args, **kwargs):
    """Return the process output, error and returncode of the command"""
    LOGGER.action("run: {}".format(" ".join(command)))
    if dry_run and not kwargs.get("internal"):
        return "", "", 0
    else:
        LOGGER.debug("Calling: {}".format(' '.join(quote(arg) for arg in command)))
    if "internal" in kwargs:
        del kwargs["internal"]
    try:
        process = subprocess.Popen(command,
                                   stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE, *args, **kwargs)
        output, error = process.communicate()
        output = output.decode("utf-8")
        error = error.decode("utf-8")
        return output, error, process.returncode
    except:
        return "", "", 1


def check_output(cmd, *args, **kwargs):
    """Return the process output"""
    message = ' '.join(quote(str(arg)) for arg in cmd)
    try:
        nostderr = kwargs.pop('nostderr')
    except KeyError:
        nostderr = False
    try:
        internal = kwargs.pop('internal')
    except KeyError:
        internal = False
    # deal with backward compatibility
    if 'force' in kwargs.keys():
        LOGGER.deprecated("'force' argument is deprecated since version 0.9.0, use 'internal' instead.")
        internal = kwargs['force']
        del kwargs['force']
    action_message = "run: {}".format(message)
    if internal:
        LOGGER.develop(action_message)
    else:
        LOGGER.action(action_message)
    if not (dry_run and not internal):
        if call_capture_stdout:
            kwargs["stderr"] = subprocess.PIPE
            kwargs["stdout"] = subprocess.PIPE
            p = subprocess.Popen(cmd, *args, **kwargs)
            while True:
                line = p.stderr.readline().decode("utf-8")
                if not nostderr:
                    sys.stderr.write(line)
                if line == u'' and p.poll() is not None:
                    break
            p.wait()
            stdout = p.stdout.read().decode("utf-8")
            if p.returncode != 0:
                raise subprocess.CalledProcessError(
                    p.returncode, args,
                    output=stdout)
            return stdout
        else:
            if nostderr:
                kwargs['stderr'] = None
            return subprocess.check_output(cmd, *args, **kwargs).decode('utf-8')


def is_pip_install(src_dir):
    try:
        with cd(src_dir, internal=True):
            pip_install = subprocess.Popen(['git', 'rev-parse'], stdout=subprocess.PIPE, stderr=subprocess.PIPE).wait()
            # make sure that src_dir is actually in the project repository (and not in homebrew for example)
            pip_install = pip_install or not safe_check_output(['git', 'ls-files'], internal=True)
    except OSError:
        pip_install = True
    return pip_install


def get_netrc_keyring():
    netrcfile = os.path.expanduser("~/.netrc")
    if os.path.exists(netrcfile) and platform.system() != 'Windows':
        chmod(netrcfile, 0o600)
    from click_project.keyring_netrc import NetrcKeyring
    return NetrcKeyring()


def get_keyring():
    import keyring
    if isinstance(keyring.core.get_keyring(), keyring.backends.fail.Keyring):
        LOGGER.debug("could not find a correct keyring backend, fallback on the netrc one")
        from click_project.keyring_netrc import NetrcKeyring
        keyring.core.set_keyring(NetrcKeyring())
    return keyring.core.get_keyring()


def extract(url, dest='.'):
    """Download and extract all the files in the archive at url in dest"""
    import tarfile
    import zipfile
    from io import BytesIO
    makedirs(dest)
    r = urlopen(url)
    size = int(r.headers["Content-Length"] or r.headers['content-length'])
    archname = os.path.basename(url)
    archive = BytesIO()
    with progressbar(length=size, label="Downloading %s" % archname) as bar:
        chunk = r.read(1024)
        while chunk:
            archive.write(chunk)
            bar.update(1024)
            chunk = r.read(1024)
    archive.seek(0)
    if archname.endswith('.zip'):
        zipfile.ZipFile(archive).extractall(path=dest)
        return dest + '/' + archname[:-4]
    else:
        tarfile.open(fileobj=archive).extractall(dest)
    for ext in ['.tar.gz', '.tgz', '.tar']:
        if archname.endswith(ext):
            return dest + '/' + archname[:-len(ext)]
    return dest + '/' + archname


def download(url, outdir=None, outfilename=None, mkdir=False, sha256=None):
    outdir = outdir or tempfile.mkdtemp()
    outfilename = outfilename or os.path.basename(url)
    if not os.path.exists(outdir) and mkdir:
        makedirs(outdir)
    outpath = os.path.join(outdir, outfilename)
    LOGGER.action("download %s" % url)
    if dry_run:
        return outpath

    r = urlopen(url)
    size = int(r.headers["Content-Length"] or r.headers['content-length'])
    outfile = open(outpath, "wb")
    try:
        with progressbar(length=size, label="Downloading %s" % os.path.basename(url)) as bar:
            chunk = r.read(1024)
            while chunk:
                outfile.write(chunk)
                bar.update(1024)
                chunk = r.read(1024)
    except:
        outfile.close()
        rm(outpath)
        raise
    outfile.close()
    if sha256 is not None:
        LOGGER.debug("Checking for corruption")
        if hashlib.sha256(open(outpath, "rb").read()).hexdigest() != sha256:
            rm(outpath)
            raise click.ClickException("The file at {} was corrupted. It was removed".format(outpath))
    return outpath


def part_of_day():
    import datetime
    hour = datetime.datetime.now().hour
    if hour < 11:
        return "morning"
    elif 11 <= hour < 13:
        return "lunch"
    elif 13 <= hour < 17:
        return "afternoon"
    elif 17 <= hour < 18:
        return "tea"
    else:
        return "night"


def pid_exists(pidpath):
    """Check whether a program is running or not, based on its pid file"""
    LOGGER.develop("Checking %s" % pidpath)
    running = False
    if os.path.exists(pidpath):
        with open(pidpath) as f:
            pid = int(f.readline().strip())
            try:
                import psutil
                running = psutil.pid_exists(pid)
                if running:
                    proc = psutil.Process(pid)
                    running = proc.status() != psutil.STATUS_ZOMBIE
            except ImportError:
                LOGGER.warn("Can't check the program is actually running. Please install psutils.")
                # pid file still exists, so lets say rest is running
                running = True
    return running


def pid_kill(pidpath, signal=signal.SIGTERM):
    """Send a signal to a process, based on its pid file"""
    LOGGER.develop("Checking %s" % pidpath)
    if os.path.exists(pidpath):
        pid = int(read(pidpath))
        LOGGER.action("kill -{} {}".format(signal, pid))
        os.kill(pid, signal)


def username():
    """Return the current user name"""
    try:
        import pwd
        return pwd.getpwuid(os.getuid()).pw_name
    except:
        import getpass
        return getpass.getuser()


_find_unsafe = re.compile(r'[^\w@%+=:,./-]').search


def single_quote(s):
    """Return a shell-escaped version of the string *s*."""
    if not s:
        return "''"
    if _find_unsafe(s) is None:
        return s

    # use single quotes, and put single quotes into double quotes
    # the string $'b is then quoted as '$'"'"'b'
    return "'" + s.replace("'", "'\"'\"'") + "'"


def double_quote(s):
    '''Return a shell-escaped version of the string *s*.'''
    if not s:
        return '""'
    if _find_unsafe(s) is None:
        return s

    # use double quotes, and put double quotes into single quotes
    # the string $"b is then quoted as "$"'"'"b"
    return '"' + s.replace('"', '"\'"\'"') + '"'


def quote(s):
    """Quote a string, with either single or double quotes depending on the content"""
    sq = single_quote(s)
    dq = double_quote(s)
    return sq if len(sq) <= len(dq) else dq


def echo_key_value(k, v, alt_style={'dim': True}):
    """Print a key and its associated value with a common style"""
    click.echo("%s %s" % (k, click.style(v, **alt_style)))


def echo_json(v):
    """Print a value as formatted and colored json"""
    click.echo(colorize_json(v), nl=False)


def colorize_json(v):
    """Format and colorize in json"""
    from pygments import highlight, lexers, formatters
    return highlight(json_dumps(v), lexers.JsonLexer(), formatters.TerminalFormatter())


def ordered_unique(ls):
    """Return the list with unique elements while keeping the elements ordered by first appearance"""
    seen = set()
    return [l for l in ls if not (l in seen or seen.add(l))]


def git_sync(url, directory, commit_ish='master', extra_branches=(), force=False, push_url=None, quiet=False,
             last_tag=False, reset=False, use_shallow=False):
    """Retrieve and/or update a git repository"""
    version = re.search('git version (.+)', safe_check_output(['git', '--version'], internal=True)).group(1)
    use_shallow = use_shallow and parse_version(version) >= parse_version('2.1.4') and not last_tag
    directory = os.path.abspath(directory or re.split('[:/]', url)[-1])
    git_dir = os.path.join(directory, ".git")
    ref_file = os.path.abspath(directory + '/.git/click-project-git-sync-reference')
    updated = False
    quiet = ['--quiet'] if quiet else []
    parent = os.path.dirname(directory)
    if not os.path.exists(parent):
        makedirs(parent)
    if force and os.path.exists(directory):
        rm(directory)
    if os.path.exists(directory):
        assert os.path.exists(git_dir), (
            "Want to git sync {} in {} but {}"
            " already exists and is not a git root".format(
                url, directory, directory
            )
        )
        with cd(directory):
            if reset:
                call(['git', 'reset', '--hard'] + quiet)
            call(['git', 'remote', 'set-url', 'origin', url])
            # always fetch, just in case something went missing
            call(['git', 'fetch', '--tags'] + quiet)
            if os.path.exists(ref_file) and open(ref_file).read() != commit_ish:
                # reference has changed. Unfortunately we can't continue with the single branch shallow repository
                call(['git', 'remote', 'set-branches', 'origin', '*'])
                if os.path.exists(directory + '/.git/shallow'):
                    call(['git', 'fetch', '--unshallow', '--tags'] + quiet)
            prevrev = check_output(['git', 'rev-parse', 'HEAD'], internal=True)
            # just to make sure the user hasn't done anything by himself
            if commit_ish:
                call(['git', 'checkout'] + quiet + [commit_ish])
            if check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD'], internal=True).strip() != 'HEAD':
                # not in a detached head, ok, we can use pull
                call(['git', 'pull'] + quiet)
            updated = prevrev != check_output(['git', 'rev-parse', 'HEAD'], internal=True)
    else:
        commit_ish = commit_ish or 'master'
        ref_exists = check_output(['git', 'ls-remote', url, commit_ish], internal=True).strip() != ""
        if ref_exists:
            call(['git', 'clone'] + quiet + (['--depth', '1'] if use_shallow else []) + ['-b', commit_ish, url, directory])
        else:
            call(['git', 'clone'] + quiet + ['-n', url, directory])
            with cd(directory):
                call(['git', 'checkout', commit_ish])
        if extra_branches:
            with cd(directory):
                call(['git', 'remote', 'set-branches', '--add', 'origin'] + list(extra_branches))
                call(['git', 'fetch'] + quiet)
    # save the reference used, so we can compare it with the asked reference in case of update
    if commit_ish:
        createfile(ref_file, commit_ish)
    if push_url:
        with cd(directory):
            call(['git', 'remote', 'set-url', '--push', 'origin', push_url])
    if last_tag:
        with cd(directory):
            tag = check_output(['git', 'describe', '--tags', '--abbrev=0']).strip()
            call(['git', 'checkout'] + quiet + [tag])
    return updated


def get_option_choices(option_name):
    """Returns the choices available for an option in the current context

    This is useful to avoid duplicating the choice list."""
    context = click_get_current_context_safe()
    if not context or not hasattr(context, 'command'):
        return ()
    options = [o for o in context.command.params if o.name == option_name]
    if not options:
        return ()
    fields = options[0]
    if not isinstance(fields.type, click.Choice):
        return ()
    return fields.type.choices


def clear_ansi_color_codes(v):
    """make sure we don't have any terminal chars"""
    if isinstance(v, six.string_types):
        v = colorama.AnsiToWin32.ANSI_CSI_RE.sub('', v)
        v = colorama.AnsiToWin32.ANSI_OSC_RE.sub('', v)
    return v


def get_tabulate_formats():
    import tabulate
    return click.Choice(list(tabulate._table_formats.keys()) + ['csv', 'json', 'key_value', 'json-map', 'json-maps'])


def get_key_values_formats():
    return get_tabulate_formats()


def progressbar(iterable=None, length=None, label=None, show_eta=True,
                show_percent=None, show_pos=False,
                item_show_func=None, fill_char='#', empty_char='-',
                bar_template='%(label)s  [%(bar)s]  %(info)s',
                info_sep='  ', width=36, file=sys.stderr, color=None, clear=True,
                disabled=False):
    """This function creates an iterable context manager that can be used
    to iterate over something while showing a progress bar.  It will
    either iterate over the `iterable` or `length` items (that are counted
    up).  While iteration happens, this function will print a rendered
    progress bar to the given `file` (defaults to stdout) and will attempt
    to calculate remaining time and more.  By default, this progress bar
    will not be rendered if the file is not a terminal.

    The context manager creates the progress bar.  When the context
    manager is entered the progress bar is already displayed.  With every
    iteration over the progress bar, the iterable passed to the bar is
    advanced and the bar is updated.  When the context manager exits,
    a newline is printed and the progress bar is finalized on screen.

    No printing must happen or the progress bar will be unintentionally
    destroyed.

    Example usage::

        with progressbar(items) as bar:
            for item in bar:
                do_something_with(item)

    Alternatively, if no iterable is specified, one can manually update the
    progress bar through the `update()` method instead of directly
    iterating over the progress bar.  The update method accepts the number
    of steps to increment the bar with::

        with progressbar(length=chunks.total_bytes) as bar:
            for chunk in chunks:
                process_chunk(chunk)
                bar.update(chunks.bytes)

    .. versionadded:: 2.0

    .. versionadded:: 4.0
       Added the `color` parameter.  Added a `update` method to the
       progressbar object.

    :param iterable: an iterable to iterate over.  If not provided the length
                     is required.
    :param length: the number of items to iterate over.  By default the
                   progressbar will attempt to ask the iterator about its
                   length, which might or might not work.  If an iterable is
                   also provided this parameter can be used to override the
                   length.  If an iterable is not provided the progress bar
                   will iterate over a range of that length.
    :param label: the label to show next to the progress bar.
    :param show_eta: enables or disables the estimated time display.  This is
                     automatically disabled if the length cannot be
                     determined.
    :param show_percent: enables or disables the percentage display.  The
                         default is `True` if the iterable has a length or
                         `False` if not.
    :param show_pos: enables or disables the absolute position display.  The
                     default is `False`.
    :param item_show_func: a function called with the current item which
                           can return a string to show the current item
                           next to the progress bar.  Note that the current
                           item can be `None`!
    :param fill_char: the character to use to show the filled part of the
                      progress bar.
    :param empty_char: the character to use to show the non-filled part of
                       the progress bar.
    :param bar_template: the format string to use as template for the bar.
                         The parameters in it are ``label`` for the label,
                         ``bar`` for the progress bar and ``info`` for the
                         info section.
    :param info_sep: the separator between multiple info items (eta etc.)
    :param width: the width of the progress bar in characters, 0 means full
                  terminal width
    :param file: the file to write to.  If this is not a terminal then
                 only the label is printed.
    :param color: controls if the terminal supports ANSI colors or not.  The
                  default is autodetection.  This is only needed if ANSI
                  codes are included anywhere in the progress bar output
                  which is not the case by default.
    """
    if disabled:
        return null_context
    color = click.termui.resolve_color_default(color)
    return ProgressBar(iterable=iterable, length=length, show_eta=show_eta,
                       show_percent=show_percent, show_pos=show_pos,
                       item_show_func=item_show_func, fill_char=fill_char,
                       empty_char=empty_char, bar_template=bar_template,
                       info_sep=info_sep, file=file, label=label,
                       width=width, color=color, clear=clear)


class ProgressBar(ProgressBar_):
    def __init__(self, clear=True, *args, **kwargs):
        self.clear = clear
        kwargs.setdefault('file', sys.stderr)
        ProgressBar_.__init__(self, *args, **kwargs)

    def render_finish(self):
        if self.is_hidden:
            return
        if self.clear and platform.system() != 'Windows':
            AFTER_BAR = '\r\033[2K\033[?25h'
            self.file.write(AFTER_BAR)
            self.file.flush()
        else:
            ProgressBar_.render_finish(self)

    def __iter__(self):
        self.render_progress()
        return self

    def next(self):
        if self.is_hidden:
            return next(self.iter)
        try:
            rv = next(self.iter)
            self.current_item = rv
        except StopIteration:
            self.finish()
            self.render_progress()
            if not self.entered:
                self.render_finish()
            raise StopIteration()
        else:
            self.update(1)
            return rv

    if not six.PY2:
        __next__ = next
        del next


def get_close_matches(words, possibilities, n=3, cutoff=0.6):
    """Use SequenceMatcher to return list of the best "good enough" matches.

    word is a sequence for which close matches are desired (typically a
    string).

    possibilities is a list of sequences against which to match word
    (typically a list of strings).

    Optional arg n (default 3) is the maximum number of close matches to
    return.  n must be > 0.

    Optional arg cutoff (default 0.6) is a float in [0, 1].  Possibilities
    that don't score at least that similar to word are ignored.

    The best (no more than n) matches among the possibilities are returned
    in a list, sorted by similarity score, most similar first.

    >>> get_close_matches("appel", ["ape", "apple", "peach", "puppy"])
    ['apple', 'ape']
    >>> import keyword as _keyword
    >>> get_close_matches("wheel", _keyword.kwlist)
    ['while']
    >>> get_close_matches("apple", _keyword.kwlist)
    []
    >>> get_close_matches("accept", _keyword.kwlist)
    ['except']
    """

    if not n > 0:
        raise ValueError("n must be > 0: %r" % (n,))
    if not 0.0 <= cutoff <= 1.0:
        raise ValueError("cutoff must be in [0.0, 1.0]: %r" % (cutoff,))
    if not isinstance(words, list):
        words = [words]
    result = []
    s = difflib.SequenceMatcher()
    for word in words:
        s.set_seq2(word)
        for x in possibilities:
            s.set_seq1(x)
            if s.real_quick_ratio() >= cutoff and \
               s.quick_ratio() >= cutoff and \
               s.ratio() >= cutoff:
                result.append((s.ratio(), x))

    # Move the best scorers to head of list
    result = heapq.nlargest(n, result)
    # Strip scores for the best n matches
    return [x for score, x in result]


def json_dump_file(path, content, internal=False):
    """Dump a python object to a file using a nicely formated json format"""
    createfile(path, json_dumps(content), internal=internal)


def json_dumps(content):
    """Dump a python object using a nicely formated json format"""
    return json.dumps(content, indent=4, sort_keys=True).replace(' \n', '\n') + '\n'


def grep(file_list, args=None, pager=True, ):
    args = args or []
    args = [quote(arg) for arg in args]
    color_opt = ['--color=always'] if sys.stdout.isatty() else []
    xargs = subprocess.Popen('xargs -0 grep ' + ' '.join(color_opt + list(args)) + (' | less' if pager else ''),
                             stdin=subprocess.PIPE, shell=True)
    xargs.communicate(input='\0'.join(file_list).encode("utf-8"))
    xargs.wait()


class NullContext:
    def __enter__(self):
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass

    def update(self, foo):
        """Fake update method to mimic the progress bar API"""
        pass


null_context = NullContext()


class Spinner(object):
    spinner_cycle = itertools.cycle(['-', '\\', '|', '/'])

    def __init__(self, message=''):
        self.stop_running = None
        self.spin_thread = None
        self.message = message

    def start(self):
        if sys.stderr.isatty():
            if self.message:
                sys.stderr.write(self.message + ' ')
            self.stop_running = threading.Event()
            self.spin_thread = threading.Thread(target=self.init_spin)
            self.spin_thread.start()
        elif self.message:
            LOGGER.status(self.message)

    def stop(self):
        if self.spin_thread:
            self.stop_running.set()
            self.spin_thread.join()
            if self.message:
                sys.stderr.write('\b' * (len(self.message) + 1))
                sys.stderr.write(' ' * (len(self.message) + 2))
                sys.stderr.write('\b' * (len(self.message) + 2))
                sys.stderr.flush()

    def init_spin(self):
        while not self.stop_running.is_set():
            sys.stderr.write(next(self.spinner_cycle))
            sys.stderr.flush()
            time.sleep(0.25)
            sys.stderr.write('\b')
            sys.stderr.flush()

    def __enter__(self):
        self.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop()
        return False

    def update(self, foo):
        """Fake update method to mimic the progress bar API"""
        pass


def spinner(disabled=False, message=''):
    if disabled:
        return null_context
    return Spinner(message)


def read(f):
    """Read a file an return its content in utf-8"""
    return open(f, 'rb').read().decode('utf-8')


def natural_delta(value):
    """Given a timedelta or a number of seconds, return a natural
    representation of the amount of time elapsed.  This is similar to
    ``natural_time``, but does not add tense to the result."""
    date, delta = date_and_delta(value)
    if date is None:
        return value

    seconds = abs(delta.seconds)
    hours = seconds // 3600
    seconds = seconds % 3600
    minutes = seconds // 60
    seconds = seconds % 60
    days = abs(delta.days)
    years = days // 365
    days = days % 365

    if years:
        return "%s year%s %s day%s" % (years, 's' if years > 1 else '', days, 's' if days > 1 else '')
    elif days:
        return "%s day%s %s hour%s" % (days, 's' if days > 1 else '', hours, 's' if hours > 1 else '')
    elif hours:
        return "%s hour%s %s minute%s" % (hours, 's' if hours > 1 else '', minutes, 's' if minutes > 1 else '')
    elif minutes:
        return "%s minute%s %s second%s" % (minutes, 's' if minutes > 1 else '', seconds, 's' if seconds > 1 else '')
    elif delta.microseconds:
        seconds = seconds + abs(delta.microseconds)/10.**6
        return "%1.3f second%s" % (seconds, 's' if seconds > 1 else '')
    return "%s second%s" % (seconds, 's' if seconds > 1 else '')


def natural_time(value, future=False, months=True):
    """Given a datetime or a number of seconds, return a natural representation
    of that time in a resolution that makes sense.  This is more or less
    compatible with Django's ``naturaltime`` filter.  ``future`` is ignored for
    datetimes, where the tense is always figured out based on the current time.
    If an integer is passed, the return value will be past tense by default,
    unless ``future`` is set to True."""
    from humanize.time import naturaldelta, _
    from datetime import datetime, timedelta
    import dateutil.tz
    now = datetime.now(dateutil.tz.tzlocal())
    date, delta = date_and_delta(value)
    if date is None:
        return value
    # determine tense by value only if datetime/timedelta were passed
    if isinstance(value, (datetime, timedelta)):
        future = date > now

    ago = _('%s from now') if future else _('%s ago')
    delta = naturaldelta(delta, months)

    if delta == _("a moment"):
        return _("now")

    return ago % delta


def date_and_delta(value):
    """Turn a value into a date and a timedelta which represents how long ago
    it was.  If that's not possible, return (None, value)."""
    from humanize.time import abs_timedelta
    from datetime import datetime, timedelta
    import dateutil.tz
    now = datetime.now(dateutil.tz.tzlocal())
    if isinstance(value, datetime):
        date = value
        delta = now - value
    elif isinstance(value, timedelta):
        date = now - value
        delta = value
    else:
        try:
            value = int(value)
            delta = timedelta(seconds=value)
            date = now - delta
        except (ValueError, TypeError):
            return (None, value)
    return date, abs_timedelta(delta)


def read_cmakecache(file):
    content = open(file).read()
    return dict(re.findall('^([a-zA-Z_]+)(?::[^=]+=)(.+)$', content, flags=re.MULTILINE))


class ParameterType(click.ParamType):
    def __init__(self):
        click.ParamType.__init__(self)
        if not self.name:
            class_name = self.__class__.__name__
            self.name = re.sub('(Param(eter|)|)Type$', '', class_name)
            # switch to snake case
            self.name = re.sub('([a-z])([A-Z])', '\\1_\\2', self.name).lower()
            # remove the prefix if it match the module
            self.name = re.sub('^%s(_|)' % self.__module__.split('.')[-1].lower(), '', self.name)


@contextmanager
def json_file(location):
    if (
            not os.path.exists(location) or
            open(location, "r").read().strip() == ""
    ):
        open(location, "w").write("{}")
    values = json.load(open(location))
    oldvalues = deepcopy(values)
    yield values
    if values != oldvalues:
        json.dump(values, open(location, "w"))


def flat_map(l):
    """Transform a list of list in a list with all the elements of the nested lists

    >>> flat_map([[1, 2, 3], [4, 5]])
    [1, 2, 3, 4, 5]
    """
    l = list(l)
    return functools.reduce(list.__add__, l) if l else []


def subkwargs(kwargs, params):
    return {
        key: value
        for key, value in kwargs.items()
        if key in params
    }


def deprecated_module(src, dst):
    stack = traceback.extract_stack()

    def get_frame_info(frame):
        if six.PY2 or sys.version_info.minor <= 4:
            filename = frame[0]
            lineno = frame[1]
            line = frame[3]
        else:
            filename = frame.filename
            lineno = frame.lineno
            line = frame.line
        return filename, lineno, line

    # find a relevant frame
    frame = [
        frame
        for frame in stack[:-2]
        if "frozen" not in get_frame_info(frame)[0]
        and "pluginbase" not in get_frame_info(frame)[0]
    ][-1]
    filename, lineno, line = get_frame_info(frame)
    return (
        "{}:{} '{}' =>"
        " Importing {} is deprecated, import {} instead"
    ).format(
        filename, lineno, line,
        src, dst
    )


class TablePrinter(object):
    direct_output_formats = ['key_value', 'csv']

    def __init__(self, fields=(), tablefmt=None, separator=' ', headers=(), **options):
        fields = fields or self.fields_from_context()
        headers = headers or self.headers_from_context()
        self._tablefmt = tablefmt or self.format_from_context() or 'simple'
        self._options = options
        self._headers = fields or headers
        self._separator = separator
        self._data = []
        self._field_indices = [headers.index(f) for f in fields]

    @staticmethod
    def headers_from_context():
        return get_option_choices('fields')

    @staticmethod
    def fields_from_context():
        context = click_get_current_context_safe()
        if not context or not hasattr(context, 'params'):
            return ()
        return context.params.get('fields', ())

    @staticmethod
    def format_from_context():
        context = click_get_current_context_safe()
        if not context or not hasattr(context, 'params'):
            return ()
        return context.params.get('format', ())

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self._tablefmt not in self.direct_output_formats:
            click.echo(tabulate(self._data, self._headers, tablefmt=self._tablefmt, **self._options))

    def echo(self, *args, stripped=False):
        if self._field_indices and not stripped:
            args = [args[i] for i in self._field_indices]
        cleaned_args = []
        for arg in args:
            if isinstance(arg, (tuple, list)):
                arg = self._separator.join(arg)
            cleaned_args.append(arg)
        if self._tablefmt in self.direct_output_formats:
            click.echo(tabulate([cleaned_args], self._headers, tablefmt=self._tablefmt, **self._options))
        else:
            self._data.append(cleaned_args)

    def echos(self, ls):
        for l in ls:
            self.echo(*l)

    def echo_records(self, records):
        for record in records:
            self.echo(*[record[value] for value in self.headers_from_context()])


def tabulate(tabular_data, headers=(), tablefmt="simple",
             floatfmt="g", numalign="decimal", stralign="left",
             missingval=""):
    """Tabulate the data"""
    from tabulate import tabulate as tabulate_
    if tablefmt == 'key_value':
        from click_project.config import config
        data = []
        for kv in tabular_data:
            if len(kv) > 1:
                data.append("%s %s" % (kv[0], click.style(u' '.join(to_string(v) for v in kv[1:]), **config.alt_style)))
            else:
                data.append(kv[0])
        return '\n'.join(data)
    elif tablefmt == 'csv':
        import csv
        f = csv.StringIO()
        csvwriter = csv.writer(f)
        csvwriter.writerows(tabular_data)
        f.seek(0)
        return f.read().rstrip('\n')
    elif tablefmt == 'json':
        import collections
        json_data = []
        if not headers and tabular_data:
            headers = ['key%s' % i for i in range(len(tabular_data[0]))]
        for ls in tabular_data:
            d = collections.OrderedDict()
            for i, v in enumerate(ls):
                if isinstance(v, six.string_types):
                    v = clear_ansi_color_codes(v)
                d[headers[i]] = v
            json_data.append(d)
        return colorize_json(json_data)
    elif tablefmt == 'json-map':
        return colorize_json(dict((d[0], clear_ansi_color_codes(str_join(' ', d[1:])) if len(d[1:]) > 1 else d[1]) for d in tabular_data))
    elif tablefmt == 'json-maps':
        import collections
        json_data = {}
        if not headers and tabular_data:
            headers = ['key%s' % i for i in range(len(tabular_data[0]))]
        for ls in tabular_data:
            d = collections.OrderedDict()
            for i, v in enumerate(ls[1:]):
                v = clear_ansi_color_codes(v)
                d[headers[i+1]] = v
            json_data[clear_ansi_color_codes(ls[0])] = d
        return colorize_json(json_data)
    elif tablefmt == 'plain':
        return tabulate_(tabular_data, (), 'plain', floatfmt, numalign, stralign, missingval)
    else:
        return tabulate_(tabular_data, headers, tablefmt, floatfmt, numalign, stralign, missingval)


def str_join(sep, ls):
    """Return a joined string of all the members of the list converted in strings"""
    return sep.join(str(l) for l in ls)


class AuthenticatorNotFound(click.UsageError):
    def __init__(self, machine, *args, **kwargs):
        super(AuthenticatorNotFound, self).__init__(
            "User credentials required for machine {}.".format(machine),
            *args, **kwargs
        )
        self.machine = machine


get_authenticator_hints = {}


def get_authenticator(machine, askpass=True, required=True):
    login, password = None, None
    netrc_keyring = False
    try:
        keyring = get_keyring()
        from click_project.keyring_netrc import NetrcKeyring
        if isinstance(keyring, NetrcKeyring):
            netrc_keyring = True
        try:
            login, password = json.loads(keyring.get_password("click_project", machine))
        except Exception:
            netrc = get_netrc_keyring()
            netrc_keyring = True
            login, password = json.loads(netrc.get_password("click_project", machine))
    except Exception:
        LOGGER.warning("I could not automatically find your login/password for {}.".format(machine))

    from click_project import completion
    if (login is None or password is None) and askpass and not completion.IN_COMPLETION:
        LOGGER.info("Please enter your username and password for {}".format(machine))
        if machine in get_authenticator_hints:
            LOGGER.info("Hint: {}".format(get_authenticator_hints[machine]))
        login = six.moves.input("%s username: " % machine)
        password = getpass.getpass("%s password: " % machine)
        try:
            LOGGER.info("Saving the credentials in your keyring: {}".format(keyring.name))
            keyring.set_password("click_project", machine, json.dumps((login, password)))
        except:
            LOGGER.warning("I could not save your credentials.")
            if netrc_keyring:
                LOGGER.warning(
                    "You can save them manually by running:"
                    " `passwords {} netrc-set {}`".format(machine, login))

    if login is None or password is None:
        if required:
            raise AuthenticatorNotFound(machine)
        else:
            return None

    return login, password


def assert_main_module():
    assert main_module != "__main__", (
        "You cannot call the main module, for there is none."
    )


def call_me(*cmd):
    assert_main_module()
    return call(
        [
            sys.executable,
            '-c',
            'from {} import main; main()'.format(main_module)
        ] + list(cmd))


def check_my_output(*cmd):
    assert_main_module()
    return safe_check_output(
        [
            sys.executable,
            '-c',
            'from {} import main; main()'.format(main_module)
        ] + list(cmd))


def to_bool(s):
    """Converts a string to a boolean"""
    from distutils.util import strtobool
    return bool(strtobool(s))


def to_string(s):
    if isinstance(s, six.string_types):
        return s
    return str(s)
