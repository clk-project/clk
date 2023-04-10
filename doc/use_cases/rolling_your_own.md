When installed, clk comes with an executable that may be used for all your workflows.

But you may want to run your own project without prefixing stuffs with `clk...`.

But first, two things:

1.  we assume you want to create a tool that contains subcommands, like **git**, not a single command, like **find**. This is because we will automatically create some subcommands to deal with aliases, parameters etc.
2.  we assume you don't mind creating a full python project and not a single ".py" file.

clk provides out of the box a command to bootstrap your own tool.

```bash
clk fork mytool
```

    Now, install mytool with `python3 -m pip install mytool`, enable its completion with `mytool completion install` and don't forget to have fun

Now, simply install this tool, like suggested.

```bash
python3 -m pip install ./mytool
```

From there, you can play with this new toy.

```bash
mytool command create bash hello-world --description "Just say hello" --body 'echo "Hello world"'
```

```bash
mytool hello-world
```

    Hello world

This new tools has all the bells and whistles of clk.

```bash
mytool --help
```

```
Usage: mytool [OPTIONS] COMMAND [ARGS]...

Options:
  --env TEXT                      Add this custom
                                  environment
                                  variable
  --profiling                     Enable profiling
                                  the application
                                  code
  -u, --without-extension EXTENSION
                                  Disable this
                                  extension for
                                  the time of the
                                  command
  -e, --extension EXTENSION       Enable this
                                  extension for
                                  the time of the
                                  command
  --report-file TEXT              Create a report
                                  file to put with
                                  bug reports
  --flow-verbose                  Show more
                                  precisely when a
                                  flow starts and
                                  when it ends
  --debug-on-command-load-error   Trigger a
                                  debugger
                                  whenever a
                                  command fails to
                                  load
  --post-mortem / --no-post-mortem
                                  Run a post-
                                  mortem debugger
                                  in case of
                                  exception
  --exit-on-log-level [develop|debug|action|status|deprecated|info|warning|error|critical]
                                  Exit when one
                                  log of this
                                  level is issued.
                                  Useful to
                                  reproduce the
                                  -Werror behavior
                                  of gcc
  -D, --develop / --no-develop    Same as --log-
                                  level develop
  -d, --debug / --no-debug        Same as --log-
                                  level debug
  -a, --action / --no-action      Same as --log-
                                  level action
  -q, --quiet / --no-quiet        Same as --log-
                                  level critical
  -L, --log-level [develop|debug|action|status|deprecated|info|warning|error|critical]
                                  Log level
                                  (default to
                                  'deprecated')
  --alternate-style STYLE         Alternate style
  --plugin-dirs TEXT
  --persist-migration / --no-persist-migration
                                  Make the profile
                                  migration
                                  persistent,
                                  using --no-
                                  persist-
                                  migration will
                                  preserve the
                                  profiles, unless
                                  you explicitly
                                  write into them.
                                  This is useful
                                  if you want to
                                  use a razor edge
                                  version of the
                                  application
                                  without forcing
                                  peoples to move
                                  to it.
  -P, --project DIR               Project
                                  directory
  --flow-step / --no-flow-step    Make a pause in
                                  between the flow
                                  steps. Useful to
                                  make
                                  demonstrations.
                                  Implies --flow-
                                  verbose.
  --autoflow / --no-autoflow      Automatically
                                  trigger the
                                  --flow option in
                                  every command
  --no-cache / --cache            Deactivate the
                                  caching
                                  mechanism
  -n, --dry-run / --no-dry-run    Don't actually
                                  run anything
  --force-color / --no-force-color
                                  Force the color
                                  output, even if
                                  the output is
                                  not a terminal
  --help-all                      Show the full
                                  help message,
                                  automatic
                                  options
                                  included.
  --help                          Show this
                                  message and
                                  exit.

Commands:
  alias        Manipulate the command aliases
  command      Display all the available commands
  completion   Shell completion
  describe     Describe the given profile
  echo         Log a message
  env          Show the environment
  exec         Run a command.
  extension    Extension related commands
  flowdep      Manipulate command flow
               dependencies.
  fork         Create a brand new project, based
               on clk that can be used by itself.
  hello-world  Just say hello
  help         Display help information
  launcher     Manipulate launchers
  log          Log a message
  parameter    Manipulate command parameters
  password     Manipulate your passwords
  pip          Run pip in the context of this
               installation of clk
  plugin       Manipulate plugins
  trigger      Manipulate command triggers
  value        Manipulate the values
```