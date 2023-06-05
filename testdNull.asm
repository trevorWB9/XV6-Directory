
_testdNull:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	57                   	push   %edi
  12:	53                   	push   %ebx
  13:	51                   	push   %ecx
  14:	81 ec 14 02 00 00    	sub    $0x214,%esp
    int devNulFd = open("dev/null", O_WRONLY);
  1a:	6a 01                	push   $0x1
  1c:	68 38 05 00 00       	push   $0x538
  21:	e8 b6 00 00 00       	call   dc <open>
    if(0 > devNulFd) {
  26:	83 c4 10             	add    $0x10,%esp
  29:	85 c0                	test   %eax,%eax
  2b:	78 53                	js     80 <main+0x80>
  2d:	89 c3                	mov    %eax,%ebx
        printf(2, "Error: Unable to open dNull\n");
    }
    else {
        char buffer[512] = {'\0'};
  2f:	c7 85 e8 fd ff ff 00 	movl   $0x0,-0x218(%ebp)
  36:	00 00 00 
  39:	8d bd ec fd ff ff    	lea    -0x214(%ebp),%edi
  3f:	b9 7f 00 00 00       	mov    $0x7f,%ecx
  44:	b8 00 00 00 00       	mov    $0x0,%eax
  49:	f3 ab                	rep stos %eax,%es:(%edi)
        write(devNulFd, buffer, 512);
  4b:	83 ec 04             	sub    $0x4,%esp
  4e:	68 00 02 00 00       	push   $0x200
  53:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  59:	57                   	push   %edi
  5a:	53                   	push   %ebx
  5b:	e8 5c 00 00 00       	call   bc <write>
        printf(1, "Write <%s>\n", buffer);
  60:	83 c4 0c             	add    $0xc,%esp
  63:	57                   	push   %edi
  64:	68 5e 05 00 00       	push   $0x55e
  69:	6a 01                	push   $0x1
  6b:	e8 9b 04 00 00       	call   50b <printf>
        close(devNulFd);
  70:	89 1c 24             	mov    %ebx,(%esp)
  73:	e8 4c 00 00 00       	call   c4 <close>
        devNulFd = -1;
  78:	83 c4 10             	add    $0x10,%esp
    }
    exit();
  7b:	e8 1c 00 00 00       	call   9c <exit>
        printf(2, "Error: Unable to open dNull\n");
  80:	83 ec 08             	sub    $0x8,%esp
  83:	68 41 05 00 00       	push   $0x541
  88:	6a 02                	push   $0x2
  8a:	e8 7c 04 00 00       	call   50b <printf>
  8f:	83 c4 10             	add    $0x10,%esp
  92:	eb e7                	jmp    7b <main+0x7b>

00000094 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  94:	b8 01 00 00 00       	mov    $0x1,%eax
  99:	cd 40                	int    $0x40
  9b:	c3                   	ret    

0000009c <exit>:
SYSCALL(exit)
  9c:	b8 02 00 00 00       	mov    $0x2,%eax
  a1:	cd 40                	int    $0x40
  a3:	c3                   	ret    

000000a4 <wait>:
SYSCALL(wait)
  a4:	b8 03 00 00 00       	mov    $0x3,%eax
  a9:	cd 40                	int    $0x40
  ab:	c3                   	ret    

000000ac <pipe>:
SYSCALL(pipe)
  ac:	b8 04 00 00 00       	mov    $0x4,%eax
  b1:	cd 40                	int    $0x40
  b3:	c3                   	ret    

000000b4 <read>:
SYSCALL(read)
  b4:	b8 05 00 00 00       	mov    $0x5,%eax
  b9:	cd 40                	int    $0x40
  bb:	c3                   	ret    

000000bc <write>:
SYSCALL(write)
  bc:	b8 10 00 00 00       	mov    $0x10,%eax
  c1:	cd 40                	int    $0x40
  c3:	c3                   	ret    

