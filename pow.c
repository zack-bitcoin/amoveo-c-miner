#include <stdio.h>
//#include <memory.h>
//#include <string.h>
//#define pair2sci(A) ((exponent(2, l[0]) * (256 + b)) / 256)
#define int2pair_macro(p)\
  int x[2];\
  int a = (lg(p) - 1);\
  int b = (((p * 256) / (exponent(2, a))) - 256);\
  x[0] = a;\
  x[1] = b;
  

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

int hash2integer(int* binary, int x)
{
  return(0);
}
int pair2int(int l[2])
{
  int a = l[0];
  int b = l[1];
  return((exponent(2, a) * (256 + b)) / 256);
}
int pair2sci(int l[2])
{
  int a = l[0];
  int b = l[1];
  return((256*a) + b);
}
int lg(int n)
{
  if (n == 1) {
    return(n);
  }
  return (1+(lg(n / 2)));
}
void int2pair(int p, int x[2])
{
  int a = (lg(p) - 1);
  int b = (((p * 256) / (exponent(2, a))) - 256);
  x[0] = a;
  x[1] = b;
}
void sci2pair(int i, int x[2])
{
  int a = (i / 256);
  int b = (i % 256);
  x[0] = a;
  x[1] = b;
}
int sci2int(int x)
{
  int y[2];
  sci2pair(x, y);
  pair2int(y);
  return(pair2int(y));
}
int int2sci(int x)
{
  int y[2];
  int2pair(x, y);
  return(pair2sci(y));
}
int check_pow(int nonce, int difficulty, int data) {
  //Y = <<data/binary, difficulty:16, nonce:256>>,
  //H2 = hash:doit(Y, HashSize),
  //I = hash2integer(H2),
  //return(I > difficulty)
  return(0);
}


int main()
{
  printf("%i\n", (int2sci(sci2int(5000))));
  return(0);
}
