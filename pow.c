#include <stdio.h>
#include <memory.h>
#include <string.h>
#include "sha256.h"

//static WORD exponent(WORD, WORD);
WORD hash2integer(BYTE h[32]);
//static WORD pair2int(WORD l[2]);
static WORD pair2sci(WORD l[2]);
//static WORD lg(WORD);
//static void int2pair(WORD, WORD l[2]);
//static void sci2pair(WORD, WORD l[2]);
//static WORD sci2int(WORD);
//static WORD int2sci(WORD);
int check_pow(BYTE nonce[32], int, BYTE data[32]);

/*
static WORD exponent(WORD a, WORD b) {
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
*/

WORD hash2integer(BYTE h[32]) {
  WORD x = 0;
  for (int i = 0; i < 31; i++) {
    if (h[i] == 0) {
      x += 8;
      continue;
    } else if (h[i] < 2) {
      x += 7;
    } else if (h[i] < 4) {
      x += 6;
    } else if (h[i] < 8) {
      x += 5;
    } else if (h[i] < 16) {
      x += 4;
    } else if (h[i] < 32) {
      x += 3;
    } else if (h[i] < 64) {
      x += 2;
    } else if (h[i] < 128) {
      x += 1;
    }
    break;
  }
  WORD y[2];
  y[0] = x;
  y[1] = h[31];
  //printf("y1 is %d\n", y[1]);
  return(pair2sci(y));
}
/*
static WORD pair2int(WORD l[2]) {
  WORD a = l[0];
  WORD b = l[1];
  return((exponent(2, a) * (256 + b)) / 256);
}
*/
static WORD pair2sci(WORD l[2]) {
  WORD a = l[0];
  WORD b = l[1];
  return((256*a) + b);
}
/*
static WORD lg(WORD n) {
  if (n == 1) {
    return(n);
  }
  return (1+(lg(n / 2)));
}
static void int2pair(WORD p, WORD x[2]) {
  WORD a = (lg(p) - 1);
  x[0] = a;
  x[1] = (((p * 256) / (exponent(2, a))) - 256);
}
static void sci2pair(WORD i, WORD x[2]) {
  x[0] = (i / 256);
  x[1] = (i % 256);
}
static WORD sci2int(WORD x) {
  WORD y[2];
  sci2pair(x, y);
  return(pair2int(y));
}
static WORD int2sci(WORD x) {
  WORD y[2];
  int2pair(x, y);
  return(pair2sci(y));
}
*/
int check_pow(BYTE nonce[32], int difficulty, BYTE data[32]) {

  SHA256_CTX ctx;
  BYTE buf[32];
  BYTE text[66];//32+2+32
  for (int i = 0; i < 32; i++) {
    text[i] = data[i];
  }
  text[32] = difficulty / 256;
  text[33] = difficulty % 256;
  for (int i = 0; i < 32; i++) {
    text[i+34] = nonce[i];
  }
  sha256_init(&ctx);
  sha256_update(&ctx, text, 66);
  sha256_final(&ctx, buf);
  
  int i = hash2integer(buf);
  //printf("%d pow check pow \n", i);
  return(i > difficulty);
}
BYTE* next_nonce(BYTE nonce[32]){
  for (int i = 0; i < 32; i++) {
    if (nonce[i] == 255) {
      nonce[i] = 0;
    } else {
      nonce[i] += 1;
      return nonce;
    }
  }
  return(0);
}
BYTE* mine(BYTE nonce[32], int difficulty, BYTE data[32]) {
  while (1) {
    if (check_pow(nonce, difficulty, data)) {
      return nonce;
    }
    nonce = next_nonce(nonce);
  }
}


int main()
{
  BYTE x[32] = {
    1,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0
  };
  BYTE y[32] = {
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,5
  };
  //printf("%i\n", (hash2integer(x)));
  //printf("%i\n", (hash2integer(y)));
  //nonce difficulty data
  //printf("%i\n", (check_pow(x, 1, x)));
  //printf("%i\n", (check_pow(x, 1000, x)));
  //printf("%i\n", (check_pow(x, 1000, y)));
  //BYTE n[32] ;
  WORD difficulty = 4303;
  mine(x, WORD, y); //nonce, difficulty, data
  printf("%i, %i, %i, %i, \n", x[0], x[1], x[2], x[3]);
  return(0);
}
