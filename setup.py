#!/usr/bin/env python

from setuptools import find_packages, setup

import fasterentrypoint  # NOQA: For side effects only
import versioneer

versions = versioneer.get_versions()
version = versions["version"]
if version == "0+unknown":
    if versions["full-revisionid"] is None:
        version = "0.0.0-dev"
    else:
        version = "sha:{}".format(versions["full-revisionid"])

cmdclass = versioneer.get_cmdclass()

setup(
    name="clk",
    cmdclass=cmdclass,
    version=version,
    author="Samuel Loury",
    author_email="konubinixweb@gmail.com",
    description="A framework to help you have an awesome CLI",
    packages=find_packages(),
    long_description="See https://clk-project.org/ or https://github.com/clk-project/clk",
    zip_safe=False,
    python_requires=">=3.8",
    include_package_data=True,
    install_requires=[
        "click>=8,<8.2",
        "click-log",
        "click-didyoumean",
        "glob2",
        "colorama",
        "python-dateutil",
        "tabulate==0.8.10",
        "networkx",
        "parsedatetime",
        "pydotplus",
        "pluginbase",
        "appdirs",
        "ipdb",
        "humanize==4",
        "Pygments",
        "cached-property",
        "requests",
        "tqdm",
    ],
    entry_points={
        "console_scripts": [
            "clk=clk.main:main",
        ]
    },
)
