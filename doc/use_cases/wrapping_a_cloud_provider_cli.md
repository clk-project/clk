- [wrapping AWS with clk](#wrapping-aws)
- [setting default parameters](#default-parameters)
- [managing parameters](#managing-parameters)
- [per-project configuration](#per-project)

I use AWS a lot at work. The AWS CLI is powerful but verbose. Every command needs `--profile` to specify which account I'm targeting, and often `--region` too. I find myself typing things like:

```bash
aws --profile company-prod --region eu-west-1 s3 ls s3://some-bucket
aws --profile company-prod --region eu-west-1 ec2 describe-instances
aws --profile company-staging --region eu-west-1 s3 cp file.txt s3://staging-bucket/
```

This gets old fast. I wanted something where I could set my usual profile once and forget about it, but still be able to switch when needed.


<a id="wrapping-aws"></a>

# wrapping AWS with clk

I created a clk wrapper around AWS. The idea is simple: a group command that handles the `--profile` and `--region` options, then passes them to subcommands via environment variables.

Here's a simplified version (in real life, the subcommands would call the actual `aws` CLI).

First, create the group:

```bash
clk command create python aws --group --description "AWS CLI wrapper"
```

Then edit it to add the options. The code looks like this:

```python
from clk.config import config
from clk.decorators import group, option


@group()
@option("--profile", "-p", default="default", help="The AWS profile to use")
@option("--region", "-r", default="us-east-1", help="The AWS region")
def aws(profile, region):
    "AWS CLI wrapper with persistent configuration"
    config.override_env["AWS_PROFILE"] = profile
    config.override_env["AWS_REGION"] = region
    config.init()


@aws.group()
def s3():
    "S3 operations"
```

The subcommands are bash scripts that use the environment variables set by the parent group. We can declare arguments directly on the command line:

```bash
clk command create bash aws.s3.ls --description "List S3 buckets or objects" \
    --argument 'path:str:S3 path to list:{"required": false}' \
    --body 'echo "[${AWS_PROFILE}/${AWS_REGION}] aws s3 ls ${CLK___PATH:-}"'
```

```bash
clk command create bash aws.s3.cp --description "Copy files to/from S3" \
    --argument 'source:str:Source path' \
    --argument 'destination:str:Destination path' \
    --body 'echo "[${AWS_PROFILE}/${AWS_REGION}] aws s3 cp ${CLK___SOURCE} ${CLK___DESTINATION}"'
```

```bash
clk command create bash aws.ec2 --description "EC2 operations" \
    --argument 'args:str:EC2 command arguments:{"nargs": -1}' \
    --body 'echo "[${AWS_PROFILE}/${AWS_REGION}] aws ec2 ${CLK___ARGS}"'
```

Now I can use it like this:

```bash
clk aws --profile company-prod --region eu-west-1 s3 ls s3://prod-bucket
```

    [company-prod/eu-west-1] aws s3 ls s3://prod-bucket

That's better, but I still have to type the profile every time.


<a id="default-parameters"></a>

# setting default parameters

Here's where clk shines. I can persist options so they become the default.

```bash
clk parameter set aws --profile company-prod --region eu-west-1
```

    New global parameters for aws: --profile company-prod --region eu-west-1

Now I don't need to specify them anymore:

```bash
clk aws s3 ls s3://prod-bucket
clk aws s3 cp backup.sql s3://prod-bucket/backups/
clk aws ec2 describe-instances
```

    [company-prod/eu-west-1] aws s3 ls s3://prod-bucket
    [company-prod/eu-west-1] aws s3 cp backup.sql s3://prod-bucket/backups/
    [company-prod/eu-west-1] aws ec2 describe-instances

Much cleaner! And when I need to work with staging, I just override:

```bash
clk aws --profile company-staging s3 ls s3://staging-bucket
```

    [company-staging/eu-west-1] aws s3 ls s3://staging-bucket

The region is still `eu-west-1` from my persisted parameters, only the profile changed.


<a id="managing-parameters"></a>

# managing parameters

I can check what's currently set:

```bash
clk parameter show aws
```

    aws --profile company-prod --region eu-west-1

And remove options I no longer want persisted:

```bash
clk parameter remove aws --region eu-west-1
clk parameter show aws
```

    Erasing aws parameters --region eu-west-1 from global settings
    aws --profile company-prod

Or clear everything:

```bash
clk parameter unset aws
clk aws s3 ls
```

    Erasing global parameters of aws (was: --profile company-prod)
    [default/us-east-1] aws s3 ls


<a id="per-project"></a>

# per-project configuration

Different projects often use different AWS accounts. I can set parameters at the project level so they only apply when I'm in that directory.

```bash
mkdir -p webapp-project
cd webapp-project
mkdir .clk
```

Note that simply creating the `.clk` dir make webapp-project a project in clk point of view.

```bash
clk --project . parameter set aws --profile webapp-prod --region ap-southeast-1
clk parameter show aws
```

    New local parameters for aws: --profile webapp-prod --region ap-southeast-1
    aws --profile webapp-prod --region ap-southeast-1

```bash
clk aws s3 ls s3://webapp-assets
```

    [webapp-prod/ap-southeast-1] aws s3 ls s3://webapp-assets

When I leave the project, my global defaults (or lack thereof) take over again:

```bash
cd ..
clk aws s3 ls
```

    [default/us-east-1] aws s3 ls

This way, I never accidentally run a command against the wrong account just because I forgot to switch profiles.
