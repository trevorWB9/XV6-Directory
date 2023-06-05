
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:




int main(int argc, char *argv[])
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
  15:	83 ec 08             	sub    $0x8,%esp
  18:	8b 41 04             	mov    0x4(%ecx),%eax
    int pid;
    int x,y,a,b;
    if(argc <2)
  1b:	83 39 01             	cmpl   $0x1,(%ecx)
  1e:	7f 16                	jg     36 <main+0x36>
    {
        x = 1; 
  20:	bf 01 00 00 00       	mov    $0x1,%edi
    }else
    {
        x = atoi(argv[1]);
    }

    if(x < 0 || x > 5)
  25:	83 ff 05             	cmp    $0x5,%edi
  28:	76 05                	jbe    2f <main+0x2f>
    {
        x = 2;
  2a:	bf 02 00 00 00       	mov    $0x2,%edi
    }

    y = 0;
    pid = 0;

    for(a = 0; a < x; a++)
  2f:	be 00 00 00 00       	mov    $0x0,%esi
  34:	eb 2d                	jmp    63 <main+0x63>
        x = atoi(argv[1]);
  36:	83 ec 0c             	sub    $0xc,%esp
  39:	ff 70 04             	pushl  0x4(%eax)
  3c:	e8 cf 01 00 00       	call   210 <atoi>
  41:	89 c7                	mov    %eax,%edi
  43:	83 c4 10             	add    $0x10,%esp
  46:	eb dd                	jmp    25 <main+0x25>
        pid = fork();
        //printf(1, "pid %d \n", pid);
        if(pid<0)
        {
            //Error if pid = 0
            printf(1, "%d failed to fork\n", getpid());
  48:	e8 ad 02 00 00       	call   2fa <getpid>
  4d:	83 ec 04             	sub    $0x4,%esp
  50:	50                   	push   %eax
  51:	68 18 07 00 00       	push   $0x718
  56:	6a 01                	push   $0x1
  58:	e8 8c 06 00 00       	call   6e9 <printf>
  5d:	83 c4 10             	add    $0x10,%esp
    for(a = 0; a < x; a++)
  60:	83 c6 01             	add    $0x1,%esi
  63:	39 f7                	cmp    %esi,%edi
  65:	7e 51                	jle    b8 <main+0xb8>
        pid = fork();
  67:	e8 06 02 00 00       	call   272 <fork>
  6c:	89 c3                	mov    %eax,%ebx
        if(pid<0)
  6e:	85 c0                	test   %eax,%eax
  70:	78 d6                	js     48 <main+0x48>
        }else if(pid>0)
  72:	7e 1d                	jle    91 <main+0x91>
        {
            //Create parent process
            printf(1, "Parent %d creating child %d\n",getpid(), pid);
  74:	e8 81 02 00 00       	call   2fa <getpid>
  79:	53                   	push   %ebx
  7a:	50                   	push   %eax
  7b:	68 2b 07 00 00       	push   $0x72b
  80:	6a 01                	push   $0x1
  82:	e8 62 06 00 00       	call   6e9 <printf>
            //Aquire lock and hold, then child will have lock, just show that the child stops the parent with lower priority 

            wait();
  87:	e8 f6 01 00 00       	call   282 <wait>
  8c:	83 c4 10             	add    $0x10,%esp
  8f:	eb cf                	jmp    60 <main+0x60>
        }else
        {
            //Create Child process
            printf(1, "Child %d created\n",getpid(), pid);
  91:	e8 64 02 00 00       	call   2fa <getpid>
  96:	53                   	push   %ebx
  97:	50                   	push   %eax
  98:	68 48 07 00 00       	push   $0x748
  9d:	6a 01                	push   $0x1
  9f:	e8 45 06 00 00       	call   6e9 <printf>
            for(y = 0; y < 400000; y+=1)
  a4:	83 c4 10             	add    $0x10,%esp
  a7:	b8 00 00 00 00       	mov    $0x0,%eax
  ac:	3d 7f 1a 06 00       	cmp    $0x61a7f,%eax
  b1:	7f 05                	jg     b8 <main+0xb8>
  b3:	83 c0 01             	add    $0x1,%eax
  b6:	eb f4                	jmp    ac <main+0xac>
	            b = b + 100 * 5; //Useless calculation to consume CPU Time
                break;
        }
    }
    exit();
  b8:	e8 bd 01 00 00       	call   27a <exit>

