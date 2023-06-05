
_newPipe:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, const char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	53                   	push   %ebx
  12:	51                   	push   %ecx
  13:	83 ec 1c             	sub    $0x1c,%esp
  16:	8b 59 04             	mov    0x4(%ecx),%ebx
    int p[2];
    pipe(p);
  19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1c:	50                   	push   %eax
  1d:	e8 85 00 00 00       	call   a7 <pipe>
    
    if(fork() == 0) {
  22:	e8 68 00 00 00       	call   8f <fork>
  27:	83 c4 10             	add    $0x10,%esp
  2a:	85 c0                	test   %eax,%eax
  2c:	75 41                	jne    6f <main+0x6f>
        //Child Process
        close(0);
  2e:	83 ec 0c             	sub    $0xc,%esp
  31:	6a 00                	push   $0x0
  33:	e8 87 00 00 00       	call   bf <close>
        dup(p[0]);
  38:	83 c4 04             	add    $0x4,%esp
  3b:	ff 75 f0             	pushl  -0x10(%ebp)
  3e:	e8 cc 00 00 00       	call   10f <dup>
        close(p[0]);
  43:	83 c4 04             	add    $0x4,%esp
  46:	ff 75 f0             	pushl  -0x10(%ebp)
  49:	e8 71 00 00 00       	call   bf <close>
        close(p[1]);
  4e:	83 c4 04             	add    $0x4,%esp
  51:	ff 75 f4             	pushl  -0xc(%ebp)
  54:	e8 66 00 00 00       	call   bf <close>
        exec("wc", (char ** const)argv);
  59:	83 c4 08             	add    $0x8,%esp
  5c:	53                   	push   %ebx
  5d:	68 57 01 00 00       	push   $0x157
  62:	e8 68 00 00 00       	call   cf <exec>
  67:	83 c4 10             	add    $0x10,%esp
        //Parent Process
        close(p[0]);
        close(p[1]);
        wait();     // wait for child process to finish
    }
    exit();
  6a:	e8 28 00 00 00       	call   97 <exit>
        close(p[0]);
  6f:	83 ec 0c             	sub    $0xc,%esp
  72:	ff 75 f0             	pushl  -0x10(%ebp)
  75:	e8 45 00 00 00       	call   bf <close>
        close(p[1]);
  7a:	83 c4 04             	add    $0x4,%esp
  7d:	ff 75 f4             	pushl  -0xc(%ebp)
  80:	e8 3a 00 00 00       	call   bf <close>
        wait();     // wait for child process to finish
  85:	e8 15 00 00 00       	call   9f <wait>
  8a:	83 c4 10             	add    $0x10,%esp
  8d:	eb db                	jmp    6a <main+0x6a>

0000008f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  8f:	b8 01 00 00 00       	mov    $0x1,%eax
  94:	cd 40                	int    $0x40
  96:	c3                   	ret    

00000097 <exit>:
SYSCALL(exit)
  97:	b8 02 00 00 00       	mov    $0x2,%eax
  9c:	cd 40                	int    $0x40
  9e:	c3                   	ret    

0000009f <wait>:
SYSCALL(wait)
  9f:	b8 03 00 00 00       	mov    $0x3,%eax
  a4:	cd 40                	int    $0x40
  a6:	c3                   	ret    

000000a7 <pipe>:
SYSCALL(pipe)
  a7:	b8 04 00 00 00       	mov    $0x4,%eax
  ac:	cd 40                	int    $0x40
  ae:	c3                   	ret    

000000af <read>:
SYSCALL(read)
  af:	b8 05 00 00 00       	mov    $0x5,%eax
  b4:	cd 40                	int    $0x40
  b6:	c3                   	ret    

000000b7 <write>:
SYSCALL(write)
  b7:	b8 10 00 00 00       	mov    $0x10,%eax
  bc:	cd 40                	int    $0x40
  be:	c3                   	ret    

