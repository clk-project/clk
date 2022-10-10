
# Table of Contents

1.  [rm](#org8adb105)



<a id="org8adb105"></a>

# rm

This function can be use as a substitute of shutil.rmtree, that deals with the
dry-run mode and symbolic links.

    def rm(*file_or_tree):
    	"""
    	Removing some files or directories.

    	Does nothing in case dry run is set.
    	"""

    	LOGGER.action('remove {}'.format(' '.join(map(str, file_or_tree))))
    	if dry_run:
    		return
    	for f in file_or_tree:
    		if os.path.isdir(f) and not os.path.islink(f):
    			shutil.rmtree(f)
    		else:
    			os.unlink(f)