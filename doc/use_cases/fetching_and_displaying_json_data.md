- [Fetching and displaying JSON](#orgfaf6537)
- [Filtering the data](#org4410e16)
- [Caching the downloaded data](#org00a4d80)

A common use case when building CLI tools is fetching data from an API and displaying it to the user. This example shows how to create a command that downloads JSON data and outputs it in a nicely formatted way.

Let's create a tool to fetch and display school holidays data.


<a id="orgfaf6537"></a>

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

```
[
    {
        "description": "Vacances de No\u00ebl",
        "end_date": "2025-01-06",
        "location": "Zone A",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2024-12-21"
    },
    {
        "description": "Vacances de No\u00ebl",
        "end_date": "2025-01-06",
        "location": "Zone B",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2024-12-21"
    },
    {
        "description": "Vacances d'hiver",
        "end_date": "2025-02-24",
        "location": "Zone A",
```


<a id="org4410e16"></a>

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

```
[
    {
        "description": "Vacances de No\u00ebl",
        "end_date": "2025-01-06",
        "location": "Zone A",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2024-12-21"
    },
    {
        "description": "Vacances d'hiver",
        "end_date": "2025-02-24",
        "location": "Zone A",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2025-02-08"
    },
    {
        "description": "Vacances de printemps",
        "end_date": "2025-04-22",
        "location": "Zone A",
        "population": "\u00c9l\u00e8ves",
        "start_date": "2025-04-05"
    }
]
```


<a id="org00a4d80"></a>

# Caching the downloaded data

If you're going to call this command frequently, you might want to cache the downloaded data to avoid repeated network requests. See [scrapping the web](scrapping_the_web.md) for how to use `cache_disk` to cache the results.
