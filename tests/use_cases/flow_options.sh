#!/bin/bash -eu
# [[file:flow_options.org::script][script]]
documentation='This is a group of commands to deal with 3D printing.'
. ./sandboxing.sh

clk command create python --group printer

sed -i "s/Description/$documentation/" "${CLKCONFIGDIR}/python/printer.py"

cat<<EOF >> "${CLKCONFIGDIR}/python/printer.py"
@printer.command()
@option("--gcode", help="The gcode file", default="model.gcode")
@flag("--warn-when-done", help="Trigger a notification when done")
@argument("printer", help="The ip of the printer to send the gcode to")
def send(gcode, warn_when_done, printer):
    """Send some gcode to your printer"""
    print(f"Printing {gcode} using {printer}")
    if warn_when_done:
        print("Driiiiiiing!")

@printer.command()
@option("--model", default="model.stl", help="The model to slice")
@option("--output", default="model.gcode", help="The file getting the final gcode")
def slice(model, output):
    """Slice a model"""
    print(f"Slicing {model} to {output}")

@printer.command()
def calibrate():
    """Run everything that is needed to have the printer ready to print"""
    print("Running some stuff for the printer to be ready to go")

from clk.overloads import get_command

@printer.flow_command()
@get_command("printer.slice").flow_option("model")
@get_command("printer.send").flow_option("warn_when_done")
@get_command("printer.send").flow_argument("printer")
def flow(**kwargs):
    """Run the whole flow"""
    print("The flow is done")
EOF


run_flow_code () {
      clk printer flow myprinter --model somemodel --warn-when-done
}

run_flow_expected () {
      cat<<EOEXPECTED
Slicing somemodel to model.gcode
Printing model.gcode using myprinter
Driiiiiiing!
The flow is done
EOEXPECTED
}

diff -u <(run_flow_code) <(run_flow_expected)
# script ends here
