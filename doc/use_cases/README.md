- [bash commands](#932f47a6-803b-40df-ba30-ac437aac92e2)
- [python commands](#python-commands)
- [parameters, alias etc](#fa3df212-fc5f-4c3e-9e3e-3f71e897c9b1)
- [how to structure your commands](#6abcb030-192b-4c73-a62f-4551d1e92a77)
  - [commands as first order objects](#d82b6533-b098-43e7-b4b8-30e283419b9b)
- [batteries included](#3a184190-e5cb-4e8b-bf5a-177b8ec9ec66)
- [project](#57153b01-e474-42f0-baa2-26b1b1611ae7)
- [flow](#8ad4d10e-1ece-45ef-a558-905b5996ddc4)
- [real world example: backing up documents](#backing-up-documents)
- [is it a tool or a library?](#f291ada8-c504-4624-baa7-9c7d600d5c53)
- [publish my code](#875fe27e-ca39-4733-a459-e2a35bcfa124)
- [plugins](#fbe30b36-5265-4690-abfd-1eb12e333f01)

Here are some use cases that hopefully will have the following properties:

-   provide a better idea of what clk is capable of than a simple description,
-   show some common pattern that emerged when using clk,
-   give examples of real life uses of clk, giving hints about when it might be useful,


<a id="932f47a6-803b-40df-ba30-ac437aac92e2"></a>

# bash commands

The basics are covered [here](bash_command.md). To get more into how to provide parameters to your command, read [that one](bash_command_use_option.md). If your parameters are too complicated to be simply parsed, follow the idea of this [use case](send_sms.md).

If you find out that your bash command starts to become quite big, read [this](bash_command_import.md) to find out how to split your code.

Most of my bash commands start with simple aliases. You can read more about this way of thinking in [here](bash_command_from_alias.md).


<a id="python-commands"></a>

# python commands

The basics of creating python commands are covered [here](python_command.md). For more advanced patterns involving dynamic parameters and exposed classes, see the section on [how to structure your commands](#6abcb030-192b-4c73-a62f-4551d1e92a77).


<a id="fa3df212-fc5f-4c3e-9e3e-3f71e897c9b1"></a>

# parameters, alias etc

Sometimes, you might want to have some control about how the arguments of the command lines are evaluated, take a look at [this use case](controlling_a_server_using_an_environment_variable.md) to know more about them.

If you want to share configuration between a Python group and its bash subcommands through environment variables, see the [multi-environment deployment tool](multi_environment_deployment_tool.md) example.

For an example of using aliases with templated environment variables to create flexible workflows, see the [podcast automation](podcast_automation.md) example.

If you want to persist command options so you don't have to repeat them, and optionally override them per-project, see the [cloud provider CLI wrapper](wrapping_a_cloud_provider_cli.md) example.

When parameters become tedious because you need to set the same option on many commands, consider using [values to set semantic defaults](setting_default_values.md) instead. This use case also explains the difference between syntactic (parameters) and semantic (values) configuration, with a comparison to git config.


<a id="6abcb030-192b-4c73-a62f-4551d1e92a77"></a>

# how to structure your commands

To create powerful, dynamic command line tools that provide the best completion possible, see [this pattern](dynamic_parameters_and_exposed_class.md) for writing your commands. In case you have some issues, you might want to look at the [advanced use cases](dynamic_parameters_advanced_use_cases.md).


<a id="d82b6533-b098-43e7-b4b8-30e283419b9b"></a>

## commands as first order objects

Sometimes, you create commands not only to be called directly, but to be used as basis to build greater commands.

This example of an [ethereum local environment dev tool](ethereum_local_environment_dev_tool.md) shows how to plug clk commands as parameters in other commands.

[ipfs name publish](ipfs_name_publish.md) shows how to use clk bash commands to create the completion for other commands.


<a id="3a184190-e5cb-4e8b-bf5a-177b8ec9ec66"></a>

# batteries included

Like python, clk try hard to provide most of the things you want in a generic command line tool.

In shell command, the library included by default (called \_clk.sh) provides some useful [helpers](bash_command_built_in_lib.md) to help you create a nice and friendly command, despite, well&#x2026; bash.

When you want to provide some choices in command, it might be worthwhile to look at [those examples](choices.md).

To cache some computation to disk, see the [web scrapping](scrapping_the_web.md) use case.

We put a lot of useful logic in clk.lib but did not document much as of now. [This](lib.md) is the current state of this documentation.

Some commands might need to use secret, [here is how](dealing_with_secrets.md) we implement that.

When you have many aliases, parameters, commands, and extensions spread across different profiles, it can be hard to remember what's available. The `clk describe` command helps you [explore and document your configuration](self_documentation.md), showing what features are available in any profile (global, local, or extension).


<a id="57153b01-e474-42f0-baa2-26b1b1611ae7"></a>

# project

Sometimes, you want to gather some commands or configuration in a folder. We call that folder a project.

If you want to do that to, you might want to [read this](using_a_project.md).

When you have a consistent workflow across projects but each project uses different tools, see [global workflow, local implementation](global_workflow_local_implementation.md). This pattern lets you define workflows like `test-n-push` once globally, while each project provides its own `test` command.


<a id="8ad4d10e-1ece-45ef-a558-905b5996ddc4"></a>

# flow

When your commands need to be connected and called in a sequence, we call that a flow.

clk does not want to compete with flow tools, like nodered, but it helps having a basic flow handling from time to time, like when you have a [3D printing flow](3D_printing_flow.md).


<a id="backing-up-documents"></a>

# real world example: backing up documents

The [backing up documents](backing_up_documents.md) use case shows how to build a complete backup system starting from a simple command. It demonstrates hierarchical commands, auto-created groups, persisted parameters, flow dependencies, aliases, and per-project configuration all working together.


<a id="f291ada8-c504-4624-baa7-9c7d600d5c53"></a>

# is it a tool or a library?

If you don't want to use the clk command line tool, you can [roll your own](rolling_your_own.md).


<a id="875fe27e-ca39-4733-a459-e2a35bcfa124"></a>

# publish my code

In that case, you would like to take a look at [how to create your own extensions](creating_extensions.md).


<a id="fbe30b36-5265-4690-abfd-1eb12e333f01"></a>

# plugins

In case clk does not fit your use cases totally, and you want to dynamically monkey-patch its internal (at your own risks), you can use the plugin mechanism.

We [describe here](using_a_plugin.md) how a command could be added along with some modification of behavior of clk invoke system. This is almost dark magic, so we don't actually expect you to need this, but it has been useful in a few very specific situations.
