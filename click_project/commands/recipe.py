#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
import requests
import re
import tarfile
import io
import subprocess
from pathlib import Path
from shlex import split

import click

from click_project.decorators import (
    group,
    option,
    argument,
    use_settings,
    flag,
    pass_context,
    settings_stores,
    table_fields,
    table_format,
)
from click_project.completion import startswith
from click_project.log import get_logger
from click_project.config import config
from click_project.colors import Colorer
from click_project.profile import (
    DirectoryProfile,
    profile_name_to_commandline_name,
)
from click_project.lib import (
    check_output, move,
    copy,
    ParameterType,
    json_file,
    json_dumps,
    rm,
    call,
    cd,
    get_option_choices,
    ln,
    glob,
)
from click_project.lib import TablePrinter
from click_project.overloads import CommandSettingsKeyType
from click_project.types import DirectoryProfileType, Suggestion
from click_project.commands.pip import pip

LOGGER = get_logger(__name__)


class RecipeConfig(object):
    pass


class RecipeNameType(ParameterType):
    def __init__(self, enabled=False, disabled=False, failok=True):
        self.disabled = disabled
        self.enabled = enabled
        self.failok = failok
        super(RecipeNameType, self).__init__()

    def getchoice(self, ctx):
        if self.enabled:
            recipes = config.all_enabled_recipes
        elif self.disabled:
            recipes = list(config.all_disabled_recipes) + list(
                config.all_unset_recipes
            )
        else:
            recipes = config.all_recipes
        return [recipe.short_name for recipe in recipes]

    def complete(self, ctx, incomplete):
        choice = self.getchoice(ctx)
        return [
            (recipe, load_short_help(recipe))
            for recipe in choice
            if startswith(recipe, incomplete)
        ]


class RecipeType(RecipeNameType):
    def convert(self, value, param, ctx):
        choice = self.getchoice(ctx)
        if value not in choice and self.failok:
            self.fail(
                "invalid choice: %s. (choose from %s)"
                % (value, ", ".join(choice)),
                param,
                ctx,
            )
        candidates = list(reversed(list(config.all_enabled_recipes)))
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


def load_short_help(recipe):
    return recipe


@group(default_command="show")
@use_settings("recipe", RecipeConfig)
def recipe():
    """Recipe related commands

    A recipe is a set of settings that may be activated or disactivated in a project.
    The recipes can be defined at the global or local profile."""
    pass


@recipe.command(handle_dry_run=True)
@argument("name", help="The recipe name")
@flag(
    "--enable/--disable",
    help="Automatically enable the cloned recipe",
    default=True,
)
@pass_context
def create(ctx, name, enable):
    """Create a new recipe"""
    profile = config.recipe.profile
    r = profile.create_recipe(name)
    LOGGER.status("Created recipe {}.".format(r.friendly_name))
    if enable:
        ctx.invoke(__enable, recipe=[name])


@recipe.command(handle_dry_run=True)
@argument("old", type=RecipeType(), help="The current recipe name")
@argument("new", help="The new recipe name")
def rename(old, new):
    """Rename a recipe"""
    if "/" not in new:
        new = "{}/{}".format(old.name.split("/")[0], new)
    new_loc = config.recipe_location(new)
    if os.path.exists(new_loc):
        raise click.UsageError("{} already exists".format(new_loc))
    move(old.location, new_loc)


@recipe.command(handle_dry_run=True)
@argument("old", type=RecipeType(), help="The current recipe name")
@argument(
    "profile",
    type=DirectoryProfileType(root_only=True),
    help="The profile where to move the recipe",
)
def _move(old, profile):
    """Move a recipe to another profile"""
    move(
        old.location,
        Path(profile.location) / "recipes" / Path(old.location).name,
    )


@recipe.command(handle_dry_run=True)
@argument("src", type=RecipeType(), help="The source recipe name")
@argument("dest", help="The destination recipe name")
def _copy(src, dest):
    """Copy a recipe"""
    if "/" not in dest:
        dest = "{}/{}".format(src.name.split("/")[0], dest)
    new_loc = config.recipe_location(dest)
    if os.path.exists(new_loc):
        raise click.UsageError("{} already exists".format(new_loc))
    copy(src.location, new_loc)


@recipe.command(handle_dry_run=True)
@argument(
    "recipe",
    type=RecipeType(),
    nargs=-1,
    help="The name of the recipes to remove",
)
def remove(recipe):
    """Remove a recipe"""
    for rec in recipe:
        LOGGER.status("Removing {}".format(rec.friendly_name))
        config.get_profile_containing_recipe(rec.name).remove_recipe(rec.name)


