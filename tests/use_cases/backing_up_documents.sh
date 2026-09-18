#!/usr/bin/env bash
# [[file:../../doc/use_cases/backing_up_documents.org::#69f8a2f5-ba36-41fc-9d2c-6235b839bd9b][summary:1]]
set -eu
. ./sandboxing.sh

clk command create python backup --group --description "Backup operations"

cat <<'EOF' > "$(clk command which backup)"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from clk.config import config
from clk.decorators import group, option


@group()
@option("--dest", default="/mnt/backup", help="Backup destination base directory")
def backup(dest):
    "Backup operations"
    config.override_env["BACKUP_DESTINATION"] = dest
    config.init()
EOF

clk command create bash backup.docs.do \
    --description "Backup documents to external drive" \
    --option '--source:str:Source directory:~/docs' \
    --body 'echo "Backing up documents from ${CLK___SOURCE} to ${BACKUP_DESTINATION}"'


try-backup-docs-do_code () {
      clk backup docs do
}

try-backup-docs-do_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ~/docs to /mnt/backup
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-backup-docs-do'

{ try-backup-docs-do_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-backup-docs-do"
else
    try-backup-docs-do_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-backup-docs-do"
        exit 1
    }
fi



show-backup-help_code () {
      clk backup --help
}

show-backup-help_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk backup [OPTIONS] COMMAND [ARGS]...

  Backup operations

  Edit this custom command by running `clk command edit backup`
  Or edit ./clk-root/python/backup.py directly.

Options:
  --dest TEXT  Backup destination base directory  [default: /mnt/backup]
  --help-all   Show the full help message, automatic options included.
  --help       Show this message and exit.

Commands:
  docs  Automatically created group to organize subcommands

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-backup-help'

{ show-backup-help_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/show-backup-help"
else
    show-backup-help_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-backup-help"
        exit 1
    }
fi



set-dest-param_code () {
      clk parameter set backup --dest /media/external/documents
}

set-dest-param_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global parameters for backup: --dest /media/external/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-dest-param'

{ set-dest-param_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/set-dest-param"
else
    set-dest-param_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-dest-param"
        exit 1
    }
fi



try-with-param_code () {
      clk backup docs do
}

try-with-param_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ~/docs to /media/external/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-with-param'

{ try-with-param_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-with-param"
else
    try-with-param_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-with-param"
        exit 1
    }
fi



override-param_code () {
      clk backup --dest /tmp/quick-backup docs do
}

override-param_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ~/docs to /tmp/quick-backup
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run override-param'

{ override-param_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/override-param"
else
    override-param_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying override-param"
        exit 1
    }
fi


clk command create bash backup.database \
    --description "Backup database" \
    --option '--db:str:Database name:main.db' \
    --body 'echo "Dumping database ${CLK___DB} to ${BACKUP_DESTINATION}"'

clk command create bash backup.photos \
    --description "Backup photos" \
    --option '--quality:str:Compression quality:high' \
    --body 'echo "Backing up photos with ${CLK___QUALITY} quality to ${BACKUP_DESTINATION}"'


show-backup-commands_code () {
      clk backup --help
}

show-backup-commands_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk backup [OPTIONS] COMMAND [ARGS]...

  Backup operations

  The current parameters set for this command are: --dest /media/external/documents

  Edit this custom command by running `clk command edit backup`
  Or edit ./clk-root/python/backup.py directly.

Options:
  --dest TEXT  Backup destination base directory  [default: /mnt/backup]
  --help-all   Show the full help message, automatic options included.
  --help       Show this message and exit.

Commands:
  database  Backup database
  docs      Automatically created group to organize subcommands
  photos    Backup photos

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-backup-commands'

{ show-backup-commands_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/show-backup-commands"
else
    show-backup-commands_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-backup-commands"
        exit 1
    }
fi



try-all-backups_code () {
      clk backup database
      clk backup photos
}

try-all-backups_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Dumping database main.db to /media/external/documents
Backing up photos with high quality to /media/external/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-all-backups'

{ try-all-backups_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-all-backups"
else
    try-all-backups_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-all-backups"
        exit 1
    }
fi


clk command create bash backup.docs.verify \
    --description "Verify backup integrity" \
    --body 'echo "Verifying backup integrity at ${BACKUP_DESTINATION}..."'

clk command create bash backup.docs.retrieve \
    --description "Retrieve a file from backup" \
    --argument 'filename:str:File to retrieve' \
    --body 'echo "Retrieving ${CLK___FILENAME} from ${BACKUP_DESTINATION}"'


show-docs-group_code () {
      clk backup docs --help
}

show-docs-group_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk backup docs [OPTIONS] COMMAND [ARGS]...

  Automatically created group to organize subcommands

  This is a built in created group. To remove it, simply remove all its subcommands (with `clk command remove SUBCMD`,
  or `clk alias unset SUBCMD`). To rename it, simply rename them (with `clk command rename SUBCMD` or `clk alias rename
  SUBCMD`)

Options:
  --help-all  Show the full help message, automatic options included.
  --help      Show this message and exit.

Commands:
  do        Backup documents to external drive
  retrieve  Retrieve a file from backup
  verify    Verify backup integrity

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-docs-group'

{ show-docs-group_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/show-docs-group"
else
    show-docs-group_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-docs-group"
        exit 1
    }
fi



call-docs-do_code () {
      clk backup docs do
}

call-docs-do_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ~/docs to /media/external/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run call-docs-do'

{ call-docs-do_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/call-docs-do"
else
    call-docs-do_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying call-docs-do"
        exit 1
    }
fi



call-docs-subcommands_code () {
      clk backup docs verify
      clk backup docs retrieve important-notes.txt
}