000000c4 <close>:
SYSCALL(close)
  c4:	b8 15 00 00 00       	mov    $0x15,%eax
  c9:	cd 40                	int    $0x40
  cb:	c3                   	ret    

000000cc <kill>:
SYSCALL(kill)
  cc:	b8 06 00 00 00       	mov    $0x6,%eax
  d1:	cd 40                	int    $0x40
  d3:	c3                   	ret    

000000d4 <exec>:
SYSCALL(exec)
  d4:	b8 07 00 00 00       	mov    $0x7,%eax
  d9:	cd 40                	int    $0x40
  db:	c3                   	ret    

000000dc <open>:
SYSCALL(open)
  dc:	b8 0f 00 00 00       	mov    $0xf,%eax
  e1:	cd 40                	int    $0x40
  e3:	c3                   	ret    

000000e4 <mknod>:
SYSCALL(mknod)
  e4:	b8 11 00 00 00       	mov    $0x11,%eax
  e9:	cd 40                	int    $0x40
  eb:	c3                   	ret    

000000ec <unlink>:
SYSCALL(unlink)
  ec:	b8 12 00 00 00       	mov    $0x12,%eax
  f1:	cd 40                	int    $0x40
  f3:	c3                   	ret    

000000f4 <fstat>:
SYSCALL(fstat)
  f4:	b8 08 00 00 00       	mov    $0x8,%eax
  f9:	cd 40                	int    $0x40
  fb:	c3                   	ret    

000000fc <link>:
SYSCALL(link)
  fc:	b8 13 00 00 00       	mov    $0x13,%eax
 101:	cd 40                	int    $0x40
 103:	c3                   	ret    

00000104 <mkdir>:
SYSCALL(mkdir)
 104:	b8 14 00 00 00       	mov    $0x14,%eax
 109:	cd 40                	int    $0x40
 10b:	c3                   	ret    

0000010c <chdir>:
SYSCALL(chdir)
 10c:	b8 09 00 00 00       	mov    $0x9,%eax
 111:	cd 40                	int    $0x40
 113:	c3                   	ret    

00000114 <dup>:
SYSCALL(dup)
 114:	b8 0a 00 00 00       	mov    $0xa,%eax
 119:	cd 40                	int    $0x40
 11b:	c3                   	ret    

0000011c <getpid>:
SYSCALL(getpid)
 11c:	b8 0b 00 00 00       	mov    $0xb,%eax
 121:	cd 40                	int    $0x40
 123:	c3                   	ret    

00000124 <sbrk>:
SYSCALL(sbrk)
 124:	b8 0c 00 00 00       	mov    $0xc,%eax
 129:	cd 40                	int    $0x40
 12b:	c3                   	ret    

0000012c <sleep>:
SYSCALL(sleep)
 12c:	b8 0d 00 00 00       	mov    $0xd,%eax
 131:	cd 40                	int    $0x40
 133:	c3                   	ret    

00000134 <uptime>:
SYSCALL(uptime)
 134:	b8 0e 00 00 00       	mov    $0xe,%eax
 139:	cd 40                	int    $0x40
 13b:	c3                   	ret    

0000013c <yield>:
SYSCALL(yield)
 13c:	b8 16 00 00 00       	mov    $0x16,%eax
 141:	cd 40                	int    $0x40
 143:	c3                   	ret    

00000144 <shutdown>:
SYSCALL(shutdown)
 144:	b8 17 00 00 00       	mov    $0x17,%eax
 149:	cd 40                	int    $0x40
 14b:	c3                   	ret    

0000014c <nice>:
SYSCALL(nice)
 14c:	b8 18 00 00 00       	mov    $0x18,%eax
 151:	cd 40                	int    $0x40
 153:	c3                   	ret    

00000154 <cps>:
SYSCALL(cps)
 154:	b8 19 00 00 00       	mov    $0x19,%eax
 159:	cd 40                	int    $0x40
 15b:	c3                   	ret    

