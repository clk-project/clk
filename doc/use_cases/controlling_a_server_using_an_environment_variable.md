Say that I have a server to perform some home automation.

Some commands are as simple as curling to its IP address. Because I want to make use of clk power, I want to wrap those curl commands into clk.

In this example, I mock this call using echo, but we simply can replace echo by exec to make it work for real.

```bash
clk alias set myserver echo curl http://myserverip/somecommand
clk myserver
```

    New global alias for myserver: echo curl http://myserverip/somecommand
    curl http://myserverip/somecommand

In my setup, the address of the server is actually in some environment variable.

```bash
export MYSERVER=myserverip
```

Therefore, I want my alias to make use of that environment variable.

I can call any python code on the fly in any argument using the pyeval: prefix.

And to make sure the pyeval code is actually run when running the alias but not when defining it, I can use noeval:

```bash
clk alias set myserver echo curl 'noeval:pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)'
clk myserver
```

    Removing global alias of myserver: echo curl http://myserverip/somecommand
    New global alias for myserver: echo curl pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)
    curl http://myserverip/sommecommand

This might be useful in some situation, but as you can see it is quite verbose.

We can also use shell commands, using the eval: prefix in arguments, let's try it.

```bash
clk alias set myserver echo curl 'noeval:eval:sh -c "echo http://${MYSERVER}/sommecommand"'
clk myserver
```

    Removing global alias of myserver: echo curl pyeval:"http://{MYSERVER}/sommecommand".format(**os.environ)
    New global alias for myserver: echo curl eval:sh -c "echo http://${MYSERVER}/sommecommand"
    curl http://myserverip/sommecommand

That's better. But still very verbose compared to what I want.

The last shortcut we have is to use the tpl: prefix, to only replace the environment variables.

```bash
clk alias set myserver echo curl 'noeval:tpl:http://{MYSERVER}/sommecommand'
clk myserver
```

    Removing global alias of myserver: echo curl eval:sh -c "echo http://${MYSERVER}/sommecommand"
    New global alias for myserver: echo curl tpl:http://{MYSERVER}/sommecommand
    curl http://myserverip/sommecommand

That's much better!
