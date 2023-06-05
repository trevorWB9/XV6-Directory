
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	53                   	push   %ebx
  12:	51                   	push   %ecx
  int pid, wpid;
  if(open("console", O_RDWR) < 0){
  13:	83 ec 08             	sub    $0x8,%esp
  16:	6a 02                	push   $0x2
  18:	68 a8 06 00 00       	push   $0x6a8
  1d:	e8 27 02 00 00       	call   249 <open>
  22:	83 c4 10             	add    $0x10,%esp
  25:	85 c0                	test   %eax,%eax
  27:	0f 88 d2 00 00 00    	js     ff <main+0xff>
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  2d:	83 ec 0c             	sub    $0xc,%esp
  30:	6a 00                	push   $0x0
  32:	e8 4a 02 00 00       	call   281 <dup>
  dup(0);  // stderr
  37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  3e:	e8 3e 02 00 00       	call   281 <dup>

  //Changed here
  mkdir("dev");
  43:	c7 04 24 b0 06 00 00 	movl   $0x6b0,(%esp)
  4a:	e8 22 02 00 00       	call   271 <mkdir>
  if(open("dev/null", O_RDONLY) < 0){
  4f:	83 c4 08             	add    $0x8,%esp
  52:	6a 00                	push   $0x0
  54:	68 b4 06 00 00       	push   $0x6b4
  59:	e8 eb 01 00 00       	call   249 <open>
  5e:	83 c4 10             	add    $0x10,%esp
  61:	85 c0                	test   %eax,%eax
  63:	0f 88 be 00 00 00    	js     127 <main+0x127>
    mknod("dev/null", 7, 1);
    open("dev/null", O_RDONLY);
  }
  if(open("dev/zero", O_WRONLY) < 0){
  69:	83 ec 08             	sub    $0x8,%esp
  6c:	6a 01                	push   $0x1
  6e:	68 bd 06 00 00       	push   $0x6bd
  73:	e8 d1 01 00 00       	call   249 <open>
  78:	83 c4 10             	add    $0x10,%esp
  7b:	85 c0                	test   %eax,%eax
  7d:	0f 88 cc 00 00 00    	js     14f <main+0x14f>
    mknod("dev/zero", 8, 1);
    open("dev/zero", O_WRONLY);
  }
  if(open("dev/ticks", O_RDONLY) < 0){
  83:	83 ec 08             	sub    $0x8,%esp
  86:	6a 00                	push   $0x0
  88:	68 c6 06 00 00       	push   $0x6c6
  8d:	e8 b7 01 00 00       	call   249 <open>
  92:	83 c4 10             	add    $0x10,%esp
  95:	85 c0                	test   %eax,%eax
  97:	0f 88 da 00 00 00    	js     177 <main+0x177>
    mknod("dev/ticks", 9, 1);
    open("dev/ticks", O_RDONLY);
  }
  if(open("hello", O_RDWR) < 0){
  9d:	83 ec 08             	sub    $0x8,%esp
  a0:	6a 02                	push   $0x2
  a2:	68 d0 06 00 00       	push   $0x6d0
  a7:	e8 9d 01 00 00       	call   249 <open>
  ac:	83 c4 10             	add    $0x10,%esp
  af:	85 c0                	test   %eax,%eax
  b1:	0f 88 e8 00 00 00    	js     19f <main+0x19f>
    mknod("hello", 6, 1);
    open("hello", O_RDWR);
  }
  for(;;){
    printf(1, "init: starting sh\n");
  b7:	83 ec 08             	sub    $0x8,%esp
  ba:	68 d6 06 00 00       	push   $0x6d6
  bf:	6a 01                	push   $0x1
  c1:	e8 b2 05 00 00       	call   678 <printf>
    pid = fork();
  c6:	e8 36 01 00 00       	call   201 <fork>
  cb:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  cd:	83 c4 10             	add    $0x10,%esp
  d0:	85 c0                	test   %eax,%eax
  d2:	0f 88 ef 00 00 00    	js     1c7 <main+0x1c7>
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
  d8:	0f 84 fd 00 00 00    	je     1db <main+0x1db>
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  de:	e8 2e 01 00 00       	call   211 <wait>
  e3:	85 c0                	test   %eax,%eax
  e5:	78 d0                	js     b7 <main+0xb7>
  e7:	39 c3                	cmp    %eax,%ebx
  e9:	74 cc                	je     b7 <main+0xb7>
      printf(1, "zombie!\n");
  eb:	83 ec 08             	sub    $0x8,%esp
  ee:	68 15 07 00 00       	push   $0x715
  f3:	6a 01                	push   $0x1
  f5:	e8 7e 05 00 00       	call   678 <printf>
  fa:	83 c4 10             	add    $0x10,%esp
  fd:	eb df                	jmp    de <main+0xde>
    mknod("console", 1, 1);
  ff:	83 ec 04             	sub    $0x4,%esp
 102:	6a 01                	push   $0x1
 104:	6a 01                	push   $0x1
 106:	68 a8 06 00 00       	push   $0x6a8
 10b:	e8 41 01 00 00       	call   251 <mknod>
    open("console", O_RDWR);
 110:	83 c4 08             	add    $0x8,%esp
 113:	6a 02                	push   $0x2
 115:	68 a8 06 00 00       	push   $0x6a8
 11a:	e8 2a 01 00 00       	call   249 <open>
 11f:	83 c4 10             	add    $0x10,%esp
 122:	e9 06 ff ff ff       	jmp    2d <main+0x2d>
    mknod("dev/null", 7, 1);
 127:	83 ec 04             	sub    $0x4,%esp
 12a:	6a 01                	push   $0x1
 12c:	6a 07                	push   $0x7
 12e:	68 b4 06 00 00       	push   $0x6b4
 133:	e8 19 01 00 00       	call   251 <mknod>
    open("dev/null", O_RDONLY);
 138:	83 c4 08             	add    $0x8,%esp
 13b:	6a 00                	push   $0x0
 13d:	68 b4 06 00 00       	push   $0x6b4
 142:	e8 02 01 00 00       	call   249 <open>
 147:	83 c4 10             	add    $0x10,%esp
 14a:	e9 1a ff ff ff       	jmp    69 <main+0x69>
    mknod("dev/zero", 8, 1);
 14f:	83 ec 04             	sub    $0x4,%esp
 152:	6a 01                	push   $0x1
 154:	6a 08                	push   $0x8
 156:	68 bd 06 00 00       	push   $0x6bd
 15b:	e8 f1 00 00 00       	call   251 <mknod>
    open("dev/zero", O_WRONLY);
 160:	83 c4 08             	add    $0x8,%esp
 163:	6a 01                	push   $0x1
 165:	68 bd 06 00 00       	push   $0x6bd
 16a:	e8 da 00 00 00       	call   249 <open>
 16f:	83 c4 10             	add    $0x10,%esp
 172:	e9 0c ff ff ff       	jmp    83 <main+0x83>
    mknod("dev/ticks", 9, 1);
 177:	83 ec 04             	sub    $0x4,%esp
 17a:	6a 01                	push   $0x1
 17c:	6a 09                	push   $0x9
 17e:	68 c6 06 00 00       	push   $0x6c6
 183:	e8 c9 00 00 00       	call   251 <mknod>
    open("dev/ticks", O_RDONLY);
 188:	83 c4 08             	add    $0x8,%esp
 18b:	6a 00                	push   $0x0
 18d:	68 c6 06 00 00       	push   $0x6c6
 192:	e8 b2 00 00 00       	call   249 <open>
 197:	83 c4 10             	add    $0x10,%esp
 19a:	e9 fe fe ff ff       	jmp    9d <main+0x9d>
    mknod("hello", 6, 1);
 19f:	83 ec 04             	sub    $0x4,%esp
 1a2:	6a 01                	push   $0x1
 1a4:	6a 06                	push   $0x6
 1a6:	68 d0 06 00 00       	push   $0x6d0
 1ab:	e8 a1 00 00 00       	call   251 <mknod>
    open("hello", O_RDWR);
 1b0:	83 c4 08             	add    $0x8,%esp
 1b3:	6a 02                	push   $0x2
 1b5:	68 d0 06 00 00       	push   $0x6d0
 1ba:	e8 8a 00 00 00       	call   249 <open>
 1bf:	83 c4 10             	add    $0x10,%esp
 1c2:	e9 f0 fe ff ff       	jmp    b7 <main+0xb7>
      printf(1, "init: fork failed\n");
 1c7:	83 ec 08             	sub    $0x8,%esp
 1ca:	68 e9 06 00 00       	push   $0x6e9
 1cf:	6a 01                	push   $0x1
 1d1:	e8 a2 04 00 00       	call   678 <printf>
      exit();
 1d6:	e8 2e 00 00 00       	call   209 <exit>
      exec("sh", argv);
 1db:	83 ec 08             	sub    $0x8,%esp
 1de:	68 3c 07 00 00       	push   $0x73c
 1e3:	68 fc 06 00 00       	push   $0x6fc
 1e8:	e8 54 00 00 00       	call   241 <exec>
      printf(1, "init: exec sh failed\n");
 1ed:	83 c4 08             	add    $0x8,%esp
 1f0:	68 ff 06 00 00       	push   $0x6ff
 1f5:	6a 01                	push   $0x1
 1f7:	e8 7c 04 00 00       	call   678 <printf>
      exit();
 1fc:	e8 08 00 00 00       	call   209 <exit>

00000201 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 201:	b8 01 00 00 00       	mov    $0x1,%eax
 206:	cd 40                	int    $0x40
 208:	c3                   	ret    

00000209 <exit>:
SYSCALL(exit)
 209:	b8 02 00 00 00       	mov    $0x2,%eax
 20e:	cd 40                	int    $0x40
 210:	c3                   	ret    

00000211 <wait>:
SYSCALL(wait)
 211:	b8 03 00 00 00       	mov    $0x3,%eax
 216:	cd 40                	int    $0x40
 218:	c3                   	ret    

00000219 <pipe>:
SYSCALL(pipe)
 219:	b8 04 00 00 00       	mov    $0x4,%eax
 21e:	cd 40                	int    $0x40
 220:	c3                   	ret    

00000221 <read>:
SYSCALL(read)
 221:	b8 05 00 00 00       	mov    $0x5,%eax
 226:	cd 40                	int    $0x40
 228:	c3                   	ret    

00000229 <write>:
SYSCALL(write)
 229:	b8 10 00 00 00       	mov    $0x10,%eax
 22e:	cd 40                	int    $0x40
 230:	c3                   	ret    

00000231 <close>:
SYSCALL(close)
 231:	b8 15 00 00 00       	mov    $0x15,%eax
 236:	cd 40                	int    $0x40
 238:	c3                   	ret    

00000239 <kill>:
SYSCALL(kill)
 239:	b8 06 00 00 00       	mov    $0x6,%eax
 23e:	cd 40                	int    $0x40
 240:	c3                   	ret    

00000241 <exec>:
SYSCALL(exec)
 241:	b8 07 00 00 00       	mov    $0x7,%eax
 246:	cd 40                	int    $0x40
 248:	c3                   	ret    

00000249 <open>:
SYSCALL(open)
 249:	b8 0f 00 00 00       	mov    $0xf,%eax
 24e:	cd 40                	int    $0x40
 250:	c3                   	ret    

00000251 <mknod>:
SYSCALL(mknod)
 251:	b8 11 00 00 00       	mov    $0x11,%eax
 256:	cd 40                	int    $0x40
 258:	c3                   	ret    

00000259 <unlink>:
SYSCALL(unlink)
 259:	b8 12 00 00 00       	mov    $0x12,%eax
 25e:	cd 40                	int    $0x40
 260:	c3                   	ret    

00000261 <fstat>:
SYSCALL(fstat)
 261:	b8 08 00 00 00       	mov    $0x8,%eax
 266:	cd 40                	int    $0x40
 268:	c3                   	ret    

00000269 <link>:
SYSCALL(link)
 269:	b8 13 00 00 00       	mov    $0x13,%eax
 26e:	cd 40                	int    $0x40
 270:	c3                   	ret    

00000271 <mkdir>:
SYSCALL(mkdir)
 271:	b8 14 00 00 00       	mov    $0x14,%eax
 276:	cd 40                	int    $0x40
 278:	c3                   	ret    

00000279 <chdir>:
SYSCALL(chdir)
 279:	b8 09 00 00 00       	mov    $0x9,%eax
 27e:	cd 40                	int    $0x40
 280:	c3                   	ret    

00000281 <dup>:
SYSCALL(dup)
 281:	b8 0a 00 00 00       	mov    $0xa,%eax
 286:	cd 40                	int    $0x40
 288:	c3                   	ret    

00000289 <getpid>:
SYSCALL(getpid)
 289:	b8 0b 00 00 00       	mov    $0xb,%eax
 28e:	cd 40                	int    $0x40
 290:	c3                   	ret    

00000291 <sbrk>:
SYSCALL(sbrk)
 291:	b8 0c 00 00 00       	mov    $0xc,%eax
 296:	cd 40                	int    $0x40
 298:	c3                   	ret    

00000299 <sleep>:
SYSCALL(sleep)
 299:	b8 0d 00 00 00       	mov    $0xd,%eax
 29e:	cd 40                	int    $0x40
 2a0:	c3                   	ret    

000002a1 <uptime>:
SYSCALL(uptime)
 2a1:	b8 0e 00 00 00       	mov    $0xe,%eax
 2a6:	cd 40                	int    $0x40
 2a8:	c3                   	ret    

000002a9 <yield>:
SYSCALL(yield)
 2a9:	b8 16 00 00 00       	mov    $0x16,%eax
 2ae:	cd 40                	int    $0x40
 2b0:	c3                   	ret    

000002b1 <shutdown>:
SYSCALL(shutdown)
 2b1:	b8 17 00 00 00       	mov    $0x17,%eax
 2b6:	cd 40                	int    $0x40
 2b8:	c3                   	ret    

000002b9 <nice>:
SYSCALL(nice)
 2b9:	b8 18 00 00 00       	mov    $0x18,%eax
 2be:	cd 40                	int    $0x40
 2c0:	c3                   	ret    

000002c1 <cps>:
SYSCALL(cps)
 2c1:	b8 19 00 00 00       	mov    $0x19,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret    

000002c9 <s_sputc>:
  write(fd, &c, 1);
}

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
 2c9:	f3 0f 1e fb          	endbr32 
 2cd:	55                   	push   %ebp
 2ce:	89 e5                	mov    %esp,%ebp
 2d0:	8b 45 14             	mov    0x14(%ebp),%eax
 2d3:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
 2d6:	3b 45 10             	cmp    0x10(%ebp),%eax
 2d9:	73 06                	jae    2e1 <s_sputc+0x18>
  {
    outbuffer[index] = c;
 2db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 2de:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
 2e1:	5d                   	pop    %ebp
 2e2:	c3                   	ret    

000002e3 <s_getReverseDigits>:
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
 2e3:	55                   	push   %ebp
 2e4:	89 e5                	mov    %esp,%ebp
 2e6:	57                   	push   %edi
 2e7:	56                   	push   %esi
 2e8:	53                   	push   %ebx
 2e9:	83 ec 08             	sub    $0x8,%esp
 2ec:	89 c6                	mov    %eax,%esi
 2ee:	89 d3                	mov    %edx,%ebx
 2f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2f3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 2f7:	0f 95 c2             	setne  %dl
 2fa:	89 c8                	mov    %ecx,%eax
 2fc:	c1 e8 1f             	shr    $0x1f,%eax
 2ff:	84 c2                	test   %al,%dl
 301:	74 33                	je     336 <s_getReverseDigits+0x53>
    neg = 1;
    x = -xx;
 303:	89 c8                	mov    %ecx,%eax
 305:	f7 d8                	neg    %eax
    neg = 1;
 307:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 30e:	bf 00 00 00 00       	mov    $0x0,%edi
  while(i + 1 < length && x != 0) {
 313:	8d 4f 01             	lea    0x1(%edi),%ecx
 316:	89 ca                	mov    %ecx,%edx
 318:	39 d9                	cmp    %ebx,%ecx
 31a:	73 26                	jae    342 <s_getReverseDigits+0x5f>
 31c:	85 c0                	test   %eax,%eax
 31e:	74 22                	je     342 <s_getReverseDigits+0x5f>
    outbuf[i++] = digits[x % base];
 320:	ba 00 00 00 00       	mov    $0x0,%edx
 325:	f7 75 08             	divl   0x8(%ebp)
 328:	0f b6 92 28 07 00 00 	movzbl 0x728(%edx),%edx
 32f:	88 14 3e             	mov    %dl,(%esi,%edi,1)
 332:	89 cf                	mov    %ecx,%edi
 334:	eb dd                	jmp    313 <s_getReverseDigits+0x30>
    x = xx;
 336:	8b 45 f0             	mov    -0x10(%ebp),%eax
  neg = 0;
 339:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 340:	eb cc                	jmp    30e <s_getReverseDigits+0x2b>
    x /= base;
  }

  if(0 == xx && i + 1 < length) {
 342:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 346:	75 0a                	jne    352 <s_getReverseDigits+0x6f>
 348:	39 da                	cmp    %ebx,%edx
 34a:	73 06                	jae    352 <s_getReverseDigits+0x6f>
    outbuf[i++] = digits[0];   
 34c:	c6 04 3e 30          	movb   $0x30,(%esi,%edi,1)
 350:	89 cf                	mov    %ecx,%edi
  }

  if(neg && i < length) {
 352:	89 fa                	mov    %edi,%edx
 354:	39 df                	cmp    %ebx,%edi
 356:	0f 92 c0             	setb   %al
 359:	84 45 ec             	test   %al,-0x14(%ebp)
 35c:	74 07                	je     365 <s_getReverseDigits+0x82>
    outbuf[i++] = '-';
 35e:	83 c7 01             	add    $0x1,%edi
 361:	c6 04 16 2d          	movb   $0x2d,(%esi,%edx,1)
  }

  return i;
}
 365:	89 f8                	mov    %edi,%eax
 367:	83 c4 08             	add    $0x8,%esp
 36a:	5b                   	pop    %ebx
 36b:	5e                   	pop    %esi
 36c:	5f                   	pop    %edi
 36d:	5d                   	pop    %ebp
 36e:	c3                   	ret    

0000036f <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
 36f:	39 c2                	cmp    %eax,%edx
 371:	0f 46 c2             	cmovbe %edx,%eax
}
 374:	c3                   	ret    

