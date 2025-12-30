#!/bin/bash -eu
# [[id:f47428c2-56ea-4d91-97d9-4f2ff63ef052::all][all]]
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
diff -uBw <(try-it_code 2>&1) <(try-it_expected) || {
echo "Something went wrong when trying try-it"
exit 1
}



disable_code () {
      clk extension disable k8s
      clk k8s run-dev-env --flow
}

disable_expected () {
      cat<<"EOEXPECTED"
Usage: clk [OPTIONS] COMMAND [ARGS]...
error: No such command 'k8s'.
EOEXPECTED
}

echo 'Run disable'
diff -uBw <(disable_code 2>&1) <(disable_expected) || {
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
diff -uBw <(enable_code 2>&1) <(enable_expected) || {
echo "Something went wrong when trying enable"
exit 1
}



find-it_code () {
      clk extension where-is global/k8s | sed "s|$(pwd)|.|"
}

find-it_expected () {
      cat<<"EOEXPECTED"
./clk-root/extensions/k8s
EOEXPECTED
}

echo 'Run find-it'
diff -uBw <(find-it_code 2>&1) <(find-it_expected) || {
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
diff -uBw <(install-extension_code 2>&1) <(install-extension_expected) || {
echo "Something went wrong when trying install-extension"
exit 1
}



remove-extension_code () {
      clk extension remove hello
      clk hello
}

remove-extension_expected () {
      cat<<"EOEXPECTED"
Usage: clk [OPTIONS] COMMAND [ARGS]...
error: No such command 'hello'.
error:
error: Did you mean one of these?
error:     help
error:     log
EOEXPECTED
}

echo 'Run remove-extension'
diff -uBw <(remove-extension_code 2>&1) <(remove-extension_expected) || {
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
diff -uBw <(install-extension-github_code 2>&1) <(install-extension-github_expected) || {
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
diff -uBw <(install-extension-name_code 2>&1) <(install-extension-name_expected) || {
echo "Something went wrong when trying install-extension-name"
exit 1
}
# all ends here
