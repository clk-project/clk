- [creating our own extension](#578ef2c9-a4d4-448a-9d56-be4afe4ac64a)
- [enable/disable it](#72f61beb-cd79-4fdd-86a2-2c56ef08292c)
- [generic programming](#7e7ae624-ce8a-4470-8bb0-7a44d8c2caea)
- [publish it](#21d2895b-db01-4a09-b2a2-18e34e2830b6)
- [get an extension](#b7bcef53-dd68-4660-9c5c-d9aa029d1a72)
- [leaning on the helpers of clk.lib](#795e915b-29f5-4fbc-a8d9-480a094d3e37)
  - [tempdir](#60d4bff1-366d-45cb-b0ce-3bb7468734aa)
  - [temporary\_file](#d18237dd-7e05-4225-b9de-bf63f09b6d99)
  - [check\_output](#5fab2cd5-3e10-4c2c-ac79-038abeec8a41)
- [extension names with special characters](#1a2b3c4d-5678-90ab-cdef-abcdef012345)
- [an extension that outgrew the project](#an-extension-that-outgrew-the-project)

Extensions are folders that contain clk configurations and commands. You can create and share those with your colleagues.

For instance, let's suppose you need to bootstrap a development environment to work with k8s, you would need to create commands to:

-   install the needed binaries dependencies,
-   run the cluster,
-   start some controllers of your choice,
-   run the development environment that would update the cluster automatically,
-   setup some credentials into the dev cluster.


<a id="578ef2c9-a4d4-448a-9d56-be4afe4ac64a"></a>

# creating our own extension

The real life extension can be found in [here](https://github.com/clk-project/clk_extension_k8s). In this document, we will mock its behavior. There should be something like.

```python
@k8s.command()
def install_dependencies():
    """Install the required binary dependencies for k8s development."""
    print("installing dependencies")

@k8s.command(flowdepends=["k8s.install-dependencies"])
def run_cluster():
    """Start the Kubernetes cluster."""
    print("starting k8s cluster")

@k8s.command(flowdepends=["k8s.run-cluster"])
def start_controllers():
    """Start the necessary controllers for the k8s environment."""
    print("starting controllers")

@k8s.command(flowdepends=["k8s.start-controllers"])
def setup_credentials():
    """Placeholder to setup whatever credentials you need."""
    print("noop, this must be overloaded by a project command")

@k8s.command(flowdepends=["k8s.setup-credentials"])
def run_dev_env():
    """Run the development environment with automatic cluster updates."""
    print("running development environment")

```

To share them, you would first need to create the extension named k8s.

```bash
clk extension create k8s
```

Them, create the k8s command inside the extension.

```bash
clk command create --extension k8s python k8s --group --description "Deal with k8s stuff" --body '
@k8s.command()
def install_dependencies():
    """Install the required binary dependencies for k8s development."""
    print("installing dependencies")

@k8s.command(flowdepends=["k8s.install-dependencies"])
def run_cluster():
    """Start the Kubernetes cluster."""
    print("starting k8s cluster")

@k8s.command(flowdepends=["k8s.run-cluster"])
def start_controllers():
    """Start the necessary controllers for the k8s environment."""
    print("starting controllers")

@k8s.command(flowdepends=["k8s.start-controllers"])
def setup_credentials():
    """Placeholder to setup whatever credentials you need."""
    print("noop, this must be overloaded by a project command")

@k8s.command(flowdepends=["k8s.setup-credentials"])
def run_dev_env():
    """Run the development environment with automatic cluster updates."""
    print("running development environment")

'
```

Try it with

```bash
clk k8s run-dev-env --flow
```

    installing dependencies
    starting k8s cluster
    starting controllers
    noop, this must be overloaded by a project command
    running development environment


<a id="72f61beb-cd79-4fdd-86a2-2c56ef08292c"></a>

# enable/disable it

Note that once it is there, the extension is automatically enabled.

Now, if you decide that you don't want to be bothered with that extension anymore, you can disable it.

```bash
clk extension disable k8s
clk k8s run-dev-env --flow
```

    warning: Failed to get the command k8s: Command k8s not found
    Usage: clk [OPTIONS] [COMMAND] [ARGS]...
    error: No such command 'k8s'.

While it is disabled, you can still call it for one command line, without changing your mind about it.

```bash
clk --extension k8s k8s run-dev-env --flow
```

    installing dependencies
    starting k8s cluster
    starting controllers
    noop, this must be overloaded by a project command
    running development environment

You can enable it again with.

```bash
clk extension enable k8s
clk k8s run-dev-env --flow
```

    installing dependencies
    starting k8s cluster
    starting controllers
    noop, this must be overloaded by a project command
    running development environment

The other way round works too, to leave it out of a single command line.

```bash
clk --without-extension k8s k8s run-dev-env --flow
```

    warning: Failed to get the command k8s: Command k8s not found
    Usage: clk [OPTIONS] [COMMAND] [ARGS]...
    error: No such command 'k8s'.


<a id="7e7ae624-ce8a-4470-8bb0-7a44d8c2caea"></a>

# generic programming

You have noticed that we created a command named setup-credential. In general, the author of the extension does not know in advance the kind of credentials that must be injected in the stack, but the extension can still provide a "placeholder" command that does nothing and is replaced by a more specific one in the project.

For instance, let's create a local bash script to write some credentials. It needs a project to live in.

```bash
mkdir myproject && cd myproject && mkdir .clk
```

In there, the script only has to care about the credentials.

```bash
echo "injecting the credentials of my project"
```

Because it is defined in the project, it takes precedence over the placeholder of the extension. The flow dependencies were described by the placeholder though, and our script depends on nothing, so we ask to inherit the ones of the command we hide with `[overridden]`.

```bash
clk command create bash k8s.setup-credentials --flowdeps '[overridden]' --description "Setup the credentials of this project" --body '
echo "injecting the credentials of my project"
'
```

That way, the step does something useful and the flow still runs whole.

```bash
clk k8s run-dev-env --flow
```

    installing dependencies
    starting k8s cluster
    starting controllers
    injecting the credentials of my project
    running development environment

It is an opt-in, so that you never inherit a flow you did not ask for. Also, `[overridden]` keeps its position, hence you may run something before or after the inherited dependencies.

Leaving the project brings the placeholder back, so that the flow keeps working everywhere.

That way, the extension provides the workflow and each project provides only the parts that are specific to it. An alias would have done as well, would you rather describe the credentials in terms of other clk commands.


<a id="21d2895b-db01-4a09-b2a2-18e34e2830b6"></a>

# publish it

In case you lost that extension folder and want to find it again, simply run.

```bash
clk extension where-is global/k8s
```

    ./clk-root/extensions/k8s

That folder is only code, so git can carry it. A fresh repository wants to know who you are, and then it is a push like any other.

```bash
git init --bare "${TMP}/k8s.git"
cd "$(clk extension where-is global/k8s)"
git init
echo "__pycache__/" > .gitignore
git add .
git -c user.email=you@example.com -c user.name=You commit -m "the k8s extension"
git remote add origin "${TMP}/k8s.git"
git push origin HEAD
cd "${TMP}"
```

Now lose it, the way your colleagues have never had it.

```bash
clk extension remove k8s
clk k8s run-dev-env --flow 2>&1 | tail -1
```

    error: No such command 'k8s'.

`clk extension install` takes that url. It would guess the name from the url, so say the one you want.

```bash
clk extension install "${TMP}/k8s.git" k8s
```

And the whole flow answers again.

```bash
clk k8s run-dev-env --flow
```

    installing dependencies
    starting k8s cluster
    starting controllers
    noop, this must be overloaded by a project command
    running development environment

Should someone hand you another repository under that same name, clk would rather say no than pull a stranger over what you have.

```bash
git init --bare "${TMP}/someone-else.git"
```

```bash
clk extension install "${TMP}/someone-else.git" k8s 2>&1 | sed "s|$(pwd)|.|" | tail -1
```

    error: Extension k8s already exists and is not using the same URL: ./k8s.git

A url that leads nowhere says so, and names what it tried.

```bash
clk extension install "${TMP}/nowhere.git" nowhere 2>&1 | sed "s|$(pwd)|.|" | tail -1
```

    error: Tried git cloning the following urls, without success: ./nowhere.git. Please take a look at the documentation to see how you can pass urls

Meanwhile a colleague of yours writes the command that stops the cluster, and pushes it to that same repository.

```bash
git clone "${TMP}/k8s.git" "${TMP}/their-k8s"
cd "${TMP}/their-k8s"
mkdir -p bin
cat <<'EOF' > bin/stop-cluster
#!/usr/bin/env bash
echo "stopping k8s cluster"
EOF
chmod +x bin/stop-cluster
git add .
git -c user.email=them@example.com -c user.name=Them commit -m "stop the cluster too"
git push origin HEAD
cd "${TMP}"
```

You do not have it yet.

```bash
clk stop-cluster 2>&1 | tail -1
```

    error: No such command 'stop-cluster'.

`clk extension update` pulls the clone, and what they wrote is yours.

```bash
clk extension update k8s
```

```bash
clk stop-cluster 2>/dev/null
```

    stopping k8s cluster


<a id="b7bcef53-dd68-4660-9c5c-d9aa029d1a72"></a>

# get an extension

Let's try to install another extension for the sake of learning. Let's try to install the one available in <https://github.com/clk-project/clk_extension_hello> . It does nothing useful. It simply says hello in a funny way.

There are three ways to provide the url to the extension:

1.  use the full url to the git remote,
2.  if it is hosted in github, and its repository name is something like `clk_extension_NAME`, then you can simply pass `<GITHUB_OWNER>/<NAME>`. This will be automatically changed into `https://github.com/<GITHUB_OWNER>/clk_extension_<NAME>`.
3.  if it is an official extension provided by clk (meaning hosted at <https://github.com/orgs/clk-project/repositories> with the prefix `clk_extension_`), then the name will suffice.

Let's try the three methods.

```bash
clk extension install https://github.com/clk-project/clk_extension_hello > /dev/null 2>&1
clk hello
```

```
_____
| hello |
  =====
       \
        \
         \
          \
                                / \\  //\\
                 |\\___/|      /   \\//  \\\\
                 /0  0  \\__  /    //  | \\ \\
                /     /  \\/_/    //   |  \\  \\
                \@_^_\@'/   \\/_   //    |   \\   \\
                //_^_/     \\/_ //     |    \\    \\
             ( //) |        \\///      |     \\     \\
           ( / /) _|_ /   )  //       |      \\     _\\
         ( // /) '/,_ _ _/  ( ; -.    |    _ _\\.-~        .-~~~^-.
       (( / / )) ,-{        _      `-.|.-~-.           .~         `.
      (( // / ))  '/\\      /                 ~-. _ .-~      .-~^-.  \\
      (( /// ))      `.   {            }                   /      \\  \\
       (( / ))     .----~-.\\        \\-'                 .~         \\  `. \\^-.
                  ///.----..>        \\             _ -~             `.  ^-`  ^-_
                    ///-._ _ _ _ _ _ _}^ - - - - ~                     ~-- ,.-~
                                                                       /.-~
```

An extension you did not write yourself leaves you wondering what is in it. `clk extension describe` answers that.

```bash
clk extension describe global/hello
```

    The extension global/hello is located at ./clk-root/extensions/hello . Let's try to see what it has to offer.
    ##########
    I found some alias:
      hello: say hello
    I found some parameter:
      hello: --who dragon
    I found some commands:
      say

Remove the extension with

```bash
clk extension remove hello
clk hello
```

    warning: Failed to get the command hello: Command hello not found
    Usage: clk [OPTIONS] [COMMAND] [ARGS]...
    error: No such command 'hello'.
    error:
    error: Did you mean one of these?
    error:     help
    error:     log

Because it is hosted on github, this should do as well to install it.

```bash
clk extension install clk-project/hello > /dev/null 2>&1
clk hello
```

```
_____
| hello |
  =====
       \
        \
         \
          \
                                / \\  //\\
                 |\\___/|      /   \\//  \\\\
                 /0  0  \\__  /    //  | \\ \\
                /     /  \\/_/    //   |  \\  \\
                \@_^_\@'/   \\/_   //    |   \\   \\
                //_^_/     \\/_ //     |    \\    \\
             ( //) |        \\///      |     \\     \\
           ( / /) _|_ /   )  //       |      \\     _\\
         ( // /) '/,_ _ _/  ( ; -.    |    _ _\\.-~        .-~~~^-.
       (( / / )) ,-{        _      `-.|.-~-.           .~         `.
      (( // / ))  '/\\      /                 ~-. _ .-~      .-~^-.  \\
      (( /// ))      `.   {            }                   /      \\  \\
       (( / ))     .----~-.\\        \\-'                 .~         \\  `. \\^-.
                  ///.----..>        \\             _ -~             `.  ^-`  ^-_
                    ///-._ _ _ _ _ _ _}^ - - - - ~                     ~-- ,.-~
                                                                       /.-~
```

And because this is also a clk provided extension, the name is enough.

```bash
clk extension remove hello
clk extension install hello > /dev/null 2>&1
clk hello
```

```
_____
| hello |
  =====
       \
        \
         \
          \
                                / \\  //\\
                 |\\___/|      /   \\//  \\\\
                 /0  0  \\__  /    //  | \\ \\
                /     /  \\/_/    //   |  \\  \\
                \@_^_\@'/   \\/_   //    |   \\   \\
                //_^_/     \\/_ //     |    \\    \\
             ( //) |        \\///      |     \\     \\
           ( / /) _|_ /   )  //       |      \\     _\\
         ( // /) '/,_ _ _/  ( ; -.    |    _ _\\.-~        .-~~~^-.
       (( / / )) ,-{        _      `-.|.-~-.           .~         `.
      (( // / ))  '/\\      /                 ~-. _ .-~      .-~^-.  \\
      (( /// ))      `.   {            }                   /      \\  \\
       (( / ))     .----~-.\\        \\-'                 .~         \\  `. \\^-.
                  ///.----..>        \\             _ -~             `.  ^-`  ^-_
                    ///-._ _ _ _ _ _ _}^ - - - - ~                     ~-- ,.-~
                                                                       /.-~
```


<a id="795e915b-29f5-4fbc-a8d9-480a094d3e37"></a>

# leaning on the helpers of clk.lib


<a id="60d4bff1-366d-45cb-b0ce-3bb7468734aa"></a>

## tempdir

`tempdir()` creates a temporary directory and returns its path. It is useful when you need to extract archives and move files around.

Let's mock a typical use case: installing a tool by extracting an archive and moving the binary to a destination. This pattern is used in the [k8s extension](https://github.com/clk-project/clk_extension_k8s) to install helm, tilt, etc.

```bash
clk extension create tempdir-demo
```

```bash
clk command create --extension tempdir-demo python tempdir-demo --group --description "Demonstrate tempdir usage" --body '
from pathlib import Path
from clk.lib import tempdir, makedirs, move

@tempdir_demo.command()
def install_mock_tool():
    """Mock installing a tool by extracting an archive to a temp dir."""
    install_dir = Path(".")
    with tempdir() as d:
        # Simulate extracting an archive (in real code: extract(url, d))
        extracted_dir = Path(d) / "tool-1.0.0"
        makedirs(extracted_dir)
        tool_binary = extracted_dir / "tool"
        tool_binary.write_text("#!/bin/sh\necho tool v1.0.0")

        # Move the binary to install location
        dest = install_dir / "mock-tool"
        move(tool_binary, dest)
        print(f"Installed: {dest.read_text()}")
    # temp dir is automatically cleaned up
    # clean up the installed file for the demo
    (install_dir / "mock-tool").unlink()
'
```

```bash
clk tempdir-demo install-mock-tool
```

    Installed: #!/bin/sh
    echo tool v1.0.0


<a id="d18237dd-7e05-4225-b9de-bf63f09b6d99"></a>

## temporary\_file

`temporary_file()` creates a temporary file. You can optionally pass `content` to write initial content. The file is automatically removed when leaving the context.

This is useful when you need to pass configuration to a command that reads from a file. The [k8s extension](https://github.com/clk-project/clk_extension_k8s) uses this pattern to pass YAML configuration to kubectl.

```bash
clk command create --extension tempdir-demo python apply-mock-config --description "Demonstrate temporary_file usage" --body '
from clk.lib import temporary_file, check_output

@command()
def apply_mock_config():
    """Mock applying a k8s config using a temporary file."""
    config = """apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  key: value
"""
    with temporary_file(content=config) as f:
        # In real code: call(["kubectl", "apply", "-f", f.name])
        # Here we just cat the file to show it works
        result = check_output(["cat", f.name])
        print("Applied config:")
        print(result.strip())
    # temp file is automatically cleaned up
'
```

```bash
clk apply-mock-config
```

    Applied config:
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: my-config
    data:
      key: value


<a id="5fab2cd5-3e10-4c2c-ac79-038abeec8a41"></a>

## check\_output

You know `check_output` from the standard library. The one in `clk.lib` wraps it with what a command needs.

Let's create a command asking a program about the cluster we name. That program complains on its error output, and gives up on every cluster but `main`.

```bash
clk extension create cluster-demo
```

```bash
clk command create --extension cluster-demo python check-cluster --description "Ask a program about a cluster" --body '
from clk.lib import check_output

@command()
@argument("cluster", help="The cluster to ask about")
@flag("--quiet", help="Do not pass on what the program says on its error output")
def check_cluster(cluster, quiet):
    """Ask a program about a cluster."""
    print(check_output(["bash", "-c", "echo trouble reaching $1 >&2 ; test $1 = main || exit 4 ; echo ok", "--", cluster], nostderr=quiet).strip())
'
```

Ask it about `main`.

```bash
clk check-cluster main 2>&1
```

    trouble reaching main
    ok

And if you want to get rid of the warning.

```bash
clk check-cluster --quiet main 2>&1
```

    ok

Now ask about a cluster the program cannot reach.

```bash
clk check-cluster other 2>&1
```

    trouble reaching other
    error: bash -c 'echo trouble reaching $1 >&2 ; test $1 = main || exit 4 ; echo ok' -- other exited with 4

Ask quietly and it fails just the same.

```bash
clk check-cluster --quiet other 2>&1
```

    error: bash -c 'echo trouble reaching $1 >&2 ; test $1 = main || exit 4 ; echo ok' -- other exited with 4, saying:
    error: trouble reaching other

Of course, you can use `--timeout` as well.

```bash
clk command create --extension cluster-demo python watch-cluster --description "Wait for the cluster to answer" --body '
import subprocess

from clk.lib import check_output

@command()
@option("--timeout", type=int, default=30, help="How long to give the cluster to answer")
def watch_cluster(timeout):
    """Wait for the cluster to answer, but not for ever."""
    try:
        print(check_output(["bash", "-c", "sleep 600"], timeout=timeout))
    except subprocess.TimeoutExpired:
        print("giving up, the cluster is not answering")
'
```

```bash
clk watch-cluster --timeout 1 2>&1
```

    error: bash -c 'sleep 600' did not finish in 1s
    giving up, the cluster is not answering


<a id="1a2b3c4d-5678-90ab-cdef-abcdef012345"></a>

# extension names with special characters

Sometimes, extension names come from hostnames. For instance, you may want a per-machine extension whose name is the machine's hostname. Hostnames can contain dots, at signs, brackets or other characters that are unusual in simple identifiers. CLK supports this.

```bash
clk extension create "my-host.[example].com"
```

```bash
clk extension | grep "my-host.\[example\].com"
```

    my-host.[example].com  Unset            global

Note that clk will always enable the extension matching your hostname, even if you explicitly disable it in a project. This is practical to put personal preference in shared project without disturbing the colleagues.


<a id="an-extension-that-outgrew-the-project"></a>

# an extension that outgrew the project

Extensions are cheap too, so one often starts inside a project, under whatever name came to mind.

```bash
mkdir -p tidyproject/.clk
cd tidyproject
clk extension create --local kube
clk command create --extension kube bash run-cluster --description "Run the cluster" --body 'echo "starting the cluster"'
```

```bash
clk extension show kube
```

    extension    configuration    installation
    -----------  ---------------  --------------
    kube         Unset            local

`clk extension rename` gives it the name you would have chosen with more time.

```bash
clk extension rename kube kubernetes
clk extension show kubernetes
```

    extension    configuration    installation
    -----------  ---------------  --------------
    kubernetes   Unset            local

And `clk extension move` carries it out of the project, so that it answers everywhere.

```bash
clk extension move kubernetes global
clk extension show kubernetes
```

    extension    configuration    installation
    -----------  ---------------  --------------
    kubernetes   Unset            global

```bash
cd ..
clk run-cluster
```

    starting the cluster
