- [starting with a backup group](#org1b09af2)
- [persisting the destination](#org8d69ac8)
- [adding more backup targets](#orgda14215)
- [organizing with nested groups](#org8bac0ba)
- [chaining backups with flows](#org925c995)
- [creating a full backup alias](#org8098521)
- [shortcut aliases for common scenarios](#orgecc405e)
- [per-project backup configuration](#orgb73bc95)
- [personal preferences with a hostname extension](#org9e9eb34)
- [seeing everything at a glance](#orgbe45cf5)
- [summary](#org2582d36)

I have years of personal documents - notes, scanned papers, receipts, photos of whiteboards. I want a command line tool to back them up reliably. This use case shows how to build a document backup system with clk, starting simple and growing as needs evolve.


<a id="org1b09af2"></a>

# starting with a backup group

First, I need a group to hold all backup-related commands. I create a Python group called `backup` that sets a `BACKUP_DESTINATION` environment variable. All subcommands - even bash ones - will have access to it.

```bash
clk command create python backup --group --description "Backup operations"
```

The code for the group looks like this:

```python
from clk.config import config
from clk.decorators import group, option


@group()
@option("--dest", default="/mnt/backup", help="Backup destination base directory")
def backup(dest):
    "Backup operations"
    config.override_env["BACKUP_DESTINATION"] = dest
    config.init()
```

The key line is `config.override_env["BACKUP_DESTINATION"] = dest`. This makes the `BACKUP_DESTINATION` environment variable available to all subcommands, including bash commands.

Now I create a bash command to back up my docs. Since I want it nested under the `backup` group and inside a `docs` subgroup, I name it `backup.docs.do`. clk automatically creates the intermediate `docs` group.

```bash
clk command create bash backup.docs.do \
    --description "Backup documents to external drive" \
    --option '--source:str:Source directory:~/docs' \
    --body 'echo "Backing up documents from ${CLK___SOURCE} to ${BACKUP_DESTINATION}"'
```

Let's try it.

```bash
clk backup docs do
```

    Backing up documents from ~/docs to /mnt/backup

The bash command automatically has access to `BACKUP_DESTINATION` because the parent group set it in `config.override_env`.

The `backup` group now has a `docs` subgroup.

```bash
clk backup --help
```

```
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
```


<a id="org8d69ac8"></a>

# persisting the destination

I always backup to the same external drive. Rather than typing `--dest` every time, I persist it as a parameter on the `backup` group. Since `BACKUP_DESTINATION` is set from this option, all subcommands benefit.

```bash
clk parameter set backup --dest /media/external/documents
```

    New global parameters for backup: --dest /media/external/documents

Now the command uses my preferred destination automatically.

```bash
clk backup docs do
```

    Backing up documents from ~/docs to /media/external/documents

I can still override it when needed.

```bash
clk backup --dest /tmp/quick-backup docs do
```

    Backing up documents from ~/docs to /tmp/quick-backup


<a id="orgda14215"></a>

# adding more backup targets

My backup needs grow. I want to back up my database and photos too. I create sibling commands under the `backup` group. They all use the same `BACKUP_DESTINATION` environment variable set by the group.

```bash
clk command create bash backup.database \
    --description "Backup database" \
    --option '--db:str:Database name:main.db' \
    --body 'echo "Dumping database ${CLK___DB} to ${BACKUP_DESTINATION}"'
```

```bash
clk command create bash backup.photos \
    --description "Backup photos" \
    --option '--quality:str:Compression quality:high' \
    --body 'echo "Backing up photos with ${CLK___QUALITY} quality to ${BACKUP_DESTINATION}"'
```

Now my backup group has three commands.

```bash
clk backup --help
```

```
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
```

```bash
clk backup database
clk backup photos
```

    Dumping database main.db to /media/external/documents
    Backing up photos with high quality to /media/external/documents

Notice how both commands use `/media/external/documents` - the destination I persisted on the `backup` group. I didn't have to configure it on each command separately.


<a id="org8bac0ba"></a>

# organizing with nested groups

As my backup system grows, I need sub-operations for documents. I want commands to verify backups and retrieve files. I simply create commands with dots in their names - clk automatically created the intermediate `docs` group when I first created `backup.docs.do`.

```bash
clk command create bash backup.docs.verify \
    --description "Verify backup integrity" \
    --body 'echo "Verifying backup integrity at ${BACKUP_DESTINATION}..."'
```

```bash
clk command create bash backup.docs.retrieve \
    --description "Retrieve a file from backup" \
    --argument 'filename:str:File to retrieve' \
    --body 'echo "Retrieving ${CLK___FILENAME} from ${BACKUP_DESTINATION}"'
```

Now `backup docs` is a group with several subcommands. All of them have access to `BACKUP_DESTINATION` from the parent `backup` group.

```bash
clk backup docs --help
```

```
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
```

I can call the backup command directly.

```bash
clk backup docs do
```

    Backing up documents from ~/docs to /media/external/documents

Or use the subcommands.

```bash
clk backup docs verify
clk backup docs retrieve important-notes.txt
```

    Verifying backup integrity at /media/external/documents...
    Retrieving important-notes.txt from /media/external/documents


<a id="org925c995"></a>

# chaining backups with flows

My documents reference database entries, so I want to ensure the database is backed up before backing up documents. I use flow dependencies.

```bash
clk flowdep set backup.docs.do backup.database
```

    New global flowdep for backup.docs.do: backup.database

Now when I run `backup docs do` with `--flow`, it first backs up the database.

```bash
clk backup docs do --flow
```

    Dumping database main.db to /media/external/documents
    Backing up documents from ~/docs to /media/external/documents


<a id="org8098521"></a>

# creating a full backup alias

I want a single command to back up everything. I create an alias that chains all backup commands.

```bash
clk alias set backup.full backup database , backup docs do , backup photos
```

    New global alias for backup.full: backup database , backup docs do , backup photos

```bash
clk backup full
```

    Dumping database main.db to /media/external/documents
    Backing up documents from ~/docs to /media/external/documents
    Backing up photos with high quality to /media/external/documents


<a id="orgecc405e"></a>

# shortcut aliases for common scenarios

I create aliases for frequent backup patterns.

```bash
clk alias set backup.quick backup docs do --source '~/notes'
clk alias set backup.work backup docs do --source '~/work/documents'
```

    New global alias for backup.quick: backup docs do --source '~/notes'
    New global alias for backup.work: backup docs do --source '~/work/documents'

```bash
clk backup quick
clk backup work
```

    Backing up documents from ~/notes to /media/external/documents
    Backing up documents from ~/work/documents to /media/external/documents


<a id="orgb73bc95"></a>

# per-project backup configuration

Different projects have different backup needs. I use project-local parameters so backup commands do the right thing depending on where I am.

```bash
mkdir -p project-a && cd project-a && mkdir .clk
```

I set the source directory on the `backup.docs.do` command, and the destination on the `backup` group. Since the destination is on the group, it affects all backup commands in this project - documents, database, photos.

```bash
clk parameter set backup.docs.do --source ./documentation
clk parameter set backup --dest /mnt/backup/project-a
```

    New local parameters for backup.docs.do: --source ./documentation
    New local parameters for backup: --dest /mnt/backup/project-a

```bash
clk backup docs do
```

    Backing up documents from ./documentation to /mnt/backup/project-a

When I leave the project, global settings take over.

```bash
cd ..
clk backup docs do
```

    Backing up documents from ~/docs to /media/external/documents


<a id="org9e9eb34"></a>

# personal preferences with a hostname extension

I want my personal backup to go to my own NAS, regardless of any project I'm in. The solution is to create an extension named after my hostname and put my personal preferences there.

```bash
clk extension create "$(hostname)"
```

I set my personal backup destination inside this extension.

```bash
clk parameter --extension "$(hostname)" set backup --dest /mnt/my-nas/documents
```

    New global/myhostname parameters for backup: --dest /mnt/my-nas/documents

Outside any project, the extension's destination is used.

```bash
clk backup docs do
```

    Backing up documents from ~/docs to /media/external/documents

Inside a project that defines its own `--dest`, the project-local parameters take precedence. This is useful when a shared project needs a specific backup destination that everyone on the team should use.

```bash
cd project-a
```

```bash
clk backup docs do
```

    Backing up documents from ./documentation to /mnt/backup/project-a

Note that clk will always enable the extension matching your hostname, even if you explicitly disable it in a project. Let's try it.

```bash
clk extension disable "$(hostname)"
clk extension show | grep myhostname
```

    myhostname        local            global

Even after disabling, the hostname extension remains active. This is practical to put personal preferences that apply everywhere, while still respecting project-specific overrides when they exist.

```bash
cd ..
clk extension remove "$(hostname)"
```


<a id="orgbe45cf5"></a>

# seeing everything at a glance

As the backup system grows, I can see all available commands with `--help`.

```bash
clk backup --help
```

```
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
```

This gives me a complete overview: the core commands (`database`, `docs`, `photos`), the convenience aliases (`full`, `quick`, `work`), and I can drill down into any group for more details.


<a id="org2582d36"></a>

# summary

This use case demonstrates several clk patterns working together:

-   **shared environment variables**: the `backup` group sets `BACKUP_DESTINATION` for all subcommands
-   **hierarchical commands**: `backup.docs.do`, `backup.database` organize naturally
-   **auto-created groups**: creating `backup.docs.do` automatically creates the `docs` group
-   **persisted parameters**: set once on the group, used by all subcommands
-   **flow dependencies**: chain dependent operations
-   **aliases**: create shortcuts for common patterns
-   **per-project config**: same command, different behavior based on location
-   **hostname extensions**: personal preferences that apply globally

Starting from a single backup command, we built a complete backup system that's easy to use, easy to extend, and self-documenting through `--help`.
