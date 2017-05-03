#include <stdio.h>
#include <stdlib.h>

extern int our_code_starts_here() asm("our_code_starts_here");
extern int print(int val) asm("print");
extern void error(int val) asm("error");

void error(int error_code) {
  if(error_code == 0)
    fprintf(stderr, "ERROR_NON");
  else if(error_code == 1)
    fprintf(stderr, "ERROR_NONINT");
  else if(error_code == 2)
    fprintf(stderr, "ERROR_NONBOOL");
  else if(error_code ==3)
    fprintf(stderr, "ERROR_OVERFLOW");
  exit(123456);
}

int print(int val) {
  if(val == -1)
    printf("true\n");
  else if(val == 0x7fffffff)
    printf("false\n");
  else
    printf("%i\n", val/2);
   //printf("Unknown value: %#010x\n", val);
  return val;
}

int main(int argc, char** argv) {
  int result = our_code_starts_here();
  print(result);
  return 0;
}
