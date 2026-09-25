- [a command to get my token](#a-command-to-get-my-token)
- [not typing the password every hour](#not-typing-the-password-every-hour)
- [on a machine where I have not stored it](#on-a-machine-where-i-have-not-stored-it)
- [storing it in my password manager](#storing-it-in-my-password-manager)
- [a check of my own in python](#a-check-of-my-own-in-python)
- [when the demo-buyer password is reset](#when-the-demo-buyer-password-is-reset)
- [when an agent runs it for me](#when-an-agent-runs-it-for-me)

I have an MCP server running on Amazon Bedrock AgentCore. It sits behind a Cognito user pool, so before calling one of its tools I need an access token, and to get one I log in as a test user, demo-buyer, with its password.

The token lasts an hour. Every hour, I read the password from a plain file with `$(cat ...)`, hand it to `aws cognito-idp initiate-auth` and paste the token where it goes. Let's make a command out of it, and get that password out of the file on the way.


<a id="a-command-to-get-my-token"></a>

# a command to get my token

Writing the password on the command line would leave it in my shell history, so the command prompts for it, hiding what I type and asking twice, the [click way](https://click.palletsprojects.com/en/8.1.x/options/#password-prompts). In real life, `token` calls `aws cognito-idp initiate-auth`. Here, it only says how it logs in.

```python
from clk.config import config
from clk.decorators import group, option


class AgentcoreConfig:
    pass


@group()
@option("--user", default="demo-buyer", help="The Cognito user to log in as", expose_class=AgentcoreConfig)
@option(
    "--password",
    help="The password of that user",
    prompt=True,
    confirmation_prompt=True,
    hide_input=True,
    expose_class=AgentcoreConfig,
)
def agentcore():
    "Talk to my MCP server on Bedrock AgentCore"


@agentcore.command()
def token():
    "Get a fresh access token from Cognito"
    print(f"Logging in as {config.agentcore.user} with password {config.agentcore.password}")
```

To know more about `expose_class=AgentcoreConfig`, see [dynamic parameters](dynamic_parameters_and_exposed_class.md).


<a id="not-typing-the-password-every-hour"></a>

# not typing the password every hour

Being prompted every hour gets old fast. I could make the password a parameter.

```bash
clk parameter set agentcore --password mytoken
```

    New global parameters for agentcore: --password mytoken

```bash
clk agentcore token
```

    Logging in as demo-buyer with password mytoken

It works, but the password now sits in plain text in my clk parameters, no better than the file I started from.

Instead, the parameter can tell clk to look the password up in my password manager.

```bash
clk parameter set agentcore --password noeval:secret:demo-buyer-password
```

    Removing global parameters of agentcore: --password mytoken
    New global parameters for agentcore: --password secret:demo-buyer-password

1.  `secret:demo-buyer-password` tells clk to get the value from my password manager, under the key `demo-buyer-password`,
2.  `noeval:` keeps clk from looking it up right now, so that the parameter holds the reference rather than the password.

I have not stored it yet, so clk fails and says so<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>.

```bash
clk agentcore token
```

    error: Could not find the secret for demo-buyer-password


<a id="on-a-machine-where-i-have-not-stored-it"></a>

# on a machine where I have not stored it

On a colleague's laptop, or on mine before I store it, `--ask-secret` makes clk ask me for the password rather than fail.

```bash
clk --ask-secret agentcore token
```

    warning: Could not find the secret for demo-buyer-password
    Please provide the secret demo-buyer-password:
    Repeat for confirmation:
    Logging in as demo-buyer with password test

The error became a warning, and I typed the password.

When I mistype it, clk asks again until both match.

    warning: Could not find the secret for demo-buyer-password
    Please provide the secret demo-buyer-password:
    Repeat for confirmation:
    Error: The two entered values do not match.
    Please provide the secret demo-buyer-password:

The missing password does not get in the way of completing the command, with or without `--ask-secret`.

```bash
clk agentcore --us<TAB>
```

    --user

    --user


<a id="storing-it-in-my-password-manager"></a>

# storing it in my password manager

clk stores secrets with [keyring](https://github.com/jaraco/keyring), hence in whatever password manager keyring is set up to use.

```bash
clk secret set demo-buyer-password
```

It prompts for the password, to keep it out of my shell history too. Let's say I typed "mytoken".

```bash
clk secret show demo-buyer-password
```

    demo-buyer-password *****

That tells me it is there without putting it on my screen. When I do want to see it, I say so.

```bash
clk secret show demo-buyer-password --secret
```

    demo-buyer-password mytoken

And to hand it to another program, the value alone.

```bash
clk secret show demo-buyer-password --secret --field secret
```

    mytoken

Now my command gets its password on its own, and I can delete that plain file.

```bash
clk agentcore token
```

    Logging in as demo-buyer with password mytoken

Calling a tool of the server is a bash command, whose password defaults to the secret.

```bash
clk command create bash mcp-call --description "Call a tool of my MCP server" \
    --option '--password:str:The password of demo-buyer:{"default": "secret:demo-buyer-password"}' \
    --argument 'tool:str:The tool to call' \
    --body 'echo "Calling ${CLK___TOOL} as demo-buyer with password ${CLK___PASSWORD}"'
```

```bash
clk mcp-call get_account_info
```

    Calling get_account_info as demo-buyer with password mytoken


<a id="a-check-of-my-own-in-python"></a>

# a check of my own in python

I also wrote a quick python command that logs in with its own http client. It reads the same password with `get_secret`.

```python
from clk import get_secret

@command()
def dosomething():
    'Log in with my own client'
    click.echo(get_secret('demo-buyer-password'))
```

```bash
clk dosomething
```

    mytoken


<a id="when-the-demo-buyer-password-is-reset"></a>

# when the demo-buyer password is reset

When someone resets the demo-buyer password, I remove the old one.

```bash
clk secret unset demo-buyer-password
```

clk asks first. I hesitate, since the reset may not be done yet, and answer no.

    This will definitely remove the secret for demo-buyer-password. Are you sure? [y/N]: warning: Removing anyway!
    ...Just kidding! You secret is safe :-)

It is still there.

```bash
clk secret show demo-buyer-password
```

    demo-buyer-password *****

The reset is done, so this time I answer yes. In a script, `--force` skips the question.

```bash
clk secret unset demo-buyer-password
```

Asking for it now tells me it is gone.

```bash
clk secret show demo-buyer-password
```

    warning: No secret set


<a id="when-an-agent-runs-it-for-me"></a>

# when an agent runs it for me

These days, a coding agent calls my MCP server as often as I do. It runs in a shell with no desktop session, where keyring has no backend to work with, and it cannot answer a prompt either. There, I keep the password in `~/.netrc`: the secret name in `machine`, its value in `password`.

```authinfo
machine demo-buyer-password
password thevalue
```

Sometimes the agent runs in a container where clk was installed without the python library keyring. clk reads my netrc file all the same.

```bash
clk secret show demo-buyer-password --secret
```

    demo-buyer-password thevalue

Naming a keyring there makes no sense, and clk says so.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret show demo-buyer-password
```

    Usage: clk [OPTIONS] [COMMAND] [ARGS]...
    error: You need to install keyring in order to manipulate secrets. Hint: python3 -m pip install keyring

Where keyring is installed but finds no password manager, clk falls back on netrc by itself.

```bash
clk secret show demo-buyer-password --secret
```

    demo-buyer-password thevalue

I can also ask for netrc explicitly, with the `NetrcKeyring` of `clk.keyrings`.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret show demo-buyer-password --secret
```

    demo-buyer-password thevalue

A secret my netrc file does not hold is simply not there.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret show other_token --secret
```

    warning: No secret set

It only reads: storing one is up to me, in the file itself.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret set other_token
```

    error: Could not save your secret.
    Usage: clk secret set [OPTIONS] KEY
    error: The netrc keyring only reads secrets. Write this one in your netrc file to use it.

Removing one is up to me as well.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret unset demo-buyer-password
```

    Usage: clk secret unset [OPTIONS] KEY
    error: The netrc keyring only reads secrets. Remove this one from your netrc file to get rid of it.

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> so that a script calling clk learns that something went wrong
