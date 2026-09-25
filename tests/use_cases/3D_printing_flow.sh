#!/usr/bin/env bash
# [[file:../../doc/use_cases/3D_printing_flow.org::script][script]]
set -eu
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
@get_command("printer.slice").flow_options()
@get_command("printer.send").flow_option("warn_when_done")
@get_command("printer.send").flow_argument("printer")
def flow(**kwargs):
    """Run the whole flow"""
    print("The flow is done")
EOF


run_flow_code () {
      clk printer flow myprinter --model somemodel --model someothermodel --output some.gcode --warn-when-done
}

run_flow_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running some stuff for the printer to be ready to go
Slicing somemodel, someothermodel to some.gcode
Printing model.gcode using myprinter
Driiiiiiing!
The flow is done
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_flow'

{ run_flow_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run_flow"
else
    run_flow_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_flow"
        exit 1
    }
fi


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
      local expected
      expected="$(cat<<"EOEXPECTED"
# Running the send command, without the flow
Printing model.gcode using myprinter
# Running the send command, asking for its flow
Running some stuff for the printer to be ready to go
Slicing model.stl to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run running-the-explicit-flow'

{ running-the-explicit-flow_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/running-the-explicit-flow"
else
    running-the-explicit-flow_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying running-the-explicit-flow"
        exit 1
    }
fi



running-the-explicit-flow-with-model_code () {
      clk parameter set printer.slice --model someothermodel
      clk printer send myprinter --flow
}

running-the-explicit-flow-with-model_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m parameters for printer.slice: --model someothermodel
Running some stuff for the printer to be ready to go
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run running-the-explicit-flow-with-model'

{ running-the-explicit-flow-with-model_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/running-the-explicit-flow-with-model"
else
    running-the-explicit-flow-with-model_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying running-the-explicit-flow-with-model"
        exit 1
    }
fi



running-the-flow-from_code () {
      clk printer send myprinter --flow-from printer.slice
}

running-the-flow-from_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run running-the-flow-from'

{ running-the-flow-from_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/running-the-flow-from"
else
    running-the-flow-from_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying running-the-flow-from"
        exit 1
    }
fi



running-the-flow-after_code () {
      clk printer send myprinter --flow-after printer.slice
}

running-the-flow-after_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run running-the-flow-after'

{ running-the-flow-after_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/running-the-flow-after"
else
    running-the-flow-after_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying running-the-flow-after"
        exit 1
    }
fi



gcode-in-value_code () {
      clk value set gcode print.gcode
      clk parameter set printer.slice --model someothermodel --output noeval:value:gcode
      clk parameter set printer.send --gcode noeval:value:gcode
      clk printer send myprinter --flow
}