0000015c <s_sputc>:
  write(fd, &c, 1);
}

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
 15c:	f3 0f 1e fb          	endbr32 
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	8b 45 14             	mov    0x14(%ebp),%eax
 166:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
 169:	3b 45 10             	cmp    0x10(%ebp),%eax
 16c:	73 06                	jae    174 <s_sputc+0x18>
  {
    outbuffer[index] = c;
 16e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 171:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
 174:	5d                   	pop    %ebp
 175:	c3                   	ret    

00000176 <s_getReverseDigits>:
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
 176:	55                   	push   %ebp
 177:	89 e5                	mov    %esp,%ebp
 179:	57                   	push   %edi
 17a:	56                   	push   %esi
 17b:	53                   	push   %ebx
 17c:	83 ec 08             	sub    $0x8,%esp
 17f:	89 c6                	mov    %eax,%esi
 181:	89 d3                	mov    %edx,%ebx
 183:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 186:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 18a:	0f 95 c2             	setne  %dl
 18d:	89 c8                	mov    %ecx,%eax
 18f:	c1 e8 1f             	shr    $0x1f,%eax
 192:	84 c2                	test   %al,%dl
 194:	74 33                	je     1c9 <s_getReverseDigits+0x53>
    neg = 1;
    x = -xx;
 196:	89 c8                	mov    %ecx,%eax
 198:	f7 d8                	neg    %eax
    neg = 1;
 19a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1a1:	bf 00 00 00 00       	mov    $0x0,%edi
  while(i + 1 < length && x != 0) {
 1a6:	8d 4f 01             	lea    0x1(%edi),%ecx
 1a9:	89 ca                	mov    %ecx,%edx
 1ab:	39 d9                	cmp    %ebx,%ecx
 1ad:	73 26                	jae    1d5 <s_getReverseDigits+0x5f>
 1af:	85 c0                	test   %eax,%eax
 1b1:	74 22                	je     1d5 <s_getReverseDigits+0x5f>
    outbuf[i++] = digits[x % base];
 1b3:	ba 00 00 00 00       	mov    $0x0,%edx
 1b8:	f7 75 08             	divl   0x8(%ebp)
 1bb:	0f b6 92 74 05 00 00 	movzbl 0x574(%edx),%edx
 1c2:	88 14 3e             	mov    %dl,(%esi,%edi,1)
 1c5:	89 cf                	mov    %ecx,%edi
 1c7:	eb dd                	jmp    1a6 <s_getReverseDigits+0x30>
    x = xx;
 1c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  neg = 0;
 1cc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 1d3:	eb cc                	jmp    1a1 <s_getReverseDigits+0x2b>
    x /= base;
  }

  if(0 == xx && i + 1 < length) {
 1d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1d9:	75 0a                	jne    1e5 <s_getReverseDigits+0x6f>
 1db:	39 da                	cmp    %ebx,%edx
 1dd:	73 06                	jae    1e5 <s_getReverseDigits+0x6f>
    outbuf[i++] = digits[0];   
 1df:	c6 04 3e 30          	movb   $0x30,(%esi,%edi,1)
 1e3:	89 cf                	mov    %ecx,%edi
  }

  if(neg && i < length) {
 1e5:	89 fa                	mov    %edi,%edx
 1e7:	39 df                	cmp    %ebx,%edi
 1e9:	0f 92 c0             	setb   %al
 1ec:	84 45 ec             	test   %al,-0x14(%ebp)
 1ef:	74 07                	je     1f8 <s_getReverseDigits+0x82>
    outbuf[i++] = '-';
 1f1:	83 c7 01             	add    $0x1,%edi
 1f4:	c6 04 16 2d          	movb   $0x2d,(%esi,%edx,1)
  }

  return i;
}
 1f8:	89 f8                	mov    %edi,%eax
 1fa:	83 c4 08             	add    $0x8,%esp
 1fd:	5b                   	pop    %ebx
 1fe:	5e                   	pop    %esi
 1ff:	5f                   	pop    %edi
 200:	5d                   	pop    %ebp
 201:	c3                   	ret    