000000bd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  bd:	f3 0f 1e fb          	endbr32 
  c1:	55                   	push   %ebp
  c2:	89 e5                	mov    %esp,%ebp
  c4:	56                   	push   %esi
  c5:	53                   	push   %ebx
  c6:	8b 75 08             	mov    0x8(%ebp),%esi
  c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  cc:	89 f0                	mov    %esi,%eax
  ce:	89 d1                	mov    %edx,%ecx
  d0:	83 c2 01             	add    $0x1,%edx
  d3:	89 c3                	mov    %eax,%ebx
  d5:	83 c0 01             	add    $0x1,%eax
  d8:	0f b6 09             	movzbl (%ecx),%ecx
  db:	88 0b                	mov    %cl,(%ebx)
  dd:	84 c9                	test   %cl,%cl
  df:	75 ed                	jne    ce <strcpy+0x11>
    ;
  return os;
}
  e1:	89 f0                	mov    %esi,%eax
  e3:	5b                   	pop    %ebx
  e4:	5e                   	pop    %esi
  e5:	5d                   	pop    %ebp
  e6:	c3                   	ret    

000000e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e7:	f3 0f 1e fb          	endbr32 
  eb:	55                   	push   %ebp
  ec:	89 e5                	mov    %esp,%ebp
  ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  f4:	0f b6 01             	movzbl (%ecx),%eax
  f7:	84 c0                	test   %al,%al
  f9:	74 0c                	je     107 <strcmp+0x20>
  fb:	3a 02                	cmp    (%edx),%al
  fd:	75 08                	jne    107 <strcmp+0x20>
    p++, q++;
  ff:	83 c1 01             	add    $0x1,%ecx
 102:	83 c2 01             	add    $0x1,%edx
 105:	eb ed                	jmp    f4 <strcmp+0xd>
  return (uchar)*p - (uchar)*q;
 107:	0f b6 c0             	movzbl %al,%eax
 10a:	0f b6 12             	movzbl (%edx),%edx
 10d:	29 d0                	sub    %edx,%eax
}
 10f:	5d                   	pop    %ebp
 110:	c3                   	ret    

00000111 <strlen>:

uint
strlen(const char *s)
{
 111:	f3 0f 1e fb          	endbr32 
 115:	55                   	push   %ebp
 116:	89 e5                	mov    %esp,%ebp
 118:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 11b:	b8 00 00 00 00       	mov    $0x0,%eax
 120:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
 124:	74 05                	je     12b <strlen+0x1a>
 126:	83 c0 01             	add    $0x1,%eax
 129:	eb f5                	jmp    120 <strlen+0xf>
    ;
  return n;
}
 12b:	5d                   	pop    %ebp
 12c:	c3                   	ret    

0000012d <memset>:

