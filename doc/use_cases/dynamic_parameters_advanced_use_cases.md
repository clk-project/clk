- [Adding values in the created class](#org0c385bc)

After discovering the [dynamic parameters](dynamic_parameters_and_exposed_class.md), you may want to use them for plenty of use cases. Here are a few pattern that I encountered when writing command line tools.


<a id="org0c385bc"></a>

# Adding values in the created class

It may happen that you want to add some values to the created class when it is created.

This is not currently possible, as the creation of the class is done internally in clk.

You can do this using callback then.

This pattern was found when creating an openapi client.

Let's suppose you want to implement the get and the post commands of the openapi group of commands.

You may want the completion of get and post to show only the appropriate paths.

```python
@group()
def openapi():
    "Play with some openapi server"


class OpenApi:
    pass


class Payload(DynamicChoice):
    def choices(self):
        if config.openapi.method == "put":
            return ["a", "b", "c"]
        elif config.openapi.method == "post":
            return ["d", "e", "f"]
        else:
            return []

def put_callback(ctx, attr, value):
    config.openapi.method = "put"
    return value


@openapi.command()
@argument("path", expose_class=OpenApi, help="The path to put",
          expose_value=True, callback=put_callback)
@argument("payload", type=Payload(), help="The payload to provide")
def put(path, payload):
    "Performing the put operation"
    click.echo(f"PUT on {path} with {payload}")


def post_callback(ctx, attr, value):
    config.openapi.method = "post"
    return value


@openapi.command()
@argument("path", expose_class=OpenApi, help="The path to post",
          expose_value=True, callback=post_callback)
@argument("payload", type=Payload(), help="The payload to provide")
def post(path, payload):
    "Performing the post operation"
    click.echo(f"POST on {path} with {payload}")
```

Then, you can call post and put with the appropriate argument values.

```bash
clk openapi put somepath a
clk openapi post somepath d
```

    PUT on somepath with a
    POST on somepath with d
