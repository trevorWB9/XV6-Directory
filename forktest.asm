
_forktest:     file format elf32-i386


Disassembly of section .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, const char *s, ...)
{
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	53                   	push   %ebx
   8:	83 ec 10             	sub    $0x10,%esp
   b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  write(fd, s, strlen(s));
   e:	53                   	push   %ebx
   f:	e8 35 01 00 00       	call   149 <strlen>
  14:	83 c4 0c             	add    $0xc,%esp
  17:	50                   	push   %eax
  18:	53                   	push   %ebx
  19:	ff 75 08             	pushl  0x8(%ebp)
  1c:	e8 b1 02 00 00       	call   2d2 <write>
}
  21:	83 c4 10             	add    $0x10,%esp
  24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <forktest>:

void
forktest(void)
{
  29:	f3 0f 1e fb          	endbr32 
  2d:	55                   	push   %ebp
  2e:	89 e5                	mov    %esp,%ebp
  30:	53                   	push   %ebx
  31:	83 ec 0c             	sub    $0xc,%esp
  int n, pid;

  printf(1, "fork test\n");
  34:	68 74 03 00 00       	push   $0x374
  39:	6a 01                	push   $0x1
  3b:	e8 c0 ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  40:	83 c4 10             	add    $0x10,%esp
  43:	bb 00 00 00 00       	mov    $0x0,%ebx
  48:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  4e:	7f 15                	jg     65 <forktest+0x3c>
    pid = fork();
  50:	e8 55 02 00 00       	call   2aa <fork>
    if(pid < 0)
  55:	85 c0                	test   %eax,%eax
  57:	78 0c                	js     65 <forktest+0x3c>
      break;
    if(pid == 0)
  59:	74 05                	je     60 <forktest+0x37>
  for(n=0; n<N; n++){
  5b:	83 c3 01             	add    $0x1,%ebx
  5e:	eb e8                	jmp    48 <forktest+0x1f>
      exit();
  60:	e8 4d 02 00 00       	call   2b2 <exit>
  }

  if(n == N){
  65:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  6b:	74 12                	je     7f <forktest+0x56>
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }

  for(; n > 0; n--){
  6d:	85 db                	test   %ebx,%ebx
  6f:	7e 3b                	jle    ac <forktest+0x83>
    if(wait() < 0){
  71:	e8 44 02 00 00       	call   2ba <wait>
  76:	85 c0                	test   %eax,%eax
  78:	78 1e                	js     98 <forktest+0x6f>
  for(; n > 0; n--){
  7a:	83 eb 01             	sub    $0x1,%ebx
  7d:	eb ee                	jmp    6d <forktest+0x44>
    printf(1, "fork claimed to work N times!\n", N);
  7f:	83 ec 04             	sub    $0x4,%esp
  82:	68 e8 03 00 00       	push   $0x3e8
  87:	68 b4 03 00 00       	push   $0x3b4
  8c:	6a 01                	push   $0x1
  8e:	e8 6d ff ff ff       	call   0 <printf>
    exit();
  93:	e8 1a 02 00 00       	call   2b2 <exit>
      printf(1, "wait stopped early\n");
  98:	83 ec 08             	sub    $0x8,%esp
  9b:	68 7f 03 00 00       	push   $0x37f
  a0:	6a 01                	push   $0x1
  a2:	e8 59 ff ff ff       	call   0 <printf>
      exit();
  a7:	e8 06 02 00 00       	call   2b2 <exit>
    }
  }

  if(wait() != -1){
  ac:	e8 09 02 00 00       	call   2ba <wait>
  b1:	83 f8 ff             	cmp    $0xffffffff,%eax
  b4:	75 17                	jne    cd <forktest+0xa4>
    printf(1, "wait got too many\n");
    exit();
  }

  printf(1, "fork test OK\n");
  b6:	83 ec 08             	sub    $0x8,%esp
  b9:	68 a6 03 00 00       	push   $0x3a6
  be:	6a 01                	push   $0x1
  c0:	e8 3b ff ff ff       	call   0 <printf>
}
  c5:	83 c4 10             	add    $0x10,%esp
  c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  cb:	c9                   	leave  
  cc:	c3                   	ret    
    printf(1, "wait got too many\n");
  cd:	83 ec 08             	sub    $0x8,%esp
  d0:	68 93 03 00 00       	push   $0x393
  d5:	6a 01                	push   $0x1
  d7:	e8 24 ff ff ff       	call   0 <printf>
    exit();
  dc:	e8 d1 01 00 00       	call   2b2 <exit>

000000e1 <main>:

int
main(void)
{
  e1:	f3 0f 1e fb          	endbr32 
  e5:	55                   	push   %ebp
  e6:	89 e5                	mov    %esp,%ebp
  e8:	83 e4 f0             	and    $0xfffffff0,%esp
  forktest();
  eb:	e8 39 ff ff ff       	call   29 <forktest>
  exit();
  f0:	e8 bd 01 00 00       	call   2b2 <exit>

000000f5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  f5:	f3 0f 1e fb          	endbr32 
  f9:	55                   	push   %ebp
  fa:	89 e5                	mov    %esp,%ebp
  fc:	56                   	push   %esi
  fd:	53                   	push   %ebx
  fe:	8b 75 08             	mov    0x8(%ebp),%esi
 101:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 104:	89 f0                	mov    %esi,%eax
 106:	89 d1                	mov    %edx,%ecx
 108:	83 c2 01             	add    $0x1,%edx
 10b:	89 c3                	mov    %eax,%ebx
 10d:	83 c0 01             	add    $0x1,%eax
 110:	0f b6 09             	movzbl (%ecx),%ecx
 113:	88 0b                	mov    %cl,(%ebx)
 115:	84 c9                	test   %cl,%cl
 117:	75 ed                	jne    106 <strcpy+0x11>
    ;
  return os;
}
 119:	89 f0                	mov    %esi,%eax
 11b:	5b                   	pop    %ebx
 11c:	5e                   	pop    %esi
 11d:	5d                   	pop    %ebp
 11e:	c3                   	ret    

0000011f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11f:	f3 0f 1e fb          	endbr32 
 123:	55                   	push   %ebp
 124:	89 e5                	mov    %esp,%ebp
 126:	8b 4d 08             	mov    0x8(%ebp),%ecx
 129:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 12c:	0f b6 01             	movzbl (%ecx),%eax
 12f:	84 c0                	test   %al,%al
 131:	74 0c                	je     13f <strcmp+0x20>
 133:	3a 02                	cmp    (%edx),%al
 135:	75 08                	jne    13f <strcmp+0x20>
    p++, q++;
 137:	83 c1 01             	add    $0x1,%ecx
 13a:	83 c2 01             	add    $0x1,%edx
 13d:	eb ed                	jmp    12c <strcmp+0xd>
  return (uchar)*p - (uchar)*q;
 13f:	0f b6 c0             	movzbl %al,%eax
 142:	0f b6 12             	movzbl (%edx),%edx
 145:	29 d0                	sub    %edx,%eax
}
 147:	5d                   	pop    %ebp
 148:	c3                   	ret    

