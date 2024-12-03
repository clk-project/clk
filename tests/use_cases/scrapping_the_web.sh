#!/bin/bash -eu
# [[file:../../doc/use_cases/choices.org::run][run]]
. ./sandboxing.sh
clk command create python --force --group --body '
def code_that_fetches_the_content_of(url):
  LOGGER.info(f"Getting the content of {url}")
  return {"title": "clk project", "h1": "./ clk"}

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
    click.echo("The topic is " + config.soup.get("h1"))
' scrap

running_the_test_code () {
      clk scrap --url "http://clk-project.org" title
      clk scrap --url "http://clk-project.org" topic
}

running_the_test_expected () {
      cat<<"EOEXPECTED"
Getting the content of http://clk-project.org
The title is clk project
Getting the content of http://clk-project.org
The topic is ./ clk
EOEXPECTED
}

diff -uBw <(running_the_test_code 2>&1) <(running_the_test_expected) || {
echo "Something went wrong when trying running_the_test"
exit 1
}

clk command create python --force --group --body '
from clk.core import cache_disk

@cache_disk(expire=3600)
def code_that_fetches_the_content_of(url):
  LOGGER.info(f"Getting the content of {url}")
  return {"title": "clk project", "h1": "./ clk"}

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
    click.echo("The topic is " + config.soup.get("h1"))
' scrap

running_the_test_with_cache_code () {
      clean_cache
      init_faked_time

      clk scrap --url "http://clk-project.org" title

      sleep 3500
      echo "After 3500 seconds of waiting, it gets the result from the cache"
      clk scrap --url "http://clk-project.org" title

      sleep 200
      echo "After a 200 seconds, the cache is older than 3600s and is fetched again"
      clk scrap --url "http://clk-project.org" title

      stop_faked_time
}

running_the_test_with_cache_expected () {
      cat<<"EOEXPECTED"
Getting the content of http://clk-project.org
The title is clk project
After 3500 seconds of waiting, it gets the result from the cache
The title is clk project
After a 200 seconds, the cache is older than 3600s and is fetched again
Getting the content of http://clk-project.org
The title is clk project
EOEXPECTED
}

diff -uBw <(running_the_test_with_cache_code 2>&1) <(running_the_test_with_cache_expected) || {
echo "Something went wrong when trying running_the_test_with_cache"
exit 1
}

clk command create python --force --group --body '
from clk.core import cache_disk

@cache_disk(expire=65, renew=True)
def code_that_fetches_the_content_of(url):
  LOGGER.info(f"Getting the content of {url}")
  return {"title": "clk project", "h1": "./ clk"}

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
    click.echo("The topic is " + config.soup.get("h1"))
' scrap

running_the_test_with_cache_with_renew_code () {
      init_faked_time
      clean_cache

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

      stop_faked_time
}

running_the_test_with_cache_with_renew_expected () {
      cat<<"EOEXPECTED"
At Thu Feb 15 00:00:00 CET 2024, running the commands for the first time -> the page is fetched and its content is cached
Getting the content of http://clk-project.org
The title is clk project
At Thu Feb 15 00:01:00 CET 2024, after having waited for 60s, slightly less than the expiration time of 65s, the cached content is got and the cache is renewed
The title is clk project
At Thu Feb 15 00:02:00 CET 2024, after having waited again for 60s, again slightly less than the expiration time of 65s, the cached content is got and the cache is renewed
The title is clk project
Therefore, the cached content, whose expiration is set to 65s, was kept for 120s, thanks to the renewal
At Thu Feb 15 00:03:20 CET 2024, after having waited 80s, hence slightly more than the expiration time of 65s, the content expired and the page is fetched again
Getting the content of http://clk-project.org
The title is clk project

EOEXPECTED
}

diff -uBw <(running_the_test_with_cache_with_renew_code 2>&1) <(running_the_test_with_cache_with_renew_expected) || {
echo "Something went wrong when trying running_the_test_with_cache_with_renew"
exit 1
}
# run ends here
