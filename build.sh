gcc -Wall -c sha256.c
gcc -Wall -c pow.c
gcc sha256.o pow.o -o main
rm *.o

./main
