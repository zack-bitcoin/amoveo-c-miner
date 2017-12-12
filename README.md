==== Amoveo C miner

This is the best miner for Amoveo currently available.

It expects that you are running a full node of Amoveo using port 8080, which is the default port.
[Here is a link to the main Amoveo repo, you need this running to use the miner.](https://github.com/zack-bitcoin/amoveo)

On ubuntu, it can be compiled and turned on like this: 
```
sh build.sh 
```
Then you start mining like this:
```
miner:start().
```
To turn it off, first use `Control + C`, `a`, `enter` to exit the erlang interface.
Then to kill the miner processes, do:
```
sh clean.sh
```

[The build.sh install script works for ubuntu linux](build.sh). If you are using a different system, you will have to make some simple changes.

By writing a miner for Amoveo in C, it becomes easier to write miners for the GPU and FPGAs.
This simple C miner is a template for making miners in other languages.

[Here is a link to where the same mining is implemented in erlang. The 'pow' function is the one to look at](https://github.com/BumblebeeBat/pink_crypto)