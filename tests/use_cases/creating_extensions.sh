#!/bin/bash -eu
# [[file:../../doc/use_cases/creating_extensions.org::all][all]]
. ./sandboxing.sh

clk extension create k8s

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


try-it_code () {
      clk k8s run-dev-env --flow
}

try-it_expected () {
      cat<<"EOEXPECTED"
installing dependencies
starting k8s cluster
starting controllers
running development environment
EOEXPECTED
}

echo 'Run try-it'

{ try-it_code || true ; } > "${TMP}/code.txt" 2>&1
try-it_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-it"
exit 1
}



disable_code () {
      clk extension disable k8s
      clk k8s run-dev-env --flow
}

disable_expected () {
      cat<<"EOEXPECTED"
warning: Failed to get the command k8s: Command k8s not found
Usage: clk [OPTIONS] COMMAND [ARGS]...
error: No such command 'k8s'.
EOEXPECTED
}

echo 'Run disable'

{ disable_code || true ; } > "${TMP}/code.txt" 2>&1
disable_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying disable"
exit 1
}



enable_code () {
      clk extension enable k8s
      clk k8s run-dev-env --flow
}

enable_expected () {
      cat<<"EOEXPECTED"
installing dependencies
starting k8s cluster
starting controllers
running development environment
EOEXPECTED
}

echo 'Run enable'

{ enable_code || true ; } > "${TMP}/code.txt" 2>&1
enable_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying enable"
exit 1
}



find-it_code () {
      clk extension where-is global/k8s
}

find-it_expected () {
      cat<<"EOEXPECTED"
./clk-root/extensions/k8s
EOEXPECTED
}

echo 'Run find-it'

{ find-it_code || true ; } > "${TMP}/code.txt" 2>&1
find-it_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying find-it"
exit 1
}



install-extension_code () {
      clk extension install https://github.com/clk-project/clk_extension_hello > /dev/null 2>&1
      clk hello
}

install-extension_expected () {
      cat<<"EOEXPECTED"
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

EOEXPECTED
}

echo 'Run install-extension'

{ install-extension_code || true ; } > "${TMP}/code.txt" 2>&1
install-extension_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying install-extension"
exit 1
}



remove-extension_code () {
      clk extension remove hello
      clk hello
}

remove-extension_expected () {
      cat<<"EOEXPECTED"
warning: Failed to get the command hello: Command hello not found
Usage: clk [OPTIONS] COMMAND [ARGS]...
error: No such command 'hello'.
error:
error: Did you mean one of these?
error:     help
error:     log
EOEXPECTED
}

echo 'Run remove-extension'

{ remove-extension_code || true ; } > "${TMP}/code.txt" 2>&1
remove-extension_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying remove-extension"
exit 1
}



install-extension-github_code () {
      clk extension install clk-project/hello > /dev/null 2>&1
      clk hello
}

install-extension-github_expected () {
      cat<<"EOEXPECTED"
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

EOEXPECTED
}

echo 'Run install-extension-github'

{ install-extension-github_code || true ; } > "${TMP}/code.txt" 2>&1
install-extension-github_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying install-extension-github"
exit 1
}



install-extension-name_code () {
      clk extension remove hello
      clk extension install hello > /dev/null 2>&1
      clk hello
}

install-extension-name_expected () {
      cat<<"EOEXPECTED"
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

EOEXPECTED
}

echo 'Run install-extension-name'

{ install-extension-name_code || true ; } > "${TMP}/code.txt" 2>&1
install-extension-name_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying install-extension-name"
exit 1
}


clk extension create tempdir-demo

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


run-tempdir-demo_code () {
      clk tempdir-demo install-mock-tool
}

run-tempdir-demo_expected () {
      cat<<"EOEXPECTED"
Installed: #!/bin/sh
echo tool v1.0.0
EOEXPECTED
}

echo 'Run run-tempdir-demo'

{ run-tempdir-demo_code || true ; } > "${TMP}/code.txt" 2>&1
run-tempdir-demo_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-tempdir-demo"
exit 1
}


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


run-tempfile-demo_code () {
      clk apply-mock-config
}

run-tempfile-demo_expected () {
      cat<<"EOEXPECTED"
Applied config:
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  key: value
EOEXPECTED
}

echo 'Run run-tempfile-demo'

{ run-tempfile-demo_code || true ; } > "${TMP}/code.txt" 2>&1
run-tempfile-demo_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-tempfile-demo"
exit 1
}


clk extension remove tempdir-demo

clk extension create "my-host.[example].com"


hostname-extension-visible_code () {
      clk extension | grep "my-host.\[example\].com"
}

hostname-extension-visible_expected () {
      cat<<"EOEXPECTED"
my-host.[example].com    Unset            global
EOEXPECTED
}

echo 'Run hostname-extension-visible'

{ hostname-extension-visible_code || true ; } > "${TMP}/code.txt" 2>&1
hostname-extension-visible_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying hostname-extension-visible"
exit 1
}


clk extension remove "my-host.[example].com"
# all ends here
