#!/bin/bash -eu
# [[file:../../doc/use_cases/3D_printing_flow.org::script][script]]
. ./sandboxing.sh

clk command create python --group printer --description "This is a group of commands to deal with 3D printing."

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
@option("--model", default=["model.stl"], help="The model to slice", multiple=True)
@option("--output", default="model.gcode", help="The file getting the final gcode")
def slice(model, output):
    """Slice a model"""
    print("Slicing " + ", ".join(model) + f" to {output}")

@printer.command()
def calibrate():
    """Run everything that is needed to have the printer ready to print"""
    print("Running some stuff for the printer to be ready to go")

from clk.overloads import get_command

@printer.flow_command(flowdepends=["printer.calibrate"])
@get_command("printer.slice").flow_option("model")
@get_command("printer.send").flow_option("warn_when_done")
@get_command("printer.send").flow_argument("printer")
def flow(**kwargs):
    """Run the whole flow"""
    print("The flow is done")
EOF


run_flow_code () {
      clk printer flow myprinter --model somemodel --model someothermodel --warn-when-done
}

run_flow_expected () {
      cat<<"EOEXPECTED"
Running some stuff for the printer to be ready to go
Slicing somemodel, someothermodel to model.gcode
Printing model.gcode using myprinter
Driiiiiiing!
The flow is done
EOEXPECTED
}

diff -uBw <(run_flow_code 2>&1) <(run_flow_expected) || {
echo "Something went wrong when trying run_flow"
exit 1
}


  clk command create python --force --group printer --description "This is a group of commands to deal with 3D printing." --body '
@printer.command()
def calibrate():
    """Run everything that is needed to have the printer ready to print"""
    print("Running some stuff for the printer to be ready to go")

@printer.command(flowdepends=["printer.calibrate"])
@option("--model", default=["model.stl"], help="The model to slice", multiple=True)
@option("--output", default="model.gcode", help="The file getting the final gcode")
def slice(model, output):
    """Slice a model"""
    print("Slicing " + ", ".join(model) + f" to {output}")

@printer.command(flowdepends=["printer.slice"])
@option("--gcode", help="The gcode file", default="model.gcode")
@flag("--warn-when-done", help="Trigger a notification when done")
@argument("printer", help="The ip of the printer to send the gcode to")
def send(gcode, warn_when_done, printer):
    """Send some gcode to your printer"""
    print(f"Printing {gcode} using {printer}")
    if warn_when_done:
        print("Driiiiiiing!")
'


running-the-explicit-flow_code () {
      echo "# Running the send command, without the flow"
      clk printer send myprinter
      echo "# Running the send command, asking for its flow"
      clk printer send myprinter --flow
}

running-the-explicit-flow_expected () {
      cat<<"EOEXPECTED"
# Running the send command, without the flow
Printing model.gcode using myprinter
# Running the send command, asking for its flow
Running some stuff for the printer to be ready to go
Slicing model.stl to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
}

diff -uBw <(running-the-explicit-flow_code 2>&1) <(running-the-explicit-flow_expected) || {
echo "Something went wrong when trying running-the-explicit-flow"
exit 1
}



running-the-explicit-flow-with-model_code () {
      clk parameter set printer.slice --model someothermodel
      clk printer send myprinter --flow
}

running-the-explicit-flow-with-model_expected () {
      cat<<"EOEXPECTED"
New global parameters for printer.slice: --model someothermodel
Running some stuff for the printer to be ready to go
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
}

diff -uBw <(running-the-explicit-flow-with-model_code 2>&1) <(running-the-explicit-flow-with-model_expected) || {
echo "Something went wrong when trying running-the-explicit-flow-with-model"
exit 1
}


  clk command create python --force --group printer --description "This is a group of commands to deal with 3D printing." --body '
@printer.command()
def calibrate():
    """Run everything that is needed to have the printer ready to print"""
    print("Running some stuff for the printer to be ready to go")

@printer.command(flowdepends=["printer.calib"])
@option("--model", default=["model.stl"], help="The model to slice", multiple=True)
@option("--output", default="model.gcode", help="The file getting the final gcode")
def slice(model, output):
    """Slice a model"""
    print("Slicing " + ", ".join(model) + f" to {output}")

@printer.command(flowdepends=["printer.slice"])
@option("--gcode", help="The gcode file", default="model.gcode")
@flag("--warn-when-done", help="Trigger a notification when done")
@argument("printer", help="The ip of the printer to send the gcode to")
def send(gcode, warn_when_done, printer):
    """Send some gcode to your printer"""
    print(f"Printing {gcode} using {printer}")
    if warn_when_done:
        print("Driiiiiiing!")
'


run-with-wrong-flow-deps_code () {
      clk printer send --flow myprinter
}

run-with-wrong-flow-deps_expected () {
      cat<<"EOEXPECTED"
error: The flow of printer.slice could not be resolved. Command printer.calib not found
error: The flow of printer.send could not be resolved. Command printer.calib not found
Usage: clk printer send [OPTIONS] PRINTER
error: No such option: --flow
Hint: If you don't know where this option comes from, try checking the parameters (with clk --no-parameter parameters show).
EOEXPECTED
}

diff -uBw <(run-with-wrong-flow-deps_code 2>&1) <(run-with-wrong-flow-deps_expected) || {
echo "Something went wrong when trying run-with-wrong-flow-deps"
exit 1
}
# script ends here
