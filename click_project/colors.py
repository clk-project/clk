#!/usr/bin/env python
# -*- coding:utf-8 -*-

from __future__ import print_function, absolute_import

import collections
from itertools import cycle

import click

from click_project.decorators import flag, option
from click_project.config import config
from click_project.lib import clear_ansi_color_codes
from click_project.core import ColorType


class Colorer(object):

    def __init__(self, kwargs):
        with_legend = kwargs.pop("with_legend")
        self.legend = kwargs.pop("legend")
        self.full = kwargs.pop("full")
        self.legend = self.legend or with_legend
        color = kwargs.pop("color")
        if color is False:
            self.legend = False
        self.kwargs = kwargs

        def compute_preset_colors(level):
            """Return the same colors as the level, swapping the underline parameter

            For example, if the level is configured to have underline on, the underlined is off.
            """
            colors = kwargs[f"{level}_color"].copy()
            colors["underline"] = not colors.get("underline")
            return colors

        self.level_to_color = collections.defaultdict(dict)
        self.level_to_color["global"] = kwargs["global_color"]
        self.level_to_color["global/preset"] = compute_preset_colors("global")
        if config.local_profile:
            self.level_to_color["workgroup"] = kwargs.get("workgroup_color")
            self.level_to_color["workgroup/preset"] = compute_preset_colors("workgroup")
            self.level_to_color["local"] = kwargs.get("local_color")
            self.level_to_color["local/preset"] = compute_preset_colors("local")
        for recipe in config.all_recipes:
            self.level_to_color[recipe.name] = kwargs[
                recipe.name.replace("/", "_") + "_color"
            ]
        self.level_to_color["env"] = {"bold": True}
        if not color:
            for key in self.level_to_color.copy():
                self.level_to_color[key] = None
        self.used_levels = set()

    @property
    def levels_to_show(self):
        return [
            level for level in config.all_levels
            if self.full or (level not in config.implicit_levels)
        ]

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.legend:
            colored_levels = self.colorize_values(
                {
                    level: (
                        level
                        if "-" not in level
                        else config.get_recipe(level).friendly_name
                    )
                    for level in self.levels_to_show
                }
            )
            message = "Legend: " + ", ".join(
                colored_levels[level]
                for level in self.levels_to_show
                if level in self.used_levels
            )
            click.secho("-" * len(clear_ansi_color_codes(message)), dim=True)
            click.echo(message)

    def last_level_of_settings(self, name, all_settings):
        for level in reversed(self.levels_to_show):
            if level in all_settings and name in all_settings[level]:
                return level

    @staticmethod
    def color_options(f):
        colors = cycle([
            "fg-yellow",
            "fg-blue",
            "bold-True,fg-yellow",
            "bold-True,fg-blue",
            "bold-True,fg-cyan",
            "bold-True,fg-green",
            "bold-True,fg-magenta",
            "fg-red",
            "bold-True,fg-red",
        ])
        f = flag("--with-legend/--without-legend", help="Start with a legend on colors",
                 deprecated="please use --legend instead")(f)
        f = flag("--legend/--no-legend",
                 default=config.get_value('config.color.legend') or False,
                 help="Start with a legend on colors")(f)
        f = flag('--color/--no-color', default=True, help="Show levels in color")(f)
        f = flag('--full', help="Show the full information, even those guessed from the context")(f)
        f = option('--global-color', help="Color to show the global level",
                   type=ColorType(), default="fg-cyan")(f)
        recipename_color = {}
        if config.project:
            f = option('--workgroup-color', help="Color to show the workgroup level",
                       type=ColorType(), default="fg-magenta")(f)
            f = option('--local-color', help="Color to show the local level",
                       type=ColorType(), default="fg-green")(f)
        for recipe in config.all_recipes:
            if recipe.short_name not in recipename_color:
                recipename_color[recipe.short_name] = next(colors)
            f = option('--{}-color'.format(recipe.name.replace('/', '-')), help="Color to show the {} level".format(recipe.name),
                       type=ColorType(), default=recipename_color[recipe.short_name])(f)
        return f

    def apply_color(self, string, level):
        return click.style(string, **self.get_style(level))

    def echo(self, message, level):
        click.echo(self.apply_color(message, level))

    def get_style(self, level):
        self.used_levels.add(level)
        style = config.alt_style.copy()
        style.update(self.level_to_color[level] or {})
        return style

    def colorize_values(self, elems):
        return {
            level:
            click.style(elem, **self.get_style(level)) if elem else elem
            for level, elem in elems.items()
        }

    def colorize(self, values, readlevel):
        args = []
        values = self.colorize_values(values)
        if readlevel == "context":
            args = self.combine(values)
        else:
            readlevels = [readlevel] + [
                rl for rl in self.levels_to_show
                if rl.startswith(readlevel + "-")
            ]
            args = self.combine(
                {
                    rl: values[rl]
                    for rl in readlevels
                })
        return args

    def combine(self, values):
        args = []
        for level_name in self.levels_to_show:
            value = values.get(level_name)
            if value:
                args.append(value)
        return args
