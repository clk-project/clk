#!/usr/bin/env python
# -*- coding:utf-8 -*-

import versioneer
from setuptools import setup, find_packages

versions = versioneer.get_versions()
version = versions["version"]
if version == u"0+unknown":
    version = u"sha:{}".format(versions["full-revisionid"])

cmdclass = versioneer.get_cmdclass()

setup(
    name='click_project',
    cmdclass=cmdclass,
    version=version,
    author='Samuel Loury',
    author_email='konubinixweb@gmail.com',
    description='A framework to help you have an awesome CLI',
    packages=find_packages(),
    zip_safe=False,
    install_requires=[
        "click>=6.4",
        "click-log",
        "click-didyoumean",
        "click-completion>=0.3.0",
        "six",
        "glob2",
        "colorama",
        "python-dateutil",
        "keyring",
        "psutil==5.0.0",
        "tabulate",
        "networkx",
        "pydotplus",
        "pluginbase",
        # cryptography is pinned so that we are not bothered by it very frequent
        # updates
        "cryptography==2.1.2",
        "appdirs",
        "ipdb",
        "humanize",
        "ipython<6",
        "Pygments",
    ],
)
