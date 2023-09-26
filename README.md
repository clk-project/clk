- [In a nutshell](#fe60735c-91c2-4f54-8ae2-7e3b307f27a5)
- [Rationale](#7857f3bb-e4c7-4bad-9e27-ea48bf808a44)
- [Note on version](#8152d0c9-564d-4761-a847-66a40e41aac5)

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

Come and discuss clk with us on

-   [[IRC libera.chat #clk](https://raster.shields.io/badge/libera.chat-%23clk-blue)](<https://web.libera.chat/?channels>
-   [[Gitter](https://badges.gitter.im/clk-project/community.svg)

clk, the **Command Line Kit** is a unique tool that aims to contains everything needed to create human friendly command line tools.

The [rationale](#7857f3bb-e4c7-4bad-9e27-ea48bf808a44) attempts to explain why clk started to exist. You will find in the [use cases](./doc/use_cases) classical situations where clk is worth being used. In the future, we might write even more [documentation](./doc).


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

This actually does not tell you much why **clk** is so awesome. Try taking a look, the [use cases](./doc/use_cases) to get more real life examples.


<a id="7857f3bb-e4c7-4bad-9e27-ea48bf808a44"></a>

# Rationale

Low level command line tools are very powerful. Yet they are not very intuitive. It takes time to understand those like **find**, **kill**, **tr**, **awk** or **sed**. We spend a lot of time reading the documentation and the tool itself does not help much<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>.

It looks like a lot of high level command line tools, like **maven** or **npm** have followed the same idea of relying on a comprehensive documentation and do not provide a friendly user experience.

Yet, there are a lot a stuffs that the command line tool itself can do to become less a burden and more a partner.

One awesome command line tool on that matter is **git**. There are semantic completion for almost everything (`git push <tab>` shows the remotes and `git push origin <tab>` shows the branches). You can create aliases to shorten commands you often use. Almost every behavior can be enabled or disabled using config. Most commands provide meaningful suggestions of what commands you are likely to want to call next.

The concepts behind **git** are not that easy and a good and comprehensive documentation is still needed. But **git** tries its best to be as friendly as possible anyway.

I think that tools like **git** opened my mind and made me realize that command line tools are not necessarily obtuse.

The **Command Line Kit** was started in 2016 out of the frustration of dealing with yet another set of command line tools that provided only the bare minimum that a CLI can provide.

In my mind, the authors of those tools did not willingly create obtuse tools. They most likely could not afford the cognitive load of having to thing about such "non functional" feature.

For that reason, **clk** provides out of the box a nice completion framework, aliases and a way to save configuration, so that when writing my command line tools, I don't have to think about them. They are automatically there<sup><a id="fnr.2" class="footref" href="#fn.2" role="doc-backlink">2</a></sup>.

There already exist awesome libraries to create nice command line interfaces. **click** provides an easy way to write the commands, **tqdm** provides nice progress bars, **humanize** helps converting dates and intervals to human readable ones. What **clk** does is use all that and opinionatedly combines them to create a "batteries included" tool.

Nowadays, I use **clk** for most of my day to day use, from communicating in slack to fetching rss, to getting my mails or to play music. Under the hood, I use the classical tools such as flexget, offlineimap or mopidy. They simply are wrapped in a very user friendly overlay.


<a id="8152d0c9-564d-4761-a847-66a40e41aac5"></a>

# Note on version

**clk** is quite old, and most of its concepts are stable. There are still a few areas that I want to dig into before starting a v1. For a start, I want to end up describing all the [use cases](./doc/use_cases) that matter to me before considering it ready.

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> After more than a decade of use, I still have a hard time finding out how to use **find** for non trivial use cases.

<sup><a id="fn.2" class="footnum" href="#fnr.2">2</a></sup> for that reason, clk is also called the \*C\*ognitive \*L\*oad \*K\*iller.