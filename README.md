Amoveo C miner
=============

This is the best miner for Amoveo currently available.

[First, if you haven't installed the dependencies, do that here.](https://github.com/zack-bitcoin/amoveo/blob/master/docs/getting-started/dependencies.md)

## configure

You can connect it to a full node. Change the url at the top of miner.erl to point to your full node. It is named `Peer`. This gives all your money to whoever runs that full node.

You can also connect to a mining pool. If you connect to a mining pool, you get paid by the person running the pool.
This way you don't have to run Amoveo.
set `Peer` to be the url for the mining pool.

By default `Peer` is set up to connect to a public mining pool.

Put your pubkey into the `Pubkey` definition at the top of miner.erl so that you can get paid. 

By default it uses 3 threads for mining. To change this, change the line near the top of `miner.erl`
It says `-define(CORES, 3).`

Change the 3 to the number of threads that you want to mine with. Usually, this should be the same as, or one less than the number of CPU cores on your computer.



## mining

On ubuntu, the miner in C language can be compiled and turned on like this: 
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





## Check how fast you can mine in megahashes per second.

You can do a speed test to measure how fast your computer is able to mine. First build the software normally
```
sh build_ubuntu.sh
```
Then change the settings to be in speed-test mode.
```
miner:speed_test().
```
then quit from erlang
```
halt().
```
now run the c program alone
```
./amoveo_c_miner
```

## other notes

[The build.sh install script works for ubuntu linux](build_ubuntu.sh). If you are using a different system, you will have to make some simple changes.

By writing a miner for Amoveo in C, it becomes easier to write miners for the GPU and FPGAs.
This simple C miner is a template for making miners in other languages.

[Here is a link to where the same mining is implemented in erlang. The 'pow' function is the one to look at](https://github.com/BumblebeeBat/pink_crypto)

[Here is a link to the main Amoveo repo.](https://github.com/zack-bitcoin/amoveo). If you want to solo mine without a mining pool, you will need this. Solo miners make more profit.
