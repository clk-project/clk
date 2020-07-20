#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import os
import json

import click

from click_project.decorators import group, option, argument, use_settings, flag, \
    pass_context, settings_stores, table_fields, table_format
from click_project.completion import startswith
from click_project.log import get_logger
from click_project.config import config
from click_project.colors import Colorer
from click_project.lib import move, copy, ParameterType, json_file,\
    json_dumps, rm, call, cd, get_option_choices
from click_project.lib import TablePrinter, get_authenticator
from click_project.overloads import CommandSettingsKeyType

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
            recipes = (
                list(config.all_disabled_recipes) +
                list(config.all_unset_recipes)
            )
        else:
            recipes = config.all_recipes
        return [
            recipe.short_name
            for recipe in recipes
        ]

    def complete(self, ctx, incomplete):
        choice = self.getchoice(ctx)
        return [(recipe, load_short_help(recipe))
                for recipe in choice
                if startswith(recipe, incomplete)]


class AllRecipeNameType(RecipeNameType):
    def getchoice(self, ctx):
        return super(AllRecipeNameType, self).getchoice(ctx) + [
            n
            for p in config.root_profiles
            for n in p.recipe_link_names
        ]


class RecipeLinkNameType(ParameterType):
    def getchoice(self, ctx):
        return settings_stores["recipe"].profile.recipe_link_names

    def complete(self, ctx, incomplete):
        choice = self.getchoice(ctx)
        return [(recipe, load_short_help(recipe))
                for recipe in choice
                if startswith(recipe, incomplete)]


class RecipeType(RecipeNameType):
    def convert(self, value, param, ctx):
        choice = self.getchoice(ctx)
        if value not in choice and self.failok:
            self.fail('invalid choice: %s. (choose from %s)' %
                      (value, ', '.join(choice)), param, ctx)
        profile = settings_stores["recipe"].profile
        return profile.get_recipe(value)


def load_short_help(recipe):
    return recipe


@group(default_command='show')
@use_settings("recipe", RecipeConfig)
def recipe():
    """Recipe related commands

    A recipe is a set of settings that may be activated or disactivated in a project.
    The recipes can be defined at the global or local profile."""
    pass


@recipe.command(handle_dry_run=True)
@argument("name", help="The recipe name")
def create(name):
    """Create a new recipe"""
    profile = config.recipe.profile
    r = profile.create_recipe(name)
    LOGGER.status(
        "Created recipe {}.".format(
            r.friendly_name
        ))


@recipe.command(handle_dry_run=True)
@argument("old", type=RecipeType(), help="The current recipe name")
@argument("new", help="The new recipe name")
def rename(old, new):
    """Rename a recipe"""
    if "/" not in new:
        new = "{}/{}".format(
            old.name.split("/")[0],
            new
        )
    new_loc = config.recipe_location(new)
    if os.path.exists(new_loc):
        raise click.UsageError("{} already exists".format(new_loc))
    move(old.location, new_loc)


@recipe.command(handle_dry_run=True)
@argument("src", type=RecipeType(), help="The source recipe name")
@argument("dest", help="The destination recipe name")
def _copy(src, dest):
    """Copy a recipe"""
    if "/" not in dest:
        dest = "{}/{}".format(
            src.name.split("/")[0],
            dest
        )
    new_loc = config.recipe_location(dest)
    if os.path.exists(new_loc):
        raise click.UsageError("{} already exists".format(new_loc))
    copy(src.location, new_loc)


@recipe.command(handle_dry_run=True)
@argument("recipe", type=RecipeType(), nargs=-1, help="The name of the recipes to remove")
def remove(recipe):
    """Remove a recipe"""
    for rec in recipe:
        LOGGER.status("Removing {}".format(rec.friendly_name))
        config.get_profile_containing_recipe(rec.name).remove_recipe(rec.name)


@recipe.command(handle_dry_run=True)
@table_fields(choices=['recipe', "set_in", "defined_in", "link", "order"])
@table_format(default='simple')
@Colorer.color_options
@flag("--link/--no-link", help="Show links also", default=False)
@flag("--enabled-only/--not-enabled-only", help="Show only the enabled recipes")
@flag("--disabled-only/--not-disabled-only", help="Show only the disabled recipes")
@option('--order/--no-order', help="Display the priority of the recipe")
@argument('recipes', type=RecipeNameType(disabled=True, failok=False), nargs=-1,
          help="The names of the recipes to show")
def show(fields, format, link, order, recipes, enabled_only, disabled_only, **kwargs):
    """List the recipes and some info about them"""
    config_recipes = set(config.recipe.readonly.keys())
    avail_recipes = set([r.short_name for r in config.all_recipes])
    if not fields:
        fields = list(get_option_choices('fields'))
        if not link:
            fields.remove('link')
        if not order:
            fields.remove('order')

    if not recipes:
        for profile in config.root_profiles:
            config_recipes |= profile.recipe_link_names
        recipes = config_recipes | avail_recipes
    if not recipes:
        LOGGER.status("No recipe yet")
        exit(0)
    with Colorer(kwargs) as colorer, TablePrinter(fields, format) as tp:
        for recipe_name in sorted(recipes):
            profiles = ", ".join([
                click.style(profile.name, **colorer.get_style(profile.name))
                for profile in config.root_profiles
                if profile.has_recipe(recipe_name)
                ])
            link_profiles = ", ".join([
                profile.name
                for profile in config.root_profiles
                if profile.has_recipe_link(recipe_name)
                ])
            profile = colorer.last_profile_of_settings(
                recipe_name,
                config.recipe.all_settings,
            )
            recipe_enabled = config.is_recipe_enabled(recipe_name)
            if (
                    (
                        not enabled_only or
                        recipe_enabled
                    ) and
                    (
                        not disabled_only or
                        not recipe_enabled
                    )
            ):
                profile_style = colorer.get_style(profile) if profile else {}

                tp.echo(
                    click.style(recipe_name, fg = "green" if recipe_enabled else "red"),
                    (profile and click.style(profile, **profile_style)) or "Unset",
                    profiles or "Undefined",
                    link_profiles,
                    config.get_recipe_order(recipe_name),
                )