00000202 <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
 202:	39 c2                	cmp    %eax,%edx
 204:	0f 46 c2             	cmovbe %edx,%eax
}
 207:	c3                   	ret    

00000208 <s_printint>:
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
 20b:	57                   	push   %edi
 20c:	56                   	push   %esi
 20d:	53                   	push   %ebx
 20e:	83 ec 2c             	sub    $0x2c,%esp
 211:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 214:	89 55 d0             	mov    %edx,-0x30(%ebp)
 217:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 21a:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);
 21d:	ff 75 14             	pushl  0x14(%ebp)
 220:	ff 75 10             	pushl  0x10(%ebp)
 223:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 226:	ba 10 00 00 00       	mov    $0x10,%edx
 22b:	8d 45 d8             	lea    -0x28(%ebp),%eax
 22e:	e8 43 ff ff ff       	call   176 <s_getReverseDigits>
 233:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
 236:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
 238:	83 c4 08             	add    $0x8,%esp
  int j = 0;
 23b:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
 240:	83 eb 01             	sub    $0x1,%ebx
 243:	78 22                	js     267 <s_printint+0x5f>
 245:	39 fe                	cmp    %edi,%esi
 247:	73 1e                	jae    267 <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
 249:	83 ec 0c             	sub    $0xc,%esp
 24c:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
 251:	50                   	push   %eax
 252:	56                   	push   %esi
 253:	57                   	push   %edi
 254:	ff 75 cc             	pushl  -0x34(%ebp)
 257:	ff 75 d0             	pushl  -0x30(%ebp)
 25a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 25d:	ff d0                	call   *%eax
    j++;
 25f:	83 c6 01             	add    $0x1,%esi
 262:	83 c4 20             	add    $0x20,%esp
 265:	eb d9                	jmp    240 <s_printint+0x38>
}
 267:	8b 45 c8             	mov    -0x38(%ebp),%eax
 26a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 26d:	5b                   	pop    %ebx
 26e:	5e                   	pop    %esi
 26f:	5f                   	pop    %edi
 270:	5d                   	pop    %ebp
 271:	c3                   	ret    

