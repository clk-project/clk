#!/bin/bash -eu
# [[file:../../doc/use_cases/backing_up_documents.org::*summary][summary:1]]
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
      cat<<"EOEXPECTED"
Backing up documents from ~/docs to /mnt/backup
EOEXPECTED
}

echo 'Run try-backup-docs-do'

{ try-backup-docs-do_code || true ; } > "${TMP}/code.txt" 2>&1
try-backup-docs-do_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-backup-docs-do"
exit 1
}



show-backup-help_code () {
      clk backup --help
}

show-backup-help_expected () {
      cat<<"EOEXPECTED"
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
}

echo 'Run show-backup-help'

{ show-backup-help_code || true ; } > "${TMP}/code.txt" 2>&1
show-backup-help_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-backup-help"
exit 1
}



set-dest-param_code () {
      clk parameter set backup --dest /media/external/documents
}

set-dest-param_expected () {
      cat<<"EOEXPECTED"
New global parameters for backup: --dest /media/external/documents
EOEXPECTED
}

echo 'Run set-dest-param'

{ set-dest-param_code || true ; } > "${TMP}/code.txt" 2>&1
set-dest-param_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying set-dest-param"
exit 1
}



try-with-param_code () {
      clk backup docs do
}

try-with-param_expected () {
      cat<<"EOEXPECTED"
Backing up documents from ~/docs to /media/external/documents
EOEXPECTED
}

echo 'Run try-with-param'

{ try-with-param_code || true ; } > "${TMP}/code.txt" 2>&1
try-with-param_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-with-param"
exit 1
}



override-param_code () {
      clk backup --dest /tmp/quick-backup docs do
}

override-param_expected () {
      cat<<"EOEXPECTED"
Backing up documents from ~/docs to /tmp/quick-backup
EOEXPECTED
}

echo 'Run override-param'

{ override-param_code || true ; } > "${TMP}/code.txt" 2>&1
override-param_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying override-param"
exit 1
}


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
      cat<<"EOEXPECTED"
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
}

echo 'Run show-backup-commands'

{ show-backup-commands_code || true ; } > "${TMP}/code.txt" 2>&1
show-backup-commands_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-backup-commands"
exit 1
}



try-all-backups_code () {
      clk backup database
      clk backup photos
}

try-all-backups_expected () {
      cat<<"EOEXPECTED"
Dumping database main.db to /media/external/documents
Backing up photos with high quality to /media/external/documents
EOEXPECTED
}

echo 'Run try-all-backups'

{ try-all-backups_code || true ; } > "${TMP}/code.txt" 2>&1
try-all-backups_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-all-backups"
exit 1
}


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
      cat<<"EOEXPECTED"
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
}

echo 'Run show-docs-group'

{ show-docs-group_code || true ; } > "${TMP}/code.txt" 2>&1
show-docs-group_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-docs-group"
exit 1
}



call-docs-do_code () {
      clk backup docs do
}

call-docs-do_expected () {
      cat<<"EOEXPECTED"
Backing up documents from ~/docs to /media/external/documents
EOEXPECTED
}

echo 'Run call-docs-do'

{ call-docs-do_code || true ; } > "${TMP}/code.txt" 2>&1
call-docs-do_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying call-docs-do"
exit 1
}



call-docs-subcommands_code () {
      clk backup docs verify
      clk backup docs retrieve important-notes.txt
}

call-docs-subcommands_expected () {
      cat<<"EOEXPECTED"
Verifying backup integrity at /media/external/documents...
Retrieving important-notes.txt from /media/external/documents
EOEXPECTED
}

echo 'Run call-docs-subcommands'

{ call-docs-subcommands_code || true ; } > "${TMP}/code.txt" 2>&1
call-docs-subcommands_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying call-docs-subcommands"
exit 1
}



set-flowdep_code () {
      clk flowdep set backup.docs.do backup.database
}

set-flowdep_expected () {
      cat<<"EOEXPECTED"
New global flowdep for backup.docs.do: backup.database
EOEXPECTED
}

echo 'Run set-flowdep'

{ set-flowdep_code || true ; } > "${TMP}/code.txt" 2>&1
set-flowdep_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying set-flowdep"
exit 1
}



run-with-flow_code () {
      clk backup docs do --flow
}

run-with-flow_expected () {
      cat<<"EOEXPECTED"
Dumping database main.db to /media/external/documents
Backing up documents from ~/docs to /media/external/documents
EOEXPECTED
}

echo 'Run run-with-flow'

{ run-with-flow_code || true ; } > "${TMP}/code.txt" 2>&1
run-with-flow_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-with-flow"
exit 1
}



create-full-alias_code () {
      clk alias set backup.full backup database , backup docs do , backup photos
}

create-full-alias_expected () {
      cat<<"EOEXPECTED"
New global alias for backup.full: backup database , backup docs do , backup photos
EOEXPECTED
}

echo 'Run create-full-alias'

{ create-full-alias_code || true ; } > "${TMP}/code.txt" 2>&1
create-full-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create-full-alias"
exit 1
}



run-full-backup_code () {
      clk backup full
}