void*
memset(void *dst, int c, uint n)
{
 12d:	f3 0f 1e fb          	endbr32 
 131:	55                   	push   %ebp
 132:	89 e5                	mov    %esp,%ebp
 134:	57                   	push   %edi
 135:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 138:	89 d7                	mov    %edx,%edi
 13a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 13d:	8b 45 0c             	mov    0xc(%ebp),%eax
 140:	fc                   	cld    
 141:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 143:	89 d0                	mov    %edx,%eax
 145:	5f                   	pop    %edi
 146:	5d                   	pop    %ebp
 147:	c3                   	ret    

00000148 <strchr>:

char*
strchr(const char *s, char c)
{
 148:	f3 0f 1e fb          	endbr32 
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	8b 45 08             	mov    0x8(%ebp),%eax
 152:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 156:	0f b6 10             	movzbl (%eax),%edx
 159:	84 d2                	test   %dl,%dl
 15b:	74 09                	je     166 <strchr+0x1e>
    if(*s == c)
 15d:	38 ca                	cmp    %cl,%dl
 15f:	74 0a                	je     16b <strchr+0x23>
  for(; *s; s++)
 161:	83 c0 01             	add    $0x1,%eax
 164:	eb f0                	jmp    156 <strchr+0xe>
      return (char*)s;
  return 0;
 166:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16b:	5d                   	pop    %ebp
 16c:	c3                   	ret    

0000016d <gets>:

char*
gets(char *buf, int max)
{
 16d:	f3 0f 1e fb          	endbr32 
 171:	55                   	push   %ebp
 172:	89 e5                	mov    %esp,%ebp
 174:	57                   	push   %edi
 175:	56                   	push   %esi
 176:	53                   	push   %ebx
 177:	83 ec 1c             	sub    $0x1c,%esp
 17a:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17d:	bb 00 00 00 00       	mov    $0x0,%ebx
 182:	89 de                	mov    %ebx,%esi
 184:	83 c3 01             	add    $0x1,%ebx
 187:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 18a:	7d 2e                	jge    1ba <gets+0x4d>
    cc = read(0, &c, 1);
 18c:	83 ec 04             	sub    $0x4,%esp
 18f:	6a 01                	push   $0x1
 191:	8d 45 e7             	lea    -0x19(%ebp),%eax
 194:	50                   	push   %eax
 195:	6a 00                	push   $0x0
 197:	e8 f6 00 00 00       	call   292 <read>
    if(cc < 1)
 19c:	83 c4 10             	add    $0x10,%esp
 19f:	85 c0                	test   %eax,%eax
 1a1:	7e 17                	jle    1ba <gets+0x4d>
      break;
    buf[i++] = c;
 1a3:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1a7:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 1aa:	3c 0a                	cmp    $0xa,%al
 1ac:	0f 94 c2             	sete   %dl
 1af:	3c 0d                	cmp    $0xd,%al
 1b1:	0f 94 c0             	sete   %al
 1b4:	08 c2                	or     %al,%dl
 1b6:	74 ca                	je     182 <gets+0x15>
    buf[i++] = c;
 1b8:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 1ba:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 1be:	89 f8                	mov    %edi,%eax
 1c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1c3:	5b                   	pop    %ebx
 1c4:	5e                   	pop    %esi
 1c5:	5f                   	pop    %edi
 1c6:	5d                   	pop    %ebp
 1c7:	c3                   	ret    

000001c8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c8:	f3 0f 1e fb          	endbr32 
 1cc:	55                   	push   %ebp
 1cd:	89 e5                	mov    %esp,%ebp
 1cf:	56                   	push   %esi
 1d0:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d1:	83 ec 08             	sub    $0x8,%esp
 1d4:	6a 00                	push   $0x0
 1d6:	ff 75 08             	pushl  0x8(%ebp)
 1d9:	e8 dc 00 00 00       	call   2ba <open>
  if(fd < 0)
 1de:	83 c4 10             	add    $0x10,%esp
 1e1:	85 c0                	test   %eax,%eax
 1e3:	78 24                	js     209 <stat+0x41>
 1e5:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1e7:	83 ec 08             	sub    $0x8,%esp
 1ea:	ff 75 0c             	pushl  0xc(%ebp)
 1ed:	50                   	push   %eax
 1ee:	e8 df 00 00 00       	call   2d2 <fstat>
 1f3:	89 c6                	mov    %eax,%esi
  close(fd);
 1f5:	89 1c 24             	mov    %ebx,(%esp)
 1f8:	e8 a5 00 00 00       	call   2a2 <close>
  return r;
 1fd:	83 c4 10             	add    $0x10,%esp
}
 200:	89 f0                	mov    %esi,%eax
 202:	8d 65 f8             	lea    -0x8(%ebp),%esp
 205:	5b                   	pop    %ebx
 206:	5e                   	pop    %esi
 207:	5d                   	pop    %ebp
 208:	c3                   	ret    
    return -1;
 209:	be ff ff ff ff       	mov    $0xffffffff,%esi
 20e:	eb f0                	jmp    200 <stat+0x38>

00000210 <atoi>:

int
atoi(const char *s)
{
 210:	f3 0f 1e fb          	endbr32 
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	53                   	push   %ebx
 218:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 21b:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 220:	0f b6 01             	movzbl (%ecx),%eax
 223:	8d 58 d0             	lea    -0x30(%eax),%ebx
 226:	80 fb 09             	cmp    $0x9,%bl
 229:	77 12                	ja     23d <atoi+0x2d>
    n = n*10 + *s++ - '0';
 22b:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
 22e:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
 231:	83 c1 01             	add    $0x1,%ecx
 234:	0f be c0             	movsbl %al,%eax
 237:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
 23b:	eb e3                	jmp    220 <atoi+0x10>
  return n;
}
 23d:	89 d0                	mov    %edx,%eax
 23f:	5b                   	pop    %ebx
 240:	5d                   	pop    %ebp
 241:	c3                   	ret    

00000242 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 242:	f3 0f 1e fb          	endbr32 
 246:	55                   	push   %ebp
 247:	89 e5                	mov    %esp,%ebp
 249:	56                   	push   %esi
 24a:	53                   	push   %ebx
 24b:	8b 75 08             	mov    0x8(%ebp),%esi
 24e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 251:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
 254:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
 256:	8d 58 ff             	lea    -0x1(%eax),%ebx
 259:	85 c0                	test   %eax,%eax
 25b:	7e 0f                	jle    26c <memmove+0x2a>
    *dst++ = *src++;
 25d:	0f b6 01             	movzbl (%ecx),%eax
 260:	88 02                	mov    %al,(%edx)
 262:	8d 49 01             	lea    0x1(%ecx),%ecx
 265:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
 268:	89 d8                	mov    %ebx,%eax
 26a:	eb ea                	jmp    256 <memmove+0x14>
  return vdst;
}
 26c:	89 f0                	mov    %esi,%eax
 26e:	5b                   	pop    %ebx
 26f:	5e                   	pop    %esi
 270:	5d                   	pop    %ebp
 271:	c3                   	ret    

00000272 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 272:	b8 01 00 00 00       	mov    $0x1,%eax
 277:	cd 40                	int    $0x40
 279:	c3                   	ret    

0000027a <exit>:
SYSCALL(exit)
 27a:	b8 02 00 00 00       	mov    $0x2,%eax
 27f:	cd 40                	int    $0x40
 281:	c3                   	ret    

00000282 <wait>:
SYSCALL(wait)
 282:	b8 03 00 00 00       	mov    $0x3,%eax
 287:	cd 40                	int    $0x40
 289:	c3                   	ret    

0000028a <pipe>:
SYSCALL(pipe)
 28a:	b8 04 00 00 00       	mov    $0x4,%eax
 28f:	cd 40                	int    $0x40
 291:	c3                   	ret    

00000292 <read>:
SYSCALL(read)
 292:	b8 05 00 00 00       	mov    $0x5,%eax
 297:	cd 40                	int    $0x40
 299:	c3                   	ret    

0000029a <write>:
SYSCALL(write)
 29a:	b8 10 00 00 00       	mov    $0x10,%eax
 29f:	cd 40                	int    $0x40
 2a1:	c3                   	ret    

000002a2 <close>:
SYSCALL(close)
 2a2:	b8 15 00 00 00       	mov    $0x15,%eax
 2a7:	cd 40                	int    $0x40
 2a9:	c3                   	ret    

000002aa <kill>:
SYSCALL(kill)
 2aa:	b8 06 00 00 00       	mov    $0x6,%eax
 2af:	cd 40                	int    $0x40
 2b1:	c3                   	ret    

000002b2 <exec>:
SYSCALL(exec)
 2b2:	b8 07 00 00 00       	mov    $0x7,%eax
 2b7:	cd 40                	int    $0x40
 2b9:	c3                   	ret    

000002ba <open>:
SYSCALL(open)
 2ba:	b8 0f 00 00 00       	mov    $0xf,%eax
 2bf:	cd 40                	int    $0x40
 2c1:	c3                   	ret    

000002c2 <mknod>:
SYSCALL(mknod)
 2c2:	b8 11 00 00 00       	mov    $0x11,%eax
 2c7:	cd 40                	int    $0x40
 2c9:	c3                   	ret    

000002ca <unlink>:
SYSCALL(unlink)
 2ca:	b8 12 00 00 00       	mov    $0x12,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <fstat>:
SYSCALL(fstat)
 2d2:	b8 08 00 00 00       	mov    $0x8,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <link>:
SYSCALL(link)
 2da:	b8 13 00 00 00       	mov    $0x13,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <mkdir>:
SYSCALL(mkdir)
 2e2:	b8 14 00 00 00       	mov    $0x14,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <chdir>:
SYSCALL(chdir)
 2ea:	b8 09 00 00 00       	mov    $0x9,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <dup>:
SYSCALL(dup)
 2f2:	b8 0a 00 00 00       	mov    $0xa,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <getpid>:
SYSCALL(getpid)
 2fa:	b8 0b 00 00 00       	mov    $0xb,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <sbrk>:
SYSCALL(sbrk)
 302:	b8 0c 00 00 00       	mov    $0xc,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <sleep>:
SYSCALL(sleep)
 30a:	b8 0d 00 00 00       	mov    $0xd,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <uptime>:
SYSCALL(uptime)
 312:	b8 0e 00 00 00       	mov    $0xe,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <yield>:
SYSCALL(yield)
 31a:	b8 16 00 00 00       	mov    $0x16,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <shutdown>:
SYSCALL(shutdown)
 322:	b8 17 00 00 00       	mov    $0x17,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <nice>:
SYSCALL(nice)
 32a:	b8 18 00 00 00       	mov    $0x18,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <cps>:
SYSCALL(cps)
 332:	b8 19 00 00 00       	mov    $0x19,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <s_sputc>:
  write(fd, &c, 1);
}

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
 33a:	f3 0f 1e fb          	endbr32 
 33e:	55                   	push   %ebp
 33f:	89 e5                	mov    %esp,%ebp
 341:	8b 45 14             	mov    0x14(%ebp),%eax
 344:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
 347:	3b 45 10             	cmp    0x10(%ebp),%eax
 34a:	73 06                	jae    352 <s_sputc+0x18>
  {
    outbuffer[index] = c;
 34c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 34f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
 352:	5d                   	pop    %ebp
 353:	c3                   	ret    

00000354 <s_getReverseDigits>:
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	57                   	push   %edi
 358:	56                   	push   %esi
 359:	53                   	push   %ebx
 35a:	83 ec 08             	sub    $0x8,%esp
 35d:	89 c6                	mov    %eax,%esi
 35f:	89 d3                	mov    %edx,%ebx
 361:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 364:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 368:	0f 95 c2             	setne  %dl
 36b:	89 c8                	mov    %ecx,%eax
 36d:	c1 e8 1f             	shr    $0x1f,%eax
 370:	84 c2                	test   %al,%dl
 372:	74 33                	je     3a7 <s_getReverseDigits+0x53>
    neg = 1;
    x = -xx;
 374:	89 c8                	mov    %ecx,%eax
 376:	f7 d8                	neg    %eax
    neg = 1;
 378:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 37f:	bf 00 00 00 00       	mov    $0x0,%edi
  while(i + 1 < length && x != 0) {
 384:	8d 4f 01             	lea    0x1(%edi),%ecx
 387:	89 ca                	mov    %ecx,%edx
 389:	39 d9                	cmp    %ebx,%ecx
 38b:	73 26                	jae    3b3 <s_getReverseDigits+0x5f>
 38d:	85 c0                	test   %eax,%eax
 38f:	74 22                	je     3b3 <s_getReverseDigits+0x5f>
    outbuf[i++] = digits[x % base];
 391:	ba 00 00 00 00       	mov    $0x0,%edx
 396:	f7 75 08             	divl   0x8(%ebp)
 399:	0f b6 92 64 07 00 00 	movzbl 0x764(%edx),%edx
 3a0:	88 14 3e             	mov    %dl,(%esi,%edi,1)
 3a3:	89 cf                	mov    %ecx,%edi
 3a5:	eb dd                	jmp    384 <s_getReverseDigits+0x30>
    x = xx;
 3a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  neg = 0;
 3aa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 3b1:	eb cc                	jmp    37f <s_getReverseDigits+0x2b>
    x /= base;
  }

  if(0 == xx && i + 1 < length) {
 3b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3b7:	75 0a                	jne    3c3 <s_getReverseDigits+0x6f>
 3b9:	39 da                	cmp    %ebx,%edx
 3bb:	73 06                	jae    3c3 <s_getReverseDigits+0x6f>
    outbuf[i++] = digits[0];   
 3bd:	c6 04 3e 30          	movb   $0x30,(%esi,%edi,1)
 3c1:	89 cf                	mov    %ecx,%edi
  }

  if(neg && i < length) {
 3c3:	89 fa                	mov    %edi,%edx
 3c5:	39 df                	cmp    %ebx,%edi
 3c7:	0f 92 c0             	setb   %al
 3ca:	84 45 ec             	test   %al,-0x14(%ebp)
 3cd:	74 07                	je     3d6 <s_getReverseDigits+0x82>
    outbuf[i++] = '-';
 3cf:	83 c7 01             	add    $0x1,%edi
 3d2:	c6 04 16 2d          	movb   $0x2d,(%esi,%edx,1)
  }

  return i;
}
 3d6:	89 f8                	mov    %edi,%eax
 3d8:	83 c4 08             	add    $0x8,%esp
 3db:	5b                   	pop    %ebx
 3dc:	5e                   	pop    %esi
 3dd:	5f                   	pop    %edi
 3de:	5d                   	pop    %ebp
 3df:	c3                   	ret    