00000375 <s_printint>:
{
 375:	55                   	push   %ebp
 376:	89 e5                	mov    %esp,%ebp
 378:	57                   	push   %edi
 379:	56                   	push   %esi
 37a:	53                   	push   %ebx
 37b:	83 ec 2c             	sub    $0x2c,%esp
 37e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 381:	89 55 d0             	mov    %edx,-0x30(%ebp)
 384:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 387:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);
 38a:	ff 75 14             	pushl  0x14(%ebp)
 38d:	ff 75 10             	pushl  0x10(%ebp)
 390:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 393:	ba 10 00 00 00       	mov    $0x10,%edx
 398:	8d 45 d8             	lea    -0x28(%ebp),%eax
 39b:	e8 43 ff ff ff       	call   2e3 <s_getReverseDigits>
 3a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
 3a3:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
 3a5:	83 c4 08             	add    $0x8,%esp
  int j = 0;
 3a8:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
 3ad:	83 eb 01             	sub    $0x1,%ebx
 3b0:	78 22                	js     3d4 <s_printint+0x5f>
 3b2:	39 fe                	cmp    %edi,%esi
 3b4:	73 1e                	jae    3d4 <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
 3b6:	83 ec 0c             	sub    $0xc,%esp
 3b9:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
 3be:	50                   	push   %eax
 3bf:	56                   	push   %esi
 3c0:	57                   	push   %edi
 3c1:	ff 75 cc             	pushl  -0x34(%ebp)
 3c4:	ff 75 d0             	pushl  -0x30(%ebp)
 3c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 3ca:	ff d0                	call   *%eax
    j++;
 3cc:	83 c6 01             	add    $0x1,%esi
 3cf:	83 c4 20             	add    $0x20,%esp
 3d2:	eb d9                	jmp    3ad <s_printint+0x38>
}
 3d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
 3d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3da:	5b                   	pop    %ebx
 3db:	5e                   	pop    %esi
 3dc:	5f                   	pop    %edi
 3dd:	5d                   	pop    %ebp
 3de:	c3                   	ret    

