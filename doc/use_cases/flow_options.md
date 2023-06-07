When you get used to create groups of commands, you generally end up having a sequence that comes out quite naturally.

It is handy to have each command do one thing and do it well, while at the same time have a shortcut to chain them.

For the sake of the example, let's suppose you are writing a bunch of commands to perform 3d printing.

You would first create the group of commands named `printer` like so.

```bash
clk command create python --group printer
```

Then, in the printer.py file that just opened, there is already the group printer set up. Let's change its documentation so that it says something more meaningful.

Something like this

    This is a group of commands to deal with 3D printing.

You might be tempted to start with the most important command, the one that sends a gcode to the printer.

```python
@printer.command()
@option("--gcode", help="The gcode file", default="model.gcode")
@flag("--warn-when-done", help="Trigger a notification when done")
@argument("printer", help="The ip of the printer to send the gcode to")
def send(gcode, warn_when_done, printer):
    """Send some gcode to your printer"""
    print(f"Printing {gcode} using {printer}")
    if warn_when_done:
        print("Driiiiiiing!")
```

Then, you realize that you got from thingiverse some stl file, not some actual gcode. Therefore, you might want to run a slicer to.

```python
@printer.command()
@option("--model", default=["model.stl"], help="The model to slice", multiple=True)
@option("--output", default="model.gcode", help="The file getting the final gcode")
def slice(model, output):
    """Slice a model"""
    print(f"Slicing {', '.join(model)} to {output}")
```

That is nice. But now, you also realize that you need to calibrate the printer before sending the gcode content.

```python
@printer.command()
def calibrate():
    """Run everything that is needed to have the printer ready to print"""
    print("Running some stuff for the printer to be ready to go")
```

As you see, we focused on each individual command separately, without much care for the other ones.

Now, let's try to create one command to combine them all.

It would be great to have a flow that would take the "&#x2013;model" option of slice as well as the "&#x2013;warn-when-done" flag and the "printer" argument of send.

Let's define such a flow.

```python
from clk.overloads import get_command

@printer.flow_command()
@get_command("printer.slice").flow_option("model")
@get_command("printer.send").flow_option("warn_when_done")
@get_command("printer.send").flow_argument("printer")
def flow(**kwargs):
    """Run the whole flow"""
    print("The flow is done")
```

The flow\_option and flow\_argument lines tell that this new command "captures" those parameters from the respective commands.

This will make the command flow behave like if

1.  it naturally had those parameters
2.  it has a flow to those commands
3.  it was called with `--flow`

Then, when you run the flow, you get this.

```bash
clk printer flow myprinter --model somemodel --model someothermodel --warn-when-done
```

    Slicing somemodel, someothermodel to model.gcode
    Printing model.gcode using myprinter
    Driiiiiiing!
    The flow is done