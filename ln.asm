
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	53                   	push   %ebx
  12:	51                   	push   %ecx
  13:	8b 59 04             	mov    0x4(%ecx),%ebx
  if(argc != 3){
  16:	83 39 03             	cmpl   $0x3,(%ecx)
  19:	74 14                	je     2f <main+0x2f>
    printf(2, "Usage: ln old new\n");
  1b:	83 ec 08             	sub    $0x8,%esp
  1e:	68 04 05 00 00       	push   $0x504
  23:	6a 02                	push   $0x2
  25:	e8 ad 04 00 00       	call   4d7 <printf>
    exit();
  2a:	e8 39 00 00 00       	call   68 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2f:	83 ec 08             	sub    $0x8,%esp
  32:	ff 73 08             	pushl  0x8(%ebx)
  35:	ff 73 04             	pushl  0x4(%ebx)
  38:	e8 8b 00 00 00       	call   c8 <link>
  3d:	83 c4 10             	add    $0x10,%esp
  40:	85 c0                	test   %eax,%eax
  42:	78 05                	js     49 <main+0x49>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit();
  44:	e8 1f 00 00 00       	call   68 <exit>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  49:	ff 73 08             	pushl  0x8(%ebx)
  4c:	ff 73 04             	pushl  0x4(%ebx)
  4f:	68 17 05 00 00       	push   $0x517
  54:	6a 02                	push   $0x2
  56:	e8 7c 04 00 00       	call   4d7 <printf>
  5b:	83 c4 10             	add    $0x10,%esp
  5e:	eb e4                	jmp    44 <main+0x44>

00000060 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  60:	b8 01 00 00 00       	mov    $0x1,%eax
  65:	cd 40                	int    $0x40
  67:	c3                   	ret    

00000068 <exit>:
SYSCALL(exit)
  68:	b8 02 00 00 00       	mov    $0x2,%eax
  6d:	cd 40                	int    $0x40
  6f:	c3                   	ret    

00000070 <wait>:
SYSCALL(wait)
  70:	b8 03 00 00 00       	mov    $0x3,%eax
  75:	cd 40                	int    $0x40
  77:	c3                   	ret    

00000078 <pipe>:
SYSCALL(pipe)
  78:	b8 04 00 00 00       	mov    $0x4,%eax
  7d:	cd 40                	int    $0x40
  7f:	c3                   	ret    

00000080 <read>:
SYSCALL(read)
  80:	b8 05 00 00 00       	mov    $0x5,%eax
  85:	cd 40                	int    $0x40
  87:	c3                   	ret    

00000088 <write>:
SYSCALL(write)
  88:	b8 10 00 00 00       	mov    $0x10,%eax
  8d:	cd 40                	int    $0x40
  8f:	c3                   	ret    

00000090 <close>:
SYSCALL(close)
  90:	b8 15 00 00 00       	mov    $0x15,%eax
  95:	cd 40                	int    $0x40
  97:	c3                   	ret    

00000098 <kill>:
SYSCALL(kill)
  98:	b8 06 00 00 00       	mov    $0x6,%eax
  9d:	cd 40                	int    $0x40
  9f:	c3                   	ret    

000000a0 <exec>:
SYSCALL(exec)
  a0:	b8 07 00 00 00       	mov    $0x7,%eax
  a5:	cd 40                	int    $0x40
  a7:	c3                   	ret    

000000a8 <open>:
SYSCALL(open)
  a8:	b8 0f 00 00 00       	mov    $0xf,%eax
  ad:	cd 40                	int    $0x40
  af:	c3                   	ret    

000000b0 <mknod>:
SYSCALL(mknod)
  b0:	b8 11 00 00 00       	mov    $0x11,%eax
  b5:	cd 40                	int    $0x40
  b7:	c3                   	ret    

000000b8 <unlink>:
SYSCALL(unlink)
  b8:	b8 12 00 00 00       	mov    $0x12,%eax
  bd:	cd 40                	int    $0x40
  bf:	c3                   	ret    

000000c0 <fstat>:
SYSCALL(fstat)
  c0:	b8 08 00 00 00       	mov    $0x8,%eax
  c5:	cd 40                	int    $0x40
  c7:	c3                   	ret    

000000c8 <link>:
SYSCALL(link)
  c8:	b8 13 00 00 00       	mov    $0x13,%eax
  cd:	cd 40                	int    $0x40
  cf:	c3                   	ret    

000000d0 <mkdir>:
SYSCALL(mkdir)
  d0:	b8 14 00 00 00       	mov    $0x14,%eax
  d5:	cd 40                	int    $0x40
  d7:	c3                   	ret    

000000d8 <chdir>:
SYSCALL(chdir)
  d8:	b8 09 00 00 00       	mov    $0x9,%eax
  dd:	cd 40                	int    $0x40
  df:	c3                   	ret    

000000e0 <dup>:
SYSCALL(dup)
  e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  e5:	cd 40                	int    $0x40
  e7:	c3                   	ret    

000000e8 <getpid>:
SYSCALL(getpid)
  e8:	b8 0b 00 00 00       	mov    $0xb,%eax
  ed:	cd 40                	int    $0x40
  ef:	c3                   	ret    

000000f0 <sbrk>:
SYSCALL(sbrk)
  f0:	b8 0c 00 00 00       	mov    $0xc,%eax
  f5:	cd 40                	int    $0x40
  f7:	c3                   	ret    

000000f8 <sleep>:
SYSCALL(sleep)
  f8:	b8 0d 00 00 00       	mov    $0xd,%eax
  fd:	cd 40                	int    $0x40
  ff:	c3                   	ret    

00000100 <uptime>:
SYSCALL(uptime)
 100:	b8 0e 00 00 00       	mov    $0xe,%eax
 105:	cd 40                	int    $0x40
 107:	c3                   	ret    

00000108 <yield>:
SYSCALL(yield)
 108:	b8 16 00 00 00       	mov    $0x16,%eax
 10d:	cd 40                	int    $0x40
 10f:	c3                   	ret    

00000110 <shutdown>:
SYSCALL(shutdown)
 110:	b8 17 00 00 00       	mov    $0x17,%eax
 115:	cd 40                	int    $0x40
 117:	c3                   	ret    

00000118 <nice>:
SYSCALL(nice)
 118:	b8 18 00 00 00       	mov    $0x18,%eax
 11d:	cd 40                	int    $0x40
 11f:	c3                   	ret    

00000120 <cps>:
SYSCALL(cps)
 120:	b8 19 00 00 00       	mov    $0x19,%eax
 125:	cd 40                	int    $0x40
 127:	c3                   	ret    

00000128 <s_sputc>:
  write(fd, &c, 1);
}

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
 128:	f3 0f 1e fb          	endbr32 
 12c:	55                   	push   %ebp
 12d:	89 e5                	mov    %esp,%ebp
 12f:	8b 45 14             	mov    0x14(%ebp),%eax
 132:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
 135:	3b 45 10             	cmp    0x10(%ebp),%eax
 138:	73 06                	jae    140 <s_sputc+0x18>
  {
    outbuffer[index] = c;
 13a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 13d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
 140:	5d                   	pop    %ebp
 141:	c3                   	ret    

00000142 <s_getReverseDigits>:
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
 145:	57                   	push   %edi
 146:	56                   	push   %esi
 147:	53                   	push   %ebx
 148:	83 ec 08             	sub    $0x8,%esp
 14b:	89 c6                	mov    %eax,%esi
 14d:	89 d3                	mov    %edx,%ebx
 14f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 152:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 156:	0f 95 c2             	setne  %dl
 159:	89 c8                	mov    %ecx,%eax
 15b:	c1 e8 1f             	shr    $0x1f,%eax
 15e:	84 c2                	test   %al,%dl
 160:	74 33                	je     195 <s_getReverseDigits+0x53>
    neg = 1;
    x = -xx;
 162:	89 c8                	mov    %ecx,%eax
 164:	f7 d8                	neg    %eax
    neg = 1;
 166:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 16d:	bf 00 00 00 00       	mov    $0x0,%edi
  while(i + 1 < length && x != 0) {
 172:	8d 4f 01             	lea    0x1(%edi),%ecx
 175:	89 ca                	mov    %ecx,%edx
 177:	39 d9                	cmp    %ebx,%ecx
 179:	73 26                	jae    1a1 <s_getReverseDigits+0x5f>
 17b:	85 c0                	test   %eax,%eax
 17d:	74 22                	je     1a1 <s_getReverseDigits+0x5f>
    outbuf[i++] = digits[x % base];
 17f:	ba 00 00 00 00       	mov    $0x0,%edx
 184:	f7 75 08             	divl   0x8(%ebp)
 187:	0f b6 92 34 05 00 00 	movzbl 0x534(%edx),%edx
 18e:	88 14 3e             	mov    %dl,(%esi,%edi,1)
 191:	89 cf                	mov    %ecx,%edi
 193:	eb dd                	jmp    172 <s_getReverseDigits+0x30>
    x = xx;
 195:	8b 45 f0             	mov    -0x10(%ebp),%eax
  neg = 0;
 198:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 19f:	eb cc                	jmp    16d <s_getReverseDigits+0x2b>
    x /= base;
  }

  if(0 == xx && i + 1 < length) {
 1a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a5:	75 0a                	jne    1b1 <s_getReverseDigits+0x6f>
 1a7:	39 da                	cmp    %ebx,%edx
 1a9:	73 06                	jae    1b1 <s_getReverseDigits+0x6f>
    outbuf[i++] = digits[0];   
 1ab:	c6 04 3e 30          	movb   $0x30,(%esi,%edi,1)
 1af:	89 cf                	mov    %ecx,%edi
  }

  if(neg && i < length) {
 1b1:	89 fa                	mov    %edi,%edx
 1b3:	39 df                	cmp    %ebx,%edi
 1b5:	0f 92 c0             	setb   %al
 1b8:	84 45 ec             	test   %al,-0x14(%ebp)
 1bb:	74 07                	je     1c4 <s_getReverseDigits+0x82>
    outbuf[i++] = '-';
 1bd:	83 c7 01             	add    $0x1,%edi
 1c0:	c6 04 16 2d          	movb   $0x2d,(%esi,%edx,1)
  }

  return i;
}
 1c4:	89 f8                	mov    %edi,%eax
 1c6:	83 c4 08             	add    $0x8,%esp
 1c9:	5b                   	pop    %ebx
 1ca:	5e                   	pop    %esi
 1cb:	5f                   	pop    %edi
 1cc:	5d                   	pop    %ebp
 1cd:	c3                   	ret    