00000149 <strlen>:

uint
strlen(const char *s)
{
 149:	f3 0f 1e fb          	endbr32 
 14d:	55                   	push   %ebp
 14e:	89 e5                	mov    %esp,%ebp
 150:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 153:	b8 00 00 00 00       	mov    $0x0,%eax
 158:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
 15c:	74 05                	je     163 <strlen+0x1a>
 15e:	83 c0 01             	add    $0x1,%eax
 161:	eb f5                	jmp    158 <strlen+0xf>
    ;
  return n;
}
 163:	5d                   	pop    %ebp
 164:	c3                   	ret    

00000165 <memset>:

void*
memset(void *dst, int c, uint n)
{
 165:	f3 0f 1e fb          	endbr32 
 169:	55                   	push   %ebp
 16a:	89 e5                	mov    %esp,%ebp
 16c:	57                   	push   %edi
 16d:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 170:	89 d7                	mov    %edx,%edi
 172:	8b 4d 10             	mov    0x10(%ebp),%ecx
 175:	8b 45 0c             	mov    0xc(%ebp),%eax
 178:	fc                   	cld    
 179:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 17b:	89 d0                	mov    %edx,%eax
 17d:	5f                   	pop    %edi
 17e:	5d                   	pop    %ebp
 17f:	c3                   	ret    

00000180 <strchr>:

char*
strchr(const char *s, char c)
{
 180:	f3 0f 1e fb          	endbr32 
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	8b 45 08             	mov    0x8(%ebp),%eax
 18a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 18e:	0f b6 10             	movzbl (%eax),%edx
 191:	84 d2                	test   %dl,%dl
 193:	74 09                	je     19e <strchr+0x1e>
    if(*s == c)
 195:	38 ca                	cmp    %cl,%dl
 197:	74 0a                	je     1a3 <strchr+0x23>
  for(; *s; s++)
 199:	83 c0 01             	add    $0x1,%eax
 19c:	eb f0                	jmp    18e <strchr+0xe>
      return (char*)s;
  return 0;
 19e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a3:	5d                   	pop    %ebp
 1a4:	c3                   	ret    

000001a5 <gets>:

char*
gets(char *buf, int max)
{
 1a5:	f3 0f 1e fb          	endbr32 
 1a9:	55                   	push   %ebp
 1aa:	89 e5                	mov    %esp,%ebp
 1ac:	57                   	push   %edi
 1ad:	56                   	push   %esi
 1ae:	53                   	push   %ebx
 1af:	83 ec 1c             	sub    $0x1c,%esp
 1b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b5:	bb 00 00 00 00       	mov    $0x0,%ebx
 1ba:	89 de                	mov    %ebx,%esi
 1bc:	83 c3 01             	add    $0x1,%ebx
 1bf:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 1c2:	7d 2e                	jge    1f2 <gets+0x4d>
    cc = read(0, &c, 1);
 1c4:	83 ec 04             	sub    $0x4,%esp
 1c7:	6a 01                	push   $0x1
 1c9:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1cc:	50                   	push   %eax
 1cd:	6a 00                	push   $0x0
 1cf:	e8 f6 00 00 00       	call   2ca <read>
    if(cc < 1)
 1d4:	83 c4 10             	add    $0x10,%esp
 1d7:	85 c0                	test   %eax,%eax
 1d9:	7e 17                	jle    1f2 <gets+0x4d>
      break;
    buf[i++] = c;
 1db:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1df:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 1e2:	3c 0a                	cmp    $0xa,%al
 1e4:	0f 94 c2             	sete   %dl
 1e7:	3c 0d                	cmp    $0xd,%al
 1e9:	0f 94 c0             	sete   %al
 1ec:	08 c2                	or     %al,%dl
 1ee:	74 ca                	je     1ba <gets+0x15>
    buf[i++] = c;
 1f0:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 1f2:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 1f6:	89 f8                	mov    %edi,%eax
 1f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1fb:	5b                   	pop    %ebx
 1fc:	5e                   	pop    %esi
 1fd:	5f                   	pop    %edi
 1fe:	5d                   	pop    %ebp
 1ff:	c3                   	ret    

00000200 <stat>:

int
stat(const char *n, struct stat *st)
{
 200:	f3 0f 1e fb          	endbr32 
 204:	55                   	push   %ebp
 205:	89 e5                	mov    %esp,%ebp
 207:	56                   	push   %esi
 208:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 209:	83 ec 08             	sub    $0x8,%esp
 20c:	6a 00                	push   $0x0
 20e:	ff 75 08             	pushl  0x8(%ebp)
 211:	e8 dc 00 00 00       	call   2f2 <open>
  if(fd < 0)
 216:	83 c4 10             	add    $0x10,%esp
 219:	85 c0                	test   %eax,%eax
 21b:	78 24                	js     241 <stat+0x41>
 21d:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 21f:	83 ec 08             	sub    $0x8,%esp
 222:	ff 75 0c             	pushl  0xc(%ebp)
 225:	50                   	push   %eax
 226:	e8 df 00 00 00       	call   30a <fstat>
 22b:	89 c6                	mov    %eax,%esi
  close(fd);
 22d:	89 1c 24             	mov    %ebx,(%esp)
 230:	e8 a5 00 00 00       	call   2da <close>
  return r;
 235:	83 c4 10             	add    $0x10,%esp
}
 238:	89 f0                	mov    %esi,%eax
 23a:	8d 65 f8             	lea    -0x8(%ebp),%esp
 23d:	5b                   	pop    %ebx
 23e:	5e                   	pop    %esi
 23f:	5d                   	pop    %ebp
 240:	c3                   	ret    
    return -1;
 241:	be ff ff ff ff       	mov    $0xffffffff,%esi
 246:	eb f0                	jmp    238 <stat+0x38>

00000248 <atoi>:

int
atoi(const char *s)
{
 248:	f3 0f 1e fb          	endbr32 
 24c:	55                   	push   %ebp
 24d:	89 e5                	mov    %esp,%ebp
 24f:	53                   	push   %ebx
 250:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 253:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 258:	0f b6 01             	movzbl (%ecx),%eax
 25b:	8d 58 d0             	lea    -0x30(%eax),%ebx
 25e:	80 fb 09             	cmp    $0x9,%bl
 261:	77 12                	ja     275 <atoi+0x2d>
    n = n*10 + *s++ - '0';
 263:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
 266:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
 269:	83 c1 01             	add    $0x1,%ecx
 26c:	0f be c0             	movsbl %al,%eax
 26f:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
 273:	eb e3                	jmp    258 <atoi+0x10>
  return n;
}
 275:	89 d0                	mov    %edx,%eax
 277:	5b                   	pop    %ebx
 278:	5d                   	pop    %ebp
 279:	c3                   	ret    

0000027a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27a:	f3 0f 1e fb          	endbr32 
 27e:	55                   	push   %ebp
 27f:	89 e5                	mov    %esp,%ebp
 281:	56                   	push   %esi
 282:	53                   	push   %ebx
 283:	8b 75 08             	mov    0x8(%ebp),%esi
 286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 289:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
 28c:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
 28e:	8d 58 ff             	lea    -0x1(%eax),%ebx
 291:	85 c0                	test   %eax,%eax
 293:	7e 0f                	jle    2a4 <memmove+0x2a>
    *dst++ = *src++;
 295:	0f b6 01             	movzbl (%ecx),%eax
 298:	88 02                	mov    %al,(%edx)
 29a:	8d 49 01             	lea    0x1(%ecx),%ecx
 29d:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
 2a0:	89 d8                	mov    %ebx,%eax
 2a2:	eb ea                	jmp    28e <memmove+0x14>
  return vdst;
}
 2a4:	89 f0                	mov    %esi,%eax
 2a6:	5b                   	pop    %ebx
 2a7:	5e                   	pop    %esi
 2a8:	5d                   	pop    %ebp
 2a9:	c3                   	ret    

000002aa <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2aa:	b8 01 00 00 00       	mov    $0x1,%eax
 2af:	cd 40                	int    $0x40
 2b1:	c3                   	ret    

000002b2 <exit>:
SYSCALL(exit)
 2b2:	b8 02 00 00 00       	mov    $0x2,%eax
 2b7:	cd 40                	int    $0x40
 2b9:	c3                   	ret    

000002ba <wait>:
SYSCALL(wait)
 2ba:	b8 03 00 00 00       	mov    $0x3,%eax
 2bf:	cd 40                	int    $0x40
 2c1:	c3                   	ret    

000002c2 <pipe>:
SYSCALL(pipe)
 2c2:	b8 04 00 00 00       	mov    $0x4,%eax
 2c7:	cd 40                	int    $0x40
 2c9:	c3                   	ret    

000002ca <read>:
SYSCALL(read)
 2ca:	b8 05 00 00 00       	mov    $0x5,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <write>:
SYSCALL(write)
 2d2:	b8 10 00 00 00       	mov    $0x10,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <close>:
SYSCALL(close)
 2da:	b8 15 00 00 00       	mov    $0x15,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <kill>:
SYSCALL(kill)
 2e2:	b8 06 00 00 00       	mov    $0x6,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <exec>:
SYSCALL(exec)
 2ea:	b8 07 00 00 00       	mov    $0x7,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <open>:
SYSCALL(open)
 2f2:	b8 0f 00 00 00       	mov    $0xf,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <mknod>:
SYSCALL(mknod)
 2fa:	b8 11 00 00 00       	mov    $0x11,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <unlink>:
SYSCALL(unlink)
 302:	b8 12 00 00 00       	mov    $0x12,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <fstat>:
SYSCALL(fstat)
 30a:	b8 08 00 00 00       	mov    $0x8,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <link>:
SYSCALL(link)
 312:	b8 13 00 00 00       	mov    $0x13,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <mkdir>:
SYSCALL(mkdir)
 31a:	b8 14 00 00 00       	mov    $0x14,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <chdir>:
SYSCALL(chdir)
 322:	b8 09 00 00 00       	mov    $0x9,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <dup>:
SYSCALL(dup)
 32a:	b8 0a 00 00 00       	mov    $0xa,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <getpid>:
SYSCALL(getpid)
 332:	b8 0b 00 00 00       	mov    $0xb,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <sbrk>:
SYSCALL(sbrk)
 33a:	b8 0c 00 00 00       	mov    $0xc,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <sleep>:
SYSCALL(sleep)
 342:	b8 0d 00 00 00       	mov    $0xd,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <uptime>:
SYSCALL(uptime)
 34a:	b8 0e 00 00 00       	mov    $0xe,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <yield>:
SYSCALL(yield)
 352:	b8 16 00 00 00       	mov    $0x16,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <shutdown>:
SYSCALL(shutdown)
 35a:	b8 17 00 00 00       	mov    $0x17,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <nice>:
SYSCALL(nice)
 362:	b8 18 00 00 00       	mov    $0x18,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <cps>:
SYSCALL(cps)
 36a:	b8 19 00 00 00       	mov    $0x19,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    
