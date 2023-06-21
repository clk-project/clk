- [if you don't have access to a password manager](#org1312dbb)
- [if you have access to a password manager](#org3d3b5d1)
- [using the secret in your command](#org8182efa)
- [using your own secret provider, or the built-in netrc one](#org85b99a6)

There are plenty of use cases that need to use some secret value.

Let's dig into how those are done in clk.

Because clk uses click, the most obvious way of using a secret value is to use [the click way](https://click.palletsprojects.com/en/8.1.x/options/#password-prompts), with `hide_input=True, confirmation_prompt=True, prompt=True`: This will ask twice for the password, hiding the input.

For the sake of the example, let's imagine you create a tool that calls some http endpoint that requires a bearer token.

Something that would be called like this.

```bash
clk http --base-url http://somesite --bearer sometoken get /something
```

This translates into something that looks like the following python code.

```python
class HTTPConfig:
    pass

@group()
@option("--bearer", help="The bearer token to request the API", prompt=True, confirmation_prompt=True, hide_input=True, expose_class=HTTPConfig)
@option("--base-url", help="The url of the site to play with", expose_class=HTTPConfig)
def http():
    "Commands to play with some OAuth 2 protected site"

@http.command()
@argument("path", help="The endpoint to call")
def get(path):
    "Perform a get request from the site"
    print(f"Calling {config.http.base_url}/{path} with bearer token {config.http.bearer}")

```

If you simply use that command, it will prompt you for the password. This may be not very practical if you are used to call this command pretty often.

To get more information about the pattern behind `expose_class=HTTPConfig`, see the tutorial about [dynamic parameters](dynamic_parameters_and_exposed_class.md).

You may be tempted to add the secret in a simple parameter, like this.

```bash
clk parameter set http --bearer mytoken
```

    New global parameters for http: --bearer mytoken

```bash
clk http --base-url someurl get someendpoint
```

    Calling someurl/someendpoint with bearer token mytoken

This works, but it keeps the bearer token in plain text into the clk parameters. That is not ideal security-wise.

What we can do instead is use a special value for this parameter that tells clk to lookup the value in your password manager instead.

```bash
clk parameter set http --bearer noeval:secret:http_bearer
```

    Removing global parameters of http: --bearer mytoken
    New global parameters for http: --bearer secret:http_bearer

Here is some explanation:

1.  the `noeval:` prefix tells clk not to replace the following content, so that the secret is not actually looked up when you create the parameter. That way, the parameter will be the literal `secret:http_bearer` instead of its content,
2.  `secret:http_bearer` tells clk to get the secret from your secret manager at the key `http_bearer`

If the secret is not there, clk will fail and tell you that it could not find it.

```bash
clk http --base-url someurl get someendpoint
```

    error: Could not find the secret for http_bearer

Now, there are two situations: either you have access to a password manager, or you don't.


<a id="org1312dbb"></a>

# if you don't have access to a password manager

If the former case, `clk` fails by default<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>, but you can ask it on the command line to ask you for the password by providing the `--ask-secret` flag to `clk`.

```bash
clk --ask-secret http --base-url someurl get someendpoint
```

    warning: Could not find the secret for http_bearer
    Please provide the secret http_bearer:
    Repeat for confirmation:
    Calling someurl/someendpoint with bearer token test


<a id="org3d3b5d1"></a>

# if you have access to a password manager

If you have access to a password manager, here is how you would proceed.

Every password manager has its particularities, so clk does not try to guess where the secret is located. It uses [keyring](https://github.com/jaraco/keyring) to deal with secrets and provides an interface to lookup secret and store secrets in your password manager.

To store a secret, use this command

```bash
clk secret set http_bearer
```

As you can see, you don't directly write the secret in the command line, for the same reasons explained above.

Let's assume for the sake of this use case that you typed "mytoken" when prompted for a value.

Then, you can look up a secret with:

```bash
clk secret show http_bearer
```

    http_bearer *****

As you can see, the secret is not actually shown, to avoid secrets to easily show up when you don't want them to. What this command tells is that a secret actually exists associated to that key.

You have to explicitly ask clk to show the secret.

```bash
clk secret show http_bearer --secret
```

    http_bearer mytoken

And in case you want to provide this secret to another command and just want the secret, nothing more.

```bash
clk secret show http_bearer --secret --field secret
```

    mytoken

Now, putting things together, the previous command will work as expected.

```bash
clk http --base-url someurl get someendpoint
```

    Calling someurl/someendpoint with bearer token mytoken


<a id="org8182efa"></a>

# using the secret in your command

This secret can also be used directly in the source code, using the `get_secret` function from clk.

```python
from clk import get_secret

@command()
def dosomething():
    'Example of using secrets'
    click.echo(get_secret('http_bearer'))
```

```bash
clk dosomething
```

    mytoken

You can remove this secret now using the unset command. But beware that the command won't work anymore as its parameter explicitly lookup for this secret.

```bash
clk secret unset http_bearer
```

Then, you can verify that the secret is gone.

```bash
clk secret show http_bearer
```

    warning: No secret set


<a id="org85b99a6"></a>

# using your own secret provider, or the built-in netrc one

The secret feature of `clk` is only a small wrapper on top of [keyring](https://github.com/jaraco/keyring). If you configured keyring to use a backend, it will be used in clk.

If you want to overwrite this in `clk`, you can pass the import value in the `--keyring` option.

For example, clk comes with a keyring to read secrets from netrc, implemented by the class `NetrcKeyring` of the module `clk.keyrings`.

Let's try to use netrc to provide the secret.

Write this content in `~/.netrc`

```authinfo
machine thesecretname
login notused
password thevalue
```

Then, you can show this secret by explicitly asking clk to use netrc.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret show thesecretname --secret
```

    thesecretname thevalue

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> this is so that if you use `clk` in scripts, you will be aware that something went wrong