#!/usr/bin/env python
# -*- coding: utf-8 -*-

import io
import os
import re
import subprocess
import tarfile
from pathlib import Path
from shlex import split

import click
import requests

from clk.colors import Colorer
from clk.commands.pip import pip
from clk.completion import startswith
from clk.config import config
from clk.decorators import argument, flag, group, option, pass_context, table_fields, table_format, use_settings
from clk.lib import ParameterType, TablePrinter, call, cd, check_output, copy, get_option_choices, glob, ln, move, rm
from clk.log import get_logger
from clk.overloads import CommandSettingsKeyType
from clk.profile import DirectoryProfile
from clk.types import DirectoryProfile as DirectoryProfileType

LOGGER = get_logger(__name__)


class ExtensionConfig(object):
    pass


class ExtensionNameType(ParameterType):
    def __init__(self, enabled=False, disabled=False, failok=True):
        self.disabled = disabled
        self.enabled = enabled
        self.failok = failok
        super(ExtensionNameType, self).__init__()

    def getchoice(self, ctx):
        if self.enabled:
            extensions = config.all_enabled_extensions
        elif self.disabled:
            extensions = list(config.all_disabled_extensions) + list(config.all_unset_extensions)
        else:
            extensions = config.all_extensions
        return [extension.short_name for extension in extensions]

    def complete(self, ctx, incomplete):
        choice = self.getchoice(ctx)
        return [(extension, load_short_help(extension)) for extension in choice if startswith(extension, incomplete)]


class ExtensionType(ExtensionNameType):
    def convert(self, value, param, ctx):
        choice = self.getchoice(ctx)
        if value not in choice and self.failok:
            self.fail(
                'invalid choice: %s. (choose from %s)' % (value, ', '.join(choice)),
                param,
                ctx,
            )
        candidates = list(reversed(list(config.all_enabled_extensions)))
        # the algorithm here is to first prefer exact match before falling back
        # to looser match. Both loops look alike, but the reason why they are
        # searated is that even if a loose (based on the short_name) match
        # occurs earlier on the list than an exact match (based on the name),
        # the exact match should take the precedence.
        for candidate in candidates:
            if candidate.name == value:
                return candidate
        for candidate in candidates:
            if candidate.short_name == value:
                return candidate
        raise NotImplementedError('This part of the code should never be reached')


def load_short_help(extension):
    return extension


@group(default_command='show')
@use_settings('extension', ExtensionConfig)
def extension():
    """Extension related commands

    An extension is a set of settings that may be activated or disactivated in a project.
    The extensions can be defined at the global or local profile."""
    pass


@extension.command(handle_dry_run=True)
@argument('name', help='The extension name')
@flag(
    '--disable/--enable',
    help='Automatically disable the cloned extension',
)
@pass_context
def create(ctx, name, disable):
    """Create a new extension"""
    profile = config.extension.profile
    r = profile.create_extension(name)
    LOGGER.status('Created extension {}.'.format(r.friendly_name))
    if disable:
        ctx.invoke(_disable, extension=[name])


@extension.command(handle_dry_run=True)
@argument('old', type=ExtensionType(), help='The current extension name')
@argument('new', help='The new extension name')
def rename(old, new):
    """Rename an extension"""
    if '/' not in new:
        new = '{}/{}'.format(old.name.split('/')[0], new)
    new_loc = config.extension_location(new)
    if os.path.exists(new_loc):
        raise click.UsageError('{} already exists'.format(new_loc))
    move(old.location, new_loc)


@extension.command(handle_dry_run=True)
@argument('old', type=ExtensionType(), help='The current extension name')
@argument(
    'profile',
    type=DirectoryProfileType(root_only=True),
    help='The profile where to move the extension',
)
def _move(old, profile):
    """Move an extension to another profile"""
    move(
        old.location,
        Path(profile.location) / 'extensions' / Path(old.location).name,
    )


@extension.command(handle_dry_run=True)
@argument('src', type=ExtensionType(), help='The source extension name')
@argument('dest', help='The destination extension name')
def _copy(src, dest):
    """Copy an extension"""
    if '/' not in dest:
        dest = '{}/{}'.format(src.name.split('/')[0], dest)
    new_loc = config.extension_location(dest)
    if os.path.exists(new_loc):
        raise click.UsageError('{} already exists'.format(new_loc))
    copy(src.location, new_loc)


@extension.command(handle_dry_run=True)
@argument(
    'extension',
    type=ExtensionType(),
    nargs=-1,
    help='The name of the extensions to remove',
)
@flag('--force', help="Don't ask for confirmation")
def remove(extension, force):
    """Remove an extension"""
    for rec in extension:
        profile = config.get_profile_containing_extension(rec.name)
        path = profile.get_extension(rec.name).location
        if force or click.confirm(f'Removing {path}, are you sure ?'):
            rm(path)