00000272 <s_printf>:

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
 272:	55                   	push   %ebp
 273:	89 e5                	mov    %esp,%ebp
 275:	57                   	push   %edi
 276:	56                   	push   %esi
 277:	53                   	push   %ebx
 278:	83 ec 2c             	sub    $0x2c,%esp
 27b:	89 45 d8             	mov    %eax,-0x28(%ebp)
 27e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 281:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1; // leave room for nul termination
 284:	8b 45 08             	mov    0x8(%ebp),%eax
 287:	8d 78 ff             	lea    -0x1(%eax),%edi

  state = 0;
 28a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
 291:	bb 00 00 00 00       	mov    $0x0,%ebx
 296:	89 f8                	mov    %edi,%eax
 298:	89 df                	mov    %ebx,%edi
 29a:	89 c6                	mov    %eax,%esi
 29c:	eb 20                	jmp    2be <s_printf+0x4c>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
 29e:	8d 43 01             	lea    0x1(%ebx),%eax
 2a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
 2a4:	83 ec 0c             	sub    $0xc,%esp
 2a7:	51                   	push   %ecx
 2a8:	53                   	push   %ebx
 2a9:	56                   	push   %esi
 2aa:	ff 75 d0             	pushl  -0x30(%ebp)
 2ad:	ff 75 d4             	pushl  -0x2c(%ebp)
 2b0:	8b 55 d8             	mov    -0x28(%ebp),%edx
 2b3:	ff d2                	call   *%edx
 2b5:	83 c4 20             	add    $0x20,%esp
 2b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
 2bb:	83 c7 01             	add    $0x1,%edi
 2be:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c1:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
 2c5:	84 c0                	test   %al,%al
 2c7:	0f 84 cd 01 00 00    	je     49a <s_printf+0x228>
 2cd:	89 75 e0             	mov    %esi,-0x20(%ebp)
 2d0:	39 de                	cmp    %ebx,%esi
 2d2:	0f 86 c2 01 00 00    	jbe    49a <s_printf+0x228>
    c = fmt[i] & 0xff;
 2d8:	0f be c8             	movsbl %al,%ecx
 2db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 2de:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 2e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 2e5:	75 0a                	jne    2f1 <s_printf+0x7f>
      if(c == '%') {
 2e7:	83 f8 25             	cmp    $0x25,%eax
 2ea:	75 b2                	jne    29e <s_printf+0x2c>
        state = '%';
 2ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 2ef:	eb ca                	jmp    2bb <s_printf+0x49>
      }
    } else if(state == '%'){
 2f1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 2f5:	75 c4                	jne    2bb <s_printf+0x49>
      if(c == 'd'){
 2f7:	83 f8 64             	cmp    $0x64,%eax
 2fa:	74 6e                	je     36a <s_printf+0xf8>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 2fc:	83 f8 78             	cmp    $0x78,%eax
 2ff:	0f 94 c1             	sete   %cl
 302:	83 f8 70             	cmp    $0x70,%eax
 305:	0f 94 c2             	sete   %dl
 308:	08 d1                	or     %dl,%cl
 30a:	0f 85 8e 00 00 00    	jne    39e <s_printf+0x12c>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 310:	83 f8 73             	cmp    $0x73,%eax
 313:	0f 84 b9 00 00 00    	je     3d2 <s_printf+0x160>
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
 319:	83 f8 63             	cmp    $0x63,%eax
 31c:	0f 84 1a 01 00 00    	je     43c <s_printf+0x1ca>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
 322:	83 f8 25             	cmp    $0x25,%eax
 325:	0f 84 44 01 00 00    	je     46f <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
 32b:	8d 43 01             	lea    0x1(%ebx),%eax
 32e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 331:	83 ec 0c             	sub    $0xc,%esp
 334:	6a 25                	push   $0x25
 336:	53                   	push   %ebx
 337:	56                   	push   %esi
 338:	ff 75 d0             	pushl  -0x30(%ebp)
 33b:	ff 75 d4             	pushl  -0x2c(%ebp)
 33e:	8b 45 d8             	mov    -0x28(%ebp),%eax
 341:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
 343:	83 c3 02             	add    $0x2,%ebx
 346:	83 c4 14             	add    $0x14,%esp
 349:	ff 75 dc             	pushl  -0x24(%ebp)
 34c:	ff 75 e4             	pushl  -0x1c(%ebp)
 34f:	56                   	push   %esi
 350:	ff 75 d0             	pushl  -0x30(%ebp)
 353:	ff 75 d4             	pushl  -0x2c(%ebp)
 356:	8b 45 d8             	mov    -0x28(%ebp),%eax
 359:	ff d0                	call   *%eax
 35b:	83 c4 20             	add    $0x20,%esp
      }
      state = 0;
 35e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 365:	e9 51 ff ff ff       	jmp    2bb <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
 36a:	8b 45 d0             	mov    -0x30(%ebp),%eax
 36d:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 370:	6a 01                	push   $0x1
 372:	6a 0a                	push   $0xa
 374:	8b 45 10             	mov    0x10(%ebp),%eax
 377:	ff 30                	pushl  (%eax)
 379:	89 f0                	mov    %esi,%eax
 37b:	29 d8                	sub    %ebx,%eax
 37d:	50                   	push   %eax
 37e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 381:	8b 45 d8             	mov    -0x28(%ebp),%eax
 384:	e8 7f fe ff ff       	call   208 <s_printint>
 389:	01 c3                	add    %eax,%ebx
        ap++;
 38b:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 38f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 392:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 399:	e9 1d ff ff ff       	jmp    2bb <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
 39e:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3a1:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 3a4:	6a 00                	push   $0x0
 3a6:	6a 10                	push   $0x10
 3a8:	8b 45 10             	mov    0x10(%ebp),%eax
 3ab:	ff 30                	pushl  (%eax)
 3ad:	89 f0                	mov    %esi,%eax
 3af:	29 d8                	sub    %ebx,%eax
 3b1:	50                   	push   %eax
 3b2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 3b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
 3b8:	e8 4b fe ff ff       	call   208 <s_printint>
 3bd:	01 c3                	add    %eax,%ebx
        ap++;
 3bf:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 3c3:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 3cd:	e9 e9 fe ff ff       	jmp    2bb <s_printf+0x49>
        s = (char*)*ap;
 3d2:	8b 45 10             	mov    0x10(%ebp),%eax
 3d5:	8b 00                	mov    (%eax),%eax
        ap++;
 3d7:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
 3db:	85 c0                	test   %eax,%eax
 3dd:	75 4e                	jne    42d <s_printf+0x1bb>
          s = "(null)";
 3df:	b8 6a 05 00 00       	mov    $0x56a,%eax
 3e4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3e7:	89 da                	mov    %ebx,%edx
 3e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 3ec:	89 75 e0             	mov    %esi,-0x20(%ebp)
 3ef:	89 c6                	mov    %eax,%esi
 3f1:	eb 1f                	jmp    412 <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
 3f3:	8d 7a 01             	lea    0x1(%edx),%edi
 3f6:	83 ec 0c             	sub    $0xc,%esp
 3f9:	0f be c0             	movsbl %al,%eax
 3fc:	50                   	push   %eax
 3fd:	52                   	push   %edx
 3fe:	53                   	push   %ebx
 3ff:	ff 75 d0             	pushl  -0x30(%ebp)
 402:	ff 75 d4             	pushl  -0x2c(%ebp)
 405:	8b 45 d8             	mov    -0x28(%ebp),%eax
 408:	ff d0                	call   *%eax
          s++;
 40a:	83 c6 01             	add    $0x1,%esi
 40d:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
 410:	89 fa                	mov    %edi,%edx
        while(*s != 0){
 412:	0f b6 06             	movzbl (%esi),%eax
 415:	84 c0                	test   %al,%al
 417:	75 da                	jne    3f3 <s_printf+0x181>
 419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 41c:	89 d3                	mov    %edx,%ebx
 41e:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
 421:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 428:	e9 8e fe ff ff       	jmp    2bb <s_printf+0x49>
 42d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 430:	89 da                	mov    %ebx,%edx
 432:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 435:	89 75 e0             	mov    %esi,-0x20(%ebp)
 438:	89 c6                	mov    %eax,%esi
 43a:	eb d6                	jmp    412 <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 43c:	8d 43 01             	lea    0x1(%ebx),%eax
 43f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 442:	83 ec 0c             	sub    $0xc,%esp
 445:	8b 55 10             	mov    0x10(%ebp),%edx
 448:	0f be 02             	movsbl (%edx),%eax
 44b:	50                   	push   %eax
 44c:	53                   	push   %ebx
 44d:	56                   	push   %esi
 44e:	ff 75 d0             	pushl  -0x30(%ebp)
 451:	ff 75 d4             	pushl  -0x2c(%ebp)
 454:	8b 55 d8             	mov    -0x28(%ebp),%edx
 457:	ff d2                	call   *%edx
        ap++;
 459:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 45d:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 460:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 463:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 46a:	e9 4c fe ff ff       	jmp    2bb <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
 46f:	8d 43 01             	lea    0x1(%ebx),%eax
 472:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 475:	83 ec 0c             	sub    $0xc,%esp
 478:	ff 75 dc             	pushl  -0x24(%ebp)
 47b:	53                   	push   %ebx
 47c:	56                   	push   %esi
 47d:	ff 75 d0             	pushl  -0x30(%ebp)
 480:	ff 75 d4             	pushl  -0x2c(%ebp)
 483:	8b 55 d8             	mov    -0x28(%ebp),%edx
 486:	ff d2                	call   *%edx
 488:	83 c4 20             	add    $0x20,%esp
 48b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 48e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 495:	e9 21 fe ff ff       	jmp    2bb <s_printf+0x49>
    }
  }
  
  return s_min(length, outindex);
 49a:	89 da                	mov    %ebx,%edx
 49c:	89 f0                	mov    %esi,%eax
 49e:	e8 5f fd ff ff       	call   202 <s_min>
}
 4a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4a6:	5b                   	pop    %ebx
 4a7:	5e                   	pop    %esi
 4a8:	5f                   	pop    %edi
 4a9:	5d                   	pop    %ebp
 4aa:	c3                   	ret    

