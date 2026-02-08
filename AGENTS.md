# clk - Command Line Kit

clk is a framework for building command-line tools with Click, providing features like aliases, parameters, flows, and custom commands.

## Use Cases Documentation

Use cases are documented in `doc/use_cases/` as org-mode literate programming files.

### Structure

- `doc/use_cases/*.org` - literate documents with executable code blocks
- `doc/use_cases/README.org` - lists and categorizes all use cases
- `tests/use_cases/*.sh` - tangled test scripts from the org files
- `tests/test_use_cases.py` - pytest wrapper to run all use case tests

### Adding a new use case

1. Generate a UUID (e.g., `uuidgen`)
2. Create `doc/use_cases/your_use_case.org` with the UUID in `:PROPERTIES:`
3. Use `:session UUID` on all bash code blocks to share state

#### Code block conventions

**Results and exports:**
- `:results none :exports code` - setup code, no output expected, show the code
- `:results none :exports none` - internal setup, hidden from export (e.g., `init` block sourcing sandboxing.sh)
- `:results verbatim :exports both :cache yes` - commands with output to display

**Important:**
- Blocks with `:results verbatim` must have `:cache yes` and be referenced in the tangle block with `check-result(block-name)`
- Blocks with `:results none` and `:session` (setup blocks) must be referenced in the tangle block with noweb syntax `<<block-name>>`

**Focus on user-facing examples:**
- Export blocks that show what the end user would type
- Use `:exports none` for internal/technical setup
- Use noweb (`<<block-name>>`) to include hidden setup blocks in the tangle without exporting them
- The goal is documentation that reads like a tutorial, not a test script

**Example structure:**
```org
#+name: init
#+BEGIN_SRC bash :results none :exports none :session UUID
  . ./sandboxing.sh
#+END_SRC

#+NAME: create-command
#+BEGIN_SRC bash :results none :exports code :session UUID
clk command create bash mycommand
#+END_SRC

#+NAME: run-command
#+BEGIN_SRC bash :results verbatim :exports both :session UUID :cache yes
clk mycommand
#+END_SRC

#+RESULTS[]: run-command
: output here

#+BEGIN_SRC bash :exports none :tangle ../../tests/use_cases/your_use_case.sh :noweb yes :shebang "#!/bin/bash -eu"
<<init>>

<<create-command>>

check-result(run-command)
#+END_SRC
```

1. Add a reference in `doc/use_cases/README.org`
2. Add a test function in `tests/test_use_cases.py`:
   ```python
   def test_your_use_case():
       call_script("your_use_case.sh")
   ```

### Running use case tests

```bash
# Run a specific use case test
cd tests/use_cases && ./your_use_case.sh

# Run all use case tests via pytest
pytest tests/test_use_cases.py
```
