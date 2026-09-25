- [a command to get my token](#a-command-to-get-my-token)
- [not typing the password every hour](#not-typing-the-password-every-hour)
- [on a machine where I have not stored it](#on-a-machine-where-i-have-not-stored-it)
- [storing it in my password manager](#storing-it-in-my-password-manager)
- [setting up a new laptop](#setting-up-a-new-laptop)
- [a check of my own in python](#a-check-of-my-own-in-python)
- [when the demo-buyer password is reset](#when-the-demo-buyer-password-is-reset)
- [when an agent runs it for me](#when-an-agent-runs-it-for-me)
- [when the team shares the password](#when-the-team-shares-the-password)
- [keeping it in the project](#keeping-it-in-the-project)
- [when the demo is over](#when-the-demo-is-over)

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

<pre>
New <span style="color:teal;">global</span> parameters for agentcore: --password mytoken
</pre>

```bash
clk agentcore token
```

    Logging in as demo-buyer with password mytoken

It works, but the password now sits in plain text in my clk parameters, no better than the file I started from.

Instead, the parameter can tell clk to look the password up in my password manager.

```bash
clk parameter set agentcore --password noeval:secret:demo-buyer-password
```

<pre>
Removing <span style="color:teal;">global</span> parameters of agentcore: --password mytoken
New <span style="color:teal;">global</span> parameters for agentcore: --password secret:demo-buyer-password
</pre>

1.  `secret:demo-buyer-password` tells clk to get the value from my password manager, under the key `demo-buyer-password`,
2.  `noeval:` keeps clk from looking it up right now, so that the parameter holds the reference rather than the password.

I have not stored it yet, so clk fails and says so<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>.

```bash
clk agentcore token
```

<pre>
<span style="color:red;">error: </span>Could not find the secret for demo-buyer-password
</pre>


<a id="on-a-machine-where-i-have-not-stored-it"></a>

# on a machine where I have not stored it

On a colleague's laptop, or on mine before I store it, `--ask-secret` makes clk ask me for the password rather than fail.

```bash
clk --ask-secret agentcore token
```

<pre>
<span style="color:olive;">warning: </span>Could not find the secret for demo-buyer-password
Please provide the secret demo-buyer-password:
Repeat for confirmation:
Logging in as demo-buyer with password test
</pre>

The error became a warning, and I typed the password.

When I mistype it, clk asks again until both match.

<pre>
<span style="color:olive;">warning: </span>Could not find the secret for demo-buyer-password
Please provide the secret demo-buyer-password:
Repeat for confirmation:
Error: The two entered values do not match.
Please provide the secret demo-buyer-password:
</pre>

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

<pre>
demo-buyer-password *****
</pre>

That tells me it is there without putting it on my screen. When I do want to see it, I say so.

```bash
clk secret show demo-buyer-password --secret
```

<pre>
demo-buyer-password mytoken
</pre>

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


<a id="setting-up-a-new-laptop"></a>

# setting up a new laptop

My clk parameters and aliases follow me from laptop to laptop, my password manager does not always. One of those aliases gets the token of demo-buyer whatever the parameters say.

```bash
clk alias set buyer-token agentcore --user demo-buyer --password noeval:secret:demo-buyer-password token
```

To know which secrets to store again, clk lists the ones they refer to, and whether each is there.

```bash
clk secret list
```

<pre>
key                  status    commands
-------------------  --------  ---------------------
demo-buyer-password  <span style="color:green;">set</span>       <span style="color:teal;">agentcore</span> <span style="color:teal;">buyer-token</span>
--------------
Legend: <span style="color:teal;">global</span>
</pre>


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

    This will definitely remove the secret for demo-buyer-password. Are you sure? [y/N]: Kept the secret for demo-buyer-password

It is still there.

```bash
clk secret show demo-buyer-password
```

<pre>
demo-buyer-password *****
</pre>

The reset is done, so this time I answer yes. In a script, `--force` skips the question.

```bash
clk secret unset demo-buyer-password
```

Asking for it now fails, so a script that reads it notices.

```bash
clk secret show demo-buyer-password
```

    error: No secret set

Removing it again tells me there is nothing left to remove.

```bash
clk secret unset demo-buyer-password
```

    error: No secret set

And the list reminds me to store the new one.

```bash
clk secret list
```

<pre>
key                  status    commands
-------------------  --------  ---------------------
demo-buyer-password  <span style="color:red;">missing</span>   <span style="color:teal;">agentcore</span> <span style="color:teal;">buyer-token</span>
--------------
Legend: <span style="color:teal;">global</span>
</pre>


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

<pre>
demo-buyer-password thevalue
</pre>

```bash
clk secret backend which
```

    clk keeps your secrets in clk.netrc.Netrc, because the python library keyring is not installed.

```bash
clk secret backend show
```

<pre>
backend          configuration      priority  status
---------------  ---------------  ----------  --------
<span style="color:green;">clk.netrc.Netrc</span>  Unset                     1  in use
</pre>

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

<pre>
demo-buyer-password thevalue
</pre>

When I wonder where a secret comes from, clk tells me where it keeps them, and why.

```bash
clk secret backend which
```

    clk keeps your secrets in clk.keyrings.NetrcKeyring, because the python library keyring found no password manager on this machine.

And which keyrings it could use instead.

```bash
clk secret backend show
```

<pre>
backend                                  configuration      priority  status
---------------------------------------  ---------------  ----------  --------
<span style="color:red;">keyring.backends.chainer.ChainerBackend</span>  Unset                    10
<span style="color:red;">clk.keyrings.GpgKeyring</span>                  Unset                     1
<span style="color:green;">clk.keyrings.NetrcKeyring</span>                Unset                     1  in use
<span style="color:red;">keyring.backends.fail.Keyring</span>            Unset                     0
</pre>

I can also ask for netrc explicitly, with the `NetrcKeyring` of `clk.keyrings`.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret show demo-buyer-password --secret
```

<pre>
demo-buyer-password thevalue
</pre>

A secret my netrc file does not hold is simply not there.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret show other_token --secret
```

    error: No secret set

It only reads: storing one is up to me, in the file itself.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret set other_token
```

<pre>
<span style="color:red;">error: </span>Could not save your secret.
Usage: clk secret set [OPTIONS] KEY
error: The netrc keyring only reads secrets. Write this one in your netrc file to use it.
</pre>

Removing one is up to me as well.

```bash
clk --keyring clk.keyrings.NetrcKeyring secret unset demo-buyer-password
```

    Usage: clk secret unset [OPTIONS] KEY
    error: The netrc keyring only reads secrets. Remove this one from your netrc file to get rid of it.


<a id="when-the-team-shares-the-password"></a>

# when the team shares the password

The team now keeps the demo-buyer password in AWS Secrets Manager, and my role may read it, not write it. I wrote a keyring backend that reads from there. In real life, `get_password` calls `aws secretsmanager get-secret-value`.

```python
import keyring.backend


class SecretsManagerKeyring(keyring.backend.KeyringBackend):
    priority = 6

    def get_password(self, service, username):
        return None

    def set_password(self, service, username, password):
        raise NotImplementedError

    def delete_password(self, service, username):
        raise NotImplementedError
```

Out of habit, I tried storing the new password after it was reset. clk says which keyring refused.

```bash
clk --keyring team_keyring.SecretsManagerKeyring secret set demo-buyer-password
```

    error: The keyring team_keyring.SecretsManagerKeyring cannot store secrets. Store it with the tool of that password manager, or pick another keyring with --keyring.

```bash
clk --keyring team_keyring.SecretsManagerKeyring secret backend which
```

    clk keeps your secrets in team_keyring.SecretsManagerKeyring, because --keyring names it.

Rather than typing `--keyring` every time, I tell clk to use it from now on.

```bash
clk secret backend use team_keyring.SecretsManagerKeyring
```

<pre>
clk now keeps your secrets in team_keyring.SecretsManagerKeyring (<span style="color:teal;">global</span> settings)
</pre>

```bash
clk secret backend which
```

<pre>
clk keeps your secrets in team_keyring.SecretsManagerKeyring, because the <span style="color:teal;">global</span> settings name it.
</pre>

```bash
clk secret backend show
```

<pre>
backend                                  configuration      priority  status
---------------------------------------  ---------------  ----------  --------
<span style="color:green;">team_keyring.SecretsManagerKeyring</span>       <span style="color:teal;">global</span>                    6  in use
<span style="color:red;">keyring.backends.fail.Keyring</span>            Unset                     0
<span style="color:red;">keyring.backends.chainer.ChainerBackend</span>  Unset                    -1
--------------
Legend: <span style="color:teal;">global</span>
</pre>


<a id="keeping-it-in-the-project"></a>

# keeping it in the project

The demo-buyer password is a throwaway, not worth a place in a password manager. I keep it in the project of my MCP server instead, encrypted with my gpg key.

I give it a try first.

```bash
clk --keyring clk.keyrings.GpgKeyring secret set demo-buyer-password
```

<pre>
<span style="color:red;">error: </span>Could not save your secret.
Usage: clk secret set [OPTIONS] KEY
error: Write in ./.clk/secrets/.gpg-id the gpg ids to encrypt the secrets to, one per line. gpg --list-secret-keys shows yours.
</pre>

```bash
mkdir -p .clk/secrets
echo me@example.com > .clk/secrets/.gpg-id
```

Then I make it the keyring of the project. I don't remember its name, tab does.

```bash
clk secret backend --local use clk.keyrings.<TAB>
```

    clk.keyrings.GpgKeyring
    clk.keyrings.NetrcKeyring

```bash
clk secret backend --local use clk.keyrings.GpgKeyring
```

<pre>
clk now keeps your secrets in clk.keyrings.GpgKeyring (<span style="color:green;">local</span> settings)
</pre>

```bash
clk secret set demo-buyer-password
```

```bash
ls .clk/secrets
```

    demo-buyer-password.gpg

```bash
clk secret show demo-buyer-password --secret
```

<pre>
demo-buyer-password mytoken
</pre>

Removing it removes the file.

```bash
clk secret unset demo-buyer-password
ls .clk/secrets
clk secret show demo-buyer-password
```

    error: No secret set

With no secret left in it, the project goes back to the keyring of my laptop.

```bash
clk secret backend --local unuse
```

    clk no longer picks a keyring

On my desktop, the password manager of my session, behind the Secret Service interface, does just as well, and I don't need to handle gpg ids.

```bash
clk secret backend --local use keyring.backends.SecretService.Keyring
```

<pre>
clk now keeps your secrets in keyring.backends.SecretService.Keyring (<span style="color:green;">local</span> settings)
</pre>

```bash
clk secret set demo-buyer-password
```

```bash
clk secret show demo-buyer-password --secret
clk secret backend which
```

<pre>
demo-buyer-password mytoken
clk keeps your secrets in keyring.backends.SecretService.Keyring, because the <span style="color:green;">local</span> settings name it.
</pre>


<a id="when-the-demo-is-over"></a>

# when the demo is over

The demo-buyer user is gone, and so are its parameter and its alias.

```bash
clk parameter unset agentcore
clk alias unset buyer-token
```

I no longer need the team keyring either.

```bash
clk secret backend unuse
```

    clk no longer picks a keyring

Once is enough.

```bash
clk secret backend unuse
```

    error: The global settings pick no keyring

Without a choice of clk, the python library keyring picks the backend. It first reads the environment variable PYTHON\_KEYRING\_BACKEND.

```bash
PYTHON_KEYRING_BACKEND=clk.keyrings.NetrcKeyring clk secret backend which
```

    clk keeps your secrets in clk.keyrings.NetrcKeyring, because the environment variable PYTHON_KEYRING_BACKEND names it.

Then its configuration file.

```bash
mkdir -p "${XDG_CONFIG_HOME}/python_keyring"
cat <<EOF > "${XDG_CONFIG_HOME}/python_keyring/keyringrc.cfg"
[backend]
default-keyring=clk.keyrings.NetrcKeyring
EOF
```

```bash
clk secret backend which
```

    clk keeps your secrets in clk.keyrings.NetrcKeyring, because ./config/python_keyring/keyringrc.cfg names it.

Without either, it takes the backend of highest priority, here the Secret Service of my session.

```bash
rm "${XDG_CONFIG_HOME}/python_keyring/keyringrc.cfg"
clk secret backend which
```

    clk keeps your secrets in keyring.backends.SecretService.Keyring, because it has the highest priority of the backends the python library keyring found.

Once the team publishes its Secrets Manager keyring as a package, installing it is enough: keyring finds it beside the Secret Service, and chains the two, asking the team keyring first.

```bash
pip install team-keyring
```

```bash
clk secret backend which
```

    clk keeps your secrets in keyring.backends.chainer.ChainerBackend, because it has the highest priority of the backends the python library keyring found.

No command of mine needs a secret any more.

```bash
clk secret list
```

    No parameter or alias refers to a secret

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> so that a script calling clk learns that something went wrong
