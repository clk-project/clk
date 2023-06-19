- [manipulating strings](#orgbfdc959)
  - [dropping duplicate lines](#org74a8e94)

Now that [you can write a bash command](bash_command.md). you might want to do some complicated stuff with it. If your logic becomes pretty complicated, I definitely recommend that you use a python command instead.

But for moderate size commands, bash is pretty usable. clk provides some helpers to help with every day uses.

Let's start by creating a command line.

```bash
clk command create bash mycommand
```

We will use it to illustrate most of the example below.


<a id="orgbfdc959"></a>

# manipulating strings

When using bash, you don't have powerful string manipulation at hand. So you often need to put data in files and use tools like `cat`, `sed`, `cut` or `sed` (or `awk`) to deal with them.


<a id="org74a8e94"></a>

## dropping duplicate lines

Say that you want to deal with a file that contains duplicate entries and would like to deduplicate them, without sorting the file.

```bash
cat<<EOF>"file_with_duplicate.txt"
a
b
b
c
b
a
c
b
a
EOF
```

`clk_drop_duplicate` helps in that case, simply write the following line at the end of your command.

```bash
clk_drop_duplicate
```

Then run this command.

```bash
cat file_with_duplicate.txt | clk mycommand
```