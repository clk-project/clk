#!/usr/bin/env python

import io
import os
import re
import subprocess
import tarfile
from pathlib import Path
from shlex import split

import click
import requests

from clk import run
from clk.colors import Colorer
from clk.commands.pip import pip
from clk.completion import startswith
from clk.config import config
from clk.decorators import (
    argument,
    flag,
    group,
    option,
    pass_context,
    table_fields,
    table_format,
    use_settings,
)
from clk.lib import (
    ParameterType,
    TablePrinter,
    call,
    cd,
    check_output,
    copy,
    get_option_choices,
    glob,
    ln,
    move,
    rm,
)
from clk.log import get_logger
from clk.overloads import CommandSettingsKeyType
from clk.profile import DirectoryProfile
from clk.types import DirectoryProfile as DirectoryProfileType

LOGGER = get_logger(__name__)


class ExtensionConfig:
    pass


class ExtensionNameType(ParameterType):
    def __init__(self, enabled=False, disabled=False, shortonly=False):
        self.disabled = disabled
        self.enabled = enabled
        self.shortonly = shortonly
        super().__init__()

    def getchoice(self, ctx):
        if self.enabled:
            extensions = config.all_enabled_extensions
        elif self.disabled:
            extensions = list(config.all_disabled_extensions) + list(
                config.all_unset_extensions
            )
        else:
            extensions = config.all_extensions
        extensions = list(extensions)  # capture a list out of the generator
        names = [extension.short_name for extension in extensions]
        if not self.shortonly:
            names += [extension.name for extension in extensions]
        return names

    def shell_complete(self, ctx, param, incomplete):
        choice = self.getchoice(ctx)
        return [
            click.shell_completion.CompletionItem(
                extension, help=load_short_help(extension)
            )
            for extension in choice
            if startswith(extension, incomplete)
        ]


class ExtensionType(ExtensionNameType):
    def convert(self, value, param, ctx):
        choice = self.getchoice(ctx)
        if value not in choice:
            self.fail(
                "invalid choice: {}. (choose from {})".format(value, ", ".join(choice)),
                param,
                ctx,
            )

        candidates = list(reversed(list(config.all_extensions)))
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
        raise NotImplementedError("This part of the code should never be reached")


def load_short_help(extension):
    return extension


@group(default_command="show")
@use_settings("recipe", ExtensionConfig)
def extension():
    """Extension related commands

    An extension is a set of settings that may be activated or disactivated in a project.
    The extensions can be defined at the global or local profile."""
    pass


@extension.command(handle_dry_run=True)
@argument("name", help="The extension name")
@flag(
    "--disable/--enable",
    help="Automatically disable the cloned extension",
)
@pass_context
def create(ctx, name, disable):
    """Create a new extension"""
    profile = config.recipe.profile
    r = profile.create_extension(name)
    LOGGER.status(
        "Created extension {}.".format(
            Colorer.apply_color_default_value(
                r.friendly_name, config.recipe.writeprofilename
            )
        )
    )
    if disable:
        ctx.invoke(_disable, extension=[name])


@extension.command(handle_dry_run=True)
@argument("old", type=ExtensionType(), help="The current extension name")
@argument("new", help="The new extension name")
def rename(old, new):
    """Rename an extension"""
    if "/" not in new:
        new = "{}/{}".format(old.name.split("/")[0], new)
    new_loc = config.extension_location(new)
    if os.path.exists(new_loc):
        raise click.UsageError(f"{new_loc} already exists")
    move(old.location, new_loc)
    LOGGER.status(
        f"Renamed extension {old.friendly_name} -> {new} in profile"
        f" {Colorer.apply_color_profilename(old.parent_name)}."
    )


@extension.command(handle_dry_run=True)
@argument("old", type=ExtensionType(), help="The current extension name")
@argument(
    "profile",
    type=DirectoryProfileType(root_only=True),
    help="The profile where to move the extension",
)
def _move(old, profile):
    """Move an extension to another profile"""
    move(
        old.location,
        Path(profile.location) / "extensions" / Path(old.location).name,
    )
    LOGGER.status(
        f"Moved extension {Colorer.apply_color_default_value(old.friendly_name, old.parent_name)} to profile"
        f" {Colorer.apply_color_profilename(profile.name)}."
    )


