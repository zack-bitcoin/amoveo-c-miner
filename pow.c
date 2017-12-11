#include <stdio.h>
#include <memory.h>
#include <string.h>
#include "sha256.h"

WORD hash2integer(BYTE h[32]);
static WORD pair2sci(WORD l[2]);
static BYTE* next_nonce(BYTE nonce[32]);
int check_pow(BYTE nonce[32], int, BYTE data[32]);
BYTE* mine(BYTE nonce[32], int, BYTE data[32]);

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
  return(pair2sci(y));
}
static WORD pair2sci(WORD l[2]) {
  WORD a = l[0];
  WORD b = l[1];
  return((256*a) + b);
}
int check_pow(BYTE nonce[32], int difficulty, BYTE data[32]) {

  SHA256_CTX ctx;
  BYTE buf[32];
  BYTE text[66];//32+2+32
  for (int i = 0; i < 32; i++) 
    text[i] = data[i];
  text[32] = difficulty / 256;
  text[33] = difficulty % 256;
  for (int i = 0; i < 32; i++) 
    text[i+34] = nonce[i];
  sha256_init(&ctx);
  sha256_update(&ctx, text, 66);
  sha256_final(&ctx, buf);
  
  int i = hash2integer(buf);
  //printf("%d pow check pow \n", i);
  return(i > difficulty);
}
static BYTE* next_nonce(BYTE nonce[32]){
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
    if (check_pow(nonce, difficulty, data)) 
      return nonce;
    nonce = next_nonce(nonce);
  }
}

int main()
{
  BYTE x[32] = {
    0,0,0,0,0,0,0,0,
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
  //printf("%i\n", (check_pow(x, 1, x)));
  //printf("%i\n", (check_pow(x, 1000, y)));
  WORD difficulty = 5003;
  mine(x, difficulty, y); //nonce, difficulty, data
  printf("%i, %i, %i, %i, %i, %i, %i, %i, \n",
         x[0], x[1], x[2], x[3],
         x[4], x[5], x[6], x[7]);

  //write the nonce to a file
  FILE *f = fopen("nonce.txt", "w");
  if (f == NULL)
    {
      printf("Error opening file!\n");
      //exit(1);
    }
  fprintf(f, "%s", x);
  fclose(f);

  return(0);
}
