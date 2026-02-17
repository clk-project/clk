- [A smart deployment command](#orgd989ede)
- [Shortcut aliases for common targets](#orgf929f7b)

When deploying applications, you often want to target different environments like staging, production, or development. A good deployment tool should be smart about defaults: when you don't specify an environment, it could auto-detect based on context (like the current git branch), but when you explicitly choose one, it should respect that choice.


<a id="orgd989ede"></a>

# A smart deployment command

Let's create a deploy command that auto-detects the environment when not specified, but uses the explicit value when provided:

```python
@group()
def app():
    "Application management"

@app.command()
@option('--environment', '-e', default='staging', help='Target environment')
def deploy(environment):
    "Deploy the application"
    import click
    ctx = click.get_current_context()
    source = ctx.get_parameter_source('environment')

    if source.name == 'DEFAULT':
        print(f"No environment specified, auto-detecting...")
        print(f"Detected: production (from git branch)")
        print(f"Deploying to production")
    else:
        print(f"Environment explicitly set to: {environment}")
        print(f"Deploying to {environment}")
```

When called without the environment flag, it auto-detects:

```bash
clk app deploy
```

    No environment specified, auto-detecting...
    Detected: production (from git branch)
    Deploying to production

When called with an explicit environment, it uses that:

```bash
clk app deploy --environment staging
```

    Environment explicitly set to: staging
    Deploying to staging


<a id="orgf929f7b"></a>

# Shortcut aliases for common targets

To make deployments even more convenient, let's create aliases for the most common targets:

```bash
clk alias set app.deploy-prod app deploy --environment production
clk alias set app.deploy-staging app deploy --environment staging
```

    New global alias for app.deploy-prod: app deploy --environment production
    New global alias for app.deploy-staging: app deploy --environment staging

The alias provides an explicit environment value, so the command correctly recognizes it as an explicit choice rather than falling back to auto-detection:

```bash
clk app deploy-prod
```

    Environment explicitly set to: production
    Deploying to production

This way, `clk app deploy` auto-detects while `clk app deploy-prod` always targets production.
