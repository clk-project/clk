- [defining your workflow globally](#defining-your-workflow-globally)
- [filling in the details for a specific project](#filling-in-the-details-for-a-specific-project)
- [the workflow adapts to context](#the-workflow-adapts-to-context)
- [going further: project-specific workflows](#going-further-project-specific-workflows)
- [summary](#summary)

You have the same workflow across all your projects: test, then push. But each project has its own way of running tests. One uses pytest, another npm test, a third make test. With clk, you define the workflow once globally, and let each project fill in the details.


<a id="defining-your-workflow-globally"></a>

# defining your workflow globally

Start with a `test` placeholder - a command that does nothing by default.

```bash
clk alias set test echo "No tests configured" , exec false
```

<pre>
New <span style="color:teal;">global</span> alias for test: echo 'No tests configured' , exec false
</pre>

Then create your workflow alias.

```bash
clk alias set test-n-push test , echo "git push"
```

<pre>
New <span style="color:teal;">global</span> alias for test-n-push: test , echo 'git push'
</pre>

This workflow works everywhere, even where tests aren't configured yet.

```bash
clk test-n-push
```

    No tests configured


<a id="filling-in-the-details-for-a-specific-project"></a>

# filling in the details for a specific project

Now you enter a project that uses pytest. You create a local `test` command that knows how to run this project's tests.

```bash
mkdir myproject && cd myproject && mkdir .clk
```

```bash
clk command create bash test --description "Run the project tests" --body '
echo "Running pytest..."
echo "All 42 tests passed!"
'
```

Your workflow alias immediately picks it up.

```bash
clk test-n-push
```

    Running pytest...
    All 42 tests passed!
    git push

You didn't touch `test-n-push`. The workflow stays the same; only the implementation changed.


<a id="the-workflow-adapts-to-context"></a>

# the workflow adapts to context

Leave the project, and everything goes back to defaults.

```bash
cd ..
clk test-n-push
```

    No tests configured

Enter another project with npm, define a local `test` there, and `test-n-push` will run npm. The pattern scales to as many projects as you have.


<a id="going-further-project-specific-workflows"></a>

# going further: project-specific workflows

Sometimes a project needs an entirely different workflow. You can also define local aliases.

```bash
cd myproject
```

```bash
clk alias set deploy echo "Deploying to production..."
```

<pre>
New <span style="color:green;">local</span> alias for deploy: echo 'Deploying to production...'
</pre>

This `deploy` command only exists inside this project.

```bash
clk deploy
```

    Deploying to production...

```bash
cd ..
clk deploy
```

<pre>
<span style="color:olive;">warning: </span>Failed to get the command deploy: Command deploy not found
Usage: clk [OPTIONS] [COMMAND] [ARGS]...
error: No such command 'deploy'.
</pre>


<a id="summary"></a>

# summary

This pattern - global workflow, local implementation - is useful whenever you have:

-   A consistent way of working (`test-n-push`, `lint-n-commit`, `build-n-deploy`)
-   Projects with different tools or configurations

Define your workflow once. Let each project provide the specific commands. clk handles the rest.