@extension.command(handle_dry_run=True)
@argument("src", type=ExtensionType(), help="The source extension name")
@argument("dest", help="The destination extension name")
def _copy(src, dest):
    """Copy an extension"""
    if "/" not in dest:
        dest = "{}/{}".format(src.name.split("/")[0], dest)
    new_loc = config.extension_location(dest)
    if os.path.exists(new_loc):
        raise click.UsageError(f"{new_loc} already exists")
    copy(src.location, new_loc)
    LOGGER.status(
        f"Copied extension {Colorer.apply_color_default_value(src.friendly_name, src.parent_name)}"
        f" -> {Colorer.apply_color_default_value(dest, src.parent_name)}."
    )


@extension.command(handle_dry_run=True)
@argument(
    "extension",
    type=ExtensionType(),
    nargs=-1,
    help="The name of the extensions to remove",
)
@flag("--force", help="Don't ask for confirmation")
def remove(extension, force):
    """Remove an extension"""
    for rec in extension:
        profile = config.get_profile_containing_extension(rec.name)
        path = profile.get_extension(rec.name).location
        if force or click.confirm(f"Removing {path}, are you sure ?"):
            rm(path)
            LOGGER.status(
                f"Removed extension {Colorer.apply_color_default_value(rec.friendly_name, rec.parent_name)}"
            )


@extension.command(handle_dry_run=True)
@table_fields(
    choices=["extension", "configuration", "installation", "order"],
    default=[
        "extension",
        "configuration",
        "installation",
    ],
)
@table_format(default="simple")
@Colorer.color_options
@flag("--enabled-only/--not-enabled-only", help="Show only the enabled extensions")
@flag(
    "--disabled-only/--not-disabled-only",
    help="Show only the disabled extensions",
)
@option("--order/--no-order", help="Display the priority of the extension")
@argument(
    "extensions",
    type=ExtensionNameType(shortonly=True),
    nargs=-1,
    help="The names of the extensions to show",
)
def show(fields, format, order, extensions, enabled_only, disabled_only, **kwargs):
    """List the extensions and some info about them"""
    config_extensions = set(config.recipe.readonly.keys())
    avail_extensions = {r.short_name for r in config.all_extensions}
    if not fields:
        fields = list(get_option_choices("fields"))
        if not order:
            fields.remove("order")

    if not extensions:
        extensions = config_extensions | avail_extensions
    if not extensions:
        LOGGER.status("No extension yet")
        exit(0)
    with Colorer(kwargs) as colorer, TablePrinter(fields, format) as tp:
        for extension_name in sorted(extensions):
            profiles = ", ".join(
                [
                    click.style(profile.name, **colorer.get_style(profile.name))
                    for profile in config.root_profiles
                    if profile.has_extension(extension_name)
                ]
            )
            profile = colorer.last_profile_of_settings(
                extension_name,
                config.recipe.all_settings,
            )
            extension_enabled = config.is_extension_enabled(extension_name)
            if (not enabled_only or extension_enabled) and (
                not disabled_only or not extension_enabled
            ):
                profile_style = colorer.get_style(profile) if profile else {}

                tp.echo(
                    click.style(
                        extension_name, fg="green" if extension_enabled else "red"
                    ),
                    (profile and click.style(profile, **profile_style)) or "Unset",
                    profiles or "Undefined",
                    config.get_extension_order(extension_name),
                )


@extension.command(handle_dry_run=True)
@flag("--all", help="On all extensions")
@argument(
    "extension",
    type=ExtensionNameType(enabled=True, shortonly=True),
    nargs=-1,
    help="The names of the extensions to disable",
)
@pass_context
def _disable(ctx, extension, all):
    """Don't use this extension"""
    if all:
        extension = ExtensionNameType(disabled=True, shortonly=True).getchoice(ctx)
    for cmd in extension:
        if cmd in config.recipe.writable:
            config.recipe.writable[cmd]["enabled"] = False
        else:
            config.recipe.writable[cmd] = {"enabled": False}
        LOGGER.status(
            f"Disabling extension {cmd} in profile {Colorer.apply_color_profilename(config.recipe.writeprofilename)}"
        )
    config.recipe.write()


@extension.command(handle_dry_run=True)
@flag("--all", help="On all extensions")
@argument(
    "extension",
    type=CommandSettingsKeyType("recipe"),
    nargs=-1,
    help="The name of the extension to unset",
)
@pass_context
def unset(ctx, extension, all):
    """Don't say whether to use or not this extension (let the upper profiles decide)"""
    if all:
        extension = list(config.recipe.profile.settings["recipe"].keys())
    for cmd in extension:
        if cmd not in config.recipe.writable:
            raise click.UsageError(
                f"Extension {cmd} not set in profile {Colorer.apply_color_profilename(config.recipe.writeprofilename)}"
            )
    for cmd in extension:
        del config.recipe.writable[cmd]
        LOGGER.status(
            f"Unsetting {cmd} from profile {Colorer.apply_color_profilename(config.recipe.writeprofilename)}"
        )
    config.recipe.write()


