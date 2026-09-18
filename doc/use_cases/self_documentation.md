- [Describing the global profile](#describing-the-global-profile)
- [Describing a local project](#describing-a-local-project)
- [Describing an extension](#describing-an-extension)
- [Comparing profiles](#comparing-profiles)
- [Discovering custom commands](#discovering-custom-commands)
- [Coming back to a project you forgot](#coming-back-to-a-project-you-forgot)
- [Settings clk does not know](#settings-clk-does-not-know)
- [Summary](#summary)

When you start using clk extensively, you might end up with many [aliases](bash_command_from_alias.md), [parameters](setting_default_values.md), [commands](bash_command.md), and [extensions](creating_extensions.md) spread across different profiles. The `clk describe` command helps you discover what features are available in any profile, making clk a self-documented tool.

This is particularly useful when:

-   you come back to a [project](using_a_project.md) after some time and forgot what commands you created,
-   you want to explore what an extension provides before enabling it,
-   you want to understand what configuration exists at different levels (global vs local).


<a id="describing-the-global-profile"></a>

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
    I found some alias:
      hello: echo Hello
    I found some parameter:
      echo: --no-newline

It says what it found, and the usual show commands remain there when you want them on their own.

```bash
clk alias --global show
```

    hello echo Hello

```bash
clk parameter --global show | grep echo
```

    echo --no-newline


<a id="describing-a-local-project"></a>

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
    I found some alias:
      build: echo Building the project
      test: echo Running tests
    I found some parameter:
      build: --verbose

This helps you quickly understand what's configured specifically for this project.

```bash
clk alias --local show
```

    build echo Building the project
    test echo Running tests


<a id="describing-an-extension"></a>

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
    I found some alias:
      greet: echo Greetings
    I found some commands:
      now

Which is the answer you wanted. The show commands are still there for the detail.

```bash
clk --extension mytools alias --local --extension mytools show
```

    greet echo Greetings

```bash
clk --extension mytools command --local --extension mytools list
```

    ./.clk/extensions/mytools/bin/now

This is especially useful when you receive an extension from someone else or when you want to remember what you put in an extension you created a while ago.


<a id="comparing-profiles"></a>

# Comparing profiles

A powerful pattern is to use `clk describe` on different profiles to understand where configuration comes from. When a command behaves unexpectedly, you can check each level.

```bash
clk describe global
clk describe local
```

This helps you understand the layered configuration: global settings provide defaults, while local settings can override them for specific projects.


<a id="discovering-custom-commands"></a>

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
    I found some alias:
      build: echo Building the project
      test: echo Running tests
    I found some parameter:
      build: --verbose
    I found some commands:
      deploy

```bash
clk command --local list
```

    ./.clk/bin/deploy


<a id="coming-back-to-a-project-you-forgot"></a>

# Coming back to a project you forgot

A project is never only aliases and commands. Over the weeks you also set a [value](setting_default_values.md) your commands read at run time, and you switched off an extension you had had enough of.

```bash
clk value set deploy-target staging
clk extension disable mytools
```

Come back to the project months later, having forgotten all of it, and one describe hands you the lot.

```bash
clk describe local
```

    The extension local is located at ./.clk . Let's try to see what it has to offer.
    ##########
    I found some alias:
      build: echo Building the project
      test: echo Running tests
    I found some parameter:
      build: --verbose
    I found some value:
      deploy-target: staging
    I found some extension:
      mytools: disabled
    I found some commands:
      deploy

Read it from the top and the project comes back to you: `build` and `test` are the shortcuts you wrote, `build` always runs verbose because you got tired of adding the option, `deploy-target` is what your deploy reads to know it goes to staging, and `deploy` is a script living in the project. As for `mytools`, it is still there and merely not loaded, which is the answer the day you go looking for a command that seems to have gone missing.


<a id="settings-clk-does-not-know"></a>

# Settings clk does not know

Something else may have written in that file: a tool of yours, an older clk, a hand that slipped.

```bash
cat<<EOF >> .clk/clk.yaml
weather:
  today: rainy
EOF
```

describe does not pretend it is not there.

```bash
clk describe local | tail -2
```

      deploy
    I also found some settings that I cannot explain: weather. They might have been set by other plugins, custom commands or extensions.


<a id="summary"></a>

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