000003df <s_printf>:

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
 3df:	55                   	push   %ebp
 3e0:	89 e5                	mov    %esp,%ebp
 3e2:	57                   	push   %edi
 3e3:	56                   	push   %esi
 3e4:	53                   	push   %ebx
 3e5:	83 ec 2c             	sub    $0x2c,%esp
 3e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
 3eb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3ee:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1; // leave room for nul termination
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	8d 78 ff             	lea    -0x1(%eax),%edi

  state = 0;
 3f7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
 3fe:	bb 00 00 00 00       	mov    $0x0,%ebx
 403:	89 f8                	mov    %edi,%eax
 405:	89 df                	mov    %ebx,%edi
 407:	89 c6                	mov    %eax,%esi
 409:	eb 20                	jmp    42b <s_printf+0x4c>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
 40b:	8d 43 01             	lea    0x1(%ebx),%eax
 40e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 411:	83 ec 0c             	sub    $0xc,%esp
 414:	51                   	push   %ecx
 415:	53                   	push   %ebx
 416:	56                   	push   %esi
 417:	ff 75 d0             	pushl  -0x30(%ebp)
 41a:	ff 75 d4             	pushl  -0x2c(%ebp)
 41d:	8b 55 d8             	mov    -0x28(%ebp),%edx
 420:	ff d2                	call   *%edx
 422:	83 c4 20             	add    $0x20,%esp
 425:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
 428:	83 c7 01             	add    $0x1,%edi
 42b:	8b 45 0c             	mov    0xc(%ebp),%eax
 42e:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
 432:	84 c0                	test   %al,%al
 434:	0f 84 cd 01 00 00    	je     607 <s_printf+0x228>
 43a:	89 75 e0             	mov    %esi,-0x20(%ebp)
 43d:	39 de                	cmp    %ebx,%esi
 43f:	0f 86 c2 01 00 00    	jbe    607 <s_printf+0x228>
    c = fmt[i] & 0xff;
 445:	0f be c8             	movsbl %al,%ecx
 448:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 44b:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 44e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 452:	75 0a                	jne    45e <s_printf+0x7f>
      if(c == '%') {
 454:	83 f8 25             	cmp    $0x25,%eax
 457:	75 b2                	jne    40b <s_printf+0x2c>
        state = '%';
 459:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 45c:	eb ca                	jmp    428 <s_printf+0x49>
      }
    } else if(state == '%'){
 45e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 462:	75 c4                	jne    428 <s_printf+0x49>
      if(c == 'd'){
 464:	83 f8 64             	cmp    $0x64,%eax
 467:	74 6e                	je     4d7 <s_printf+0xf8>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 469:	83 f8 78             	cmp    $0x78,%eax
 46c:	0f 94 c1             	sete   %cl
 46f:	83 f8 70             	cmp    $0x70,%eax
 472:	0f 94 c2             	sete   %dl
 475:	08 d1                	or     %dl,%cl
 477:	0f 85 8e 00 00 00    	jne    50b <s_printf+0x12c>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 47d:	83 f8 73             	cmp    $0x73,%eax
 480:	0f 84 b9 00 00 00    	je     53f <s_printf+0x160>
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
 486:	83 f8 63             	cmp    $0x63,%eax
 489:	0f 84 1a 01 00 00    	je     5a9 <s_printf+0x1ca>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
 48f:	83 f8 25             	cmp    $0x25,%eax
 492:	0f 84 44 01 00 00    	je     5dc <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
 498:	8d 43 01             	lea    0x1(%ebx),%eax
 49b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 49e:	83 ec 0c             	sub    $0xc,%esp
 4a1:	6a 25                	push   $0x25
 4a3:	53                   	push   %ebx
 4a4:	56                   	push   %esi
 4a5:	ff 75 d0             	pushl  -0x30(%ebp)
 4a8:	ff 75 d4             	pushl  -0x2c(%ebp)
 4ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
 4ae:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
 4b0:	83 c3 02             	add    $0x2,%ebx
 4b3:	83 c4 14             	add    $0x14,%esp
 4b6:	ff 75 dc             	pushl  -0x24(%ebp)
 4b9:	ff 75 e4             	pushl  -0x1c(%ebp)
 4bc:	56                   	push   %esi
 4bd:	ff 75 d0             	pushl  -0x30(%ebp)
 4c0:	ff 75 d4             	pushl  -0x2c(%ebp)
 4c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
 4c6:	ff d0                	call   *%eax
 4c8:	83 c4 20             	add    $0x20,%esp
      }
      state = 0;
 4cb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 4d2:	e9 51 ff ff ff       	jmp    428 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
 4d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
 4da:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 4dd:	6a 01                	push   $0x1
 4df:	6a 0a                	push   $0xa
 4e1:	8b 45 10             	mov    0x10(%ebp),%eax
 4e4:	ff 30                	pushl  (%eax)
 4e6:	89 f0                	mov    %esi,%eax
 4e8:	29 d8                	sub    %ebx,%eax
 4ea:	50                   	push   %eax
 4eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 4ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
 4f1:	e8 7f fe ff ff       	call   375 <s_printint>
 4f6:	01 c3                	add    %eax,%ebx
        ap++;
 4f8:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 4fc:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 506:	e9 1d ff ff ff       	jmp    428 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
 50b:	8b 45 d0             	mov    -0x30(%ebp),%eax
 50e:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 511:	6a 00                	push   $0x0
 513:	6a 10                	push   $0x10
 515:	8b 45 10             	mov    0x10(%ebp),%eax
 518:	ff 30                	pushl  (%eax)
 51a:	89 f0                	mov    %esi,%eax
 51c:	29 d8                	sub    %ebx,%eax
 51e:	50                   	push   %eax
 51f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 522:	8b 45 d8             	mov    -0x28(%ebp),%eax
 525:	e8 4b fe ff ff       	call   375 <s_printint>
 52a:	01 c3                	add    %eax,%ebx
        ap++;
 52c:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 530:	83 c4 10             	add    $0x10,%esp
      state = 0;
 533:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 53a:	e9 e9 fe ff ff       	jmp    428 <s_printf+0x49>
        s = (char*)*ap;
 53f:	8b 45 10             	mov    0x10(%ebp),%eax
 542:	8b 00                	mov    (%eax),%eax
        ap++;
 544:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
 548:	85 c0                	test   %eax,%eax
 54a:	75 4e                	jne    59a <s_printf+0x1bb>
          s = "(null)";
 54c:	b8 1e 07 00 00       	mov    $0x71e,%eax
 551:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 554:	89 da                	mov    %ebx,%edx
 556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 559:	89 75 e0             	mov    %esi,-0x20(%ebp)
 55c:	89 c6                	mov    %eax,%esi
 55e:	eb 1f                	jmp    57f <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
 560:	8d 7a 01             	lea    0x1(%edx),%edi
 563:	83 ec 0c             	sub    $0xc,%esp
 566:	0f be c0             	movsbl %al,%eax
 569:	50                   	push   %eax
 56a:	52                   	push   %edx
 56b:	53                   	push   %ebx
 56c:	ff 75 d0             	pushl  -0x30(%ebp)
 56f:	ff 75 d4             	pushl  -0x2c(%ebp)
 572:	8b 45 d8             	mov    -0x28(%ebp),%eax
 575:	ff d0                	call   *%eax
          s++;
 577:	83 c6 01             	add    $0x1,%esi
 57a:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
 57d:	89 fa                	mov    %edi,%edx
        while(*s != 0){
 57f:	0f b6 06             	movzbl (%esi),%eax
 582:	84 c0                	test   %al,%al
 584:	75 da                	jne    560 <s_printf+0x181>
 586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 589:	89 d3                	mov    %edx,%ebx
 58b:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
 58e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 595:	e9 8e fe ff ff       	jmp    428 <s_printf+0x49>
 59a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 59d:	89 da                	mov    %ebx,%edx
 59f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 5a2:	89 75 e0             	mov    %esi,-0x20(%ebp)
 5a5:	89 c6                	mov    %eax,%esi
 5a7:	eb d6                	jmp    57f <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 5a9:	8d 43 01             	lea    0x1(%ebx),%eax
 5ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 5af:	83 ec 0c             	sub    $0xc,%esp
 5b2:	8b 55 10             	mov    0x10(%ebp),%edx
 5b5:	0f be 02             	movsbl (%edx),%eax
 5b8:	50                   	push   %eax
 5b9:	53                   	push   %ebx
 5ba:	56                   	push   %esi
 5bb:	ff 75 d0             	pushl  -0x30(%ebp)
 5be:	ff 75 d4             	pushl  -0x2c(%ebp)
 5c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
 5c4:	ff d2                	call   *%edx
        ap++;
 5c6:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 5ca:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 5cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 5d0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 5d7:	e9 4c fe ff ff       	jmp    428 <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
 5dc:	8d 43 01             	lea    0x1(%ebx),%eax
 5df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 5e2:	83 ec 0c             	sub    $0xc,%esp
 5e5:	ff 75 dc             	pushl  -0x24(%ebp)
 5e8:	53                   	push   %ebx
 5e9:	56                   	push   %esi
 5ea:	ff 75 d0             	pushl  -0x30(%ebp)
 5ed:	ff 75 d4             	pushl  -0x2c(%ebp)
 5f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
 5f3:	ff d2                	call   *%edx
 5f5:	83 c4 20             	add    $0x20,%esp
 5f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 5fb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 602:	e9 21 fe ff ff       	jmp    428 <s_printf+0x49>
    }
  }
  
  return s_min(length, outindex);
 607:	89 da                	mov    %ebx,%edx
 609:	89 f0                	mov    %esi,%eax
 60b:	e8 5f fd ff ff       	call   36f <s_min>
}
 610:	8d 65 f4             	lea    -0xc(%ebp),%esp
 613:	5b                   	pop    %ebx
 614:	5e                   	pop    %esi
 615:	5f                   	pop    %edi
 616:	5d                   	pop    %ebp
 617:	c3                   	ret    