@recipe.command(handle_dry_run=True)
@table_fields(choices=["recipe", "set_in", "defined_in", "order"])
@table_format(default="simple")
@Colorer.color_options
@flag(
    "--enabled-only/--not-enabled-only", help="Show only the enabled recipes"
)
@flag(
    "--disabled-only/--not-disabled-only",
    help="Show only the disabled recipes",
)
@option("--order/--no-order", help="Display the priority of the recipe")
@argument(
    "recipes",
    type=RecipeNameType(disabled=True, failok=False),
    nargs=-1,
    help="The names of the recipes to show",
)
def show(
    fields, format, order, recipes, enabled_only, disabled_only, **kwargs
):
    """List the recipes and some info about them"""
    config_recipes = set(config.recipe.readonly.keys())
    avail_recipes = set([r.short_name for r in config.all_recipes])
    if not fields:
        fields = list(get_option_choices("fields"))
        if not order:
            fields.remove("order")

    if not recipes:
        recipes = config_recipes | avail_recipes
    if not recipes:
        LOGGER.status("No recipe yet")
        exit(0)
    with Colorer(kwargs) as colorer, TablePrinter(fields, format) as tp:
        for recipe_name in sorted(recipes):
            profiles = ", ".join(
                [
                    click.style(
                        profile.name, **colorer.get_style(profile.name)
                    )
                    for profile in config.root_profiles
                    if profile.has_recipe(recipe_name)
                ]
            )
            profile = colorer.last_profile_of_settings(
                recipe_name,
                config.recipe.all_settings,
            )
            recipe_enabled = config.is_recipe_enabled(recipe_name)
            if (not enabled_only or recipe_enabled) and (
                not disabled_only or not recipe_enabled
            ):
                profile_style = colorer.get_style(profile) if profile else {}

                tp.echo(
                    click.style(
                        recipe_name, fg="green" if recipe_enabled else "red"
                    ),
                    (profile and click.style(profile, **profile_style))
                    or "Unset",
                    profiles or "Undefined",
                    config.get_recipe_order(recipe_name),
                )


@recipe.command(handle_dry_run=True)
@flag("--all", help="On all recipes")
@argument(
    "recipe",
    type=RecipeNameType(enabled=True, failok=False),
    nargs=-1,
    help="The names of the recipes to disable",
)
@pass_context
def disable(ctx, recipe, all):
    """Don't use this recipe"""
    if all:
        recipe = RecipeType(disabled=True).getchoice(ctx)
    for cmd in recipe:
        if cmd in config.recipe.writable:
            config.recipe.writable[cmd]["enabled"] = False
        else:
            config.recipe.writable[cmd] = {"enabled": False}
        LOGGER.status(
            "Disabling recipe {} in profile {}".format(
                cmd, config.recipe.writeprofile
            )
        )
    config.recipe.write()


@recipe.command(handle_dry_run=True)
@flag("--all", help="On all recipes")
@argument(
    "recipe",
    type=CommandSettingsKeyType("recipe"),
    nargs=-1,
    help="The name of the recipe to unset",
)
@pass_context
def unset(ctx, recipe, all):
    """Don't say whether to use or not this recipe (let the upper profiles decide)"""
    if all:
        recipe = list(config.recipe.readonly.keys())
    for cmd in recipe:
        if cmd not in config.recipe.writable:
            raise click.UsageError(
                "Recipe {} not set in profile {}".format(
                    cmd, config.recipe.writeprofile
                )
            )
    for cmd in recipe:
        del config.recipe.writable[cmd]
        LOGGER.status(
            "Unsetting {} from profile {}".format(
                cmd, config.recipe.writeprofile
            )
        )
    config.recipe.write()


@recipe.command(handle_dry_run=True)
@flag("--all", help="On all recipes")
@option(
    "--only/--no-only",
    help="Use only the provided recipe, and disable the others",
)
@argument(
    "recipe",
    type=RecipeNameType(disabled=True, failok=False),
    nargs=-1,
    help="The names of the recipes to enable",
)
@pass_context
def __enable(ctx, recipe, all, only):
    """Use this recipe"""
    if all:
        recipe = RecipeType(disabled=True).getchoice(ctx)

    if only:
        for cmd in set(RecipeType().getchoice(ctx)) - set(recipe):
            if cmd in config.recipe.writable:
                config.recipe.writable[cmd]["enabled"] = False
            else:
                config.recipe.writable[cmd] = {"enabled": False}
            LOGGER.status(
                "Disabling recipe {} in profile {}".format(
                    cmd, config.recipe.writeprofile
                )
            )

    for cmd in recipe:
        if cmd in config.recipe.writable:
            config.recipe.writable[cmd]["enabled"] = True
        else:
            config.recipe.writable[cmd] = {"enabled": True}
        LOGGER.status(
            "Enabling recipe {} in profile {}".format(
                cmd, config.recipe.writeprofile
            )
        )
    config.recipe.write()


