#!/usr/bin/env bash
# [[file:../../doc/use_cases/creating_extensions.org::all][all]]
set -eu
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
def setup_credentials():
    """Placeholder to setup whatever credentials you need."""
    print("noop, this must be overloaded by a project command")

@k8s.command(flowdepends=["k8s.setup-credentials"])
def run_dev_env():
    """Run the development environment with automatic cluster updates."""
    print("running development environment")

'


try-it_code () {
      clk k8s run-dev-env --flow
}

try-it_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
installing dependencies
starting k8s cluster
starting controllers
noop, this must be overloaded by a project command
running development environment
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: Failed to get the command k8s: Command k8s not found
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: No such command 'k8s'.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run disable'

{ disable_code || true ; } > "${TMP}/code.txt" 2>&1
disable_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying disable"
exit 1
}



enable-for-one-run_code () {
      clk --extension k8s k8s run-dev-env --flow
}

enable-for-one-run_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
installing dependencies
starting k8s cluster
starting controllers
noop, this must be overloaded by a project command
running development environment
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run enable-for-one-run'

{ enable-for-one-run_code || true ; } > "${TMP}/code.txt" 2>&1
enable-for-one-run_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying enable-for-one-run"
exit 1
}



enable_code () {
      clk extension enable k8s
      clk k8s run-dev-env --flow
}

enable_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
installing dependencies
starting k8s cluster
starting controllers
noop, this must be overloaded by a project command
running development environment
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run enable'

{ enable_code || true ; } > "${TMP}/code.txt" 2>&1
enable_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying enable"
exit 1
}



disable-for-one-run_code () {
      clk --without-extension k8s k8s run-dev-env --flow
}

disable-for-one-run_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: Failed to get the command k8s: Command k8s not found
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: No such command 'k8s'.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run disable-for-one-run'

{ disable-for-one-run_code || true ; } > "${TMP}/code.txt" 2>&1
disable-for-one-run_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying disable-for-one-run"
exit 1
}


mkdir noisy-project && cd noisy-project && mkdir .clk


disable-in-project_code () {
      clk extension disable k8s
      clk k8s run-dev-env --flow 2>&1 | tail -1
}

disable-in-project_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: No such command 'k8s'.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run disable-in-project'

{ disable-in-project_code || true ; } > "${TMP}/code.txt" 2>&1
disable-in-project_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying disable-in-project"
exit 1
}



unset-in-project_code () {
      clk extension unset k8s
      clk k8s run-dev-env --flow
}

unset-in-project_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
installing dependencies
starting k8s cluster
starting controllers
noop, this must be overloaded by a project command
running development environment
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run unset-in-project'

{ unset-in-project_code || true ; } > "${TMP}/code.txt" 2>&1
unset-in-project_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying unset-in-project"
exit 1
}


cd ..

clk command create --extension k8s bash deploy --description "Deploy the stack" --body 'echo deploying the usual way'

mkdir myproject && cd myproject && mkdir .clk

clk command create bash deploy --flowdeps '[overridden]' --description "Deploy the stack our way" --body 'echo deploying our way'


run_project_deploy_code () {
      clk deploy
}

run_project_deploy_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
deploying our way
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_project_deploy'

{ run_project_deploy_code || true ; } > "${TMP}/code.txt" 2>&1
run_project_deploy_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_project_deploy"
exit 1
}


clk flowdep --extension k8s set deploy k8s.run-cluster


run_project_deploy_again_code () {
      clk deploy --flow
}

run_project_deploy_again_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
installing dependencies
starting k8s cluster
deploying our way
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_project_deploy_again'

{ run_project_deploy_again_code || true ; } > "${TMP}/code.txt" 2>&1
run_project_deploy_again_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_project_deploy_again"
exit 1
}


clk command create bash k8s.setup-credentials --flowdeps '[overridden]' --description "Setup the credentials of this project" --body '
echo "injecting the credentials of my project"
'


run-flow-in-project_code () {
      clk k8s run-dev-env --flow
}

run-flow-in-project_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
installing dependencies
starting k8s cluster
starting controllers
injecting the credentials of my project
running development environment
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-flow-in-project'

{ run-flow-in-project_code || true ; } > "${TMP}/code.txt" 2>&1
run-flow-in-project_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-flow-in-project"
exit 1
}


cd ..


find-it_code () {
      clk extension where-is global/k8s
}

find-it_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./clk-root/extensions/k8s
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run find-it'

{ find-it_code || true ; } > "${TMP}/code.txt" 2>&1
find-it_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying find-it"
exit 1
}


