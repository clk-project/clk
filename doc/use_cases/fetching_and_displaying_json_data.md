- [Fetching and displaying JSON](#fetching-and-displaying-json)
- [Filtering the data](#filtering-the-data)
- [Caching the downloaded data](#caching-the-downloaded-data)

A common use case when building CLI tools is fetching data from an API and displaying it to the user. This example shows how to create a command that downloads JSON data and outputs it in a nicely formatted way.

Let's create a tool to fetch and display school holidays data.


<a id="fetching-and-displaying-json"></a>

# Fetching and displaying JSON

First, let's create the group of commands.

```bash
clk command create python --group holidays --description "Fetch and display school holidays"
```

We'll use `download` from `clk.lib` to fetch the JSON file and `echo_json` to display it with syntax highlighting.

```python
def fetch_holidays():
    """Download and parse the holidays JSON file."""
    url = "https://github.com/clk-project/clk/raw/main/tests/holidays.json"
    with temporary_file(suffix=".json") as f:
        download(url, outdir=Path(f.name).parent, outfilename=Path(f.name).name)
        return json.loads(Path(f.name).read_text())
```

Now let's create the `cat` command that dumps the raw JSON data.

```python
@holidays.command()
def cat():
    """Dump the holidays data as JSON."""
    echo_json(fetch_holidays())
```

When your command needs to output structured data, `echo_json` from `clk.lib` provides formatted and syntax-highlighted JSON output. The output is automatically colorized in terminals that support colors. When piping to other commands or in dumb terminals, plain JSON is produced.

Let's try it out.

```bash
clk holidays cat 2>/dev/null | head -19
```

<pre>
[<span style="color:gray;"></span>
<span style="color:gray;">    </span>{<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;description&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Vacances de No\u00ebl&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;end_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2025-01-06&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;location&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Zone A&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;population&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;\u00c9l\u00e8ves&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;start_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2024-12-21&quot;</span><span style="color:gray;"></span>
<span style="color:gray;">    </span>},<span style="color:gray;"></span>
<span style="color:gray;">    </span>{<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;description&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Vacances de No\u00ebl&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;end_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2025-01-06&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;location&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Zone B&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;population&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;\u00c9l\u00e8ves&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;start_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2024-12-21&quot;</span><span style="color:gray;"></span>
<span style="color:gray;">    </span>},<span style="color:gray;"></span>
<span style="color:gray;">    </span>{<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;description&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Vacances d'hiver&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;end_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2025-02-24&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;location&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Zone A&quot;</span>,<span style="color:gray;"></span>
</pre>


<a id="filtering-the-data"></a>

# Filtering the data

Now let's add a command that filters holidays by location.

```python
@holidays.command()
@argument("location", help="Location to filter by (e.g., 'Zone A')")
def show(location):
    """Show holidays for a specific location."""
    data = fetch_holidays()
    filtered = [h for h in data if h["location"] == location]
    echo_json(filtered)
```

```bash
clk holidays show "Zone A" 2>/dev/null
```

<pre>
[<span style="color:gray;"></span>
<span style="color:gray;">    </span>{<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;description&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Vacances de No\u00ebl&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;end_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2025-01-06&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;location&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Zone A&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;population&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;\u00c9l\u00e8ves&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;start_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2024-12-21&quot;</span><span style="color:gray;"></span>
<span style="color:gray;">    </span>},<span style="color:gray;"></span>
<span style="color:gray;">    </span>{<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;description&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Vacances d'hiver&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;end_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2025-02-24&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;location&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Zone A&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;population&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;\u00c9l\u00e8ves&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;start_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2025-02-08&quot;</span><span style="color:gray;"></span>
<span style="color:gray;">    </span>},<span style="color:gray;"></span>
<span style="color:gray;">    </span>{<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;description&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Vacances de printemps&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;end_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2025-04-22&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;location&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;Zone A&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;population&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;\u00c9l\u00e8ves&quot;</span>,<span style="color:gray;"></span>
<span style="color:gray;">        </span><span style="filter: contrast(70%) brightness(190%);color:blue;">&quot;start_date&quot;</span>:<span style="color:gray;"> </span><span style="color:olive;">&quot;2025-04-05&quot;</span><span style="color:gray;"></span>
<span style="color:gray;">    </span>}<span style="color:gray;"></span>
]<span style="color:gray;"></span>
</pre>


<a id="caching-the-downloaded-data"></a>

# Caching the downloaded data

If you're going to call this command frequently, you might want to cache the downloaded data to avoid repeated network requests. See [scrapping the web](scrapping_the_web.md) for how to use `cache_disk` to cache the results.
