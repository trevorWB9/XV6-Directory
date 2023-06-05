
_countUD:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int main(int argc, const char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	57                   	push   %edi
  12:	56                   	push   %esi
  13:	53                   	push   %ebx
  14:	51                   	push   %ecx
  15:	83 ec 38             	sub    $0x38,%esp
  18:	8b 01                	mov    (%ecx),%eax
  1a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1d:	8b 71 04             	mov    0x4(%ecx),%esi
  20:	89 75 c4             	mov    %esi,-0x3c(%ebp)
    int udCount = 0;
    int otherCount = 0;
    if (1 >= argc)
  23:	83 f8 01             	cmp    $0x1,%eax
  26:	7e 15                	jle    3d <main+0x3d>
    {
        printf(1, "Usage: %s <path>\n", argv[0]);
    }
    else
    {
        for (int i = 1; i < argc; i++)
  28:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
    int otherCount = 0;
  2f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
    int udCount = 0;
  36:	be 00 00 00 00       	mov    $0x0,%esi
  3b:	eb 41                	jmp    7e <main+0x7e>
        printf(1, "Usage: %s <path>\n", argv[0]);
  3d:	83 ec 04             	sub    $0x4,%esp
  40:	ff 36                	pushl  (%esi)
  42:	68 fc 05 00 00       	push   $0x5fc
  47:	6a 01                	push   $0x1
  49:	e8 80 05 00 00       	call   5ce <printf>
  4e:	83 c4 10             	add    $0x10,%esp
    {
        return 0;
    }
    else
    {
        return 1;
  51:	b8 01 00 00 00       	mov    $0x1,%eax
  56:	e9 f0 00 00 00       	jmp    14b <main+0x14b>
                printf(1, "Opening to file: %d\n", path);
  5b:	83 ec 04             	sub    $0x4,%esp
  5e:	57                   	push   %edi
  5f:	68 0e 06 00 00       	push   $0x60e
  64:	6a 01                	push   $0x1
  66:	e8 63 05 00 00       	call   5ce <printf>
  6b:	83 c4 10             	add    $0x10,%esp
            close(fd);
  6e:	83 ec 0c             	sub    $0xc,%esp
  71:	53                   	push   %ebx
  72:	e8 10 01 00 00       	call   187 <close>
        for (int i = 1; i < argc; i++)
  77:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
  7b:	83 c4 10             	add    $0x10,%esp
  7e:	8b 5d c8             	mov    -0x38(%ebp),%ebx
  81:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
  84:	0f 8d 8f 00 00 00    	jge    119 <main+0x119>
            const char *path = argv[i];
  8a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8d:	8b 7d d0             	mov    -0x30(%ebp),%edi
  90:	8b 3c b8             	mov    (%eax,%edi,4),%edi
  93:	89 7d c0             	mov    %edi,-0x40(%ebp)
            int fd = open(path, O_RDONLY);
  96:	83 ec 08             	sub    $0x8,%esp
  99:	6a 00                	push   $0x0
  9b:	57                   	push   %edi
  9c:	e8 fe 00 00 00       	call   19f <open>
  a1:	89 c3                	mov    %eax,%ebx
            if (0 > fd)
  a3:	83 c4 10             	add    $0x10,%esp
  a6:	85 c0                	test   %eax,%eax
  a8:	78 b1                	js     5b <main+0x5b>
                char buffer[1] = {0};
  aa:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  b1:	eb 07                	jmp    ba <main+0xba>
                        udCount++;
  b3:	83 c6 01             	add    $0x1,%esi
                } while (0 < status);
  b6:	85 c0                	test   %eax,%eax
  b8:	7e 3c                	jle    f6 <main+0xf6>
                    status = read(fd, buffer, 1);
  ba:	83 ec 04             	sub    $0x4,%esp
  bd:	6a 01                	push   $0x1
  bf:	8d 45 e7             	lea    -0x19(%ebp),%eax
  c2:	50                   	push   %eax
  c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  c6:	e8 ac 00 00 00       	call   177 <read>
                    if (buffer[0] == 68 || buffer[0] == 85 || buffer[0] == 117 || buffer[0] == 100)
  cb:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  cf:	83 c4 10             	add    $0x10,%esp
  d2:	80 fa 44             	cmp    $0x44,%dl
  d5:	0f 94 c1             	sete   %cl
  d8:	89 cf                	mov    %ecx,%edi
  da:	80 fa 55             	cmp    $0x55,%dl
  dd:	0f 94 c1             	sete   %cl
  e0:	89 fb                	mov    %edi,%ebx
  e2:	08 cb                	or     %cl,%bl
  e4:	75 cd                	jne    b3 <main+0xb3>
  e6:	80 fa 75             	cmp    $0x75,%dl
  e9:	74 c8                	je     b3 <main+0xb3>
  eb:	80 fa 64             	cmp    $0x64,%dl
  ee:	74 c3                	je     b3 <main+0xb3>
                        otherCount++;
  f0:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
  f4:	eb c0                	jmp    b6 <main+0xb6>
  f6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
                if (0 > status)
  f9:	0f 89 6f ff ff ff    	jns    6e <main+0x6e>
                    printf(1, "Writing to file: %d\n", path);
  ff:	83 ec 04             	sub    $0x4,%esp
 102:	ff 75 c0             	pushl  -0x40(%ebp)
 105:	68 23 06 00 00       	push   $0x623
 10a:	6a 01                	push   $0x1
 10c:	e8 bd 04 00 00       	call   5ce <printf>
 111:	83 c4 10             	add    $0x10,%esp
 114:	e9 55 ff ff ff       	jmp    6e <main+0x6e>
        printf(1, "Number of UD's: %d\n", udCount);
 119:	83 ec 04             	sub    $0x4,%esp
 11c:	56                   	push   %esi
 11d:	68 38 06 00 00       	push   $0x638
 122:	6a 01                	push   $0x1
 124:	e8 a5 04 00 00       	call   5ce <printf>
        printf(2, "Number of others: %d\n", otherCount);
 129:	83 c4 0c             	add    $0xc,%esp
 12c:	ff 75 cc             	pushl  -0x34(%ebp)
 12f:	68 4c 06 00 00       	push   $0x64c
 134:	6a 02                	push   $0x2
 136:	e8 93 04 00 00       	call   5ce <printf>
    if (udCount >= 1)
 13b:	83 c4 10             	add    $0x10,%esp
 13e:	85 f6                	test   %esi,%esi
 140:	0f 8e 0b ff ff ff    	jle    51 <main+0x51>
        return 0;
 146:	b8 00 00 00 00       	mov    $0x0,%eax
    }
 14b:	8d 65 f0             	lea    -0x10(%ebp),%esp
 14e:	59                   	pop    %ecx
 14f:	5b                   	pop    %ebx
 150:	5e                   	pop    %esi
 151:	5f                   	pop    %edi
 152:	5d                   	pop    %ebp
 153:	8d 61 fc             	lea    -0x4(%ecx),%esp
 156:	c3                   	ret    

00000157 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 157:	b8 01 00 00 00       	mov    $0x1,%eax
 15c:	cd 40                	int    $0x40
 15e:	c3                   	ret    

0000015f <exit>:
SYSCALL(exit)
 15f:	b8 02 00 00 00       	mov    $0x2,%eax
 164:	cd 40                	int    $0x40
 166:	c3                   	ret    

00000167 <wait>:
SYSCALL(wait)
 167:	b8 03 00 00 00       	mov    $0x3,%eax
 16c:	cd 40                	int    $0x40
 16e:	c3                   	ret    

0000016f <pipe>:
SYSCALL(pipe)
 16f:	b8 04 00 00 00       	mov    $0x4,%eax
 174:	cd 40                	int    $0x40
 176:	c3                   	ret    

00000177 <read>:
SYSCALL(read)
 177:	b8 05 00 00 00       	mov    $0x5,%eax
 17c:	cd 40                	int    $0x40
 17e:	c3                   	ret    

0000017f <write>:
SYSCALL(write)
 17f:	b8 10 00 00 00       	mov    $0x10,%eax
 184:	cd 40                	int    $0x40
 186:	c3                   	ret    

00000187 <close>:
SYSCALL(close)
 187:	b8 15 00 00 00       	mov    $0x15,%eax
 18c:	cd 40                	int    $0x40
 18e:	c3                   	ret    

0000018f <kill>:
SYSCALL(kill)
 18f:	b8 06 00 00 00       	mov    $0x6,%eax
 194:	cd 40                	int    $0x40
 196:	c3                   	ret    

00000197 <exec>:
SYSCALL(exec)
 197:	b8 07 00 00 00       	mov    $0x7,%eax
 19c:	cd 40                	int    $0x40
 19e:	c3                   	ret    

0000019f <open>:
SYSCALL(open)
 19f:	b8 0f 00 00 00       	mov    $0xf,%eax
 1a4:	cd 40                	int    $0x40
 1a6:	c3                   	ret    

000001a7 <mknod>:
SYSCALL(mknod)
 1a7:	b8 11 00 00 00       	mov    $0x11,%eax
 1ac:	cd 40                	int    $0x40
 1ae:	c3                   	ret    

000001af <unlink>:
SYSCALL(unlink)
 1af:	b8 12 00 00 00       	mov    $0x12,%eax
 1b4:	cd 40                	int    $0x40
 1b6:	c3                   	ret    

000001b7 <fstat>:
SYSCALL(fstat)
 1b7:	b8 08 00 00 00       	mov    $0x8,%eax
 1bc:	cd 40                	int    $0x40
 1be:	c3                   	ret    

000001bf <link>:
SYSCALL(link)
 1bf:	b8 13 00 00 00       	mov    $0x13,%eax
 1c4:	cd 40                	int    $0x40
 1c6:	c3                   	ret    

000001c7 <mkdir>:
SYSCALL(mkdir)
 1c7:	b8 14 00 00 00       	mov    $0x14,%eax
 1cc:	cd 40                	int    $0x40
 1ce:	c3                   	ret    

000001cf <chdir>:
SYSCALL(chdir)
 1cf:	b8 09 00 00 00       	mov    $0x9,%eax
 1d4:	cd 40                	int    $0x40
 1d6:	c3                   	ret    

000001d7 <dup>:
SYSCALL(dup)
 1d7:	b8 0a 00 00 00       	mov    $0xa,%eax
 1dc:	cd 40                	int    $0x40
 1de:	c3                   	ret    

000001df <getpid>:
SYSCALL(getpid)
 1df:	b8 0b 00 00 00       	mov    $0xb,%eax
 1e4:	cd 40                	int    $0x40
 1e6:	c3                   	ret    

000001e7 <sbrk>:
SYSCALL(sbrk)
 1e7:	b8 0c 00 00 00       	mov    $0xc,%eax
 1ec:	cd 40                	int    $0x40
 1ee:	c3                   	ret    

000001ef <sleep>:
SYSCALL(sleep)
 1ef:	b8 0d 00 00 00       	mov    $0xd,%eax
 1f4:	cd 40                	int    $0x40
 1f6:	c3                   	ret    

000001f7 <uptime>:
SYSCALL(uptime)
 1f7:	b8 0e 00 00 00       	mov    $0xe,%eax
 1fc:	cd 40                	int    $0x40
 1fe:	c3                   	ret    

000001ff <yield>:
SYSCALL(yield)
 1ff:	b8 16 00 00 00       	mov    $0x16,%eax
 204:	cd 40                	int    $0x40
 206:	c3                   	ret    

00000207 <shutdown>:
SYSCALL(shutdown)
 207:	b8 17 00 00 00       	mov    $0x17,%eax
 20c:	cd 40                	int    $0x40
 20e:	c3                   	ret    

0000020f <nice>:
SYSCALL(nice)
 20f:	b8 18 00 00 00       	mov    $0x18,%eax
 214:	cd 40                	int    $0x40
 216:	c3                   	ret    

00000217 <cps>:
SYSCALL(cps)
 217:	b8 19 00 00 00       	mov    $0x19,%eax
 21c:	cd 40                	int    $0x40
 21e:	c3                   	ret    

0000021f <s_sputc>:
  write(fd, &c, 1);
}

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
 21f:	f3 0f 1e fb          	endbr32 
 223:	55                   	push   %ebp
 224:	89 e5                	mov    %esp,%ebp
 226:	8b 45 14             	mov    0x14(%ebp),%eax
 229:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
 22c:	3b 45 10             	cmp    0x10(%ebp),%eax
 22f:	73 06                	jae    237 <s_sputc+0x18>
  {
    outbuffer[index] = c;
 231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 234:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
 237:	5d                   	pop    %ebp
 238:	c3                   	ret    

00000239 <s_getReverseDigits>:
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
 239:	55                   	push   %ebp
 23a:	89 e5                	mov    %esp,%ebp
 23c:	57                   	push   %edi
 23d:	56                   	push   %esi
 23e:	53                   	push   %ebx
 23f:	83 ec 08             	sub    $0x8,%esp
 242:	89 c6                	mov    %eax,%esi
 244:	89 d3                	mov    %edx,%ebx
 246:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 249:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 24d:	0f 95 c2             	setne  %dl
 250:	89 c8                	mov    %ecx,%eax
 252:	c1 e8 1f             	shr    $0x1f,%eax
 255:	84 c2                	test   %al,%dl
 257:	74 33                	je     28c <s_getReverseDigits+0x53>
    neg = 1;
    x = -xx;
 259:	89 c8                	mov    %ecx,%eax
 25b:	f7 d8                	neg    %eax
    neg = 1;
 25d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 264:	bf 00 00 00 00       	mov    $0x0,%edi
  while(i + 1 < length && x != 0) {
 269:	8d 4f 01             	lea    0x1(%edi),%ecx
 26c:	89 ca                	mov    %ecx,%edx
 26e:	39 d9                	cmp    %ebx,%ecx
 270:	73 26                	jae    298 <s_getReverseDigits+0x5f>
 272:	85 c0                	test   %eax,%eax
 274:	74 22                	je     298 <s_getReverseDigits+0x5f>
    outbuf[i++] = digits[x % base];
 276:	ba 00 00 00 00       	mov    $0x0,%edx
 27b:	f7 75 08             	divl   0x8(%ebp)
 27e:	0f b6 92 6c 06 00 00 	movzbl 0x66c(%edx),%edx
 285:	88 14 3e             	mov    %dl,(%esi,%edi,1)
 288:	89 cf                	mov    %ecx,%edi
 28a:	eb dd                	jmp    269 <s_getReverseDigits+0x30>
    x = xx;
 28c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  neg = 0;
 28f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 296:	eb cc                	jmp    264 <s_getReverseDigits+0x2b>
    x /= base;
  }

  if(0 == xx && i + 1 < length) {
 298:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 29c:	75 0a                	jne    2a8 <s_getReverseDigits+0x6f>
 29e:	39 da                	cmp    %ebx,%edx
 2a0:	73 06                	jae    2a8 <s_getReverseDigits+0x6f>
    outbuf[i++] = digits[0];   
 2a2:	c6 04 3e 30          	movb   $0x30,(%esi,%edi,1)
 2a6:	89 cf                	mov    %ecx,%edi
  }

  if(neg && i < length) {
 2a8:	89 fa                	mov    %edi,%edx
 2aa:	39 df                	cmp    %ebx,%edi
 2ac:	0f 92 c0             	setb   %al
 2af:	84 45 ec             	test   %al,-0x14(%ebp)
 2b2:	74 07                	je     2bb <s_getReverseDigits+0x82>
    outbuf[i++] = '-';
 2b4:	83 c7 01             	add    $0x1,%edi
 2b7:	c6 04 16 2d          	movb   $0x2d,(%esi,%edx,1)
  }

  return i;
}
 2bb:	89 f8                	mov    %edi,%eax
 2bd:	83 c4 08             	add    $0x8,%esp
 2c0:	5b                   	pop    %ebx
 2c1:	5e                   	pop    %esi
 2c2:	5f                   	pop    %edi
 2c3:	5d                   	pop    %ebp
 2c4:	c3                   	ret    

