#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Automatically generated, don't edit
def test_extract():
    from clk.lib import extract
    from pathlib import Path
    
    f = Path('readme')
    
    assert not f.exists()
    extract('https://github.com/clk-project/clk/raw/main/tests/zipfile.zip')
    assert f.exists()
    assert f.read_text() == 'hello from some zip file\n'


def test_download():
    from clk.lib import download
    from pathlib import Path
    import zipfile
    
    f = Path('zipfile.zip')
    assert not f.exists()
    
    download('https://github.com/clk-project/clk/raw/main/tests/zipfile.zip',
             sha256='702bb46372dfad9632c8dc3d8b5bbe945f9efd2f5575723bf66a0128486b7fb5')
    
    assert f.exists()
    z = zipfile.ZipFile(f)
    assert z.read("readme").decode() == 'hello from some zip file\n'
