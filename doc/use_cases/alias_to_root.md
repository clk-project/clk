- [The problem](#683fcbea-b776-44ff-8af2-bb7e10a69bb0)
- [Global aliases](#260d04a3-8c35-4581-8d40-e3479eb874a9)
- [Local aliases](#450ba117-403e-4bc3-a809-28d8a6f590c0)
- [promoting an alias to the global profile](#promoting-an-alias-to-the-global-profile)
- [tidying up as the aliases pile up](#tidying-up-as-the-aliases-pile-up)

When you work on linked but separate projects — say a backend API and a frontend app — changes in one often need to be verified in the other. If they live in separate directories, you end up constantly `cd`-ing back and forth, losing context along the way.

clk projects scope their commands to directories: aliases, parameters and scripts only activate when you're inside the project. That's great for isolation, but painful when you need to jump between two or three repos in a single workflow.


<a id="683fcbea-b776-44ff-8af2-bb7e10a69bb0"></a>

# The problem

Let's set up two projects to see the problem in action.

```bash
mkdir -p billing-api/.clk
cd billing-api
```

```bash
clk alias set build echo "Building the API"
```

<pre>
New <span style="color:green;">local</span> alias for build: echo 'Building the API'
</pre>

```bash
clk alias set test echo "Running API tests"
```

<pre>
New <span style="color:green;">local</span> alias for test: echo 'Running API tests'
</pre>

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

<pre>
New <span style="color:green;">local</span> alias for build: echo 'Building the frontend'
</pre>

```bash
clk alias set test echo "Running frontend tests"
```

<pre>
New <span style="color:green;">local</span> alias for test: echo 'Running frontend tests'
</pre>

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


<a id="260d04a3-8c35-4581-8d40-e3479eb874a9"></a>

# Global aliases

This is where an alias to the root command helps. You can create a global alias that points to `clk` itself, with the `--project` option baked in. Do this once for each project.

```bash
cd ..
```

```bash
clk alias set api clk --project ./billing-api
```

<pre>
New <span style="color:teal;">global</span> alias for api: clk --project ./billing-api
</pre>

```bash
clk alias set app clk --project ./billing-app
```

<pre>
New <span style="color:teal;">global</span> alias for app: clk --project ./billing-app
</pre>

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

<pre>
build <span style="color:green;">echo Building the API</span>
-------------
Legend: <span style="color:green;">local</span>
</pre>

Ask one of them for help and clk says where it really comes from, so you know which of the two to go and edit.

```bash
clk api build --help 2>/dev/null | grep -A1 "This is a sub command"
```

    This is a sub command of 'api' that is an alias towards 'clk'. To edit it, try getting help from both of them or from
    the subcommand of the original group (something like `clk build --help`)


<a id="450ba117-403e-4bc3-a809-28d8a6f590c0"></a>

# Local aliases

The global approach is convenient but pollutes your top-level namespace. If you only need cross-project shortcuts when you're actually working inside one of the projects, local aliases are a cleaner fit. Each project declares its own shortcut to the sibling, and nothing leaks outside.

First, let's remove the global aliases.

```bash
clk alias unset api
```

<pre>
Erasing api alias from <span style="color:teal;">global</span> settings
</pre>

```bash
clk alias unset app
```

<pre>
Erasing app alias from <span style="color:teal;">global</span> settings
</pre>

Now, inside `billing-api`, create a local alias that points to the frontend.

```bash
cd billing-api
```

```bash
clk alias set app clk --project ../billing-app
```

<pre>
New <span style="color:green;">local</span> alias for app: clk --project ../billing-app
</pre>

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

<pre>
New <span style="color:green;">local</span> alias for api: clk --project ../billing-api
</pre>

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


<a id="promoting-an-alias-to-the-global-profile"></a>

# promoting an alias to the global profile

An alias you end up wanting everywhere need not be typed again elsewhere. From `billing-api`, `clk alias move` carries `build` to the global profile as it stands.

```bash
clk alias move build global
```

<pre>
Moved alias build, <span style="color:green;">local</span> -&gt; <span style="color:teal;">global</span>
</pre>

It still answers here, now from the global profile rather than the local one.

```bash
clk build
```

    Building the API

And `billing-app` keeps the `build` of its own, which still wins over the one we just made global.

```bash
cd ../billing-app
```

```bash
clk build
```

    Building the frontend


<a id="tidying-up-as-the-aliases-pile-up"></a>

# tidying up as the aliases pile up

Made in a hurry, aliases pile up and say nothing about themselves. Here is one more, still in `billing-app`, standing on the two you already have.

```bash
clk alias set ship build , test
```

<pre>
New <span style="color:green;">local</span> alias for ship: build , test
</pre>

Were you setting things up from a script, you would rather it kept quiet. It still does the work, it just stops saying so.

```bash
clk --quiet alias set ship-nightly build , test
clk alias show ship-nightly
```

<pre>
ship-nightly <span style="color:green;">build, test</span>
-------------
Legend: <span style="color:green;">local</span>
</pre>

Asked for its help, it can only repeat itself.

```bash
clk ship --help | head -3
```

    Usage: clk ship [OPTIONS] [MESSAGE]...

      Alias for: build , test

`clk alias set-documentation` gives it something better to say.

```bash
clk alias set-documentation ship "Build and test the frontend"
```

```bash
clk ship --help | head -3
```

    Usage: clk ship [OPTIONS] [MESSAGE]...

      Build and test the frontend

Before a release you want the API in as well. Copying `ship` gives you something to start from, that you are then free to let drift.

```bash
clk alias copy ship ship-all
```

    Copied alias ship -> ship-all in local

```bash
clk alias append ship-all api build , api test
```

Renaming is not only about the alias itself: the aliases that call it follow. It reaches further than you asked for, so you may want to watch it happen before it does. `--dry-run` says what it would do and writes nothing.

```bash
clk --dry-run alias rename test test-front
```

    Would have moved alias test -> test-front in local

```bash
clk alias show
```

<pre>
api <span style="color:green;">clk --project ../billing-api</span>
build <span style="color:green;">echo Building the frontend</span>
ship <span style="color:green;">build, test</span>
ship-all <span style="color:green;">build, test, api build, api test</span>
ship-nightly <span style="color:green;">build, test</span>
test <span style="color:green;">echo Running frontend tests</span>
-------------
Legend: <span style="color:green;">local</span>
</pre>

Nothing moved, so now do it for real.

```bash
clk alias rename test test-front
```

    Moved alias test -> test-front in local

Both `ship` and `ship-all` were built on `test`, and now call `test-front` without your having to say so.

```bash
clk alias show
```

<pre>
api <span style="color:green;">clk --project ../billing-api</span>
build <span style="color:green;">echo Building the frontend</span>
ship <span style="color:green;">build, test-front</span>
ship-all <span style="color:green;">build, test-front, api build, api test</span>
ship-nightly <span style="color:green;">build, test-front</span>
test-front <span style="color:green;">echo Running frontend tests</span>
-------------
Legend: <span style="color:green;">local</span>
</pre>

Had one of them lived in a profile clk cannot write to, it would have warned you that the old name is still used there, for you to correct by hand.

Not every name will do, though. Start one with a dash and your shell would hand it to clk as an option, so clk turns it down before you get there.

```bash
clk alias set -ship build
```

    Usage: clk alias set [OPTIONS] ALIAS COMMAND [PARAMS]...
    error: Aliases must not start with dashes (-)

Begin it with punctuation instead and it tells you what a name may start with.

```bash
clk alias set ,ship build
```

    error: Invalid alias name: ,ship. An alias must start with a letter, a digit or an underscore

You see every alias from here, but you only write to one profile at a time. Put one in the global profile and then forget where it lives.

```bash
clk alias --global set deploy-prod echo Deploying to production
```

```bash
clk alias set-documentation deploy-prod "Ship to production"
```

    error: The profile local has no 'deploy-prod' alias registered. Try using another profile option (like --local or --global)

Dropping it from here gets the same answer.

```bash
clk alias unset deploy-prod
```

    error: The profile local has no alias named 'deploy-prod'. Try using another profile option (like --local or --global)