000002c5 <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
 2c5:	39 c2                	cmp    %eax,%edx
 2c7:	0f 46 c2             	cmovbe %edx,%eax
}
 2ca:	c3                   	ret    

000002cb <s_printint>:
{
 2cb:	55                   	push   %ebp
 2cc:	89 e5                	mov    %esp,%ebp
 2ce:	57                   	push   %edi
 2cf:	56                   	push   %esi
 2d0:	53                   	push   %ebx
 2d1:	83 ec 2c             	sub    $0x2c,%esp
 2d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 2d7:	89 55 d0             	mov    %edx,-0x30(%ebp)
 2da:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 2dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);
 2e0:	ff 75 14             	pushl  0x14(%ebp)
 2e3:	ff 75 10             	pushl  0x10(%ebp)
 2e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 2e9:	ba 10 00 00 00       	mov    $0x10,%edx
 2ee:	8d 45 d8             	lea    -0x28(%ebp),%eax
 2f1:	e8 43 ff ff ff       	call   239 <s_getReverseDigits>
 2f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
 2f9:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
 2fb:	83 c4 08             	add    $0x8,%esp
  int j = 0;
 2fe:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
 303:	83 eb 01             	sub    $0x1,%ebx
 306:	78 22                	js     32a <s_printint+0x5f>
 308:	39 fe                	cmp    %edi,%esi
 30a:	73 1e                	jae    32a <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
 30c:	83 ec 0c             	sub    $0xc,%esp
 30f:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
 314:	50                   	push   %eax
 315:	56                   	push   %esi
 316:	57                   	push   %edi
 317:	ff 75 cc             	pushl  -0x34(%ebp)
 31a:	ff 75 d0             	pushl  -0x30(%ebp)
 31d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 320:	ff d0                	call   *%eax
    j++;
 322:	83 c6 01             	add    $0x1,%esi
 325:	83 c4 20             	add    $0x20,%esp
 328:	eb d9                	jmp    303 <s_printint+0x38>
}
 32a:	8b 45 c8             	mov    -0x38(%ebp),%eax
 32d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 330:	5b                   	pop    %ebx
 331:	5e                   	pop    %esi
 332:	5f                   	pop    %edi
 333:	5d                   	pop    %ebp
 334:	c3                   	ret    

