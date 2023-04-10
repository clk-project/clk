An option is an optional parameter that is given a value. A flag is an optional parameter that is a boolean. An argument is a positional parameter that you must give.

```bash
A:kind-of-animal:$(clk_format_choice duck whale cat dog):A name of animal
O:--sound-of-animal:str:The sound the animal makes
F:--shout:Print the message of the animal in capital case
```

```bash
if clk_given sound-of-animal
then
    msg="$(clk_value kind-of-animal) does $(clk_value sound-of-animal)"
else
    msg="I don't know what sound ${CLK___KIND_OF_ANIMAL} makes"
fi

if clk_true shout
then
    echo "${msg}"|tr '[:lower:]' '[:upper:]'
else
    echo "${msg}"
fi
```

```bash
clk command create bash animal --no-open
cat <<"EOH" > "$(clk command which animal)"
#!/bin/bash -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

This command shows something
--
A:kind-of-animal:$(clk_format_choice duck whale cat dog):A name of animal
O:--sound-of-animal:str:The sound the animal makes
F:--shout:Print the message of the animal in capital case
EOF
}

clk_help_handler "$@"

if clk_given sound-of-animal
then
    msg="$(clk_value kind-of-animal) does $(clk_value sound-of-animal)"
else
    msg="I don't know what sound ${CLK___KIND_OF_ANIMAL} makes"
fi

if clk_true shout
then
    echo "${msg}"|tr '[:lower:]' '[:upper:]'
else
    echo "${msg}"
fi

EOH
```

We can see the help of those parameters in the help of the command.

```bash
clk animal --help | grep -- 'KIND_OF_ANIMAL'
clk animal --help | grep -- '--sound-of-animal'
clk animal --help | grep -- '--shout'
```

