- [rm](#bcdb0473-f9fa-4947-bc65-8cd6a91b5089)
- [format\_options](#0d4a3f2e-8b17-4c6a-9e35-1c7d2b4f8a60)



<a id="bcdb0473-f9fa-4947-bc65-8cd6a91b5089"></a>

# rm

This function can be use as a substitute of shutil.rmtree, that deals with the dry-run mode and symbolic links.

```python
def rm(*file_or_tree):
    """
    Removing some files or directories.

    Does nothing in case dry run is set.
    """

    LOGGER.action("remove {}".format(" ".join(map(str, file_or_tree))))
    if dry_run:
        return
    for f in file_or_tree:
        p = Path(f)
        if not (p.exists() or p.is_symlink()):
            LOGGER.debug(f"{f} not removed because already missing")
            return
        if p.is_dir() and not p.is_symlink():
            shutil.rmtree(f)
        else:
            p.unlink()
```


<a id="0d4a3f2e-8b17-4c6a-9e35-1c7d2b4f8a60"></a>

# format\_options

A command that drives another program gathers its options as it goes, then hands the whole to `call`. Gather them in a dictionary and this turns it into the list `call` expects.

An option is named on the command line with dashes, whatever it is called in your code.

```python
def format_opt(opt):
    """Give the option the name it has on the command line"""
    return f"--{opt.replace('_', '-')}"
```

A true one is the option alone, a false one says nothing at all, and a list says its option once per value. Some programs want the value glued to the option instead, hence `glue`.

```python
def format_options(options, glue=False):
    """Turn a dictionary of options into the list of arguments call expects"""
    cmd = []
    for opt, value in options.items():
        if value is True:
            cmd.append(format_opt(opt))
        elif isinstance(value, (list, tuple)):
            for item in value:
                if glue:
                    cmd.append(f"{format_opt(opt)}={item}")
                else:
                    cmd.extend([format_opt(opt), item])
        elif value:
            if glue:
                cmd.append(f"{format_opt(opt)}={value}")
            else:
                cmd.extend([format_opt(opt), value])
    return cmd
```

See [chaotic simulator manager](../doc/use_cases/chaotic_simulator_manager.md) for a command handing its own options over this way.