00000335 <s_printf>:

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
 335:	55                   	push   %ebp
 336:	89 e5                	mov    %esp,%ebp
 338:	57                   	push   %edi
 339:	56                   	push   %esi
 33a:	53                   	push   %ebx
 33b:	83 ec 2c             	sub    $0x2c,%esp
 33e:	89 45 d8             	mov    %eax,-0x28(%ebp)
 341:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 344:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1; // leave room for nul termination
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	8d 78 ff             	lea    -0x1(%eax),%edi

  state = 0;
 34d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
 354:	bb 00 00 00 00       	mov    $0x0,%ebx
 359:	89 f8                	mov    %edi,%eax
 35b:	89 df                	mov    %ebx,%edi
 35d:	89 c6                	mov    %eax,%esi
 35f:	eb 20                	jmp    381 <s_printf+0x4c>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
 361:	8d 43 01             	lea    0x1(%ebx),%eax
 364:	89 45 e0             	mov    %eax,-0x20(%ebp)
 367:	83 ec 0c             	sub    $0xc,%esp
 36a:	51                   	push   %ecx
 36b:	53                   	push   %ebx
 36c:	56                   	push   %esi
 36d:	ff 75 d0             	pushl  -0x30(%ebp)
 370:	ff 75 d4             	pushl  -0x2c(%ebp)
 373:	8b 55 d8             	mov    -0x28(%ebp),%edx
 376:	ff d2                	call   *%edx
 378:	83 c4 20             	add    $0x20,%esp
 37b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
 37e:	83 c7 01             	add    $0x1,%edi
 381:	8b 45 0c             	mov    0xc(%ebp),%eax
 384:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
 388:	84 c0                	test   %al,%al
 38a:	0f 84 cd 01 00 00    	je     55d <s_printf+0x228>
 390:	89 75 e0             	mov    %esi,-0x20(%ebp)
 393:	39 de                	cmp    %ebx,%esi
 395:	0f 86 c2 01 00 00    	jbe    55d <s_printf+0x228>
    c = fmt[i] & 0xff;
 39b:	0f be c8             	movsbl %al,%ecx
 39e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 3a1:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 3a8:	75 0a                	jne    3b4 <s_printf+0x7f>
      if(c == '%') {
 3aa:	83 f8 25             	cmp    $0x25,%eax
 3ad:	75 b2                	jne    361 <s_printf+0x2c>
        state = '%';
 3af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 3b2:	eb ca                	jmp    37e <s_printf+0x49>
      }
    } else if(state == '%'){
 3b4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 3b8:	75 c4                	jne    37e <s_printf+0x49>
      if(c == 'd'){
 3ba:	83 f8 64             	cmp    $0x64,%eax
 3bd:	74 6e                	je     42d <s_printf+0xf8>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3bf:	83 f8 78             	cmp    $0x78,%eax
 3c2:	0f 94 c1             	sete   %cl
 3c5:	83 f8 70             	cmp    $0x70,%eax
 3c8:	0f 94 c2             	sete   %dl
 3cb:	08 d1                	or     %dl,%cl
 3cd:	0f 85 8e 00 00 00    	jne    461 <s_printf+0x12c>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3d3:	83 f8 73             	cmp    $0x73,%eax
 3d6:	0f 84 b9 00 00 00    	je     495 <s_printf+0x160>
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
 3dc:	83 f8 63             	cmp    $0x63,%eax
 3df:	0f 84 1a 01 00 00    	je     4ff <s_printf+0x1ca>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
 3e5:	83 f8 25             	cmp    $0x25,%eax
 3e8:	0f 84 44 01 00 00    	je     532 <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
 3ee:	8d 43 01             	lea    0x1(%ebx),%eax
 3f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 3f4:	83 ec 0c             	sub    $0xc,%esp
 3f7:	6a 25                	push   $0x25
 3f9:	53                   	push   %ebx
 3fa:	56                   	push   %esi
 3fb:	ff 75 d0             	pushl  -0x30(%ebp)
 3fe:	ff 75 d4             	pushl  -0x2c(%ebp)
 401:	8b 45 d8             	mov    -0x28(%ebp),%eax
 404:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
 406:	83 c3 02             	add    $0x2,%ebx
 409:	83 c4 14             	add    $0x14,%esp
 40c:	ff 75 dc             	pushl  -0x24(%ebp)
 40f:	ff 75 e4             	pushl  -0x1c(%ebp)
 412:	56                   	push   %esi
 413:	ff 75 d0             	pushl  -0x30(%ebp)
 416:	ff 75 d4             	pushl  -0x2c(%ebp)
 419:	8b 45 d8             	mov    -0x28(%ebp),%eax
 41c:	ff d0                	call   *%eax
 41e:	83 c4 20             	add    $0x20,%esp
      }
      state = 0;
 421:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 428:	e9 51 ff ff ff       	jmp    37e <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
 42d:	8b 45 d0             	mov    -0x30(%ebp),%eax
 430:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 433:	6a 01                	push   $0x1
 435:	6a 0a                	push   $0xa
 437:	8b 45 10             	mov    0x10(%ebp),%eax
 43a:	ff 30                	pushl  (%eax)
 43c:	89 f0                	mov    %esi,%eax
 43e:	29 d8                	sub    %ebx,%eax
 440:	50                   	push   %eax
 441:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 444:	8b 45 d8             	mov    -0x28(%ebp),%eax
 447:	e8 7f fe ff ff       	call   2cb <s_printint>
 44c:	01 c3                	add    %eax,%ebx
        ap++;
 44e:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 452:	83 c4 10             	add    $0x10,%esp
      state = 0;
 455:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 45c:	e9 1d ff ff ff       	jmp    37e <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
 461:	8b 45 d0             	mov    -0x30(%ebp),%eax
 464:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 467:	6a 00                	push   $0x0
 469:	6a 10                	push   $0x10
 46b:	8b 45 10             	mov    0x10(%ebp),%eax
 46e:	ff 30                	pushl  (%eax)
 470:	89 f0                	mov    %esi,%eax
 472:	29 d8                	sub    %ebx,%eax
 474:	50                   	push   %eax
 475:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 478:	8b 45 d8             	mov    -0x28(%ebp),%eax
 47b:	e8 4b fe ff ff       	call   2cb <s_printint>
 480:	01 c3                	add    %eax,%ebx
        ap++;
 482:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 486:	83 c4 10             	add    $0x10,%esp
      state = 0;
 489:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 490:	e9 e9 fe ff ff       	jmp    37e <s_printf+0x49>
        s = (char*)*ap;
 495:	8b 45 10             	mov    0x10(%ebp),%eax
 498:	8b 00                	mov    (%eax),%eax
        ap++;
 49a:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
 49e:	85 c0                	test   %eax,%eax
 4a0:	75 4e                	jne    4f0 <s_printf+0x1bb>
          s = "(null)";
 4a2:	b8 62 06 00 00       	mov    $0x662,%eax
 4a7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4aa:	89 da                	mov    %ebx,%edx
 4ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 4af:	89 75 e0             	mov    %esi,-0x20(%ebp)
 4b2:	89 c6                	mov    %eax,%esi
 4b4:	eb 1f                	jmp    4d5 <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
 4b6:	8d 7a 01             	lea    0x1(%edx),%edi
 4b9:	83 ec 0c             	sub    $0xc,%esp
 4bc:	0f be c0             	movsbl %al,%eax
 4bf:	50                   	push   %eax
 4c0:	52                   	push   %edx
 4c1:	53                   	push   %ebx
 4c2:	ff 75 d0             	pushl  -0x30(%ebp)
 4c5:	ff 75 d4             	pushl  -0x2c(%ebp)
 4c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
 4cb:	ff d0                	call   *%eax
          s++;
 4cd:	83 c6 01             	add    $0x1,%esi
 4d0:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
 4d3:	89 fa                	mov    %edi,%edx
        while(*s != 0){
 4d5:	0f b6 06             	movzbl (%esi),%eax
 4d8:	84 c0                	test   %al,%al
 4da:	75 da                	jne    4b6 <s_printf+0x181>
 4dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4df:	89 d3                	mov    %edx,%ebx
 4e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
 4e4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 4eb:	e9 8e fe ff ff       	jmp    37e <s_printf+0x49>
 4f0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4f3:	89 da                	mov    %ebx,%edx
 4f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 4f8:	89 75 e0             	mov    %esi,-0x20(%ebp)
 4fb:	89 c6                	mov    %eax,%esi
 4fd:	eb d6                	jmp    4d5 <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 4ff:	8d 43 01             	lea    0x1(%ebx),%eax
 502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 505:	83 ec 0c             	sub    $0xc,%esp
 508:	8b 55 10             	mov    0x10(%ebp),%edx
 50b:	0f be 02             	movsbl (%edx),%eax
 50e:	50                   	push   %eax
 50f:	53                   	push   %ebx
 510:	56                   	push   %esi
 511:	ff 75 d0             	pushl  -0x30(%ebp)
 514:	ff 75 d4             	pushl  -0x2c(%ebp)
 517:	8b 55 d8             	mov    -0x28(%ebp),%edx
 51a:	ff d2                	call   *%edx
        ap++;
 51c:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 520:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 523:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 526:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 52d:	e9 4c fe ff ff       	jmp    37e <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
 532:	8d 43 01             	lea    0x1(%ebx),%eax
 535:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 538:	83 ec 0c             	sub    $0xc,%esp
 53b:	ff 75 dc             	pushl  -0x24(%ebp)
 53e:	53                   	push   %ebx
 53f:	56                   	push   %esi
 540:	ff 75 d0             	pushl  -0x30(%ebp)
 543:	ff 75 d4             	pushl  -0x2c(%ebp)
 546:	8b 55 d8             	mov    -0x28(%ebp),%edx
 549:	ff d2                	call   *%edx
 54b:	83 c4 20             	add    $0x20,%esp
 54e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 551:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 558:	e9 21 fe ff ff       	jmp    37e <s_printf+0x49>
    }
  }
  
  return s_min(length, outindex);
 55d:	89 da                	mov    %ebx,%edx
 55f:	89 f0                	mov    %esi,%eax
 561:	e8 5f fd ff ff       	call   2c5 <s_min>
}
 566:	8d 65 f4             	lea    -0xc(%ebp),%esp
 569:	5b                   	pop    %ebx
 56a:	5e                   	pop    %esi
 56b:	5f                   	pop    %edi
 56c:	5d                   	pop    %ebp
 56d:	c3                   	ret    