run-full-backup_expected () {
      cat<<"EOEXPECTED"
Dumping database main.db to /media/external/documents
Backing up documents from ~/docs to /media/external/documents
Backing up photos with high quality to /media/external/documents
EOEXPECTED
}

echo 'Run run-full-backup'

{ run-full-backup_code || true ; } > "${TMP}/code.txt" 2>&1
run-full-backup_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-full-backup"
exit 1
}



create-shortcuts_code () {
      clk alias set backup.quick backup docs do --source '~/notes'
      clk alias set backup.work backup docs do --source '~/work/documents'
}

create-shortcuts_expected () {
      cat<<"EOEXPECTED"
New global alias for backup.quick: backup docs do --source '~/notes'
New global alias for backup.work: backup docs do --source '~/work/documents'
EOEXPECTED
}

echo 'Run create-shortcuts'

{ create-shortcuts_code || true ; } > "${TMP}/code.txt" 2>&1
create-shortcuts_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create-shortcuts"
exit 1
}



try-shortcuts_code () {
      clk backup quick
      clk backup work
}

try-shortcuts_expected () {
      cat<<"EOEXPECTED"
Backing up documents from ~/notes to /media/external/documents
Backing up documents from ~/work/documents to /media/external/documents
EOEXPECTED
}

echo 'Run try-shortcuts'

{ try-shortcuts_code || true ; } > "${TMP}/code.txt" 2>&1
try-shortcuts_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-shortcuts"
exit 1
}


mkdir -p project-a && cd project-a && mkdir .clk


set-project-a-params_code () {
      clk parameter set backup.docs.do --source ./documentation
      clk parameter set backup --dest /mnt/backup/project-a
}

set-project-a-params_expected () {
      cat<<"EOEXPECTED"
New local parameters for backup.docs.do: --source ./documentation
New local parameters for backup: --dest /mnt/backup/project-a
EOEXPECTED
}

echo 'Run set-project-a-params'

{ set-project-a-params_code || true ; } > "${TMP}/code.txt" 2>&1
set-project-a-params_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying set-project-a-params"
exit 1
}



run-in-project-a_code () {
      clk backup docs do
}

run-in-project-a_expected () {
      cat<<"EOEXPECTED"
Backing up documents from ./documentation to /mnt/backup/project-a
EOEXPECTED
}

echo 'Run run-in-project-a'

{ run-in-project-a_code || true ; } > "${TMP}/code.txt" 2>&1
run-in-project-a_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-in-project-a"
exit 1
}



leave-project_code () {
      cd ..
      clk backup docs do
}

leave-project_expected () {
      cat<<"EOEXPECTED"
Backing up documents from ~/docs to /media/external/documents
EOEXPECTED
}

echo 'Run leave-project'

{ leave-project_code || true ; } > "${TMP}/code.txt" 2>&1
leave-project_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying leave-project"
exit 1
}


clk extension create "$(hostname)"


set-hostname-params_code () {
      clk parameter --extension "$(hostname)" set backup --dest /mnt/my-nas/documents
}

set-hostname-params_expected () {
      cat<<"EOEXPECTED"
New global/myhostname parameters for backup: --dest /mnt/my-nas/documents
EOEXPECTED
}

echo 'Run set-hostname-params'

{ set-hostname-params_code || true ; } > "${TMP}/code.txt" 2>&1
set-hostname-params_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying set-hostname-params"
exit 1
}



run-with-hostname_code () {
      clk backup docs do
}

run-with-hostname_expected () {
      cat<<"EOEXPECTED"
Backing up documents from ~/docs to /media/external/documents
EOEXPECTED
}

echo 'Run run-with-hostname'

{ run-with-hostname_code || true ; } > "${TMP}/code.txt" 2>&1
run-with-hostname_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-with-hostname"
exit 1
}


cd project-a


run-in-project-a-hostname_code () {
      clk backup docs do
}

run-in-project-a-hostname_expected () {
      cat<<"EOEXPECTED"
Backing up documents from ./documentation to /mnt/backup/project-a
EOEXPECTED
}

echo 'Run run-in-project-a-hostname'

{ run-in-project-a-hostname_code || true ; } > "${TMP}/code.txt" 2>&1
run-in-project-a-hostname_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-in-project-a-hostname"
exit 1
}



try-disable-hostname_code () {
      clk extension disable "$(hostname)"
      clk extension show | grep myhostname
}

try-disable-hostname_expected () {
      cat<<"EOEXPECTED"
myhostname        local            global
EOEXPECTED
}

echo 'Run try-disable-hostname'

{ try-disable-hostname_code || true ; } > "${TMP}/code.txt" 2>&1
try-disable-hostname_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try-disable-hostname"
exit 1
}


cd ..
clk extension remove "$(hostname)"


final-help_code () {
      clk backup --help
}

final-help_expected () {
      cat<<"EOEXPECTED"
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
}

echo 'Run final-help'

{ final-help_code || true ; } > "${TMP}/code.txt" 2>&1
final-help_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying final-help"
exit 1
}
# summary:1 ends here
