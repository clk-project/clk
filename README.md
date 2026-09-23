- [Use cases](#d7cb0451-bc8f-42cc-912c-8a46599375a7)
- [In a nutshell](#fe60735c-91c2-4f54-8ae2-7e3b307f27a5)
- [Rationale](#7857f3bb-e4c7-4bad-9e27-ea48bf808a44)
- [Note on version](#8152d0c9-564d-4761-a847-66a40e41aac5)
- [Coverage reports](#a53fa97d-ceb5-44e9-b921-89cf03d2775d)

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
[![CI](https://github.com/clk-project/clk/actions/workflows/ci.yml/badge.svg)](https://github.com/clk-project/clk/actions/workflows/ci.yml)

![Gitter ](https://img.shields.io/gitter/room/clk-project/clk)
![Libera](https://raster.shields.io/badge/libera.chat-%23clk-blue)

Come and discuss clk with us on

-   [#clk on Libera](https://web.libera.chat/?channels)
-   [Gitter](https://gitter.im/clk-project/community)

clk, the **Command Line Kit** is a unique tool that aims to contains everything needed to create human friendly command line tools.

The [rationale](#7857f3bb-e4c7-4bad-9e27-ea48bf808a44) attempts to explain why clk started to exist. You will find in the [use cases](./doc/use_cases/README.md) classical situations where clk is worth being used. In the future, we might write even more [documentation](./doc).


<a id="d7cb0451-bc8f-42cc-912c-8a46599375a7"></a>

# Use cases

This is most likely the most useful part of the documentation. Take a look at the [use cases](./doc/use_cases/README.md) to find out how clk could be used in real life situations.

If you know what you need but not what clk calls it, start here.

-   wrap a tool I already use: [controlling my music](doc/use_cases/controlling_my_music.md)
-   write a small command that takes arguments: [checking my server](doc/use_cases/checking_my_server.md), then [options and flags](doc/use_cases/bash_command_use_option.md)
-   write it in python rather than bash: [python command](doc/use_cases/python_command.md)
-   take a date, said as "yesterday": [finding recent documents](doc/use_cases/finding_recent_documents.md)
-   offer a fixed list of values: [choices](doc/use_cases/choices.md)
-   complete with what exists right now, like the buckets of my account: [cloud provider CLI wrapper](doc/use_cases/wrapping_a_cloud_provider_cli.md)
-   stop typing the same options again and again: [cloud provider CLI wrapper](doc/use_cases/wrapping_a_cloud_provider_cli.md)
-   set one value that many commands read: [setting default values](doc/use_cases/setting_default_values.md)
-   control a command with an environment variable: [controlling a server](doc/use_cases/controlling_a_server_using_an_environment_variable.md), [podcast automation](doc/use_cases/podcast_automation.md)
-   chain steps that depend on each other: [3D printing flow](doc/use_cases/3D_printing_flow.md)
-   have commands that only exist in a project: [using a project](doc/use_cases/using_a_project.md)
-   run the same workflow everywhere, each project doing it its own way: [global workflow, local implementation](doc/use_cases/global_workflow_local_implementation.md)
-   reach the commands of a sibling project without `cd`: [alias to root](doc/use_cases/alias_to_root.md)
-   keep a password out of my scripts: [dealing with secrets](doc/use_cases/dealing_with_secrets.md)
-   fetch some json and show it: [fetching and displaying json data](doc/use_cases/fetching_and_displaying_json_data.md)
-   not fetch the same page twice: [scrapping the web](doc/use_cases/scrapping_the_web.md)
-   clean up what my command set up, even when it fails: [controlling the audio](doc/use_cases/controlling_the_audio.md)
-   call clk from another program that brings its own python libraries: [reading later from qutebrowser](doc/use_cases/reading_later_from_qutebrowser.md)
-   find out why a command is slow: [spotting slow code](doc/use_cases/spotting_slow_code.md)
-   know where a setting comes from: [self documentation](doc/use_cases/self_documentation.md)
-   share my commands with other people: [creating extensions](doc/use_cases/creating_extensions.md)
-   build my own tool, with its own name, on top of clk: [chaotic simulator manager](doc/use_cases/chaotic_simulator_manager.md)
-   see it all put together: [backing up documents](doc/use_cases/backing_up_documents.md)


<a id="fe60735c-91c2-4f54-8ae2-7e3b307f27a5"></a>

# In a nutshell

Install with

```bash
curl -sSL https://clk-project.org/install.sh | bash
```

Update with

```bash
clk update
```

Then wrap the tools you already use, like in [controlling my music](./doc/use_cases/controlling_my_music.md).

Let's imagine you want to use clk to control your musicplayer. Chances are there already exists some command line tool to do so and that you want to wrap it into clk to take advantages of aliases, parameters and flows.

On that case, you most likely will want to create a simple alias on top of exec.

For the sake of this example, let's use this fake music control program and call it 'mpc'.

```bash
if test "$1" = history
then
    printf '%s\n' Kind-of-Blue Bitches-Brew Kind-of-Blue Blue-Train Bitches-Brew
    exit 0
fi
echo "Running mpc with: $*"
```

Then, to use this program as a clk command, we could simply create an alias like this.

```bash
clk alias set music.play exec -- mpc play --random --use-speakers --replaygain
```

    New global alias for music.play: exec mpc play --random --use-speakers --replaygain

Then, we can simple call this command.

```bash
clk music play MyAlbum
```

    Running mpc with: play --random --use-speakers --replaygain MyAlbum

This actually does not tell you much why **clk** is so awesome. Try taking a look, the [use cases](./doc/use_cases/README.md) to get more real life examples.


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

**clk** is quite old, and most of its concepts are stable. There are still a few areas that I want to dig into before starting a v1. For a start, I want to end up describing all the [use cases](./doc/use_cases/README.md) that matter to me before considering it ready.


<a id="a53fa97d-ceb5-44e9-b921-89cf03d2775d"></a>

# Coverage reports

Coverage reports are automatically generated and committed by CI on each push to main.

-   [TestIQ Report](./coverage-reports/testiq-report.md) - Test duplicate/redundancy analysis
-   [Overlap Report](./coverage-reports/overlap.md) - Test coverage overlap analysis
-   [Line Heat Map](./coverage-reports/line-heat.md) - Lines covered by many tests

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> After more than a decade of use, I still have a hard time finding out how to use **find** for non trivial use cases.

<sup><a id="fn.2" class="footnum" href="#fnr.2">2</a></sup> for that reason, clk is also called the \*C\*ognitive \*L\*oad \*K\*iller.
