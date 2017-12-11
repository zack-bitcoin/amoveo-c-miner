gcc -Wall -c sha256.c
gcc -Wall -c sha256_test.c
gcc sha256.o sha256_test.o -o main
rm *.o
