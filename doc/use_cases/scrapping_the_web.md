I sometimes need to extract some date from some HTML page. Those pages barely change, so I need to fetch them only once in a while.

This article is not actually about scrapping the data. `requests` and `BeautifulSoup` already provide what I generally need. It is more about making sure I don't run to many unnecessary requests against the site because it is not polite, and I will eventually reach some uncomfortable rate limit.

For the scope of this article, I will mock the scrapping part<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup> with the following code.

```python
def code_that_fetches_the_content_of(url):
  LOGGER.info(f"Getting the content of {url}")
  return {"title": "clk project", "h1": "clk is awesome"}
```

Each time we see the message `Getting the content of X`, we can assume there would have been an HTTP request in real life.

Let's consider this group of commands, a straightforward implementation to get the data and print it when needed.

```python
@group()
@option("--url", required=True, help="The site to scrap")
def scrap(url):
    "Extract some data from the clk website"
    config.soup = code_that_fetches_the_content_of(url)

@scrap.command()
def title():
    "Show the title of the website"
    click.echo("The title is " + config.soup.get("title"))

@scrap.command()
def topic():
    "Show the topic of the site"
    click.echo(f"""The topic is "{config.soup.get("h1")}".""")
```

Those are valid commands and can be run easily.

```bash
clk scrap --url "http://clk-project.org" title
clk scrap --url "http://clk-project.org" topic
```

    Getting the content of http://clk-project.org
    The title is clk project
    Getting the content of http://clk-project.org
    The topic is "clk is awesome".

This does the job, but it fetches the page every time the command is run. If the page is not expected to change often, and the command is supposed to be run a lot, it would be polite to cache the HTML content.

`clk` provides out of the box the `cache_disk` decorator.

```python
from clk.core import cache_disk
```

That you use on top of the function you want to cache.

```python
@cache_disk(expire=3600)
def code_that_fetches_the_content_of(url):
  LOGGER.info(f"Getting the content of {url}")
  return {"title": "clk project", "h1": "clk is awesome"}
```

Using that decorator, that keeps the content for 1 hour, you get

```bash
date
clk scrap --url "http://clk-project.org" title

sleep 3500
echo "After 3500 seconds of waiting, it gets the result from the cache"
date
clk scrap --url "http://clk-project.org" title
sleep 200
echo "After a 200 seconds, the cache is older than 3600s and is fetched again"
date
clk scrap --url "http://clk-project.org" title
```

```
Thu Feb 15 00:00:00 CET 2024
Getting the content of http://clk-project.org
The title is clk project
After 3500 seconds of waiting, it gets the result from the cache
Thu Feb 15 00:58:20 CET 2024
The title is clk project
After a 200 seconds, the cache is older than 3600s and is fetched again
Thu Feb 15 01:01:40 CET 2024
Getting the content of http://clk-project.org
The title is clk project
```

The first call fetches the page and puts its result in the cache. A proof of this is that we can see the log "Getting the content of&hellip;".

3500s (less than one hour) later, the cache has not yet expired and we get the content without fetching again. Indeed, we see the result but not the associated log.

Then, 200s later, hence after 3700s (more than one hour), the cache is invalid and we get back the content. That is shown by the log appearing once again.

Now, a pattern that I use sometimes is that I renew the cache everytime I get it. That way when I run several commands in a short period, the cache is kept. But I wait a bit, the cache is cleaned. That allows me to have shorter expiration while still be able to keep the cache a long time when I heavily use it (like in a flow).

This can be done with this change of code.

```python
@cache_disk(expire=65, renew=True)
def code_that_fetches_the_content_of(url):
  LOGGER.info(f"Getting the content of {url}")
  return {"title": "clk project", "h1": "clk is awesome"}
```

```bash
echo "At $(date), running the commands for the first time -> the page is fetched and its content is cached"
clk scrap --url "http://clk-project.org" title
sleep 60
echo "At $(date), after having waited for 60s, slightly less than the expiration time of 65s, the cached content is got and the cache is renewed"
clk scrap --url "http://clk-project.org" title
sleep 60
echo "At $(date), after having waited again for 60s, again slightly less than the expiration time of 65s, the cached content is got and the cache is renewed"
clk scrap --url "http://clk-project.org" title
echo "Therefore, the cached content, whose expiration is set to 65s, was kept for 120s, thanks to the renewal"
sleep 80
echo "At $(date), after having waited 80s, hence slightly more than the expiration time of 65s, the content expired and the page is fetched again"
clk scrap --url "http://clk-project.org" title
```

```
At Thu Feb 15 01:01:40 CET 2024, running the commands for the first time -> the page is fetched and its content is cached
Getting the content of http://clk-project.org
The title is clk project
At Thu Feb 15 01:02:40 CET 2024, after having waited for 60s, slightly less than the expiration time of 65s, the cached content is got and the cache is renewed
The title is clk project
At Thu Feb 15 01:03:40 CET 2024, after having waited again for 60s, again slightly less than the expiration time of 65s, the cached content is got and the cache is renewed
The title is clk project
Therefore, the cached content, whose expiration is set to 65s, was kept for 120s, thanks to the renewal
At Thu Feb 15 01:05:00 CET 2024, after having waited 80s, hence slightly more than the expiration time of 65s, the content expired and the page is fetched again
Getting the content of http://clk-project.org
The title is clk project
```

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> In real life, it would look like this (untested) code

```python
import requests
from bs4 import BeautifulSoup as soup
def code_that_fetches_the_content_of(url):
  return soup(requests.get(url).text)
```