000003e0 <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
 3e0:	39 c2                	cmp    %eax,%edx
 3e2:	0f 46 c2             	cmovbe %edx,%eax
}
 3e5:	c3                   	ret    

000003e6 <s_printint>:
{
 3e6:	55                   	push   %ebp
 3e7:	89 e5                	mov    %esp,%ebp
 3e9:	57                   	push   %edi
 3ea:	56                   	push   %esi
 3eb:	53                   	push   %ebx
 3ec:	83 ec 2c             	sub    $0x2c,%esp
 3ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 3f2:	89 55 d0             	mov    %edx,-0x30(%ebp)
 3f5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
 3f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);
 3fb:	ff 75 14             	pushl  0x14(%ebp)
 3fe:	ff 75 10             	pushl  0x10(%ebp)
 401:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 404:	ba 10 00 00 00       	mov    $0x10,%edx
 409:	8d 45 d8             	lea    -0x28(%ebp),%eax
 40c:	e8 43 ff ff ff       	call   354 <s_getReverseDigits>
 411:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
 414:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
 416:	83 c4 08             	add    $0x8,%esp
  int j = 0;
 419:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
 41e:	83 eb 01             	sub    $0x1,%ebx
 421:	78 22                	js     445 <s_printint+0x5f>
 423:	39 fe                	cmp    %edi,%esi
 425:	73 1e                	jae    445 <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
 427:	83 ec 0c             	sub    $0xc,%esp
 42a:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
 42f:	50                   	push   %eax
 430:	56                   	push   %esi
 431:	57                   	push   %edi
 432:	ff 75 cc             	pushl  -0x34(%ebp)
 435:	ff 75 d0             	pushl  -0x30(%ebp)
 438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
 43b:	ff d0                	call   *%eax
    j++;
 43d:	83 c6 01             	add    $0x1,%esi
 440:	83 c4 20             	add    $0x20,%esp
 443:	eb d9                	jmp    41e <s_printint+0x38>
}
 445:	8b 45 c8             	mov    -0x38(%ebp),%eax
 448:	8d 65 f4             	lea    -0xc(%ebp),%esp
 44b:	5b                   	pop    %ebx
 44c:	5e                   	pop    %esi
 44d:	5f                   	pop    %edi
 44e:	5d                   	pop    %ebp
 44f:	c3                   	ret    