0000056e <s_putc>:
{
 56e:	f3 0f 1e fb          	endbr32 
 572:	55                   	push   %ebp
 573:	89 e5                	mov    %esp,%ebp
 575:	83 ec 1c             	sub    $0x1c,%esp
 578:	8b 45 18             	mov    0x18(%ebp),%eax
 57b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 57e:	6a 01                	push   $0x1
 580:	8d 45 f4             	lea    -0xc(%ebp),%eax
 583:	50                   	push   %eax
 584:	ff 75 08             	pushl  0x8(%ebp)
 587:	e8 f3 fb ff ff       	call   17f <write>
}
 58c:	83 c4 10             	add    $0x10,%esp
 58f:	c9                   	leave  
 590:	c3                   	ret    

00000591 <snprintf>:
// Print into outbuffer at most n characters. Only understands %d, %x, %p, %s.
// If n is greater than 0, a terminating nul is always stored in outbuffer.
// \return the number of characters written to outbuffer not counting the
// terminating nul.
int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
 591:	f3 0f 1e fb          	endbr32 
 595:	55                   	push   %ebp
 596:	89 e5                	mov    %esp,%ebp
 598:	56                   	push   %esi
 599:	53                   	push   %ebx
 59a:	8b 75 08             	mov    0x8(%ebp),%esi
 59d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
 5a0:	83 ec 04             	sub    $0x4,%esp
 5a3:	8d 45 14             	lea    0x14(%ebp),%eax
 5a6:	50                   	push   %eax
 5a7:	ff 75 10             	pushl  0x10(%ebp)
 5aa:	53                   	push   %ebx
 5ab:	89 f1                	mov    %esi,%ecx
 5ad:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 5b2:	b8 1f 02 00 00       	mov    $0x21f,%eax
 5b7:	e8 79 fd ff ff       	call   335 <s_printf>
  if(count < n) {
 5bc:	83 c4 10             	add    $0x10,%esp
 5bf:	39 c3                	cmp    %eax,%ebx
 5c1:	76 04                	jbe    5c7 <snprintf+0x36>
    outbuffer[count] = 0; // Assure nul termination
 5c3:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
  } 

  return count;
}
 5c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
 5ca:	5b                   	pop    %ebx
 5cb:	5e                   	pop    %esi
 5cc:	5d                   	pop    %ebp
 5cd:	c3                   	ret    

000005ce <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5ce:	f3 0f 1e fb          	endbr32 
 5d2:	55                   	push   %ebp
 5d3:	89 e5                	mov    %esp,%ebp
 5d5:	83 ec 0c             	sub    $0xc,%esp
  static const uint veryLarge = 1<<30;
  uint* ap = (uint*)(void*)&fmt + 1;
  s_printf(s_putc, fd, 0, veryLarge, fmt, ap);
 5d8:	8d 45 10             	lea    0x10(%ebp),%eax
 5db:	50                   	push   %eax
 5dc:	ff 75 0c             	pushl  0xc(%ebp)
 5df:	68 00 00 00 40       	push   $0x40000000
 5e4:	b9 00 00 00 00       	mov    $0x0,%ecx
 5e9:	8b 55 08             	mov    0x8(%ebp),%edx
 5ec:	b8 6e 05 00 00       	mov    $0x56e,%eax
 5f1:	e8 3f fd ff ff       	call   335 <s_printf>
 5f6:	83 c4 10             	add    $0x10,%esp
 5f9:	c9                   	leave  
 5fa:	c3                   	ret    