000000bf <close>:
SYSCALL(close)
  bf:	b8 15 00 00 00       	mov    $0x15,%eax
  c4:	cd 40                	int    $0x40
  c6:	c3                   	ret    

000000c7 <kill>:
SYSCALL(kill)
  c7:	b8 06 00 00 00       	mov    $0x6,%eax
  cc:	cd 40                	int    $0x40
  ce:	c3                   	ret    

000000cf <exec>:
SYSCALL(exec)
  cf:	b8 07 00 00 00       	mov    $0x7,%eax
  d4:	cd 40                	int    $0x40
  d6:	c3                   	ret    

000000d7 <open>:
SYSCALL(open)
  d7:	b8 0f 00 00 00       	mov    $0xf,%eax
  dc:	cd 40                	int    $0x40
  de:	c3                   	ret    

000000df <mknod>:
SYSCALL(mknod)
  df:	b8 11 00 00 00       	mov    $0x11,%eax
  e4:	cd 40                	int    $0x40
  e6:	c3                   	ret    

000000e7 <unlink>:
SYSCALL(unlink)
  e7:	b8 12 00 00 00       	mov    $0x12,%eax
  ec:	cd 40                	int    $0x40
  ee:	c3                   	ret    

000000ef <fstat>:
SYSCALL(fstat)
  ef:	b8 08 00 00 00       	mov    $0x8,%eax
  f4:	cd 40                	int    $0x40
  f6:	c3                   	ret    

000000f7 <link>:
SYSCALL(link)
  f7:	b8 13 00 00 00       	mov    $0x13,%eax
  fc:	cd 40                	int    $0x40
  fe:	c3                   	ret    

000000ff <mkdir>:
SYSCALL(mkdir)
  ff:	b8 14 00 00 00       	mov    $0x14,%eax
 104:	cd 40                	int    $0x40
 106:	c3                   	ret    

00000107 <chdir>:
SYSCALL(chdir)
 107:	b8 09 00 00 00       	mov    $0x9,%eax
 10c:	cd 40                	int    $0x40
 10e:	c3                   	ret    

0000010f <dup>:
SYSCALL(dup)
 10f:	b8 0a 00 00 00       	mov    $0xa,%eax
 114:	cd 40                	int    $0x40
 116:	c3                   	ret    

00000117 <getpid>:
SYSCALL(getpid)
 117:	b8 0b 00 00 00       	mov    $0xb,%eax
 11c:	cd 40                	int    $0x40
 11e:	c3                   	ret    

0000011f <sbrk>:
SYSCALL(sbrk)
 11f:	b8 0c 00 00 00       	mov    $0xc,%eax
 124:	cd 40                	int    $0x40
 126:	c3                   	ret    

00000127 <sleep>:
SYSCALL(sleep)
 127:	b8 0d 00 00 00       	mov    $0xd,%eax
 12c:	cd 40                	int    $0x40
 12e:	c3                   	ret    

0000012f <uptime>:
SYSCALL(uptime)
 12f:	b8 0e 00 00 00       	mov    $0xe,%eax
 134:	cd 40                	int    $0x40
 136:	c3                   	ret    

00000137 <yield>:
SYSCALL(yield)
 137:	b8 16 00 00 00       	mov    $0x16,%eax
 13c:	cd 40                	int    $0x40
 13e:	c3                   	ret    

0000013f <shutdown>:
SYSCALL(shutdown)
 13f:	b8 17 00 00 00       	mov    $0x17,%eax
 144:	cd 40                	int    $0x40
 146:	c3                   	ret    

00000147 <nice>:
SYSCALL(nice)
 147:	b8 18 00 00 00       	mov    $0x18,%eax
 14c:	cd 40                	int    $0x40
 14e:	c3                   	ret    

0000014f <cps>:
SYSCALL(cps)
 14f:	b8 19 00 00 00       	mov    $0x19,%eax
 154:	cd 40                	int    $0x40
 156:	c3                   	ret    