00000450 <s_printf>:

static 
int s_printf(putFunction_t putcFunction, int fd, char *outbuffer, int n, const char *fmt, uint* ap)
{
 450:	55                   	push   %ebp
 451:	89 e5                	mov    %esp,%ebp
 453:	57                   	push   %edi
 454:	56                   	push   %esi
 455:	53                   	push   %ebx
 456:	83 ec 2c             	sub    $0x2c,%esp
 459:	89 45 d8             	mov    %eax,-0x28(%ebp)
 45c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 45f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  char *s;
  int c, i, state;
  uint outindex = 0;
  const int length = n -1; // leave room for nul termination
 462:	8b 45 08             	mov    0x8(%ebp),%eax
 465:	8d 78 ff             	lea    -0x1(%eax),%edi

  state = 0;
 468:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
 46f:	bb 00 00 00 00       	mov    $0x0,%ebx
 474:	89 f8                	mov    %edi,%eax
 476:	89 df                	mov    %ebx,%edi
 478:	89 c6                	mov    %eax,%esi
 47a:	eb 20                	jmp    49c <s_printf+0x4c>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%') {
        state = '%';
      } else {
        putcFunction(fd, outbuffer, length, outindex++, c);
 47c:	8d 43 01             	lea    0x1(%ebx),%eax
 47f:	89 45 e0             	mov    %eax,-0x20(%ebp)
 482:	83 ec 0c             	sub    $0xc,%esp
 485:	51                   	push   %ecx
 486:	53                   	push   %ebx
 487:	56                   	push   %esi
 488:	ff 75 d0             	pushl  -0x30(%ebp)
 48b:	ff 75 d4             	pushl  -0x2c(%ebp)
 48e:	8b 55 d8             	mov    -0x28(%ebp),%edx
 491:	ff d2                	call   *%edx
 493:	83 c4 20             	add    $0x20,%esp
 496:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
 499:	83 c7 01             	add    $0x1,%edi
 49c:	8b 45 0c             	mov    0xc(%ebp),%eax
 49f:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
 4a3:	84 c0                	test   %al,%al
 4a5:	0f 84 cd 01 00 00    	je     678 <s_printf+0x228>
 4ab:	89 75 e0             	mov    %esi,-0x20(%ebp)
 4ae:	39 de                	cmp    %ebx,%esi
 4b0:	0f 86 c2 01 00 00    	jbe    678 <s_printf+0x228>
    c = fmt[i] & 0xff;
 4b6:	0f be c8             	movsbl %al,%ecx
 4b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
 4bc:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 4bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 4c3:	75 0a                	jne    4cf <s_printf+0x7f>
      if(c == '%') {
 4c5:	83 f8 25             	cmp    $0x25,%eax
 4c8:	75 b2                	jne    47c <s_printf+0x2c>
        state = '%';
 4ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 4cd:	eb ca                	jmp    499 <s_printf+0x49>
      }
    } else if(state == '%'){
 4cf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4d3:	75 c4                	jne    499 <s_printf+0x49>
      if(c == 'd'){
 4d5:	83 f8 64             	cmp    $0x64,%eax
 4d8:	74 6e                	je     548 <s_printf+0xf8>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 4da:	83 f8 78             	cmp    $0x78,%eax
 4dd:	0f 94 c1             	sete   %cl
 4e0:	83 f8 70             	cmp    $0x70,%eax
 4e3:	0f 94 c2             	sete   %dl
 4e6:	08 d1                	or     %dl,%cl
 4e8:	0f 85 8e 00 00 00    	jne    57c <s_printf+0x12c>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 4ee:	83 f8 73             	cmp    $0x73,%eax
 4f1:	0f 84 b9 00 00 00    	je     5b0 <s_printf+0x160>
          s = "(null)";
        while(*s != 0){
          putcFunction(fd, outbuffer, length, outindex++, *s);
          s++;
        }
      } else if(c == 'c'){
 4f7:	83 f8 63             	cmp    $0x63,%eax
 4fa:	0f 84 1a 01 00 00    	je     61a <s_printf+0x1ca>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
        ap++;
      } else if(c == '%'){
 500:	83 f8 25             	cmp    $0x25,%eax
 503:	0f 84 44 01 00 00    	je     64d <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putcFunction(fd, outbuffer, length, outindex++, '%');
 509:	8d 43 01             	lea    0x1(%ebx),%eax
 50c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 50f:	83 ec 0c             	sub    $0xc,%esp
 512:	6a 25                	push   $0x25
 514:	53                   	push   %ebx
 515:	56                   	push   %esi
 516:	ff 75 d0             	pushl  -0x30(%ebp)
 519:	ff 75 d4             	pushl  -0x2c(%ebp)
 51c:	8b 45 d8             	mov    -0x28(%ebp),%eax
 51f:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
 521:	83 c3 02             	add    $0x2,%ebx
 524:	83 c4 14             	add    $0x14,%esp
 527:	ff 75 dc             	pushl  -0x24(%ebp)
 52a:	ff 75 e4             	pushl  -0x1c(%ebp)
 52d:	56                   	push   %esi
 52e:	ff 75 d0             	pushl  -0x30(%ebp)
 531:	ff 75 d4             	pushl  -0x2c(%ebp)
 534:	8b 45 d8             	mov    -0x28(%ebp),%eax
 537:	ff d0                	call   *%eax
 539:	83 c4 20             	add    $0x20,%esp
      }
      state = 0;
 53c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 543:	e9 51 ff ff ff       	jmp    499 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
 548:	8b 45 d0             	mov    -0x30(%ebp),%eax
 54b:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 54e:	6a 01                	push   $0x1
 550:	6a 0a                	push   $0xa
 552:	8b 45 10             	mov    0x10(%ebp),%eax
 555:	ff 30                	pushl  (%eax)
 557:	89 f0                	mov    %esi,%eax
 559:	29 d8                	sub    %ebx,%eax
 55b:	50                   	push   %eax
 55c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 55f:	8b 45 d8             	mov    -0x28(%ebp),%eax
 562:	e8 7f fe ff ff       	call   3e6 <s_printint>
 567:	01 c3                	add    %eax,%ebx
        ap++;
 569:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 56d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 570:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 577:	e9 1d ff ff ff       	jmp    499 <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
 57c:	8b 45 d0             	mov    -0x30(%ebp),%eax
 57f:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
 582:	6a 00                	push   $0x0
 584:	6a 10                	push   $0x10
 586:	8b 45 10             	mov    0x10(%ebp),%eax
 589:	ff 30                	pushl  (%eax)
 58b:	89 f0                	mov    %esi,%eax
 58d:	29 d8                	sub    %ebx,%eax
 58f:	50                   	push   %eax
 590:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 593:	8b 45 d8             	mov    -0x28(%ebp),%eax
 596:	e8 4b fe ff ff       	call   3e6 <s_printint>
 59b:	01 c3                	add    %eax,%ebx
        ap++;
 59d:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 5a1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 5ab:	e9 e9 fe ff ff       	jmp    499 <s_printf+0x49>
        s = (char*)*ap;
 5b0:	8b 45 10             	mov    0x10(%ebp),%eax
 5b3:	8b 00                	mov    (%eax),%eax
        ap++;
 5b5:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
 5b9:	85 c0                	test   %eax,%eax
 5bb:	75 4e                	jne    60b <s_printf+0x1bb>
          s = "(null)";
 5bd:	b8 5a 07 00 00       	mov    $0x75a,%eax
 5c2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5c5:	89 da                	mov    %ebx,%edx
 5c7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 5ca:	89 75 e0             	mov    %esi,-0x20(%ebp)
 5cd:	89 c6                	mov    %eax,%esi
 5cf:	eb 1f                	jmp    5f0 <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
 5d1:	8d 7a 01             	lea    0x1(%edx),%edi
 5d4:	83 ec 0c             	sub    $0xc,%esp
 5d7:	0f be c0             	movsbl %al,%eax
 5da:	50                   	push   %eax
 5db:	52                   	push   %edx
 5dc:	53                   	push   %ebx
 5dd:	ff 75 d0             	pushl  -0x30(%ebp)
 5e0:	ff 75 d4             	pushl  -0x2c(%ebp)
 5e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
 5e6:	ff d0                	call   *%eax
          s++;
 5e8:	83 c6 01             	add    $0x1,%esi
 5eb:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
 5ee:	89 fa                	mov    %edi,%edx
        while(*s != 0){
 5f0:	0f b6 06             	movzbl (%esi),%eax
 5f3:	84 c0                	test   %al,%al
 5f5:	75 da                	jne    5d1 <s_printf+0x181>
 5f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5fa:	89 d3                	mov    %edx,%ebx
 5fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
 5ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 606:	e9 8e fe ff ff       	jmp    499 <s_printf+0x49>
 60b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 60e:	89 da                	mov    %ebx,%edx
 610:	8b 5d e0             	mov    -0x20(%ebp),%ebx
 613:	89 75 e0             	mov    %esi,-0x20(%ebp)
 616:	89 c6                	mov    %eax,%esi
 618:	eb d6                	jmp    5f0 <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 61a:	8d 43 01             	lea    0x1(%ebx),%eax
 61d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 620:	83 ec 0c             	sub    $0xc,%esp
 623:	8b 55 10             	mov    0x10(%ebp),%edx
 626:	0f be 02             	movsbl (%edx),%eax
 629:	50                   	push   %eax
 62a:	53                   	push   %ebx
 62b:	56                   	push   %esi
 62c:	ff 75 d0             	pushl  -0x30(%ebp)
 62f:	ff 75 d4             	pushl  -0x2c(%ebp)
 632:	8b 55 d8             	mov    -0x28(%ebp),%edx
 635:	ff d2                	call   *%edx
        ap++;
 637:	83 45 10 04          	addl   $0x4,0x10(%ebp)
 63b:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
 63e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 641:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 648:	e9 4c fe ff ff       	jmp    499 <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
 64d:	8d 43 01             	lea    0x1(%ebx),%eax
 650:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 653:	83 ec 0c             	sub    $0xc,%esp
 656:	ff 75 dc             	pushl  -0x24(%ebp)
 659:	53                   	push   %ebx
 65a:	56                   	push   %esi
 65b:	ff 75 d0             	pushl  -0x30(%ebp)
 65e:	ff 75 d4             	pushl  -0x2c(%ebp)
 661:	8b 55 d8             	mov    -0x28(%ebp),%edx
 664:	ff d2                	call   *%edx
 666:	83 c4 20             	add    $0x20,%esp
 669:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
 66c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 673:	e9 21 fe ff ff       	jmp    499 <s_printf+0x49>
    }
  }
  
  return s_min(length, outindex);
 678:	89 da                	mov    %ebx,%edx
 67a:	89 f0                	mov    %esi,%eax
 67c:	e8 5f fd ff ff       	call   3e0 <s_min>
}
 681:	8d 65 f4             	lea    -0xc(%ebp),%esp
 684:	5b                   	pop    %ebx
 685:	5e                   	pop    %esi
 686:	5f                   	pop    %edi
 687:	5d                   	pop    %ebp
 688:	c3                   	ret    

