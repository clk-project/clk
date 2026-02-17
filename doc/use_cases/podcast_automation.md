- [filtering by directory](#filtering-by-directory)

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