000001ce <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
 1ce:	39 c2                	cmp    %eax,%edx
 1d0:	0f 46 c2             	cmovbe %edx,%eax
}
 1d3:	c3                   	ret    

000001d4 <s_printint>:
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	57                   	push   %edi
 1d8:	56                   	push   %esi
 1d9:	53                   	push   %ebx
 1da:	83 ec 2c             	sub    $0x2c,%esp
 1dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 1e0:	89 55 d0             	mov    %edx,-0x30(%ebp)
 1e3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 1e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);
 1e9:	ff 75 14             	pushl  0x14(%ebp)
 1ec:	ff 75 10             	pushl  0x10(%ebp)
 1ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 1f2:	ba 10 00 00 00       	mov    $0x10,%edx
 1f7:	8d 45 d8             	lea    -0x28(%ebp),%eax
 1fa:	e8 43 ff ff ff       	call   142 <s_getReverseDigits>
 1ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
 202:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
 204:	83 c4 08             	add    $0x8,%esp
  int j = 0;
 207:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
 20c:	83 eb 01             	sub    $0x1,%ebx
 20f:	78 22                	js     233 <s_printint+0x5f>
 211:	39 fe                	cmp    %edi,%esi
 213:	73 1e                	jae    233 <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
 215:	83 ec 0c             	sub    $0xc,%esp
 218:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
 21d:	50                   	push   %eax
 21e:	56                   	push   %esi
 21f:	57                   	push   %edi
 220:	ff 75 cc             	pushl  -0x34(%ebp)
 223:	ff 75 d0             	pushl  -0x30(%ebp)
 226:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 229:	ff d0                	call   *%eax
    j++;
 22b:	83 c6 01             	add    $0x1,%esi
 22e:	83 c4 20             	add    $0x20,%esp
 231:	eb d9                	jmp    20c <s_printint+0x38>
}
 233:	8b 45 c8             	mov    -0x38(%ebp),%eax
 236:	8d 65 f4             	lea    -0xc(%ebp),%esp
 239:	5b                   	pop    %ebx
 23a:	5e                   	pop    %esi
 23b:	5f                   	pop    %edi
 23c:	5d                   	pop    %ebp
 23d:	c3                   	ret    

