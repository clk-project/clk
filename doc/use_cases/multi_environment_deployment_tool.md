Sometimes you want a group of commands to share configuration through environment variables. This is useful when you have bash subcommands that need access to values computed or validated by the parent Python command.

For example, imagine you have a deployment tool where you select an environment (dev, staging, prod) once, and all subcommands should use that environment.

First, create a Python command group:

```bash
clk command create python myenv --group --description "Commands that work with a specific environment"
```

Then edit it to add the option and set environment variables:

```python
import click

from clk.config import config
from clk.decorators import group, option


@group()
@option("--env", "-e", type=click.Choice(["dev", "staging", "prod"]), default="dev", help="The environment to use")
def myenv(env):
    "Commands that work with a specific environment"
    config.override_env["MYENV_NAME"] = env
    config.override_env["MYENV_URL"] = f"https://{env}.example.com"
    config.init()
```

The key line is `config.override_env["MYENV_NAME"] = env`. This makes the `MYENV_NAME` environment variable available to all subcommands, including bash commands.

Now let's add a bash subcommand that uses these environment variables.

```bash
clk command create bash myenv.status --description "Show the current environment status" --body '
echo "Environment: ${MYENV_NAME}"
echo "URL: ${MYENV_URL}"
echo "Checking status..."
# In real life, you might do: curl -s "${MYENV_URL}/health"
echo "Status: OK"
'
```

Let's test it.

```bash
clk myenv status
```

    Environment: dev
    URL: https://dev.example.com
    Checking status...
    Status: OK

```bash
clk myenv --env prod status
```

    Environment: prod
    URL: https://prod.example.com
    Checking status...
    Status: OK

The bash command automatically has access to `MYENV_NAME` and `MYENV_URL` because the parent group set them in `config.override_env`.

Let's add another bash command that deploys to the selected environment.

```bash
clk myenv --env staging deploy
```

    Deploying to staging at https://staging.example.com...
    Deployment complete!

This pattern is particularly useful when:

-   You have a CLI that targets different servers or contexts
-   Configuration is computed dynamically in Python but used in bash scripts
-   You want to validate options once at the group level rather than in each subcommand