git init --bare "${TMP}/k8s.git"
cd "$(clk extension where-is global/k8s)"
git init
echo "__pycache__/" > .gitignore
git add .
git -c user.email=you@example.com -c user.name=You commit -m "the k8s extension"
git remote add origin "${TMP}/k8s.git"
git push origin HEAD
cd "${TMP}"


lose-k8s_code () {
      clk extension remove k8s
      clk k8s run-dev-env --flow 2>&1 | tail -1
}

lose-k8s_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: No such command 'k8s'.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run lose-k8s'

{ lose-k8s_code || true ; } > "${TMP}/code.txt" 2>&1
lose-k8s_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying lose-k8s"
exit 1
}


clk extension install "${TMP}/k8s.git" k8s


k8s-is-back_code () {
      clk k8s run-dev-env --flow
}

k8s-is-back_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
installing dependencies
starting k8s cluster
starting controllers
noop, this must be overloaded by a project command
running development environment
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run k8s-is-back'

{ k8s-is-back_code || true ; } > "${TMP}/code.txt" 2>&1
k8s-is-back_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying k8s-is-back"
exit 1
}



install-k8s-again_code () {
      clk extension install "${TMP}/k8s.git" k8s 2>&1 | tail -1
}

install-k8s-again_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Nothing to be done for global/k8s
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run install-k8s-again'

{ install-k8s-again_code || true ; } > "${TMP}/code.txt" 2>&1
install-k8s-again_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying install-k8s-again"
exit 1
}


git init --bare "${TMP}/someone-else.git"


refuse-another-k8s_code () {
      clk extension install "${TMP}/someone-else.git" k8s 2>&1 | sed "s|$(pwd)|.|" | tail -1
}

refuse-another-k8s_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: Extension k8s already exists and is not using the same URL: ./k8s.git
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run refuse-another-k8s'

{ refuse-another-k8s_code || true ; } > "${TMP}/code.txt" 2>&1
refuse-another-k8s_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying refuse-another-k8s"
exit 1
}



install-from-nowhere_code () {
      clk extension install "${TMP}/nowhere.git" nowhere 2>&1 | sed "s|$(pwd)|.|" | tail -1
}

install-from-nowhere_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: Tried git cloning the following urls, without success: ./nowhere.git. Please take a look at the documentation to see how you can pass urls
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run install-from-nowhere'

{ install-from-nowhere_code || true ; } > "${TMP}/code.txt" 2>&1
install-from-nowhere_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying install-from-nowhere"
exit 1
}


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


no-stop-cluster_code () {
      clk stop-cluster 2>&1 | tail -1
}

no-stop-cluster_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: No such command 'stop-cluster'.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run no-stop-cluster'

{ no-stop-cluster_code || true ; } > "${TMP}/code.txt" 2>&1
no-stop-cluster_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying no-stop-cluster"
exit 1
}


clk extension update k8s


stop-cluster_code () {
      clk stop-cluster 2>/dev/null
}

stop-cluster_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
stopping k8s cluster
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run stop-cluster'

{ stop-cluster_code || true ; } > "${TMP}/code.txt" 2>&1
stop-cluster_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying stop-cluster"
exit 1
}



install-extension_code () {
      clk extension install https://github.com/clk-project/clk_extension_hello > /dev/null 2>&1
      clk hello
}

install-extension_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
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
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run install-extension'

{ install-extension_code || true ; } > "${TMP}/code.txt" 2>&1
install-extension_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying install-extension"
exit 1
}



describe-hello_code () {
      clk extension describe global/hello
}

describe-hello_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
The extension global/hello is located at ./clk-root/extensions/hello . Let's try to see what it has to offer.
##########
I found some alias:
  hello: say hello
I found some parameter:
  hello: --who dragon
I found some commands:
  say
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run describe-hello'

{ describe-hello_code || true ; } > "${TMP}/code.txt" 2>&1
describe-hello_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying describe-hello"
exit 1
}



remove-extension_code () {
      clk extension remove hello
      clk hello
}

remove-extension_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: Failed to get the command hello: Command hello not found
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: No such command 'hello'.
error:
error: Did you mean one of these?
error:     help
error:     deploy
error:     log
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
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
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
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
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
Installed: #!/bin/sh
echo tool v1.0.0
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
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
      local expected
      expected="$(cat<<"EOEXPECTED"
Applied config:
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  key: value
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-tempfile-demo'

{ run-tempfile-demo_code || true ; } > "${TMP}/code.txt" 2>&1
run-tempfile-demo_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-tempfile-demo"
exit 1
}


