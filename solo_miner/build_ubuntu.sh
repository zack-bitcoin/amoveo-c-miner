#For development purposes, it is convenient to recompile your code every time you run it. This way if anything changed, the changes will be included.
# Since the things being compiled are so small, they can be compiled instantly, and there is no cost to recompiling every time we run the software.

#first recompile the C.
gcc -Wall -c sha256.c
gcc -Wall -c amoveo_pow.c
gcc sha256.o amoveo_pow.o -o amoveo_c_miner
rm *.o
# next recompile the erlang.
erlc miner.erl
# finally start an erlang interpreter so you can call the program.
erl

# run like this `miner:start()`


