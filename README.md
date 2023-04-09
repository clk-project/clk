- [In a nutshell](#fe60735c-91c2-4f54-8ae2-7e3b307f27a5)
- [Rationale](#7857f3bb-e4c7-4bad-9e27-ea48bf808a44)

[clk](https://clk-project.org/)
==============================================================================

[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=sqale_index)](https://sonarcloud.io/dashboard?id=clk-project_clk)

[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=vulnerabilities)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=bugs)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=code_smells)](https://sonarcloud.io/dashboard?id=clk-project_clk)

[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=ncloc)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=duplicated_lines_density)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=coverage)](https://sonarcloud.io/dashboard?id=clk-project_clk)

[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=reliability_rating)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=security_rating)](https://sonarcloud.io/dashboard?id=clk-project_clk)

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=clk-project_clk&metric=alert_status)](https://sonarcloud.io/dashboard?id=clk-project_clk)
[![CircleCI](https://circleci.com/gh/clk-project/clk.svg?style=svg)](https://app.circleci.com/pipelines/github/clk-project/clk)

Note: This is a rewrite of the documentation, mostly using org-mode and literate programming. See here for the [old documentation](./README_old).

clk, the **Command Line Kit** is a unique tool that aims to contains everything needed to create human friendly command line tools.


<a id="fe60735c-91c2-4f54-8ae2-7e3b307f27a5"></a>

# In a nutshell

Install with

```bash
curl -sSL https://clk-project.org/install.sh | bash
```

Then create a hello world command with

```bash
clk command create bash hello-world --description "Some simple hello world command" --body 'echo "Hello world"'
```

```bash
clk hello-world
```

    Hello world

This actually does not tell you much why clk is so awesome. I try in [rationale](#7857f3bb-e4c7-4bad-9e27-ea48bf808a44) to explain why clk started to exist. The [use cases](./doc/use_cases) try to show real life examples of situations where clk shines. To get more, take a look at the [documentation](./doc).


<a id="7857f3bb-e4c7-4bad-9e27-ea48bf808a44"></a>

# Rationale

Low level command line tools are very powerful. Yet they are not very intuitive. It takes time to understand **find**, **kill**, **tr**, **awk** or **sed**. We spend a lot of time reading the documentation and the tool itself does not help much.

It looks like a lot of high level command line tools, like **maven** or **npm** have followed the same idea of relying on a comprehensive documentation and leave the tool unhelpful to the user.

Yet, there are a lot a stuffs that the tool can do to help the user, so that the clear documentation is not the only resort.

One awesome command line tool on that matter is **git**. There are semantic completion for almost everything (`git push <tab>` shows the remotes and `git push origin <tab>` shows the branches). You can create aliases to shorten commands you often use. Almost every behavior can be enabled or disabled using config. Most command provide meaningful suggestions of what commands you are likely to want to call next.

The concepts behind git are not that easy and a good and comprehensive documentation is still needed. But git tries its best to be as friendly as possible.

I think that tools like **git** opened my mind and made me realize that command line tools are not necessarily obtuse.

The **Command Line Kit** was started in 2016 out of the frustration of dealing with yet another set of command line tools that provided only the bare minimum that a CLI can provide. That led to very long and hard to understand lines of code to call them.

At that time, I created clk to wrap those tools and provide a nice user experience on top on them.

That's the reason why clk provides out of the box a nice completion framework, aliases and a way to save configuration.

There already exist awesome libraries to create a nice interface, **click** provides an easy way to write the commands, **tqdm** provides nice progress bars, **humanize** helps converting dates and intervals to human readable ones. What clk does is use all that and opinionatedly combines them to create a "batteries included" tool.

Nowadays, I use clk for most of my day to day use, from communicating in slack to fetching rss, to getting my mails or to play music. Under the hood are the classical tools such as flexget, offlineimap or mopidy. They simply are wrapped in a very user friendly overlay.