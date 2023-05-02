#!/bin/bash -eu
# [[file:dynamic_parameters_advanced_use_cases.org::all][all]]
. ./sandboxing.sh

clk command create python --group openapi --force
cat<<EOF >> "${CLKCONFIGDIR}/python/openapi.py"
@group()
def openapi():
    "Play with some openapi server"


class OpenApi:
    pass


class Payload(DynamicChoice):
    def choices(self):
        if config.openapi.method == "put":
            return ["a", "b", "c"]
        elif config.openapi.method == "post":
            return ["d", "e", "f"]
        else:
            return []

def put_callback(ctx, attr, value):
    config.openapi.method = "put"
    return value


@openapi.command()
@argument("path", expose_class=OpenApi, help="The path to put",
          expose_value=True, callback=put_callback)
@argument("payload", type=Payload(), help="The payload to provide")
def put(path, payload):
    "Performing the put operation"
    click.echo(f"PUT on {path} with {payload}")


def post_callback(ctx, attr, value):
    config.openapi.method = "post"
    return value


@openapi.command()
@argument("path", expose_class=OpenApi, help="The path to post",
          expose_value=True, callback=post_callback)
@argument("payload", type=Payload(), help="The payload to provide")
def post(path, payload):
    "Performing the post operation"
    click.echo(f"POST on {path} with {payload}")
EOF


use_it_code () {
      clk openapi put somepath a
      clk openapi post somepath d
}

use_it_expected () {
      cat<<EOEXPECTED
PUT on somepath with a
POST on somepath with d
EOEXPECTED
}

diff -uw <(use_it_code 2>&1) <(use_it_expected)
# all ends here
