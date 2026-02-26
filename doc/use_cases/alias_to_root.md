- [The problem](#org3b62638)
- [Global aliases](#orgd589360)
- [Local aliases](#org501a36c)

When you work on linked but separate projects — say a backend API and a frontend app — changes in one often need to be verified in the other. If they live in separate directories, you end up constantly `cd`-ing back and forth, losing context along the way.

clk projects scope their commands to directories: aliases, parameters and scripts only activate when you're inside the project. That's great for isolation, but painful when you need to jump between two or three repos in a single workflow.


<a id="org3b62638"></a>

# The problem

Let's set up two projects to see the problem in action.

```bash
mkdir -p billing-api/.clk
cd billing-api
```

```bash
clk alias set build echo "Building the API"
```

    New local alias for build: echo 'Building the API'

```bash
clk alias set test echo "Running API tests"
```

    New local alias for test: echo 'Running API tests'

```bash
cd ..
```

```bash
mkdir -p billing-app/.clk
cd billing-app
```

```bash
clk alias set build echo "Building the frontend"
```

    New local alias for build: echo 'Building the frontend'

```bash
clk alias set test echo "Running frontend tests"
```

    New local alias for test: echo 'Running frontend tests'

Each project works fine on its own. But the moment you're inside `billing-app` and want to rebuild the API, the command isn't there.

```bash
clk build 2>/dev/null
```

    Building the frontend

You only see the frontend's `build`. To reach the API, you'd need `--project`.

```bash
clk --project ../billing-api build 2>/dev/null
```

    Building the API

That works, but typing `clk --project ../billing-api` every time you switch context gets old fast — especially when you're going back and forth several times in a row.


<a id="orgd589360"></a>

# Global aliases

This is where an alias to the root command helps. You can create a global alias that points to `clk` itself, with the `--project` option baked in. Do this once for each project.

```bash
cd ..
```

```bash
clk alias set api clk --project ./billing-api
```

    New global alias for api: clk --project ./billing-api

```bash
clk alias set app clk --project ./billing-app
```

    New global alias for app: clk --project ./billing-app

Now every command from both projects is available from anywhere, under `api` and `app`. No more `cd`-ing around.

```bash
clk api build 2>/dev/null
```

    Building the API

```bash
clk app build 2>/dev/null
```

    Building the frontend

```bash
clk api test 2>/dev/null
```

    Running API tests

```bash
clk app test 2>/dev/null
```

    Running frontend tests

You changed an endpoint in the API? Rebuild it, then run the frontend tests — all without leaving your terminal.

Subgroups and introspection commands work too. You can inspect either project's aliases at any time.

```bash
clk api alias show build 2>/dev/null
```

    build echo Building the API


<a id="org501a36c"></a>

# Local aliases

The global approach is convenient but pollutes your top-level namespace. If you only need cross-project shortcuts when you're actually working inside one of the projects, local aliases are a cleaner fit. Each project declares its own shortcut to the sibling, and nothing leaks outside.

First, let's remove the global aliases.

```bash
clk alias unset api
```

    Erasing api alias from global settings

```bash
clk alias unset app
```

    Erasing app alias from global settings

Now, inside `billing-api`, create a local alias that points to the frontend.

```bash
cd billing-api
```

```bash
clk alias set app clk --project ../billing-app
```

    New local alias for app: clk --project ../billing-app

```bash
cd ..
```

And inside `billing-app`, create the reverse shortcut.

```bash
cd billing-app
```

```bash
clk alias set api clk --project ../billing-api
```

    New local alias for api: clk --project ../billing-api

From inside `billing-app`, you can now reach the API the same way as before.

```bash
clk api build 2>/dev/null
```

    Building the API

```bash
clk api test 2>/dev/null
```

    Running API tests

```bash
cd ..
```

And from inside `billing-api`, you reach the frontend.

```bash
cd billing-api
```

```bash
clk app build 2>/dev/null
```

    Building the frontend

```bash
clk app test 2>/dev/null
```

    Running frontend tests

The aliases only exist inside their respective projects, so they won't clutter your global namespace or show up in unrelated directories.
