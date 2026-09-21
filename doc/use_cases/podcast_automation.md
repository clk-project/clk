- [filtering by directory](#filtering-by-directory)
- [discovering all podcast commands at a glance](#getting-help-on-groups-with-aliases)
- [the state of an episode, shared by several commands](#6cf69e7a-e155-41dc-896f-a1ed940d42cd)

When listening to podcast, I like to download some episode up front.

```python
@podcast.command()
@option('--number', type=int, default=10, help='How many episodes to download at once')
def download(number):
    'Downloading podcasts'
    print(f'Downloading {number} episodes')
```

```bash
clk podcast download
```

    Downloading 10 episodes

Now, I want this command to be wrapped into an alias to ease making it part of more complicated flows. I want to control the number of podcast to download using an environment variable, hence the use of the 'tpl:' pattern appears appropriate.

```bash
clk alias set podcast.dwim echo 'Would do something before' , podcast download --number 'noeval:tpl:{NUMBER_TO_DOWNLOAD}' , echo 'would do something after'
```

    New global alias for podcast.dwim: echo 'Would do something before' , podcast download --number 'tpl:{NUMBER_TO_DOWNLOAD}' , echo 'would do something after'

Then I can call it with:

```bash
export NUMBER_TO_DOWNLOAD=100
clk podcast dwim
```

    Would do something before
    Downloading 100 episodes
    would do something after

Note that it needs the environment variable to be set, or it will raise an error.

A download that stops halfway should not leave anything in my collection, so let's write the episode in a temporary place and move it in when it is done.

```python
from pathlib import Path

from clk.lib import createfile, makedirs, move, tempdir


@podcast.command()
@argument('episode', help='The episode to download')
def get(episode):
    'Download an episode'
    collection = Path('music')
    with tempdir() as workspace:
        downloading = Path(workspace) / episode
        createfile(downloading, 'some audio\n')
        makedirs(collection)
        move(downloading, collection / episode)
    createfile(collection / 'fetched.txt', f'{episode}\n', append=True)
```

```bash
clk podcast get episode-1.mp3
clk podcast get episode-2.mp3
ls music
cat music/fetched.txt
```

    episode-1.mp3
    episode-2.mp3
    fetched.txt
    episode-1.mp3
    episode-2.mp3


<a id="filtering-by-directory"></a>

# filtering by directory

As my podcast collection grows, I organize episodes into directories: music, stories, news, etc. I want to add a `--directory` option to the podcast group so I can filter which directories to work with.

```python
@group()
@option('--directory', '-d', multiple=True, help='Only work with these directories')
def podcast(directory):
    'Dealing with podcasts'
    if directory:
        print(f'Filtering to directories: {', '.join(directory)}')
```

Now I can filter downloads to specific directories:

```bash
clk podcast --directory music download
```

    Filtering to directories: music
    Downloading 10 episodes

I frequently work with my music podcasts, so I create an alias to save typing:

```bash
clk alias set podcast.music podcast --directory music download
```

    New global alias for podcast.music: podcast --directory music download

Now `clk podcast music` is a shortcut for downloading music podcasts:

```bash
clk podcast music
```

    Filtering to directories: music
    Downloading 10 episodes

The `--directory music` option from the alias is correctly passed to the podcast group, and the download command runs as expected.

I can also create an alias that filters multiple directories at once. For instance, I want a shortcut for all my audio entertainment (music and songs):

```bash
clk alias set podcast.audio podcast --directory music --directory song download
```

    New global alias for podcast.audio: podcast --directory music --directory song download

Now `clk podcast audio` downloads from both directories:

```bash
clk podcast audio
```

    Filtering to directories: music, song
    Downloading 10 episodes

Both directory options are passed correctly to the podcast group.


<a id="getting-help-on-groups-with-aliases"></a>

# discovering all podcast commands at a glance

Now that we have several ways to download podcasts—the base `download` command plus specialized shortcuts like `music` and `audio~—it's helpful to see them all in one place. Running ~--help` on the podcast group shows the complete picture.

```bash
clk podcast --help
```

```
Usage: clk podcast [OPTIONS] COMMAND [ARGS]...

  Dealing with podcasts

  Edit this custom command by running `clk command edit podcast`
  Or edit ./clk-root/python/podcast.py directly.

Options:
  -d, --directory TEXT  Only work with these directories
  --help-all            Show the full help message, automatic options included.
  --help                Show this message and exit.

Commands:
  audio     Alias for: podcast --directory music --directory son...
  download  Downloading podcasts
  dwim      Alias for: echo 'Would do something before' , podcas...
  music     Alias for: podcast --directory music download
```

This gives us a quick overview of all our podcast-related commands: the core `download` command and the shortcuts we created (`audio`, `music`, `dwim`). Each alias shows a brief description of what it does, making it easy to remember which shortcut to use for different podcast categories.


<a id="6cf69e7a-e155-41dc-896f-a1ed940d42cd"></a>

# the state of an episode, shared by several commands

An episode comes in `todo`. It goes to `to-process` to have its audio extracted, then to `next` to wait, then to `ready` when it moves to my phone, and to `done` once I have listened to it. Several commands take that state, some of them bash scripts. I write the list once in python, beside the rest of my podcast code.

```python
from clk.types import Suggestion

STATES = ["todo", "to-process", "next", "ready", "done"]

stateType = Suggestion(STATES)
```

```bash
mkdir -p lib
cat<<'EOF' > lib/podcastlib.py
from clk.types import Suggestion

STATES = ["todo", "to-process", "next", "ready", "done"]

stateType = Suggestion(STATES)
EOF
export PYTHONPATH="$(pwd)/lib"
```

The usage of the bash command names the module and the type in it.

```bash
#!/usr/bin/env bash
set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Extract the audio of the episodes in that state
--
O:--state:podcastlib.stateType:The state of the episodes to extract the audio of:to-process
EOF
}

clk_help_handler "$@"

echo "extracting the audio of the episodes in state $(clk_value state)"
```

```bash
clk podcast extract-audio
```

    extracting the audio of the episodes in state to-process

```bash
clk podcast extract-audio --state <TAB>
```

    todo
    to-process
    next
    ready
    done

Add a state in python, and the command offers it.

```bash
sed -i 's/"done"]/"done", "to-digest"]/' lib/podcastlib.py
```

    todo
    to-process
    next
    ready
    done
    to-digest
