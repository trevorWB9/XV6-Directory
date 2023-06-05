// "ticks" device driver"

#include "types.h"
#include "defs.h"
#include "param.h" // for NDEV
#include "traps.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h" // for struct devsw
//#include "memlayout.h"
//#include "mmu.h"
//#include "proc.h"
//#include "x86.h"


/*
// Copy into outbuffer at most n characters of string.
static int s_cnputs(char *outbuffer, int n, const char* string)
{
    int count = 0;

    for(; count < n && '\0' != string[count]; ++count)  {
        outbuffer[count] = string[count];
    }
    if(count < n) {
        outbuffer[count] = '\0';
    }
    return count;
}
*/

// /*

// Type for functions that can "output" a single character either to a 
// file descriptor or a character buffer of at least length characters.
typedef void (*putFunction_t)(int fd, char *outbuffer, uint length, uint index, char c);

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
  if(index < length)
  {
    outbuffer[index] = c;
  }
}

// This function stores a reverse text representation of xx expressed in 
// base [10 or 16] into outbuf. Reversed means that the most significant digit
// is last in the text representation instead of first. It is necessary to
// output the characters in outbuf from last to first to get the normal
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
  while(i + 1 < length && x != 0) {
    outbuf[i++] = digits[x % base];
    x /= base;
  }

  if(neg && i < length) {
    outbuf[i++] = '-';
  }

  return i;
}

static uint 
s_printint(putFunction_t putcFunction, 
  int fd, char *outbuf, uint length, int xx, int base, int sgn)
{
  static const uint localBufferLength = 16; 
  char localBuffer[localBufferLength];

  uint result = 
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);

  // Reverse the digits to put them in normal print order with most significant
  // to the left
  int j = 0;
  int i = result;
  while(--i >= 0 && j < length) 
  {
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
    j++;
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
}

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1; // leave room for nul termination

  state = 0;
  for(i = 0; fmt[i] && outindex < length; i++) {
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
        putcFunction(fd, outbuffer, length, outindex++, c);
      }
      state = 0;
    }
  }
  
  return s_min(length, outindex);
}

// Print into outbuffer at most n characters. Only understands %d, %x, %p, %s.
// If n is greater than 0, a terminating nul is always stored in outbuffer.
// \return the number of characters written to outbuffer not counting the
// terminating nul.
int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
  if(count < n) {
    outbuffer[count] = 0; // Assure nul termination
  } 

  return count;
}

// */

int
ticksread(struct inode *ip, char *dst, int n)
{
    // return s_cnputs(dst, n, "0");
    return snprintf(dst, n, "%d", ticks);
//    s_cnputs(dst, n, "Hello, World!");
}

int
tickswrite(struct inode *ip, char *buf, int n)
{
    return 0;
}

void
ticksinit(void)
{
  devsw[TICKS].write = tickswrite;
  devsw[TICKS].read = ticksread;
}