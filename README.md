Amoveo C miner
=============

This is the best miner for Amoveo currently available.


## Dependencies
```
   sudo apt-get install erlang libncurses5-dev libssl-dev unixodbc-dev g++ git
```
You might need less than what is listed above ^
[If you still have trouble with dependencies, look at dependencies from Amoveo: ](https://github.com/zack-bitcoin/amoveo/blob/master/docs/getting-started/dependencies.md)


## installation
```
git clone https://github.com/zack-bitcoin/amoveo-c-miner.git
```


## configure

You can connect it to a full node. Change the url at the top of miner.erl to point to your full node. It is named `Peer`. This gives all your money to whoever runs that full node.

You can also connect to a mining pool. If you connect to a mining pool, you get paid by the person running the pool.
This way you don't have to run Amoveo.
set `Peer` to be the url for the mining pool.

By default `Peer` is set up to connect to a public mining pool.

Put your pubkey into the `Pubkey` definition at the top of miner.erl so that you can get paid. 

By default it uses 2 threads for mining. To change this, change the line near the top of `miner.erl`
It says `-define(CORES, 2).`

Change the 2 to the number of threads that you want to mine with. Usually, this should be the same as, or one less than the number of CPU cores on your computer.

You can tell it to sleep in between mining periods so that you consume less CPU for mining.



## mining

On ubuntu, the miner in C language can be compiled and turned on like this: 
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

On windows, you'll need [Visual Studio Community 2017](https://www.visualstudio.com/downloads/). To compile the miner, you have to run the Visual Studio and open `Tools > Visual Studio Command Prompt`. Then within the command prompt:
```
cd <miner_repo_path>
build.bat
```
Then, just like on ubuntu, start miner by:
```
miner:start().
```



## Check how fast you can mine in megahashes per second.

You can do a speed test to measure how fast your computer is able to mine. First build the software normally
```
sh build.sh
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

[The build.sh install script works for ubuntu linux and Mac OSX](build.sh). If you are using a different system, you will have to make some simple changes.

By writing a miner for Amoveo in C, it becomes easier to write miners for the GPU and FPGAs.
This simple C miner is a template for making miners in other languages.

[Here is a link to where the same mining is implemented in erlang. The 'pow' function is the one to look at](https://github.com/BumblebeeBat/pink_crypto)

[Here is a link to the main Amoveo repo.](https://github.com/zack-bitcoin/amoveo). If you want to solo mine without a mining pool, you will need this. Solo miners make more profit.
