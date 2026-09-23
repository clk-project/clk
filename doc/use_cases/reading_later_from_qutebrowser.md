- [keeping a page for later](#keeping-a-page-for-later)
- [a key in qutebrowser](#a-key-in-qutebrowser)
- [letting clk use its own libraries](#letting-clk-use-its-own-libraries)



<a id="keeping-a-page-for-later"></a>

# keeping a page for later

I read with qutebrowser, and I often stumble upon a page I have no time for. I already keep them with a clk command.

```python
@command()
@argument('url', help='The page to read later')
def read_later(url):
    'Keep a page to read it later'
    print(f'I will read {url} later')
```

```bash
clk read-later https://clk-project.org/
```

    I will read https://clk-project.org/ later


<a id="a-key-in-qutebrowser"></a>

# a key in qutebrowser

I want a key that does it on the page I am reading. qutebrowser runs userscripts and gives them the url in `QUTE_URL`, so mine only calls clk.

```bash
#!/usr/bin/env bash
clk read-later "${QUTE_URL}"
```

I bind it in my config.py.

```python
config.bind('<Space>r', 'spawn --userscript read-later')
```

qutebrowser is a python program, and its userscripts get the PYTHONPATH it runs with. Mine comes with a click of its own, one clk cannot work with.

I press the key, and clk does not even start.

    ImportError: clk cannot work with the click of qutebrowser


<a id="letting-clk-use-its-own-libraries"></a>

# letting clk use its own libraries

With `CLK_FORCE_DEPS` set, clk puts what PYTHONPATH says after its own libraries. It takes its own click, and still finds the rest of PYTHONPATH.

```bash
#!/usr/bin/env bash
export CLK_FORCE_DEPS=1
clk read-later "${QUTE_URL}"
```

    I will read https://clk-project.org/ later