0000023e <s_printf>:

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
 23e:	55                   	push   %ebp
 23f:	89 e5                	mov    %esp,%ebp
 241:	57                   	push   %edi
 242:	56                   	push   %esi
 243:	53                   	push   %ebx
 244:	83 ec 2c             	sub    $0x2c,%esp
 247:	89 45 d8             	mov    %eax,-0x28(%ebp)
 24a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 24d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1; // leave room for nul termination
 250:	8b 45 08             	mov    0x8(%ebp),%eax
 253:	8d 78 ff             	lea    -0x1(%eax),%edi

  state = 0;
 256:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
 25d:	bb 00 00 00 00       	mov    $0x0,%ebx
 262:	89 f8                	mov    %edi,%eax
 264:	89 df                	mov    %ebx,%edi
 266:	89 c6                	mov    %eax,%esi
 268:	eb 20                	jmp    28a <s_printf+0x4c>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
 26a:	8d 43 01             	lea    0x1(%ebx),%eax
 26d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 270:	83 ec 0c             	sub    $0xc,%esp
 273:	51                   	push   %ecx
 274:	53                   	push   %ebx
 275:	56                   	push   %esi
 276:	ff 75 d0             	pushl  -0x30(%ebp)
 279:	ff 75 d4             	pushl  -0x2c(%ebp)
 27c:	8b 55 d8             	mov    -0x28(%ebp),%edx
 27f:	ff d2                	call   *%edx
 281:	83 c4 20             	add    $0x20,%esp
 284:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
 287:	83 c7 01             	add    $0x1,%edi
 28a:	8b 45 0c             	mov    0xc(%ebp),%eax
 28d:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
 291:	84 c0                	test   %al,%al
 293:	0f 84 cd 01 00 00    	je     466 <s_printf+0x228>
 299:	89 75 e0             	mov    %esi,-0x20(%ebp)
 29c:	39 de                	cmp    %ebx,%esi
 29e:	0f 86 c2 01 00 00    	jbe    466 <s_printf+0x228>
    c = fmt[i] & 0xff;
 2a4:	0f be c8             	movsbl %al,%ecx
 2a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 2aa:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 2ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 2b1:	75 0a                	jne    2bd <s_printf+0x7f>
      if(c == '%') {
 2b3:	83 f8 25             	cmp    $0x25,%eax
 2b6:	75 b2                	jne    26a <s_printf+0x2c>
        state = '%';
 2b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 2bb:	eb ca                	jmp    287 <s_printf+0x49>
      }
    } else if(state == '%'){
 2bd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 2c1:	75 c4                	jne    287 <s_printf+0x49>
      if(c == 'd'){
 2c3:	83 f8 64             	cmp    $0x64,%eax
 2c6:	74 6e                	je     336 <s_printf+0xf8>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 2c8:	83 f8 78             	cmp    $0x78,%eax
 2cb:	0f 94 c1             	sete   %cl
 2ce:	83 f8 70             	cmp    $0x70,%eax
 2d1:	0f 94 c2             	sete   %dl
 2d4:	08 d1                	or     %dl,%cl
 2d6:	0f 85 8e 00 00 00    	jne    36a <s_printf+0x12c>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 2dc:	83 f8 73             	cmp    $0x73,%eax
 2df:	0f 84 b9 00 00 00    	je     39e <s_printf+0x160>
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
 2e5:	83 f8 63             	cmp    $0x63,%eax
 2e8:	0f 84 1a 01 00 00    	je     408 <s_printf+0x1ca>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
 2ee:	83 f8 25             	cmp    $0x25,%eax
 2f1:	0f 84 44 01 00 00    	je     43b <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
 2f7:	8d 43 01             	lea    0x1(%ebx),%eax
 2fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 2fd:	83 ec 0c             	sub    $0xc,%esp
 300:	6a 25                	push   $0x25
 302:	53                   	push   %ebx
 303:	56                   	push   %esi
 304:	ff 75 d0             	pushl  -0x30(%ebp)
 307:	ff 75 d4             	pushl  -0x2c(%ebp)
 30a:	8b 45 d8             	mov    -0x28(%ebp),%eax
 30d:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
 30f:	83 c3 02             	add    $0x2,%ebx
 312:	83 c4 14             	add    $0x14,%esp
 315:	ff 75 dc             	pushl  -0x24(%ebp)
 318:	ff 75 e4             	pushl  -0x1c(%ebp)
 31b:	56                   	push   %esi
 31c:	ff 75 d0             	pushl  -0x30(%ebp)
 31f:	ff 75 d4             	pushl  -0x2c(%ebp)
 322:	8b 45 d8             	mov    -0x28(%ebp),%eax
 325:	ff d0                	call   *%eax
 327:	83 c4 20             	add    $0x20,%esp
      }
      state = 0;
 32a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 331:	e9 51 ff ff ff       	jmp    287 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
 336:	8b 45 d0             	mov    -0x30(%ebp),%eax
 339:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 33c:	6a 01                	push   $0x1
 33e:	6a 0a                	push   $0xa
 340:	8b 45 10             	mov    0x10(%ebp),%eax
 343:	ff 30                	pushl  (%eax)
 345:	89 f0                	mov    %esi,%eax
 347:	29 d8                	sub    %ebx,%eax
 349:	50                   	push   %eax
 34a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 34d:	8b 45 d8             	mov    -0x28(%ebp),%eax
 350:	e8 7f fe ff ff       	call   1d4 <s_printint>
 355:	01 c3                	add    %eax,%ebx
        ap++;
 357:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 35b:	83 c4 10             	add    $0x10,%esp
      state = 0;
 35e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 365:	e9 1d ff ff ff       	jmp    287 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
 36a:	8b 45 d0             	mov    -0x30(%ebp),%eax
 36d:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 370:	6a 00                	push   $0x0
 372:	6a 10                	push   $0x10
 374:	8b 45 10             	mov    0x10(%ebp),%eax
 377:	ff 30                	pushl  (%eax)
 379:	89 f0                	mov    %esi,%eax
 37b:	29 d8                	sub    %ebx,%eax
 37d:	50                   	push   %eax
 37e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 381:	8b 45 d8             	mov    -0x28(%ebp),%eax
 384:	e8 4b fe ff ff       	call   1d4 <s_printint>
 389:	01 c3                	add    %eax,%ebx
        ap++;
 38b:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 38f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 392:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 399:	e9 e9 fe ff ff       	jmp    287 <s_printf+0x49>
        s = (char*)*ap;
 39e:	8b 45 10             	mov    0x10(%ebp),%eax
 3a1:	8b 00                	mov    (%eax),%eax
        ap++;
 3a3:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
 3a7:	85 c0                	test   %eax,%eax
 3a9:	75 4e                	jne    3f9 <s_printf+0x1bb>
          s = "(null)";
 3ab:	b8 2b 05 00 00       	mov    $0x52b,%eax
 3b0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3b3:	89 da                	mov    %ebx,%edx
 3b5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 3b8:	89 75 e0             	mov    %esi,-0x20(%ebp)
 3bb:	89 c6                	mov    %eax,%esi
 3bd:	eb 1f                	jmp    3de <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
 3bf:	8d 7a 01             	lea    0x1(%edx),%edi
 3c2:	83 ec 0c             	sub    $0xc,%esp
 3c5:	0f be c0             	movsbl %al,%eax
 3c8:	50                   	push   %eax
 3c9:	52                   	push   %edx
 3ca:	53                   	push   %ebx
 3cb:	ff 75 d0             	pushl  -0x30(%ebp)
 3ce:	ff 75 d4             	pushl  -0x2c(%ebp)
 3d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
 3d4:	ff d0                	call   *%eax
          s++;
 3d6:	83 c6 01             	add    $0x1,%esi
 3d9:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
 3dc:	89 fa                	mov    %edi,%edx
        while(*s != 0){
 3de:	0f b6 06             	movzbl (%esi),%eax
 3e1:	84 c0                	test   %al,%al
 3e3:	75 da                	jne    3bf <s_printf+0x181>
 3e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e8:	89 d3                	mov    %edx,%ebx
 3ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
 3ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 3f4:	e9 8e fe ff ff       	jmp    287 <s_printf+0x49>
 3f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3fc:	89 da                	mov    %ebx,%edx
 3fe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 401:	89 75 e0             	mov    %esi,-0x20(%ebp)
 404:	89 c6                	mov    %eax,%esi
 406:	eb d6                	jmp    3de <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 408:	8d 43 01             	lea    0x1(%ebx),%eax
 40b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 40e:	83 ec 0c             	sub    $0xc,%esp
 411:	8b 55 10             	mov    0x10(%ebp),%edx
 414:	0f be 02             	movsbl (%edx),%eax
 417:	50                   	push   %eax
 418:	53                   	push   %ebx
 419:	56                   	push   %esi
 41a:	ff 75 d0             	pushl  -0x30(%ebp)
 41d:	ff 75 d4             	pushl  -0x2c(%ebp)
 420:	8b 55 d8             	mov    -0x28(%ebp),%edx
 423:	ff d2                	call   *%edx
        ap++;
 425:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 429:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 42c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 42f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 436:	e9 4c fe ff ff       	jmp    287 <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
 43b:	8d 43 01             	lea    0x1(%ebx),%eax
 43e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 441:	83 ec 0c             	sub    $0xc,%esp
 444:	ff 75 dc             	pushl  -0x24(%ebp)
 447:	53                   	push   %ebx
 448:	56                   	push   %esi
 449:	ff 75 d0             	pushl  -0x30(%ebp)
 44c:	ff 75 d4             	pushl  -0x2c(%ebp)
 44f:	8b 55 d8             	mov    -0x28(%ebp),%edx
 452:	ff d2                	call   *%edx
 454:	83 c4 20             	add    $0x20,%esp
 457:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 45a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 461:	e9 21 fe ff ff       	jmp    287 <s_printf+0x49>
    }
  }
  
  return s_min(length, outindex);
 466:	89 da                	mov    %ebx,%edx
 468:	89 f0                	mov    %esi,%eax
 46a:	e8 5f fd ff ff       	call   1ce <s_min>
}
 46f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 472:	5b                   	pop    %ebx
 473:	5e                   	pop    %esi
 474:	5f                   	pop    %edi
 475:	5d                   	pop    %ebp
 476:	c3                   	ret    

