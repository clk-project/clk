- [Describing the global profile](#org2707ea5)
- [Describing a local project](#org8cd38a8)
- [Describing an extension](#org45c7061)
- [Comparing profiles](#org5f7b294)
- [Discovering custom commands](#orge37b19f)
- [Summary](#orga0f2837)

When you start using clk extensively, you might end up with many [aliases](bash_command_from_alias.md), [parameters](setting_default_values.md), [commands](bash_command.md), and [extensions](creating_extensions.md) spread across different profiles. The `clk describe` command helps you discover what features are available in any profile, making clk a self-documented tool.

This is particularly useful when:

-   you come back to a [project](using_a_project.md) after some time and forgot what commands you created,
-   you want to explore what an extension provides before enabling it,
-   you want to understand what configuration exists at different levels (global vs local).


<a id="org2707ea5"></a>

# Describing the global profile

The global profile contains your personal configuration that applies everywhere. Let's set up some global configuration first.

```bash
clk alias set hello echo Hello
clk parameter set echo --no-newline
```

    New global alias for hello: echo Hello
    New global parameters for echo: --no-newline

Now let's describe the global profile to see what it contains.

```bash
clk describe global
```

    The extension global is located at ./clk-root . Let's try to see what it has to offer.
    ##########
    I found some alias, try running `clk alias --global show` to know more.
    I found some parameter, try running `clk parameter --global show` to know more.
    I found some value, try running `clk value --global show` to know more.

The `clk describe` command tells you exactly what commands to run to explore further. Let's follow its suggestions.

```bash
clk alias --global show
```

    hello echo Hello

```bash
clk parameter --global show | grep echo
```

    echo --no-newline


<a id="org8cd38a8"></a>

# Describing a local project

When working in a project (a directory with a `.clk` folder), the local profile holds project-specific configuration. Let's create a project and add some local configuration.

```bash
mkdir myproject && cd myproject && mkdir .clk
```

```bash
clk alias set build echo Building the project
clk alias set test echo Running tests
clk parameter set build --verbose
```

    New local alias for build: echo Building the project
    New local alias for test: echo Running tests
    New local parameters for build: --verbose

Now let's describe the local profile.

```bash
clk describe local
```

    The extension local is located at ./.clk . Let's try to see what it has to offer.
    ##########
    I found some alias, try running `clk alias --local show` to know more.
    I found some parameter, try running `clk parameter --local show` to know more.

This helps you quickly understand what's configured specifically for this project.

```bash
clk alias --local show
```

    build echo Building the project
    test echo Running tests


<a id="org45c7061"></a>

# Describing an extension

Extensions are reusable configurations that can be enabled or disabled. They're great for grouping related functionality. Let's create an extension with some commands and configuration.

```bash
clk extension create mytools
clk alias set --extension mytools greet echo Greetings
```

    New local/mytools alias for greet: echo Greetings

```bash
clk command create --extension mytools bash --description "Show current date and time" --body 'date' now
```

Now let's describe this extension to see what it provides.

```bash
clk describe local/mytools
```

    The extension local/mytools is located at ./.clk/extensions/mytools . Let's try to see what it has to offer.
    ##########
    I found some alias, try running `clk --extension mytools alias --local --extension mytools show` to know more.
    I found some executable commands, try running `clk --extension mytools command --local --extension mytools list` to know more.

Let's follow these suggestions.

```bash
clk --extension mytools alias --local --extension mytools show
```

    greet echo Greetings

```bash
clk --extension mytools command --local --extension mytools list
```

    ./.clk/extensions/mytools/bin/now

This is especially useful when you receive an extension from someone else or when you want to remember what you put in an extension you created a while ago.


<a id="org5f7b294"></a>

# Comparing profiles

A powerful pattern is to use `clk describe` on different profiles to understand where configuration comes from. When a command behaves unexpectedly, you can check each level.

```bash
clk describe global
clk describe local
```

This helps you understand the layered configuration: global settings provide defaults, while local settings can override them for specific projects.


<a id="orge37b19f"></a>

# Discovering custom commands

When you or your team create custom bash or python commands, `clk describe` will detect them too.

```bash
clk command create bash --description "Deploy the application" --body 'echo Deploying...' deploy
```

```bash
clk describe local
```

    The extension local is located at ./.clk . Let's try to see what it has to offer.
    ##########
    I found some alias, try running `clk alias --local show` to know more.
    I found some parameter, try running `clk parameter --local show` to know more.
    I found some executable commands, try running `clk command --local list` to know more.

```bash
clk command --local list
```

    ./.clk/bin/deploy


<a id="orga0f2837"></a>

# Summary

The `clk describe` command is your entry point for exploring any profile's configuration. It provides actionable suggestions for diving deeper into:

-   **aliases**: shortcuts for frequently used commands
-   **parameters**: default options for commands
-   **executable commands**: custom bash or python commands
-   **flowdeps and triggers**: workflow automation settings
-   **values**: semantic configuration settings
-   **environment variables**: environment customization
-   **plugins**: advanced behavior modifications

This self-documentation capability means you can always find your way around clk's configuration, whether you're exploring your own setup after some time away, or understanding a configuration shared by a colleague.