@recipe.command(handle_dry_run=True)
@argument(
    "recipe1",
    type=RecipeNameType(enabled=True, failok=False),
    help="The name of the recipe to disable",
)
@argument(
    "recipe2",
    type=RecipeNameType(disabled=True, failok=False),
    help="The name of the recipe to enable",
)
@pass_context
def switch(ctx, recipe1, recipe2):
    """Switch from a recipe to another"""
    ctx.invoke(disable, recipe=[recipe1])
    ctx.invoke(__enable, recipe=[recipe2])


@recipe.command(handle_dry_run=True)
@argument(
    "recipe",
    type=RecipeNameType(failok=False),
    nargs=-1,
    help="The names of the recipes to which the order will be set",
)
@argument("order", type=int, help="The order to be set on the recipes")
def set_order(recipe, order):
    """Set the order of the recipes"""
    if not recipe:
        recipe = config.all_recipes
    for cmd in recipe:
        if cmd in config.recipe.writable:
            config.recipe.writable[cmd]["order"] = order
        else:
            config.recipe.writable[cmd] = {"order": order}
        LOGGER.status(
            "Set order of {} to {} in profile {}".format(
                cmd, order, config.recipe.writeprofile
            )
        )
    config.recipe.write()


@recipe.command()
@argument(
    "profile",
    type=RecipeType(),
    help="The name of the profile to open",
)
@option(
    "--opener",
    help="Program to call to open the directory",
    default="xdg-open",
)
def open(profile, opener):
    """Open the directory containing the profile"""
    call([opener, profile.location])


@recipe.command()
@argument(
    "profile",
    type=DirectoryProfileType(),
    help="The name of the profile to show",
)
def where_is(profile):
    """Show where is a given recipe"""
    print(profile.location)


@recipe.command()
@option(
    "--profile",
    type=DirectoryProfileType(),
    help="The profile where to install the recipe",
)
@argument(
    "url",
    help=(
        "The url of the git repository hosting the recipe."
        " Can be author/recipe for github repository."
        " If that case, the url will become"
        " https://github.com/{author}/clk_recipe_{recipe}."
        " Actually, the prefix (github.com) may be changed using --url-prefix."
        " Can also be gitlab.com/{author}/{recipe},"
        " github.com/{author}/{recipe},"
        " git@...,"
        " http://...,"
        " a path to a local directory"
        " (not that in that case, using --editable makes sense)."
    ),
)
@option(
    "--url-prefix",
    help="The prefix to insert before the url in needed.",
    type=Suggestion(["github.com", "gitlab.com"]),
    default="github.com",
)
@argument("name", help="The name of the recipe", required=False)
@flag(
    "--install-deps/--no-install-deps",
    help="Automatically install the dependencies.",
    default=True,
)
@flag("--force/--no-force", help="Overwrite the existing recipe if need be.")
@flag(
    "-e",
    "--editable",
    help="(only for local path) Create a symbolic link rather than copying the content",
)
@pass_context
def install(
    ctx, profile, url, name, url_prefix, install_deps, editable, force
):
    """Install a recipe from outside"""
    profile = profile or config.global_profile
    install_type = None
    urls = []
    if re.match("[a-z0-9_]+", url):
        url = f"click-project/{url}"
    if match := re.match("^(?P<author>[a-zA-Z0-9_-]+)/(?P<recipe>[a-zA-Z0-9]+)$", url):
        author = match.group("author")
        recipe = match.group("recipe")
        urls.append(f"https://{url_prefix}/{author}/clk_recipe_{recipe}")
        install_type = "git"
        if name is None:
            name = recipe
    elif m := re.match(
        "^https://github.com/.+/(?P<name>[^/]+)/tarball/.+$", url
    ):
        install_type = "webtar"
        urls.append(url)
        name = name or m["name"]
    elif re.match(
        r"(\w+://)(.+@)*([\w\d\.]+)(:[\d]+)?/*(.*)|(.+@)*([\w\d\.]+):(.*)", url
    ):
        install_type = "git"
        urls.append(url)
    elif url.startswith("http"):
        install_type = "git"
        urls.append(url)
    elif "/" in url:
        # fallback wild guessing it could be a github/gitlab/... url, and try to get
        # it using https and ssh
        LOGGER.info(
            "I don't see what this url is about."
            " I'm wild guessing it might a gitlab/github short url style."
            " In the form [host]/[path], without the initial https://."
        )
        install_type = "git"
        host = url.split("/")[0]
        path = "/".join(url.split("/")[1:])
        urls.append(f"https://{url}")
        urls.append(f"git@{host}:{path}")
    elif Path(url).exists():
        install_type = "file"
        name = name or Path(url).name
        urls.append(url)
    else:
        raise click.UsageError(
            "I tried hard guessing what this url is about, without success."
            " Please take a look at the documentation"
            " to know about the supported formats"
        )
    if editable is True and install_type != "file":
        LOGGER.warning(
            "Ignoring --editable for we guessed that"
            " you did not provide a url that actually"
            " points to a local file"
        )

    if name is None:
        if "/" in url:
            name = url.split("/")[-1]
        else:
            raise click.UsageError(
                "I cannot infer a name for your recipe. Please provide one explicitly."
            )
    if name.startswith("clk_recipe_"):
        name = name.replace("clk_recipe_", "")
    if not re.match(f"^{DirectoryProfile.recipe_name_re}$", name):
        raise click.UsageError(
            f"Invalid recipe name '{name}'."
            " A recipe's name must contain only letters or _"
        )

    if install_type is None:
        raise click.UsageError(
            "I cannot infer how to install the recipe"
            " Please tell us what you wanted to do"
            " so that we can fix the code and the doc."
        )

    recipe_path = (Path(profile.location) / "recipes" / name).resolve()
    if recipe_path.exists() or recipe_path.is_symlink():
        if force:
            rm(recipe_path)
        else:
            if not os.path.exists(f'{recipe_path}/.git'):
                raise click.UsageError(
                    f"A recipe already exists at location {recipe_path}"
                    " Use --force to override it."
                )
    if install_type == "git":
        # check if we already have that recipe locally
        if os.path.exists(f'{recipe_path}/.git'):
            with cd(recipe_path):
                url = check_output(['git', 'remote', 'get-url', 'origin']).strip()
                if url not in urls:
                    LOGGER.debug(f"urls: {urls}")
                    raise click.UsageError(f"Recipe {name} already exists and is not using the same URL: {url}")
                call(['git', 'pull'])
        else:
            ok = False
            for tryurl in urls:
                try:
                    call(["git", "clone", tryurl, str(recipe_path)])
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
            ln(Path(url).resolve(), recipe_path)
        else:
            copy(url, recipe_path)
    elif install_type == "webtar":
        LOGGER.info(f"Getting the tarfile from {url}")
        tar = tarfile.open(fileobj=io.BytesIO(requests.get(url).content))
        tar.extractall(recipe_path)
        for file in glob(f"{recipe_path}/*/*"):
            move(file, recipe_path)

    recipe = profile.get_recipe(name)

    if install_deps is True:
        LOGGER.status("-> Installing the dependencies of the recipe")
        ctx.invoke(_install_deps, recipe=[recipe])
    LOGGER.status(f"Done installing the recipe {name}")