clk extension remove tempdir-demo

clk extension create cluster-demo

clk command create --extension cluster-demo python check-cluster --description "Ask a program about a cluster" --body '
from clk.lib import check_output

@command()
@argument("cluster", help="The cluster to ask about")
@flag("--quiet", help="Do not pass on what the program says on its error output")
def check_cluster(cluster, quiet):
    """Ask a program about a cluster."""
    print(check_output(["bash", "-c", "echo trouble reaching $1 >&2 ; test $1 = main || exit 4 ; echo ok", "--", cluster], nostderr=quiet).strip())
'


run-complaining-demo_code () {
      clk check-cluster main 2>&1
}

run-complaining-demo_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
trouble reaching main
ok
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-complaining-demo'

{ run-complaining-demo_code || true ; } > "${TMP}/code.txt" 2>&1
run-complaining-demo_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-complaining-demo"
exit 1
}



run-quiet-demo_code () {
      clk check-cluster --quiet main 2>&1
}

run-quiet-demo_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
ok
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-quiet-demo'

{ run-quiet-demo_code || true ; } > "${TMP}/code.txt" 2>&1
run-quiet-demo_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-quiet-demo"
exit 1
}



run-failing-demo_code () {
      clk check-cluster other 2>&1
}

run-failing-demo_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
trouble reaching other
error: bash -c 'echo trouble reaching $1 >&2 ; test $1 = main || exit 4 ; echo ok' -- other exited with 4
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-failing-demo'

{ run-failing-demo_code || true ; } > "${TMP}/code.txt" 2>&1
run-failing-demo_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-failing-demo"
exit 1
}



run-quiet-failing-demo_code () {
      clk check-cluster --quiet other 2>&1
}

run-quiet-failing-demo_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: bash -c 'echo trouble reaching $1 >&2 ; test $1 = main || exit 4 ; echo ok' -- other exited with 4, saying:
error: trouble reaching other
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-quiet-failing-demo'

{ run-quiet-failing-demo_code || true ; } > "${TMP}/code.txt" 2>&1
run-quiet-failing-demo_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-quiet-failing-demo"
exit 1
}


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


run-waiting-demo_code () {
      clk watch-cluster --timeout 1 2>&1
}

run-waiting-demo_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: bash -c 'sleep 600' did not finish in 1s
giving up, the cluster is not answering
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-waiting-demo'

{ run-waiting-demo_code || true ; } > "${TMP}/code.txt" 2>&1
run-waiting-demo_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-waiting-demo"
exit 1
}


clk extension remove cluster-demo

clk extension create "my-host.[example].com"


hostname-extension-visible_code () {
      clk extension | grep "my-host.\[example\].com"
}

hostname-extension-visible_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
my-host.[example].com  Unset            global
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run hostname-extension-visible'

{ hostname-extension-visible_code || true ; } > "${TMP}/code.txt" 2>&1
hostname-extension-visible_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying hostname-extension-visible"
exit 1
}


clk extension remove "my-host.[example].com"

mkdir -p tidyproject/.clk
cd tidyproject
clk extension create --local kube
clk command create --extension kube bash run-cluster --description "Run the cluster" --body 'echo "starting the cluster"'


kube-is-local_code () {
      clk extension show kube
}

kube-is-local_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
extension    configuration    installation
-----------  ---------------  --------------
kube         Unset            local
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run kube-is-local'

{ kube-is-local_code || true ; } > "${TMP}/code.txt" 2>&1
kube-is-local_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying kube-is-local"
exit 1
}



rename-kube_code () {
      clk extension rename kube kubernetes
      clk extension show kubernetes
}

rename-kube_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
extension    configuration    installation
-----------  ---------------  --------------
kubernetes   Unset            local
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run rename-kube'

{ rename-kube_code || true ; } > "${TMP}/code.txt" 2>&1
rename-kube_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying rename-kube"
exit 1
}



move-kube_code () {
      clk extension move kubernetes global
      clk extension show kubernetes
}

move-kube_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
extension    configuration    installation
-----------  ---------------  --------------
kubernetes   Unset            global
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run move-kube'

{ move-kube_code || true ; } > "${TMP}/code.txt" 2>&1
move-kube_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying move-kube"
exit 1
}



leave-tidyproject_code () {
      cd ..
      clk run-cluster
}

leave-tidyproject_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
starting the cluster
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run leave-tidyproject'

{ leave-tidyproject_code || true ; } > "${TMP}/code.txt" 2>&1
leave-tidyproject_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying leave-tidyproject"
exit 1
}
# all ends here
