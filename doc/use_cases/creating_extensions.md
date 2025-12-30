- [creating our own extension](#org0b04b41)
- [enable/disable it](#orgaba3ac9)
- [publish it](#orgff036f5)
- [get an extension](#org2d821ed)

Extensions are folders that contain clk configurations and commands. You can create and share those with your colleagues.

For instance, let's suppose you need to bootstrap a development environment to work with k8s, you would need to create commands to:

-   install the needed binaries dependencies,
-   run the cluster,
-   start some controllers of your choice,
-   run the development environment that would update the cluster automatically.


<a id="org0b04b41"></a>

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


<a id="orgaba3ac9"></a>

# enable/disable it

Note that once it is there, the extension is automatically enabled.

Now, if you decide that you don't want to be bothered with that extension anymore, you can disable it.

```bash
clk extension disable k8s
clk k8s run-dev-env --flow
```

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


<a id="orgff036f5"></a>

# publish it

In case you lost that extension folder and want to find it again, simply run.

```bash
clk extension where-is global/k8s | sed "s|$(pwd)|.|"
```

    ./clk-root/extensions/k8s

You can git init that code and push it to some remote repository. Your colleagues then can get it with `clk extension install yourextensionurl`.


<a id="org2d821ed"></a>

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