call-docs-subcommands_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Verifying backup integrity at /media/external/documents...
Retrieving important-notes.txt from /media/external/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run call-docs-subcommands'

{ call-docs-subcommands_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/call-docs-subcommands"
else
    call-docs-subcommands_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying call-docs-subcommands"
        exit 1
    }
fi



set-flowdep_code () {
      clk flowdep set backup.docs.do backup.database
}

set-flowdep_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global flowdep for backup.docs.do: backup.database
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-flowdep'

{ set-flowdep_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/set-flowdep"
else
    set-flowdep_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-flowdep"
        exit 1
    }
fi



run-with-flow_code () {
      clk backup docs do --flow
}

run-with-flow_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Dumping database main.db to /media/external/documents
Backing up documents from ~/docs to /media/external/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-with-flow'

{ run-with-flow_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-with-flow"
else
    run-with-flow_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-with-flow"
        exit 1
    }
fi



create-full-alias_code () {
      clk alias set backup.full backup database , backup docs do , backup photos
}

create-full-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global alias for backup.full: backup database , backup docs do , backup photos
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create-full-alias'

{ create-full-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/create-full-alias"
else
    create-full-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create-full-alias"
        exit 1
    }
fi



run-full-backup_code () {
      clk backup full
}

run-full-backup_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Dumping database main.db to /media/external/documents
Backing up documents from ~/docs to /media/external/documents
Backing up photos with high quality to /media/external/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-full-backup'

{ run-full-backup_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-full-backup"
else
    run-full-backup_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-full-backup"
        exit 1
    }
fi



create-shortcuts_code () {
      clk alias set backup.quick backup docs do --source '~/notes'
      clk alias set backup.work backup docs do --source '~/work/documents'
}

create-shortcuts_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global alias for backup.quick: backup docs do --source '~/notes'
New global alias for backup.work: backup docs do --source '~/work/documents'
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create-shortcuts'

{ create-shortcuts_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/create-shortcuts"
else
    create-shortcuts_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create-shortcuts"
        exit 1
    }
fi



try-shortcuts_code () {
      clk backup quick
      clk backup work
}

try-shortcuts_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ~/notes to /media/external/documents
Backing up documents from ~/work/documents to /media/external/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-shortcuts'

{ try-shortcuts_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-shortcuts"
else
    try-shortcuts_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-shortcuts"
        exit 1
    }
fi


mkdir -p project-a && cd project-a && mkdir .clk


set-project-a-params_code () {
      clk parameter set backup.docs.do --source ./documentation
      clk parameter set backup --dest /mnt/backup/project-a
}

set-project-a-params_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New local parameters for backup.docs.do: --source ./documentation
New local parameters for backup: --dest /mnt/backup/project-a
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-project-a-params'

{ set-project-a-params_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/set-project-a-params"
else
    set-project-a-params_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-project-a-params"
        exit 1
    }
fi



run-in-project-a_code () {
      clk backup docs do
}

run-in-project-a_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ./documentation to /mnt/backup/project-a
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-in-project-a'

{ run-in-project-a_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-in-project-a"
else
    run-in-project-a_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-in-project-a"
        exit 1
    }
fi



leave-project_code () {
      cd ..
      clk backup docs do
}

leave-project_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ~/docs to /media/external/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run leave-project'

{ leave-project_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/leave-project"
else
    leave-project_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying leave-project"
        exit 1
    }
fi


clk extension create "$(hostname)"


set-hostname-params_code () {
      clk parameter --extension "$(hostname)" set backup --dest /mnt/my-nas/documents
}

set-hostname-params_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global/myhostname parameters for backup: --dest /mnt/my-nas/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run set-hostname-params'

{ set-hostname-params_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/set-hostname-params"
else
    set-hostname-params_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying set-hostname-params"
        exit 1
    }
fi



run-with-hostname_code () {
      clk backup docs do
}

run-with-hostname_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ~/docs to /mnt/my-nas/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-with-hostname'

{ run-with-hostname_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-with-hostname"
else
    run-with-hostname_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-with-hostname"
        exit 1
    }
fi


cd project-a


run-in-project-a-hostname_code () {
      clk backup docs do
}

run-in-project-a-hostname_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ./documentation to /mnt/backup/project-a
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-in-project-a-hostname'

{ run-in-project-a-hostname_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-in-project-a-hostname"
else
    run-in-project-a-hostname_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-in-project-a-hostname"
        exit 1
    }
fi


cd ..


try-disable-hostname_code () {
      clk extension disable "$(hostname)"
      clk backup docs do
}

try-disable-hostname_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Backing up documents from ~/docs to /mnt/my-nas/documents
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-disable-hostname'

{ try-disable-hostname_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-disable-hostname"
else
    try-disable-hostname_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-disable-hostname"
        exit 1
    }
fi


clk extension remove "$(hostname)"


final-help_code () {
      clk backup --help
}

final-help_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk backup [OPTIONS] COMMAND [ARGS]...

  Backup operations

  The current parameters set for this command are: --dest /media/external/documents

  Edit this custom command by running `clk command edit backup`
  Or edit ./clk-root/python/backup.py directly.

Options:
  --dest TEXT  Backup destination base directory  [default: /mnt/backup]
  --help-all   Show the full help message, automatic options included.
  --help       Show this message and exit.

Commands:
  database  Backup database
  docs      Automatically created group to organize subcommands
  full      Alias for: backup database , backup docs do , backup...
  photos    Backup photos
  quick     Alias for: backup docs do --source '~/notes'
  work      Alias for: backup docs do --source '~/work/documents'

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run final-help'

{ final-help_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/final-help"
else
    final-help_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying final-help"
        exit 1
    }
fi
# summary:1 ends here