000004ab <s_putc>:
{
 4ab:	f3 0f 1e fb          	endbr32 
 4af:	55                   	push   %ebp
 4b0:	89 e5                	mov    %esp,%ebp
 4b2:	83 ec 1c             	sub    $0x1c,%esp
 4b5:	8b 45 18             	mov    0x18(%ebp),%eax
 4b8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4bb:	6a 01                	push   $0x1
 4bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4c0:	50                   	push   %eax
 4c1:	ff 75 08             	pushl  0x8(%ebp)
 4c4:	e8 f3 fb ff ff       	call   bc <write>
}
 4c9:	83 c4 10             	add    $0x10,%esp
 4cc:	c9                   	leave  
 4cd:	c3                   	ret    

000004ce <snprintf>:
// Print into outbuffer at most n characters. Only understands %d, %x, %p, %s.
// If n is greater than 0, a terminating nul is always stored in outbuffer.
// \return the number of characters written to outbuffer not counting the
// terminating nul.
int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
 4ce:	f3 0f 1e fb          	endbr32 
 4d2:	55                   	push   %ebp
 4d3:	89 e5                	mov    %esp,%ebp
 4d5:	56                   	push   %esi
 4d6:	53                   	push   %ebx
 4d7:	8b 75 08             	mov    0x8(%ebp),%esi
 4da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
 4dd:	83 ec 04             	sub    $0x4,%esp
 4e0:	8d 45 14             	lea    0x14(%ebp),%eax
 4e3:	50                   	push   %eax
 4e4:	ff 75 10             	pushl  0x10(%ebp)
 4e7:	53                   	push   %ebx
 4e8:	89 f1                	mov    %esi,%ecx
 4ea:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 4ef:	b8 5c 01 00 00       	mov    $0x15c,%eax
 4f4:	e8 79 fd ff ff       	call   272 <s_printf>
  if(count < n) {
 4f9:	83 c4 10             	add    $0x10,%esp
 4fc:	39 c3                	cmp    %eax,%ebx
 4fe:	76 04                	jbe    504 <snprintf+0x36>
    outbuffer[count] = 0; // Assure nul termination
 500:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
  } 

  return count;
}
 504:	8d 65 f8             	lea    -0x8(%ebp),%esp
 507:	5b                   	pop    %ebx
 508:	5e                   	pop    %esi
 509:	5d                   	pop    %ebp
 50a:	c3                   	ret    

0000050b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 50b:	f3 0f 1e fb          	endbr32 
 50f:	55                   	push   %ebp
 510:	89 e5                	mov    %esp,%ebp
 512:	83 ec 0c             	sub    $0xc,%esp
  static const uint veryLarge = 1<<30;
  uint* ap = (uint*)(void*)&fmt + 1;
  s_printf(s_putc, fd, 0, veryLarge, fmt, ap);
 515:	8d 45 10             	lea    0x10(%ebp),%eax
 518:	50                   	push   %eax
 519:	ff 75 0c             	pushl  0xc(%ebp)
 51c:	68 00 00 00 40       	push   $0x40000000
 521:	b9 00 00 00 00       	mov    $0x0,%ecx
 526:	8b 55 08             	mov    0x8(%ebp),%edx
 529:	b8 ab 04 00 00       	mov    $0x4ab,%eax
 52e:	e8 3f fd ff ff       	call   272 <s_printf>
 533:	83 c4 10             	add    $0x10,%esp
 536:	c9                   	leave  
 537:	c3                   	ret    
