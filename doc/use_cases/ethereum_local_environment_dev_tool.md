- [advanced use case, caching the result](#e909c8aa-34f1-499c-b789-2581ec67e4f2)

When needing to play with ethereum, I created a [clk extension](https://github.com/clk-project/clk_extension_eth) to do so. I will simply mock this extension right now so that we won't have to install a local blockchain node to reproduce the story, but it should feel the same.

In particular, I will focus only the part that discuss with smart contracts.

```bash
clk command create python eth --description "Play with ethereum" --group --body "
@eth.group()
@option('--abi-path', help='Where the abi description is located', required=True)
@option('--address', help='The address of the contract', required=True)
def contract(abi_path, address):
    'Discuss with a smart contract'
    print(f'I would discuss with the contract whose address is {address} and abi path is {abi_path}')

@contract.command()
@argument('name', help='The function to call on the contract', type=click.Choice(['dosomething', 'dosomethingelse']))
def call(name):
    'Call a function'
    print(f'I would call the function {name}')
"
```

This command simulates the discussion with a contract.

```bash
clk eth contract --abi-path some.json --address 0xdeadbeef call dosomething
```

    I would discuss with the contract whose address is 0xdeadbeef and abi path is some.json
    I would call the function dosomething

This is a quite generic way to discuss with contracts, but it is not practical. Fortunately, aliases are here to help.

```bash
clk alias set eth.mycontract eth contract --abi-path some.json --address 0xdeadbeef
```

Then, I can simply call the contract function.

```bash
clk eth mycontract call dosomething
```

    I would discuss with the contract whose address is 0xdeadbeef and abi path is some.json
    I would call the function dosomething

I can even take advantage of the completion.

```bash
clk eth mycontract call do<TAB>
```

    dosomething
    dosomethingelse

Unfortunately, this is still not ideal. Each time I deploy the contract, its address will change. So I would like to avoid the hardcoded value `0xdeadbeef`.

Let's do that using the `eval:` value.

First, let's add clk commands to simulate deploying a contract and fetching its address.

```bash
clk command create bash --force eth.deploy --description 'Deploy a new contract, save its address locally' --body '

# we simply want that each time this code is run, it returns something
# different. But for the sake of this example, we also want the code to return
# something reproducible

if test -e contract-address.txt
then
   prev="$(cat contract-address.txt)"
else
   prev=""
fi

echo ${prev} | md5sum | cut -f1 -d" " > contract-address.txt
clk log "Contract deployed at address: $(cat contract-address.txt)"
'
```

Let's try it

```bash
clk eth deploy
clk eth deploy
```

    Contract deployed at address: 68b329da9893e34099c7d8ad5cb9c940
    Contract deployed at address: 223632c428784fecaaa3e2a6aaaf6d8e

Now, we want to have a command to get this address, so that we will be able to put it in the definition of another command. In this mock, it simply shows the value stored in the `contract-address.txt` file. Therefore, an alias is more than enough.

```bash
clk alias set eth.get-address exec cat contract-address.txt
clk eth get-address
```

    New global alias for eth.get-address: exec cat contract-address.txt
    223632c428784fecaaa3e2a6aaaf6d8e

Now, let's use a call to this command instead of hardcoding `0xdeadbeef`.

```bash
clk alias set eth.mycontract eth contract --abi-path some.json --address "noeval:eval:clk eth get-address"
```

The first `noeval:` tells clk not to evaluate this command when creating the alias, otherwise, the alias would be defined with the result of the `eval:`, while we actually want it to be defined verbatim.

Now, the mycontract command it done. The value of the address it communicates with is dynamically updated.

```bash
clk eth mycontract call dosomething
clk eth deploy
clk eth mycontract call dosomething
```

    I would discuss with the contract whose address is 223632c428784fecaaa3e2a6aaaf6d8e and abi path is some.json
    I would call the function dosomething
    Contract deployed at address: 47156ddb404b893cbbe9c85509710f64
    I would discuss with the contract whose address is 47156ddb404b893cbbe9c85509710f64 and abi path is some.json
    I would call the function dosomething


<a id="e909c8aa-34f1-499c-b789-2581ec67e4f2"></a>

# advanced use case, caching the result

In case `eval:clk eth get-address` takes some time to run, you can make use of caching, using `eval(60):clk eth get-address`. This will cache the result for 60 seconds, making only the first call be slow.

This is particularly handy in case you use the completion of clk a lot and are annoying by the time it may take to answer.

Of course, you might object that, because the result is cached, we could be out of sync. Indeed, let's consider the following example, where the command line is cached and we deploy again.

```bash
clk alias set eth.mycontract eth contract --abi-path some.json --address "noeval:eval(60):clk eth get-address"
clk eth mycontract call dosomething
clk eth deploy
clk eth mycontract call dosomething
```

    Removing global alias of eth.mycontract: eth contract --abi-path some.json --address eval:clk eth get-address
    New global alias for eth.mycontract: eth contract --abi-path some.json --address eval(60):clk eth get-address
    I would discuss with the contract whose address is 47156ddb404b893cbbe9c85509710f64 and abi path is some.json
    I would call the function dosomething
    Contract deployed at address: ed5b4c043e36c30f31a158e8bda16e2b
    I would discuss with the contract whose address is 47156ddb404b893cbbe9c85509710f64 and abi path is some.json
    I would call the function dosomething

As you can see, even though we create a new contract, the command still use the last address. This is expected, as its result is cached for 60 seconds.

One way to mitigate this is to use the experimental command `parameter drop-cache` when deploying the contract.

```bash
clk eth mycontract call dosomething
clk eth deploy && clk parameter drop-cache "clk eth get-address"
clk eth mycontract call dosomething
```

    I would discuss with the contract whose address is 47156ddb404b893cbbe9c85509710f64 and abi path is some.json
    I would call the function dosomething
    Contract deployed at address: 53303a8fa63a943a2591b8de2b026da6
    I would discuss with the contract whose address is 53303a8fa63a943a2591b8de2b026da6 and abi path is some.json
    I would call the function dosomething

Now, we are finished with this command. It is reactive because the slow computation is cached, but you can still invalidate the cache if need be, avoiding making it inconsistent.