```
'Context' object has no attribute 'required'
Traceback (most recent call last):
  File "/home/sam/Prog/clk/clk/core.py", line 618, in main
    config.main_command()
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1116, in __call__
    return self.main(*args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/lib.py", line 210, in main
    oldmain(*args, **newopts)
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1038, in main
    rv = self.invoke(ctx)
         ^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/overloads.py", line 1246, in invoke
    return super(MainCommand, self).invoke(ctx, *args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/triggers.py", line 31, in invoke
    res = super(TriggerMixin, self).invoke(*args, **kwargs)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1636, in invoke
    sub_ctx = cmd.make_context(cmd_name, args, parent=ctx)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 902, in make_context
    self.parse_args(ctx, args)
  File "/home/sam/Prog/clk/clk/overloads.py", line 569, in parse_args
    click.Command.parse_args(self, ctx, args)
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1365, in parse_args
    value, args = param.handle_parse_result(ctx, opts, args)
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 2342, in handle_parse_result
    value = self.process_value(ctx, value)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 2305, in process_value
    value = self.callback(ctx, self, value)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1259, in show_help
    echo(ctx.get_help(), color=ctx.color)
         ^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 676, in get_help
    return self.command.get_help(self)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1284, in get_help
    self.format_help(ctx, formatter)
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1317, in format_help
    self.format_options(ctx, formatter)
  File "/home/sam/Prog/clk/clk/overloads.py", line 424, in format_options
    rv = param.get_help_record(ctx)
         ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/overloads.py", line 890, in get_help_record
    metavar = self.type.get_metavar(ctx)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/types.py", line 258, in get_metavar
    if param.required and param.param_type_name == "argument":
       ^^^^^^^^^^^^^^
AttributeError: 'Context' object has no attribute 'required'
[31merror: [0mHmm, it looks like we did not properly catch this error. Please help us improve clk by telling us what caused the error on https://github.com/clk-project/clk/issues/new . If you feel like a pythonista, you can try debugging the issue yourself, running the command with clk --post-mortem or clk --develop
'Context' object has no attribute 'required'
Traceback (most recent call last):
  File "/home/sam/Prog/clk/clk/core.py", line 618, in main
    config.main_command()
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1116, in __call__
    return self.main(*args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/lib.py", line 210, in main
    oldmain(*args, **newopts)
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1038, in main
    rv = self.invoke(ctx)
         ^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/overloads.py", line 1246, in invoke
    return super(MainCommand, self).invoke(ctx, *args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/triggers.py", line 31, in invoke
    res = super(TriggerMixin, self).invoke(*args, **kwargs)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1636, in invoke
    sub_ctx = cmd.make_context(cmd_name, args, parent=ctx)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 902, in make_context
    self.parse_args(ctx, args)
  File "/home/sam/Prog/clk/clk/overloads.py", line 569, in parse_args
    click.Command.parse_args(self, ctx, args)
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1365, in parse_args
    value, args = param.handle_parse_result(ctx, opts, args)
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 2342, in handle_parse_result
    value = self.process_value(ctx, value)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 2305, in process_value
    value = self.callback(ctx, self, value)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1259, in show_help
    echo(ctx.get_help(), color=ctx.color)
         ^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 676, in get_help
    return self.command.get_help(self)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1284, in get_help
    self.format_help(ctx, formatter)
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1317, in format_help
    self.format_options(ctx, formatter)
  File "/home/sam/Prog/clk/clk/overloads.py", line 424, in format_options
    rv = param.get_help_record(ctx)
         ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/overloads.py", line 890, in get_help_record
    metavar = self.type.get_metavar(ctx)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/types.py", line 258, in get_metavar
    if param.required and param.param_type_name == "argument":
       ^^^^^^^^^^^^^^
AttributeError: 'Context' object has no attribute 'required'
[31merror: [0mHmm, it looks like we did not properly catch this error. Please help us improve clk by telling us what caused the error on https://github.com/clk-project/clk/issues/new . If you feel like a pythonista, you can try debugging the issue yourself, running the command with clk --post-mortem or clk --develop
'Context' object has no attribute 'required'
Traceback (most recent call last):
  File "/home/sam/Prog/clk/clk/core.py", line 618, in main
    config.main_command()
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1116, in __call__
    return self.main(*args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/lib.py", line 210, in main
    oldmain(*args, **newopts)
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1038, in main
    rv = self.invoke(ctx)
         ^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/overloads.py", line 1246, in invoke
    return super(MainCommand, self).invoke(ctx, *args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/triggers.py", line 31, in invoke
    res = super(TriggerMixin, self).invoke(*args, **kwargs)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1636, in invoke
    sub_ctx = cmd.make_context(cmd_name, args, parent=ctx)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 902, in make_context
    self.parse_args(ctx, args)
  File "/home/sam/Prog/clk/clk/overloads.py", line 569, in parse_args
    click.Command.parse_args(self, ctx, args)
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1365, in parse_args
    value, args = param.handle_parse_result(ctx, opts, args)
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 2342, in handle_parse_result
    value = self.process_value(ctx, value)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 2305, in process_value
    value = self.callback(ctx, self, value)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1259, in show_help
    echo(ctx.get_help(), color=ctx.color)
         ^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 676, in get_help
    return self.command.get_help(self)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1284, in get_help
    self.format_help(ctx, formatter)
  File "/home/sam/.local/lib/python3.11/site-packages/click/core.py", line 1317, in format_help
    self.format_options(ctx, formatter)
  File "/home/sam/Prog/clk/clk/overloads.py", line 424, in format_options
    rv = param.get_help_record(ctx)
         ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/Prog/clk/clk/overloads.py", line 890, in get_help_record
    metavar = self.type.get_metavar(ctx)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/sam/.local/lib/python3.11/site-packages/click/types.py", line 258, in get_metavar
    if param.required and param.param_type_name == "argument":
       ^^^^^^^^^^^^^^
AttributeError: 'Context' object has no attribute 'required'
[31merror: [0mHmm, it looks like we did not properly catch this error. Please help us improve clk by telling us what caused the error on https://github.com/clk-project/clk/issues/new . If you feel like a pythonista, you can try debugging the issue yourself, running the command with clk --post-mortem or clk --develop
```

```bash
clk animal 2>&1 > /dev/null | grep "Missing argument 'KIND_OF_ANIMAL'"
```

    error: Missing argument 'KIND_OF_ANIMAL'.

```bash
test "$(clk animal duck --sound-of-animal couac)" = "duck does couac"
test "$(clk animal whale --shout)" = "I DON'T KNOW WHAT SOUND WHALE MAKES"
```