00000689 <s_putc>:
{
 689:	f3 0f 1e fb          	endbr32 
 68d:	55                   	push   %ebp
 68e:	89 e5                	mov    %esp,%ebp
 690:	83 ec 1c             	sub    $0x1c,%esp
 693:	8b 45 18             	mov    0x18(%ebp),%eax
 696:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 699:	6a 01                	push   $0x1
 69b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 69e:	50                   	push   %eax
 69f:	ff 75 08             	pushl  0x8(%ebp)
 6a2:	e8 f3 fb ff ff       	call   29a <write>
}
 6a7:	83 c4 10             	add    $0x10,%esp
 6aa:	c9                   	leave  
 6ab:	c3                   	ret    

000006ac <snprintf>:
// Print into outbuffer at most n characters. Only understands %d, %x, %p, %s.
// If n is greater than 0, a terminating nul is always stored in outbuffer.
// \return the number of characters written to outbuffer not counting the
// terminating nul.
int snprintf(char *outbuffer, int n, const char *fmt, ...)
{
 6ac:	f3 0f 1e fb          	endbr32 
 6b0:	55                   	push   %ebp
 6b1:	89 e5                	mov    %esp,%ebp
 6b3:	56                   	push   %esi
 6b4:	53                   	push   %ebx
 6b5:	8b 75 08             	mov    0x8(%ebp),%esi
 6b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  uint* ap = (uint*)(void*)&fmt + 1;
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
 6bb:	83 ec 04             	sub    $0x4,%esp
 6be:	8d 45 14             	lea    0x14(%ebp),%eax
 6c1:	50                   	push   %eax
 6c2:	ff 75 10             	pushl  0x10(%ebp)
 6c5:	53                   	push   %ebx
 6c6:	89 f1                	mov    %esi,%ecx
 6c8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
 6cd:	b8 3a 03 00 00       	mov    $0x33a,%eax
 6d2:	e8 79 fd ff ff       	call   450 <s_printf>
  if(count < n) {
 6d7:	83 c4 10             	add    $0x10,%esp
 6da:	39 c3                	cmp    %eax,%ebx
 6dc:	76 04                	jbe    6e2 <snprintf+0x36>
    outbuffer[count] = 0; // Assure nul termination
 6de:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
  } 

  return count;
}
 6e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
 6e5:	5b                   	pop    %ebx
 6e6:	5e                   	pop    %esi
 6e7:	5d                   	pop    %ebp
 6e8:	c3                   	ret    

000006e9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 6e9:	f3 0f 1e fb          	endbr32 
 6ed:	55                   	push   %ebp
 6ee:	89 e5                	mov    %esp,%ebp
 6f0:	83 ec 0c             	sub    $0xc,%esp
  static const uint veryLarge = 1<<30;
  uint* ap = (uint*)(void*)&fmt + 1;
  s_printf(s_putc, fd, 0, veryLarge, fmt, ap);
 6f3:	8d 45 10             	lea    0x10(%ebp),%eax
 6f6:	50                   	push   %eax
 6f7:	ff 75 0c             	pushl  0xc(%ebp)
 6fa:	68 00 00 00 40       	push   $0x40000000
 6ff:	b9 00 00 00 00       	mov    $0x0,%ecx
 704:	8b 55 08             	mov    0x8(%ebp),%edx
 707:	b8 89 06 00 00       	mov    $0x689,%eax
 70c:	e8 3f fd ff ff       	call   450 <s_printf>
 711:	83 c4 10             	add    $0x10,%esp
 714:	c9                   	leave  
 715:	c3                   	ret    