00000477 <s_putc>:
{
 477:	f3 0f 1e fb          	endbr32 
 47b:	55                   	push   %ebp
 47c:	89 e5                	mov    %esp,%ebp
 47e:	83 ec 1c             	sub    $0x1c,%esp
 481:	8b 45 18             	mov    0x18(%ebp),%eax
 484:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 487:	6a 01                	push   $0x1
 489:	8d 45 f4             	lea    -0xc(%ebp),%eax
 48c:	50                   	push   %eax
 48d:	ff 75 08             	pushl  0x8(%ebp)
 490:	e8 f3 fb ff ff       	call   88 <write>
}
 495:	83 c4 10             	add    $0x10,%esp
 498:	c9                   	leave  
 499:	c3                   	ret    

0000049a <snprintf>:
// Print into outbuffer at most n characters. Only understands %d, %x, %p, %s.
// If n is greater than 0, a terminating nul is always stored in outbuffer.
// \return the number of characters written to outbuffer not counting the
// terminating nul.
int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
 49a:	f3 0f 1e fb          	endbr32 
 49e:	55                   	push   %ebp
 49f:	89 e5                	mov    %esp,%ebp
 4a1:	56                   	push   %esi
 4a2:	53                   	push   %ebx
 4a3:	8b 75 08             	mov    0x8(%ebp),%esi
 4a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
 4a9:	83 ec 04             	sub    $0x4,%esp
 4ac:	8d 45 14             	lea    0x14(%ebp),%eax
 4af:	50                   	push   %eax
 4b0:	ff 75 10             	pushl  0x10(%ebp)
 4b3:	53                   	push   %ebx
 4b4:	89 f1                	mov    %esi,%ecx
 4b6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 4bb:	b8 28 01 00 00       	mov    $0x128,%eax
 4c0:	e8 79 fd ff ff       	call   23e <s_printf>
  if(count < n) {
 4c5:	83 c4 10             	add    $0x10,%esp
 4c8:	39 c3                	cmp    %eax,%ebx
 4ca:	76 04                	jbe    4d0 <snprintf+0x36>
    outbuffer[count] = 0; // Assure nul termination
 4cc:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
  } 

  return count;
}
 4d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
 4d3:	5b                   	pop    %ebx
 4d4:	5e                   	pop    %esi
 4d5:	5d                   	pop    %ebp
 4d6:	c3                   	ret    

000004d7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 4d7:	f3 0f 1e fb          	endbr32 
 4db:	55                   	push   %ebp
 4dc:	89 e5                	mov    %esp,%ebp
 4de:	83 ec 0c             	sub    $0xc,%esp
  static const uint veryLarge = 1<<30;
  uint* ap = (uint*)(void*)&fmt + 1;
  s_printf(s_putc, fd, 0, veryLarge, fmt, ap);
 4e1:	8d 45 10             	lea    0x10(%ebp),%eax
 4e4:	50                   	push   %eax
 4e5:	ff 75 0c             	pushl  0xc(%ebp)
 4e8:	68 00 00 00 40       	push   $0x40000000
 4ed:	b9 00 00 00 00       	mov    $0x0,%ecx
 4f2:	8b 55 08             	mov    0x8(%ebp),%edx
 4f5:	b8 77 04 00 00       	mov    $0x477,%eax
 4fa:	e8 3f fd ff ff       	call   23e <s_printf>
 4ff:	83 c4 10             	add    $0x10,%esp
 502:	c9                   	leave  
 503:	c3                   	ret    
