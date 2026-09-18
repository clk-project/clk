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