@extension.command(handle_dry_run=True)
@table_fields(choices=['extension', 'set_in', 'defined_in', 'order'], default=[
    'extension',
    'set_in',
    'defined_in',
])
@table_format(default='simple')
@Colorer.color_options
@flag('--enabled-only/--not-enabled-only', help='Show only the enabled extensions')
@flag(
    '--disabled-only/--not-disabled-only',
    help='Show only the disabled extensions',
)
@option('--order/--no-order', help='Display the priority of the extension')
@argument(
    'extensions',
    type=ExtensionNameType(disabled=True, failok=False),
    nargs=-1,
    help='The names of the extensions to show',
)
def show(fields, format, order, extensions, enabled_only, disabled_only, **kwargs):
    """List the extensions and some info about them"""
    config_extensions = set(config.extension.readonly.keys())
    avail_extensions = set([r.short_name for r in config.all_extensions])
    if not fields:
        fields = list(get_option_choices('fields'))
        if not order:
            fields.remove('order')

    if not extensions:
        extensions = config_extensions | avail_extensions
    if not extensions:
        LOGGER.status('No extension yet')
        exit(0)
    with Colorer(kwargs) as colorer, TablePrinter(fields, format) as tp:
        for extension_name in sorted(extensions):
            profiles = ', '.join([
                click.style(profile.name, **colorer.get_style(profile.name))
                for profile in config.root_profiles
                if profile.has_extension(extension_name)
            ])
            profile = colorer.last_profile_of_settings(
                extension_name,
                config.extension.all_settings,
            )
            extension_enabled = config.is_extension_enabled(extension_name)
            if (not enabled_only or extension_enabled) and (not disabled_only or not extension_enabled):
                profile_style = colorer.get_style(profile) if profile else {}

                tp.echo(
                    click.style(extension_name, fg='green' if extension_enabled else 'red'),
                    (profile and click.style(profile, **profile_style)) or 'Unset',
                    profiles or 'Undefined',
                    config.get_extension_order(extension_name),
                )


@extension.command(handle_dry_run=True)
@flag('--all', help='On all extensions')
@argument(
    'extension',
    type=ExtensionNameType(enabled=True, failok=False),
    nargs=-1,
    help='The names of the extensions to disable',
)
@pass_context
def _disable(ctx, extension, all):
    """Don't use this extension"""
    if all:
        extension = ExtensionType(disabled=True).getchoice(ctx)
    for cmd in extension:
        if cmd in config.extension.writable:
            config.extension.writable[cmd]['enabled'] = False
        else:
            config.extension.writable[cmd] = {'enabled': False}
        LOGGER.status('Disabling extension {} in profile {}'.format(cmd, config.extension.writeprofile))
    config.extension.write()


@extension.command(handle_dry_run=True)
@flag('--all', help='On all extensions')
@argument(
    'extension',
    type=CommandSettingsKeyType('extension'),
    nargs=-1,
    help='The name of the extension to unset',
)
@pass_context
def unset(ctx, extension, all):
    """Don't say whether to use or not this extension (let the upper profiles decide)"""
    if all:
        extension = list(config.extension.readonly.keys())
    for cmd in extension:
        if cmd not in config.extension.writable:
            raise click.UsageError('Extension {} not set in profile {}'.format(cmd, config.extension.writeprofile))
    for cmd in extension:
        del config.extension.writable[cmd]
        LOGGER.status('Unsetting {} from profile {}'.format(cmd, config.extension.writeprofile))
    config.extension.write()


@extension.command(handle_dry_run=True)
@flag('--all', help='On all extensions')
@option(
    '--only/--no-only',
    help='Use only the provided extension, and disable the others',
)
@argument(
    'extension',
    type=ExtensionNameType(disabled=True, failok=False),
    nargs=-1,
    help='The names of the extensions to enable',
)
@pass_context
def __enable(ctx, extension, all, only):
    """Use this extension"""
    if all:
        extension = ExtensionType(disabled=True).getchoice(ctx)
    if only:
        for cmd in set(ExtensionType().getchoice(ctx)) - set(extension):
            if cmd in config.extension.writable:
                config.extension.writable[cmd]['enabled'] = False
            else:
                config.extension.writable[cmd] = {'enabled': False}
            LOGGER.status('Disabling extension {} in profile {}'.format(cmd, config.extension.writeprofile))

    for cmd in extension:
        if cmd in config.extension.writable:
            config.extension.writable[cmd]['enabled'] = True
        else:
            config.extension.writable[cmd] = {'enabled': True}
        LOGGER.status('Enabling extension {} in profile {}'.format(cmd, config.extension.writeprofile))
    config.extension.write()