@recipe.command(handle_dry_run=True)
@flag("--all", help="On all recipes")
@argument("recipe", type=RecipeNameType(enabled=True, failok=False), nargs=-1,
          help="The names of the recipes to disable")
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
        LOGGER.status("Disabling recipe {} in profile {}".format(cmd, config.recipe.writeprofile))
    config.recipe.write()


@recipe.command(handle_dry_run=True)
@flag("--all", help="On all recipes")
@argument("recipe", type=CommandSettingsKeyType("recipe"), nargs=-1, help="The name of the recipe to unset")
@pass_context
def unset(ctx, recipe, all):
    """Don't say whether to use or not this recipe (let the upper profiles decide)"""
    if all:
        recipe = list(config.recipe.readonly.keys())
    for cmd in recipe:
        if cmd not in config.recipe.writable:
            raise click.UsageError(
                "Recipe {} not set in profile {}".format(
                    cmd,
                    config.recipe.writeprofile
                )
            )
    for cmd in recipe:
        del config.recipe.writable[cmd]
        LOGGER.status("Unsetting {} from profile {}".format(cmd, config.recipe.writeprofile))
    config.recipe.write()


@recipe.command(handle_dry_run=True)
@flag("--all", help="On all recipes")
@option('--only/--no-only', help="Use only the provided recipe, and disable the others")
@argument("recipe", type=RecipeNameType(disabled=True, failok=False), nargs=-1,
          help="The names of the recipes to enable")
@pass_context
def enable(ctx, recipe, all, only):
    """Use this recipe"""
    if all:
        recipe = RecipeType(disabled=True).getchoice(ctx)

    if only:
        for cmd in set(RecipeType().getchoice(ctx)) - set(recipe):
            if cmd in config.recipe.writable:
                config.recipe.writable[cmd]["enabled"] = False
            else:
                config.recipe.writable[cmd] = {"enabled": False}
            LOGGER.status("Disabling recipe {} in profile {}".format(cmd, config.recipe.writeprofile))

    for cmd in recipe:
        if cmd in config.recipe.writable:
            config.recipe.writable[cmd]["enabled"] = True
        else:
            config.recipe.writable[cmd] = {"enabled": True}
        LOGGER.status("Enabling recipe {} in profile {}".format(cmd, config.recipe.writeprofile))
    config.recipe.write()

@recipe.command(handle_dry_run=True)
@argument("recipe1", type=RecipeNameType(enabled=True, failok=False),
          help="The name of the recipe to disable")
@argument("recipe2", type=RecipeNameType(disabled=True, failok=False),
          help="The name of the recipe to enable")
@pass_context
def switch(ctx, recipe1, recipe2):
    """Switch from a recipe to another"""
    ctx.invoke(disable, recipe=[recipe1])
    ctx.invoke(enable, recipe=[recipe2])


@recipe.command(handle_dry_run=True)
@argument("recipe", type=RecipeNameType(failok=False), nargs=-1,
          help="The names of the recipes to which the order will be set")
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
        LOGGER.status("Set order of {} to {} in profile {}".format(cmd, order, config.recipe.writeprofile))
    config.recipe.write()


@recipe.group(default_command="show")
def link():
    """Manipulate recipes link"""


link.inherited_params = ["profile", "recipe"]


@link.command()
@argument("recipes", type=AllRecipeNameType(), nargs=-1, help="The names of the recipes to enable")
def _enable(recipes):
    """Enable the given recipe in the link"""
    for recipe in recipes:
        with json_file(
                config.recipe.profile.link_location(recipe)
        ) as values:
            values["enabled"] = True
        LOGGER.status("Enabling the link file of {} ({})".format(recipe, config.recipe.writeprofile))


@link.command()
@argument("recipes", type=AllRecipeNameType(), nargs=-1, help="The names of the recipes to enable")
def _disable(recipes):
    """Disable the given recipe in the link"""
    for recipe in recipes:
        with json_file(
                config.recipe.profile.link_location(recipe)
        ) as values:
            values["enabled"] = False
        LOGGER.status("Disabling the link file of {} ({})".format(recipe, config.recipe.writeprofile))


@link.command()
@argument("recipe", type=RecipeNameType(), help="The name of the recipe to dump")
def _dump(recipe):
    """Show the values of the link file"""
    with json_file(
            config.recipe.profile.link_location(recipe)
    ) as values:
        click.echo(json_dumps(values))


@link.command()
@Colorer.color_options
def _show(**kwargs):
    """Link the list recipes"""
    with Colorer(kwargs) as colorer:
        for profile in config.root_profiles:
            for name in profile.recipe_link_names:
                message = name
                enabled = profile.recipeislinkenabled(name)

                message += " ({})".format(
                    {
                        True: "enabled",
                        False: "disabled",
                        None: "implicitly disabled"
                    }[enabled]
                )
                colorer.echo(message, profile.name)


@link.command()
@argument("recipes", type=RecipeLinkNameType(), help="The names of the recipes to unset")
def _unset(recipes):
    """Remove the the link file"""
    for recipe in recipes:
        rm(config.recipe.profile.link_location(recipe))
        LOGGER.status("Removing the link file of {} ({})".format(recipe, config.recipe.writeprofile))