@extension.command(handle_dry_run=True)
@flag("--all", help="On all extensions")
@option(
    "--only",
    help="Use only the provided extension, and disable the others",
    type=ExtensionNameType(shortonly=True),
)
@argument(
    "extension",
    type=ExtensionNameType(disabled=True, shortonly=True),
    nargs=-1,
    help="The names of the extensions to enable",
)
@pass_context
def __enable(ctx, extension, all, only):
    """Use this extension"""
    if only and extension:
        raise click.UsageError(
            "You can only provide one of --only extension or simply extension"
        )
    if all:
        extension = ExtensionNameType(disabled=True, shortonly=True).getchoice(ctx)
    if only:
        extension = [only]
        for cmd in set(ExtensionNameType(shortonly=True).getchoice(ctx)) - set(
            extension
        ):
            if cmd in config.recipe.writable:
                config.recipe.writable[cmd]["enabled"] = False
            else:
                config.recipe.writable[cmd] = {"enabled": False}
            LOGGER.status(
                f"Disabling extension {cmd} in profile {Colorer.apply_color_profilename(config.recipe.writeprofilename)}"
            )

    for cmd in extension:
        if cmd in config.recipe.writable:
            config.recipe.writable[cmd]["enabled"] = True
        else:
            config.recipe.writable[cmd] = {"enabled": True}
        LOGGER.status(
            f"Enabling extension {cmd} in profile {Colorer.apply_color_profilename(config.recipe.writeprofilename)}"
        )
    config.recipe.write()


@extension.command(handle_dry_run=True)
@argument(
    "extension",
    type=ExtensionType(),
    help="The name of the extension to enable",
)
@pass_context
def switch(ctx, extension):
    """Switch to an extension, disabling all the other extensions that are know
    as alternatives"""
    ctx.invoke(__enable, extension=[extension.short_name])
    if extension.alternative_groups:
        LOGGER.status(
            f"Part of the group {', '.join(extension.alternative_groups)}, disabling the other ones"
        )
        for other_extension in config.all_extensions:
            if (
                other_extension != extension
                and other_extension.alternative_groups == extension.alternative_groups
            ):
                ctx.invoke(_disable, extension=[other_extension.short_name])


@extension.command(handle_dry_run=True)
@argument(
    "extension",
    type=ExtensionNameType(shortonly=True),
    nargs=-1,
    help="The names of the extensions to which the order will be set",
)
@argument("order", type=int, help="The order to be set on the extensions")
def set_order(extension, order):
    """Set the order of the extensions"""
    if not extension:
        extension = config.all_extensions
    for cmd in extension:
        if cmd in config.recipe.writable:
            config.recipe.writable[cmd]["order"] = order
        else:
            config.recipe.writable[cmd] = {"order": order}
        LOGGER.status(
            f"Set order of {cmd} to {order} in profile {Colorer.apply_color_profilename(config.recipe.writeprofilename)}"
        )
    config.recipe.write()


@extension.command()
@argument("extension", type=ExtensionType(), help="The name of the extension to open")
@option("--opener", help="Program to call to open the directory", default="xdg-open")
def _open(extension, opener):
    """Open the directory containing the profile"""
    call([opener, extension.location])


@extension.command()
@argument(
    "profile", type=DirectoryProfileType(), help="The name of the profile to show"
)
def where_is(profile):
    """Show where is a given profile"""
    print(profile.location)