gcode-in-value_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Removing [36mglobal[0m parameters of printer.slice: --model someothermodel
New [36mglobal[0m parameters for printer.slice: --model someothermodel --output value:gcode
New [36mglobal[0m parameters for printer.send: --gcode value:gcode
Running some stuff for the printer to be ready to go
Slicing someothermodel to print.gcode
Printing print.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run gcode-in-value'

{ gcode-in-value_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/gcode-in-value"
else
    gcode-in-value_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying gcode-in-value"
        exit 1
    }
fi



move-gcode-value_code () {
      clk value set gcode other.gcode
      clk printer send myprinter --flow
}

move-gcode-value_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running some stuff for the printer to be ready to go
Slicing someothermodel to other.gcode
Printing other.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run move-gcode-value'

{ move-gcode-value_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/move-gcode-value"
else
    move-gcode-value_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying move-gcode-value"
        exit 1
    }
fi


clk parameter set printer.slice --model someothermodel
clk parameter unset printer.send
clk value unset gcode


flowdep-show_code () {
      clk flowdep show printer.send --all
}

flowdep-show_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
printer.send [2mprinter.calibrate printer.slice[0m
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run flowdep-show'

{ flowdep-show_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/flowdep-show"
else
    flowdep-show_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying flowdep-show"
        exit 1
    }
fi


clk flowdep graph printer.send --format png --output flow.png

clk flowdep graph printer.send --format dot --output flow.dot

echo "Checking the resulting flow.png file"
test "$(sha256sum flow.dot|cut -f1 -d' ')" = "$(sha256sum ${SRCDIR}/../../doc/use_cases/flow.dot|cut -f1 -d' ')"

clk flowdep graph printer.send --format dot --output - \
    | sed '1a\  label="How a print gets made";' \
    > titled-flow.dot
dot -Tpng titled-flow.dot > titled-flow.png

echo "Checking the resulting titled-flow.png file"
test "$(sha256sum titled-flow.dot|cut -f1 -d' ')" = "$(sha256sum ${SRCDIR}/../../doc/use_cases/titled-flow.dot|cut -f1 -d' ')"

clk flowdep graph --format dot --output - > every-flow.dot

echo "Checking the resulting every-flow.dot file"
test "$(sha256sum every-flow.dot|cut -f1 -d' ')" = "$(sha256sum flow.dot|cut -f1 -d' ')"


flow-verbose_code () {
      clk --flow-verbose printer send myprinter --flow
}

flow-verbose_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
1/2 Running step 'printer calibrate'
Running some stuff for the printer to be ready to go
2/2 Running step 'printer slice'
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run flow-verbose'

{ flow-verbose_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/flow-verbose"
else
    flow-verbose_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying flow-verbose"
        exit 1
    }
fi



flow-step_code () {
      yes | clk --flow-step printer send myprinter --flow
}

flow-step_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
1/2 About to run step 'printer calibrate'
Press Enter to start this step: Here we go!
Running some stuff for the printer to be ready to go
2/2 About to run step 'printer slice'
Press Enter to start this step: Here we go!
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run flow-step'

{ flow-step_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/flow-step"
else
    flow-step_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying flow-step"
        exit 1
    }
fi



flow-progress_code () {
            output=$(
      clk --flow-progress printer send myprinter --flow 2>&1
      )
            echo "$output" | grep -q "Executing flow steps:" && echo "has_executing_flow_steps"
            echo "$output" | grep -q "printer calibrate:" && echo "has_printer_calibrate"
            echo "$output" | grep -q "printer slice:" && echo "has_printer_slice"
            echo "$output" | grep -q "█" && echo "has_progress_bar"
            echo "$output" | grep -q "Running some stuff" && echo "has_calibrate_output"
            echo "$output" | grep -q "Slicing someothermodel" && echo "has_slice_output"
            echo "$output" | grep -q "Printing model.gcode" && echo "has_send_output"
}

flow-progress_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
has_executing_flow_steps
has_printer_calibrate
has_printer_slice
has_progress_bar
has_calibrate_output
has_slice_output
has_send_output
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run flow-progress'

{ flow-progress_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/flow-progress"
else
    flow-progress_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying flow-progress"
        exit 1
    }
fi


clk alias set printer.clean echo "Cleaning the printer bed"


flowdep-set-clean_code () {
      clk flowdep set printer.calibrate printer.clean
      clk printer send myprinter --flow
}

flowdep-set-clean_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m flowdep for printer.calibrate: printer.clean
Cleaning the printer bed
Running some stuff for the printer to be ready to go
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run flowdep-set-clean'

{ flowdep-set-clean_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/flowdep-set-clean"
else
    flowdep-set-clean_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying flowdep-set-clean"
        exit 1
    }
fi


clk alias set printer.preheat echo "Preheating the nozzle"


flowdep-append_code () {
      clk flowdep append printer.calibrate printer.preheat
      clk printer send myprinter --flow
}

flowdep-append_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Cleaning the printer bed
Preheating the nozzle
Running some stuff for the printer to be ready to go
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run flowdep-append'

{ flowdep-append_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/flowdep-append"
else
    flowdep-append_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying flowdep-append"
        exit 1
    }
fi


clk alias set printer.check-filament echo "Checking filament level"


flowdep-insert_code () {
      clk flowdep insert printer.calibrate printer.check-filament
      clk printer send myprinter --flow
}

flowdep-insert_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Checking filament level
Cleaning the printer bed
Preheating the nozzle
Running some stuff for the printer to be ready to go
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run flowdep-insert'

{ flowdep-insert_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/flowdep-insert"
else
    flowdep-insert_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying flowdep-insert"
        exit 1
    }
fi



flowdep-remove_code () {
      clk flowdep remove printer.calibrate printer.preheat
      clk printer send myprinter --flow
}

flowdep-remove_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Checking filament level
Cleaning the printer bed
Running some stuff for the printer to be ready to go
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run flowdep-remove'

{ flowdep-remove_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/flowdep-remove"
else
    flowdep-remove_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying flowdep-remove"
        exit 1
    }
fi



flowdep-unset_code () {
      clk flowdep unset printer.calibrate
      clk printer send myprinter --flow
}

flowdep-unset_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Erasing printer.calibrate flow dependencies from [36mglobal[0m settings
Running some stuff for the printer to be ready to go
Slicing someothermodel to model.gcode
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run flowdep-unset'

{ flowdep-unset_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/flowdep-unset"
else
    flowdep-unset_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying flowdep-unset"
        exit 1
    }
fi



alias-with-flowdep_code () {
      clk alias set --flowdep printer.calibrate printer.nightly printer send myprinter
      clk printer nightly --flow
}

alias-with-flowdep_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New [36mglobal[0m alias for printer.nightly: printer send myprinter
New [36mglobal[0m flowdep for printer.nightly: printer.calibrate
Running some stuff for the printer to be ready to go
Printing model.gcode using myprinter
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run alias-with-flowdep'

{ alias-with-flowdep_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/alias-with-flowdep"
else
    alias-with-flowdep_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying alias-with-flowdep"
        exit 1
    }
fi


  clk command create python --group printer --description "This is a group of commands to deal with 3D printing." --body '
import click

@printer.command()
def calibrate():
    """Run everything that is needed to have the printer ready to print"""
    raise click.ClickException("the printer does not answer")

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


run-with-failing-step_code () {
      clk printer send myprinter --flow
}

run-with-failing-step_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
error: the printer does not answer
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-with-failing-step'

{ run-with-failing-step_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run-with-failing-step"
else
    run-with-failing-step_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-with-failing-step"
        exit 1
    }
fi


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
      local expected
      expected="$(cat<<"EOEXPECTED"
[31merror: [0mCould not load the flow of printer.slice with the error: Command printer.calib not found
[31merror: [0mCould not load the flow of printer.send with the error: Command printer.calib not found
[33mwarning: [0mFailed to get the command printer.send: Command printer.calib not found
error: printer.send could not be loaded. Re run with clk --develop to see the stacktrace or clk --debug-on-command-load-error to debug the load error
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-with-wrong-flow-deps'

{ run-with-wrong-flow-deps_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    mkdir -p "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)"
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/$(basename "$0" .sh)/run-with-wrong-flow-deps"
else
    run-with-wrong-flow-deps_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-with-wrong-flow-deps"
        exit 1
    }
fi
# script ends here
