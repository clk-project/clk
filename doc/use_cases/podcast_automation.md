- [filtering by directory](#filtering-by-directory)
- [discovering all podcast commands at a glance](#getting-help-on-groups-with-aliases)

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