def process_url(name, url):
    urls = []
    if re.match("^[a-zA-Z0-9]+$", url):
        urls.append(f"git@github.com:clk-project/clk_extension_{url}")
        urls.append(f"https://github.com/clk-project/clk_extension_{url}")
        install_type = "git"
        if name is None:
            name = url
    elif match := re.match(
        "^(?P<author>[a-zA-Z0-9_-]+)/(?P<extension>[a-zA-Z0-9_]+)$", url
    ):
        author = match.group("author")
        extension = match.group("extension")
        for host in predefined_hosts:
            urls.append(f"git@{host}:{author}/clk_extension_{extension}")
            urls.append(f"https://{host}/{author}/clk_extension_{extension}")
            urls.append(f"git@{host}:{author}/{extension}")
            urls.append(f"https://{host}/{author}/{extension}")
        install_type = "git"
        if name is None:
            name = extension
    elif match := re.match(
        "^(?P<host>[a-zA-Z0-9_.-]+)/(?P<path>[a-zA-Z0-9_/-]+)/(?P<extension>[a-zA-Z0-9]+)$",
        url,
    ):
        host = match.group("host")
        path = match.group("path")
        extension = match.group("extension")
        urls.append(f"git@{host}:{path}/clk_extension_{extension}")
        urls.append(f"https://{host}/{path}/clk_extension_{extension}")
        urls.append(f"git@{host}:{path}/{extension}")
        urls.append(f"https://{host}/{path}/{extension}")
        install_type = "git"
        if name is None:
            name = extension
    elif m := re.match("^https://github.com/.+/(?P<name>[^/]+)/tarball/.+$", url):
        install_type = "webtar"
        urls.append(url)
        name = name or m["name"]
    elif url.startswith("file:"):
        url = str(Path(url[len("file:") :]).absolute())
        install_type = "file"
        name = name or Path(url).name
        urls.append(os.path.abspath(url))
    elif re.match(
        r"(\w+://)(.+@)*([\w\d\.]+)(:[\d]+)?/*(.*)|(.+@)*([\w\d\.]+):(.*)", url
    ):
        install_type = "git"
        urls.append(url)
    elif Path(url).exists():
        install_type = "file"
        name = name or Path(url).name
        urls.append(os.path.abspath(url))
    else:
        install_type = "git"
        urls.append(url)
    if name is None and "/" in url:
        name = url.split("/")[-1]
    if name is None:
        raise NotImplementedError(
            f"Could not parse the given url to extract a name out of it: {url}"
        )
    if name.startswith("clk_extension_"):
        name = name.replace("clk_extension_", "")
    return name, urls, install_type


predefined_hosts = [
    "github.com",
    "gitlab.com",
    "bitbucket.org",
]


@extension.command()
@option(
    "--profile",
    type=DirectoryProfileType(),
    help="The profile where to install the extension",
)
@argument(
    "url",
    help=(
        "The url of the git repository hosting the extension."
        " Can be author/extension for github repository."
        " If that case, the url will become"
        " https://github.com/{author}/clk_extension_{extension}."
        " Actually, the prefix (github.com) may be changed using --url-prefix."
        " Can also be gitlab.com/{author}/{extension},"
        " github.com/{author}/{extension},"
        " git@...,"
        " http://...,"
        " a path to a local directory"
        " (not that in that case, using --editable makes sense)."
    ),
)
@argument("name", help="The name of the extension", required=False)
@flag(
    "--install-deps/--no-install-deps",
    help="Automatically install the dependencies.",
    default=True,
)
@flag("--force/--no-force", help="Overwrite the existing extension if need be.")
@flag(
    "-e",
    "--editable",
    help="(only for local path) Create a symbolic link rather than copying the content",
)
@flag("--break-system-packages", help="Use this flag of pip")
@pass_context
def install(
    ctx, profile, url, name, install_deps, editable, force, break_system_packages
):
    """Install an extension from outside"""
    profile = profile or config.global_profile
    name, urls, install_type = process_url(name, url)
    if name is None:
        raise click.UsageError(
            "I cannot infer a name for your extension. Please provide one explicitly."
        )

    if not re.match(f"^{DirectoryProfile.extension_name_re}$", name):
        raise click.UsageError(
            f"Invalid extension name '{name}'."
            " an extension's name must contain only letters or _"
        )

    if editable is True and install_type != "file":
        LOGGER.warning(
            "Ignoring --editable for we guessed that"
            " you did not provide a url that actually"
            " points to a local file"
        )

    if install_type is None:
        raise click.UsageError(
            "I cannot infer how to install the extension"
            " Please tell us what you wanted to do"
            " so that we can fix the code and the doc."
        )

    extension_path = (Path(profile.location) / "extensions").resolve() / name
    if extension_path.exists() or extension_path.is_symlink():
        if force:
            rm(extension_path)
        else:
            if not os.path.exists(f"{extension_path}/.git"):
                raise click.UsageError(
                    f"An extension already exists at location {extension_path}"
                    " Use --force to override it."
                )
    if install_type == "git":
        # check if we already have that extension locally
        if os.path.exists(f"{extension_path}/.git"):
            with cd(extension_path):
                url = check_output(["git", "remote", "get-url", "origin"]).strip()
                if url not in urls:
                    LOGGER.debug(f"urls: {urls}")
                    raise click.UsageError(
                        f"Extension {name} already exists and is not using the same URL: {url}"
                    )
                call(["git", "pull"])
        else:
            ok = False
            for tryurl in urls:
                try:
                    call(["git", "clone", tryurl, str(extension_path)])
                except subprocess.CalledProcessError:
                    # this one did not work, go on to the next one
                    continue
                else:
                    # found one that works, stop trying
                    ok = True
                    break
            if ok is False:
                raise click.UsageError(
                    "Tried git cloning the following urls, without success:"
                    f" {', '.join(urls)}. Please take a look at the documentation"
                    " to see how you can pass urls"
                )
    elif install_type == "file":
        if editable:
            ln(Path(url).resolve(), extension_path)
        else:
            copy(url, extension_path)
            (extension_path / "url").write_text(url)
    elif install_type == "webtar":
        LOGGER.info(f"Getting the tarfile from {url}")
        tar = tarfile.open(fileobj=io.BytesIO(requests.get(url).content))
        tar.extractall(extension_path)
        for file in glob(f"{extension_path}/*/*"):
            move(file, extension_path)
        (extension_path / "url").write_text(url)

    extension = profile.get_extension(name)

    if install_deps is True:
        LOGGER.status("-> Installing the dependencies of the extension")
        ctx.invoke(
            _install_deps,
            extension=[extension],
            break_system_packages=break_system_packages,
        )
    LOGGER.status(f"Done installing the extension {name}")


