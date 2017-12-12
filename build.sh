#For development purposes, it is convenient to recompile your code every time you run it. This way if anything changed, the changes will be included.

#first recompile the C.
gcc -Wall -c sha256.c
gcc -Wall -c pow.c
gcc sha256.o pow.o -o amoveo_c_miner
rm *.o
#./main
# next recompile the erlang.
erlc miner.erl
# finally start an erlang interpreter so you can call the program.
erl

# run like this `miner:start()`


