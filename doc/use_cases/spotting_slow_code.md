- [setting up a command with several steps](#slow-command-setup)
- [the command is slow, but where?](#without-timestamp)
- [adding &ndash;timestamp to spot the bottleneck](#with-timestamp)
- [adding &ndash;debug for the full picture](#with-debug-timestamp)
- [going deeper with &ndash;profiling](#with-profiling)

I have a command that feels slow and I want to find out why.


<a id="slow-command-setup"></a>

# setting up a command with several steps

Let's say I have this command that simulates several steps. It logs a summary at info level and detailed steps at debug level.

```python
import time

from clk.decorators import command
from clk.log import get_logger

LOGGER = get_logger(__name__)


@command()
def slowcmd():
    """A command with several steps."""
    LOGGER.debug("starting step 1: fetch config")
    LOGGER.debug("starting step 2: heavy computation")
    time.sleep(3)
    LOGGER.debug("starting step 3: write results")
    LOGGER.info("done")
```


<a id="without-timestamp"></a>

# the command is slow, but where?

Running it, all I see is "done" — no clue about what took so long:

```bash
clk slowcmd 2>&1
```

    done


<a id="with-timestamp"></a>

# adding &ndash;timestamp to spot the bottleneck

Adding `--timestamp` prefixes each log line with a timestamp. I can confirm it is slow, but there is only one log line — not enough to pinpoint the cause:

```bash
clk --timestamp slowcmd 2>&1
```

    2023-11-14 22:13:23,000 done


<a id="with-debug-timestamp"></a>

# adding &ndash;debug for the full picture

Adding `--debug` reveals the debug log lines. Combined with `--timestamp`, I can now see exactly where the time is spent:

```bash
clk --debug --timestamp slowcmd 2>&1
```

    2023-11-14 22:13:20,000 debug: starting step 1: fetch config
    2023-11-14 22:13:20,000 debug: starting step 2: heavy computation
    2023-11-14 22:13:23,000 debug: starting step 3: write results
    2023-11-14 22:13:23,000 done
    2023-11-14 22:13:23,000 debug: command `/home/sam/prog/clk/clk/__main__.py --debug --timestamp slowcmd` run in 0.146 second

The three-second gap between step 2 and step 3 is immediately visible, pointing to the heavy computation as the bottleneck.


<a id="with-profiling"></a>

# going deeper with &ndash;profiling

Now I know that step 2 is the bottleneck. To understand what exactly is happening inside, I can use `--profiling` to get function-level detail:

```bash
clk --profiling slowcmd 2>&1 | grep sleep
```

    1    0.000    0.000    0.000    0.000 /home/sam/prog/clk/clk/core.py:883(_fake_sleep)

Here `_fake_sleep` appears because the test environment replaces `time.sleep` with a fake. In real life, the output would show `{built-in method time.sleep}` with 3 seconds of cumulative time, confirming where the bottleneck is.
