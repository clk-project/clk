#!/bin/bash -eu
# [[id:841a8082-597b-45cc-8a4d-115e31137dc9::script][script]]
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

echo 'Run run_flow'

{ run_flow_code || true ; } > "${TMP}/code.txt" 2>&1
run_flow_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run_flow"
exit 1
}


  clk command create python --group printer --description "This is a group of commands to deal with 3D printing." --body '
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

echo 'Run running-the-explicit-flow'

{ running-the-explicit-flow_code || true ; } > "${TMP}/code.txt" 2>&1
running-the-explicit-flow_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
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

echo 'Run running-the-explicit-flow-with-model'

{ running-the-explicit-flow-with-model_code || true ; } > "${TMP}/code.txt" 2>&1
running-the-explicit-flow-with-model_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying running-the-explicit-flow-with-model"
exit 1
}



flowdep-show_code () {
      clk flowdep show printer.send --all
}

flowdep-show_expected () {
      cat<<"EOEXPECTED"
printer.send printer.calibrate printer.slice
EOEXPECTED
}

echo 'Run flowdep-show'

{ flowdep-show_code || true ; } > "${TMP}/code.txt" 2>&1
flowdep-show_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying flowdep-show"
exit 1
}


clk flowdep graph printer.send --format png --output flow.png

echo "Checking the resulting flow.png file"
test "$(sha256sum flow.png|cut -f1 -d' ')" = "$(sha256sum ${SRCDIR}/../../doc/use_cases/flow.png|cut -f1 -d' ')"


flow-verbose_code () {
      clk --flow-verbose printer send myprinter --flow
}

flow-verbose_expected () {
      cat<<"EOEXPECTED"
Running step 'printer calibrate'
Running some stuff for the printer to be ready to go
Running step 'printer slice'
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
}

echo 'Run flow-verbose'

{ flow-verbose_code || true ; } > "${TMP}/code.txt" 2>&1
flow-verbose_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying flow-verbose"
exit 1
}



flow-step_code () {
      yes | clk --flow-step printer send myprinter --flow
}

flow-step_expected () {
      cat<<"EOEXPECTED"
About to run step 'printer calibrate'
Press Enter to start this step: Here we go!
Running some stuff for the printer to be ready to go
About to run step 'printer slice'
Press Enter to start this step: Here we go!
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
}

echo 'Run flow-step'

{ flow-step_code || true ; } > "${TMP}/code.txt" 2>&1
flow-step_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying flow-step"
exit 1
}


  clk command create python --group printer --description "This is a group of commands to deal with 3D printing." --body '
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

echo 'Run run-with-wrong-flow-deps'

{ run-with-wrong-flow-deps_code || true ; } > "${TMP}/code.txt" 2>&1
run-with-wrong-flow-deps_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying run-with-wrong-flow-deps"
exit 1
}
# script ends here