@recipe.command()
@argument(
    "recipe",
    type=DirectoryProfileType(),
    nargs=-1,
    help="The name of the recipes to consider",
)
@pass_context
def _install_deps(ctx, recipe):
    "Install the dependencies of the recipe"
    for rec in recipe:
        LOGGER.status("Handling {}".format(rec.friendly_name))
        if rec.requirements_path.exists():
            ctx.invoke(
                pip, args=("install", "--upgrade", "-r", rec.requirements_path)
            )
        else:
            LOGGER.info(f"Nothing to be done for {rec.friendly_name}")


@recipe.command()
@argument(
    "recipe",
    type=RecipeType(),
    nargs=-1,
    required=True,
    help="The names of the recipes to update",
)
@flag("--clean", "method", flag_value="clean", help="Remove local modification and update")
@flag("--stash", "method", flag_value="stash", help="Stash local modification and update")
@flag("--no-clean", "method", flag_value="no-clean", help="Don't try cleaning the repository before pulling")
def update(recipe, method):
    """Update this cloned recipe"""
    for cmd in recipe:
        root = Path(cmd.location)
        LOGGER.info(f"Updating {cmd.name}")
        if not (root / ".git").exists():
            LOGGER.warning(
                f"I cannot update the recipe {cmd.name}."
                " For the time being, I only can update" " cloned recipes."
            )
            continue
        with cd(root):
            need_stash = False
            if method == "clean":
                call(["git", "clean", "-fd"])
                call(["git", "checkout", "."])
                call(["git", "reset", "--hard", "HEAD"])
            elif method == "stash":
                need_stash = (
                    check_output(split("git status --porcelain --ignore-submodules --untracked-files=no")) != ""
                )
            if need_stash:
                call(split("git stash"))
            call(["git", "pull"])
            if need_stash:
                call(split("git stash pop"))


@recipe.command()
@argument("recipe", type=RecipeType(), help="The recipe to describe")
def describe(recipe):
    """Try to give some insights into the content of the recipe"""
    recipe.describe()
