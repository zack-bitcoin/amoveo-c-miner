Amoveo C miner
=============

This is the best miner for Amoveo currently available.

It expects that you are running a full node of Amoveo using port 8080, which is the default port.
[Here is a link to the main Amoveo repo.](https://github.com/zack-bitcoin/amoveo)

On ubuntu, it can be compiled and turned on like this: 
```
sh build_ubuntu.sh 
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

By default it uses 3 threads for mining. To change this, change the line near the top of `miner.erl`
It says `-define(CORES, 3).`

Change the 3 to the number of threads that you want to mine with. Usually, this should be the same as, or one less than the number of CPU cores on your computer.

[The build.sh install script works for ubuntu linux](build_ubuntu.sh). If you are using a different system, you will have to make some simple changes.

By writing a miner for Amoveo in C, it becomes easier to write miners for the GPU and FPGAs.
This simple C miner is a template for making miners in other languages.

[Here is a link to where the same mining is implemented in erlang. The 'pow' function is the one to look at](https://github.com/BumblebeeBat/pink_crypto)