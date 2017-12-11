
#include <stdio.h>
//#include <memory.h>
//#include <string.h>

int exponent(int a, int b)
{
  if (b == 0) {
    return(1);
  }
  if (b == 1) {
    return(a);
  }
  if ((b % 2) == 0) {
    return(exponent((a * a), (b / 2)));
  }
  return (a * (exponent(a, (b - 1))));
}

int check_pow(int nonce, int difficulty, int data) {
  //Y = <<data/binary, difficulty:16, nonce:256>>,
  //H2 = hash:doit(Y, HashSize),
  //I = hash2integer(H2),
  //return(I > difficulty)
  
}

int lg(int n)
{
  if (n == 1) {
    return(n);
  }
  return (1+(lg(n / 2)));
}

int main()
{
  printf("here\n");
  printf("%i\n", (5 > 2));
  return(0);
}
