@echo off

cl -c sha256.c
cl -c amoveo_pow.c
cl sha256.obj amoveo_pow.obj -o amoveo_c_miner
rm *.obj

erl -compile miner.erl
erl