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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/usingaliases"
else
    usingaliases_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying usingaliases"
        exit 1
    }
fi



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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/callingthealias"
else
    callingthealias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying callingthealias"
        exit 1
    }
fi


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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/callingthealiasoutsideoftheproject"
else
    callingthealiasoutsideoftheproject_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying callingthealiasoutsideoftheproject"
        exit 1
    }
fi


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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/createaparameter"
else
    createaparameter_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying createaparameter"
        exit 1
    }
fi



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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/callingparameteroutsideofproject"
else
    callingparameteroutsideofproject_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying callingparameteroutsideofproject"
        exit 1
    }
fi



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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/projectprefix"
else
    projectprefix_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying projectprefix"
        exit 1
    }
fi



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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/projectprefix_absolute_warning"
else
    projectprefix_absolute_warning_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying projectprefix_absolute_warning"
        exit 1
    }
fi


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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_build_script"
else
    run_build_script_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_build_script"
        exit 1
    }
fi



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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_from_subdir"
else
    run_from_subdir_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_from_subdir"
        exit 1
    }
fi



run_in_project_code () {
      cd src/deep/nested
      clk exec --in-project ./scripts/build.sh
}

run_in_project_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building project at: ./
App: clk
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_in_project'

{ run_in_project_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_in_project"
else
    run_in_project_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_in_project"
        exit 1
    }
fi



run_in_cwd_code () {
      clk exec --in-project --cwd scripts ./build.sh
}

run_in_cwd_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Building project at: ../
App: clk
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_in_cwd'

{ run_in_cwd_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_in_cwd"
else
    run_in_cwd_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_in_cwd"
        exit 1
    }
fi


cd ../../..


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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/completion_exec"
else
    completion_exec_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying completion_exec"
        exit 1
    }
fi



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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/completion_exec_deep"
else
    completion_exec_deep_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying completion_exec_deep"
        exit 1
    }
fi


mkdir -p "${TMP}/bin"
export PATH="${TMP}/bin:${PATH}"
echo '#!/usr/bin/env bash' > "${TMP}/bin/run-ci"
chmod +x "${TMP}/bin/run-ci"


completion_exec_program_code () {
      clk completion try --last exec run-c
}

completion_exec_program_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
run-ci
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run completion_exec_program'

{ completion_exec_program_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/completion_exec_program"
else
    completion_exec_program_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying completion_exec_program"
        exit 1
    }
fi


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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/create_flow_alias"
else
    create_flow_alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create_flow_alias"
        exit 1
    }
fi



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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_flow"
else
    run_flow_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_flow"
        exit 1
    }
fi


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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/where_release_notes"
else
    where_release_notes_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying where_release_notes"
        exit 1
    }
fi



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
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/move_release_notes"
else
    move_release_notes_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying move_release_notes"
        exit 1
    }
fi



copy_release_notes_code () {
      clk command copy release-notes local release-notes-draft
      clk command which release-notes-draft
}

copy_release_notes_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./.clk/bin/release-notes-draft
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run copy_release_notes'

{ copy_release_notes_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/copy_release_notes"
else
    copy_release_notes_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying copy_release_notes"
        exit 1
    }
fi



copy_release_notes_again_code () {
      clk command copy release-notes local release-notes-draft
}

copy_release_notes_again_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk command copy [OPTIONS] CUSTOMCOMMAND PROFILE NAME
error: I won't overwrite ./.clk/bin/release-notes-draft unless explicitly called with --force
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run copy_release_notes_again'

{ copy_release_notes_again_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/copy_release_notes_again"
else
    copy_release_notes_again_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying copy_release_notes_again"
        exit 1
    }
fi



copy_release_notes_forced_code () {
      clk command copy release-notes local release-notes-draft --force
      clk release-notes-draft
}

copy_release_notes_forced_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
gathering the commits since the last tag
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run copy_release_notes_forced'

{ copy_release_notes_forced_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/copy_release_notes_forced"
else
    copy_release_notes_forced_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying copy_release_notes_forced"
        exit 1
    }
fi


mkdir -p ../oldproject/.clk
echo 8 > ../oldproject/.clk/version.txt
cat<<'EOF' > ../oldproject/.clk/clk.json
{
    "alias": {
        "hello": {
            "commands": [["echo", "hello"]],
            "documentation": null
        }
    }
}
EOF


run_old_project_code () {
      cd ../oldproject
      clk alias show 2>&1
      ls .clk
      cd ../myprojet
}

run_old_project_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: Profile in ./.clk is obsolete. It has the version 8 and current version is 9. Migration started.
hello echo hello
clk.json5
version.txt
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_old_project'

{ run_old_project_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_old_project"
else
    run_old_project_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_old_project"
        exit 1
    }
fi


echo 99 > .clk/version.txt


run_from_the_future_code () {
      clk alias show 2>&1 | head -2
}

run_from_the_future_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: The profile at location ./.clk is at version 99. I can only manage till version 9. Please upgrade clk and try again.
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_from_the_future'

{ run_from_the_future_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_from_the_future"
else
    run_from_the_future_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_from_the_future"
        exit 1
    }
fi


echo 1 > .clk/version.txt


run_from_the_past_code () {
      clk alias show 2>&1 | head -2
}

run_from_the_past_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: The profile at location ./.clk is at version 1. I can only migrate profiles from version 8 on. Migrate it manually, or ask for help on https://github.com/clk-project/clk/issues/new .
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_from_the_past'

{ run_from_the_past_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_from_the_past"
else
    run_from_the_past_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_from_the_past"
        exit 1
    }
fi


echo 9 > .clk/version.txt
echo '{parameters: [oops' > .clk/clk.json5


run_with_broken_settings_code () {
      clk alias show 2>&1
}

run_with_broken_settings_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
warning: Can't read settings from ./.clk/clk.json5
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_with_broken_settings'

{ run_with_broken_settings_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_with_broken_settings"
else
    run_with_broken_settings_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_with_broken_settings"
        exit 1
    }
fi
# run ends here