@extension.command()
@argument(
    "extension",
    type=DirectoryProfileType(),
    nargs=-1,
    help="The name of the extensions to consider",
)
@flag("--break-system-packages", help="Use this flag of pip")
@pass_context
def _install_deps(ctx, extension, break_system_packages):
    "Install the dependencies of the extension"
    for rec in extension:
        LOGGER.status(f"Handling {rec.friendly_name}")
        if rec.requirements_path.exists():
            pip_args = ["install"]
            if break_system_packages:
                pip_args += ["--break-system-packages"]
            pip_args += ["--upgrade", "-r", rec.requirements_path]
            ctx.invoke(pip, args=pip_args)
        else:
            LOGGER.info(f"Nothing to be done for {rec.friendly_name}")


@extension.command()
@argument(
    "extension",
    type=ExtensionType(),
    nargs=-1,
    required=True,
    help="The names of the extensions to update",
)
@flag(
    "--clean",
    "--force",
    "method",
    flag_value="clean",
    help="Remove local modification and update",
)
@flag(
    "--stash", "method", flag_value="stash", help="Stash local modification and update"
)
@flag(
    "--no-clean",
    "method",
    flag_value="no-clean",
    help="Don't try cleaning the repository before pulling",
)
@flag(
    "--install-deps/--no-install-deps",
    help="Automatically install the dependencies.",
    default=True,
)
@option("--branch", help="Make sure to get into that branch before updating")
def update(extension, method, install_deps, branch):
    """Update this cloned extension"""
    for cmd in extension:
        root = Path(cmd.location)
        LOGGER.status(f"Updating {cmd.name}")
        if not (root / ".git").exists():
            LOGGER.warning(
                f"I cannot update the extension {cmd.name}."
                " For the time being, I only can update"
                " cloned extensions."
            )
            continue
        with cd(root):
            if not branch:
                current_branch_name = check_output(
                    ["git", "rev-parse", "--abbrev-ref", "HEAD"]
                ).strip()
                if current_branch_name not in ("main", "master"):
                    LOGGER.warning(
                        f"I will update {cmd.name} on branch {current_branch_name}."
                        " It does not look like a main branch name."
                        " To get back to the main branch,"
                        " consider calling `clk extension update"
                        f" {cmd.name} --branch main` (or master)."
                    )
            need_stash = False
            if method == "clean":
                call(["git", "clean", "-fd"])
                call(["git", "checkout", "."])
                call(["git", "reset", "--hard", "HEAD"])
            elif method == "stash":
                need_stash = (
                    check_output(
                        split(
                            "git status --porcelain --ignore-submodules --untracked-files=no"
                        )
                    )
                    != ""
                )
            if need_stash:
                call(split("git stash"))
            if branch:
                call(["git", "checkout", branch])
            call(["git", "pull"])
            if need_stash:
                call(split("git stash pop"))
        if install_deps is True:
            LOGGER.status(f"-> Installing the dependencies of {cmd.name}")
            run(["extension", "install-deps", cmd.name])


@extension.command()
@argument("extension", type=ExtensionType(), help="The extension to describe")
def describe(extension):
    """Try to give some insights into the content of the extension"""
    extension.describe()
