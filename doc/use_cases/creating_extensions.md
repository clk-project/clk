- [creating our own extension](#578ef2c9-a4d4-448a-9d56-be4afe4ac64a)
- [enable/disable it](#72f61beb-cd79-4fdd-86a2-2c56ef08292c)
- [publish it](#21d2895b-db01-4a09-b2a2-18e34e2830b6)
- [get an extension](#b7bcef53-dd68-4660-9c5c-d9aa029d1a72)
- [using temporary files and directories](#795e915b-29f5-4fbc-a8d9-480a094d3e37)
  - [tempdir](#60d4bff1-366d-45cb-b0ce-3bb7468734aa)
  - [temporary\_file](#d18237dd-7e05-4225-b9de-bf63f09b6d99)
- [extension names with special characters](#1a2b3c4d-5678-90ab-cdef-abcdef012345)

Extensions are folders that contain clk configurations and commands. You can create and share those with your colleagues.

For instance, let's suppose you need to bootstrap a development environment to work with k8s, you would need to create commands to:

-   install the needed binaries dependencies,
-   run the cluster,
-   start some controllers of your choice,
-   run the development environment that would update the cluster automatically.


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
    Usage: clk [OPTIONS] COMMAND [ARGS]...
    error: No such command 'k8s'.

You can enable it again with.

```bash
clk extension enable k8s
clk k8s run-dev-env --flow
```

    installing dependencies
    starting k8s cluster
    starting controllers
    running development environment


<a id="21d2895b-db01-4a09-b2a2-18e34e2830b6"></a>

# publish it

In case you lost that extension folder and want to find it again, simply run.

```bash
clk extension where-is global/k8s
```

    ./clk-root/extensions/k8s

You can git init that code and push it to some remote repository. Your colleagues then can get it with `clk extension install yourextensionurl`.


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

Remove the extension with

```bash
clk extension remove hello
clk hello
```

    warning: Failed to get the command hello: Command hello not found
    Usage: clk [OPTIONS] COMMAND [ARGS]...
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

# using temporary files and directories

When writing extensions, you often need to work with temporary files or directories. clk provides two helpers in `clk.lib`: `tempdir` and `temporary_file`. They are context managers that automatically clean up after themselves.


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


<a id="1a2b3c4d-5678-90ab-cdef-abcdef012345"></a>

# extension names with special characters

Sometimes, extension names come from hostnames. For instance, you may want a per-machine extension whose name is the machine's hostname. Hostnames can contain dots, at signs, brackets or other characters that are unusual in simple identifiers. CLK supports this.

```bash
clk extension create "my-host.[example].com"
```

```bash
clk extension | grep "my-host.\[example\].com"
```

    my-host.[example].com    Unset            global

Note that clk will always enable the extension matching your hostname, even if you explicitly disable it in a project. This is practical to put personal preference in shared project without disturbing the colleagues.
