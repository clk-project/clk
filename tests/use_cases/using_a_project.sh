#!/usr/bin/env bash
# [[file:../../doc/use_cases/using_a_project.org::run][run]]
set -eu
. ./sandboxing.sh

mkdir myprojet && cd myprojet && mkdir .clk


usingaliases_code () {
      clk alias set somelocalcommand echo hello
}

usingaliases_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New local alias for somelocalcommand: echo hello
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run usingaliases'

{ usingaliases_code || true ; } > "${TMP}/code.txt" 2>&1
usingaliases_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying usingaliases"
exit 1
}



callingthealias_code () {
      clk somelocalcommand
}

callingthealias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
hello
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run callingthealias'

{ callingthealias_code || true ; } > "${TMP}/code.txt" 2>&1
callingthealias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying callingthealias"
exit 1
}


cd ..


callingthealiasoutsideoftheproject_code () {
      clk somelocalcommand
}

callingthealiasoutsideoftheproject_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: Failed to get the command somelocalcommand: Command somelocalcommand not found
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: No such command 'somelocalcommand'.
error:
error: Did you mean one of these?
error:     command
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run callingthealiasoutsideoftheproject'

{ callingthealiasoutsideoftheproject_code || true ; } > "${TMP}/code.txt" 2>&1
callingthealiasoutsideoftheproject_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying callingthealiasoutsideoftheproject"
exit 1
}


cd myprojet


createaparameter_code () {
      clk parameter set echo hello
      clk echo world
}

createaparameter_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New local parameters for echo: hello
hello world
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run createaparameter'

{ createaparameter_code || true ; } > "${TMP}/code.txt" 2>&1
createaparameter_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying createaparameter"
exit 1
}



callingparameteroutsideofproject_code () {
      cd .. && clk echo world
      cd myprojet && clk echo world
}

callingparameteroutsideofproject_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
world
hello world
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run callingparameteroutsideofproject'

{ callingparameteroutsideofproject_code || true ; } > "${TMP}/code.txt" 2>&1
callingparameteroutsideofproject_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying callingparameteroutsideofproject"
exit 1
}



projectprefix_code () {
      echo somecontent > somefile.txt
      clk exec cat project:somefile.txt
}

projectprefix_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
somecontent
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run projectprefix'

{ projectprefix_code || true ; } > "${TMP}/code.txt" 2>&1
projectprefix_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying projectprefix"
exit 1
}



projectprefix_absolute_warning_code () {
      clk exec cat project:/tmp/somefile.txt
}

projectprefix_absolute_warning_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: when evaluating project:/tmp/somefile.txt: /tmp/somefile.txt is absolute, prepending project is a noop.
cat: /tmp/somefile.txt: No such file or directory
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run projectprefix_absolute_warning'

{ projectprefix_absolute_warning_code || true ; } > "${TMP}/code.txt" 2>&1
projectprefix_absolute_warning_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying projectprefix_absolute_warning"
exit 1
}


mkdir -p scripts
cat <<'EOF' > scripts/build.sh
#!/usr/bin/env bash
echo "Building project at: ${CLK__PROJECT}"
echo "App: ${CLK_APPNAME}"
EOF
chmod +x scripts/build.sh


run_build_script_code () {
      clk exec ./scripts/build.sh
}

run_build_script_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building project at: ./
App: clk
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_build_script'

{ run_build_script_code || true ; } > "${TMP}/code.txt" 2>&1
run_build_script_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_build_script"
exit 1
}



run_from_subdir_code () {
      mkdir -p src/deep/nested
      cd src/deep/nested
      clk exec ../../../scripts/build.sh
      cd ../../..
}

run_from_subdir_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building project at: ../../../
App: clk
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_from_subdir'

{ run_from_subdir_code || true ; } > "${TMP}/code.txt" 2>&1
run_from_subdir_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_from_subdir"
exit 1
}



completion_exec_code () {
      clk completion try --last exec ./ | grep scripts
}

completion_exec_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./scripts/
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run completion_exec'

{ completion_exec_code || true ; } > "${TMP}/code.txt" 2>&1
completion_exec_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying completion_exec"
exit 1
}



completion_exec_deep_code () {
      clk completion try --last exec ./scripts/b
}

completion_exec_deep_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./scripts/build.sh
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run completion_exec_deep'

{ completion_exec_deep_code || true ; } > "${TMP}/code.txt" 2>&1
completion_exec_deep_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying completion_exec_deep"
exit 1
}


cat <<'EOF' > scripts/deploy.sh
#!/usr/bin/env bash
echo "Deploying from ${CLK__PROJECT}"
EOF
chmod +x scripts/deploy.sh


create_flow_alias_code () {
      clk alias set deploy exec ./scripts/build.sh , exec ./scripts/deploy.sh
}

create_flow_alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New local alias for deploy: exec ./scripts/build.sh , exec ./scripts/deploy.sh
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create_flow_alias'

{ create_flow_alias_code || true ; } > "${TMP}/code.txt" 2>&1
create_flow_alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create_flow_alias"
exit 1
}



run_flow_code () {
      clk deploy
}

run_flow_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building project at: ./
App: clk
Deploying from ./
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_flow'

{ run_flow_code || true ; } > "${TMP}/code.txt" 2>&1
run_flow_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_flow"
exit 1
}


clk command create bash release-notes --description "Write the release notes" --body 'echo "gathering the commits since the last tag"'


where_release_notes_code () {
      clk command which release-notes
      cd .. && clk release-notes 2>&1 | tail -1 ; cd myprojet
}

where_release_notes_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./.clk/bin/release-notes
error: No such command 'release-notes'.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run where_release_notes'

{ where_release_notes_code || true ; } > "${TMP}/code.txt" 2>&1
where_release_notes_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying where_release_notes"
exit 1
}



move_release_notes_code () {
      clk command move release-notes global
      clk command which release-notes | sed "s|${TMP}|.|"
      cd .. && clk release-notes ; cd myprojet
}

move_release_notes_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./clk-root/bin/release-notes
gathering the commits since the last tag
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run move_release_notes'

{ move_release_notes_code || true ; } > "${TMP}/code.txt" 2>&1
move_release_notes_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying move_release_notes"
exit 1
}
# run ends here