00000618 <s_putc>:
{
 618:	f3 0f 1e fb          	endbr32 
 61c:	55                   	push   %ebp
 61d:	89 e5                	mov    %esp,%ebp
 61f:	83 ec 1c             	sub    $0x1c,%esp
 622:	8b 45 18             	mov    0x18(%ebp),%eax
 625:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 628:	6a 01                	push   $0x1
 62a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 62d:	50                   	push   %eax
 62e:	ff 75 08             	pushl  0x8(%ebp)
 631:	e8 f3 fb ff ff       	call   229 <write>
}
 636:	83 c4 10             	add    $0x10,%esp
 639:	c9                   	leave  
 63a:	c3                   	ret    

0000063b <snprintf>:
// Print into outbuffer at most n characters. Only understands %d, %x, %p, %s.
// If n is greater than 0, a terminating nul is always stored in outbuffer.
// \return the number of characters written to outbuffer not counting the
// terminating nul.
int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
 63b:	f3 0f 1e fb          	endbr32 
 63f:	55                   	push   %ebp
 640:	89 e5                	mov    %esp,%ebp
 642:	56                   	push   %esi
 643:	53                   	push   %ebx
 644:	8b 75 08             	mov    0x8(%ebp),%esi
 647:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
 64a:	83 ec 04             	sub    $0x4,%esp
 64d:	8d 45 14             	lea    0x14(%ebp),%eax
 650:	50                   	push   %eax
 651:	ff 75 10             	pushl  0x10(%ebp)
 654:	53                   	push   %ebx
 655:	89 f1                	mov    %esi,%ecx
 657:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 65c:	b8 c9 02 00 00       	mov    $0x2c9,%eax
 661:	e8 79 fd ff ff       	call   3df <s_printf>
  if(count < n) {
 666:	83 c4 10             	add    $0x10,%esp
 669:	39 c3                	cmp    %eax,%ebx
 66b:	76 04                	jbe    671 <snprintf+0x36>
    outbuffer[count] = 0; // Assure nul termination
 66d:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
  } 

  return count;
}
 671:	8d 65 f8             	lea    -0x8(%ebp),%esp
 674:	5b                   	pop    %ebx
 675:	5e                   	pop    %esi
 676:	5d                   	pop    %ebp
 677:	c3                   	ret    

00000678 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 678:	f3 0f 1e fb          	endbr32 
 67c:	55                   	push   %ebp
 67d:	89 e5                	mov    %esp,%ebp
 67f:	83 ec 0c             	sub    $0xc,%esp
  static const uint veryLarge = 1<<30;
  uint* ap = (uint*)(void*)&fmt + 1;
  s_printf(s_putc, fd, 0, veryLarge, fmt, ap);
 682:	8d 45 10             	lea    0x10(%ebp),%eax
 685:	50                   	push   %eax
 686:	ff 75 0c             	pushl  0xc(%ebp)
 689:	68 00 00 00 40       	push   $0x40000000
 68e:	b9 00 00 00 00       	mov    $0x0,%ecx
 693:	8b 55 08             	mov    0x8(%ebp),%edx
 696:	b8 18 06 00 00       	mov    $0x618,%eax
 69b:	e8 3f fd ff ff       	call   3df <s_printf>
 6a0:	83 c4 10             	add    $0x10,%esp
 6a3:	c9                   	leave  
 6a4:	c3                   	ret    
