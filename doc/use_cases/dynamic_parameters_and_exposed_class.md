When creating complex commands, you will likely want to split its behavior among several subcommands, part of a common group. This is how we recommend to proceed.

Let's imagine for example that you want to create a tool to perform http requests, like an ad-hoc version of httpie specialized for some particular use case you might have in mind.

Let's start by focusing on how you would use such tool.

You most likely want to have a command for each http verb: get, post, put&#x2026;

```bash
clk get http://url/something
clk post http://url/something bodyoftherequest
```

Then, you will most likely want to make the word `http` more explicit, either by [rolling your own command](rolling_your_own.md)

```bash
http get http://url/something
http post http://url/something bodyoftherequest
```

or by creating a group of commands

```bash
clk http get http://url/something
clk http post http://url/something bodyoftherequest
```

I am not fond of the former way of doing as it may result in hiding other tools (in that case, httpie). I will focus on the later use case here.

After some time using this commands, you will likely realize that you have to repeat the base url again and again.

You might want to regroup this repeated concept in the http group, so that it would be called like.

```bash
clk http --base-url http://url get something
clk http --base-url http://url post something --body bodyoftherequest
```

That way, you can make use of parameters to persist that data.

```bash
clk parameter set http --base-url http://url
clk http get something
clk http post something --body bodyoftherequest
```

Or you might want to create aliases for some sites you use a lot, like this:

```bash
clk alias set somesite http --base-url http://url
clk somesite get something
clk somesite post something --body bodyoftherequest
```

Let's get our hands dirty then! There are plenty of ways and patterns to implement this tool. Here, I present the pattern that I converged to after many experiments.

Let's start with the code of the http group.

```python
class HTTPConfig:
    pass

@group()
@option("--base-url", help="The url to use as a basis for all commands", expose_class=HTTPConfig, required=True)
def http():
    "Commands to make http requests"
```

There are a few things to consider here, in particular if you already know click:

1.  the option is given an argument `expose_class` with the value HTTPConfig
2.  clk will make sure there exists in the config singleton an instance of this class with the name http.
    1.  the naming logic is very simple, lowercase the class name and remove the "config" suffix,
3.  clk will set the attribute "base\_url" into this instance, so that any part of the code will be able to read `config.http.base_url` at any time.
4.  clk will not expose this value to the http group of command. That means that the http function is not supposed to expect the "base\_url" variable. Instead, it is suppose to read it from the config of need be.

Then, in the code of the subcommands, I suggest to write all the logic that deals with the interaction with the user (90% of the time, this is simply logging) and call method of HTTPConfig to do the work.

And then, in `HTTPConfig`, you write whatever the real logic.

```python
class HTTPConfig:

    def get(self, path):
        print("Would run the get code")

    def post(self, path, body):
        print("Would run the post code")
```

Because the http instance is created very early, even during completion, you can take advantage of this object to help providing powerful completion.

```python
class HttpPathType(DynamicChoice):
    def choices(self):
        if config.http.base_url == "http://url":
            return ["/a", "/b", "/c"]
        elif config.http.base_url == "http://otherurl":
            return ["/d", "/e", "/f"]
        return []

    def convert(self, value, param, ctx):
        return value
```

Then, by providing the `HttpPathType` to the get and post subcommands, you get a powerful dynamic completion.

All in one, the final code looks like this:

```python
class HTTPConfig:

    def get(self, path):
        print("Would run the get code")

    def post(self, path, body):
        print("Would run the post code")

class HttpPathType(DynamicChoice):
    def choices(self):
        if config.http.base_url == "http://url":
            return ["/a", "/b", "/c"]
        elif config.http.base_url == "http://otherurl":
            return ["/d", "/e", "/f"]
        return []

    def convert(self, value, param, ctx):
        return value

@group()
@option("--base-url", help="The url to use as a basis for all commands", expose_class=HTTPConfig, required=True)
def http():
    "Commands to make http requests"

@http.command()
@argument("path", help="The path to GET", type=HttpPathType())
def get(path):
    "Perform a GET request"
    LOGGER.info(f"GET {config.http.base_url}/{path}")
    res = config.http.get(path)
    LOGGER.info(f"res = {res}")

@http.command()
@argument("path", help="The path to POST to", type=HttpPathType())
@option("--body", help="The body to send")
def post(path, body):
    "Perform a POST request"
    LOGGER.info(f"POST {config.http.base_url}/{path} with body {body}")
    res = config.http.post(path, body)
    LOGGER.info(f"res = {res}")
```

Enough explanation.

Create the http group of commands like this:

```bash
clk command create python --group http
```

Then, in the newly opened file paste the above code.

Try calling the command with:

```bash
clk http --base-url http://url get /path
```

    GET http://url//path
    Would run the get code
    res = None

```bash
clk http --base-url http://url post /path --body somebody
```

    POST http://url//path with body somebody
    Would run the post code
    res = None

But also, you get the completion that depends on what value you gave for `--base-url`.

```bash
clk http --base-url "http://url" get <TAB>
```

    /a /b /c

```bash
clk http --base-url "http://otherurl" get <TAB>
```

    /d /e /f

Now, let's try creating an alias to play with somesite, as explained above.

```bash
clk alias set somesite http --base-url http://url
clk somesite get something
clk somesite post something --body bodyoftherequest
```

    New global alias for somesite: http --base-url http://url
    GET http://url/something
    Would run the get code
    res = None
    POST http://url/something with body bodyoftherequest
    Would run the post code
    res = None
