- [how old they are](#how-old-they-are)

Everything you scan, download or write ends up in the same folder, and after a while you have no idea what landed there this week.

```bash
mkdir documents && cd documents
touch -d 2024-02-01 minutes.txt
touch -d 2024-02-12 invoice.txt
touch -d 2024-02-14 receipt.txt
```

A command answering "what is new since when?" needs a day to work from, and `date` is the type for that.

```bash
A:since:date:The day to look back to
```

clk hands your script the day it understood, in a shape `date` will take.

```bash
find . -maxdepth 1 -type f -newermt "$(date -d"$(clk_value since)" "+%Y-%m-%d")" -printf "%f\n" | sort
```

Today is the 15th of February 2024. Here is what came in since the 10th.

```bash
clk find-new-documents 2024-02-10
```

    invoice.txt
    receipt.txt

You seldom think in dates, though. You think "since yesterday", and the type reads that too.

```bash
clk find-new-documents yesterday
```

    receipt.txt


<a id="how-old-they-are"></a>

# how old they are

Knowing what is new is one thing, knowing how old it is another, and `natural_time` says it the way you would.

```python
from datetime import datetime
from pathlib import Path

from clk.decorators import command
from clk.lib import natural_delta, natural_time


@command()
def howold():
    """Say how old the documents are"""
    times = []
    for path in sorted(Path(".").glob("*.txt")):
        when = datetime.fromtimestamp(path.stat().st_mtime).astimezone()
        times.append(when)
        print(f"{path.name}: {natural_time(when)}")
    print(f"{natural_delta(max(times) - min(times))} between the oldest and the newest")
```

```bash
clk howold
```

    invoice.txt: 2 days ago
    minutes.txt: 13 days ago
    receipt.txt: 23 hours ago
    13 days 0 hour between the oldest and the newest
