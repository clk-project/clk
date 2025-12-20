- [rm](#bcdb0473-f9fa-4947-bc65-8cd6a91b5089)



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
        if not (os.path.exists(f) or os.path.islink(f)):
            LOGGER.debug(f"{f} not removed because already missing")
            return
        if os.path.isdir(f) and not os.path.islink(f):
            shutil.rmtree(f)
        else:
            os.unlink(f)
```
