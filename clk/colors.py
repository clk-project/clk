#!/usr/bin/env python
# -*- coding: utf-8 -*-

from itertools import cycle

import click

from clk.config import config
from clk.core import ColorType
from clk.decorators import flag, option
from clk.lib import clear_ansi_color_codes


class Colorer(object):
    def __init__(self, kwargs):
        self.legend = kwargs.pop('legend')
        self.full = kwargs.pop('full')
        color = kwargs.pop('color')
        if color is False:
            self.legend = False
        self.kwargs = kwargs

        def compute_preset_colors(profile):
            """Return the same colors as the profile, swapping the underline parameter

            For example, if the profile is configured to have underline on, the underlined is off.
            """
            colors = kwargs[f'{profile}_color'].copy()
            colors['underline'] = not colors.get('underline')
            return colors

        self.profile_to_color = {
            name[:-len('_color')].replace('_slash_', '/'): value
            for name, value in kwargs.items()
            if name.endswith('_color')
        }
        if not color:
            for key in self.profile_to_color.copy():
                self.profile_to_color[key] = None
        self.used_profiles = set()

    @property
    def default_profilenames_to_show(self):
        return [profile.name for profile in config.all_enabled_profiles if self.full or profile.explicit]

    def profilenames_to_show(self, profile):
        return [
            profile_.name
            for profile_ in config.all_enabled_profiles
            if profile_.name == profile or profile_.name.startswith(profile + '/')
        ]

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.legend:
            used_profiles = self.used_profiles.copy()
            colored_profiles = self.colorize_values({
                profile: (profile if '-' not in profile else config.get_extension(profile).friendly_name)
                for profile in used_profiles
            })
            message = 'Legend: ' + ', '.join(colored_profiles[profile] for profile in used_profiles)
            click.secho('-' * len(clear_ansi_color_codes(message)), dim=True)
            click.echo(message)

    def last_profile_of_settings(self, name, all_settings):
        for profile in reversed(self.default_profilenames_to_show):
            if profile in all_settings and name in all_settings[profile]:
                return profile

    @classmethod
    def color_options(cls, f=None, full_default=None):
        def decorator(f):
            colors = cycle([
                'fg-yellow',
                'fg-blue',
                'bold-True,fg-yellow',
                'bold-True,fg-blue',
                'bold-True,fg-cyan',
                'bold-True,fg-green',
                'bold-True,fg-magenta',
                'fg-red',
                'bold-True,fg-red',
            ])
            f = flag('--legend/--no-legend',
                     default=config.get_value('config.show.legend', True),
                     help='Start with a legend on colors')(f)
            f = flag('--color/--no-color',
                     default=config.get_value('config.show.color', True),
                     help='Show profiles in color')(f)
            f = flag('--full/--explicit-only',
                     default=config.get_value('config.show.full', full_default),
                     help='Show the full information, even those guessed from the context')(f)
            shortname_color = {}

            for profile in config.all_enabled_profiles:
                if profile.default_color is None:
                    if profile.short_name not in shortname_color:
                        shortname_color[profile.short_name] = next(colors)
                    default_color = shortname_color[profile.short_name]
                else:
                    default_color = profile.default_color
                f = option(f'--{profile.name.replace("/", "-")}-color',
                           f"""{profile.name.replace("/", "_slash_")}_color""",
                           help=f'Color to show the {profile.name} profile',
                           type=ColorType(),
                           default=default_color)(f)
            return f

        if f is None:
            return decorator
        else:
            return decorator(f)

    def apply_color(self, string, profile):
        return click.style(string, **self.get_style(profile))

    def echo(self, message, profile):
        click.echo(self.apply_color(message, profile))

    def get_style(self, profile):
        self.used_profiles.add(profile)
        style = config.alt_style.copy()
        style.update(self.profile_to_color[profile] or {})
        return style

    def colorize_values(self, elems, profiles=None):
        return {
            profile: click.style(elem, **self.get_style(profile)) if elem else elem
            for profile, elem in elems.items()
            if profiles is None or profile in profiles
        }

    def colorize(self, values, readprofile):
        args = []
        readprofiles = self.default_profilenames_to_show
        if readprofile != 'context':
            readprofiles = self.profilenames_to_show(readprofile)
        else:
            readprofiles = self.default_profilenames_to_show
        args = [value for value in self.colorize_values(values, readprofiles).values() if value]
        return args