@extension.command(handle_dry_run=True)
@argument(
    'extension1',
    type=ExtensionNameType(enabled=True, failok=False),
    help='The name of the extension to disable',
)
@argument(
    'extension2',
    type=ExtensionNameType(disabled=True, failok=False),
    help='The name of the extension to enable',
)
@pass_context
def switch(ctx, extension1, extension2):
    """Switch from an extension to another"""
    ctx.invoke(_disable, extension=[extension1])
    ctx.invoke(__enable, extension=[extension2])


@extension.command(handle_dry_run=True)
@argument(
    'extension',
    type=ExtensionNameType(failok=False),
    nargs=-1,
    help='The names of the extensions to which the order will be set',
)
@argument('order', type=int, help='The order to be set on the extensions')
def set_order(extension, order):
    """Set the order of the extensions"""
    if not extension:
        extension = config.all_extensions
    for cmd in extension:
        if cmd in config.extension.writable:
            config.extension.writable[cmd]['order'] = order
        else:
            config.extension.writable[cmd] = {'order': order}
        LOGGER.status('Set order of {} to {} in profile {}'.format(cmd, order, config.extension.writeprofile))
    config.extension.write()


@extension.command()
@argument('profile', type=ExtensionType(), help='The name of the profile to open')
@option('--opener', help='Program to call to open the directory', default='xdg-open')
def open(profile, opener):
    """Open the directory containing the profile"""
    call([opener, profile.location])


@extension.command()
@argument('profile', type=DirectoryProfileType(), help='The name of the profile to show')
def where_is(profile):
    """Show where is a given extension"""
    print(profile.location)


predefined_hosts = [
    'github.com',
    'gitlab.com',
    'bitbucket.org',
]


@extension.command()
@option('--profile', type=DirectoryProfileType(), help='The profile where to install the extension')
@argument(
    'url',
    help=('The url of the git repository hosting the extension.'
          ' Can be author/extension for github repository.'
          ' If that case, the url will become'
          ' https://github.com/{author}/clk_extension_{extension}.'
          ' Actually, the prefix (github.com) may be changed using --url-prefix.'
          ' Can also be gitlab.com/{author}/{extension},'
          ' github.com/{author}/{extension},'
          ' git@...,'
          ' http://...,'
          ' a path to a local directory'
          ' (not that in that case, using --editable makes sense).'),
)
@argument('name', help='The name of the extension', required=False)
@flag('--install-deps/--no-install-deps', help='Automatically install the dependencies.', default=True)
@flag('--force/--no-force', help='Overwrite the existing extension if need be.')
@flag('-e', '--editable', help='(only for local path) Create a symbolic link rather than copying the content')
@pass_context
def install(ctx, profile, url, name, install_deps, editable, force):
    """Install an extension from outside"""
    profile = profile or config.global_profile
    urls = []
    if re.match('^[a-zA-Z0-9]+$', url):
        urls.append(f'git@github.com:clk-project/clk_extension_{url}')
        urls.append(f'https://github.com/clk-project/clk_extension_{url}')
        install_type = 'git'
        if name is None:
            name = url
    elif match := re.match('^(?P<author>[a-zA-Z0-9_-]+)/(?P<extension>[a-zA-Z0-9]+)$', url):
        author = match.group('author')
        extension = match.group('extension')
        for host in predefined_hosts:
            urls.append(f'git@{host}:{author}/clk_extension_{extension}')
            urls.append(f'https://{host}/{author}/clk_extension_{extension}')
            urls.append(f'git@{host}:{author}/{extension}')
            urls.append(f'https://{host}/{author}/{extension}')
        install_type = 'git'
        if name is None:
            name = extension
    elif match := re.match('^(?P<host>[a-zA-Z0-9_.-]+)/(?P<path>[a-zA-Z0-9_/-]+)/(?P<extension>[a-zA-Z0-9]+)$', url):
        host = match.group('host')
        path = match.group('path')
        extension = match.group('extension')
        urls.append(f'git@{host}:{path}/clk_extension_{extension}')
        urls.append(f'https://{host}/{path}/clk_extension_{extension}')
        urls.append(f'git@{host}:{path}/{extension}')
        urls.append(f'https://{host}/{path}/{extension}')
        install_type = 'git'
        if name is None:
            name = extension
    elif m := re.match('^https://github.com/.+/(?P<name>[^/]+)/tarball/.+$', url):
        install_type = 'webtar'
        urls.append(url)
        name = name or m['name']
    elif url.startswith('file:'):
        url = str(Path(url[len('file:'):]).absolute())
        install_type = 'file'
        name = name or Path(url).name
        urls.append(os.path.abspath(url))
    elif re.match(r'(\w+://)(.+@)*([\w\d\.]+)(:[\d]+)?/*(.*)|(.+@)*([\w\d\.]+):(.*)', url):
        install_type = 'git'
        urls.append(url)
    elif Path(url).exists():
        install_type = 'file'
        name = name or Path(url).name
        urls.append(os.path.abspath(url))
    else:
        install_type = 'git'
        urls.append(url)

    if editable is True and install_type != 'file':
        LOGGER.warning('Ignoring --editable for we guessed that'
                       ' you did not provide a url that actually'
                       ' points to a local file')

    if name is None:
        if '/' in url:
            name = url.split('/')[-1]
        else:
            raise click.UsageError('I cannot infer a name for your extension. Please provide one explicitly.')
    if name.startswith('clk_extension_'):
        name = name.replace('clk_extension_', '')
    if not re.match(f'^{DirectoryProfile.extension_name_re}$', name):
        raise click.UsageError(f"Invalid extension name '{name}'."
                               " an extension's name must contain only letters or _")

    if install_type is None:
        raise click.UsageError('I cannot infer how to install the extension'
                               ' Please tell us what you wanted to do'
                               ' so that we can fix the code and the doc.')

    extension_path = (Path(profile.location) / 'extensions').resolve() / name
    if extension_path.exists() or extension_path.is_symlink():
        if force:
            rm(extension_path)
        else:
            if not os.path.exists(f'{extension_path}/.git'):
                raise click.UsageError(f'An extension already exists at location {extension_path}'
                                       ' Use --force to override it.')
    if install_type == 'git':
        # check if we already have that extension locally
        if os.path.exists(f'{extension_path}/.git'):
            with cd(extension_path):
                url = check_output(['git', 'remote', 'get-url', 'origin']).strip()
                if url not in urls:
                    LOGGER.debug(f'urls: {urls}')
                    raise click.UsageError(f'Extension {name} already exists and is not using the same URL: {url}')
                call(['git', 'pull'])
        else:
            ok = False
            for tryurl in urls:
                try:
                    call(['git', 'clone', tryurl, str(extension_path)])
                except subprocess.CalledProcessError:
                    # this one did not work, go on to the next one
                    continue
                else:
                    # found one that works, stop trying
                    ok = True
                    break
            if ok is False:
                raise click.UsageError('Tried git cloning the following urls, without success:'
                                       f" {', '.join(urls)}. Please take a look at the documentation"
                                       ' to see how you can pass urls')
    elif install_type == 'file':
        if editable:
            ln(Path(url).resolve(), extension_path)
        else:
            copy(url, extension_path)
    elif install_type == 'webtar':
        LOGGER.info(f'Getting the tarfile from {url}')
        tar = tarfile.open(fileobj=io.BytesIO(requests.get(url).content))
        tar.extractall(extension_path)
        for file in glob(f'{extension_path}/*/*'):
            move(file, extension_path)

    extension = profile.get_extension(name)

    if install_deps is True:
        LOGGER.status('-> Installing the dependencies of the extension')
        ctx.invoke(_install_deps, extension=[extension])
    LOGGER.status(f'Done installing the extension {name}')


