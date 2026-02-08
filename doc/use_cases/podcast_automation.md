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