@extension.command()
@argument(
    'extension',
    type=DirectoryProfileType(),
    nargs=-1,
    help='The name of the extensions to consider',
)
@pass_context
def _install_deps(ctx, extension):
    'Install the dependencies of the extension'
    for rec in extension:
        LOGGER.status('Handling {}'.format(rec.friendly_name))
        if rec.requirements_path.exists():
            ctx.invoke(pip, args=('install', '--upgrade', '-r', rec.requirements_path))
        else:
            LOGGER.info(f'Nothing to be done for {rec.friendly_name}')


@extension.command()
@argument(
    'extension',
    type=ExtensionType(),
    nargs=-1,
    required=True,
    help='The names of the extensions to update',
)
@flag('--clean', 'method', flag_value='clean', help='Remove local modification and update')
@flag('--stash', 'method', flag_value='stash', help='Stash local modification and update')
@flag('--no-clean', 'method', flag_value='no-clean', help="Don't try cleaning the repository before pulling")
def update(extension, method):
    """Update this cloned extension"""
    for cmd in extension:
        root = Path(cmd.location)
        LOGGER.info(f'Updating {cmd.name}')
        if not (root / '.git').exists():
            LOGGER.warning(f'I cannot update the extension {cmd.name}.'
                           ' For the time being, I only can update'
                           ' cloned extensions.')
            continue
        with cd(root):
            need_stash = False
            if method == 'clean':
                call(['git', 'clean', '-fd'])
                call(['git', 'checkout', '.'])
                call(['git', 'reset', '--hard', 'HEAD'])
            elif method == 'stash':
                need_stash = (check_output(split('git status --porcelain --ignore-submodules --untracked-files=no')) !=
                              '')
            if need_stash:
                call(split('git stash'))
            call(['git', 'pull'])
            if need_stash:
                call(split('git stash pop'))


@extension.command()
@argument('extension', type=ExtensionType(), help='The extension to describe')
def describe(extension):
    """Try to give some insights into the content of the extension"""
    extension.describe()
