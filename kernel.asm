
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 b5 10 80       	mov    $0x8010b5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 6b 2b 10 80       	mov    $0x80102b6b,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 c0 b5 10 80       	push   $0x8010b5c0
80100046:	e8 42 3e 00 00       	call   80103e8d <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 10 fd 10 80    	mov    0x8010fd10,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 c0 b5 10 80       	push   $0x8010b5c0
8010007c:	e8 75 3e 00 00       	call   80103ef6 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 cd 3b 00 00       	call   80103c59 <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 0c fd 10 80    	mov    0x8010fd0c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 c0 b5 10 80       	push   $0x8010b5c0
801000ca:	e8 27 3e 00 00       	call   80103ef6 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 7f 3b 00 00       	call   80103c59 <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 40 6e 10 80       	push   $0x80106e40
801000ef:	e8 68 02 00 00       	call   8010035c <panic>

801000f4 <binit>:
{
801000f4:	f3 0f 1e fb          	endbr32 
801000f8:	55                   	push   %ebp
801000f9:	89 e5                	mov    %esp,%ebp
801000fb:	53                   	push   %ebx
801000fc:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000ff:	68 51 6e 10 80       	push   $0x80106e51
80100104:	68 c0 b5 10 80       	push   $0x8010b5c0
80100109:	e8 2f 3c 00 00       	call   80103d3d <initlock>
  bcache.head.prev = &bcache.head;
8010010e:	c7 05 0c fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd0c
80100115:	fc 10 80 
  bcache.head.next = &bcache.head;
80100118:	c7 05 10 fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd10
8010011f:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100122:	83 c4 10             	add    $0x10,%esp
80100125:	bb f4 b5 10 80       	mov    $0x8010b5f4,%ebx
8010012a:	eb 37                	jmp    80100163 <binit+0x6f>
    b->next = bcache.head.next;
8010012c:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100131:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100134:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
8010013b:	83 ec 08             	sub    $0x8,%esp
8010013e:	68 58 6e 10 80       	push   $0x80106e58
80100143:	8d 43 0c             	lea    0xc(%ebx),%eax
80100146:	50                   	push   %eax
80100147:	e8 d6 3a 00 00       	call   80103c22 <initsleeplock>
    bcache.head.next->prev = b;
8010014c:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100151:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100154:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010015a:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
80100160:	83 c4 10             	add    $0x10,%esp
80100163:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
80100169:	72 c1                	jb     8010012c <binit+0x38>
}
8010016b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016e:	c9                   	leave  
8010016f:	c3                   	ret    

80100170 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100170:	f3 0f 1e fb          	endbr32 
80100174:	55                   	push   %ebp
80100175:	89 e5                	mov    %esp,%ebp
80100177:	53                   	push   %ebx
80100178:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
8010017b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010017e:	8b 45 08             	mov    0x8(%ebp),%eax
80100181:	e8 ae fe ff ff       	call   80100034 <bget>
80100186:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100188:	f6 00 02             	testb  $0x2,(%eax)
8010018b:	74 07                	je     80100194 <bread+0x24>
    iderw(b);
  }
  return b;
}
8010018d:	89 d8                	mov    %ebx,%eax
8010018f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100192:	c9                   	leave  
80100193:	c3                   	ret    
    iderw(b);
80100194:	83 ec 0c             	sub    $0xc,%esp
80100197:	50                   	push   %eax
80100198:	e8 f3 1c 00 00       	call   80101e90 <iderw>
8010019d:	83 c4 10             	add    $0x10,%esp
  return b;
801001a0:	eb eb                	jmp    8010018d <bread+0x1d>

801001a2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001a2:	f3 0f 1e fb          	endbr32 
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	53                   	push   %ebx
801001aa:	83 ec 10             	sub    $0x10,%esp
801001ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001b0:	8d 43 0c             	lea    0xc(%ebx),%eax
801001b3:	50                   	push   %eax
801001b4:	e8 32 3b 00 00       	call   80103ceb <holdingsleep>
801001b9:	83 c4 10             	add    $0x10,%esp
801001bc:	85 c0                	test   %eax,%eax
801001be:	74 14                	je     801001d4 <bwrite+0x32>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001c0:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001c3:	83 ec 0c             	sub    $0xc,%esp
801001c6:	53                   	push   %ebx
801001c7:	e8 c4 1c 00 00       	call   80101e90 <iderw>
}
801001cc:	83 c4 10             	add    $0x10,%esp
801001cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001d2:	c9                   	leave  
801001d3:	c3                   	ret    
    panic("bwrite");
801001d4:	83 ec 0c             	sub    $0xc,%esp
801001d7:	68 5f 6e 10 80       	push   $0x80106e5f
801001dc:	e8 7b 01 00 00       	call   8010035c <panic>

801001e1 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001e1:	f3 0f 1e fb          	endbr32 
801001e5:	55                   	push   %ebp
801001e6:	89 e5                	mov    %esp,%ebp
801001e8:	56                   	push   %esi
801001e9:	53                   	push   %ebx
801001ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001ed:	8d 73 0c             	lea    0xc(%ebx),%esi
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 f2 3a 00 00       	call   80103ceb <holdingsleep>
801001f9:	83 c4 10             	add    $0x10,%esp
801001fc:	85 c0                	test   %eax,%eax
801001fe:	74 6b                	je     8010026b <brelse+0x8a>
    panic("brelse");

  releasesleep(&b->lock);
80100200:	83 ec 0c             	sub    $0xc,%esp
80100203:	56                   	push   %esi
80100204:	e8 a3 3a 00 00       	call   80103cac <releasesleep>

  acquire(&bcache.lock);
80100209:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100210:	e8 78 3c 00 00       	call   80103e8d <acquire>
  b->refcnt--;
80100215:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100218:	83 e8 01             	sub    $0x1,%eax
8010021b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010021e:	83 c4 10             	add    $0x10,%esp
80100221:	85 c0                	test   %eax,%eax
80100223:	75 2f                	jne    80100254 <brelse+0x73>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100225:	8b 43 54             	mov    0x54(%ebx),%eax
80100228:	8b 53 50             	mov    0x50(%ebx),%edx
8010022b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010022e:	8b 43 50             	mov    0x50(%ebx),%eax
80100231:	8b 53 54             	mov    0x54(%ebx),%edx
80100234:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100237:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010023c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010023f:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    bcache.head.next->prev = b;
80100246:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010024b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010024e:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  }
  
  release(&bcache.lock);
80100254:	83 ec 0c             	sub    $0xc,%esp
80100257:	68 c0 b5 10 80       	push   $0x8010b5c0
8010025c:	e8 95 3c 00 00       	call   80103ef6 <release>
}
80100261:	83 c4 10             	add    $0x10,%esp
80100264:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100267:	5b                   	pop    %ebx
80100268:	5e                   	pop    %esi
80100269:	5d                   	pop    %ebp
8010026a:	c3                   	ret    
    panic("brelse");
8010026b:	83 ec 0c             	sub    $0xc,%esp
8010026e:	68 66 6e 10 80       	push   $0x80106e66
80100273:	e8 e4 00 00 00       	call   8010035c <panic>

80100278 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100278:	f3 0f 1e fb          	endbr32 
8010027c:	55                   	push   %ebp
8010027d:	89 e5                	mov    %esp,%ebp
8010027f:	57                   	push   %edi
80100280:	56                   	push   %esi
80100281:	53                   	push   %ebx
80100282:	83 ec 28             	sub    $0x28,%esp
80100285:	8b 7d 08             	mov    0x8(%ebp),%edi
80100288:	8b 75 0c             	mov    0xc(%ebp),%esi
8010028b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010028e:	57                   	push   %edi
8010028f:	e8 03 14 00 00       	call   80101697 <iunlock>
  target = n;
80100294:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100297:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010029e:	e8 ea 3b 00 00       	call   80103e8d <acquire>
  while(n > 0){
801002a3:	83 c4 10             	add    $0x10,%esp
801002a6:	85 db                	test   %ebx,%ebx
801002a8:	0f 8e 8f 00 00 00    	jle    8010033d <consoleread+0xc5>
    while(input.r == input.w){
801002ae:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801002b3:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002b9:	75 47                	jne    80100302 <consoleread+0x8a>
      if(myproc()->killed){
801002bb:	e8 bb 30 00 00       	call   8010337b <myproc>
801002c0:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002c4:	75 17                	jne    801002dd <consoleread+0x65>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002c6:	83 ec 08             	sub    $0x8,%esp
801002c9:	68 20 a5 10 80       	push   $0x8010a520
801002ce:	68 a0 ff 10 80       	push   $0x8010ffa0
801002d3:	e8 8e 35 00 00       	call   80103866 <sleep>
801002d8:	83 c4 10             	add    $0x10,%esp
801002db:	eb d1                	jmp    801002ae <consoleread+0x36>
        release(&cons.lock);
801002dd:	83 ec 0c             	sub    $0xc,%esp
801002e0:	68 20 a5 10 80       	push   $0x8010a520
801002e5:	e8 0c 3c 00 00       	call   80103ef6 <release>
        ilock(ip);
801002ea:	89 3c 24             	mov    %edi,(%esp)
801002ed:	e8 df 12 00 00       	call   801015d1 <ilock>
        return -1;
801002f2:	83 c4 10             	add    $0x10,%esp
801002f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002fd:	5b                   	pop    %ebx
801002fe:	5e                   	pop    %esi
801002ff:	5f                   	pop    %edi
80100300:	5d                   	pop    %ebp
80100301:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
80100302:	8d 50 01             	lea    0x1(%eax),%edx
80100305:	89 15 a0 ff 10 80    	mov    %edx,0x8010ffa0
8010030b:	89 c2                	mov    %eax,%edx
8010030d:	83 e2 7f             	and    $0x7f,%edx
80100310:	0f b6 92 20 ff 10 80 	movzbl -0x7fef00e0(%edx),%edx
80100317:	0f be ca             	movsbl %dl,%ecx
    if(c == C('D')){  // EOF
8010031a:	80 fa 04             	cmp    $0x4,%dl
8010031d:	74 14                	je     80100333 <consoleread+0xbb>
    *dst++ = c;
8010031f:	8d 46 01             	lea    0x1(%esi),%eax
80100322:	88 16                	mov    %dl,(%esi)
    --n;
80100324:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100327:	83 f9 0a             	cmp    $0xa,%ecx
8010032a:	74 11                	je     8010033d <consoleread+0xc5>
    *dst++ = c;
8010032c:	89 c6                	mov    %eax,%esi
8010032e:	e9 73 ff ff ff       	jmp    801002a6 <consoleread+0x2e>
      if(n < target){
80100333:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100336:	73 05                	jae    8010033d <consoleread+0xc5>
        input.r--;
80100338:	a3 a0 ff 10 80       	mov    %eax,0x8010ffa0
  release(&cons.lock);
8010033d:	83 ec 0c             	sub    $0xc,%esp
80100340:	68 20 a5 10 80       	push   $0x8010a520
80100345:	e8 ac 3b 00 00       	call   80103ef6 <release>
  ilock(ip);
8010034a:	89 3c 24             	mov    %edi,(%esp)
8010034d:	e8 7f 12 00 00       	call   801015d1 <ilock>
  return target - n;
80100352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100355:	29 d8                	sub    %ebx,%eax
80100357:	83 c4 10             	add    $0x10,%esp
8010035a:	eb 9e                	jmp    801002fa <consoleread+0x82>

8010035c <panic>:
{
8010035c:	f3 0f 1e fb          	endbr32 
80100360:	55                   	push   %ebp
80100361:	89 e5                	mov    %esp,%ebp
80100363:	53                   	push   %ebx
80100364:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100367:	fa                   	cli    
  cons.locking = 0;
80100368:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
8010036f:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
80100372:	e8 df 20 00 00       	call   80102456 <lapicid>
80100377:	83 ec 08             	sub    $0x8,%esp
8010037a:	50                   	push   %eax
8010037b:	68 6d 6e 10 80       	push   $0x80106e6d
80100380:	e8 a4 02 00 00       	call   80100629 <cprintf>
  cprintf(s);
80100385:	83 c4 04             	add    $0x4,%esp
80100388:	ff 75 08             	pushl  0x8(%ebp)
8010038b:	e8 99 02 00 00       	call   80100629 <cprintf>
  cprintf("\n");
80100390:	c7 04 24 e7 78 10 80 	movl   $0x801078e7,(%esp)
80100397:	e8 8d 02 00 00       	call   80100629 <cprintf>
  getcallerpcs(&s, pcs);
8010039c:	83 c4 08             	add    $0x8,%esp
8010039f:	8d 45 d0             	lea    -0x30(%ebp),%eax
801003a2:	50                   	push   %eax
801003a3:	8d 45 08             	lea    0x8(%ebp),%eax
801003a6:	50                   	push   %eax
801003a7:	e8 b0 39 00 00       	call   80103d5c <getcallerpcs>
  for(i=0; i<10; i++)
801003ac:	83 c4 10             	add    $0x10,%esp
801003af:	bb 00 00 00 00       	mov    $0x0,%ebx
801003b4:	eb 17                	jmp    801003cd <panic+0x71>
    cprintf(" %p", pcs[i]);
801003b6:	83 ec 08             	sub    $0x8,%esp
801003b9:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003bd:	68 81 6e 10 80       	push   $0x80106e81
801003c2:	e8 62 02 00 00       	call   80100629 <cprintf>
  for(i=0; i<10; i++)
801003c7:	83 c3 01             	add    $0x1,%ebx
801003ca:	83 c4 10             	add    $0x10,%esp
801003cd:	83 fb 09             	cmp    $0x9,%ebx
801003d0:	7e e4                	jle    801003b6 <panic+0x5a>
  panicked = 1; // freeze other CPU
801003d2:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003d9:	00 00 00 
  for(;;)
801003dc:	eb fe                	jmp    801003dc <panic+0x80>

801003de <cgaputc>:
{
801003de:	55                   	push   %ebp
801003df:	89 e5                	mov    %esp,%ebp
801003e1:	57                   	push   %edi
801003e2:	56                   	push   %esi
801003e3:	53                   	push   %ebx
801003e4:	83 ec 0c             	sub    $0xc,%esp
801003e7:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003e9:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003ee:	b8 0e 00 00 00       	mov    $0xe,%eax
801003f3:	89 ca                	mov    %ecx,%edx
801003f5:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f6:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003fb:	89 da                	mov    %ebx,%edx
801003fd:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003fe:	0f b6 f8             	movzbl %al,%edi
80100401:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100404:	b8 0f 00 00 00       	mov    $0xf,%eax
80100409:	89 ca                	mov    %ecx,%edx
8010040b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010040c:	89 da                	mov    %ebx,%edx
8010040e:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
8010040f:	0f b6 c8             	movzbl %al,%ecx
80100412:	09 f9                	or     %edi,%ecx
  if(c == '\n')
80100414:	83 fe 0a             	cmp    $0xa,%esi
80100417:	74 66                	je     8010047f <cgaputc+0xa1>
  else if(c == BACKSPACE){
80100419:	81 fe 00 01 00 00    	cmp    $0x100,%esi
8010041f:	74 7f                	je     801004a0 <cgaputc+0xc2>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100421:	89 f0                	mov    %esi,%eax
80100423:	0f b6 f0             	movzbl %al,%esi
80100426:	8d 59 01             	lea    0x1(%ecx),%ebx
80100429:	66 81 ce 00 07       	or     $0x700,%si
8010042e:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100435:	80 
  if(pos < 0 || pos > 25*80)
80100436:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
8010043c:	77 6f                	ja     801004ad <cgaputc+0xcf>
  if((pos/80) >= 24){  // Scroll up.
8010043e:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100444:	7f 74                	jg     801004ba <cgaputc+0xdc>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100446:	be d4 03 00 00       	mov    $0x3d4,%esi
8010044b:	b8 0e 00 00 00       	mov    $0xe,%eax
80100450:	89 f2                	mov    %esi,%edx
80100452:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
80100453:	89 d8                	mov    %ebx,%eax
80100455:	c1 f8 08             	sar    $0x8,%eax
80100458:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
8010045d:	89 ca                	mov    %ecx,%edx
8010045f:	ee                   	out    %al,(%dx)
80100460:	b8 0f 00 00 00       	mov    $0xf,%eax
80100465:	89 f2                	mov    %esi,%edx
80100467:	ee                   	out    %al,(%dx)
80100468:	89 d8                	mov    %ebx,%eax
8010046a:	89 ca                	mov    %ecx,%edx
8010046c:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
8010046d:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100474:	80 20 07 
}
80100477:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010047a:	5b                   	pop    %ebx
8010047b:	5e                   	pop    %esi
8010047c:	5f                   	pop    %edi
8010047d:	5d                   	pop    %ebp
8010047e:	c3                   	ret    
    pos += 80 - pos%80;
8010047f:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100484:	89 c8                	mov    %ecx,%eax
80100486:	f7 ea                	imul   %edx
80100488:	c1 fa 05             	sar    $0x5,%edx
8010048b:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010048e:	c1 e0 04             	shl    $0x4,%eax
80100491:	89 ca                	mov    %ecx,%edx
80100493:	29 c2                	sub    %eax,%edx
80100495:	bb 50 00 00 00       	mov    $0x50,%ebx
8010049a:	29 d3                	sub    %edx,%ebx
8010049c:	01 cb                	add    %ecx,%ebx
8010049e:	eb 96                	jmp    80100436 <cgaputc+0x58>
    if(pos > 0) --pos;
801004a0:	85 c9                	test   %ecx,%ecx
801004a2:	7e 05                	jle    801004a9 <cgaputc+0xcb>
801004a4:	8d 59 ff             	lea    -0x1(%ecx),%ebx
801004a7:	eb 8d                	jmp    80100436 <cgaputc+0x58>
  pos |= inb(CRTPORT+1);
801004a9:	89 cb                	mov    %ecx,%ebx
801004ab:	eb 89                	jmp    80100436 <cgaputc+0x58>
    panic("pos under/overflow");
801004ad:	83 ec 0c             	sub    $0xc,%esp
801004b0:	68 85 6e 10 80       	push   $0x80106e85
801004b5:	e8 a2 fe ff ff       	call   8010035c <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004ba:	83 ec 04             	sub    $0x4,%esp
801004bd:	68 60 0e 00 00       	push   $0xe60
801004c2:	68 a0 80 0b 80       	push   $0x800b80a0
801004c7:	68 00 80 0b 80       	push   $0x800b8000
801004cc:	e8 f0 3a 00 00       	call   80103fc1 <memmove>
    pos -= 80;
801004d1:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004d4:	b8 80 07 00 00       	mov    $0x780,%eax
801004d9:	29 d8                	sub    %ebx,%eax
801004db:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004e2:	83 c4 0c             	add    $0xc,%esp
801004e5:	01 c0                	add    %eax,%eax
801004e7:	50                   	push   %eax
801004e8:	6a 00                	push   $0x0
801004ea:	52                   	push   %edx
801004eb:	e8 51 3a 00 00       	call   80103f41 <memset>
801004f0:	83 c4 10             	add    $0x10,%esp
801004f3:	e9 4e ff ff ff       	jmp    80100446 <cgaputc+0x68>

801004f8 <consputc>:
  if(panicked){
801004f8:	83 3d 58 a5 10 80 00 	cmpl   $0x0,0x8010a558
801004ff:	74 03                	je     80100504 <consputc+0xc>
  asm volatile("cli");
80100501:	fa                   	cli    
    for(;;)
80100502:	eb fe                	jmp    80100502 <consputc+0xa>
{
80100504:	55                   	push   %ebp
80100505:	89 e5                	mov    %esp,%ebp
80100507:	53                   	push   %ebx
80100508:	83 ec 04             	sub    $0x4,%esp
8010050b:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
8010050d:	3d 00 01 00 00       	cmp    $0x100,%eax
80100512:	74 18                	je     8010052c <consputc+0x34>
    uartputc(c);
80100514:	83 ec 0c             	sub    $0xc,%esp
80100517:	50                   	push   %eax
80100518:	e8 ca 4e 00 00       	call   801053e7 <uartputc>
8010051d:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100520:	89 d8                	mov    %ebx,%eax
80100522:	e8 b7 fe ff ff       	call   801003de <cgaputc>
}
80100527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010052a:	c9                   	leave  
8010052b:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010052c:	83 ec 0c             	sub    $0xc,%esp
8010052f:	6a 08                	push   $0x8
80100531:	e8 b1 4e 00 00       	call   801053e7 <uartputc>
80100536:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010053d:	e8 a5 4e 00 00       	call   801053e7 <uartputc>
80100542:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100549:	e8 99 4e 00 00       	call   801053e7 <uartputc>
8010054e:	83 c4 10             	add    $0x10,%esp
80100551:	eb cd                	jmp    80100520 <consputc+0x28>

80100553 <printint>:
{
80100553:	55                   	push   %ebp
80100554:	89 e5                	mov    %esp,%ebp
80100556:	57                   	push   %edi
80100557:	56                   	push   %esi
80100558:	53                   	push   %ebx
80100559:	83 ec 2c             	sub    $0x2c,%esp
8010055c:	89 d6                	mov    %edx,%esi
8010055e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
80100561:	85 c9                	test   %ecx,%ecx
80100563:	74 0c                	je     80100571 <printint+0x1e>
80100565:	89 c7                	mov    %eax,%edi
80100567:	c1 ef 1f             	shr    $0x1f,%edi
8010056a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
8010056d:	85 c0                	test   %eax,%eax
8010056f:	78 38                	js     801005a9 <printint+0x56>
    x = xx;
80100571:	89 c1                	mov    %eax,%ecx
  i = 0;
80100573:	bb 00 00 00 00       	mov    $0x0,%ebx
    buf[i++] = digits[x % base];
80100578:	89 c8                	mov    %ecx,%eax
8010057a:	ba 00 00 00 00       	mov    $0x0,%edx
8010057f:	f7 f6                	div    %esi
80100581:	89 df                	mov    %ebx,%edi
80100583:	83 c3 01             	add    $0x1,%ebx
80100586:	0f b6 92 b0 6e 10 80 	movzbl -0x7fef9150(%edx),%edx
8010058d:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
80100591:	89 ca                	mov    %ecx,%edx
80100593:	89 c1                	mov    %eax,%ecx
80100595:	39 d6                	cmp    %edx,%esi
80100597:	76 df                	jbe    80100578 <printint+0x25>
  if(sign)
80100599:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010059d:	74 1a                	je     801005b9 <printint+0x66>
    buf[i++] = '-';
8010059f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
801005a4:	8d 5f 02             	lea    0x2(%edi),%ebx
801005a7:	eb 10                	jmp    801005b9 <printint+0x66>
    x = -xx;
801005a9:	f7 d8                	neg    %eax
801005ab:	89 c1                	mov    %eax,%ecx
801005ad:	eb c4                	jmp    80100573 <printint+0x20>
    consputc(buf[i]);
801005af:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
801005b4:	e8 3f ff ff ff       	call   801004f8 <consputc>
  while(--i >= 0)
801005b9:	83 eb 01             	sub    $0x1,%ebx
801005bc:	79 f1                	jns    801005af <printint+0x5c>
}
801005be:	83 c4 2c             	add    $0x2c,%esp
801005c1:	5b                   	pop    %ebx
801005c2:	5e                   	pop    %esi
801005c3:	5f                   	pop    %edi
801005c4:	5d                   	pop    %ebp
801005c5:	c3                   	ret    

801005c6 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005c6:	f3 0f 1e fb          	endbr32 
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	57                   	push   %edi
801005ce:	56                   	push   %esi
801005cf:	53                   	push   %ebx
801005d0:	83 ec 18             	sub    $0x18,%esp
801005d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005d6:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005d9:	ff 75 08             	pushl  0x8(%ebp)
801005dc:	e8 b6 10 00 00       	call   80101697 <iunlock>
  acquire(&cons.lock);
801005e1:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005e8:	e8 a0 38 00 00       	call   80103e8d <acquire>
  for(i = 0; i < n; i++)
801005ed:	83 c4 10             	add    $0x10,%esp
801005f0:	bb 00 00 00 00       	mov    $0x0,%ebx
801005f5:	39 f3                	cmp    %esi,%ebx
801005f7:	7d 0e                	jge    80100607 <consolewrite+0x41>
    consputc(buf[i] & 0xff);
801005f9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005fd:	e8 f6 fe ff ff       	call   801004f8 <consputc>
  for(i = 0; i < n; i++)
80100602:	83 c3 01             	add    $0x1,%ebx
80100605:	eb ee                	jmp    801005f5 <consolewrite+0x2f>
  release(&cons.lock);
80100607:	83 ec 0c             	sub    $0xc,%esp
8010060a:	68 20 a5 10 80       	push   $0x8010a520
8010060f:	e8 e2 38 00 00       	call   80103ef6 <release>
  ilock(ip);
80100614:	83 c4 04             	add    $0x4,%esp
80100617:	ff 75 08             	pushl  0x8(%ebp)
8010061a:	e8 b2 0f 00 00       	call   801015d1 <ilock>

  return n;
}
8010061f:	89 f0                	mov    %esi,%eax
80100621:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100624:	5b                   	pop    %ebx
80100625:	5e                   	pop    %esi
80100626:	5f                   	pop    %edi
80100627:	5d                   	pop    %ebp
80100628:	c3                   	ret    

80100629 <cprintf>:
{
80100629:	f3 0f 1e fb          	endbr32 
8010062d:	55                   	push   %ebp
8010062e:	89 e5                	mov    %esp,%ebp
80100630:	57                   	push   %edi
80100631:	56                   	push   %esi
80100632:	53                   	push   %ebx
80100633:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100636:	a1 54 a5 10 80       	mov    0x8010a554,%eax
8010063b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
8010063e:	85 c0                	test   %eax,%eax
80100640:	75 10                	jne    80100652 <cprintf+0x29>
  if (fmt == 0)
80100642:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100646:	74 1c                	je     80100664 <cprintf+0x3b>
  argp = (uint*)(void*)(&fmt + 1);
80100648:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010064b:	be 00 00 00 00       	mov    $0x0,%esi
80100650:	eb 27                	jmp    80100679 <cprintf+0x50>
    acquire(&cons.lock);
80100652:	83 ec 0c             	sub    $0xc,%esp
80100655:	68 20 a5 10 80       	push   $0x8010a520
8010065a:	e8 2e 38 00 00       	call   80103e8d <acquire>
8010065f:	83 c4 10             	add    $0x10,%esp
80100662:	eb de                	jmp    80100642 <cprintf+0x19>
    panic("null fmt");
80100664:	83 ec 0c             	sub    $0xc,%esp
80100667:	68 9f 6e 10 80       	push   $0x80106e9f
8010066c:	e8 eb fc ff ff       	call   8010035c <panic>
      consputc(c);
80100671:	e8 82 fe ff ff       	call   801004f8 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100676:	83 c6 01             	add    $0x1,%esi
80100679:	8b 55 08             	mov    0x8(%ebp),%edx
8010067c:	0f b6 04 32          	movzbl (%edx,%esi,1),%eax
80100680:	85 c0                	test   %eax,%eax
80100682:	0f 84 b1 00 00 00    	je     80100739 <cprintf+0x110>
    if(c != '%'){
80100688:	83 f8 25             	cmp    $0x25,%eax
8010068b:	75 e4                	jne    80100671 <cprintf+0x48>
    c = fmt[++i] & 0xff;
8010068d:	83 c6 01             	add    $0x1,%esi
80100690:	0f b6 1c 32          	movzbl (%edx,%esi,1),%ebx
    if(c == 0)
80100694:	85 db                	test   %ebx,%ebx
80100696:	0f 84 9d 00 00 00    	je     80100739 <cprintf+0x110>
    switch(c){
8010069c:	83 fb 70             	cmp    $0x70,%ebx
8010069f:	74 2e                	je     801006cf <cprintf+0xa6>
801006a1:	7f 22                	jg     801006c5 <cprintf+0x9c>
801006a3:	83 fb 25             	cmp    $0x25,%ebx
801006a6:	74 6c                	je     80100714 <cprintf+0xeb>
801006a8:	83 fb 64             	cmp    $0x64,%ebx
801006ab:	75 76                	jne    80100723 <cprintf+0xfa>
      printint(*argp++, 10, 1);
801006ad:	8d 5f 04             	lea    0x4(%edi),%ebx
801006b0:	8b 07                	mov    (%edi),%eax
801006b2:	b9 01 00 00 00       	mov    $0x1,%ecx
801006b7:	ba 0a 00 00 00       	mov    $0xa,%edx
801006bc:	e8 92 fe ff ff       	call   80100553 <printint>
801006c1:	89 df                	mov    %ebx,%edi
      break;
801006c3:	eb b1                	jmp    80100676 <cprintf+0x4d>
    switch(c){
801006c5:	83 fb 73             	cmp    $0x73,%ebx
801006c8:	74 1d                	je     801006e7 <cprintf+0xbe>
801006ca:	83 fb 78             	cmp    $0x78,%ebx
801006cd:	75 54                	jne    80100723 <cprintf+0xfa>
      printint(*argp++, 16, 0);
801006cf:	8d 5f 04             	lea    0x4(%edi),%ebx
801006d2:	8b 07                	mov    (%edi),%eax
801006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d9:	ba 10 00 00 00       	mov    $0x10,%edx
801006de:	e8 70 fe ff ff       	call   80100553 <printint>
801006e3:	89 df                	mov    %ebx,%edi
      break;
801006e5:	eb 8f                	jmp    80100676 <cprintf+0x4d>
      if((s = (char*)*argp++) == 0)
801006e7:	8d 47 04             	lea    0x4(%edi),%eax
801006ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801006ed:	8b 1f                	mov    (%edi),%ebx
801006ef:	85 db                	test   %ebx,%ebx
801006f1:	75 05                	jne    801006f8 <cprintf+0xcf>
        s = "(null)";
801006f3:	bb 98 6e 10 80       	mov    $0x80106e98,%ebx
      for(; *s; s++)
801006f8:	0f b6 03             	movzbl (%ebx),%eax
801006fb:	84 c0                	test   %al,%al
801006fd:	74 0d                	je     8010070c <cprintf+0xe3>
        consputc(*s);
801006ff:	0f be c0             	movsbl %al,%eax
80100702:	e8 f1 fd ff ff       	call   801004f8 <consputc>
      for(; *s; s++)
80100707:	83 c3 01             	add    $0x1,%ebx
8010070a:	eb ec                	jmp    801006f8 <cprintf+0xcf>
      if((s = (char*)*argp++) == 0)
8010070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010070f:	e9 62 ff ff ff       	jmp    80100676 <cprintf+0x4d>
      consputc('%');
80100714:	b8 25 00 00 00       	mov    $0x25,%eax
80100719:	e8 da fd ff ff       	call   801004f8 <consputc>
      break;
8010071e:	e9 53 ff ff ff       	jmp    80100676 <cprintf+0x4d>
      consputc('%');
80100723:	b8 25 00 00 00       	mov    $0x25,%eax
80100728:	e8 cb fd ff ff       	call   801004f8 <consputc>
      consputc(c);
8010072d:	89 d8                	mov    %ebx,%eax
8010072f:	e8 c4 fd ff ff       	call   801004f8 <consputc>
      break;
80100734:	e9 3d ff ff ff       	jmp    80100676 <cprintf+0x4d>
  if(locking)
80100739:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010073d:	75 08                	jne    80100747 <cprintf+0x11e>
}
8010073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100742:	5b                   	pop    %ebx
80100743:	5e                   	pop    %esi
80100744:	5f                   	pop    %edi
80100745:	5d                   	pop    %ebp
80100746:	c3                   	ret    
    release(&cons.lock);
80100747:	83 ec 0c             	sub    $0xc,%esp
8010074a:	68 20 a5 10 80       	push   $0x8010a520
8010074f:	e8 a2 37 00 00       	call   80103ef6 <release>
80100754:	83 c4 10             	add    $0x10,%esp
}
80100757:	eb e6                	jmp    8010073f <cprintf+0x116>

80100759 <consoleintr>:
{
80100759:	f3 0f 1e fb          	endbr32 
8010075d:	55                   	push   %ebp
8010075e:	89 e5                	mov    %esp,%ebp
80100760:	57                   	push   %edi
80100761:	56                   	push   %esi
80100762:	53                   	push   %ebx
80100763:	83 ec 18             	sub    $0x18,%esp
80100766:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
80100769:	68 20 a5 10 80       	push   $0x8010a520
8010076e:	e8 1a 37 00 00       	call   80103e8d <acquire>
  while((c = getc()) >= 0){
80100773:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100776:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010077b:	eb 13                	jmp    80100790 <consoleintr+0x37>
    switch(c){
8010077d:	83 ff 08             	cmp    $0x8,%edi
80100780:	0f 84 d9 00 00 00    	je     8010085f <consoleintr+0x106>
80100786:	83 ff 10             	cmp    $0x10,%edi
80100789:	75 25                	jne    801007b0 <consoleintr+0x57>
8010078b:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100790:	ff d3                	call   *%ebx
80100792:	89 c7                	mov    %eax,%edi
80100794:	85 c0                	test   %eax,%eax
80100796:	0f 88 f5 00 00 00    	js     80100891 <consoleintr+0x138>
    switch(c){
8010079c:	83 ff 15             	cmp    $0x15,%edi
8010079f:	0f 84 93 00 00 00    	je     80100838 <consoleintr+0xdf>
801007a5:	7e d6                	jle    8010077d <consoleintr+0x24>
801007a7:	83 ff 7f             	cmp    $0x7f,%edi
801007aa:	0f 84 af 00 00 00    	je     8010085f <consoleintr+0x106>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801007b0:	85 ff                	test   %edi,%edi
801007b2:	74 dc                	je     80100790 <consoleintr+0x37>
801007b4:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007b9:	89 c2                	mov    %eax,%edx
801007bb:	2b 15 a0 ff 10 80    	sub    0x8010ffa0,%edx
801007c1:	83 fa 7f             	cmp    $0x7f,%edx
801007c4:	77 ca                	ja     80100790 <consoleintr+0x37>
        c = (c == '\r') ? '\n' : c;
801007c6:	83 ff 0d             	cmp    $0xd,%edi
801007c9:	0f 84 b8 00 00 00    	je     80100887 <consoleintr+0x12e>
        input.buf[input.e++ % INPUT_BUF] = c;
801007cf:	8d 50 01             	lea    0x1(%eax),%edx
801007d2:	89 15 a8 ff 10 80    	mov    %edx,0x8010ffa8
801007d8:	83 e0 7f             	and    $0x7f,%eax
801007db:	89 f9                	mov    %edi,%ecx
801007dd:	88 88 20 ff 10 80    	mov    %cl,-0x7fef00e0(%eax)
        consputc(c);
801007e3:	89 f8                	mov    %edi,%eax
801007e5:	e8 0e fd ff ff       	call   801004f8 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007ea:	83 ff 0a             	cmp    $0xa,%edi
801007ed:	0f 94 c2             	sete   %dl
801007f0:	83 ff 04             	cmp    $0x4,%edi
801007f3:	0f 94 c0             	sete   %al
801007f6:	08 c2                	or     %al,%dl
801007f8:	75 10                	jne    8010080a <consoleintr+0xb1>
801007fa:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801007ff:	83 e8 80             	sub    $0xffffff80,%eax
80100802:	39 05 a8 ff 10 80    	cmp    %eax,0x8010ffa8
80100808:	75 86                	jne    80100790 <consoleintr+0x37>
          input.w = input.e;
8010080a:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
8010080f:	a3 a4 ff 10 80       	mov    %eax,0x8010ffa4
          wakeup(&input.r);
80100814:	83 ec 0c             	sub    $0xc,%esp
80100817:	68 a0 ff 10 80       	push   $0x8010ffa0
8010081c:	e8 b2 31 00 00       	call   801039d3 <wakeup>
80100821:	83 c4 10             	add    $0x10,%esp
80100824:	e9 67 ff ff ff       	jmp    80100790 <consoleintr+0x37>
        input.e--;
80100829:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
8010082e:	b8 00 01 00 00       	mov    $0x100,%eax
80100833:	e8 c0 fc ff ff       	call   801004f8 <consputc>
      while(input.e != input.w &&
80100838:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
8010083d:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
80100843:	0f 84 47 ff ff ff    	je     80100790 <consoleintr+0x37>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100849:	83 e8 01             	sub    $0x1,%eax
8010084c:	89 c2                	mov    %eax,%edx
8010084e:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100851:	80 ba 20 ff 10 80 0a 	cmpb   $0xa,-0x7fef00e0(%edx)
80100858:	75 cf                	jne    80100829 <consoleintr+0xd0>
8010085a:	e9 31 ff ff ff       	jmp    80100790 <consoleintr+0x37>
      if(input.e != input.w){
8010085f:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100864:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
8010086a:	0f 84 20 ff ff ff    	je     80100790 <consoleintr+0x37>
        input.e--;
80100870:	83 e8 01             	sub    $0x1,%eax
80100873:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
80100878:	b8 00 01 00 00       	mov    $0x100,%eax
8010087d:	e8 76 fc ff ff       	call   801004f8 <consputc>
80100882:	e9 09 ff ff ff       	jmp    80100790 <consoleintr+0x37>
        c = (c == '\r') ? '\n' : c;
80100887:	bf 0a 00 00 00       	mov    $0xa,%edi
8010088c:	e9 3e ff ff ff       	jmp    801007cf <consoleintr+0x76>
  release(&cons.lock);
80100891:	83 ec 0c             	sub    $0xc,%esp
80100894:	68 20 a5 10 80       	push   $0x8010a520
80100899:	e8 58 36 00 00       	call   80103ef6 <release>
  if(doprocdump) {
8010089e:	83 c4 10             	add    $0x10,%esp
801008a1:	85 f6                	test   %esi,%esi
801008a3:	75 08                	jne    801008ad <consoleintr+0x154>
}
801008a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801008a8:	5b                   	pop    %ebx
801008a9:	5e                   	pop    %esi
801008aa:	5f                   	pop    %edi
801008ab:	5d                   	pop    %ebp
801008ac:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
801008ad:	e8 c6 31 00 00       	call   80103a78 <procdump>
}
801008b2:	eb f1                	jmp    801008a5 <consoleintr+0x14c>

801008b4 <consoleinit>:

void
consoleinit(void)
{
801008b4:	f3 0f 1e fb          	endbr32 
801008b8:	55                   	push   %ebp
801008b9:	89 e5                	mov    %esp,%ebp
801008bb:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
801008be:	68 a8 6e 10 80       	push   $0x80106ea8
801008c3:	68 20 a5 10 80       	push   $0x8010a520
801008c8:	e8 70 34 00 00       	call   80103d3d <initlock>

  devsw[CONSOLE].write = consolewrite;
801008cd:	c7 05 6c 09 11 80 c6 	movl   $0x801005c6,0x8011096c
801008d4:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008d7:	c7 05 68 09 11 80 78 	movl   $0x80100278,0x80110968
801008de:	02 10 80 
  cons.locking = 1;
801008e1:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801008e8:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008eb:	83 c4 08             	add    $0x8,%esp
801008ee:	6a 00                	push   $0x0
801008f0:	6a 01                	push   $0x1
801008f2:	e8 0b 17 00 00       	call   80102002 <ioapicenable>
}
801008f7:	83 c4 10             	add    $0x10,%esp
801008fa:	c9                   	leave  
801008fb:	c3                   	ret    

801008fc <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008fc:	f3 0f 1e fb          	endbr32 
80100900:	55                   	push   %ebp
80100901:	89 e5                	mov    %esp,%ebp
80100903:	57                   	push   %edi
80100904:	56                   	push   %esi
80100905:	53                   	push   %ebx
80100906:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
8010090c:	e8 6a 2a 00 00       	call   8010337b <myproc>
80100911:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100917:	e8 70 1f 00 00       	call   8010288c <begin_op>

  if((ip = namei(path)) == 0){
8010091c:	83 ec 0c             	sub    $0xc,%esp
8010091f:	ff 75 08             	pushl  0x8(%ebp)
80100922:	e8 2f 13 00 00       	call   80101c56 <namei>
80100927:	83 c4 10             	add    $0x10,%esp
8010092a:	85 c0                	test   %eax,%eax
8010092c:	74 56                	je     80100984 <exec+0x88>
8010092e:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100930:	83 ec 0c             	sub    $0xc,%esp
80100933:	50                   	push   %eax
80100934:	e8 98 0c 00 00       	call   801015d1 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100939:	6a 34                	push   $0x34
8010093b:	6a 00                	push   $0x0
8010093d:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100943:	50                   	push   %eax
80100944:	53                   	push   %ebx
80100945:	e8 8d 0e 00 00       	call   801017d7 <readi>
8010094a:	83 c4 20             	add    $0x20,%esp
8010094d:	83 f8 34             	cmp    $0x34,%eax
80100950:	75 0c                	jne    8010095e <exec+0x62>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100952:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100959:	45 4c 46 
8010095c:	74 42                	je     801009a0 <exec+0xa4>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
8010095e:	85 db                	test   %ebx,%ebx
80100960:	0f 84 d0 02 00 00    	je     80100c36 <exec+0x33a>
    iunlockput(ip);
80100966:	83 ec 0c             	sub    $0xc,%esp
80100969:	53                   	push   %ebx
8010096a:	e8 15 0e 00 00       	call   80101784 <iunlockput>
    end_op();
8010096f:	e8 96 1f 00 00       	call   8010290a <end_op>
80100974:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100977:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010097c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010097f:	5b                   	pop    %ebx
80100980:	5e                   	pop    %esi
80100981:	5f                   	pop    %edi
80100982:	5d                   	pop    %ebp
80100983:	c3                   	ret    
    end_op();
80100984:	e8 81 1f 00 00       	call   8010290a <end_op>
    cprintf("exec: fail\n");
80100989:	83 ec 0c             	sub    $0xc,%esp
8010098c:	68 c1 6e 10 80       	push   $0x80106ec1
80100991:	e8 93 fc ff ff       	call   80100629 <cprintf>
    return -1;
80100996:	83 c4 10             	add    $0x10,%esp
80100999:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010099e:	eb dc                	jmp    8010097c <exec+0x80>
  if((pgdir = setupkvm()) == 0)
801009a0:	e8 e8 5c 00 00       	call   8010668d <setupkvm>
801009a5:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009ab:	85 c0                	test   %eax,%eax
801009ad:	0f 84 09 01 00 00    	je     80100abc <exec+0x1c0>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801009b3:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
801009b9:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801009be:	be 00 00 00 00       	mov    $0x0,%esi
801009c3:	eb 0c                	jmp    801009d1 <exec+0xd5>
801009c5:	83 c6 01             	add    $0x1,%esi
801009c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
801009ce:	83 c0 20             	add    $0x20,%eax
801009d1:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009d8:	39 f2                	cmp    %esi,%edx
801009da:	0f 8e 98 00 00 00    	jle    80100a78 <exec+0x17c>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009e0:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
801009e6:	6a 20                	push   $0x20
801009e8:	50                   	push   %eax
801009e9:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009ef:	50                   	push   %eax
801009f0:	53                   	push   %ebx
801009f1:	e8 e1 0d 00 00       	call   801017d7 <readi>
801009f6:	83 c4 10             	add    $0x10,%esp
801009f9:	83 f8 20             	cmp    $0x20,%eax
801009fc:	0f 85 ba 00 00 00    	jne    80100abc <exec+0x1c0>
    if(ph.type != ELF_PROG_LOAD)
80100a02:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100a09:	75 ba                	jne    801009c5 <exec+0xc9>
    if(ph.memsz < ph.filesz)
80100a0b:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100a11:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100a17:	0f 82 9f 00 00 00    	jb     80100abc <exec+0x1c0>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100a1d:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100a23:	0f 82 93 00 00 00    	jb     80100abc <exec+0x1c0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100a29:	83 ec 04             	sub    $0x4,%esp
80100a2c:	50                   	push   %eax
80100a2d:	57                   	push   %edi
80100a2e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100a34:	e8 c4 5a 00 00       	call   801064fd <allocuvm>
80100a39:	89 c7                	mov    %eax,%edi
80100a3b:	83 c4 10             	add    $0x10,%esp
80100a3e:	85 c0                	test   %eax,%eax
80100a40:	74 7a                	je     80100abc <exec+0x1c0>
    if(ph.vaddr % PGSIZE != 0)
80100a42:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a48:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a4d:	75 6d                	jne    80100abc <exec+0x1c0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a4f:	83 ec 0c             	sub    $0xc,%esp
80100a52:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a58:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a5e:	53                   	push   %ebx
80100a5f:	50                   	push   %eax
80100a60:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100a66:	e8 35 59 00 00       	call   801063a0 <loaduvm>
80100a6b:	83 c4 20             	add    $0x20,%esp
80100a6e:	85 c0                	test   %eax,%eax
80100a70:	0f 89 4f ff ff ff    	jns    801009c5 <exec+0xc9>
80100a76:	eb 44                	jmp    80100abc <exec+0x1c0>
  iunlockput(ip);
80100a78:	83 ec 0c             	sub    $0xc,%esp
80100a7b:	53                   	push   %ebx
80100a7c:	e8 03 0d 00 00       	call   80101784 <iunlockput>
  end_op();
80100a81:	e8 84 1e 00 00       	call   8010290a <end_op>
  sz = PGROUNDUP(sz);
80100a86:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a91:	83 c4 0c             	add    $0xc,%esp
80100a94:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a9a:	52                   	push   %edx
80100a9b:	50                   	push   %eax
80100a9c:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100aa2:	57                   	push   %edi
80100aa3:	e8 55 5a 00 00       	call   801064fd <allocuvm>
80100aa8:	89 c6                	mov    %eax,%esi
80100aaa:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100ab0:	83 c4 10             	add    $0x10,%esp
80100ab3:	85 c0                	test   %eax,%eax
80100ab5:	75 24                	jne    80100adb <exec+0x1df>
  ip = 0;
80100ab7:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100abc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ac2:	85 c0                	test   %eax,%eax
80100ac4:	0f 84 94 fe ff ff    	je     8010095e <exec+0x62>
    freevm(pgdir);
80100aca:	83 ec 0c             	sub    $0xc,%esp
80100acd:	50                   	push   %eax
80100ace:	e8 32 5b 00 00       	call   80106605 <freevm>
80100ad3:	83 c4 10             	add    $0x10,%esp
80100ad6:	e9 83 fe ff ff       	jmp    8010095e <exec+0x62>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100adb:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ae1:	83 ec 08             	sub    $0x8,%esp
80100ae4:	50                   	push   %eax
80100ae5:	57                   	push   %edi
80100ae6:	e8 2f 5c 00 00       	call   8010671a <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100aeb:	83 c4 10             	add    $0x10,%esp
80100aee:	bf 00 00 00 00       	mov    $0x0,%edi
80100af3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af6:	8d 1c b8             	lea    (%eax,%edi,4),%ebx
80100af9:	8b 03                	mov    (%ebx),%eax
80100afb:	85 c0                	test   %eax,%eax
80100afd:	74 4d                	je     80100b4c <exec+0x250>
    if(argc >= MAXARG)
80100aff:	83 ff 1f             	cmp    $0x1f,%edi
80100b02:	0f 87 1a 01 00 00    	ja     80100c22 <exec+0x326>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100b08:	83 ec 0c             	sub    $0xc,%esp
80100b0b:	50                   	push   %eax
80100b0c:	e8 f1 35 00 00       	call   80104102 <strlen>
80100b11:	29 c6                	sub    %eax,%esi
80100b13:	83 ee 01             	sub    $0x1,%esi
80100b16:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100b19:	83 c4 04             	add    $0x4,%esp
80100b1c:	ff 33                	pushl  (%ebx)
80100b1e:	e8 df 35 00 00       	call   80104102 <strlen>
80100b23:	83 c0 01             	add    $0x1,%eax
80100b26:	50                   	push   %eax
80100b27:	ff 33                	pushl  (%ebx)
80100b29:	56                   	push   %esi
80100b2a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100b30:	e8 81 5d 00 00       	call   801068b6 <copyout>
80100b35:	83 c4 20             	add    $0x20,%esp
80100b38:	85 c0                	test   %eax,%eax
80100b3a:	0f 88 ec 00 00 00    	js     80100c2c <exec+0x330>
    ustack[3+argc] = sp;
80100b40:	89 b4 bd 64 ff ff ff 	mov    %esi,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100b47:	83 c7 01             	add    $0x1,%edi
80100b4a:	eb a7                	jmp    80100af3 <exec+0x1f7>
80100b4c:	89 f1                	mov    %esi,%ecx
80100b4e:	89 c3                	mov    %eax,%ebx
  ustack[3+argc] = 0;
80100b50:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100b57:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b5b:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b62:	ff ff ff 
  ustack[1] = argc;
80100b65:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b6b:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100b72:	89 f2                	mov    %esi,%edx
80100b74:	29 c2                	sub    %eax,%edx
80100b76:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b7c:	8d 04 bd 10 00 00 00 	lea    0x10(,%edi,4),%eax
80100b83:	29 c1                	sub    %eax,%ecx
80100b85:	89 ce                	mov    %ecx,%esi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b87:	50                   	push   %eax
80100b88:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b8e:	50                   	push   %eax
80100b8f:	51                   	push   %ecx
80100b90:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100b96:	e8 1b 5d 00 00       	call   801068b6 <copyout>
80100b9b:	83 c4 10             	add    $0x10,%esp
80100b9e:	85 c0                	test   %eax,%eax
80100ba0:	0f 88 16 ff ff ff    	js     80100abc <exec+0x1c0>
  for(last=s=path; *s; s++)
80100ba6:	8b 55 08             	mov    0x8(%ebp),%edx
80100ba9:	89 d0                	mov    %edx,%eax
80100bab:	eb 03                	jmp    80100bb0 <exec+0x2b4>
80100bad:	83 c0 01             	add    $0x1,%eax
80100bb0:	0f b6 08             	movzbl (%eax),%ecx
80100bb3:	84 c9                	test   %cl,%cl
80100bb5:	74 0a                	je     80100bc1 <exec+0x2c5>
    if(*s == '/')
80100bb7:	80 f9 2f             	cmp    $0x2f,%cl
80100bba:	75 f1                	jne    80100bad <exec+0x2b1>
      last = s+1;
80100bbc:	8d 50 01             	lea    0x1(%eax),%edx
80100bbf:	eb ec                	jmp    80100bad <exec+0x2b1>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100bc1:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100bc7:	89 f8                	mov    %edi,%eax
80100bc9:	83 c0 6c             	add    $0x6c,%eax
80100bcc:	83 ec 04             	sub    $0x4,%esp
80100bcf:	6a 10                	push   $0x10
80100bd1:	52                   	push   %edx
80100bd2:	50                   	push   %eax
80100bd3:	e8 e9 34 00 00       	call   801040c1 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100bd8:	8b 5f 04             	mov    0x4(%edi),%ebx
  curproc->pgdir = pgdir;
80100bdb:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100be1:	89 4f 04             	mov    %ecx,0x4(%edi)
  curproc->sz = sz;
80100be4:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100bea:	89 0f                	mov    %ecx,(%edi)
  curproc->tf->eip = elf.entry;  // main
80100bec:	8b 47 18             	mov    0x18(%edi),%eax
80100bef:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bf5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bf8:	8b 47 18             	mov    0x18(%edi),%eax
80100bfb:	89 70 44             	mov    %esi,0x44(%eax)
  curproc->priority = 0;
80100bfe:	c7 47 7c 00 00 00 00 	movl   $0x0,0x7c(%edi)
  switchuvm(curproc);
80100c05:	89 3c 24             	mov    %edi,(%esp)
80100c08:	e8 de 55 00 00       	call   801061eb <switchuvm>
  freevm(oldpgdir);
80100c0d:	89 1c 24             	mov    %ebx,(%esp)
80100c10:	e8 f0 59 00 00       	call   80106605 <freevm>
  return 0;
80100c15:	83 c4 10             	add    $0x10,%esp
80100c18:	b8 00 00 00 00       	mov    $0x0,%eax
80100c1d:	e9 5a fd ff ff       	jmp    8010097c <exec+0x80>
  ip = 0;
80100c22:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c27:	e9 90 fe ff ff       	jmp    80100abc <exec+0x1c0>
80100c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c31:	e9 86 fe ff ff       	jmp    80100abc <exec+0x1c0>
  return -1;
80100c36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c3b:	e9 3c fd ff ff       	jmp    8010097c <exec+0x80>

80100c40 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c40:	f3 0f 1e fb          	endbr32 
80100c44:	55                   	push   %ebp
80100c45:	89 e5                	mov    %esp,%ebp
80100c47:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c4a:	68 cd 6e 10 80       	push   $0x80106ecd
80100c4f:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c54:	e8 e4 30 00 00       	call   80103d3d <initlock>
}
80100c59:	83 c4 10             	add    $0x10,%esp
80100c5c:	c9                   	leave  
80100c5d:	c3                   	ret    

80100c5e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c5e:	f3 0f 1e fb          	endbr32 
80100c62:	55                   	push   %ebp
80100c63:	89 e5                	mov    %esp,%ebp
80100c65:	53                   	push   %ebx
80100c66:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c69:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c6e:	e8 1a 32 00 00       	call   80103e8d <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c73:	83 c4 10             	add    $0x10,%esp
80100c76:	bb f4 ff 10 80       	mov    $0x8010fff4,%ebx
80100c7b:	eb 03                	jmp    80100c80 <filealloc+0x22>
80100c7d:	83 c3 18             	add    $0x18,%ebx
80100c80:	81 fb 54 09 11 80    	cmp    $0x80110954,%ebx
80100c86:	73 24                	jae    80100cac <filealloc+0x4e>
    if(f->ref == 0){
80100c88:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c8c:	75 ef                	jne    80100c7d <filealloc+0x1f>
      f->ref = 1;
80100c8e:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c95:	83 ec 0c             	sub    $0xc,%esp
80100c98:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c9d:	e8 54 32 00 00       	call   80103ef6 <release>
      return f;
80100ca2:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100ca5:	89 d8                	mov    %ebx,%eax
80100ca7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100caa:	c9                   	leave  
80100cab:	c3                   	ret    
  release(&ftable.lock);
80100cac:	83 ec 0c             	sub    $0xc,%esp
80100caf:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cb4:	e8 3d 32 00 00       	call   80103ef6 <release>
  return 0;
80100cb9:	83 c4 10             	add    $0x10,%esp
80100cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
80100cc1:	eb e2                	jmp    80100ca5 <filealloc+0x47>

80100cc3 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100cc3:	f3 0f 1e fb          	endbr32 
80100cc7:	55                   	push   %ebp
80100cc8:	89 e5                	mov    %esp,%ebp
80100cca:	53                   	push   %ebx
80100ccb:	83 ec 10             	sub    $0x10,%esp
80100cce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100cd1:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cd6:	e8 b2 31 00 00       	call   80103e8d <acquire>
  if(f->ref < 1)
80100cdb:	8b 43 04             	mov    0x4(%ebx),%eax
80100cde:	83 c4 10             	add    $0x10,%esp
80100ce1:	85 c0                	test   %eax,%eax
80100ce3:	7e 1a                	jle    80100cff <filedup+0x3c>
    panic("filedup");
  f->ref++;
80100ce5:	83 c0 01             	add    $0x1,%eax
80100ce8:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ceb:	83 ec 0c             	sub    $0xc,%esp
80100cee:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cf3:	e8 fe 31 00 00       	call   80103ef6 <release>
  return f;
}
80100cf8:	89 d8                	mov    %ebx,%eax
80100cfa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cfd:	c9                   	leave  
80100cfe:	c3                   	ret    
    panic("filedup");
80100cff:	83 ec 0c             	sub    $0xc,%esp
80100d02:	68 d4 6e 10 80       	push   $0x80106ed4
80100d07:	e8 50 f6 ff ff       	call   8010035c <panic>

80100d0c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100d0c:	f3 0f 1e fb          	endbr32 
80100d10:	55                   	push   %ebp
80100d11:	89 e5                	mov    %esp,%ebp
80100d13:	53                   	push   %ebx
80100d14:	83 ec 30             	sub    $0x30,%esp
80100d17:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100d1a:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d1f:	e8 69 31 00 00       	call   80103e8d <acquire>
  if(f->ref < 1)
80100d24:	8b 43 04             	mov    0x4(%ebx),%eax
80100d27:	83 c4 10             	add    $0x10,%esp
80100d2a:	85 c0                	test   %eax,%eax
80100d2c:	7e 65                	jle    80100d93 <fileclose+0x87>
    panic("fileclose");
  if(--f->ref > 0){
80100d2e:	83 e8 01             	sub    $0x1,%eax
80100d31:	89 43 04             	mov    %eax,0x4(%ebx)
80100d34:	85 c0                	test   %eax,%eax
80100d36:	7f 68                	jg     80100da0 <fileclose+0x94>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100d38:	8b 03                	mov    (%ebx),%eax
80100d3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d3d:	8b 43 08             	mov    0x8(%ebx),%eax
80100d40:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d43:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d46:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d49:	8b 43 10             	mov    0x10(%ebx),%eax
80100d4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d4f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d56:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d5c:	83 ec 0c             	sub    $0xc,%esp
80100d5f:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d64:	e8 8d 31 00 00       	call   80103ef6 <release>

  if(ff.type == FD_PIPE)
80100d69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d6c:	83 c4 10             	add    $0x10,%esp
80100d6f:	83 f8 01             	cmp    $0x1,%eax
80100d72:	74 41                	je     80100db5 <fileclose+0xa9>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100d74:	83 f8 02             	cmp    $0x2,%eax
80100d77:	75 37                	jne    80100db0 <fileclose+0xa4>
    begin_op();
80100d79:	e8 0e 1b 00 00       	call   8010288c <begin_op>
    iput(ff.ip);
80100d7e:	83 ec 0c             	sub    $0xc,%esp
80100d81:	ff 75 f0             	pushl  -0x10(%ebp)
80100d84:	e8 57 09 00 00       	call   801016e0 <iput>
    end_op();
80100d89:	e8 7c 1b 00 00       	call   8010290a <end_op>
80100d8e:	83 c4 10             	add    $0x10,%esp
80100d91:	eb 1d                	jmp    80100db0 <fileclose+0xa4>
    panic("fileclose");
80100d93:	83 ec 0c             	sub    $0xc,%esp
80100d96:	68 dc 6e 10 80       	push   $0x80106edc
80100d9b:	e8 bc f5 ff ff       	call   8010035c <panic>
    release(&ftable.lock);
80100da0:	83 ec 0c             	sub    $0xc,%esp
80100da3:	68 c0 ff 10 80       	push   $0x8010ffc0
80100da8:	e8 49 31 00 00       	call   80103ef6 <release>
    return;
80100dad:	83 c4 10             	add    $0x10,%esp
  }
}
80100db0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100db3:	c9                   	leave  
80100db4:	c3                   	ret    
    pipeclose(ff.pipe, ff.writable);
80100db5:	83 ec 08             	sub    $0x8,%esp
80100db8:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100dbc:	50                   	push   %eax
80100dbd:	ff 75 ec             	pushl  -0x14(%ebp)
80100dc0:	e8 a1 21 00 00       	call   80102f66 <pipeclose>
80100dc5:	83 c4 10             	add    $0x10,%esp
80100dc8:	eb e6                	jmp    80100db0 <fileclose+0xa4>

80100dca <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100dca:	f3 0f 1e fb          	endbr32 
80100dce:	55                   	push   %ebp
80100dcf:	89 e5                	mov    %esp,%ebp
80100dd1:	53                   	push   %ebx
80100dd2:	83 ec 04             	sub    $0x4,%esp
80100dd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100dd8:	83 3b 02             	cmpl   $0x2,(%ebx)
80100ddb:	75 31                	jne    80100e0e <filestat+0x44>
    ilock(f->ip);
80100ddd:	83 ec 0c             	sub    $0xc,%esp
80100de0:	ff 73 10             	pushl  0x10(%ebx)
80100de3:	e8 e9 07 00 00       	call   801015d1 <ilock>
    stati(f->ip, st);
80100de8:	83 c4 08             	add    $0x8,%esp
80100deb:	ff 75 0c             	pushl  0xc(%ebp)
80100dee:	ff 73 10             	pushl  0x10(%ebx)
80100df1:	e8 b2 09 00 00       	call   801017a8 <stati>
    iunlock(f->ip);
80100df6:	83 c4 04             	add    $0x4,%esp
80100df9:	ff 73 10             	pushl  0x10(%ebx)
80100dfc:	e8 96 08 00 00       	call   80101697 <iunlock>
    return 0;
80100e01:	83 c4 10             	add    $0x10,%esp
80100e04:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100e09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e0c:	c9                   	leave  
80100e0d:	c3                   	ret    
  return -1;
80100e0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e13:	eb f4                	jmp    80100e09 <filestat+0x3f>

80100e15 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100e15:	f3 0f 1e fb          	endbr32 
80100e19:	55                   	push   %ebp
80100e1a:	89 e5                	mov    %esp,%ebp
80100e1c:	56                   	push   %esi
80100e1d:	53                   	push   %ebx
80100e1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100e21:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100e25:	74 70                	je     80100e97 <fileread+0x82>
    return -1;
  if(f->type == FD_PIPE)
80100e27:	8b 03                	mov    (%ebx),%eax
80100e29:	83 f8 01             	cmp    $0x1,%eax
80100e2c:	74 44                	je     80100e72 <fileread+0x5d>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e2e:	83 f8 02             	cmp    $0x2,%eax
80100e31:	75 57                	jne    80100e8a <fileread+0x75>
    ilock(f->ip);
80100e33:	83 ec 0c             	sub    $0xc,%esp
80100e36:	ff 73 10             	pushl  0x10(%ebx)
80100e39:	e8 93 07 00 00       	call   801015d1 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100e3e:	ff 75 10             	pushl  0x10(%ebp)
80100e41:	ff 73 14             	pushl  0x14(%ebx)
80100e44:	ff 75 0c             	pushl  0xc(%ebp)
80100e47:	ff 73 10             	pushl  0x10(%ebx)
80100e4a:	e8 88 09 00 00       	call   801017d7 <readi>
80100e4f:	89 c6                	mov    %eax,%esi
80100e51:	83 c4 20             	add    $0x20,%esp
80100e54:	85 c0                	test   %eax,%eax
80100e56:	7e 03                	jle    80100e5b <fileread+0x46>
      f->off += r;
80100e58:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e5b:	83 ec 0c             	sub    $0xc,%esp
80100e5e:	ff 73 10             	pushl  0x10(%ebx)
80100e61:	e8 31 08 00 00       	call   80101697 <iunlock>
    return r;
80100e66:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e69:	89 f0                	mov    %esi,%eax
80100e6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e6e:	5b                   	pop    %ebx
80100e6f:	5e                   	pop    %esi
80100e70:	5d                   	pop    %ebp
80100e71:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e72:	83 ec 04             	sub    $0x4,%esp
80100e75:	ff 75 10             	pushl  0x10(%ebp)
80100e78:	ff 75 0c             	pushl  0xc(%ebp)
80100e7b:	ff 73 0c             	pushl  0xc(%ebx)
80100e7e:	e8 3d 22 00 00       	call   801030c0 <piperead>
80100e83:	89 c6                	mov    %eax,%esi
80100e85:	83 c4 10             	add    $0x10,%esp
80100e88:	eb df                	jmp    80100e69 <fileread+0x54>
  panic("fileread");
80100e8a:	83 ec 0c             	sub    $0xc,%esp
80100e8d:	68 e6 6e 10 80       	push   $0x80106ee6
80100e92:	e8 c5 f4 ff ff       	call   8010035c <panic>
    return -1;
80100e97:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e9c:	eb cb                	jmp    80100e69 <fileread+0x54>

80100e9e <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e9e:	f3 0f 1e fb          	endbr32 
80100ea2:	55                   	push   %ebp
80100ea3:	89 e5                	mov    %esp,%ebp
80100ea5:	57                   	push   %edi
80100ea6:	56                   	push   %esi
80100ea7:	53                   	push   %ebx
80100ea8:	83 ec 1c             	sub    $0x1c,%esp
80100eab:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;

  if(f->writable == 0)
80100eae:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
80100eb2:	0f 84 cc 00 00 00    	je     80100f84 <filewrite+0xe6>
    return -1;
  if(f->type == FD_PIPE)
80100eb8:	8b 06                	mov    (%esi),%eax
80100eba:	83 f8 01             	cmp    $0x1,%eax
80100ebd:	74 10                	je     80100ecf <filewrite+0x31>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100ebf:	83 f8 02             	cmp    $0x2,%eax
80100ec2:	0f 85 af 00 00 00    	jne    80100f77 <filewrite+0xd9>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100ec8:	bf 00 00 00 00       	mov    $0x0,%edi
80100ecd:	eb 67                	jmp    80100f36 <filewrite+0x98>
    return pipewrite(f->pipe, addr, n);
80100ecf:	83 ec 04             	sub    $0x4,%esp
80100ed2:	ff 75 10             	pushl  0x10(%ebp)
80100ed5:	ff 75 0c             	pushl  0xc(%ebp)
80100ed8:	ff 76 0c             	pushl  0xc(%esi)
80100edb:	e8 16 21 00 00       	call   80102ff6 <pipewrite>
80100ee0:	83 c4 10             	add    $0x10,%esp
80100ee3:	e9 82 00 00 00       	jmp    80100f6a <filewrite+0xcc>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ee8:	e8 9f 19 00 00       	call   8010288c <begin_op>
      ilock(f->ip);
80100eed:	83 ec 0c             	sub    $0xc,%esp
80100ef0:	ff 76 10             	pushl  0x10(%esi)
80100ef3:	e8 d9 06 00 00       	call   801015d1 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100ef8:	ff 75 e4             	pushl  -0x1c(%ebp)
80100efb:	ff 76 14             	pushl  0x14(%esi)
80100efe:	89 f8                	mov    %edi,%eax
80100f00:	03 45 0c             	add    0xc(%ebp),%eax
80100f03:	50                   	push   %eax
80100f04:	ff 76 10             	pushl  0x10(%esi)
80100f07:	e8 cc 09 00 00       	call   801018d8 <writei>
80100f0c:	89 c3                	mov    %eax,%ebx
80100f0e:	83 c4 20             	add    $0x20,%esp
80100f11:	85 c0                	test   %eax,%eax
80100f13:	7e 03                	jle    80100f18 <filewrite+0x7a>
        f->off += r;
80100f15:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
80100f18:	83 ec 0c             	sub    $0xc,%esp
80100f1b:	ff 76 10             	pushl  0x10(%esi)
80100f1e:	e8 74 07 00 00       	call   80101697 <iunlock>
      end_op();
80100f23:	e8 e2 19 00 00       	call   8010290a <end_op>

      if(r < 0)
80100f28:	83 c4 10             	add    $0x10,%esp
80100f2b:	85 db                	test   %ebx,%ebx
80100f2d:	78 31                	js     80100f60 <filewrite+0xc2>
        break;
      if(r != n1)
80100f2f:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80100f32:	75 1f                	jne    80100f53 <filewrite+0xb5>
        panic("short filewrite");
      i += r;
80100f34:	01 df                	add    %ebx,%edi
    while(i < n){
80100f36:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f39:	7d 25                	jge    80100f60 <filewrite+0xc2>
      int n1 = n - i;
80100f3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100f3e:	29 f8                	sub    %edi,%eax
80100f40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100f43:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f48:	7e 9e                	jle    80100ee8 <filewrite+0x4a>
        n1 = max;
80100f4a:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f51:	eb 95                	jmp    80100ee8 <filewrite+0x4a>
        panic("short filewrite");
80100f53:	83 ec 0c             	sub    $0xc,%esp
80100f56:	68 ef 6e 10 80       	push   $0x80106eef
80100f5b:	e8 fc f3 ff ff       	call   8010035c <panic>
    }
    return i == n ? n : -1;
80100f60:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f63:	74 0d                	je     80100f72 <filewrite+0xd4>
80100f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f6d:	5b                   	pop    %ebx
80100f6e:	5e                   	pop    %esi
80100f6f:	5f                   	pop    %edi
80100f70:	5d                   	pop    %ebp
80100f71:	c3                   	ret    
    return i == n ? n : -1;
80100f72:	8b 45 10             	mov    0x10(%ebp),%eax
80100f75:	eb f3                	jmp    80100f6a <filewrite+0xcc>
  panic("filewrite");
80100f77:	83 ec 0c             	sub    $0xc,%esp
80100f7a:	68 f5 6e 10 80       	push   $0x80106ef5
80100f7f:	e8 d8 f3 ff ff       	call   8010035c <panic>
    return -1;
80100f84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f89:	eb df                	jmp    80100f6a <filewrite+0xcc>

80100f8b <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f8b:	55                   	push   %ebp
80100f8c:	89 e5                	mov    %esp,%ebp
80100f8e:	57                   	push   %edi
80100f8f:	56                   	push   %esi
80100f90:	53                   	push   %ebx
80100f91:	83 ec 0c             	sub    $0xc,%esp
80100f94:	89 d6                	mov    %edx,%esi
  char *s;
  int len;

  while(*path == '/')
80100f96:	0f b6 10             	movzbl (%eax),%edx
80100f99:	80 fa 2f             	cmp    $0x2f,%dl
80100f9c:	75 05                	jne    80100fa3 <skipelem+0x18>
    path++;
80100f9e:	83 c0 01             	add    $0x1,%eax
80100fa1:	eb f3                	jmp    80100f96 <skipelem+0xb>
  if(*path == 0)
80100fa3:	84 d2                	test   %dl,%dl
80100fa5:	74 59                	je     80101000 <skipelem+0x75>
80100fa7:	89 c3                	mov    %eax,%ebx
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80100fa9:	0f b6 13             	movzbl (%ebx),%edx
80100fac:	80 fa 2f             	cmp    $0x2f,%dl
80100faf:	0f 95 c1             	setne  %cl
80100fb2:	84 d2                	test   %dl,%dl
80100fb4:	0f 95 c2             	setne  %dl
80100fb7:	84 d1                	test   %dl,%cl
80100fb9:	74 05                	je     80100fc0 <skipelem+0x35>
    path++;
80100fbb:	83 c3 01             	add    $0x1,%ebx
80100fbe:	eb e9                	jmp    80100fa9 <skipelem+0x1e>
  len = path - s;
80100fc0:	89 df                	mov    %ebx,%edi
80100fc2:	29 c7                	sub    %eax,%edi
  if(len >= DIRSIZ)
80100fc4:	83 ff 0d             	cmp    $0xd,%edi
80100fc7:	7e 11                	jle    80100fda <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100fc9:	83 ec 04             	sub    $0x4,%esp
80100fcc:	6a 0e                	push   $0xe
80100fce:	50                   	push   %eax
80100fcf:	56                   	push   %esi
80100fd0:	e8 ec 2f 00 00       	call   80103fc1 <memmove>
80100fd5:	83 c4 10             	add    $0x10,%esp
80100fd8:	eb 17                	jmp    80100ff1 <skipelem+0x66>
  else {
    memmove(name, s, len);
80100fda:	83 ec 04             	sub    $0x4,%esp
80100fdd:	57                   	push   %edi
80100fde:	50                   	push   %eax
80100fdf:	56                   	push   %esi
80100fe0:	e8 dc 2f 00 00       	call   80103fc1 <memmove>
    name[len] = 0;
80100fe5:	c6 04 3e 00          	movb   $0x0,(%esi,%edi,1)
80100fe9:	83 c4 10             	add    $0x10,%esp
80100fec:	eb 03                	jmp    80100ff1 <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fee:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100ff1:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100ff4:	74 f8                	je     80100fee <skipelem+0x63>
  return path;
}
80100ff6:	89 d8                	mov    %ebx,%eax
80100ff8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100ffb:	5b                   	pop    %ebx
80100ffc:	5e                   	pop    %esi
80100ffd:	5f                   	pop    %edi
80100ffe:	5d                   	pop    %ebp
80100fff:	c3                   	ret    
    return 0;
80101000:	bb 00 00 00 00       	mov    $0x0,%ebx
80101005:	eb ef                	jmp    80100ff6 <skipelem+0x6b>

80101007 <bzero>:
{
80101007:	55                   	push   %ebp
80101008:	89 e5                	mov    %esp,%ebp
8010100a:	53                   	push   %ebx
8010100b:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
8010100e:	52                   	push   %edx
8010100f:	50                   	push   %eax
80101010:	e8 5b f1 ff ff       	call   80100170 <bread>
80101015:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80101017:	8d 40 5c             	lea    0x5c(%eax),%eax
8010101a:	83 c4 0c             	add    $0xc,%esp
8010101d:	68 00 02 00 00       	push   $0x200
80101022:	6a 00                	push   $0x0
80101024:	50                   	push   %eax
80101025:	e8 17 2f 00 00       	call   80103f41 <memset>
  log_write(bp);
8010102a:	89 1c 24             	mov    %ebx,(%esp)
8010102d:	e8 8b 19 00 00       	call   801029bd <log_write>
  brelse(bp);
80101032:	89 1c 24             	mov    %ebx,(%esp)
80101035:	e8 a7 f1 ff ff       	call   801001e1 <brelse>
}
8010103a:	83 c4 10             	add    $0x10,%esp
8010103d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101040:	c9                   	leave  
80101041:	c3                   	ret    

80101042 <bfree>:
{
80101042:	55                   	push   %ebp
80101043:	89 e5                	mov    %esp,%ebp
80101045:	57                   	push   %edi
80101046:	56                   	push   %esi
80101047:	53                   	push   %ebx
80101048:	83 ec 14             	sub    $0x14,%esp
8010104b:	89 c3                	mov    %eax,%ebx
8010104d:	89 d6                	mov    %edx,%esi
  bp = bread(dev, BBLOCK(b, sb));
8010104f:	89 d0                	mov    %edx,%eax
80101051:	c1 e8 0c             	shr    $0xc,%eax
80101054:	03 05 d8 09 11 80    	add    0x801109d8,%eax
8010105a:	50                   	push   %eax
8010105b:	53                   	push   %ebx
8010105c:	e8 0f f1 ff ff       	call   80100170 <bread>
80101061:	89 c3                	mov    %eax,%ebx
  bi = b % BPB;
80101063:	89 f7                	mov    %esi,%edi
80101065:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
  m = 1 << (bi % 8);
8010106b:	89 f1                	mov    %esi,%ecx
8010106d:	83 e1 07             	and    $0x7,%ecx
80101070:	b8 01 00 00 00       	mov    $0x1,%eax
80101075:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101077:	83 c4 10             	add    $0x10,%esp
8010107a:	c1 ff 03             	sar    $0x3,%edi
8010107d:	0f b6 54 3b 5c       	movzbl 0x5c(%ebx,%edi,1),%edx
80101082:	0f b6 ca             	movzbl %dl,%ecx
80101085:	85 c1                	test   %eax,%ecx
80101087:	74 24                	je     801010ad <bfree+0x6b>
  bp->data[bi/8] &= ~m;
80101089:	f7 d0                	not    %eax
8010108b:	21 d0                	and    %edx,%eax
8010108d:	88 44 3b 5c          	mov    %al,0x5c(%ebx,%edi,1)
  log_write(bp);
80101091:	83 ec 0c             	sub    $0xc,%esp
80101094:	53                   	push   %ebx
80101095:	e8 23 19 00 00       	call   801029bd <log_write>
  brelse(bp);
8010109a:	89 1c 24             	mov    %ebx,(%esp)
8010109d:	e8 3f f1 ff ff       	call   801001e1 <brelse>
}
801010a2:	83 c4 10             	add    $0x10,%esp
801010a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010a8:	5b                   	pop    %ebx
801010a9:	5e                   	pop    %esi
801010aa:	5f                   	pop    %edi
801010ab:	5d                   	pop    %ebp
801010ac:	c3                   	ret    
    panic("freeing free block");
801010ad:	83 ec 0c             	sub    $0xc,%esp
801010b0:	68 ff 6e 10 80       	push   $0x80106eff
801010b5:	e8 a2 f2 ff ff       	call   8010035c <panic>

801010ba <balloc>:
{
801010ba:	55                   	push   %ebp
801010bb:	89 e5                	mov    %esp,%ebp
801010bd:	57                   	push   %edi
801010be:	56                   	push   %esi
801010bf:	53                   	push   %ebx
801010c0:	83 ec 1c             	sub    $0x1c,%esp
801010c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801010c6:	be 00 00 00 00       	mov    $0x0,%esi
801010cb:	eb 14                	jmp    801010e1 <balloc+0x27>
    brelse(bp);
801010cd:	83 ec 0c             	sub    $0xc,%esp
801010d0:	ff 75 e4             	pushl  -0x1c(%ebp)
801010d3:	e8 09 f1 ff ff       	call   801001e1 <brelse>
  for(b = 0; b < sb.size; b += BPB){
801010d8:	81 c6 00 10 00 00    	add    $0x1000,%esi
801010de:	83 c4 10             	add    $0x10,%esp
801010e1:	39 35 c0 09 11 80    	cmp    %esi,0x801109c0
801010e7:	76 75                	jbe    8010115e <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
801010e9:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
801010ef:	85 f6                	test   %esi,%esi
801010f1:	0f 49 c6             	cmovns %esi,%eax
801010f4:	c1 f8 0c             	sar    $0xc,%eax
801010f7:	83 ec 08             	sub    $0x8,%esp
801010fa:	03 05 d8 09 11 80    	add    0x801109d8,%eax
80101100:	50                   	push   %eax
80101101:	ff 75 d8             	pushl  -0x28(%ebp)
80101104:	e8 67 f0 ff ff       	call   80100170 <bread>
80101109:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010110c:	83 c4 10             	add    $0x10,%esp
8010110f:	b8 00 00 00 00       	mov    $0x0,%eax
80101114:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80101119:	7f b2                	jg     801010cd <balloc+0x13>
8010111b:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
8010111e:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80101121:	3b 1d c0 09 11 80    	cmp    0x801109c0,%ebx
80101127:	73 a4                	jae    801010cd <balloc+0x13>
      m = 1 << (bi % 8);
80101129:	99                   	cltd   
8010112a:	c1 ea 1d             	shr    $0x1d,%edx
8010112d:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80101130:	83 e1 07             	and    $0x7,%ecx
80101133:	29 d1                	sub    %edx,%ecx
80101135:	ba 01 00 00 00       	mov    $0x1,%edx
8010113a:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010113c:	8d 48 07             	lea    0x7(%eax),%ecx
8010113f:	85 c0                	test   %eax,%eax
80101141:	0f 49 c8             	cmovns %eax,%ecx
80101144:	c1 f9 03             	sar    $0x3,%ecx
80101147:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010114a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010114d:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
80101152:	0f b6 f9             	movzbl %cl,%edi
80101155:	85 d7                	test   %edx,%edi
80101157:	74 12                	je     8010116b <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101159:	83 c0 01             	add    $0x1,%eax
8010115c:	eb b6                	jmp    80101114 <balloc+0x5a>
  panic("balloc: out of blocks");
8010115e:	83 ec 0c             	sub    $0xc,%esp
80101161:	68 12 6f 10 80       	push   $0x80106f12
80101166:	e8 f1 f1 ff ff       	call   8010035c <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
8010116b:	09 ca                	or     %ecx,%edx
8010116d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101170:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101173:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
80101177:	83 ec 0c             	sub    $0xc,%esp
8010117a:	89 c6                	mov    %eax,%esi
8010117c:	50                   	push   %eax
8010117d:	e8 3b 18 00 00       	call   801029bd <log_write>
        brelse(bp);
80101182:	89 34 24             	mov    %esi,(%esp)
80101185:	e8 57 f0 ff ff       	call   801001e1 <brelse>
        bzero(dev, b + bi);
8010118a:	89 da                	mov    %ebx,%edx
8010118c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010118f:	e8 73 fe ff ff       	call   80101007 <bzero>
}
80101194:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101197:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010119a:	5b                   	pop    %ebx
8010119b:	5e                   	pop    %esi
8010119c:	5f                   	pop    %edi
8010119d:	5d                   	pop    %ebp
8010119e:	c3                   	ret    

8010119f <bmap>:
{
8010119f:	55                   	push   %ebp
801011a0:	89 e5                	mov    %esp,%ebp
801011a2:	57                   	push   %edi
801011a3:	56                   	push   %esi
801011a4:	53                   	push   %ebx
801011a5:	83 ec 1c             	sub    $0x1c,%esp
801011a8:	89 c3                	mov    %eax,%ebx
801011aa:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
801011ac:	83 fa 0b             	cmp    $0xb,%edx
801011af:	76 45                	jbe    801011f6 <bmap+0x57>
  bn -= NDIRECT;
801011b1:	8d 72 f4             	lea    -0xc(%edx),%esi
  if(bn < NINDIRECT){
801011b4:	83 fe 7f             	cmp    $0x7f,%esi
801011b7:	77 7f                	ja     80101238 <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
801011b9:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801011bf:	85 c0                	test   %eax,%eax
801011c1:	74 4a                	je     8010120d <bmap+0x6e>
    bp = bread(ip->dev, addr);
801011c3:	83 ec 08             	sub    $0x8,%esp
801011c6:	50                   	push   %eax
801011c7:	ff 33                	pushl  (%ebx)
801011c9:	e8 a2 ef ff ff       	call   80100170 <bread>
801011ce:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
801011d0:	8d 44 b0 5c          	lea    0x5c(%eax,%esi,4),%eax
801011d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801011d7:	8b 30                	mov    (%eax),%esi
801011d9:	83 c4 10             	add    $0x10,%esp
801011dc:	85 f6                	test   %esi,%esi
801011de:	74 3c                	je     8010121c <bmap+0x7d>
    brelse(bp);
801011e0:	83 ec 0c             	sub    $0xc,%esp
801011e3:	57                   	push   %edi
801011e4:	e8 f8 ef ff ff       	call   801001e1 <brelse>
    return addr;
801011e9:	83 c4 10             	add    $0x10,%esp
}
801011ec:	89 f0                	mov    %esi,%eax
801011ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011f1:	5b                   	pop    %ebx
801011f2:	5e                   	pop    %esi
801011f3:	5f                   	pop    %edi
801011f4:	5d                   	pop    %ebp
801011f5:	c3                   	ret    
    if((addr = ip->addrs[bn]) == 0)
801011f6:	8b 74 90 5c          	mov    0x5c(%eax,%edx,4),%esi
801011fa:	85 f6                	test   %esi,%esi
801011fc:	75 ee                	jne    801011ec <bmap+0x4d>
      ip->addrs[bn] = addr = balloc(ip->dev);
801011fe:	8b 00                	mov    (%eax),%eax
80101200:	e8 b5 fe ff ff       	call   801010ba <balloc>
80101205:	89 c6                	mov    %eax,%esi
80101207:	89 44 bb 5c          	mov    %eax,0x5c(%ebx,%edi,4)
    return addr;
8010120b:	eb df                	jmp    801011ec <bmap+0x4d>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010120d:	8b 03                	mov    (%ebx),%eax
8010120f:	e8 a6 fe ff ff       	call   801010ba <balloc>
80101214:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
8010121a:	eb a7                	jmp    801011c3 <bmap+0x24>
      a[bn] = addr = balloc(ip->dev);
8010121c:	8b 03                	mov    (%ebx),%eax
8010121e:	e8 97 fe ff ff       	call   801010ba <balloc>
80101223:	89 c6                	mov    %eax,%esi
80101225:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101228:	89 30                	mov    %esi,(%eax)
      log_write(bp);
8010122a:	83 ec 0c             	sub    $0xc,%esp
8010122d:	57                   	push   %edi
8010122e:	e8 8a 17 00 00       	call   801029bd <log_write>
80101233:	83 c4 10             	add    $0x10,%esp
80101236:	eb a8                	jmp    801011e0 <bmap+0x41>
  panic("bmap: out of range");
80101238:	83 ec 0c             	sub    $0xc,%esp
8010123b:	68 28 6f 10 80       	push   $0x80106f28
80101240:	e8 17 f1 ff ff       	call   8010035c <panic>

80101245 <iget>:
{
80101245:	55                   	push   %ebp
80101246:	89 e5                	mov    %esp,%ebp
80101248:	57                   	push   %edi
80101249:	56                   	push   %esi
8010124a:	53                   	push   %ebx
8010124b:	83 ec 28             	sub    $0x28,%esp
8010124e:	89 c7                	mov    %eax,%edi
80101250:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101253:	68 e0 09 11 80       	push   $0x801109e0
80101258:	e8 30 2c 00 00       	call   80103e8d <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010125d:	83 c4 10             	add    $0x10,%esp
  empty = 0;
80101260:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101265:	bb 14 0a 11 80       	mov    $0x80110a14,%ebx
8010126a:	eb 0a                	jmp    80101276 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010126c:	85 f6                	test   %esi,%esi
8010126e:	74 3b                	je     801012ab <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101270:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101276:	81 fb 34 26 11 80    	cmp    $0x80112634,%ebx
8010127c:	73 35                	jae    801012b3 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010127e:	8b 43 08             	mov    0x8(%ebx),%eax
80101281:	85 c0                	test   %eax,%eax
80101283:	7e e7                	jle    8010126c <iget+0x27>
80101285:	39 3b                	cmp    %edi,(%ebx)
80101287:	75 e3                	jne    8010126c <iget+0x27>
80101289:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010128c:	39 4b 04             	cmp    %ecx,0x4(%ebx)
8010128f:	75 db                	jne    8010126c <iget+0x27>
      ip->ref++;
80101291:	83 c0 01             	add    $0x1,%eax
80101294:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101297:	83 ec 0c             	sub    $0xc,%esp
8010129a:	68 e0 09 11 80       	push   $0x801109e0
8010129f:	e8 52 2c 00 00       	call   80103ef6 <release>
      return ip;
801012a4:	83 c4 10             	add    $0x10,%esp
801012a7:	89 de                	mov    %ebx,%esi
801012a9:	eb 32                	jmp    801012dd <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801012ab:	85 c0                	test   %eax,%eax
801012ad:	75 c1                	jne    80101270 <iget+0x2b>
      empty = ip;
801012af:	89 de                	mov    %ebx,%esi
801012b1:	eb bd                	jmp    80101270 <iget+0x2b>
  if(empty == 0)
801012b3:	85 f6                	test   %esi,%esi
801012b5:	74 30                	je     801012e7 <iget+0xa2>
  ip->dev = dev;
801012b7:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801012b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801012bc:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
801012bf:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801012c6:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801012cd:	83 ec 0c             	sub    $0xc,%esp
801012d0:	68 e0 09 11 80       	push   $0x801109e0
801012d5:	e8 1c 2c 00 00       	call   80103ef6 <release>
  return ip;
801012da:	83 c4 10             	add    $0x10,%esp
}
801012dd:	89 f0                	mov    %esi,%eax
801012df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012e2:	5b                   	pop    %ebx
801012e3:	5e                   	pop    %esi
801012e4:	5f                   	pop    %edi
801012e5:	5d                   	pop    %ebp
801012e6:	c3                   	ret    
    panic("iget: no inodes");
801012e7:	83 ec 0c             	sub    $0xc,%esp
801012ea:	68 3b 6f 10 80       	push   $0x80106f3b
801012ef:	e8 68 f0 ff ff       	call   8010035c <panic>

801012f4 <readsb>:
{
801012f4:	f3 0f 1e fb          	endbr32 
801012f8:	55                   	push   %ebp
801012f9:	89 e5                	mov    %esp,%ebp
801012fb:	53                   	push   %ebx
801012fc:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
801012ff:	6a 01                	push   $0x1
80101301:	ff 75 08             	pushl  0x8(%ebp)
80101304:	e8 67 ee ff ff       	call   80100170 <bread>
80101309:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010130b:	8d 40 5c             	lea    0x5c(%eax),%eax
8010130e:	83 c4 0c             	add    $0xc,%esp
80101311:	6a 1c                	push   $0x1c
80101313:	50                   	push   %eax
80101314:	ff 75 0c             	pushl  0xc(%ebp)
80101317:	e8 a5 2c 00 00       	call   80103fc1 <memmove>
  brelse(bp);
8010131c:	89 1c 24             	mov    %ebx,(%esp)
8010131f:	e8 bd ee ff ff       	call   801001e1 <brelse>
}
80101324:	83 c4 10             	add    $0x10,%esp
80101327:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010132a:	c9                   	leave  
8010132b:	c3                   	ret    

8010132c <iinit>:
{
8010132c:	f3 0f 1e fb          	endbr32 
80101330:	55                   	push   %ebp
80101331:	89 e5                	mov    %esp,%ebp
80101333:	53                   	push   %ebx
80101334:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
80101337:	68 4b 6f 10 80       	push   $0x80106f4b
8010133c:	68 e0 09 11 80       	push   $0x801109e0
80101341:	e8 f7 29 00 00       	call   80103d3d <initlock>
  for(i = 0; i < NINODE; i++) {
80101346:	83 c4 10             	add    $0x10,%esp
80101349:	bb 00 00 00 00       	mov    $0x0,%ebx
8010134e:	83 fb 31             	cmp    $0x31,%ebx
80101351:	7f 23                	jg     80101376 <iinit+0x4a>
    initsleeplock(&icache.inode[i].lock, "inode");
80101353:	83 ec 08             	sub    $0x8,%esp
80101356:	68 52 6f 10 80       	push   $0x80106f52
8010135b:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
8010135e:	89 d0                	mov    %edx,%eax
80101360:	c1 e0 04             	shl    $0x4,%eax
80101363:	05 20 0a 11 80       	add    $0x80110a20,%eax
80101368:	50                   	push   %eax
80101369:	e8 b4 28 00 00       	call   80103c22 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
8010136e:	83 c3 01             	add    $0x1,%ebx
80101371:	83 c4 10             	add    $0x10,%esp
80101374:	eb d8                	jmp    8010134e <iinit+0x22>
  readsb(dev, &sb);
80101376:	83 ec 08             	sub    $0x8,%esp
80101379:	68 c0 09 11 80       	push   $0x801109c0
8010137e:	ff 75 08             	pushl  0x8(%ebp)
80101381:	e8 6e ff ff ff       	call   801012f4 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101386:	ff 35 d8 09 11 80    	pushl  0x801109d8
8010138c:	ff 35 d4 09 11 80    	pushl  0x801109d4
80101392:	ff 35 d0 09 11 80    	pushl  0x801109d0
80101398:	ff 35 cc 09 11 80    	pushl  0x801109cc
8010139e:	ff 35 c8 09 11 80    	pushl  0x801109c8
801013a4:	ff 35 c4 09 11 80    	pushl  0x801109c4
801013aa:	ff 35 c0 09 11 80    	pushl  0x801109c0
801013b0:	68 b8 6f 10 80       	push   $0x80106fb8
801013b5:	e8 6f f2 ff ff       	call   80100629 <cprintf>
}
801013ba:	83 c4 30             	add    $0x30,%esp
801013bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013c0:	c9                   	leave  
801013c1:	c3                   	ret    

801013c2 <ialloc>:
{
801013c2:	f3 0f 1e fb          	endbr32 
801013c6:	55                   	push   %ebp
801013c7:	89 e5                	mov    %esp,%ebp
801013c9:	57                   	push   %edi
801013ca:	56                   	push   %esi
801013cb:	53                   	push   %ebx
801013cc:	83 ec 1c             	sub    $0x1c,%esp
801013cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801013d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
801013d5:	bb 01 00 00 00       	mov    $0x1,%ebx
801013da:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801013dd:	39 1d c8 09 11 80    	cmp    %ebx,0x801109c8
801013e3:	76 76                	jbe    8010145b <ialloc+0x99>
    bp = bread(dev, IBLOCK(inum, sb));
801013e5:	89 d8                	mov    %ebx,%eax
801013e7:	c1 e8 03             	shr    $0x3,%eax
801013ea:	83 ec 08             	sub    $0x8,%esp
801013ed:	03 05 d4 09 11 80    	add    0x801109d4,%eax
801013f3:	50                   	push   %eax
801013f4:	ff 75 08             	pushl  0x8(%ebp)
801013f7:	e8 74 ed ff ff       	call   80100170 <bread>
801013fc:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013fe:	89 d8                	mov    %ebx,%eax
80101400:	83 e0 07             	and    $0x7,%eax
80101403:	c1 e0 06             	shl    $0x6,%eax
80101406:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
8010140a:	83 c4 10             	add    $0x10,%esp
8010140d:	66 83 3f 00          	cmpw   $0x0,(%edi)
80101411:	74 11                	je     80101424 <ialloc+0x62>
    brelse(bp);
80101413:	83 ec 0c             	sub    $0xc,%esp
80101416:	56                   	push   %esi
80101417:	e8 c5 ed ff ff       	call   801001e1 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010141c:	83 c3 01             	add    $0x1,%ebx
8010141f:	83 c4 10             	add    $0x10,%esp
80101422:	eb b6                	jmp    801013da <ialloc+0x18>
      memset(dip, 0, sizeof(*dip));
80101424:	83 ec 04             	sub    $0x4,%esp
80101427:	6a 40                	push   $0x40
80101429:	6a 00                	push   $0x0
8010142b:	57                   	push   %edi
8010142c:	e8 10 2b 00 00       	call   80103f41 <memset>
      dip->type = type;
80101431:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80101435:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
80101438:	89 34 24             	mov    %esi,(%esp)
8010143b:	e8 7d 15 00 00       	call   801029bd <log_write>
      brelse(bp);
80101440:	89 34 24             	mov    %esi,(%esp)
80101443:	e8 99 ed ff ff       	call   801001e1 <brelse>
      return iget(dev, inum);
80101448:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010144b:	8b 45 08             	mov    0x8(%ebp),%eax
8010144e:	e8 f2 fd ff ff       	call   80101245 <iget>
}
80101453:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101456:	5b                   	pop    %ebx
80101457:	5e                   	pop    %esi
80101458:	5f                   	pop    %edi
80101459:	5d                   	pop    %ebp
8010145a:	c3                   	ret    
  panic("ialloc: no inodes");
8010145b:	83 ec 0c             	sub    $0xc,%esp
8010145e:	68 58 6f 10 80       	push   $0x80106f58
80101463:	e8 f4 ee ff ff       	call   8010035c <panic>

80101468 <iupdate>:
{
80101468:	f3 0f 1e fb          	endbr32 
8010146c:	55                   	push   %ebp
8010146d:	89 e5                	mov    %esp,%ebp
8010146f:	56                   	push   %esi
80101470:	53                   	push   %ebx
80101471:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101474:	8b 43 04             	mov    0x4(%ebx),%eax
80101477:	c1 e8 03             	shr    $0x3,%eax
8010147a:	83 ec 08             	sub    $0x8,%esp
8010147d:	03 05 d4 09 11 80    	add    0x801109d4,%eax
80101483:	50                   	push   %eax
80101484:	ff 33                	pushl  (%ebx)
80101486:	e8 e5 ec ff ff       	call   80100170 <bread>
8010148b:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010148d:	8b 43 04             	mov    0x4(%ebx),%eax
80101490:	83 e0 07             	and    $0x7,%eax
80101493:	c1 e0 06             	shl    $0x6,%eax
80101496:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010149a:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
8010149e:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801014a1:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
801014a5:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801014a9:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
801014ad:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801014b1:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
801014b5:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801014b9:	8b 53 58             	mov    0x58(%ebx),%edx
801014bc:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801014bf:	83 c3 5c             	add    $0x5c,%ebx
801014c2:	83 c0 0c             	add    $0xc,%eax
801014c5:	83 c4 0c             	add    $0xc,%esp
801014c8:	6a 34                	push   $0x34
801014ca:	53                   	push   %ebx
801014cb:	50                   	push   %eax
801014cc:	e8 f0 2a 00 00       	call   80103fc1 <memmove>
  log_write(bp);
801014d1:	89 34 24             	mov    %esi,(%esp)
801014d4:	e8 e4 14 00 00       	call   801029bd <log_write>
  brelse(bp);
801014d9:	89 34 24             	mov    %esi,(%esp)
801014dc:	e8 00 ed ff ff       	call   801001e1 <brelse>
}
801014e1:	83 c4 10             	add    $0x10,%esp
801014e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801014e7:	5b                   	pop    %ebx
801014e8:	5e                   	pop    %esi
801014e9:	5d                   	pop    %ebp
801014ea:	c3                   	ret    

801014eb <itrunc>:
{
801014eb:	55                   	push   %ebp
801014ec:	89 e5                	mov    %esp,%ebp
801014ee:	57                   	push   %edi
801014ef:	56                   	push   %esi
801014f0:	53                   	push   %ebx
801014f1:	83 ec 1c             	sub    $0x1c,%esp
801014f4:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801014f6:	bb 00 00 00 00       	mov    $0x0,%ebx
801014fb:	eb 03                	jmp    80101500 <itrunc+0x15>
801014fd:	83 c3 01             	add    $0x1,%ebx
80101500:	83 fb 0b             	cmp    $0xb,%ebx
80101503:	7f 19                	jg     8010151e <itrunc+0x33>
    if(ip->addrs[i]){
80101505:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
80101509:	85 d2                	test   %edx,%edx
8010150b:	74 f0                	je     801014fd <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
8010150d:	8b 06                	mov    (%esi),%eax
8010150f:	e8 2e fb ff ff       	call   80101042 <bfree>
      ip->addrs[i] = 0;
80101514:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
8010151b:	00 
8010151c:	eb df                	jmp    801014fd <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
8010151e:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
80101524:	85 c0                	test   %eax,%eax
80101526:	75 1b                	jne    80101543 <itrunc+0x58>
  ip->size = 0;
80101528:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
8010152f:	83 ec 0c             	sub    $0xc,%esp
80101532:	56                   	push   %esi
80101533:	e8 30 ff ff ff       	call   80101468 <iupdate>
}
80101538:	83 c4 10             	add    $0x10,%esp
8010153b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010153e:	5b                   	pop    %ebx
8010153f:	5e                   	pop    %esi
80101540:	5f                   	pop    %edi
80101541:	5d                   	pop    %ebp
80101542:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101543:	83 ec 08             	sub    $0x8,%esp
80101546:	50                   	push   %eax
80101547:	ff 36                	pushl  (%esi)
80101549:	e8 22 ec ff ff       	call   80100170 <bread>
8010154e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101551:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
80101554:	83 c4 10             	add    $0x10,%esp
80101557:	bb 00 00 00 00       	mov    $0x0,%ebx
8010155c:	eb 0a                	jmp    80101568 <itrunc+0x7d>
        bfree(ip->dev, a[j]);
8010155e:	8b 06                	mov    (%esi),%eax
80101560:	e8 dd fa ff ff       	call   80101042 <bfree>
    for(j = 0; j < NINDIRECT; j++){
80101565:	83 c3 01             	add    $0x1,%ebx
80101568:	83 fb 7f             	cmp    $0x7f,%ebx
8010156b:	77 09                	ja     80101576 <itrunc+0x8b>
      if(a[j])
8010156d:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
80101570:	85 d2                	test   %edx,%edx
80101572:	74 f1                	je     80101565 <itrunc+0x7a>
80101574:	eb e8                	jmp    8010155e <itrunc+0x73>
    brelse(bp);
80101576:	83 ec 0c             	sub    $0xc,%esp
80101579:	ff 75 e4             	pushl  -0x1c(%ebp)
8010157c:	e8 60 ec ff ff       	call   801001e1 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101581:	8b 06                	mov    (%esi),%eax
80101583:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
80101589:	e8 b4 fa ff ff       	call   80101042 <bfree>
    ip->addrs[NDIRECT] = 0;
8010158e:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101595:	00 00 00 
80101598:	83 c4 10             	add    $0x10,%esp
8010159b:	eb 8b                	jmp    80101528 <itrunc+0x3d>

8010159d <idup>:
{
8010159d:	f3 0f 1e fb          	endbr32 
801015a1:	55                   	push   %ebp
801015a2:	89 e5                	mov    %esp,%ebp
801015a4:	53                   	push   %ebx
801015a5:	83 ec 10             	sub    $0x10,%esp
801015a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801015ab:	68 e0 09 11 80       	push   $0x801109e0
801015b0:	e8 d8 28 00 00       	call   80103e8d <acquire>
  ip->ref++;
801015b5:	8b 43 08             	mov    0x8(%ebx),%eax
801015b8:	83 c0 01             	add    $0x1,%eax
801015bb:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801015be:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801015c5:	e8 2c 29 00 00       	call   80103ef6 <release>
}
801015ca:	89 d8                	mov    %ebx,%eax
801015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801015cf:	c9                   	leave  
801015d0:	c3                   	ret    

801015d1 <ilock>:
{
801015d1:	f3 0f 1e fb          	endbr32 
801015d5:	55                   	push   %ebp
801015d6:	89 e5                	mov    %esp,%ebp
801015d8:	56                   	push   %esi
801015d9:	53                   	push   %ebx
801015da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
801015dd:	85 db                	test   %ebx,%ebx
801015df:	74 22                	je     80101603 <ilock+0x32>
801015e1:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801015e5:	7e 1c                	jle    80101603 <ilock+0x32>
  acquiresleep(&ip->lock);
801015e7:	83 ec 0c             	sub    $0xc,%esp
801015ea:	8d 43 0c             	lea    0xc(%ebx),%eax
801015ed:	50                   	push   %eax
801015ee:	e8 66 26 00 00       	call   80103c59 <acquiresleep>
  if(ip->valid == 0){
801015f3:	83 c4 10             	add    $0x10,%esp
801015f6:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015fa:	74 14                	je     80101610 <ilock+0x3f>
}
801015fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015ff:	5b                   	pop    %ebx
80101600:	5e                   	pop    %esi
80101601:	5d                   	pop    %ebp
80101602:	c3                   	ret    
    panic("ilock");
80101603:	83 ec 0c             	sub    $0xc,%esp
80101606:	68 6a 6f 10 80       	push   $0x80106f6a
8010160b:	e8 4c ed ff ff       	call   8010035c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101610:	8b 43 04             	mov    0x4(%ebx),%eax
80101613:	c1 e8 03             	shr    $0x3,%eax
80101616:	83 ec 08             	sub    $0x8,%esp
80101619:	03 05 d4 09 11 80    	add    0x801109d4,%eax
8010161f:	50                   	push   %eax
80101620:	ff 33                	pushl  (%ebx)
80101622:	e8 49 eb ff ff       	call   80100170 <bread>
80101627:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101629:	8b 43 04             	mov    0x4(%ebx),%eax
8010162c:	83 e0 07             	and    $0x7,%eax
8010162f:	c1 e0 06             	shl    $0x6,%eax
80101632:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101636:	0f b7 10             	movzwl (%eax),%edx
80101639:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
8010163d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101641:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101645:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101649:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
8010164d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101651:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101655:	8b 50 08             	mov    0x8(%eax),%edx
80101658:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010165b:	83 c0 0c             	add    $0xc,%eax
8010165e:	8d 53 5c             	lea    0x5c(%ebx),%edx
80101661:	83 c4 0c             	add    $0xc,%esp
80101664:	6a 34                	push   $0x34
80101666:	50                   	push   %eax
80101667:	52                   	push   %edx
80101668:	e8 54 29 00 00       	call   80103fc1 <memmove>
    brelse(bp);
8010166d:	89 34 24             	mov    %esi,(%esp)
80101670:	e8 6c eb ff ff       	call   801001e1 <brelse>
    ip->valid = 1;
80101675:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
8010167c:	83 c4 10             	add    $0x10,%esp
8010167f:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
80101684:	0f 85 72 ff ff ff    	jne    801015fc <ilock+0x2b>
      panic("ilock: no type");
8010168a:	83 ec 0c             	sub    $0xc,%esp
8010168d:	68 70 6f 10 80       	push   $0x80106f70
80101692:	e8 c5 ec ff ff       	call   8010035c <panic>

80101697 <iunlock>:
{
80101697:	f3 0f 1e fb          	endbr32 
8010169b:	55                   	push   %ebp
8010169c:	89 e5                	mov    %esp,%ebp
8010169e:	56                   	push   %esi
8010169f:	53                   	push   %ebx
801016a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801016a3:	85 db                	test   %ebx,%ebx
801016a5:	74 2c                	je     801016d3 <iunlock+0x3c>
801016a7:	8d 73 0c             	lea    0xc(%ebx),%esi
801016aa:	83 ec 0c             	sub    $0xc,%esp
801016ad:	56                   	push   %esi
801016ae:	e8 38 26 00 00       	call   80103ceb <holdingsleep>
801016b3:	83 c4 10             	add    $0x10,%esp
801016b6:	85 c0                	test   %eax,%eax
801016b8:	74 19                	je     801016d3 <iunlock+0x3c>
801016ba:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801016be:	7e 13                	jle    801016d3 <iunlock+0x3c>
  releasesleep(&ip->lock);
801016c0:	83 ec 0c             	sub    $0xc,%esp
801016c3:	56                   	push   %esi
801016c4:	e8 e3 25 00 00       	call   80103cac <releasesleep>
}
801016c9:	83 c4 10             	add    $0x10,%esp
801016cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801016cf:	5b                   	pop    %ebx
801016d0:	5e                   	pop    %esi
801016d1:	5d                   	pop    %ebp
801016d2:	c3                   	ret    
    panic("iunlock");
801016d3:	83 ec 0c             	sub    $0xc,%esp
801016d6:	68 7f 6f 10 80       	push   $0x80106f7f
801016db:	e8 7c ec ff ff       	call   8010035c <panic>

801016e0 <iput>:
{
801016e0:	f3 0f 1e fb          	endbr32 
801016e4:	55                   	push   %ebp
801016e5:	89 e5                	mov    %esp,%ebp
801016e7:	57                   	push   %edi
801016e8:	56                   	push   %esi
801016e9:	53                   	push   %ebx
801016ea:	83 ec 18             	sub    $0x18,%esp
801016ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801016f0:	8d 73 0c             	lea    0xc(%ebx),%esi
801016f3:	56                   	push   %esi
801016f4:	e8 60 25 00 00       	call   80103c59 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801016f9:	83 c4 10             	add    $0x10,%esp
801016fc:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101700:	74 07                	je     80101709 <iput+0x29>
80101702:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101707:	74 35                	je     8010173e <iput+0x5e>
  releasesleep(&ip->lock);
80101709:	83 ec 0c             	sub    $0xc,%esp
8010170c:	56                   	push   %esi
8010170d:	e8 9a 25 00 00       	call   80103cac <releasesleep>
  acquire(&icache.lock);
80101712:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101719:	e8 6f 27 00 00       	call   80103e8d <acquire>
  ip->ref--;
8010171e:	8b 43 08             	mov    0x8(%ebx),%eax
80101721:	83 e8 01             	sub    $0x1,%eax
80101724:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
80101727:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
8010172e:	e8 c3 27 00 00       	call   80103ef6 <release>
}
80101733:	83 c4 10             	add    $0x10,%esp
80101736:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101739:	5b                   	pop    %ebx
8010173a:	5e                   	pop    %esi
8010173b:	5f                   	pop    %edi
8010173c:	5d                   	pop    %ebp
8010173d:	c3                   	ret    
    acquire(&icache.lock);
8010173e:	83 ec 0c             	sub    $0xc,%esp
80101741:	68 e0 09 11 80       	push   $0x801109e0
80101746:	e8 42 27 00 00       	call   80103e8d <acquire>
    int r = ip->ref;
8010174b:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
8010174e:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101755:	e8 9c 27 00 00       	call   80103ef6 <release>
    if(r == 1){
8010175a:	83 c4 10             	add    $0x10,%esp
8010175d:	83 ff 01             	cmp    $0x1,%edi
80101760:	75 a7                	jne    80101709 <iput+0x29>
      itrunc(ip);
80101762:	89 d8                	mov    %ebx,%eax
80101764:	e8 82 fd ff ff       	call   801014eb <itrunc>
      ip->type = 0;
80101769:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
8010176f:	83 ec 0c             	sub    $0xc,%esp
80101772:	53                   	push   %ebx
80101773:	e8 f0 fc ff ff       	call   80101468 <iupdate>
      ip->valid = 0;
80101778:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
8010177f:	83 c4 10             	add    $0x10,%esp
80101782:	eb 85                	jmp    80101709 <iput+0x29>

80101784 <iunlockput>:
{
80101784:	f3 0f 1e fb          	endbr32 
80101788:	55                   	push   %ebp
80101789:	89 e5                	mov    %esp,%ebp
8010178b:	53                   	push   %ebx
8010178c:	83 ec 10             	sub    $0x10,%esp
8010178f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101792:	53                   	push   %ebx
80101793:	e8 ff fe ff ff       	call   80101697 <iunlock>
  iput(ip);
80101798:	89 1c 24             	mov    %ebx,(%esp)
8010179b:	e8 40 ff ff ff       	call   801016e0 <iput>
}
801017a0:	83 c4 10             	add    $0x10,%esp
801017a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801017a6:	c9                   	leave  
801017a7:	c3                   	ret    

801017a8 <stati>:
{
801017a8:	f3 0f 1e fb          	endbr32 
801017ac:	55                   	push   %ebp
801017ad:	89 e5                	mov    %esp,%ebp
801017af:	8b 55 08             	mov    0x8(%ebp),%edx
801017b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
801017b5:	8b 0a                	mov    (%edx),%ecx
801017b7:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
801017ba:	8b 4a 04             	mov    0x4(%edx),%ecx
801017bd:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
801017c0:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
801017c4:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
801017c7:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
801017cb:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
801017cf:	8b 52 58             	mov    0x58(%edx),%edx
801017d2:	89 50 10             	mov    %edx,0x10(%eax)
}
801017d5:	5d                   	pop    %ebp
801017d6:	c3                   	ret    

801017d7 <readi>:
{
801017d7:	f3 0f 1e fb          	endbr32 
801017db:	55                   	push   %ebp
801017dc:	89 e5                	mov    %esp,%ebp
801017de:	57                   	push   %edi
801017df:	56                   	push   %esi
801017e0:	53                   	push   %ebx
801017e1:	83 ec 1c             	sub    $0x1c,%esp
801017e4:	8b 75 10             	mov    0x10(%ebp),%esi
  if(ip->type == T_DEV){
801017e7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ea:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
801017ef:	74 2c                	je     8010181d <readi+0x46>
  if(off > ip->size || off + n < off)
801017f1:	8b 45 08             	mov    0x8(%ebp),%eax
801017f4:	8b 40 58             	mov    0x58(%eax),%eax
801017f7:	39 f0                	cmp    %esi,%eax
801017f9:	0f 82 cb 00 00 00    	jb     801018ca <readi+0xf3>
801017ff:	89 f2                	mov    %esi,%edx
80101801:	03 55 14             	add    0x14(%ebp),%edx
80101804:	0f 82 c7 00 00 00    	jb     801018d1 <readi+0xfa>
  if(off + n > ip->size)
8010180a:	39 d0                	cmp    %edx,%eax
8010180c:	73 05                	jae    80101813 <readi+0x3c>
    n = ip->size - off;
8010180e:	29 f0                	sub    %esi,%eax
80101810:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101813:	bf 00 00 00 00       	mov    $0x0,%edi
80101818:	e9 8f 00 00 00       	jmp    801018ac <readi+0xd5>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010181d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101821:	66 83 f8 09          	cmp    $0x9,%ax
80101825:	0f 87 91 00 00 00    	ja     801018bc <readi+0xe5>
8010182b:	98                   	cwtl   
8010182c:	8b 04 c5 60 09 11 80 	mov    -0x7feef6a0(,%eax,8),%eax
80101833:	85 c0                	test   %eax,%eax
80101835:	0f 84 88 00 00 00    	je     801018c3 <readi+0xec>
    return devsw[ip->major].read(ip, dst, n);
8010183b:	83 ec 04             	sub    $0x4,%esp
8010183e:	ff 75 14             	pushl  0x14(%ebp)
80101841:	ff 75 0c             	pushl  0xc(%ebp)
80101844:	ff 75 08             	pushl  0x8(%ebp)
80101847:	ff d0                	call   *%eax
80101849:	83 c4 10             	add    $0x10,%esp
8010184c:	eb 66                	jmp    801018b4 <readi+0xdd>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010184e:	89 f2                	mov    %esi,%edx
80101850:	c1 ea 09             	shr    $0x9,%edx
80101853:	8b 45 08             	mov    0x8(%ebp),%eax
80101856:	e8 44 f9 ff ff       	call   8010119f <bmap>
8010185b:	83 ec 08             	sub    $0x8,%esp
8010185e:	50                   	push   %eax
8010185f:	8b 45 08             	mov    0x8(%ebp),%eax
80101862:	ff 30                	pushl  (%eax)
80101864:	e8 07 e9 ff ff       	call   80100170 <bread>
80101869:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
8010186b:	89 f0                	mov    %esi,%eax
8010186d:	25 ff 01 00 00       	and    $0x1ff,%eax
80101872:	bb 00 02 00 00       	mov    $0x200,%ebx
80101877:	29 c3                	sub    %eax,%ebx
80101879:	8b 55 14             	mov    0x14(%ebp),%edx
8010187c:	29 fa                	sub    %edi,%edx
8010187e:	83 c4 0c             	add    $0xc,%esp
80101881:	39 d3                	cmp    %edx,%ebx
80101883:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101886:	53                   	push   %ebx
80101887:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
8010188a:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
8010188e:	50                   	push   %eax
8010188f:	ff 75 0c             	pushl  0xc(%ebp)
80101892:	e8 2a 27 00 00       	call   80103fc1 <memmove>
    brelse(bp);
80101897:	83 c4 04             	add    $0x4,%esp
8010189a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010189d:	e8 3f e9 ff ff       	call   801001e1 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801018a2:	01 df                	add    %ebx,%edi
801018a4:	01 de                	add    %ebx,%esi
801018a6:	01 5d 0c             	add    %ebx,0xc(%ebp)
801018a9:	83 c4 10             	add    $0x10,%esp
801018ac:	39 7d 14             	cmp    %edi,0x14(%ebp)
801018af:	77 9d                	ja     8010184e <readi+0x77>
  return n;
801018b1:	8b 45 14             	mov    0x14(%ebp),%eax
}
801018b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018b7:	5b                   	pop    %ebx
801018b8:	5e                   	pop    %esi
801018b9:	5f                   	pop    %edi
801018ba:	5d                   	pop    %ebp
801018bb:	c3                   	ret    
      return -1;
801018bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018c1:	eb f1                	jmp    801018b4 <readi+0xdd>
801018c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018c8:	eb ea                	jmp    801018b4 <readi+0xdd>
    return -1;
801018ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018cf:	eb e3                	jmp    801018b4 <readi+0xdd>
801018d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018d6:	eb dc                	jmp    801018b4 <readi+0xdd>

801018d8 <writei>:
{
801018d8:	f3 0f 1e fb          	endbr32 
801018dc:	55                   	push   %ebp
801018dd:	89 e5                	mov    %esp,%ebp
801018df:	57                   	push   %edi
801018e0:	56                   	push   %esi
801018e1:	53                   	push   %ebx
801018e2:	83 ec 1c             	sub    $0x1c,%esp
801018e5:	8b 75 10             	mov    0x10(%ebp),%esi
  if(ip->type == T_DEV){
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
801018f0:	0f 84 9b 00 00 00    	je     80101991 <writei+0xb9>
  if(off > ip->size || off + n < off)
801018f6:	8b 45 08             	mov    0x8(%ebp),%eax
801018f9:	39 70 58             	cmp    %esi,0x58(%eax)
801018fc:	0f 82 f0 00 00 00    	jb     801019f2 <writei+0x11a>
80101902:	89 f0                	mov    %esi,%eax
80101904:	03 45 14             	add    0x14(%ebp),%eax
80101907:	0f 82 ec 00 00 00    	jb     801019f9 <writei+0x121>
  if(off + n > MAXFILE*BSIZE)
8010190d:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101912:	0f 87 e8 00 00 00    	ja     80101a00 <writei+0x128>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101918:	bf 00 00 00 00       	mov    $0x0,%edi
8010191d:	3b 7d 14             	cmp    0x14(%ebp),%edi
80101920:	0f 83 94 00 00 00    	jae    801019ba <writei+0xe2>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101926:	89 f2                	mov    %esi,%edx
80101928:	c1 ea 09             	shr    $0x9,%edx
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	e8 6c f8 ff ff       	call   8010119f <bmap>
80101933:	83 ec 08             	sub    $0x8,%esp
80101936:	50                   	push   %eax
80101937:	8b 45 08             	mov    0x8(%ebp),%eax
8010193a:	ff 30                	pushl  (%eax)
8010193c:	e8 2f e8 ff ff       	call   80100170 <bread>
80101941:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
80101943:	89 f0                	mov    %esi,%eax
80101945:	25 ff 01 00 00       	and    $0x1ff,%eax
8010194a:	bb 00 02 00 00       	mov    $0x200,%ebx
8010194f:	29 c3                	sub    %eax,%ebx
80101951:	8b 55 14             	mov    0x14(%ebp),%edx
80101954:	29 fa                	sub    %edi,%edx
80101956:	83 c4 0c             	add    $0xc,%esp
80101959:	39 d3                	cmp    %edx,%ebx
8010195b:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
8010195e:	53                   	push   %ebx
8010195f:	ff 75 0c             	pushl  0xc(%ebp)
80101962:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101965:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101969:	50                   	push   %eax
8010196a:	e8 52 26 00 00       	call   80103fc1 <memmove>
    log_write(bp);
8010196f:	83 c4 04             	add    $0x4,%esp
80101972:	ff 75 e4             	pushl  -0x1c(%ebp)
80101975:	e8 43 10 00 00       	call   801029bd <log_write>
    brelse(bp);
8010197a:	83 c4 04             	add    $0x4,%esp
8010197d:	ff 75 e4             	pushl  -0x1c(%ebp)
80101980:	e8 5c e8 ff ff       	call   801001e1 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101985:	01 df                	add    %ebx,%edi
80101987:	01 de                	add    %ebx,%esi
80101989:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010198c:	83 c4 10             	add    $0x10,%esp
8010198f:	eb 8c                	jmp    8010191d <writei+0x45>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101991:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101995:	66 83 f8 09          	cmp    $0x9,%ax
80101999:	77 49                	ja     801019e4 <writei+0x10c>
8010199b:	98                   	cwtl   
8010199c:	8b 04 c5 64 09 11 80 	mov    -0x7feef69c(,%eax,8),%eax
801019a3:	85 c0                	test   %eax,%eax
801019a5:	74 44                	je     801019eb <writei+0x113>
    return devsw[ip->major].write(ip, src, n);
801019a7:	83 ec 04             	sub    $0x4,%esp
801019aa:	ff 75 14             	pushl  0x14(%ebp)
801019ad:	ff 75 0c             	pushl  0xc(%ebp)
801019b0:	ff 75 08             	pushl  0x8(%ebp)
801019b3:	ff d0                	call   *%eax
801019b5:	83 c4 10             	add    $0x10,%esp
801019b8:	eb 11                	jmp    801019cb <writei+0xf3>
  if(n > 0 && off > ip->size){
801019ba:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801019be:	74 08                	je     801019c8 <writei+0xf0>
801019c0:	8b 45 08             	mov    0x8(%ebp),%eax
801019c3:	39 70 58             	cmp    %esi,0x58(%eax)
801019c6:	72 0b                	jb     801019d3 <writei+0xfb>
  return n;
801019c8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801019cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019ce:	5b                   	pop    %ebx
801019cf:	5e                   	pop    %esi
801019d0:	5f                   	pop    %edi
801019d1:	5d                   	pop    %ebp
801019d2:	c3                   	ret    
    ip->size = off;
801019d3:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
801019d6:	83 ec 0c             	sub    $0xc,%esp
801019d9:	50                   	push   %eax
801019da:	e8 89 fa ff ff       	call   80101468 <iupdate>
801019df:	83 c4 10             	add    $0x10,%esp
801019e2:	eb e4                	jmp    801019c8 <writei+0xf0>
      return -1;
801019e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019e9:	eb e0                	jmp    801019cb <writei+0xf3>
801019eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019f0:	eb d9                	jmp    801019cb <writei+0xf3>
    return -1;
801019f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019f7:	eb d2                	jmp    801019cb <writei+0xf3>
801019f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801019fe:	eb cb                	jmp    801019cb <writei+0xf3>
    return -1;
80101a00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101a05:	eb c4                	jmp    801019cb <writei+0xf3>

80101a07 <namecmp>:
{
80101a07:	f3 0f 1e fb          	endbr32 
80101a0b:	55                   	push   %ebp
80101a0c:	89 e5                	mov    %esp,%ebp
80101a0e:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101a11:	6a 0e                	push   $0xe
80101a13:	ff 75 0c             	pushl  0xc(%ebp)
80101a16:	ff 75 08             	pushl  0x8(%ebp)
80101a19:	e8 15 26 00 00       	call   80104033 <strncmp>
}
80101a1e:	c9                   	leave  
80101a1f:	c3                   	ret    

80101a20 <dirlookup>:
{
80101a20:	f3 0f 1e fb          	endbr32 
80101a24:	55                   	push   %ebp
80101a25:	89 e5                	mov    %esp,%ebp
80101a27:	57                   	push   %edi
80101a28:	56                   	push   %esi
80101a29:	53                   	push   %ebx
80101a2a:	83 ec 1c             	sub    $0x1c,%esp
80101a2d:	8b 75 08             	mov    0x8(%ebp),%esi
80101a30:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
80101a33:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101a38:	75 07                	jne    80101a41 <dirlookup+0x21>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101a3a:	bb 00 00 00 00       	mov    $0x0,%ebx
80101a3f:	eb 1d                	jmp    80101a5e <dirlookup+0x3e>
    panic("dirlookup not DIR");
80101a41:	83 ec 0c             	sub    $0xc,%esp
80101a44:	68 87 6f 10 80       	push   $0x80106f87
80101a49:	e8 0e e9 ff ff       	call   8010035c <panic>
      panic("dirlookup read");
80101a4e:	83 ec 0c             	sub    $0xc,%esp
80101a51:	68 99 6f 10 80       	push   $0x80106f99
80101a56:	e8 01 e9 ff ff       	call   8010035c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101a5b:	83 c3 10             	add    $0x10,%ebx
80101a5e:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101a61:	76 48                	jbe    80101aab <dirlookup+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101a63:	6a 10                	push   $0x10
80101a65:	53                   	push   %ebx
80101a66:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101a69:	50                   	push   %eax
80101a6a:	56                   	push   %esi
80101a6b:	e8 67 fd ff ff       	call   801017d7 <readi>
80101a70:	83 c4 10             	add    $0x10,%esp
80101a73:	83 f8 10             	cmp    $0x10,%eax
80101a76:	75 d6                	jne    80101a4e <dirlookup+0x2e>
    if(de.inum == 0)
80101a78:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a7d:	74 dc                	je     80101a5b <dirlookup+0x3b>
    if(namecmp(name, de.name) == 0){
80101a7f:	83 ec 08             	sub    $0x8,%esp
80101a82:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a85:	50                   	push   %eax
80101a86:	57                   	push   %edi
80101a87:	e8 7b ff ff ff       	call   80101a07 <namecmp>
80101a8c:	83 c4 10             	add    $0x10,%esp
80101a8f:	85 c0                	test   %eax,%eax
80101a91:	75 c8                	jne    80101a5b <dirlookup+0x3b>
      if(poff)
80101a93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a97:	74 05                	je     80101a9e <dirlookup+0x7e>
        *poff = off;
80101a99:	8b 45 10             	mov    0x10(%ebp),%eax
80101a9c:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a9e:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101aa2:	8b 06                	mov    (%esi),%eax
80101aa4:	e8 9c f7 ff ff       	call   80101245 <iget>
80101aa9:	eb 05                	jmp    80101ab0 <dirlookup+0x90>
  return 0;
80101aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101ab0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ab3:	5b                   	pop    %ebx
80101ab4:	5e                   	pop    %esi
80101ab5:	5f                   	pop    %edi
80101ab6:	5d                   	pop    %ebp
80101ab7:	c3                   	ret    

80101ab8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101ab8:	55                   	push   %ebp
80101ab9:	89 e5                	mov    %esp,%ebp
80101abb:	57                   	push   %edi
80101abc:	56                   	push   %esi
80101abd:	53                   	push   %ebx
80101abe:	83 ec 1c             	sub    $0x1c,%esp
80101ac1:	89 c3                	mov    %eax,%ebx
80101ac3:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ac6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101ac9:	80 38 2f             	cmpb   $0x2f,(%eax)
80101acc:	74 17                	je     80101ae5 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101ace:	e8 a8 18 00 00       	call   8010337b <myproc>
80101ad3:	83 ec 0c             	sub    $0xc,%esp
80101ad6:	ff 70 68             	pushl  0x68(%eax)
80101ad9:	e8 bf fa ff ff       	call   8010159d <idup>
80101ade:	89 c6                	mov    %eax,%esi
80101ae0:	83 c4 10             	add    $0x10,%esp
80101ae3:	eb 53                	jmp    80101b38 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101ae5:	ba 01 00 00 00       	mov    $0x1,%edx
80101aea:	b8 01 00 00 00       	mov    $0x1,%eax
80101aef:	e8 51 f7 ff ff       	call   80101245 <iget>
80101af4:	89 c6                	mov    %eax,%esi
80101af6:	eb 40                	jmp    80101b38 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101af8:	83 ec 0c             	sub    $0xc,%esp
80101afb:	56                   	push   %esi
80101afc:	e8 83 fc ff ff       	call   80101784 <iunlockput>
      return 0;
80101b01:	83 c4 10             	add    $0x10,%esp
80101b04:	be 00 00 00 00       	mov    $0x0,%esi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101b09:	89 f0                	mov    %esi,%eax
80101b0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b0e:	5b                   	pop    %ebx
80101b0f:	5e                   	pop    %esi
80101b10:	5f                   	pop    %edi
80101b11:	5d                   	pop    %ebp
80101b12:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101b13:	83 ec 04             	sub    $0x4,%esp
80101b16:	6a 00                	push   $0x0
80101b18:	ff 75 e4             	pushl  -0x1c(%ebp)
80101b1b:	56                   	push   %esi
80101b1c:	e8 ff fe ff ff       	call   80101a20 <dirlookup>
80101b21:	89 c7                	mov    %eax,%edi
80101b23:	83 c4 10             	add    $0x10,%esp
80101b26:	85 c0                	test   %eax,%eax
80101b28:	74 4a                	je     80101b74 <namex+0xbc>
    iunlockput(ip);
80101b2a:	83 ec 0c             	sub    $0xc,%esp
80101b2d:	56                   	push   %esi
80101b2e:	e8 51 fc ff ff       	call   80101784 <iunlockput>
80101b33:	83 c4 10             	add    $0x10,%esp
    ip = next;
80101b36:	89 fe                	mov    %edi,%esi
  while((path = skipelem(path, name)) != 0){
80101b38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101b3b:	89 d8                	mov    %ebx,%eax
80101b3d:	e8 49 f4 ff ff       	call   80100f8b <skipelem>
80101b42:	89 c3                	mov    %eax,%ebx
80101b44:	85 c0                	test   %eax,%eax
80101b46:	74 3c                	je     80101b84 <namex+0xcc>
    ilock(ip);
80101b48:	83 ec 0c             	sub    $0xc,%esp
80101b4b:	56                   	push   %esi
80101b4c:	e8 80 fa ff ff       	call   801015d1 <ilock>
    if(ip->type != T_DIR){
80101b51:	83 c4 10             	add    $0x10,%esp
80101b54:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101b59:	75 9d                	jne    80101af8 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101b5b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b5f:	74 b2                	je     80101b13 <namex+0x5b>
80101b61:	80 3b 00             	cmpb   $0x0,(%ebx)
80101b64:	75 ad                	jne    80101b13 <namex+0x5b>
      iunlock(ip);
80101b66:	83 ec 0c             	sub    $0xc,%esp
80101b69:	56                   	push   %esi
80101b6a:	e8 28 fb ff ff       	call   80101697 <iunlock>
      return ip;
80101b6f:	83 c4 10             	add    $0x10,%esp
80101b72:	eb 95                	jmp    80101b09 <namex+0x51>
      iunlockput(ip);
80101b74:	83 ec 0c             	sub    $0xc,%esp
80101b77:	56                   	push   %esi
80101b78:	e8 07 fc ff ff       	call   80101784 <iunlockput>
      return 0;
80101b7d:	83 c4 10             	add    $0x10,%esp
80101b80:	89 fe                	mov    %edi,%esi
80101b82:	eb 85                	jmp    80101b09 <namex+0x51>
  if(nameiparent){
80101b84:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b88:	0f 84 7b ff ff ff    	je     80101b09 <namex+0x51>
    iput(ip);
80101b8e:	83 ec 0c             	sub    $0xc,%esp
80101b91:	56                   	push   %esi
80101b92:	e8 49 fb ff ff       	call   801016e0 <iput>
    return 0;
80101b97:	83 c4 10             	add    $0x10,%esp
80101b9a:	89 de                	mov    %ebx,%esi
80101b9c:	e9 68 ff ff ff       	jmp    80101b09 <namex+0x51>

80101ba1 <dirlink>:
{
80101ba1:	f3 0f 1e fb          	endbr32 
80101ba5:	55                   	push   %ebp
80101ba6:	89 e5                	mov    %esp,%ebp
80101ba8:	57                   	push   %edi
80101ba9:	56                   	push   %esi
80101baa:	53                   	push   %ebx
80101bab:	83 ec 20             	sub    $0x20,%esp
80101bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101bb1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101bb4:	6a 00                	push   $0x0
80101bb6:	57                   	push   %edi
80101bb7:	53                   	push   %ebx
80101bb8:	e8 63 fe ff ff       	call   80101a20 <dirlookup>
80101bbd:	83 c4 10             	add    $0x10,%esp
80101bc0:	85 c0                	test   %eax,%eax
80101bc2:	75 07                	jne    80101bcb <dirlink+0x2a>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101bc4:	b8 00 00 00 00       	mov    $0x0,%eax
80101bc9:	eb 23                	jmp    80101bee <dirlink+0x4d>
    iput(ip);
80101bcb:	83 ec 0c             	sub    $0xc,%esp
80101bce:	50                   	push   %eax
80101bcf:	e8 0c fb ff ff       	call   801016e0 <iput>
    return -1;
80101bd4:	83 c4 10             	add    $0x10,%esp
80101bd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101bdc:	eb 63                	jmp    80101c41 <dirlink+0xa0>
      panic("dirlink read");
80101bde:	83 ec 0c             	sub    $0xc,%esp
80101be1:	68 a8 6f 10 80       	push   $0x80106fa8
80101be6:	e8 71 e7 ff ff       	call   8010035c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101beb:	8d 46 10             	lea    0x10(%esi),%eax
80101bee:	89 c6                	mov    %eax,%esi
80101bf0:	39 43 58             	cmp    %eax,0x58(%ebx)
80101bf3:	76 1c                	jbe    80101c11 <dirlink+0x70>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101bf5:	6a 10                	push   $0x10
80101bf7:	50                   	push   %eax
80101bf8:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101bfb:	50                   	push   %eax
80101bfc:	53                   	push   %ebx
80101bfd:	e8 d5 fb ff ff       	call   801017d7 <readi>
80101c02:	83 c4 10             	add    $0x10,%esp
80101c05:	83 f8 10             	cmp    $0x10,%eax
80101c08:	75 d4                	jne    80101bde <dirlink+0x3d>
    if(de.inum == 0)
80101c0a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101c0f:	75 da                	jne    80101beb <dirlink+0x4a>
  strncpy(de.name, name, DIRSIZ);
80101c11:	83 ec 04             	sub    $0x4,%esp
80101c14:	6a 0e                	push   $0xe
80101c16:	57                   	push   %edi
80101c17:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101c1a:	8d 45 da             	lea    -0x26(%ebp),%eax
80101c1d:	50                   	push   %eax
80101c1e:	e8 51 24 00 00       	call   80104074 <strncpy>
  de.inum = inum;
80101c23:	8b 45 10             	mov    0x10(%ebp),%eax
80101c26:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101c2a:	6a 10                	push   $0x10
80101c2c:	56                   	push   %esi
80101c2d:	57                   	push   %edi
80101c2e:	53                   	push   %ebx
80101c2f:	e8 a4 fc ff ff       	call   801018d8 <writei>
80101c34:	83 c4 20             	add    $0x20,%esp
80101c37:	83 f8 10             	cmp    $0x10,%eax
80101c3a:	75 0d                	jne    80101c49 <dirlink+0xa8>
  return 0;
80101c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c44:	5b                   	pop    %ebx
80101c45:	5e                   	pop    %esi
80101c46:	5f                   	pop    %edi
80101c47:	5d                   	pop    %ebp
80101c48:	c3                   	ret    
    panic("dirlink");
80101c49:	83 ec 0c             	sub    $0xc,%esp
80101c4c:	68 e0 76 10 80       	push   $0x801076e0
80101c51:	e8 06 e7 ff ff       	call   8010035c <panic>

80101c56 <namei>:

struct inode*
namei(char *path)
{
80101c56:	f3 0f 1e fb          	endbr32 
80101c5a:	55                   	push   %ebp
80101c5b:	89 e5                	mov    %esp,%ebp
80101c5d:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101c60:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101c63:	ba 00 00 00 00       	mov    $0x0,%edx
80101c68:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6b:	e8 48 fe ff ff       	call   80101ab8 <namex>
}
80101c70:	c9                   	leave  
80101c71:	c3                   	ret    

80101c72 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101c72:	f3 0f 1e fb          	endbr32 
80101c76:	55                   	push   %ebp
80101c77:	89 e5                	mov    %esp,%ebp
80101c79:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c7f:	ba 01 00 00 00       	mov    $0x1,%edx
80101c84:	8b 45 08             	mov    0x8(%ebp),%eax
80101c87:	e8 2c fe ff ff       	call   80101ab8 <namex>
}
80101c8c:	c9                   	leave  
80101c8d:	c3                   	ret    

80101c8e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101c8e:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c90:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c95:	ec                   	in     (%dx),%al
80101c96:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c98:	83 e0 c0             	and    $0xffffffc0,%eax
80101c9b:	3c 40                	cmp    $0x40,%al
80101c9d:	75 f1                	jne    80101c90 <idewait+0x2>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c9f:	85 c9                	test   %ecx,%ecx
80101ca1:	74 0a                	je     80101cad <idewait+0x1f>
80101ca3:	f6 c2 21             	test   $0x21,%dl
80101ca6:	75 08                	jne    80101cb0 <idewait+0x22>
    return -1;
  return 0;
80101ca8:	b9 00 00 00 00       	mov    $0x0,%ecx
}
80101cad:	89 c8                	mov    %ecx,%eax
80101caf:	c3                   	ret    
    return -1;
80101cb0:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
80101cb5:	eb f6                	jmp    80101cad <idewait+0x1f>

80101cb7 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101cb7:	55                   	push   %ebp
80101cb8:	89 e5                	mov    %esp,%ebp
80101cba:	56                   	push   %esi
80101cbb:	53                   	push   %ebx
  if(b == 0)
80101cbc:	85 c0                	test   %eax,%eax
80101cbe:	0f 84 91 00 00 00    	je     80101d55 <idestart+0x9e>
80101cc4:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101cc6:	8b 58 08             	mov    0x8(%eax),%ebx
80101cc9:	81 fb cf 07 00 00    	cmp    $0x7cf,%ebx
80101ccf:	0f 87 8d 00 00 00    	ja     80101d62 <idestart+0xab>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101cd5:	b8 00 00 00 00       	mov    $0x0,%eax
80101cda:	e8 af ff ff ff       	call   80101c8e <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101cdf:	b8 00 00 00 00       	mov    $0x0,%eax
80101ce4:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101ce9:	ee                   	out    %al,(%dx)
80101cea:	b8 01 00 00 00       	mov    $0x1,%eax
80101cef:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101cf4:	ee                   	out    %al,(%dx)
80101cf5:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101cfa:	89 d8                	mov    %ebx,%eax
80101cfc:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101cfd:	89 d8                	mov    %ebx,%eax
80101cff:	c1 f8 08             	sar    $0x8,%eax
80101d02:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101d07:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101d08:	89 d8                	mov    %ebx,%eax
80101d0a:	c1 f8 10             	sar    $0x10,%eax
80101d0d:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101d12:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101d13:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101d17:	c1 e0 04             	shl    $0x4,%eax
80101d1a:	83 e0 10             	and    $0x10,%eax
80101d1d:	c1 fb 18             	sar    $0x18,%ebx
80101d20:	83 e3 0f             	and    $0xf,%ebx
80101d23:	09 d8                	or     %ebx,%eax
80101d25:	83 c8 e0             	or     $0xffffffe0,%eax
80101d28:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d2d:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101d2e:	f6 06 04             	testb  $0x4,(%esi)
80101d31:	74 3c                	je     80101d6f <idestart+0xb8>
80101d33:	b8 30 00 00 00       	mov    $0x30,%eax
80101d38:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d3d:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101d3e:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101d41:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d46:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d4b:	fc                   	cld    
80101d4c:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101d4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101d51:	5b                   	pop    %ebx
80101d52:	5e                   	pop    %esi
80101d53:	5d                   	pop    %ebp
80101d54:	c3                   	ret    
    panic("idestart");
80101d55:	83 ec 0c             	sub    $0xc,%esp
80101d58:	68 0b 70 10 80       	push   $0x8010700b
80101d5d:	e8 fa e5 ff ff       	call   8010035c <panic>
    panic("incorrect blockno");
80101d62:	83 ec 0c             	sub    $0xc,%esp
80101d65:	68 14 70 10 80       	push   $0x80107014
80101d6a:	e8 ed e5 ff ff       	call   8010035c <panic>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d6f:	b8 20 00 00 00       	mov    $0x20,%eax
80101d74:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d79:	ee                   	out    %al,(%dx)
}
80101d7a:	eb d2                	jmp    80101d4e <idestart+0x97>

80101d7c <ideinit>:
{
80101d7c:	f3 0f 1e fb          	endbr32 
80101d80:	55                   	push   %ebp
80101d81:	89 e5                	mov    %esp,%ebp
80101d83:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101d86:	68 26 70 10 80       	push   $0x80107026
80101d8b:	68 80 a5 10 80       	push   $0x8010a580
80101d90:	e8 a8 1f 00 00       	call   80103d3d <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d95:	83 c4 08             	add    $0x8,%esp
80101d98:	a1 00 2d 11 80       	mov    0x80112d00,%eax
80101d9d:	83 e8 01             	sub    $0x1,%eax
80101da0:	50                   	push   %eax
80101da1:	6a 0e                	push   $0xe
80101da3:	e8 5a 02 00 00       	call   80102002 <ioapicenable>
  idewait(0);
80101da8:	b8 00 00 00 00       	mov    $0x0,%eax
80101dad:	e8 dc fe ff ff       	call   80101c8e <idewait>
80101db2:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101db7:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101dbc:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101dbd:	83 c4 10             	add    $0x10,%esp
80101dc0:	b9 00 00 00 00       	mov    $0x0,%ecx
80101dc5:	eb 03                	jmp    80101dca <ideinit+0x4e>
80101dc7:	83 c1 01             	add    $0x1,%ecx
80101dca:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101dd0:	7f 14                	jg     80101de6 <ideinit+0x6a>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101dd2:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101dd7:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101dd8:	84 c0                	test   %al,%al
80101dda:	74 eb                	je     80101dc7 <ideinit+0x4b>
      havedisk1 = 1;
80101ddc:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101de3:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101de6:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101deb:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101df0:	ee                   	out    %al,(%dx)
}
80101df1:	c9                   	leave  
80101df2:	c3                   	ret    

80101df3 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101df3:	f3 0f 1e fb          	endbr32 
80101df7:	55                   	push   %ebp
80101df8:	89 e5                	mov    %esp,%ebp
80101dfa:	57                   	push   %edi
80101dfb:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101dfc:	83 ec 0c             	sub    $0xc,%esp
80101dff:	68 80 a5 10 80       	push   $0x8010a580
80101e04:	e8 84 20 00 00       	call   80103e8d <acquire>

  if((b = idequeue) == 0){
80101e09:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101e0f:	83 c4 10             	add    $0x10,%esp
80101e12:	85 db                	test   %ebx,%ebx
80101e14:	74 48                	je     80101e5e <ideintr+0x6b>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101e16:	8b 43 58             	mov    0x58(%ebx),%eax
80101e19:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101e1e:	f6 03 04             	testb  $0x4,(%ebx)
80101e21:	74 4d                	je     80101e70 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101e23:	8b 03                	mov    (%ebx),%eax
80101e25:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101e28:	83 e0 fb             	and    $0xfffffffb,%eax
80101e2b:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101e2d:	83 ec 0c             	sub    $0xc,%esp
80101e30:	53                   	push   %ebx
80101e31:	e8 9d 1b 00 00       	call   801039d3 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101e36:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101e3b:	83 c4 10             	add    $0x10,%esp
80101e3e:	85 c0                	test   %eax,%eax
80101e40:	74 05                	je     80101e47 <ideintr+0x54>
    idestart(idequeue);
80101e42:	e8 70 fe ff ff       	call   80101cb7 <idestart>

  release(&idelock);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	68 80 a5 10 80       	push   $0x8010a580
80101e4f:	e8 a2 20 00 00       	call   80103ef6 <release>
80101e54:	83 c4 10             	add    $0x10,%esp
}
80101e57:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101e5a:	5b                   	pop    %ebx
80101e5b:	5f                   	pop    %edi
80101e5c:	5d                   	pop    %ebp
80101e5d:	c3                   	ret    
    release(&idelock);
80101e5e:	83 ec 0c             	sub    $0xc,%esp
80101e61:	68 80 a5 10 80       	push   $0x8010a580
80101e66:	e8 8b 20 00 00       	call   80103ef6 <release>
    return;
80101e6b:	83 c4 10             	add    $0x10,%esp
80101e6e:	eb e7                	jmp    80101e57 <ideintr+0x64>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101e70:	b8 01 00 00 00       	mov    $0x1,%eax
80101e75:	e8 14 fe ff ff       	call   80101c8e <idewait>
80101e7a:	85 c0                	test   %eax,%eax
80101e7c:	78 a5                	js     80101e23 <ideintr+0x30>
    insl(0x1f0, b->data, BSIZE/4);
80101e7e:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101e81:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e86:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e8b:	fc                   	cld    
80101e8c:	f3 6d                	rep insl (%dx),%es:(%edi)
}
80101e8e:	eb 93                	jmp    80101e23 <ideintr+0x30>

80101e90 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e90:	f3 0f 1e fb          	endbr32 
80101e94:	55                   	push   %ebp
80101e95:	89 e5                	mov    %esp,%ebp
80101e97:	53                   	push   %ebx
80101e98:	83 ec 10             	sub    $0x10,%esp
80101e9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e9e:	8d 43 0c             	lea    0xc(%ebx),%eax
80101ea1:	50                   	push   %eax
80101ea2:	e8 44 1e 00 00       	call   80103ceb <holdingsleep>
80101ea7:	83 c4 10             	add    $0x10,%esp
80101eaa:	85 c0                	test   %eax,%eax
80101eac:	74 37                	je     80101ee5 <iderw+0x55>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101eae:	8b 03                	mov    (%ebx),%eax
80101eb0:	83 e0 06             	and    $0x6,%eax
80101eb3:	83 f8 02             	cmp    $0x2,%eax
80101eb6:	74 3a                	je     80101ef2 <iderw+0x62>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101eb8:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101ebc:	74 09                	je     80101ec7 <iderw+0x37>
80101ebe:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101ec5:	74 38                	je     80101eff <iderw+0x6f>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101ec7:	83 ec 0c             	sub    $0xc,%esp
80101eca:	68 80 a5 10 80       	push   $0x8010a580
80101ecf:	e8 b9 1f 00 00       	call   80103e8d <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101ed4:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101edb:	83 c4 10             	add    $0x10,%esp
80101ede:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101ee3:	eb 2a                	jmp    80101f0f <iderw+0x7f>
    panic("iderw: buf not locked");
80101ee5:	83 ec 0c             	sub    $0xc,%esp
80101ee8:	68 2a 70 10 80       	push   $0x8010702a
80101eed:	e8 6a e4 ff ff       	call   8010035c <panic>
    panic("iderw: nothing to do");
80101ef2:	83 ec 0c             	sub    $0xc,%esp
80101ef5:	68 40 70 10 80       	push   $0x80107040
80101efa:	e8 5d e4 ff ff       	call   8010035c <panic>
    panic("iderw: ide disk 1 not present");
80101eff:	83 ec 0c             	sub    $0xc,%esp
80101f02:	68 55 70 10 80       	push   $0x80107055
80101f07:	e8 50 e4 ff ff       	call   8010035c <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101f0c:	8d 50 58             	lea    0x58(%eax),%edx
80101f0f:	8b 02                	mov    (%edx),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 f7                	jne    80101f0c <iderw+0x7c>
    ;
  *pp = b;
80101f15:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101f17:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101f1d:	75 1a                	jne    80101f39 <iderw+0xa9>
    idestart(b);
80101f1f:	89 d8                	mov    %ebx,%eax
80101f21:	e8 91 fd ff ff       	call   80101cb7 <idestart>
80101f26:	eb 11                	jmp    80101f39 <iderw+0xa9>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101f28:	83 ec 08             	sub    $0x8,%esp
80101f2b:	68 80 a5 10 80       	push   $0x8010a580
80101f30:	53                   	push   %ebx
80101f31:	e8 30 19 00 00       	call   80103866 <sleep>
80101f36:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101f39:	8b 03                	mov    (%ebx),%eax
80101f3b:	83 e0 06             	and    $0x6,%eax
80101f3e:	83 f8 02             	cmp    $0x2,%eax
80101f41:	75 e5                	jne    80101f28 <iderw+0x98>
  }


  release(&idelock);
80101f43:	83 ec 0c             	sub    $0xc,%esp
80101f46:	68 80 a5 10 80       	push   $0x8010a580
80101f4b:	e8 a6 1f 00 00       	call   80103ef6 <release>
}
80101f50:	83 c4 10             	add    $0x10,%esp
80101f53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f56:	c9                   	leave  
80101f57:	c3                   	ret    

80101f58 <ioapicread>:
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101f58:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80101f5e:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101f60:	a1 34 26 11 80       	mov    0x80112634,%eax
80101f65:	8b 40 10             	mov    0x10(%eax),%eax
}
80101f68:	c3                   	ret    

80101f69 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101f69:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80101f6f:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101f71:	a1 34 26 11 80       	mov    0x80112634,%eax
80101f76:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f79:	c3                   	ret    

80101f7a <ioapicinit>:

void
ioapicinit(void)
{
80101f7a:	f3 0f 1e fb          	endbr32 
80101f7e:	55                   	push   %ebp
80101f7f:	89 e5                	mov    %esp,%ebp
80101f81:	57                   	push   %edi
80101f82:	56                   	push   %esi
80101f83:	53                   	push   %ebx
80101f84:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f87:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
80101f8e:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f91:	b8 01 00 00 00       	mov    $0x1,%eax
80101f96:	e8 bd ff ff ff       	call   80101f58 <ioapicread>
80101f9b:	c1 e8 10             	shr    $0x10,%eax
80101f9e:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80101fa6:	e8 ad ff ff ff       	call   80101f58 <ioapicread>
80101fab:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101fae:	0f b6 15 60 27 11 80 	movzbl 0x80112760,%edx
80101fb5:	39 c2                	cmp    %eax,%edx
80101fb7:	75 2f                	jne    80101fe8 <ioapicinit+0x6e>
{
80101fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80101fbe:	39 fb                	cmp    %edi,%ebx
80101fc0:	7f 38                	jg     80101ffa <ioapicinit+0x80>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101fc2:	8d 53 20             	lea    0x20(%ebx),%edx
80101fc5:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101fcb:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101fcf:	89 f0                	mov    %esi,%eax
80101fd1:	e8 93 ff ff ff       	call   80101f69 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101fd6:	8d 46 01             	lea    0x1(%esi),%eax
80101fd9:	ba 00 00 00 00       	mov    $0x0,%edx
80101fde:	e8 86 ff ff ff       	call   80101f69 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101fe3:	83 c3 01             	add    $0x1,%ebx
80101fe6:	eb d6                	jmp    80101fbe <ioapicinit+0x44>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101fe8:	83 ec 0c             	sub    $0xc,%esp
80101feb:	68 74 70 10 80       	push   $0x80107074
80101ff0:	e8 34 e6 ff ff       	call   80100629 <cprintf>
80101ff5:	83 c4 10             	add    $0x10,%esp
80101ff8:	eb bf                	jmp    80101fb9 <ioapicinit+0x3f>
  }
}
80101ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ffd:	5b                   	pop    %ebx
80101ffe:	5e                   	pop    %esi
80101fff:	5f                   	pop    %edi
80102000:	5d                   	pop    %ebp
80102001:	c3                   	ret    

80102002 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102002:	f3 0f 1e fb          	endbr32 
80102006:	55                   	push   %ebp
80102007:	89 e5                	mov    %esp,%ebp
80102009:	53                   	push   %ebx
8010200a:	83 ec 04             	sub    $0x4,%esp
8010200d:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102010:	8d 50 20             	lea    0x20(%eax),%edx
80102013:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80102017:	89 d8                	mov    %ebx,%eax
80102019:	e8 4b ff ff ff       	call   80101f69 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010201e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102021:	c1 e2 18             	shl    $0x18,%edx
80102024:	8d 43 01             	lea    0x1(%ebx),%eax
80102027:	e8 3d ff ff ff       	call   80101f69 <ioapicwrite>
}
8010202c:	83 c4 04             	add    $0x4,%esp
8010202f:	5b                   	pop    %ebx
80102030:	5d                   	pop    %ebp
80102031:	c3                   	ret    

80102032 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102032:	f3 0f 1e fb          	endbr32 
80102036:	55                   	push   %ebp
80102037:	89 e5                	mov    %esp,%ebp
80102039:	53                   	push   %ebx
8010203a:	83 ec 04             	sub    $0x4,%esp
8010203d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102040:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102046:	75 61                	jne    801020a9 <kfree+0x77>
80102048:	81 fb a8 55 11 80    	cmp    $0x801155a8,%ebx
8010204e:	72 59                	jb     801020a9 <kfree+0x77>

// Convert kernel virtual address to physical address
static inline uint V2P(void *a) {
    // define panic() here because memlayout.h is included before defs.h
    extern void panic(char*) __attribute__((noreturn));
    if (a < (void*) KERNBASE)
80102050:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80102056:	76 44                	jbe    8010209c <kfree+0x6a>
        panic("V2P on address < KERNBASE "
              "(not a kernel virtual address; consider walking page "
              "table to determine physical address of a user virtual address)");
    return (uint)a - KERNBASE;
80102058:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010205e:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102063:	77 44                	ja     801020a9 <kfree+0x77>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102065:	83 ec 04             	sub    $0x4,%esp
80102068:	68 00 10 00 00       	push   $0x1000
8010206d:	6a 01                	push   $0x1
8010206f:	53                   	push   %ebx
80102070:	e8 cc 1e 00 00       	call   80103f41 <memset>

  if(kmem.use_lock)
80102075:	83 c4 10             	add    $0x10,%esp
80102078:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010207f:	75 35                	jne    801020b6 <kfree+0x84>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102081:	a1 78 26 11 80       	mov    0x80112678,%eax
80102086:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80102088:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  if(kmem.use_lock)
8010208e:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102095:	75 31                	jne    801020c8 <kfree+0x96>
    release(&kmem.lock);
}
80102097:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010209a:	c9                   	leave  
8010209b:	c3                   	ret    
        panic("V2P on address < KERNBASE "
8010209c:	83 ec 0c             	sub    $0xc,%esp
8010209f:	68 a8 70 10 80       	push   $0x801070a8
801020a4:	e8 b3 e2 ff ff       	call   8010035c <panic>
    panic("kfree");
801020a9:	83 ec 0c             	sub    $0xc,%esp
801020ac:	68 36 71 10 80       	push   $0x80107136
801020b1:	e8 a6 e2 ff ff       	call   8010035c <panic>
    acquire(&kmem.lock);
801020b6:	83 ec 0c             	sub    $0xc,%esp
801020b9:	68 40 26 11 80       	push   $0x80112640
801020be:	e8 ca 1d 00 00       	call   80103e8d <acquire>
801020c3:	83 c4 10             	add    $0x10,%esp
801020c6:	eb b9                	jmp    80102081 <kfree+0x4f>
    release(&kmem.lock);
801020c8:	83 ec 0c             	sub    $0xc,%esp
801020cb:	68 40 26 11 80       	push   $0x80112640
801020d0:	e8 21 1e 00 00       	call   80103ef6 <release>
801020d5:	83 c4 10             	add    $0x10,%esp
}
801020d8:	eb bd                	jmp    80102097 <kfree+0x65>

801020da <freerange>:
{
801020da:	f3 0f 1e fb          	endbr32 
801020de:	55                   	push   %ebp
801020df:	89 e5                	mov    %esp,%ebp
801020e1:	56                   	push   %esi
801020e2:	53                   	push   %ebx
801020e3:	8b 45 08             	mov    0x8(%ebp),%eax
801020e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if (vend < vstart) panic("freerange");
801020e9:	39 c3                	cmp    %eax,%ebx
801020eb:	72 0c                	jb     801020f9 <freerange+0x1f>
  p = (char*)PGROUNDUP((uint)vstart);
801020ed:	05 ff 0f 00 00       	add    $0xfff,%eax
801020f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801020f7:	eb 1b                	jmp    80102114 <freerange+0x3a>
  if (vend < vstart) panic("freerange");
801020f9:	83 ec 0c             	sub    $0xc,%esp
801020fc:	68 3c 71 10 80       	push   $0x8010713c
80102101:	e8 56 e2 ff ff       	call   8010035c <panic>
    kfree(p);
80102106:	83 ec 0c             	sub    $0xc,%esp
80102109:	50                   	push   %eax
8010210a:	e8 23 ff ff ff       	call   80102032 <kfree>
8010210f:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102112:	89 f0                	mov    %esi,%eax
80102114:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010211a:	39 de                	cmp    %ebx,%esi
8010211c:	76 e8                	jbe    80102106 <freerange+0x2c>
}
8010211e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102121:	5b                   	pop    %ebx
80102122:	5e                   	pop    %esi
80102123:	5d                   	pop    %ebp
80102124:	c3                   	ret    

80102125 <kinit1>:
{
80102125:	f3 0f 1e fb          	endbr32 
80102129:	55                   	push   %ebp
8010212a:	89 e5                	mov    %esp,%ebp
8010212c:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010212f:	68 46 71 10 80       	push   $0x80107146
80102134:	68 40 26 11 80       	push   $0x80112640
80102139:	e8 ff 1b 00 00       	call   80103d3d <initlock>
  kmem.use_lock = 0;
8010213e:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
80102145:	00 00 00 
  freerange(vstart, vend);
80102148:	83 c4 08             	add    $0x8,%esp
8010214b:	ff 75 0c             	pushl  0xc(%ebp)
8010214e:	ff 75 08             	pushl  0x8(%ebp)
80102151:	e8 84 ff ff ff       	call   801020da <freerange>
}
80102156:	83 c4 10             	add    $0x10,%esp
80102159:	c9                   	leave  
8010215a:	c3                   	ret    

8010215b <kinit2>:
{
8010215b:	f3 0f 1e fb          	endbr32 
8010215f:	55                   	push   %ebp
80102160:	89 e5                	mov    %esp,%ebp
80102162:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
80102165:	ff 75 0c             	pushl  0xc(%ebp)
80102168:	ff 75 08             	pushl  0x8(%ebp)
8010216b:	e8 6a ff ff ff       	call   801020da <freerange>
  kmem.use_lock = 1;
80102170:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
80102177:	00 00 00 
}
8010217a:	83 c4 10             	add    $0x10,%esp
8010217d:	c9                   	leave  
8010217e:	c3                   	ret    

8010217f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010217f:	f3 0f 1e fb          	endbr32 
80102183:	55                   	push   %ebp
80102184:	89 e5                	mov    %esp,%ebp
80102186:	53                   	push   %ebx
80102187:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
8010218a:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102191:	75 21                	jne    801021b4 <kalloc+0x35>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102193:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(r)
80102199:	85 db                	test   %ebx,%ebx
8010219b:	74 07                	je     801021a4 <kalloc+0x25>
    kmem.freelist = r->next;
8010219d:	8b 03                	mov    (%ebx),%eax
8010219f:	a3 78 26 11 80       	mov    %eax,0x80112678
  if(kmem.use_lock)
801021a4:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
801021ab:	75 19                	jne    801021c6 <kalloc+0x47>
    release(&kmem.lock);
  return (char*)r;
}
801021ad:	89 d8                	mov    %ebx,%eax
801021af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801021b2:	c9                   	leave  
801021b3:	c3                   	ret    
    acquire(&kmem.lock);
801021b4:	83 ec 0c             	sub    $0xc,%esp
801021b7:	68 40 26 11 80       	push   $0x80112640
801021bc:	e8 cc 1c 00 00       	call   80103e8d <acquire>
801021c1:	83 c4 10             	add    $0x10,%esp
801021c4:	eb cd                	jmp    80102193 <kalloc+0x14>
    release(&kmem.lock);
801021c6:	83 ec 0c             	sub    $0xc,%esp
801021c9:	68 40 26 11 80       	push   $0x80112640
801021ce:	e8 23 1d 00 00       	call   80103ef6 <release>
801021d3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801021d6:	eb d5                	jmp    801021ad <kalloc+0x2e>

801021d8 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801021d8:	f3 0f 1e fb          	endbr32 
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021dc:	ba 64 00 00 00       	mov    $0x64,%edx
801021e1:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801021e2:	a8 01                	test   $0x1,%al
801021e4:	0f 84 ad 00 00 00    	je     80102297 <kbdgetc+0xbf>
801021ea:	ba 60 00 00 00       	mov    $0x60,%edx
801021ef:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801021f0:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801021f3:	3c e0                	cmp    $0xe0,%al
801021f5:	74 5b                	je     80102252 <kbdgetc+0x7a>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801021f7:	84 c0                	test   %al,%al
801021f9:	78 64                	js     8010225f <kbdgetc+0x87>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801021fb:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
80102201:	f6 c1 40             	test   $0x40,%cl
80102204:	74 0f                	je     80102215 <kbdgetc+0x3d>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102206:	83 c8 80             	or     $0xffffff80,%eax
80102209:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
8010220c:	83 e1 bf             	and    $0xffffffbf,%ecx
8010220f:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
80102215:	0f b6 8a 80 72 10 80 	movzbl -0x7fef8d80(%edx),%ecx
8010221c:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
80102222:	0f b6 82 80 71 10 80 	movzbl -0x7fef8e80(%edx),%eax
80102229:	31 c1                	xor    %eax,%ecx
8010222b:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
80102231:	89 c8                	mov    %ecx,%eax
80102233:	83 e0 03             	and    $0x3,%eax
80102236:	8b 04 85 60 71 10 80 	mov    -0x7fef8ea0(,%eax,4),%eax
8010223d:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
80102241:	f6 c1 08             	test   $0x8,%cl
80102244:	74 56                	je     8010229c <kbdgetc+0xc4>
    if('a' <= c && c <= 'z')
80102246:	8d 50 9f             	lea    -0x61(%eax),%edx
80102249:	83 fa 19             	cmp    $0x19,%edx
8010224c:	77 3d                	ja     8010228b <kbdgetc+0xb3>
      c += 'A' - 'a';
8010224e:	83 e8 20             	sub    $0x20,%eax
80102251:	c3                   	ret    
    shift |= E0ESC;
80102252:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
80102259:	b8 00 00 00 00       	mov    $0x0,%eax
8010225e:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010225f:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
80102265:	f6 c1 40             	test   $0x40,%cl
80102268:	75 05                	jne    8010226f <kbdgetc+0x97>
8010226a:	89 c2                	mov    %eax,%edx
8010226c:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
8010226f:	0f b6 82 80 72 10 80 	movzbl -0x7fef8d80(%edx),%eax
80102276:	83 c8 40             	or     $0x40,%eax
80102279:	0f b6 c0             	movzbl %al,%eax
8010227c:	f7 d0                	not    %eax
8010227e:	21 c8                	and    %ecx,%eax
80102280:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
80102285:	b8 00 00 00 00       	mov    $0x0,%eax
8010228a:	c3                   	ret    
    else if('A' <= c && c <= 'Z')
8010228b:	8d 50 bf             	lea    -0x41(%eax),%edx
8010228e:	83 fa 19             	cmp    $0x19,%edx
80102291:	77 09                	ja     8010229c <kbdgetc+0xc4>
      c += 'a' - 'A';
80102293:	83 c0 20             	add    $0x20,%eax
  }
  return c;
80102296:	c3                   	ret    
    return -1;
80102297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010229c:	c3                   	ret    

8010229d <kbdintr>:

void
kbdintr(void)
{
8010229d:	f3 0f 1e fb          	endbr32 
801022a1:	55                   	push   %ebp
801022a2:	89 e5                	mov    %esp,%ebp
801022a4:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801022a7:	68 d8 21 10 80       	push   $0x801021d8
801022ac:	e8 a8 e4 ff ff       	call   80100759 <consoleintr>
}
801022b1:	83 c4 10             	add    $0x10,%esp
801022b4:	c9                   	leave  
801022b5:	c3                   	ret    

801022b6 <shutdown>:
#include "types.h"
#include "x86.h"

void
shutdown(void)
{
801022b6:	f3 0f 1e fb          	endbr32 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801022ba:	b8 00 00 00 00       	mov    $0x0,%eax
801022bf:	ba 01 05 00 00       	mov    $0x501,%edx
801022c4:	ee                   	out    %al,(%dx)
  /*
     This only works in QEMU and assumes QEMU was run 
     with -device isa-debug-exit
   */
  outb(0x501, 0x0);
}
801022c5:	c3                   	ret    

801022c6 <lapicw>:

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801022c6:	8b 0d 7c 26 11 80    	mov    0x8011267c,%ecx
801022cc:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801022cf:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801022d1:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801022d6:	8b 40 20             	mov    0x20(%eax),%eax
}
801022d9:	c3                   	ret    

801022da <cmos_read>:
801022da:	ba 70 00 00 00       	mov    $0x70,%edx
801022df:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022e0:	ba 71 00 00 00       	mov    $0x71,%edx
801022e5:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801022e6:	0f b6 c0             	movzbl %al,%eax
}
801022e9:	c3                   	ret    

801022ea <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801022ea:	55                   	push   %ebp
801022eb:	89 e5                	mov    %esp,%ebp
801022ed:	53                   	push   %ebx
801022ee:	83 ec 04             	sub    $0x4,%esp
801022f1:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801022f3:	b8 00 00 00 00       	mov    $0x0,%eax
801022f8:	e8 dd ff ff ff       	call   801022da <cmos_read>
801022fd:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801022ff:	b8 02 00 00 00       	mov    $0x2,%eax
80102304:	e8 d1 ff ff ff       	call   801022da <cmos_read>
80102309:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010230c:	b8 04 00 00 00       	mov    $0x4,%eax
80102311:	e8 c4 ff ff ff       	call   801022da <cmos_read>
80102316:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
80102319:	b8 07 00 00 00       	mov    $0x7,%eax
8010231e:	e8 b7 ff ff ff       	call   801022da <cmos_read>
80102323:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102326:	b8 08 00 00 00       	mov    $0x8,%eax
8010232b:	e8 aa ff ff ff       	call   801022da <cmos_read>
80102330:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102333:	b8 09 00 00 00       	mov    $0x9,%eax
80102338:	e8 9d ff ff ff       	call   801022da <cmos_read>
8010233d:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102340:	83 c4 04             	add    $0x4,%esp
80102343:	5b                   	pop    %ebx
80102344:	5d                   	pop    %ebp
80102345:	c3                   	ret    

80102346 <lapicinit>:
{
80102346:	f3 0f 1e fb          	endbr32 
  if(!lapic)
8010234a:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
80102351:	0f 84 fe 00 00 00    	je     80102455 <lapicinit+0x10f>
{
80102357:	55                   	push   %ebp
80102358:	89 e5                	mov    %esp,%ebp
8010235a:	83 ec 08             	sub    $0x8,%esp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010235d:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102362:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102367:	e8 5a ff ff ff       	call   801022c6 <lapicw>
  lapicw(TDCR, X1);
8010236c:	ba 0b 00 00 00       	mov    $0xb,%edx
80102371:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102376:	e8 4b ff ff ff       	call   801022c6 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010237b:	ba 20 00 02 00       	mov    $0x20020,%edx
80102380:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102385:	e8 3c ff ff ff       	call   801022c6 <lapicw>
  lapicw(TICR, 10000000);
8010238a:	ba 80 96 98 00       	mov    $0x989680,%edx
8010238f:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102394:	e8 2d ff ff ff       	call   801022c6 <lapicw>
  lapicw(LINT0, MASKED);
80102399:	ba 00 00 01 00       	mov    $0x10000,%edx
8010239e:	b8 d4 00 00 00       	mov    $0xd4,%eax
801023a3:	e8 1e ff ff ff       	call   801022c6 <lapicw>
  lapicw(LINT1, MASKED);
801023a8:	ba 00 00 01 00       	mov    $0x10000,%edx
801023ad:	b8 d8 00 00 00       	mov    $0xd8,%eax
801023b2:	e8 0f ff ff ff       	call   801022c6 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801023b7:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801023bc:	8b 40 30             	mov    0x30(%eax),%eax
801023bf:	c1 e8 10             	shr    $0x10,%eax
801023c2:	a8 fc                	test   $0xfc,%al
801023c4:	75 7b                	jne    80102441 <lapicinit+0xfb>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801023c6:	ba 33 00 00 00       	mov    $0x33,%edx
801023cb:	b8 dc 00 00 00       	mov    $0xdc,%eax
801023d0:	e8 f1 fe ff ff       	call   801022c6 <lapicw>
  lapicw(ESR, 0);
801023d5:	ba 00 00 00 00       	mov    $0x0,%edx
801023da:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023df:	e8 e2 fe ff ff       	call   801022c6 <lapicw>
  lapicw(ESR, 0);
801023e4:	ba 00 00 00 00       	mov    $0x0,%edx
801023e9:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023ee:	e8 d3 fe ff ff       	call   801022c6 <lapicw>
  lapicw(EOI, 0);
801023f3:	ba 00 00 00 00       	mov    $0x0,%edx
801023f8:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023fd:	e8 c4 fe ff ff       	call   801022c6 <lapicw>
  lapicw(ICRHI, 0);
80102402:	ba 00 00 00 00       	mov    $0x0,%edx
80102407:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010240c:	e8 b5 fe ff ff       	call   801022c6 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102411:	ba 00 85 08 00       	mov    $0x88500,%edx
80102416:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010241b:	e8 a6 fe ff ff       	call   801022c6 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102420:	a1 7c 26 11 80       	mov    0x8011267c,%eax
80102425:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
8010242b:	f6 c4 10             	test   $0x10,%ah
8010242e:	75 f0                	jne    80102420 <lapicinit+0xda>
  lapicw(TPR, 0);
80102430:	ba 00 00 00 00       	mov    $0x0,%edx
80102435:	b8 20 00 00 00       	mov    $0x20,%eax
8010243a:	e8 87 fe ff ff       	call   801022c6 <lapicw>
}
8010243f:	c9                   	leave  
80102440:	c3                   	ret    
    lapicw(PCINT, MASKED);
80102441:	ba 00 00 01 00       	mov    $0x10000,%edx
80102446:	b8 d0 00 00 00       	mov    $0xd0,%eax
8010244b:	e8 76 fe ff ff       	call   801022c6 <lapicw>
80102450:	e9 71 ff ff ff       	jmp    801023c6 <lapicinit+0x80>
80102455:	c3                   	ret    

80102456 <lapicid>:
{
80102456:	f3 0f 1e fb          	endbr32 
  if (!lapic)
8010245a:	a1 7c 26 11 80       	mov    0x8011267c,%eax
8010245f:	85 c0                	test   %eax,%eax
80102461:	74 07                	je     8010246a <lapicid+0x14>
  return lapic[ID] >> 24;
80102463:	8b 40 20             	mov    0x20(%eax),%eax
80102466:	c1 e8 18             	shr    $0x18,%eax
80102469:	c3                   	ret    
    return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010246f:	c3                   	ret    

80102470 <lapiceoi>:
{
80102470:	f3 0f 1e fb          	endbr32 
  if(lapic)
80102474:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
8010247b:	74 17                	je     80102494 <lapiceoi+0x24>
{
8010247d:	55                   	push   %ebp
8010247e:	89 e5                	mov    %esp,%ebp
80102480:	83 ec 08             	sub    $0x8,%esp
    lapicw(EOI, 0);
80102483:	ba 00 00 00 00       	mov    $0x0,%edx
80102488:	b8 2c 00 00 00       	mov    $0x2c,%eax
8010248d:	e8 34 fe ff ff       	call   801022c6 <lapicw>
}
80102492:	c9                   	leave  
80102493:	c3                   	ret    
80102494:	c3                   	ret    

80102495 <microdelay>:
{
80102495:	f3 0f 1e fb          	endbr32 
}
80102499:	c3                   	ret    

8010249a <lapicstartap>:
{
8010249a:	f3 0f 1e fb          	endbr32 
8010249e:	55                   	push   %ebp
8010249f:	89 e5                	mov    %esp,%ebp
801024a1:	57                   	push   %edi
801024a2:	56                   	push   %esi
801024a3:	53                   	push   %ebx
801024a4:	83 ec 0c             	sub    $0xc,%esp
801024a7:	8b 75 08             	mov    0x8(%ebp),%esi
801024aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024ad:	b8 0f 00 00 00       	mov    $0xf,%eax
801024b2:	ba 70 00 00 00       	mov    $0x70,%edx
801024b7:	ee                   	out    %al,(%dx)
801024b8:	b8 0a 00 00 00       	mov    $0xa,%eax
801024bd:	ba 71 00 00 00       	mov    $0x71,%edx
801024c2:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801024c3:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801024ca:	00 00 
  wrv[1] = addr >> 4;
801024cc:	89 f8                	mov    %edi,%eax
801024ce:	c1 e8 04             	shr    $0x4,%eax
801024d1:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
801024d7:	c1 e6 18             	shl    $0x18,%esi
801024da:	89 f2                	mov    %esi,%edx
801024dc:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024e1:	e8 e0 fd ff ff       	call   801022c6 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801024e6:	ba 00 c5 00 00       	mov    $0xc500,%edx
801024eb:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024f0:	e8 d1 fd ff ff       	call   801022c6 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801024f5:	ba 00 85 00 00       	mov    $0x8500,%edx
801024fa:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024ff:	e8 c2 fd ff ff       	call   801022c6 <lapicw>
  for(i = 0; i < 2; i++){
80102504:	bb 00 00 00 00       	mov    $0x0,%ebx
80102509:	eb 21                	jmp    8010252c <lapicstartap+0x92>
    lapicw(ICRHI, apicid<<24);
8010250b:	89 f2                	mov    %esi,%edx
8010250d:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102512:	e8 af fd ff ff       	call   801022c6 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102517:	89 fa                	mov    %edi,%edx
80102519:	c1 ea 0c             	shr    $0xc,%edx
8010251c:	80 ce 06             	or     $0x6,%dh
8010251f:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102524:	e8 9d fd ff ff       	call   801022c6 <lapicw>
  for(i = 0; i < 2; i++){
80102529:	83 c3 01             	add    $0x1,%ebx
8010252c:	83 fb 01             	cmp    $0x1,%ebx
8010252f:	7e da                	jle    8010250b <lapicstartap+0x71>
}
80102531:	83 c4 0c             	add    $0xc,%esp
80102534:	5b                   	pop    %ebx
80102535:	5e                   	pop    %esi
80102536:	5f                   	pop    %edi
80102537:	5d                   	pop    %ebp
80102538:	c3                   	ret    

80102539 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102539:	f3 0f 1e fb          	endbr32 
8010253d:	55                   	push   %ebp
8010253e:	89 e5                	mov    %esp,%ebp
80102540:	57                   	push   %edi
80102541:	56                   	push   %esi
80102542:	53                   	push   %ebx
80102543:	83 ec 3c             	sub    $0x3c,%esp
80102546:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102549:	b8 0b 00 00 00       	mov    $0xb,%eax
8010254e:	e8 87 fd ff ff       	call   801022da <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102553:	83 e0 04             	and    $0x4,%eax
80102556:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102558:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010255b:	e8 8a fd ff ff       	call   801022ea <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102560:	b8 0a 00 00 00       	mov    $0xa,%eax
80102565:	e8 70 fd ff ff       	call   801022da <cmos_read>
8010256a:	a8 80                	test   $0x80,%al
8010256c:	75 ea                	jne    80102558 <cmostime+0x1f>
        continue;
    fill_rtcdate(&t2);
8010256e:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102571:	89 d8                	mov    %ebx,%eax
80102573:	e8 72 fd ff ff       	call   801022ea <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102578:	83 ec 04             	sub    $0x4,%esp
8010257b:	6a 18                	push   $0x18
8010257d:	53                   	push   %ebx
8010257e:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102581:	50                   	push   %eax
80102582:	e8 01 1a 00 00       	call   80103f88 <memcmp>
80102587:	83 c4 10             	add    $0x10,%esp
8010258a:	85 c0                	test   %eax,%eax
8010258c:	75 ca                	jne    80102558 <cmostime+0x1f>
      break;
  }

  // convert
  if(bcd) {
8010258e:	85 ff                	test   %edi,%edi
80102590:	75 78                	jne    8010260a <cmostime+0xd1>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102592:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102595:	89 c2                	mov    %eax,%edx
80102597:	c1 ea 04             	shr    $0x4,%edx
8010259a:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010259d:	83 e0 0f             	and    $0xf,%eax
801025a0:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801025a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801025a9:	89 c2                	mov    %eax,%edx
801025ab:	c1 ea 04             	shr    $0x4,%edx
801025ae:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025b1:	83 e0 0f             	and    $0xf,%eax
801025b4:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801025ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
801025bd:	89 c2                	mov    %eax,%edx
801025bf:	c1 ea 04             	shr    $0x4,%edx
801025c2:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025c5:	83 e0 0f             	and    $0xf,%eax
801025c8:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801025ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
801025d1:	89 c2                	mov    %eax,%edx
801025d3:	c1 ea 04             	shr    $0x4,%edx
801025d6:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025d9:	83 e0 0f             	and    $0xf,%eax
801025dc:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025df:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
801025e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801025e5:	89 c2                	mov    %eax,%edx
801025e7:	c1 ea 04             	shr    $0x4,%edx
801025ea:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025ed:	83 e0 0f             	and    $0xf,%eax
801025f0:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801025f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801025f9:	89 c2                	mov    %eax,%edx
801025fb:	c1 ea 04             	shr    $0x4,%edx
801025fe:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102601:	83 e0 0f             	and    $0xf,%eax
80102604:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102607:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
8010260a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010260d:	89 06                	mov    %eax,(%esi)
8010260f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102612:	89 46 04             	mov    %eax,0x4(%esi)
80102615:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102618:	89 46 08             	mov    %eax,0x8(%esi)
8010261b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010261e:	89 46 0c             	mov    %eax,0xc(%esi)
80102621:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102624:	89 46 10             	mov    %eax,0x10(%esi)
80102627:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010262a:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
8010262d:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102634:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102637:	5b                   	pop    %ebx
80102638:	5e                   	pop    %esi
80102639:	5f                   	pop    %edi
8010263a:	5d                   	pop    %ebp
8010263b:	c3                   	ret    

8010263c <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010263c:	55                   	push   %ebp
8010263d:	89 e5                	mov    %esp,%ebp
8010263f:	53                   	push   %ebx
80102640:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102643:	ff 35 b4 26 11 80    	pushl  0x801126b4
80102649:	ff 35 c4 26 11 80    	pushl  0x801126c4
8010264f:	e8 1c db ff ff       	call   80100170 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102654:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102657:	89 1d c8 26 11 80    	mov    %ebx,0x801126c8
  for (i = 0; i < log.lh.n; i++) {
8010265d:	83 c4 10             	add    $0x10,%esp
80102660:	ba 00 00 00 00       	mov    $0x0,%edx
80102665:	39 d3                	cmp    %edx,%ebx
80102667:	7e 10                	jle    80102679 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
80102669:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
8010266d:	89 0c 95 cc 26 11 80 	mov    %ecx,-0x7feed934(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102674:	83 c2 01             	add    $0x1,%edx
80102677:	eb ec                	jmp    80102665 <read_head+0x29>
  }
  brelse(buf);
80102679:	83 ec 0c             	sub    $0xc,%esp
8010267c:	50                   	push   %eax
8010267d:	e8 5f db ff ff       	call   801001e1 <brelse>
}
80102682:	83 c4 10             	add    $0x10,%esp
80102685:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102688:	c9                   	leave  
80102689:	c3                   	ret    

8010268a <install_trans>:
{
8010268a:	55                   	push   %ebp
8010268b:	89 e5                	mov    %esp,%ebp
8010268d:	57                   	push   %edi
8010268e:	56                   	push   %esi
8010268f:	53                   	push   %ebx
80102690:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102693:	be 00 00 00 00       	mov    $0x0,%esi
80102698:	39 35 c8 26 11 80    	cmp    %esi,0x801126c8
8010269e:	7e 68                	jle    80102708 <install_trans+0x7e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801026a0:	89 f0                	mov    %esi,%eax
801026a2:	03 05 b4 26 11 80    	add    0x801126b4,%eax
801026a8:	83 c0 01             	add    $0x1,%eax
801026ab:	83 ec 08             	sub    $0x8,%esp
801026ae:	50                   	push   %eax
801026af:	ff 35 c4 26 11 80    	pushl  0x801126c4
801026b5:	e8 b6 da ff ff       	call   80100170 <bread>
801026ba:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801026bc:	83 c4 08             	add    $0x8,%esp
801026bf:	ff 34 b5 cc 26 11 80 	pushl  -0x7feed934(,%esi,4)
801026c6:	ff 35 c4 26 11 80    	pushl  0x801126c4
801026cc:	e8 9f da ff ff       	call   80100170 <bread>
801026d1:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801026d3:	8d 57 5c             	lea    0x5c(%edi),%edx
801026d6:	8d 40 5c             	lea    0x5c(%eax),%eax
801026d9:	83 c4 0c             	add    $0xc,%esp
801026dc:	68 00 02 00 00       	push   $0x200
801026e1:	52                   	push   %edx
801026e2:	50                   	push   %eax
801026e3:	e8 d9 18 00 00       	call   80103fc1 <memmove>
    bwrite(dbuf);  // write dst to disk
801026e8:	89 1c 24             	mov    %ebx,(%esp)
801026eb:	e8 b2 da ff ff       	call   801001a2 <bwrite>
    brelse(lbuf);
801026f0:	89 3c 24             	mov    %edi,(%esp)
801026f3:	e8 e9 da ff ff       	call   801001e1 <brelse>
    brelse(dbuf);
801026f8:	89 1c 24             	mov    %ebx,(%esp)
801026fb:	e8 e1 da ff ff       	call   801001e1 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102700:	83 c6 01             	add    $0x1,%esi
80102703:	83 c4 10             	add    $0x10,%esp
80102706:	eb 90                	jmp    80102698 <install_trans+0xe>
}
80102708:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010270b:	5b                   	pop    %ebx
8010270c:	5e                   	pop    %esi
8010270d:	5f                   	pop    %edi
8010270e:	5d                   	pop    %ebp
8010270f:	c3                   	ret    

80102710 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102710:	55                   	push   %ebp
80102711:	89 e5                	mov    %esp,%ebp
80102713:	53                   	push   %ebx
80102714:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102717:	ff 35 b4 26 11 80    	pushl  0x801126b4
8010271d:	ff 35 c4 26 11 80    	pushl  0x801126c4
80102723:	e8 48 da ff ff       	call   80100170 <bread>
80102728:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010272a:	8b 0d c8 26 11 80    	mov    0x801126c8,%ecx
80102730:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102733:	83 c4 10             	add    $0x10,%esp
80102736:	b8 00 00 00 00       	mov    $0x0,%eax
8010273b:	39 c1                	cmp    %eax,%ecx
8010273d:	7e 10                	jle    8010274f <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
8010273f:	8b 14 85 cc 26 11 80 	mov    -0x7feed934(,%eax,4),%edx
80102746:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
8010274a:	83 c0 01             	add    $0x1,%eax
8010274d:	eb ec                	jmp    8010273b <write_head+0x2b>
  }
  bwrite(buf);
8010274f:	83 ec 0c             	sub    $0xc,%esp
80102752:	53                   	push   %ebx
80102753:	e8 4a da ff ff       	call   801001a2 <bwrite>
  brelse(buf);
80102758:	89 1c 24             	mov    %ebx,(%esp)
8010275b:	e8 81 da ff ff       	call   801001e1 <brelse>
}
80102760:	83 c4 10             	add    $0x10,%esp
80102763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102766:	c9                   	leave  
80102767:	c3                   	ret    

80102768 <recover_from_log>:

static void
recover_from_log(void)
{
80102768:	55                   	push   %ebp
80102769:	89 e5                	mov    %esp,%ebp
8010276b:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010276e:	e8 c9 fe ff ff       	call   8010263c <read_head>
  install_trans(); // if committed, copy from log to disk
80102773:	e8 12 ff ff ff       	call   8010268a <install_trans>
  log.lh.n = 0;
80102778:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
8010277f:	00 00 00 
  write_head(); // clear the log
80102782:	e8 89 ff ff ff       	call   80102710 <write_head>
}
80102787:	c9                   	leave  
80102788:	c3                   	ret    

80102789 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102789:	55                   	push   %ebp
8010278a:	89 e5                	mov    %esp,%ebp
8010278c:	57                   	push   %edi
8010278d:	56                   	push   %esi
8010278e:	53                   	push   %ebx
8010278f:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102792:	be 00 00 00 00       	mov    $0x0,%esi
80102797:	39 35 c8 26 11 80    	cmp    %esi,0x801126c8
8010279d:	7e 68                	jle    80102807 <write_log+0x7e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010279f:	89 f0                	mov    %esi,%eax
801027a1:	03 05 b4 26 11 80    	add    0x801126b4,%eax
801027a7:	83 c0 01             	add    $0x1,%eax
801027aa:	83 ec 08             	sub    $0x8,%esp
801027ad:	50                   	push   %eax
801027ae:	ff 35 c4 26 11 80    	pushl  0x801126c4
801027b4:	e8 b7 d9 ff ff       	call   80100170 <bread>
801027b9:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801027bb:	83 c4 08             	add    $0x8,%esp
801027be:	ff 34 b5 cc 26 11 80 	pushl  -0x7feed934(,%esi,4)
801027c5:	ff 35 c4 26 11 80    	pushl  0x801126c4
801027cb:	e8 a0 d9 ff ff       	call   80100170 <bread>
801027d0:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801027d2:	8d 50 5c             	lea    0x5c(%eax),%edx
801027d5:	8d 43 5c             	lea    0x5c(%ebx),%eax
801027d8:	83 c4 0c             	add    $0xc,%esp
801027db:	68 00 02 00 00       	push   $0x200
801027e0:	52                   	push   %edx
801027e1:	50                   	push   %eax
801027e2:	e8 da 17 00 00       	call   80103fc1 <memmove>
    bwrite(to);  // write the log
801027e7:	89 1c 24             	mov    %ebx,(%esp)
801027ea:	e8 b3 d9 ff ff       	call   801001a2 <bwrite>
    brelse(from);
801027ef:	89 3c 24             	mov    %edi,(%esp)
801027f2:	e8 ea d9 ff ff       	call   801001e1 <brelse>
    brelse(to);
801027f7:	89 1c 24             	mov    %ebx,(%esp)
801027fa:	e8 e2 d9 ff ff       	call   801001e1 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027ff:	83 c6 01             	add    $0x1,%esi
80102802:	83 c4 10             	add    $0x10,%esp
80102805:	eb 90                	jmp    80102797 <write_log+0xe>
  }
}
80102807:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010280a:	5b                   	pop    %ebx
8010280b:	5e                   	pop    %esi
8010280c:	5f                   	pop    %edi
8010280d:	5d                   	pop    %ebp
8010280e:	c3                   	ret    

8010280f <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
8010280f:	83 3d c8 26 11 80 00 	cmpl   $0x0,0x801126c8
80102816:	7f 01                	jg     80102819 <commit+0xa>
80102818:	c3                   	ret    
{
80102819:	55                   	push   %ebp
8010281a:	89 e5                	mov    %esp,%ebp
8010281c:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
8010281f:	e8 65 ff ff ff       	call   80102789 <write_log>
    write_head();    // Write header to disk -- the real commit
80102824:	e8 e7 fe ff ff       	call   80102710 <write_head>
    install_trans(); // Now install writes to home locations
80102829:	e8 5c fe ff ff       	call   8010268a <install_trans>
    log.lh.n = 0;
8010282e:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
80102835:	00 00 00 
    write_head();    // Erase the transaction from the log
80102838:	e8 d3 fe ff ff       	call   80102710 <write_head>
  }
}
8010283d:	c9                   	leave  
8010283e:	c3                   	ret    

8010283f <initlog>:
{
8010283f:	f3 0f 1e fb          	endbr32 
80102843:	55                   	push   %ebp
80102844:	89 e5                	mov    %esp,%ebp
80102846:	53                   	push   %ebx
80102847:	83 ec 2c             	sub    $0x2c,%esp
8010284a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
8010284d:	68 80 73 10 80       	push   $0x80107380
80102852:	68 80 26 11 80       	push   $0x80112680
80102857:	e8 e1 14 00 00       	call   80103d3d <initlock>
  readsb(dev, &sb);
8010285c:	83 c4 08             	add    $0x8,%esp
8010285f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102862:	50                   	push   %eax
80102863:	53                   	push   %ebx
80102864:	e8 8b ea ff ff       	call   801012f4 <readsb>
  log.start = sb.logstart;
80102869:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010286c:	a3 b4 26 11 80       	mov    %eax,0x801126b4
  log.size = sb.nlog;
80102871:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102874:	a3 b8 26 11 80       	mov    %eax,0x801126b8
  log.dev = dev;
80102879:	89 1d c4 26 11 80    	mov    %ebx,0x801126c4
  recover_from_log();
8010287f:	e8 e4 fe ff ff       	call   80102768 <recover_from_log>
}
80102884:	83 c4 10             	add    $0x10,%esp
80102887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010288a:	c9                   	leave  
8010288b:	c3                   	ret    

8010288c <begin_op>:
{
8010288c:	f3 0f 1e fb          	endbr32 
80102890:	55                   	push   %ebp
80102891:	89 e5                	mov    %esp,%ebp
80102893:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102896:	68 80 26 11 80       	push   $0x80112680
8010289b:	e8 ed 15 00 00       	call   80103e8d <acquire>
801028a0:	83 c4 10             	add    $0x10,%esp
801028a3:	eb 15                	jmp    801028ba <begin_op+0x2e>
      sleep(&log, &log.lock);
801028a5:	83 ec 08             	sub    $0x8,%esp
801028a8:	68 80 26 11 80       	push   $0x80112680
801028ad:	68 80 26 11 80       	push   $0x80112680
801028b2:	e8 af 0f 00 00       	call   80103866 <sleep>
801028b7:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801028ba:	83 3d c0 26 11 80 00 	cmpl   $0x0,0x801126c0
801028c1:	75 e2                	jne    801028a5 <begin_op+0x19>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801028c3:	a1 bc 26 11 80       	mov    0x801126bc,%eax
801028c8:	83 c0 01             	add    $0x1,%eax
801028cb:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801028ce:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801028d1:	03 15 c8 26 11 80    	add    0x801126c8,%edx
801028d7:	83 fa 1e             	cmp    $0x1e,%edx
801028da:	7e 17                	jle    801028f3 <begin_op+0x67>
      sleep(&log, &log.lock);
801028dc:	83 ec 08             	sub    $0x8,%esp
801028df:	68 80 26 11 80       	push   $0x80112680
801028e4:	68 80 26 11 80       	push   $0x80112680
801028e9:	e8 78 0f 00 00       	call   80103866 <sleep>
801028ee:	83 c4 10             	add    $0x10,%esp
801028f1:	eb c7                	jmp    801028ba <begin_op+0x2e>
      log.outstanding += 1;
801028f3:	a3 bc 26 11 80       	mov    %eax,0x801126bc
      release(&log.lock);
801028f8:	83 ec 0c             	sub    $0xc,%esp
801028fb:	68 80 26 11 80       	push   $0x80112680
80102900:	e8 f1 15 00 00       	call   80103ef6 <release>
}
80102905:	83 c4 10             	add    $0x10,%esp
80102908:	c9                   	leave  
80102909:	c3                   	ret    

8010290a <end_op>:
{
8010290a:	f3 0f 1e fb          	endbr32 
8010290e:	55                   	push   %ebp
8010290f:	89 e5                	mov    %esp,%ebp
80102911:	53                   	push   %ebx
80102912:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102915:	68 80 26 11 80       	push   $0x80112680
8010291a:	e8 6e 15 00 00       	call   80103e8d <acquire>
  log.outstanding -= 1;
8010291f:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102924:	83 e8 01             	sub    $0x1,%eax
80102927:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  if(log.committing)
8010292c:	8b 1d c0 26 11 80    	mov    0x801126c0,%ebx
80102932:	83 c4 10             	add    $0x10,%esp
80102935:	85 db                	test   %ebx,%ebx
80102937:	75 2c                	jne    80102965 <end_op+0x5b>
  if(log.outstanding == 0){
80102939:	85 c0                	test   %eax,%eax
8010293b:	75 35                	jne    80102972 <end_op+0x68>
    log.committing = 1;
8010293d:	c7 05 c0 26 11 80 01 	movl   $0x1,0x801126c0
80102944:	00 00 00 
    do_commit = 1;
80102947:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
8010294c:	83 ec 0c             	sub    $0xc,%esp
8010294f:	68 80 26 11 80       	push   $0x80112680
80102954:	e8 9d 15 00 00       	call   80103ef6 <release>
  if(do_commit){
80102959:	83 c4 10             	add    $0x10,%esp
8010295c:	85 db                	test   %ebx,%ebx
8010295e:	75 24                	jne    80102984 <end_op+0x7a>
}
80102960:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102963:	c9                   	leave  
80102964:	c3                   	ret    
    panic("log.committing");
80102965:	83 ec 0c             	sub    $0xc,%esp
80102968:	68 84 73 10 80       	push   $0x80107384
8010296d:	e8 ea d9 ff ff       	call   8010035c <panic>
    wakeup(&log);
80102972:	83 ec 0c             	sub    $0xc,%esp
80102975:	68 80 26 11 80       	push   $0x80112680
8010297a:	e8 54 10 00 00       	call   801039d3 <wakeup>
8010297f:	83 c4 10             	add    $0x10,%esp
80102982:	eb c8                	jmp    8010294c <end_op+0x42>
    commit();
80102984:	e8 86 fe ff ff       	call   8010280f <commit>
    acquire(&log.lock);
80102989:	83 ec 0c             	sub    $0xc,%esp
8010298c:	68 80 26 11 80       	push   $0x80112680
80102991:	e8 f7 14 00 00       	call   80103e8d <acquire>
    log.committing = 0;
80102996:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
8010299d:	00 00 00 
    wakeup(&log);
801029a0:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801029a7:	e8 27 10 00 00       	call   801039d3 <wakeup>
    release(&log.lock);
801029ac:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801029b3:	e8 3e 15 00 00       	call   80103ef6 <release>
801029b8:	83 c4 10             	add    $0x10,%esp
}
801029bb:	eb a3                	jmp    80102960 <end_op+0x56>

801029bd <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801029bd:	f3 0f 1e fb          	endbr32 
801029c1:	55                   	push   %ebp
801029c2:	89 e5                	mov    %esp,%ebp
801029c4:	53                   	push   %ebx
801029c5:	83 ec 04             	sub    $0x4,%esp
801029c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801029cb:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
801029d1:	83 fa 1d             	cmp    $0x1d,%edx
801029d4:	7f 45                	jg     80102a1b <log_write+0x5e>
801029d6:	a1 b8 26 11 80       	mov    0x801126b8,%eax
801029db:	83 e8 01             	sub    $0x1,%eax
801029de:	39 c2                	cmp    %eax,%edx
801029e0:	7d 39                	jge    80102a1b <log_write+0x5e>
    panic("too big a transaction");
  if (log.outstanding < 1)
801029e2:	83 3d bc 26 11 80 00 	cmpl   $0x0,0x801126bc
801029e9:	7e 3d                	jle    80102a28 <log_write+0x6b>
    panic("log_write outside of trans");

  acquire(&log.lock);
801029eb:	83 ec 0c             	sub    $0xc,%esp
801029ee:	68 80 26 11 80       	push   $0x80112680
801029f3:	e8 95 14 00 00       	call   80103e8d <acquire>
  for (i = 0; i < log.lh.n; i++) {
801029f8:	83 c4 10             	add    $0x10,%esp
801029fb:	b8 00 00 00 00       	mov    $0x0,%eax
80102a00:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
80102a06:	39 c2                	cmp    %eax,%edx
80102a08:	7e 2b                	jle    80102a35 <log_write+0x78>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102a0a:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a0d:	39 0c 85 cc 26 11 80 	cmp    %ecx,-0x7feed934(,%eax,4)
80102a14:	74 1f                	je     80102a35 <log_write+0x78>
  for (i = 0; i < log.lh.n; i++) {
80102a16:	83 c0 01             	add    $0x1,%eax
80102a19:	eb e5                	jmp    80102a00 <log_write+0x43>
    panic("too big a transaction");
80102a1b:	83 ec 0c             	sub    $0xc,%esp
80102a1e:	68 93 73 10 80       	push   $0x80107393
80102a23:	e8 34 d9 ff ff       	call   8010035c <panic>
    panic("log_write outside of trans");
80102a28:	83 ec 0c             	sub    $0xc,%esp
80102a2b:	68 a9 73 10 80       	push   $0x801073a9
80102a30:	e8 27 d9 ff ff       	call   8010035c <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102a35:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a38:	89 0c 85 cc 26 11 80 	mov    %ecx,-0x7feed934(,%eax,4)
  if (i == log.lh.n)
80102a3f:	39 c2                	cmp    %eax,%edx
80102a41:	74 18                	je     80102a5b <log_write+0x9e>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102a43:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102a46:	83 ec 0c             	sub    $0xc,%esp
80102a49:	68 80 26 11 80       	push   $0x80112680
80102a4e:	e8 a3 14 00 00       	call   80103ef6 <release>
}
80102a53:	83 c4 10             	add    $0x10,%esp
80102a56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a59:	c9                   	leave  
80102a5a:	c3                   	ret    
    log.lh.n++;
80102a5b:	83 c2 01             	add    $0x1,%edx
80102a5e:	89 15 c8 26 11 80    	mov    %edx,0x801126c8
80102a64:	eb dd                	jmp    80102a43 <log_write+0x86>

80102a66 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102a66:	55                   	push   %ebp
80102a67:	89 e5                	mov    %esp,%ebp
80102a69:	53                   	push   %ebx
80102a6a:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102a6d:	68 8a 00 00 00       	push   $0x8a
80102a72:	68 8c a4 10 80       	push   $0x8010a48c
80102a77:	68 00 70 00 80       	push   $0x80007000
80102a7c:	e8 40 15 00 00       	call   80103fc1 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102a81:	83 c4 10             	add    $0x10,%esp
80102a84:	bb 80 27 11 80       	mov    $0x80112780,%ebx
80102a89:	eb 13                	jmp    80102a9e <startothers+0x38>
80102a8b:	83 ec 0c             	sub    $0xc,%esp
80102a8e:	68 a8 70 10 80       	push   $0x801070a8
80102a93:	e8 c4 d8 ff ff       	call   8010035c <panic>
80102a98:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102a9e:	69 05 00 2d 11 80 b0 	imul   $0xb0,0x80112d00,%eax
80102aa5:	00 00 00 
80102aa8:	05 80 27 11 80       	add    $0x80112780,%eax
80102aad:	39 d8                	cmp    %ebx,%eax
80102aaf:	76 58                	jbe    80102b09 <startothers+0xa3>
    if(c == mycpu())  // We've started already.
80102ab1:	e8 46 08 00 00       	call   801032fc <mycpu>
80102ab6:	39 c3                	cmp    %eax,%ebx
80102ab8:	74 de                	je     80102a98 <startothers+0x32>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102aba:	e8 c0 f6 ff ff       	call   8010217f <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102abf:	05 00 10 00 00       	add    $0x1000,%eax
80102ac4:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102ac9:	c7 05 f8 6f 00 80 4d 	movl   $0x80102b4d,0x80006ff8
80102ad0:	2b 10 80 
    if (a < (void*) KERNBASE)
80102ad3:	b8 00 90 10 80       	mov    $0x80109000,%eax
80102ad8:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80102add:	76 ac                	jbe    80102a8b <startothers+0x25>
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102adf:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102ae6:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102ae9:	83 ec 08             	sub    $0x8,%esp
80102aec:	68 00 70 00 00       	push   $0x7000
80102af1:	0f b6 03             	movzbl (%ebx),%eax
80102af4:	50                   	push   %eax
80102af5:	e8 a0 f9 ff ff       	call   8010249a <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102afa:	83 c4 10             	add    $0x10,%esp
80102afd:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102b03:	85 c0                	test   %eax,%eax
80102b05:	74 f6                	je     80102afd <startothers+0x97>
80102b07:	eb 8f                	jmp    80102a98 <startothers+0x32>
      ;
  }
}
80102b09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b0c:	c9                   	leave  
80102b0d:	c3                   	ret    

80102b0e <mpmain>:
{
80102b0e:	55                   	push   %ebp
80102b0f:	89 e5                	mov    %esp,%ebp
80102b11:	53                   	push   %ebx
80102b12:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102b15:	e8 42 08 00 00       	call   8010335c <cpuid>
80102b1a:	89 c3                	mov    %eax,%ebx
80102b1c:	e8 3b 08 00 00       	call   8010335c <cpuid>
80102b21:	83 ec 04             	sub    $0x4,%esp
80102b24:	53                   	push   %ebx
80102b25:	50                   	push   %eax
80102b26:	68 c4 73 10 80       	push   $0x801073c4
80102b2b:	e8 f9 da ff ff       	call   80100629 <cprintf>
  idtinit();       // load idt register
80102b30:	e8 43 26 00 00       	call   80105178 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102b35:	e8 c2 07 00 00       	call   801032fc <mycpu>
80102b3a:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102b3c:	b8 01 00 00 00       	mov    $0x1,%eax
80102b41:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102b48:	e8 c3 0a 00 00       	call   80103610 <scheduler>

80102b4d <mpenter>:
{
80102b4d:	f3 0f 1e fb          	endbr32 
80102b51:	55                   	push   %ebp
80102b52:	89 e5                	mov    %esp,%ebp
80102b54:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102b57:	e8 66 36 00 00       	call   801061c2 <switchkvm>
  seginit();
80102b5c:	e8 11 35 00 00       	call   80106072 <seginit>
  lapicinit();
80102b61:	e8 e0 f7 ff ff       	call   80102346 <lapicinit>
  mpmain();
80102b66:	e8 a3 ff ff ff       	call   80102b0e <mpmain>

80102b6b <main>:
{
80102b6b:	f3 0f 1e fb          	endbr32 
80102b6f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102b73:	83 e4 f0             	and    $0xfffffff0,%esp
80102b76:	ff 71 fc             	pushl  -0x4(%ecx)
80102b79:	55                   	push   %ebp
80102b7a:	89 e5                	mov    %esp,%ebp
80102b7c:	51                   	push   %ecx
80102b7d:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102b80:	68 00 00 40 80       	push   $0x80400000
80102b85:	68 a8 55 11 80       	push   $0x801155a8
80102b8a:	e8 96 f5 ff ff       	call   80102125 <kinit1>
  kvmalloc();      // kernel page table
80102b8f:	e8 6b 3b 00 00       	call   801066ff <kvmalloc>
  mpinit();        // detect other processors
80102b94:	e8 ef 01 00 00       	call   80102d88 <mpinit>
  lapicinit();     // interrupt controller
80102b99:	e8 a8 f7 ff ff       	call   80102346 <lapicinit>
  seginit();       // segment descriptors
80102b9e:	e8 cf 34 00 00       	call   80106072 <seginit>
  picinit();       // disable pic
80102ba3:	e8 ba 02 00 00       	call   80102e62 <picinit>
  ioapicinit();    // another interrupt controller
80102ba8:	e8 cd f3 ff ff       	call   80101f7a <ioapicinit>
  consoleinit();   // console hardware
80102bad:	e8 02 dd ff ff       	call   801008b4 <consoleinit>
  uartinit();      // serial port
80102bb2:	e8 79 28 00 00       	call   80105430 <uartinit>
  pinit();         // process table
80102bb7:	e8 22 07 00 00       	call   801032de <pinit>
  tvinit();        // trap vectors
80102bbc:	e8 02 25 00 00       	call   801050c3 <tvinit>
  binit();         // buffer cache
80102bc1:	e8 2e d5 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102bc6:	e8 75 e0 ff ff       	call   80100c40 <fileinit>
  ideinit();       // disk 
80102bcb:	e8 ac f1 ff ff       	call   80101d7c <ideinit>
  helloInit();     //hello
80102bd0:	e8 43 42 00 00       	call   80106e18 <helloInit>
  nullInit();
80102bd5:	e8 ae 3d 00 00       	call   80106988 <nullInit>
  zeroInit();
80102bda:	e8 16 3e 00 00       	call   801069f5 <zeroInit>
  ticksinit();
80102bdf:	e8 c7 41 00 00       	call   80106dab <ticksinit>
  startothers();   // start other processors
80102be4:	e8 7d fe ff ff       	call   80102a66 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102be9:	83 c4 08             	add    $0x8,%esp
80102bec:	68 00 00 00 8e       	push   $0x8e000000
80102bf1:	68 00 00 40 80       	push   $0x80400000
80102bf6:	e8 60 f5 ff ff       	call   8010215b <kinit2>
  userinit();      // first user process
80102bfb:	e8 a3 07 00 00       	call   801033a3 <userinit>
  mpmain();        // finish this processor's setup
80102c00:	e8 09 ff ff ff       	call   80102b0e <mpmain>

80102c05 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102c05:	55                   	push   %ebp
80102c06:	89 e5                	mov    %esp,%ebp
80102c08:	56                   	push   %esi
80102c09:	53                   	push   %ebx
80102c0a:	89 c6                	mov    %eax,%esi
  int i, sum;

  sum = 0;
80102c0c:	b8 00 00 00 00       	mov    $0x0,%eax
  for(i=0; i<len; i++)
80102c11:	b9 00 00 00 00       	mov    $0x0,%ecx
80102c16:	39 d1                	cmp    %edx,%ecx
80102c18:	7d 0b                	jge    80102c25 <sum+0x20>
    sum += addr[i];
80102c1a:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
80102c1e:	01 d8                	add    %ebx,%eax
  for(i=0; i<len; i++)
80102c20:	83 c1 01             	add    $0x1,%ecx
80102c23:	eb f1                	jmp    80102c16 <sum+0x11>
  return sum;
}
80102c25:	5b                   	pop    %ebx
80102c26:	5e                   	pop    %esi
80102c27:	5d                   	pop    %ebp
80102c28:	c3                   	ret    

80102c29 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
80102c2c:	56                   	push   %esi
80102c2d:	53                   	push   %ebx
}

// Convert physical address to kernel virtual address
static inline void *P2V(uint a) {
    extern void panic(char*) __attribute__((noreturn));
    if (a > KERNBASE)
80102c2e:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80102c33:	77 0b                	ja     80102c40 <mpsearch1+0x17>
        panic("P2V on address > KERNBASE");
    return (char*)a + KERNBASE;
80102c35:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
80102c3b:	8d 34 13             	lea    (%ebx,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102c3e:	eb 10                	jmp    80102c50 <mpsearch1+0x27>
        panic("P2V on address > KERNBASE");
80102c40:	83 ec 0c             	sub    $0xc,%esp
80102c43:	68 d8 73 10 80       	push   $0x801073d8
80102c48:	e8 0f d7 ff ff       	call   8010035c <panic>
80102c4d:	83 c3 10             	add    $0x10,%ebx
80102c50:	39 f3                	cmp    %esi,%ebx
80102c52:	73 29                	jae    80102c7d <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102c54:	83 ec 04             	sub    $0x4,%esp
80102c57:	6a 04                	push   $0x4
80102c59:	68 f2 73 10 80       	push   $0x801073f2
80102c5e:	53                   	push   %ebx
80102c5f:	e8 24 13 00 00       	call   80103f88 <memcmp>
80102c64:	83 c4 10             	add    $0x10,%esp
80102c67:	85 c0                	test   %eax,%eax
80102c69:	75 e2                	jne    80102c4d <mpsearch1+0x24>
80102c6b:	ba 10 00 00 00       	mov    $0x10,%edx
80102c70:	89 d8                	mov    %ebx,%eax
80102c72:	e8 8e ff ff ff       	call   80102c05 <sum>
80102c77:	84 c0                	test   %al,%al
80102c79:	75 d2                	jne    80102c4d <mpsearch1+0x24>
80102c7b:	eb 05                	jmp    80102c82 <mpsearch1+0x59>
      return (struct mp*)p;
  return 0;
80102c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102c82:	89 d8                	mov    %ebx,%eax
80102c84:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102c87:	5b                   	pop    %ebx
80102c88:	5e                   	pop    %esi
80102c89:	5d                   	pop    %ebp
80102c8a:	c3                   	ret    

80102c8b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102c8b:	55                   	push   %ebp
80102c8c:	89 e5                	mov    %esp,%ebp
80102c8e:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102c91:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c98:	c1 e0 08             	shl    $0x8,%eax
80102c9b:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102ca2:	09 d0                	or     %edx,%eax
80102ca4:	c1 e0 04             	shl    $0x4,%eax
80102ca7:	74 1f                	je     80102cc8 <mpsearch+0x3d>
    if((mp = mpsearch1(p, 1024)))
80102ca9:	ba 00 04 00 00       	mov    $0x400,%edx
80102cae:	e8 76 ff ff ff       	call   80102c29 <mpsearch1>
80102cb3:	85 c0                	test   %eax,%eax
80102cb5:	75 0f                	jne    80102cc6 <mpsearch+0x3b>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102cb7:	ba 00 00 01 00       	mov    $0x10000,%edx
80102cbc:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102cc1:	e8 63 ff ff ff       	call   80102c29 <mpsearch1>
}
80102cc6:	c9                   	leave  
80102cc7:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102cc8:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102ccf:	c1 e0 08             	shl    $0x8,%eax
80102cd2:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102cd9:	09 d0                	or     %edx,%eax
80102cdb:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102cde:	2d 00 04 00 00       	sub    $0x400,%eax
80102ce3:	ba 00 04 00 00       	mov    $0x400,%edx
80102ce8:	e8 3c ff ff ff       	call   80102c29 <mpsearch1>
80102ced:	85 c0                	test   %eax,%eax
80102cef:	75 d5                	jne    80102cc6 <mpsearch+0x3b>
80102cf1:	eb c4                	jmp    80102cb7 <mpsearch+0x2c>

80102cf3 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102cf3:	55                   	push   %ebp
80102cf4:	89 e5                	mov    %esp,%ebp
80102cf6:	57                   	push   %edi
80102cf7:	56                   	push   %esi
80102cf8:	53                   	push   %ebx
80102cf9:	83 ec 0c             	sub    $0xc,%esp
80102cfc:	89 c7                	mov    %eax,%edi
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102cfe:	e8 88 ff ff ff       	call   80102c8b <mpsearch>
80102d03:	89 c6                	mov    %eax,%esi
80102d05:	85 c0                	test   %eax,%eax
80102d07:	74 66                	je     80102d6f <mpconfig+0x7c>
80102d09:	8b 58 04             	mov    0x4(%eax),%ebx
80102d0c:	85 db                	test   %ebx,%ebx
80102d0e:	74 48                	je     80102d58 <mpconfig+0x65>
    if (a > KERNBASE)
80102d10:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80102d16:	77 4a                	ja     80102d62 <mpconfig+0x6f>
    return (char*)a + KERNBASE;
80102d18:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
80102d1e:	83 ec 04             	sub    $0x4,%esp
80102d21:	6a 04                	push   $0x4
80102d23:	68 f7 73 10 80       	push   $0x801073f7
80102d28:	53                   	push   %ebx
80102d29:	e8 5a 12 00 00       	call   80103f88 <memcmp>
80102d2e:	83 c4 10             	add    $0x10,%esp
80102d31:	85 c0                	test   %eax,%eax
80102d33:	75 3e                	jne    80102d73 <mpconfig+0x80>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102d35:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
80102d39:	3c 01                	cmp    $0x1,%al
80102d3b:	0f 95 c2             	setne  %dl
80102d3e:	3c 04                	cmp    $0x4,%al
80102d40:	0f 95 c0             	setne  %al
80102d43:	84 c2                	test   %al,%dl
80102d45:	75 33                	jne    80102d7a <mpconfig+0x87>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102d47:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
80102d4b:	89 d8                	mov    %ebx,%eax
80102d4d:	e8 b3 fe ff ff       	call   80102c05 <sum>
80102d52:	84 c0                	test   %al,%al
80102d54:	75 2b                	jne    80102d81 <mpconfig+0x8e>
    return 0;
  *pmp = mp;
80102d56:	89 37                	mov    %esi,(%edi)
  return conf;
}
80102d58:	89 d8                	mov    %ebx,%eax
80102d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d5d:	5b                   	pop    %ebx
80102d5e:	5e                   	pop    %esi
80102d5f:	5f                   	pop    %edi
80102d60:	5d                   	pop    %ebp
80102d61:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80102d62:	83 ec 0c             	sub    $0xc,%esp
80102d65:	68 d8 73 10 80       	push   $0x801073d8
80102d6a:	e8 ed d5 ff ff       	call   8010035c <panic>
    return 0;
80102d6f:	89 c3                	mov    %eax,%ebx
80102d71:	eb e5                	jmp    80102d58 <mpconfig+0x65>
    return 0;
80102d73:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d78:	eb de                	jmp    80102d58 <mpconfig+0x65>
    return 0;
80102d7a:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d7f:	eb d7                	jmp    80102d58 <mpconfig+0x65>
    return 0;
80102d81:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d86:	eb d0                	jmp    80102d58 <mpconfig+0x65>

80102d88 <mpinit>:

void
mpinit(void)
{
80102d88:	f3 0f 1e fb          	endbr32 
80102d8c:	55                   	push   %ebp
80102d8d:	89 e5                	mov    %esp,%ebp
80102d8f:	57                   	push   %edi
80102d90:	56                   	push   %esi
80102d91:	53                   	push   %ebx
80102d92:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102d95:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102d98:	e8 56 ff ff ff       	call   80102cf3 <mpconfig>
80102d9d:	85 c0                	test   %eax,%eax
80102d9f:	74 19                	je     80102dba <mpinit+0x32>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102da1:	8b 50 24             	mov    0x24(%eax),%edx
80102da4:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102daa:	8d 50 2c             	lea    0x2c(%eax),%edx
80102dad:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102db1:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102db3:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102db8:	eb 20                	jmp    80102dda <mpinit+0x52>
    panic("Expect to run on an SMP");
80102dba:	83 ec 0c             	sub    $0xc,%esp
80102dbd:	68 fc 73 10 80       	push   $0x801073fc
80102dc2:	e8 95 d5 ff ff       	call   8010035c <panic>
    switch(*p){
80102dc7:	bb 00 00 00 00       	mov    $0x0,%ebx
80102dcc:	eb 0c                	jmp    80102dda <mpinit+0x52>
80102dce:	83 e8 03             	sub    $0x3,%eax
80102dd1:	3c 01                	cmp    $0x1,%al
80102dd3:	76 1a                	jbe    80102def <mpinit+0x67>
80102dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102dda:	39 ca                	cmp    %ecx,%edx
80102ddc:	73 4d                	jae    80102e2b <mpinit+0xa3>
    switch(*p){
80102dde:	0f b6 02             	movzbl (%edx),%eax
80102de1:	3c 02                	cmp    $0x2,%al
80102de3:	74 38                	je     80102e1d <mpinit+0x95>
80102de5:	77 e7                	ja     80102dce <mpinit+0x46>
80102de7:	84 c0                	test   %al,%al
80102de9:	74 09                	je     80102df4 <mpinit+0x6c>
80102deb:	3c 01                	cmp    $0x1,%al
80102ded:	75 d8                	jne    80102dc7 <mpinit+0x3f>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102def:	83 c2 08             	add    $0x8,%edx
      continue;
80102df2:	eb e6                	jmp    80102dda <mpinit+0x52>
      if(ncpu < NCPU) {
80102df4:	8b 35 00 2d 11 80    	mov    0x80112d00,%esi
80102dfa:	83 fe 07             	cmp    $0x7,%esi
80102dfd:	7f 19                	jg     80102e18 <mpinit+0x90>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102dff:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e03:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102e09:	88 87 80 27 11 80    	mov    %al,-0x7feed880(%edi)
        ncpu++;
80102e0f:	83 c6 01             	add    $0x1,%esi
80102e12:	89 35 00 2d 11 80    	mov    %esi,0x80112d00
      p += sizeof(struct mpproc);
80102e18:	83 c2 14             	add    $0x14,%edx
      continue;
80102e1b:	eb bd                	jmp    80102dda <mpinit+0x52>
      ioapicid = ioapic->apicno;
80102e1d:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e21:	a2 60 27 11 80       	mov    %al,0x80112760
      p += sizeof(struct mpioapic);
80102e26:	83 c2 08             	add    $0x8,%edx
      continue;
80102e29:	eb af                	jmp    80102dda <mpinit+0x52>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102e2b:	85 db                	test   %ebx,%ebx
80102e2d:	74 26                	je     80102e55 <mpinit+0xcd>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102e2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e32:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102e36:	74 15                	je     80102e4d <mpinit+0xc5>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e38:	b8 70 00 00 00       	mov    $0x70,%eax
80102e3d:	ba 22 00 00 00       	mov    $0x22,%edx
80102e42:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e43:	ba 23 00 00 00       	mov    $0x23,%edx
80102e48:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102e49:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e4c:	ee                   	out    %al,(%dx)
  }
}
80102e4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e50:	5b                   	pop    %ebx
80102e51:	5e                   	pop    %esi
80102e52:	5f                   	pop    %edi
80102e53:	5d                   	pop    %ebp
80102e54:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102e55:	83 ec 0c             	sub    $0xc,%esp
80102e58:	68 14 74 10 80       	push   $0x80107414
80102e5d:	e8 fa d4 ff ff       	call   8010035c <panic>

80102e62 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102e62:	f3 0f 1e fb          	endbr32 
80102e66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e6b:	ba 21 00 00 00       	mov    $0x21,%edx
80102e70:	ee                   	out    %al,(%dx)
80102e71:	ba a1 00 00 00       	mov    $0xa1,%edx
80102e76:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102e77:	c3                   	ret    

80102e78 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102e78:	f3 0f 1e fb          	endbr32 
80102e7c:	55                   	push   %ebp
80102e7d:	89 e5                	mov    %esp,%ebp
80102e7f:	57                   	push   %edi
80102e80:	56                   	push   %esi
80102e81:	53                   	push   %ebx
80102e82:	83 ec 0c             	sub    $0xc,%esp
80102e85:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e88:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102e8b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102e91:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102e97:	e8 c2 dd ff ff       	call   80100c5e <filealloc>
80102e9c:	89 03                	mov    %eax,(%ebx)
80102e9e:	85 c0                	test   %eax,%eax
80102ea0:	0f 84 88 00 00 00    	je     80102f2e <pipealloc+0xb6>
80102ea6:	e8 b3 dd ff ff       	call   80100c5e <filealloc>
80102eab:	89 06                	mov    %eax,(%esi)
80102ead:	85 c0                	test   %eax,%eax
80102eaf:	74 7d                	je     80102f2e <pipealloc+0xb6>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102eb1:	e8 c9 f2 ff ff       	call   8010217f <kalloc>
80102eb6:	89 c7                	mov    %eax,%edi
80102eb8:	85 c0                	test   %eax,%eax
80102eba:	74 72                	je     80102f2e <pipealloc+0xb6>
    goto bad;
  p->readopen = 1;
80102ebc:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102ec3:	00 00 00 
  p->writeopen = 1;
80102ec6:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102ecd:	00 00 00 
  p->nwrite = 0;
80102ed0:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102ed7:	00 00 00 
  p->nread = 0;
80102eda:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102ee1:	00 00 00 
  initlock(&p->lock, "pipe");
80102ee4:	83 ec 08             	sub    $0x8,%esp
80102ee7:	68 33 74 10 80       	push   $0x80107433
80102eec:	50                   	push   %eax
80102eed:	e8 4b 0e 00 00       	call   80103d3d <initlock>
  (*f0)->type = FD_PIPE;
80102ef2:	8b 03                	mov    (%ebx),%eax
80102ef4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102efa:	8b 03                	mov    (%ebx),%eax
80102efc:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102f00:	8b 03                	mov    (%ebx),%eax
80102f02:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102f06:	8b 03                	mov    (%ebx),%eax
80102f08:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102f0b:	8b 06                	mov    (%esi),%eax
80102f0d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102f13:	8b 06                	mov    (%esi),%eax
80102f15:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102f19:	8b 06                	mov    (%esi),%eax
80102f1b:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102f1f:	8b 06                	mov    (%esi),%eax
80102f21:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102f24:	83 c4 10             	add    $0x10,%esp
80102f27:	b8 00 00 00 00       	mov    $0x0,%eax
80102f2c:	eb 29                	jmp    80102f57 <pipealloc+0xdf>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102f2e:	8b 03                	mov    (%ebx),%eax
80102f30:	85 c0                	test   %eax,%eax
80102f32:	74 0c                	je     80102f40 <pipealloc+0xc8>
    fileclose(*f0);
80102f34:	83 ec 0c             	sub    $0xc,%esp
80102f37:	50                   	push   %eax
80102f38:	e8 cf dd ff ff       	call   80100d0c <fileclose>
80102f3d:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102f40:	8b 06                	mov    (%esi),%eax
80102f42:	85 c0                	test   %eax,%eax
80102f44:	74 19                	je     80102f5f <pipealloc+0xe7>
    fileclose(*f1);
80102f46:	83 ec 0c             	sub    $0xc,%esp
80102f49:	50                   	push   %eax
80102f4a:	e8 bd dd ff ff       	call   80100d0c <fileclose>
80102f4f:	83 c4 10             	add    $0x10,%esp
  return -1;
80102f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f57:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f5a:	5b                   	pop    %ebx
80102f5b:	5e                   	pop    %esi
80102f5c:	5f                   	pop    %edi
80102f5d:	5d                   	pop    %ebp
80102f5e:	c3                   	ret    
  return -1;
80102f5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f64:	eb f1                	jmp    80102f57 <pipealloc+0xdf>

80102f66 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102f66:	f3 0f 1e fb          	endbr32 
80102f6a:	55                   	push   %ebp
80102f6b:	89 e5                	mov    %esp,%ebp
80102f6d:	53                   	push   %ebx
80102f6e:	83 ec 10             	sub    $0x10,%esp
80102f71:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102f74:	53                   	push   %ebx
80102f75:	e8 13 0f 00 00       	call   80103e8d <acquire>
  if(writable){
80102f7a:	83 c4 10             	add    $0x10,%esp
80102f7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102f81:	74 3f                	je     80102fc2 <pipeclose+0x5c>
    p->writeopen = 0;
80102f83:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f8a:	00 00 00 
    wakeup(&p->nread);
80102f8d:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f93:	83 ec 0c             	sub    $0xc,%esp
80102f96:	50                   	push   %eax
80102f97:	e8 37 0a 00 00       	call   801039d3 <wakeup>
80102f9c:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102f9f:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102fa6:	75 09                	jne    80102fb1 <pipeclose+0x4b>
80102fa8:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102faf:	74 2f                	je     80102fe0 <pipeclose+0x7a>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102fb1:	83 ec 0c             	sub    $0xc,%esp
80102fb4:	53                   	push   %ebx
80102fb5:	e8 3c 0f 00 00       	call   80103ef6 <release>
80102fba:	83 c4 10             	add    $0x10,%esp
}
80102fbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102fc0:	c9                   	leave  
80102fc1:	c3                   	ret    
    p->readopen = 0;
80102fc2:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102fc9:	00 00 00 
    wakeup(&p->nwrite);
80102fcc:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102fd2:	83 ec 0c             	sub    $0xc,%esp
80102fd5:	50                   	push   %eax
80102fd6:	e8 f8 09 00 00       	call   801039d3 <wakeup>
80102fdb:	83 c4 10             	add    $0x10,%esp
80102fde:	eb bf                	jmp    80102f9f <pipeclose+0x39>
    release(&p->lock);
80102fe0:	83 ec 0c             	sub    $0xc,%esp
80102fe3:	53                   	push   %ebx
80102fe4:	e8 0d 0f 00 00       	call   80103ef6 <release>
    kfree((char*)p);
80102fe9:	89 1c 24             	mov    %ebx,(%esp)
80102fec:	e8 41 f0 ff ff       	call   80102032 <kfree>
80102ff1:	83 c4 10             	add    $0x10,%esp
80102ff4:	eb c7                	jmp    80102fbd <pipeclose+0x57>

80102ff6 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102ff6:	f3 0f 1e fb          	endbr32 
80102ffa:	55                   	push   %ebp
80102ffb:	89 e5                	mov    %esp,%ebp
80102ffd:	57                   	push   %edi
80102ffe:	56                   	push   %esi
80102fff:	53                   	push   %ebx
80103000:	83 ec 18             	sub    $0x18,%esp
80103003:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103006:	89 de                	mov    %ebx,%esi
80103008:	53                   	push   %ebx
80103009:	e8 7f 0e 00 00       	call   80103e8d <acquire>
  for(i = 0; i < n; i++){
8010300e:	83 c4 10             	add    $0x10,%esp
80103011:	bf 00 00 00 00       	mov    $0x0,%edi
80103016:	3b 7d 10             	cmp    0x10(%ebp),%edi
80103019:	7c 41                	jl     8010305c <pipewrite+0x66>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010301b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103021:	83 ec 0c             	sub    $0xc,%esp
80103024:	50                   	push   %eax
80103025:	e8 a9 09 00 00       	call   801039d3 <wakeup>
  release(&p->lock);
8010302a:	89 1c 24             	mov    %ebx,(%esp)
8010302d:	e8 c4 0e 00 00       	call   80103ef6 <release>
  return n;
80103032:	83 c4 10             	add    $0x10,%esp
80103035:	8b 45 10             	mov    0x10(%ebp),%eax
80103038:	eb 5c                	jmp    80103096 <pipewrite+0xa0>
      wakeup(&p->nread);
8010303a:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103040:	83 ec 0c             	sub    $0xc,%esp
80103043:	50                   	push   %eax
80103044:	e8 8a 09 00 00       	call   801039d3 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103049:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010304f:	83 c4 08             	add    $0x8,%esp
80103052:	56                   	push   %esi
80103053:	50                   	push   %eax
80103054:	e8 0d 08 00 00       	call   80103866 <sleep>
80103059:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010305c:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103062:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103068:	05 00 02 00 00       	add    $0x200,%eax
8010306d:	39 c2                	cmp    %eax,%edx
8010306f:	75 2d                	jne    8010309e <pipewrite+0xa8>
      if(p->readopen == 0 || myproc()->killed){
80103071:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103078:	74 0b                	je     80103085 <pipewrite+0x8f>
8010307a:	e8 fc 02 00 00       	call   8010337b <myproc>
8010307f:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103083:	74 b5                	je     8010303a <pipewrite+0x44>
        release(&p->lock);
80103085:	83 ec 0c             	sub    $0xc,%esp
80103088:	53                   	push   %ebx
80103089:	e8 68 0e 00 00       	call   80103ef6 <release>
        return -1;
8010308e:	83 c4 10             	add    $0x10,%esp
80103091:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103096:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103099:	5b                   	pop    %ebx
8010309a:	5e                   	pop    %esi
8010309b:	5f                   	pop    %edi
8010309c:	5d                   	pop    %ebp
8010309d:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010309e:	8d 42 01             	lea    0x1(%edx),%eax
801030a1:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
801030a7:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801030ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801030b0:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
801030b4:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801030b8:	83 c7 01             	add    $0x1,%edi
801030bb:	e9 56 ff ff ff       	jmp    80103016 <pipewrite+0x20>

801030c0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801030c0:	f3 0f 1e fb          	endbr32 
801030c4:	55                   	push   %ebp
801030c5:	89 e5                	mov    %esp,%ebp
801030c7:	57                   	push   %edi
801030c8:	56                   	push   %esi
801030c9:	53                   	push   %ebx
801030ca:	83 ec 18             	sub    $0x18,%esp
801030cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801030d0:	89 df                	mov    %ebx,%edi
801030d2:	53                   	push   %ebx
801030d3:	e8 b5 0d 00 00       	call   80103e8d <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801030d8:	83 c4 10             	add    $0x10,%esp
801030db:	eb 13                	jmp    801030f0 <piperead+0x30>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801030dd:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030e3:	83 ec 08             	sub    $0x8,%esp
801030e6:	57                   	push   %edi
801030e7:	50                   	push   %eax
801030e8:	e8 79 07 00 00       	call   80103866 <sleep>
801030ed:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801030f0:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
801030f6:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
801030fc:	75 28                	jne    80103126 <piperead+0x66>
801030fe:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103104:	85 f6                	test   %esi,%esi
80103106:	74 23                	je     8010312b <piperead+0x6b>
    if(myproc()->killed){
80103108:	e8 6e 02 00 00       	call   8010337b <myproc>
8010310d:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103111:	74 ca                	je     801030dd <piperead+0x1d>
      release(&p->lock);
80103113:	83 ec 0c             	sub    $0xc,%esp
80103116:	53                   	push   %ebx
80103117:	e8 da 0d 00 00       	call   80103ef6 <release>
      return -1;
8010311c:	83 c4 10             	add    $0x10,%esp
8010311f:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103124:	eb 50                	jmp    80103176 <piperead+0xb6>
80103126:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010312b:	3b 75 10             	cmp    0x10(%ebp),%esi
8010312e:	7d 2c                	jge    8010315c <piperead+0x9c>
    if(p->nread == p->nwrite)
80103130:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103136:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
8010313c:	74 1e                	je     8010315c <piperead+0x9c>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010313e:	8d 50 01             	lea    0x1(%eax),%edx
80103141:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103147:	25 ff 01 00 00       	and    $0x1ff,%eax
8010314c:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103151:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103154:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103157:	83 c6 01             	add    $0x1,%esi
8010315a:	eb cf                	jmp    8010312b <piperead+0x6b>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010315c:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103162:	83 ec 0c             	sub    $0xc,%esp
80103165:	50                   	push   %eax
80103166:	e8 68 08 00 00       	call   801039d3 <wakeup>
  release(&p->lock);
8010316b:	89 1c 24             	mov    %ebx,(%esp)
8010316e:	e8 83 0d 00 00       	call   80103ef6 <release>
  return i;
80103173:	83 c4 10             	add    $0x10,%esp
}
80103176:	89 f0                	mov    %esi,%eax
80103178:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010317b:	5b                   	pop    %ebx
8010317c:	5e                   	pop    %esi
8010317d:	5f                   	pop    %edi
8010317e:	5d                   	pop    %ebp
8010317f:	c3                   	ret    

80103180 <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103180:	ba 54 2d 11 80       	mov    $0x80112d54,%edx
80103185:	eb 0a                	jmp    80103191 <wakeup1+0x11>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
80103187:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010318e:	83 ea 80             	sub    $0xffffff80,%edx
80103191:	81 fa 54 4d 11 80    	cmp    $0x80114d54,%edx
80103197:	73 0d                	jae    801031a6 <wakeup1+0x26>
    if(p->state == SLEEPING && p->chan == chan)
80103199:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010319d:	75 ef                	jne    8010318e <wakeup1+0xe>
8010319f:	39 42 20             	cmp    %eax,0x20(%edx)
801031a2:	75 ea                	jne    8010318e <wakeup1+0xe>
801031a4:	eb e1                	jmp    80103187 <wakeup1+0x7>
}
801031a6:	c3                   	ret    

801031a7 <allocproc>:
{
801031a7:	55                   	push   %ebp
801031a8:	89 e5                	mov    %esp,%ebp
801031aa:	53                   	push   %ebx
801031ab:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801031ae:	68 20 2d 11 80       	push   $0x80112d20
801031b3:	e8 d5 0c 00 00       	call   80103e8d <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031b8:	83 c4 10             	add    $0x10,%esp
801031bb:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801031c0:	81 fb 54 4d 11 80    	cmp    $0x80114d54,%ebx
801031c6:	0f 83 82 00 00 00    	jae    8010324e <allocproc+0xa7>
    if(p->state == UNUSED)
801031cc:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801031d0:	74 05                	je     801031d7 <allocproc+0x30>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031d2:	83 eb 80             	sub    $0xffffff80,%ebx
801031d5:	eb e9                	jmp    801031c0 <allocproc+0x19>
  p->state = EMBRYO;
801031d7:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801031de:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801031e3:	8d 50 01             	lea    0x1(%eax),%edx
801031e6:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
801031ec:	89 43 10             	mov    %eax,0x10(%ebx)
  p->priority = 0;
801031ef:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
  release(&ptable.lock);
801031f6:	83 ec 0c             	sub    $0xc,%esp
801031f9:	68 20 2d 11 80       	push   $0x80112d20
801031fe:	e8 f3 0c 00 00       	call   80103ef6 <release>
  if((p->kstack = kalloc()) == 0){
80103203:	e8 77 ef ff ff       	call   8010217f <kalloc>
80103208:	89 43 08             	mov    %eax,0x8(%ebx)
8010320b:	83 c4 10             	add    $0x10,%esp
8010320e:	85 c0                	test   %eax,%eax
80103210:	74 53                	je     80103265 <allocproc+0xbe>
  sp -= sizeof *p->tf;
80103212:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103218:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010321b:	c7 80 b0 0f 00 00 b8 	movl   $0x801050b8,0xfb0(%eax)
80103222:	50 10 80 
  sp -= sizeof *p->context;
80103225:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010322a:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010322d:	83 ec 04             	sub    $0x4,%esp
80103230:	6a 14                	push   $0x14
80103232:	6a 00                	push   $0x0
80103234:	50                   	push   %eax
80103235:	e8 07 0d 00 00       	call   80103f41 <memset>
  p->context->eip = (uint)forkret;
8010323a:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010323d:	c7 40 10 70 32 10 80 	movl   $0x80103270,0x10(%eax)
  return p;
80103244:	83 c4 10             	add    $0x10,%esp
}
80103247:	89 d8                	mov    %ebx,%eax
80103249:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010324c:	c9                   	leave  
8010324d:	c3                   	ret    
  release(&ptable.lock);
8010324e:	83 ec 0c             	sub    $0xc,%esp
80103251:	68 20 2d 11 80       	push   $0x80112d20
80103256:	e8 9b 0c 00 00       	call   80103ef6 <release>
  return 0;
8010325b:	83 c4 10             	add    $0x10,%esp
8010325e:	bb 00 00 00 00       	mov    $0x0,%ebx
80103263:	eb e2                	jmp    80103247 <allocproc+0xa0>
    p->state = UNUSED;
80103265:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
8010326c:	89 c3                	mov    %eax,%ebx
8010326e:	eb d7                	jmp    80103247 <allocproc+0xa0>

80103270 <forkret>:
{
80103270:	f3 0f 1e fb          	endbr32 
80103274:	55                   	push   %ebp
80103275:	89 e5                	mov    %esp,%ebp
80103277:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010327a:	68 20 2d 11 80       	push   $0x80112d20
8010327f:	e8 72 0c 00 00       	call   80103ef6 <release>
  if (first) {
80103284:	83 c4 10             	add    $0x10,%esp
80103287:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
8010328e:	75 02                	jne    80103292 <forkret+0x22>
}
80103290:	c9                   	leave  
80103291:	c3                   	ret    
    first = 0;
80103292:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103299:	00 00 00 
    iinit(ROOTDEV);
8010329c:	83 ec 0c             	sub    $0xc,%esp
8010329f:	6a 01                	push   $0x1
801032a1:	e8 86 e0 ff ff       	call   8010132c <iinit>
    initlog(ROOTDEV);
801032a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801032ad:	e8 8d f5 ff ff       	call   8010283f <initlog>
801032b2:	83 c4 10             	add    $0x10,%esp
}
801032b5:	eb d9                	jmp    80103290 <forkret+0x20>

801032b7 <proc_nice>:
{
801032b7:	f3 0f 1e fb          	endbr32 
801032bb:	55                   	push   %ebp
801032bc:	89 e5                	mov    %esp,%ebp
801032be:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801032c1:	68 20 2d 11 80       	push   $0x80112d20
801032c6:	e8 c2 0b 00 00       	call   80103e8d <acquire>
  release(&ptable.lock);
801032cb:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801032d2:	e8 1f 0c 00 00       	call   80103ef6 <release>
}
801032d7:	b8 00 00 00 00       	mov    $0x0,%eax
801032dc:	c9                   	leave  
801032dd:	c3                   	ret    

801032de <pinit>:
{
801032de:	f3 0f 1e fb          	endbr32 
801032e2:	55                   	push   %ebp
801032e3:	89 e5                	mov    %esp,%ebp
801032e5:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801032e8:	68 38 74 10 80       	push   $0x80107438
801032ed:	68 20 2d 11 80       	push   $0x80112d20
801032f2:	e8 46 0a 00 00       	call   80103d3d <initlock>
}
801032f7:	83 c4 10             	add    $0x10,%esp
801032fa:	c9                   	leave  
801032fb:	c3                   	ret    

801032fc <mycpu>:
{
801032fc:	f3 0f 1e fb          	endbr32 
80103300:	55                   	push   %ebp
80103301:	89 e5                	mov    %esp,%ebp
80103303:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103306:	9c                   	pushf  
80103307:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103308:	f6 c4 02             	test   $0x2,%ah
8010330b:	75 28                	jne    80103335 <mycpu+0x39>
  apicid = lapicid();
8010330d:	e8 44 f1 ff ff       	call   80102456 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103312:	ba 00 00 00 00       	mov    $0x0,%edx
80103317:	39 15 00 2d 11 80    	cmp    %edx,0x80112d00
8010331d:	7e 30                	jle    8010334f <mycpu+0x53>
    if (cpus[i].apicid == apicid)
8010331f:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103325:	0f b6 89 80 27 11 80 	movzbl -0x7feed880(%ecx),%ecx
8010332c:	39 c1                	cmp    %eax,%ecx
8010332e:	74 12                	je     80103342 <mycpu+0x46>
  for (i = 0; i < ncpu; ++i) {
80103330:	83 c2 01             	add    $0x1,%edx
80103333:	eb e2                	jmp    80103317 <mycpu+0x1b>
    panic("mycpu called with interrupts enabled\n");
80103335:	83 ec 0c             	sub    $0xc,%esp
80103338:	68 6c 75 10 80       	push   $0x8010756c
8010333d:	e8 1a d0 ff ff       	call   8010035c <panic>
      return &cpus[i];
80103342:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103348:	05 80 27 11 80       	add    $0x80112780,%eax
}
8010334d:	c9                   	leave  
8010334e:	c3                   	ret    
  panic("unknown apicid\n");
8010334f:	83 ec 0c             	sub    $0xc,%esp
80103352:	68 3f 74 10 80       	push   $0x8010743f
80103357:	e8 00 d0 ff ff       	call   8010035c <panic>

8010335c <cpuid>:
cpuid() {
8010335c:	f3 0f 1e fb          	endbr32 
80103360:	55                   	push   %ebp
80103361:	89 e5                	mov    %esp,%ebp
80103363:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103366:	e8 91 ff ff ff       	call   801032fc <mycpu>
8010336b:	2d 80 27 11 80       	sub    $0x80112780,%eax
80103370:	c1 f8 04             	sar    $0x4,%eax
80103373:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103379:	c9                   	leave  
8010337a:	c3                   	ret    

8010337b <myproc>:
myproc(void) {
8010337b:	f3 0f 1e fb          	endbr32 
8010337f:	55                   	push   %ebp
80103380:	89 e5                	mov    %esp,%ebp
80103382:	53                   	push   %ebx
80103383:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103386:	e8 19 0a 00 00       	call   80103da4 <pushcli>
  c = mycpu();
8010338b:	e8 6c ff ff ff       	call   801032fc <mycpu>
  p = c->proc;
80103390:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103396:	e8 4a 0a 00 00       	call   80103de5 <popcli>
}
8010339b:	89 d8                	mov    %ebx,%eax
8010339d:	83 c4 04             	add    $0x4,%esp
801033a0:	5b                   	pop    %ebx
801033a1:	5d                   	pop    %ebp
801033a2:	c3                   	ret    

801033a3 <userinit>:
{
801033a3:	f3 0f 1e fb          	endbr32 
801033a7:	55                   	push   %ebp
801033a8:	89 e5                	mov    %esp,%ebp
801033aa:	53                   	push   %ebx
801033ab:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801033ae:	e8 f4 fd ff ff       	call   801031a7 <allocproc>
801033b3:	89 c3                	mov    %eax,%ebx
  initproc = p;
801033b5:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
801033ba:	e8 ce 32 00 00       	call   8010668d <setupkvm>
801033bf:	89 43 04             	mov    %eax,0x4(%ebx)
801033c2:	85 c0                	test   %eax,%eax
801033c4:	0f 84 b8 00 00 00    	je     80103482 <userinit+0xdf>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801033ca:	83 ec 04             	sub    $0x4,%esp
801033cd:	68 2c 00 00 00       	push   $0x2c
801033d2:	68 60 a4 10 80       	push   $0x8010a460
801033d7:	50                   	push   %eax
801033d8:	e8 3e 2f 00 00       	call   8010631b <inituvm>
  p->sz = PGSIZE;
801033dd:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801033e3:	8b 43 18             	mov    0x18(%ebx),%eax
801033e6:	83 c4 0c             	add    $0xc,%esp
801033e9:	6a 4c                	push   $0x4c
801033eb:	6a 00                	push   $0x0
801033ed:	50                   	push   %eax
801033ee:	e8 4e 0b 00 00       	call   80103f41 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801033f3:	8b 43 18             	mov    0x18(%ebx),%eax
801033f6:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801033fc:	8b 43 18             	mov    0x18(%ebx),%eax
801033ff:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103405:	8b 43 18             	mov    0x18(%ebx),%eax
80103408:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010340c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103410:	8b 43 18             	mov    0x18(%ebx),%eax
80103413:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103417:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010341b:	8b 43 18             	mov    0x18(%ebx),%eax
8010341e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103425:	8b 43 18             	mov    0x18(%ebx),%eax
80103428:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010342f:	8b 43 18             	mov    0x18(%ebx),%eax
80103432:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103439:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010343c:	83 c4 0c             	add    $0xc,%esp
8010343f:	6a 10                	push   $0x10
80103441:	68 68 74 10 80       	push   $0x80107468
80103446:	50                   	push   %eax
80103447:	e8 75 0c 00 00       	call   801040c1 <safestrcpy>
  p->cwd = namei("/");
8010344c:	c7 04 24 71 74 10 80 	movl   $0x80107471,(%esp)
80103453:	e8 fe e7 ff ff       	call   80101c56 <namei>
80103458:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
8010345b:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103462:	e8 26 0a 00 00       	call   80103e8d <acquire>
  p->state = RUNNABLE;
80103467:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
8010346e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103475:	e8 7c 0a 00 00       	call   80103ef6 <release>
}
8010347a:	83 c4 10             	add    $0x10,%esp
8010347d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103480:	c9                   	leave  
80103481:	c3                   	ret    
    panic("userinit: out of memory?");
80103482:	83 ec 0c             	sub    $0xc,%esp
80103485:	68 4f 74 10 80       	push   $0x8010744f
8010348a:	e8 cd ce ff ff       	call   8010035c <panic>

8010348f <growproc>:
{
8010348f:	f3 0f 1e fb          	endbr32 
80103493:	55                   	push   %ebp
80103494:	89 e5                	mov    %esp,%ebp
80103496:	56                   	push   %esi
80103497:	53                   	push   %ebx
80103498:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010349b:	e8 db fe ff ff       	call   8010337b <myproc>
801034a0:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801034a2:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801034a4:	85 f6                	test   %esi,%esi
801034a6:	7f 1c                	jg     801034c4 <growproc+0x35>
  } else if(n < 0){
801034a8:	78 37                	js     801034e1 <growproc+0x52>
  curproc->sz = sz;
801034aa:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801034ac:	83 ec 0c             	sub    $0xc,%esp
801034af:	53                   	push   %ebx
801034b0:	e8 36 2d 00 00       	call   801061eb <switchuvm>
  return 0;
801034b5:	83 c4 10             	add    $0x10,%esp
801034b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801034bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
801034c0:	5b                   	pop    %ebx
801034c1:	5e                   	pop    %esi
801034c2:	5d                   	pop    %ebp
801034c3:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034c4:	83 ec 04             	sub    $0x4,%esp
801034c7:	01 c6                	add    %eax,%esi
801034c9:	56                   	push   %esi
801034ca:	50                   	push   %eax
801034cb:	ff 73 04             	pushl  0x4(%ebx)
801034ce:	e8 2a 30 00 00       	call   801064fd <allocuvm>
801034d3:	83 c4 10             	add    $0x10,%esp
801034d6:	85 c0                	test   %eax,%eax
801034d8:	75 d0                	jne    801034aa <growproc+0x1b>
      return -1;
801034da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034df:	eb dc                	jmp    801034bd <growproc+0x2e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034e1:	83 ec 04             	sub    $0x4,%esp
801034e4:	01 c6                	add    %eax,%esi
801034e6:	56                   	push   %esi
801034e7:	50                   	push   %eax
801034e8:	ff 73 04             	pushl  0x4(%ebx)
801034eb:	e8 63 2f 00 00       	call   80106453 <deallocuvm>
801034f0:	83 c4 10             	add    $0x10,%esp
801034f3:	85 c0                	test   %eax,%eax
801034f5:	75 b3                	jne    801034aa <growproc+0x1b>
      return -1;
801034f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034fc:	eb bf                	jmp    801034bd <growproc+0x2e>

801034fe <fork>:
{
801034fe:	f3 0f 1e fb          	endbr32 
80103502:	55                   	push   %ebp
80103503:	89 e5                	mov    %esp,%ebp
80103505:	57                   	push   %edi
80103506:	56                   	push   %esi
80103507:	53                   	push   %ebx
80103508:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
8010350b:	e8 6b fe ff ff       	call   8010337b <myproc>
80103510:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103512:	e8 90 fc ff ff       	call   801031a7 <allocproc>
80103517:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010351a:	85 c0                	test   %eax,%eax
8010351c:	0f 84 e7 00 00 00    	je     80103609 <fork+0x10b>
80103522:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103524:	83 ec 08             	sub    $0x8,%esp
80103527:	ff 33                	pushl  (%ebx)
80103529:	ff 73 04             	pushl  0x4(%ebx)
8010352c:	e8 19 32 00 00       	call   8010674a <copyuvm>
80103531:	89 47 04             	mov    %eax,0x4(%edi)
80103534:	83 c4 10             	add    $0x10,%esp
80103537:	85 c0                	test   %eax,%eax
80103539:	74 2a                	je     80103565 <fork+0x67>
  np->sz = curproc->sz;
8010353b:	8b 03                	mov    (%ebx),%eax
8010353d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103540:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
80103542:	89 c8                	mov    %ecx,%eax
80103544:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103547:	8b 73 18             	mov    0x18(%ebx),%esi
8010354a:	8b 79 18             	mov    0x18(%ecx),%edi
8010354d:	b9 13 00 00 00       	mov    $0x13,%ecx
80103552:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103554:	8b 40 18             	mov    0x18(%eax),%eax
80103557:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010355e:	be 00 00 00 00       	mov    $0x0,%esi
80103563:	eb 3c                	jmp    801035a1 <fork+0xa3>
    kfree(np->kstack);
80103565:	83 ec 0c             	sub    $0xc,%esp
80103568:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010356b:	ff 73 08             	pushl  0x8(%ebx)
8010356e:	e8 bf ea ff ff       	call   80102032 <kfree>
    np->kstack = 0;
80103573:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
8010357a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103581:	83 c4 10             	add    $0x10,%esp
80103584:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103589:	eb 74                	jmp    801035ff <fork+0x101>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010358b:	83 ec 0c             	sub    $0xc,%esp
8010358e:	50                   	push   %eax
8010358f:	e8 2f d7 ff ff       	call   80100cc3 <filedup>
80103594:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103597:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
8010359b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NOFILE; i++)
8010359e:	83 c6 01             	add    $0x1,%esi
801035a1:	83 fe 0f             	cmp    $0xf,%esi
801035a4:	7f 0a                	jg     801035b0 <fork+0xb2>
    if(curproc->ofile[i])
801035a6:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801035aa:	85 c0                	test   %eax,%eax
801035ac:	75 dd                	jne    8010358b <fork+0x8d>
801035ae:	eb ee                	jmp    8010359e <fork+0xa0>
  np->cwd = idup(curproc->cwd);
801035b0:	83 ec 0c             	sub    $0xc,%esp
801035b3:	ff 73 68             	pushl  0x68(%ebx)
801035b6:	e8 e2 df ff ff       	call   8010159d <idup>
801035bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801035be:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801035c1:	83 c3 6c             	add    $0x6c,%ebx
801035c4:	8d 47 6c             	lea    0x6c(%edi),%eax
801035c7:	83 c4 0c             	add    $0xc,%esp
801035ca:	6a 10                	push   $0x10
801035cc:	53                   	push   %ebx
801035cd:	50                   	push   %eax
801035ce:	e8 ee 0a 00 00       	call   801040c1 <safestrcpy>
  pid = np->pid;
801035d3:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801035d6:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801035dd:	e8 ab 08 00 00       	call   80103e8d <acquire>
  np->state = RUNNABLE;
801035e2:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  np-> priority = 0;
801035e9:	c7 47 7c 00 00 00 00 	movl   $0x0,0x7c(%edi)
  release(&ptable.lock);
801035f0:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801035f7:	e8 fa 08 00 00       	call   80103ef6 <release>
  return pid;
801035fc:	83 c4 10             	add    $0x10,%esp
}
801035ff:	89 d8                	mov    %ebx,%eax
80103601:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103604:	5b                   	pop    %ebx
80103605:	5e                   	pop    %esi
80103606:	5f                   	pop    %edi
80103607:	5d                   	pop    %ebp
80103608:	c3                   	ret    
    return -1;
80103609:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010360e:	eb ef                	jmp    801035ff <fork+0x101>

80103610 <scheduler>:
{
80103610:	f3 0f 1e fb          	endbr32 
80103614:	55                   	push   %ebp
80103615:	89 e5                	mov    %esp,%ebp
80103617:	56                   	push   %esi
80103618:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103619:	e8 de fc ff ff       	call   801032fc <mycpu>
8010361e:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103620:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103627:	00 00 00 
8010362a:	eb 7b                	jmp    801036a7 <scheduler+0x97>
      for(p1 = ptable.proc; p1 < &ptable.proc[NPROC]; p1++)
8010362c:	83 e8 80             	sub    $0xffffff80,%eax
8010362f:	3d 54 4d 11 80       	cmp    $0x80114d54,%eax
80103634:	73 12                	jae    80103648 <scheduler+0x38>
        if(p1->state != RUNNABLE)
80103636:	83 78 0c 03          	cmpl   $0x3,0xc(%eax)
8010363a:	75 f0                	jne    8010362c <scheduler+0x1c>
        if(highP->priority > p1->priority)
8010363c:	8b 50 7c             	mov    0x7c(%eax),%edx
8010363f:	39 53 7c             	cmp    %edx,0x7c(%ebx)
80103642:	7e e8                	jle    8010362c <scheduler+0x1c>
          highP = p1;
80103644:	89 c3                	mov    %eax,%ebx
80103646:	eb e4                	jmp    8010362c <scheduler+0x1c>
      c->proc = p;
80103648:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010364e:	83 ec 0c             	sub    $0xc,%esp
80103651:	53                   	push   %ebx
80103652:	e8 94 2b 00 00       	call   801061eb <switchuvm>
      p->state = RUNNING;
80103657:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
8010365e:	83 c4 08             	add    $0x8,%esp
80103661:	ff 73 1c             	pushl  0x1c(%ebx)
80103664:	8d 46 04             	lea    0x4(%esi),%eax
80103667:	50                   	push   %eax
80103668:	e8 b1 0a 00 00       	call   8010411e <swtch>
      switchkvm();
8010366d:	e8 50 2b 00 00       	call   801061c2 <switchkvm>
      c->proc = 0;
80103672:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103679:	00 00 00 
8010367c:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010367f:	83 eb 80             	sub    $0xffffff80,%ebx
80103682:	81 fb 54 4d 11 80    	cmp    $0x80114d54,%ebx
80103688:	73 0d                	jae    80103697 <scheduler+0x87>
      if(p->state != RUNNABLE)
8010368a:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
8010368e:	75 ef                	jne    8010367f <scheduler+0x6f>
      for(p1 = ptable.proc; p1 < &ptable.proc[NPROC]; p1++)
80103690:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103695:	eb 98                	jmp    8010362f <scheduler+0x1f>
    release(&ptable.lock);
80103697:	83 ec 0c             	sub    $0xc,%esp
8010369a:	68 20 2d 11 80       	push   $0x80112d20
8010369f:	e8 52 08 00 00       	call   80103ef6 <release>
  for(;;){
801036a4:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
801036a7:	fb                   	sti    
    acquire(&ptable.lock);
801036a8:	83 ec 0c             	sub    $0xc,%esp
801036ab:	68 20 2d 11 80       	push   $0x80112d20
801036b0:	e8 d8 07 00 00       	call   80103e8d <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036b5:	83 c4 10             	add    $0x10,%esp
801036b8:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801036bd:	eb c3                	jmp    80103682 <scheduler+0x72>

801036bf <sched>:
{
801036bf:	f3 0f 1e fb          	endbr32 
801036c3:	55                   	push   %ebp
801036c4:	89 e5                	mov    %esp,%ebp
801036c6:	56                   	push   %esi
801036c7:	53                   	push   %ebx
  struct proc *p = myproc();
801036c8:	e8 ae fc ff ff       	call   8010337b <myproc>
801036cd:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801036cf:	83 ec 0c             	sub    $0xc,%esp
801036d2:	68 20 2d 11 80       	push   $0x80112d20
801036d7:	e8 6d 07 00 00       	call   80103e49 <holding>
801036dc:	83 c4 10             	add    $0x10,%esp
801036df:	85 c0                	test   %eax,%eax
801036e1:	74 4f                	je     80103732 <sched+0x73>
  if(mycpu()->ncli != 1)
801036e3:	e8 14 fc ff ff       	call   801032fc <mycpu>
801036e8:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801036ef:	75 4e                	jne    8010373f <sched+0x80>
  if(p->state == RUNNING)
801036f1:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801036f5:	74 55                	je     8010374c <sched+0x8d>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801036f7:	9c                   	pushf  
801036f8:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801036f9:	f6 c4 02             	test   $0x2,%ah
801036fc:	75 5b                	jne    80103759 <sched+0x9a>
  intena = mycpu()->intena;
801036fe:	e8 f9 fb ff ff       	call   801032fc <mycpu>
80103703:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103709:	e8 ee fb ff ff       	call   801032fc <mycpu>
8010370e:	83 ec 08             	sub    $0x8,%esp
80103711:	ff 70 04             	pushl  0x4(%eax)
80103714:	83 c3 1c             	add    $0x1c,%ebx
80103717:	53                   	push   %ebx
80103718:	e8 01 0a 00 00       	call   8010411e <swtch>
  mycpu()->intena = intena;
8010371d:	e8 da fb ff ff       	call   801032fc <mycpu>
80103722:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103728:	83 c4 10             	add    $0x10,%esp
8010372b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010372e:	5b                   	pop    %ebx
8010372f:	5e                   	pop    %esi
80103730:	5d                   	pop    %ebp
80103731:	c3                   	ret    
    panic("sched ptable.lock");
80103732:	83 ec 0c             	sub    $0xc,%esp
80103735:	68 73 74 10 80       	push   $0x80107473
8010373a:	e8 1d cc ff ff       	call   8010035c <panic>
    panic("sched locks");
8010373f:	83 ec 0c             	sub    $0xc,%esp
80103742:	68 85 74 10 80       	push   $0x80107485
80103747:	e8 10 cc ff ff       	call   8010035c <panic>
    panic("sched running");
8010374c:	83 ec 0c             	sub    $0xc,%esp
8010374f:	68 91 74 10 80       	push   $0x80107491
80103754:	e8 03 cc ff ff       	call   8010035c <panic>
    panic("sched interruptible");
80103759:	83 ec 0c             	sub    $0xc,%esp
8010375c:	68 9f 74 10 80       	push   $0x8010749f
80103761:	e8 f6 cb ff ff       	call   8010035c <panic>

80103766 <exit>:
{
80103766:	f3 0f 1e fb          	endbr32 
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	56                   	push   %esi
8010376e:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010376f:	e8 07 fc ff ff       	call   8010337b <myproc>
  if(curproc == initproc)
80103774:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
8010377a:	74 09                	je     80103785 <exit+0x1f>
8010377c:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
8010377e:	bb 00 00 00 00       	mov    $0x0,%ebx
80103783:	eb 24                	jmp    801037a9 <exit+0x43>
    panic("init exiting");
80103785:	83 ec 0c             	sub    $0xc,%esp
80103788:	68 b3 74 10 80       	push   $0x801074b3
8010378d:	e8 ca cb ff ff       	call   8010035c <panic>
      fileclose(curproc->ofile[fd]);
80103792:	83 ec 0c             	sub    $0xc,%esp
80103795:	50                   	push   %eax
80103796:	e8 71 d5 ff ff       	call   80100d0c <fileclose>
      curproc->ofile[fd] = 0;
8010379b:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801037a2:	00 
801037a3:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
801037a6:	83 c3 01             	add    $0x1,%ebx
801037a9:	83 fb 0f             	cmp    $0xf,%ebx
801037ac:	7f 0a                	jg     801037b8 <exit+0x52>
    if(curproc->ofile[fd]){
801037ae:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801037b2:	85 c0                	test   %eax,%eax
801037b4:	75 dc                	jne    80103792 <exit+0x2c>
801037b6:	eb ee                	jmp    801037a6 <exit+0x40>
  begin_op();
801037b8:	e8 cf f0 ff ff       	call   8010288c <begin_op>
  iput(curproc->cwd);
801037bd:	83 ec 0c             	sub    $0xc,%esp
801037c0:	ff 76 68             	pushl  0x68(%esi)
801037c3:	e8 18 df ff ff       	call   801016e0 <iput>
  end_op();
801037c8:	e8 3d f1 ff ff       	call   8010290a <end_op>
  curproc->cwd = 0;
801037cd:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801037d4:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801037db:	e8 ad 06 00 00       	call   80103e8d <acquire>
  wakeup1(curproc->parent);
801037e0:	8b 46 14             	mov    0x14(%esi),%eax
801037e3:	e8 98 f9 ff ff       	call   80103180 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037e8:	83 c4 10             	add    $0x10,%esp
801037eb:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801037f0:	eb 03                	jmp    801037f5 <exit+0x8f>
801037f2:	83 eb 80             	sub    $0xffffff80,%ebx
801037f5:	81 fb 54 4d 11 80    	cmp    $0x80114d54,%ebx
801037fb:	73 1a                	jae    80103817 <exit+0xb1>
    if(p->parent == curproc){
801037fd:	39 73 14             	cmp    %esi,0x14(%ebx)
80103800:	75 f0                	jne    801037f2 <exit+0x8c>
      p->parent = initproc;
80103802:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
80103807:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010380a:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010380e:	75 e2                	jne    801037f2 <exit+0x8c>
        wakeup1(initproc);
80103810:	e8 6b f9 ff ff       	call   80103180 <wakeup1>
80103815:	eb db                	jmp    801037f2 <exit+0x8c>
  curproc->state = ZOMBIE;
80103817:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
8010381e:	e8 9c fe ff ff       	call   801036bf <sched>
  panic("zombie exit");
80103823:	83 ec 0c             	sub    $0xc,%esp
80103826:	68 c0 74 10 80       	push   $0x801074c0
8010382b:	e8 2c cb ff ff       	call   8010035c <panic>

80103830 <yield>:
{
80103830:	f3 0f 1e fb          	endbr32 
80103834:	55                   	push   %ebp
80103835:	89 e5                	mov    %esp,%ebp
80103837:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010383a:	68 20 2d 11 80       	push   $0x80112d20
8010383f:	e8 49 06 00 00       	call   80103e8d <acquire>
  myproc()->state = RUNNABLE;
80103844:	e8 32 fb ff ff       	call   8010337b <myproc>
80103849:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103850:	e8 6a fe ff ff       	call   801036bf <sched>
  release(&ptable.lock);
80103855:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010385c:	e8 95 06 00 00       	call   80103ef6 <release>
}
80103861:	83 c4 10             	add    $0x10,%esp
80103864:	c9                   	leave  
80103865:	c3                   	ret    

80103866 <sleep>:
{
80103866:	f3 0f 1e fb          	endbr32 
8010386a:	55                   	push   %ebp
8010386b:	89 e5                	mov    %esp,%ebp
8010386d:	56                   	push   %esi
8010386e:	53                   	push   %ebx
8010386f:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
80103872:	e8 04 fb ff ff       	call   8010337b <myproc>
  if(p == 0)
80103877:	85 c0                	test   %eax,%eax
80103879:	74 66                	je     801038e1 <sleep+0x7b>
8010387b:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
8010387d:	85 f6                	test   %esi,%esi
8010387f:	74 6d                	je     801038ee <sleep+0x88>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103881:	81 fe 20 2d 11 80    	cmp    $0x80112d20,%esi
80103887:	74 18                	je     801038a1 <sleep+0x3b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103889:	83 ec 0c             	sub    $0xc,%esp
8010388c:	68 20 2d 11 80       	push   $0x80112d20
80103891:	e8 f7 05 00 00       	call   80103e8d <acquire>
    release(lk);
80103896:	89 34 24             	mov    %esi,(%esp)
80103899:	e8 58 06 00 00       	call   80103ef6 <release>
8010389e:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801038a1:	8b 45 08             	mov    0x8(%ebp),%eax
801038a4:	89 43 20             	mov    %eax,0x20(%ebx)
  p->state = SLEEPING;
801038a7:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
801038ae:	e8 0c fe ff ff       	call   801036bf <sched>
  p->chan = 0;
801038b3:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801038ba:	81 fe 20 2d 11 80    	cmp    $0x80112d20,%esi
801038c0:	74 18                	je     801038da <sleep+0x74>
    release(&ptable.lock);
801038c2:	83 ec 0c             	sub    $0xc,%esp
801038c5:	68 20 2d 11 80       	push   $0x80112d20
801038ca:	e8 27 06 00 00       	call   80103ef6 <release>
    acquire(lk);
801038cf:	89 34 24             	mov    %esi,(%esp)
801038d2:	e8 b6 05 00 00       	call   80103e8d <acquire>
801038d7:	83 c4 10             	add    $0x10,%esp
}
801038da:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038dd:	5b                   	pop    %ebx
801038de:	5e                   	pop    %esi
801038df:	5d                   	pop    %ebp
801038e0:	c3                   	ret    
    panic("sleep");
801038e1:	83 ec 0c             	sub    $0xc,%esp
801038e4:	68 cc 74 10 80       	push   $0x801074cc
801038e9:	e8 6e ca ff ff       	call   8010035c <panic>
    panic("sleep without lk");
801038ee:	83 ec 0c             	sub    $0xc,%esp
801038f1:	68 d2 74 10 80       	push   $0x801074d2
801038f6:	e8 61 ca ff ff       	call   8010035c <panic>

801038fb <wait>:
{
801038fb:	f3 0f 1e fb          	endbr32 
801038ff:	55                   	push   %ebp
80103900:	89 e5                	mov    %esp,%ebp
80103902:	56                   	push   %esi
80103903:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103904:	e8 72 fa ff ff       	call   8010337b <myproc>
80103909:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
8010390b:	83 ec 0c             	sub    $0xc,%esp
8010390e:	68 20 2d 11 80       	push   $0x80112d20
80103913:	e8 75 05 00 00       	call   80103e8d <acquire>
80103918:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010391b:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103920:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103925:	eb 5b                	jmp    80103982 <wait+0x87>
        pid = p->pid;
80103927:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
8010392a:	83 ec 0c             	sub    $0xc,%esp
8010392d:	ff 73 08             	pushl  0x8(%ebx)
80103930:	e8 fd e6 ff ff       	call   80102032 <kfree>
        p->kstack = 0;
80103935:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
8010393c:	83 c4 04             	add    $0x4,%esp
8010393f:	ff 73 04             	pushl  0x4(%ebx)
80103942:	e8 be 2c 00 00       	call   80106605 <freevm>
        p->pid = 0;
80103947:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010394e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103955:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103959:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103960:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103967:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010396e:	e8 83 05 00 00       	call   80103ef6 <release>
        return pid;
80103973:	83 c4 10             	add    $0x10,%esp
}
80103976:	89 f0                	mov    %esi,%eax
80103978:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010397b:	5b                   	pop    %ebx
8010397c:	5e                   	pop    %esi
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010397f:	83 eb 80             	sub    $0xffffff80,%ebx
80103982:	81 fb 54 4d 11 80    	cmp    $0x80114d54,%ebx
80103988:	73 12                	jae    8010399c <wait+0xa1>
      if(p->parent != curproc)
8010398a:	39 73 14             	cmp    %esi,0x14(%ebx)
8010398d:	75 f0                	jne    8010397f <wait+0x84>
      if(p->state == ZOMBIE){
8010398f:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103993:	74 92                	je     80103927 <wait+0x2c>
      havekids = 1;
80103995:	b8 01 00 00 00       	mov    $0x1,%eax
8010399a:	eb e3                	jmp    8010397f <wait+0x84>
    if(!havekids || curproc->killed){
8010399c:	85 c0                	test   %eax,%eax
8010399e:	74 06                	je     801039a6 <wait+0xab>
801039a0:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801039a4:	74 17                	je     801039bd <wait+0xc2>
      release(&ptable.lock);
801039a6:	83 ec 0c             	sub    $0xc,%esp
801039a9:	68 20 2d 11 80       	push   $0x80112d20
801039ae:	e8 43 05 00 00       	call   80103ef6 <release>
      return -1;
801039b3:	83 c4 10             	add    $0x10,%esp
801039b6:	be ff ff ff ff       	mov    $0xffffffff,%esi
801039bb:	eb b9                	jmp    80103976 <wait+0x7b>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801039bd:	83 ec 08             	sub    $0x8,%esp
801039c0:	68 20 2d 11 80       	push   $0x80112d20
801039c5:	56                   	push   %esi
801039c6:	e8 9b fe ff ff       	call   80103866 <sleep>
    havekids = 0;
801039cb:	83 c4 10             	add    $0x10,%esp
801039ce:	e9 48 ff ff ff       	jmp    8010391b <wait+0x20>

801039d3 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801039d3:	f3 0f 1e fb          	endbr32 
801039d7:	55                   	push   %ebp
801039d8:	89 e5                	mov    %esp,%ebp
801039da:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801039dd:	68 20 2d 11 80       	push   $0x80112d20
801039e2:	e8 a6 04 00 00       	call   80103e8d <acquire>
  wakeup1(chan);
801039e7:	8b 45 08             	mov    0x8(%ebp),%eax
801039ea:	e8 91 f7 ff ff       	call   80103180 <wakeup1>
  release(&ptable.lock);
801039ef:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801039f6:	e8 fb 04 00 00       	call   80103ef6 <release>
}
801039fb:	83 c4 10             	add    $0x10,%esp
801039fe:	c9                   	leave  
801039ff:	c3                   	ret    

80103a00 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103a00:	f3 0f 1e fb          	endbr32 
80103a04:	55                   	push   %ebp
80103a05:	89 e5                	mov    %esp,%ebp
80103a07:	53                   	push   %ebx
80103a08:	83 ec 10             	sub    $0x10,%esp
80103a0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103a0e:	68 20 2d 11 80       	push   $0x80112d20
80103a13:	e8 75 04 00 00       	call   80103e8d <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a18:	83 c4 10             	add    $0x10,%esp
80103a1b:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103a20:	3d 54 4d 11 80       	cmp    $0x80114d54,%eax
80103a25:	73 3a                	jae    80103a61 <kill+0x61>
    if(p->pid == pid){
80103a27:	39 58 10             	cmp    %ebx,0x10(%eax)
80103a2a:	74 05                	je     80103a31 <kill+0x31>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a2c:	83 e8 80             	sub    $0xffffff80,%eax
80103a2f:	eb ef                	jmp    80103a20 <kill+0x20>
      p->killed = 1;
80103a31:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103a38:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103a3c:	74 1a                	je     80103a58 <kill+0x58>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103a3e:	83 ec 0c             	sub    $0xc,%esp
80103a41:	68 20 2d 11 80       	push   $0x80112d20
80103a46:	e8 ab 04 00 00       	call   80103ef6 <release>
      return 0;
80103a4b:	83 c4 10             	add    $0x10,%esp
80103a4e:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103a53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a56:	c9                   	leave  
80103a57:	c3                   	ret    
        p->state = RUNNABLE;
80103a58:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103a5f:	eb dd                	jmp    80103a3e <kill+0x3e>
  release(&ptable.lock);
80103a61:	83 ec 0c             	sub    $0xc,%esp
80103a64:	68 20 2d 11 80       	push   $0x80112d20
80103a69:	e8 88 04 00 00       	call   80103ef6 <release>
  return -1;
80103a6e:	83 c4 10             	add    $0x10,%esp
80103a71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a76:	eb db                	jmp    80103a53 <kill+0x53>

80103a78 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103a78:	f3 0f 1e fb          	endbr32 
80103a7c:	55                   	push   %ebp
80103a7d:	89 e5                	mov    %esp,%ebp
80103a7f:	56                   	push   %esi
80103a80:	53                   	push   %ebx
80103a81:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a84:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103a89:	eb 33                	jmp    80103abe <procdump+0x46>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103a8b:	b8 e3 74 10 80       	mov    $0x801074e3,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103a90:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103a93:	52                   	push   %edx
80103a94:	50                   	push   %eax
80103a95:	ff 73 10             	pushl  0x10(%ebx)
80103a98:	68 e7 74 10 80       	push   $0x801074e7
80103a9d:	e8 87 cb ff ff       	call   80100629 <cprintf>
    if(p->state == SLEEPING){
80103aa2:	83 c4 10             	add    $0x10,%esp
80103aa5:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103aa9:	74 39                	je     80103ae4 <procdump+0x6c>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103aab:	83 ec 0c             	sub    $0xc,%esp
80103aae:	68 e7 78 10 80       	push   $0x801078e7
80103ab3:	e8 71 cb ff ff       	call   80100629 <cprintf>
80103ab8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103abb:	83 eb 80             	sub    $0xffffff80,%ebx
80103abe:	81 fb 54 4d 11 80    	cmp    $0x80114d54,%ebx
80103ac4:	73 61                	jae    80103b27 <procdump+0xaf>
    if(p->state == UNUSED)
80103ac6:	8b 43 0c             	mov    0xc(%ebx),%eax
80103ac9:	85 c0                	test   %eax,%eax
80103acb:	74 ee                	je     80103abb <procdump+0x43>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103acd:	83 f8 05             	cmp    $0x5,%eax
80103ad0:	77 b9                	ja     80103a8b <procdump+0x13>
80103ad2:	8b 04 85 b4 75 10 80 	mov    -0x7fef8a4c(,%eax,4),%eax
80103ad9:	85 c0                	test   %eax,%eax
80103adb:	75 b3                	jne    80103a90 <procdump+0x18>
      state = "???";
80103add:	b8 e3 74 10 80       	mov    $0x801074e3,%eax
80103ae2:	eb ac                	jmp    80103a90 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103ae4:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103ae7:	8b 40 0c             	mov    0xc(%eax),%eax
80103aea:	83 c0 08             	add    $0x8,%eax
80103aed:	83 ec 08             	sub    $0x8,%esp
80103af0:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103af3:	52                   	push   %edx
80103af4:	50                   	push   %eax
80103af5:	e8 62 02 00 00       	call   80103d5c <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103afa:	83 c4 10             	add    $0x10,%esp
80103afd:	be 00 00 00 00       	mov    $0x0,%esi
80103b02:	eb 14                	jmp    80103b18 <procdump+0xa0>
        cprintf(" %p", pc[i]);
80103b04:	83 ec 08             	sub    $0x8,%esp
80103b07:	50                   	push   %eax
80103b08:	68 81 6e 10 80       	push   $0x80106e81
80103b0d:	e8 17 cb ff ff       	call   80100629 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103b12:	83 c6 01             	add    $0x1,%esi
80103b15:	83 c4 10             	add    $0x10,%esp
80103b18:	83 fe 09             	cmp    $0x9,%esi
80103b1b:	7f 8e                	jg     80103aab <procdump+0x33>
80103b1d:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103b21:	85 c0                	test   %eax,%eax
80103b23:	75 df                	jne    80103b04 <procdump+0x8c>
80103b25:	eb 84                	jmp    80103aab <procdump+0x33>
  }
}
80103b27:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b2a:	5b                   	pop    %ebx
80103b2b:	5e                   	pop    %esi
80103b2c:	5d                   	pop    %ebp
80103b2d:	c3                   	ret    

80103b2e <nice>:

int nice(int pid, int prio)
{
80103b2e:	f3 0f 1e fb          	endbr32 
80103b32:	55                   	push   %ebp
80103b33:	89 e5                	mov    %esp,%ebp
80103b35:	53                   	push   %ebx
80103b36:	83 ec 10             	sub    $0x10,%esp
80103b39:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;
  //Lock
  acquire(&ptable.lock);
80103b3c:	68 20 2d 11 80       	push   $0x80112d20
80103b41:	e8 47 03 00 00       	call   80103e8d <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103b46:	83 c4 10             	add    $0x10,%esp
80103b49:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103b4e:	3d 54 4d 11 80       	cmp    $0x80114d54,%eax
80103b53:	73 10                	jae    80103b65 <nice+0x37>
  {
      if(p->pid == pid)
80103b55:	39 58 10             	cmp    %ebx,0x10(%eax)
80103b58:	74 05                	je     80103b5f <nice+0x31>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103b5a:	83 e8 80             	sub    $0xffffff80,%eax
80103b5d:	eb ef                	jmp    80103b4e <nice+0x20>
      {
        //Set priority to prio
        p->priority = prio;
80103b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b62:	89 50 7c             	mov    %edx,0x7c(%eax)
        break;
      }
        
  }
  //Unlock
  release(&ptable.lock);
80103b65:	83 ec 0c             	sub    $0xc,%esp
80103b68:	68 20 2d 11 80       	push   $0x80112d20
80103b6d:	e8 84 03 00 00       	call   80103ef6 <release>
  return pid;
}
80103b72:	89 d8                	mov    %ebx,%eax
80103b74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b77:	c9                   	leave  
80103b78:	c3                   	ret    

80103b79 <cps>:

int cps()
{
80103b79:	f3 0f 1e fb          	endbr32 
80103b7d:	55                   	push   %ebp
80103b7e:	89 e5                	mov    %esp,%ebp
80103b80:	53                   	push   %ebx
80103b81:	83 ec 10             	sub    $0x10,%esp
  asm volatile("sti");
80103b84:	fb                   	sti    
struct proc *p;
//Enables interrupts on this processor.
sti();

//Loop over process table looking for process with pid.
acquire(&ptable.lock);
80103b85:	68 20 2d 11 80       	push   $0x80112d20
80103b8a:	e8 fe 02 00 00       	call   80103e8d <acquire>
cprintf("name \t pid \t state \t priority \n");
80103b8f:	c7 04 24 94 75 10 80 	movl   $0x80107594,(%esp)
80103b96:	e8 8e ca ff ff       	call   80100629 <cprintf>
for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b9b:	83 c4 10             	add    $0x10,%esp
80103b9e:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103ba3:	eb 1a                	jmp    80103bbf <cps+0x46>
  if(p->state == SLEEPING)
	  cprintf("%s \t %d \t SLEEPING \t %d \n ", p->name,p->pid,p->priority);
80103ba5:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103ba8:	ff 73 7c             	pushl  0x7c(%ebx)
80103bab:	ff 73 10             	pushl  0x10(%ebx)
80103bae:	50                   	push   %eax
80103baf:	68 f0 74 10 80       	push   $0x801074f0
80103bb4:	e8 70 ca ff ff       	call   80100629 <cprintf>
80103bb9:	83 c4 10             	add    $0x10,%esp
for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103bbc:	83 eb 80             	sub    $0xffffff80,%ebx
80103bbf:	81 fb 54 4d 11 80    	cmp    $0x80114d54,%ebx
80103bc5:	73 44                	jae    80103c0b <cps+0x92>
  if(p->state == SLEEPING)
80103bc7:	8b 43 0c             	mov    0xc(%ebx),%eax
80103bca:	83 f8 02             	cmp    $0x2,%eax
80103bcd:	74 d6                	je     80103ba5 <cps+0x2c>
	else if(p->state == RUNNING)
80103bcf:	83 f8 04             	cmp    $0x4,%eax
80103bd2:	74 1e                	je     80103bf2 <cps+0x79>
 	  cprintf("%s \t %d \t RUNNING \t %d \n ", p->name,p->pid,p->priority);
	else if(p->state == RUNNABLE)
80103bd4:	83 f8 03             	cmp    $0x3,%eax
80103bd7:	75 e3                	jne    80103bbc <cps+0x43>
 	  cprintf("%s \t %d \t RUNNABLE \t %d \n ", p->name,p->pid,p->priority);
80103bd9:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103bdc:	ff 73 7c             	pushl  0x7c(%ebx)
80103bdf:	ff 73 10             	pushl  0x10(%ebx)
80103be2:	50                   	push   %eax
80103be3:	68 25 75 10 80       	push   $0x80107525
80103be8:	e8 3c ca ff ff       	call   80100629 <cprintf>
80103bed:	83 c4 10             	add    $0x10,%esp
80103bf0:	eb ca                	jmp    80103bbc <cps+0x43>
 	  cprintf("%s \t %d \t RUNNING \t %d \n ", p->name,p->pid,p->priority);
80103bf2:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103bf5:	ff 73 7c             	pushl  0x7c(%ebx)
80103bf8:	ff 73 10             	pushl  0x10(%ebx)
80103bfb:	50                   	push   %eax
80103bfc:	68 0b 75 10 80       	push   $0x8010750b
80103c01:	e8 23 ca ff ff       	call   80100629 <cprintf>
80103c06:	83 c4 10             	add    $0x10,%esp
80103c09:	eb b1                	jmp    80103bbc <cps+0x43>
}
release(&ptable.lock);
80103c0b:	83 ec 0c             	sub    $0xc,%esp
80103c0e:	68 20 2d 11 80       	push   $0x80112d20
80103c13:	e8 de 02 00 00       	call   80103ef6 <release>
return 2;
80103c18:	b8 02 00 00 00       	mov    $0x2,%eax
80103c1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c20:	c9                   	leave  
80103c21:	c3                   	ret    

80103c22 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103c22:	f3 0f 1e fb          	endbr32 
80103c26:	55                   	push   %ebp
80103c27:	89 e5                	mov    %esp,%ebp
80103c29:	53                   	push   %ebx
80103c2a:	83 ec 0c             	sub    $0xc,%esp
80103c2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103c30:	68 cc 75 10 80       	push   $0x801075cc
80103c35:	8d 43 04             	lea    0x4(%ebx),%eax
80103c38:	50                   	push   %eax
80103c39:	e8 ff 00 00 00       	call   80103d3d <initlock>
  lk->name = name;
80103c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c41:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103c44:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c4a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103c51:	83 c4 10             	add    $0x10,%esp
80103c54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c57:	c9                   	leave  
80103c58:	c3                   	ret    

80103c59 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103c59:	f3 0f 1e fb          	endbr32 
80103c5d:	55                   	push   %ebp
80103c5e:	89 e5                	mov    %esp,%ebp
80103c60:	56                   	push   %esi
80103c61:	53                   	push   %ebx
80103c62:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c65:	8d 73 04             	lea    0x4(%ebx),%esi
80103c68:	83 ec 0c             	sub    $0xc,%esp
80103c6b:	56                   	push   %esi
80103c6c:	e8 1c 02 00 00       	call   80103e8d <acquire>
  while (lk->locked) {
80103c71:	83 c4 10             	add    $0x10,%esp
80103c74:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c77:	74 0f                	je     80103c88 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80103c79:	83 ec 08             	sub    $0x8,%esp
80103c7c:	56                   	push   %esi
80103c7d:	53                   	push   %ebx
80103c7e:	e8 e3 fb ff ff       	call   80103866 <sleep>
80103c83:	83 c4 10             	add    $0x10,%esp
80103c86:	eb ec                	jmp    80103c74 <acquiresleep+0x1b>
  }
  lk->locked = 1;
80103c88:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103c8e:	e8 e8 f6 ff ff       	call   8010337b <myproc>
80103c93:	8b 40 10             	mov    0x10(%eax),%eax
80103c96:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103c99:	83 ec 0c             	sub    $0xc,%esp
80103c9c:	56                   	push   %esi
80103c9d:	e8 54 02 00 00       	call   80103ef6 <release>
}
80103ca2:	83 c4 10             	add    $0x10,%esp
80103ca5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ca8:	5b                   	pop    %ebx
80103ca9:	5e                   	pop    %esi
80103caa:	5d                   	pop    %ebp
80103cab:	c3                   	ret    

80103cac <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103cac:	f3 0f 1e fb          	endbr32 
80103cb0:	55                   	push   %ebp
80103cb1:	89 e5                	mov    %esp,%ebp
80103cb3:	56                   	push   %esi
80103cb4:	53                   	push   %ebx
80103cb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103cb8:	8d 73 04             	lea    0x4(%ebx),%esi
80103cbb:	83 ec 0c             	sub    $0xc,%esp
80103cbe:	56                   	push   %esi
80103cbf:	e8 c9 01 00 00       	call   80103e8d <acquire>
  lk->locked = 0;
80103cc4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103cca:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103cd1:	89 1c 24             	mov    %ebx,(%esp)
80103cd4:	e8 fa fc ff ff       	call   801039d3 <wakeup>
  release(&lk->lk);
80103cd9:	89 34 24             	mov    %esi,(%esp)
80103cdc:	e8 15 02 00 00       	call   80103ef6 <release>
}
80103ce1:	83 c4 10             	add    $0x10,%esp
80103ce4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ce7:	5b                   	pop    %ebx
80103ce8:	5e                   	pop    %esi
80103ce9:	5d                   	pop    %ebp
80103cea:	c3                   	ret    

80103ceb <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103ceb:	f3 0f 1e fb          	endbr32 
80103cef:	55                   	push   %ebp
80103cf0:	89 e5                	mov    %esp,%ebp
80103cf2:	56                   	push   %esi
80103cf3:	53                   	push   %ebx
80103cf4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103cf7:	8d 73 04             	lea    0x4(%ebx),%esi
80103cfa:	83 ec 0c             	sub    $0xc,%esp
80103cfd:	56                   	push   %esi
80103cfe:	e8 8a 01 00 00       	call   80103e8d <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103d03:	83 c4 10             	add    $0x10,%esp
80103d06:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d09:	75 17                	jne    80103d22 <holdingsleep+0x37>
80103d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103d10:	83 ec 0c             	sub    $0xc,%esp
80103d13:	56                   	push   %esi
80103d14:	e8 dd 01 00 00       	call   80103ef6 <release>
  return r;
}
80103d19:	89 d8                	mov    %ebx,%eax
80103d1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103d1e:	5b                   	pop    %ebx
80103d1f:	5e                   	pop    %esi
80103d20:	5d                   	pop    %ebp
80103d21:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103d22:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103d25:	e8 51 f6 ff ff       	call   8010337b <myproc>
80103d2a:	3b 58 10             	cmp    0x10(%eax),%ebx
80103d2d:	74 07                	je     80103d36 <holdingsleep+0x4b>
80103d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d34:	eb da                	jmp    80103d10 <holdingsleep+0x25>
80103d36:	bb 01 00 00 00       	mov    $0x1,%ebx
80103d3b:	eb d3                	jmp    80103d10 <holdingsleep+0x25>

80103d3d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103d3d:	f3 0f 1e fb          	endbr32 
80103d41:	55                   	push   %ebp
80103d42:	89 e5                	mov    %esp,%ebp
80103d44:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103d47:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d4a:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103d4d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103d53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103d5a:	5d                   	pop    %ebp
80103d5b:	c3                   	ret    

80103d5c <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103d5c:	f3 0f 1e fb          	endbr32 
80103d60:	55                   	push   %ebp
80103d61:	89 e5                	mov    %esp,%ebp
80103d63:	53                   	push   %ebx
80103d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103d67:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6a:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103d6d:	b8 00 00 00 00       	mov    $0x0,%eax
80103d72:	83 f8 09             	cmp    $0x9,%eax
80103d75:	7f 25                	jg     80103d9c <getcallerpcs+0x40>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103d77:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103d7d:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103d83:	77 17                	ja     80103d9c <getcallerpcs+0x40>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103d85:	8b 5a 04             	mov    0x4(%edx),%ebx
80103d88:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103d8b:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103d8d:	83 c0 01             	add    $0x1,%eax
80103d90:	eb e0                	jmp    80103d72 <getcallerpcs+0x16>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103d92:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103d99:	83 c0 01             	add    $0x1,%eax
80103d9c:	83 f8 09             	cmp    $0x9,%eax
80103d9f:	7e f1                	jle    80103d92 <getcallerpcs+0x36>
}
80103da1:	5b                   	pop    %ebx
80103da2:	5d                   	pop    %ebp
80103da3:	c3                   	ret    

80103da4 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103da4:	f3 0f 1e fb          	endbr32 
80103da8:	55                   	push   %ebp
80103da9:	89 e5                	mov    %esp,%ebp
80103dab:	53                   	push   %ebx
80103dac:	83 ec 04             	sub    $0x4,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103daf:	9c                   	pushf  
80103db0:	5b                   	pop    %ebx
  asm volatile("cli");
80103db1:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103db2:	e8 45 f5 ff ff       	call   801032fc <mycpu>
80103db7:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103dbe:	74 12                	je     80103dd2 <pushcli+0x2e>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103dc0:	e8 37 f5 ff ff       	call   801032fc <mycpu>
80103dc5:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103dcc:	83 c4 04             	add    $0x4,%esp
80103dcf:	5b                   	pop    %ebx
80103dd0:	5d                   	pop    %ebp
80103dd1:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103dd2:	e8 25 f5 ff ff       	call   801032fc <mycpu>
80103dd7:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103ddd:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103de3:	eb db                	jmp    80103dc0 <pushcli+0x1c>

80103de5 <popcli>:

void
popcli(void)
{
80103de5:	f3 0f 1e fb          	endbr32 
80103de9:	55                   	push   %ebp
80103dea:	89 e5                	mov    %esp,%ebp
80103dec:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103def:	9c                   	pushf  
80103df0:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103df1:	f6 c4 02             	test   $0x2,%ah
80103df4:	75 28                	jne    80103e1e <popcli+0x39>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103df6:	e8 01 f5 ff ff       	call   801032fc <mycpu>
80103dfb:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103e01:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103e04:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103e0a:	85 d2                	test   %edx,%edx
80103e0c:	78 1d                	js     80103e2b <popcli+0x46>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103e0e:	e8 e9 f4 ff ff       	call   801032fc <mycpu>
80103e13:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103e1a:	74 1c                	je     80103e38 <popcli+0x53>
    sti();
}
80103e1c:	c9                   	leave  
80103e1d:	c3                   	ret    
    panic("popcli - interruptible");
80103e1e:	83 ec 0c             	sub    $0xc,%esp
80103e21:	68 d7 75 10 80       	push   $0x801075d7
80103e26:	e8 31 c5 ff ff       	call   8010035c <panic>
    panic("popcli");
80103e2b:	83 ec 0c             	sub    $0xc,%esp
80103e2e:	68 ee 75 10 80       	push   $0x801075ee
80103e33:	e8 24 c5 ff ff       	call   8010035c <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103e38:	e8 bf f4 ff ff       	call   801032fc <mycpu>
80103e3d:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103e44:	74 d6                	je     80103e1c <popcli+0x37>
  asm volatile("sti");
80103e46:	fb                   	sti    
}
80103e47:	eb d3                	jmp    80103e1c <popcli+0x37>

80103e49 <holding>:
{
80103e49:	f3 0f 1e fb          	endbr32 
80103e4d:	55                   	push   %ebp
80103e4e:	89 e5                	mov    %esp,%ebp
80103e50:	53                   	push   %ebx
80103e51:	83 ec 04             	sub    $0x4,%esp
80103e54:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103e57:	e8 48 ff ff ff       	call   80103da4 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103e5c:	83 3b 00             	cmpl   $0x0,(%ebx)
80103e5f:	75 12                	jne    80103e73 <holding+0x2a>
80103e61:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103e66:	e8 7a ff ff ff       	call   80103de5 <popcli>
}
80103e6b:	89 d8                	mov    %ebx,%eax
80103e6d:	83 c4 04             	add    $0x4,%esp
80103e70:	5b                   	pop    %ebx
80103e71:	5d                   	pop    %ebp
80103e72:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103e73:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103e76:	e8 81 f4 ff ff       	call   801032fc <mycpu>
80103e7b:	39 c3                	cmp    %eax,%ebx
80103e7d:	74 07                	je     80103e86 <holding+0x3d>
80103e7f:	bb 00 00 00 00       	mov    $0x0,%ebx
80103e84:	eb e0                	jmp    80103e66 <holding+0x1d>
80103e86:	bb 01 00 00 00       	mov    $0x1,%ebx
80103e8b:	eb d9                	jmp    80103e66 <holding+0x1d>

80103e8d <acquire>:
{
80103e8d:	f3 0f 1e fb          	endbr32 
80103e91:	55                   	push   %ebp
80103e92:	89 e5                	mov    %esp,%ebp
80103e94:	53                   	push   %ebx
80103e95:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103e98:	e8 07 ff ff ff       	call   80103da4 <pushcli>
  if(holding(lk))
80103e9d:	83 ec 0c             	sub    $0xc,%esp
80103ea0:	ff 75 08             	pushl  0x8(%ebp)
80103ea3:	e8 a1 ff ff ff       	call   80103e49 <holding>
80103ea8:	83 c4 10             	add    $0x10,%esp
80103eab:	85 c0                	test   %eax,%eax
80103ead:	75 3a                	jne    80103ee9 <acquire+0x5c>
  while(xchg(&lk->locked, 1) != 0)
80103eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103eb2:	b8 01 00 00 00       	mov    $0x1,%eax
80103eb7:	f0 87 02             	lock xchg %eax,(%edx)
80103eba:	85 c0                	test   %eax,%eax
80103ebc:	75 f1                	jne    80103eaf <acquire+0x22>
  __sync_synchronize();
80103ebe:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103ec3:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103ec6:	e8 31 f4 ff ff       	call   801032fc <mycpu>
80103ecb:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103ece:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed1:	83 c0 0c             	add    $0xc,%eax
80103ed4:	83 ec 08             	sub    $0x8,%esp
80103ed7:	50                   	push   %eax
80103ed8:	8d 45 08             	lea    0x8(%ebp),%eax
80103edb:	50                   	push   %eax
80103edc:	e8 7b fe ff ff       	call   80103d5c <getcallerpcs>
}
80103ee1:	83 c4 10             	add    $0x10,%esp
80103ee4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ee7:	c9                   	leave  
80103ee8:	c3                   	ret    
    panic("acquire");
80103ee9:	83 ec 0c             	sub    $0xc,%esp
80103eec:	68 f5 75 10 80       	push   $0x801075f5
80103ef1:	e8 66 c4 ff ff       	call   8010035c <panic>

80103ef6 <release>:
{
80103ef6:	f3 0f 1e fb          	endbr32 
80103efa:	55                   	push   %ebp
80103efb:	89 e5                	mov    %esp,%ebp
80103efd:	53                   	push   %ebx
80103efe:	83 ec 10             	sub    $0x10,%esp
80103f01:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103f04:	53                   	push   %ebx
80103f05:	e8 3f ff ff ff       	call   80103e49 <holding>
80103f0a:	83 c4 10             	add    $0x10,%esp
80103f0d:	85 c0                	test   %eax,%eax
80103f0f:	74 23                	je     80103f34 <release+0x3e>
  lk->pcs[0] = 0;
80103f11:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103f18:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103f1f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103f24:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103f2a:	e8 b6 fe ff ff       	call   80103de5 <popcli>
}
80103f2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f32:	c9                   	leave  
80103f33:	c3                   	ret    
    panic("release");
80103f34:	83 ec 0c             	sub    $0xc,%esp
80103f37:	68 fd 75 10 80       	push   $0x801075fd
80103f3c:	e8 1b c4 ff ff       	call   8010035c <panic>

80103f41 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103f41:	f3 0f 1e fb          	endbr32 
80103f45:	55                   	push   %ebp
80103f46:	89 e5                	mov    %esp,%ebp
80103f48:	57                   	push   %edi
80103f49:	53                   	push   %ebx
80103f4a:	8b 55 08             	mov    0x8(%ebp),%edx
80103f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f50:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103f53:	f6 c2 03             	test   $0x3,%dl
80103f56:	75 25                	jne    80103f7d <memset+0x3c>
80103f58:	f6 c1 03             	test   $0x3,%cl
80103f5b:	75 20                	jne    80103f7d <memset+0x3c>
    c &= 0xFF;
80103f5d:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103f60:	c1 e9 02             	shr    $0x2,%ecx
80103f63:	c1 e0 18             	shl    $0x18,%eax
80103f66:	89 fb                	mov    %edi,%ebx
80103f68:	c1 e3 10             	shl    $0x10,%ebx
80103f6b:	09 d8                	or     %ebx,%eax
80103f6d:	89 fb                	mov    %edi,%ebx
80103f6f:	c1 e3 08             	shl    $0x8,%ebx
80103f72:	09 d8                	or     %ebx,%eax
80103f74:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103f76:	89 d7                	mov    %edx,%edi
80103f78:	fc                   	cld    
80103f79:	f3 ab                	rep stos %eax,%es:(%edi)
}
80103f7b:	eb 05                	jmp    80103f82 <memset+0x41>
  asm volatile("cld; rep stosb" :
80103f7d:	89 d7                	mov    %edx,%edi
80103f7f:	fc                   	cld    
80103f80:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103f82:	89 d0                	mov    %edx,%eax
80103f84:	5b                   	pop    %ebx
80103f85:	5f                   	pop    %edi
80103f86:	5d                   	pop    %ebp
80103f87:	c3                   	ret    

80103f88 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103f88:	f3 0f 1e fb          	endbr32 
80103f8c:	55                   	push   %ebp
80103f8d:	89 e5                	mov    %esp,%ebp
80103f8f:	56                   	push   %esi
80103f90:	53                   	push   %ebx
80103f91:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f94:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f97:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f9a:	8d 70 ff             	lea    -0x1(%eax),%esi
80103f9d:	85 c0                	test   %eax,%eax
80103f9f:	74 1c                	je     80103fbd <memcmp+0x35>
    if(*s1 != *s2)
80103fa1:	0f b6 01             	movzbl (%ecx),%eax
80103fa4:	0f b6 1a             	movzbl (%edx),%ebx
80103fa7:	38 d8                	cmp    %bl,%al
80103fa9:	75 0a                	jne    80103fb5 <memcmp+0x2d>
      return *s1 - *s2;
    s1++, s2++;
80103fab:	83 c1 01             	add    $0x1,%ecx
80103fae:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103fb1:	89 f0                	mov    %esi,%eax
80103fb3:	eb e5                	jmp    80103f9a <memcmp+0x12>
      return *s1 - *s2;
80103fb5:	0f b6 c0             	movzbl %al,%eax
80103fb8:	0f b6 db             	movzbl %bl,%ebx
80103fbb:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103fbd:	5b                   	pop    %ebx
80103fbe:	5e                   	pop    %esi
80103fbf:	5d                   	pop    %ebp
80103fc0:	c3                   	ret    

80103fc1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103fc1:	f3 0f 1e fb          	endbr32 
80103fc5:	55                   	push   %ebp
80103fc6:	89 e5                	mov    %esp,%ebp
80103fc8:	56                   	push   %esi
80103fc9:	53                   	push   %ebx
80103fca:	8b 75 08             	mov    0x8(%ebp),%esi
80103fcd:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fd0:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103fd3:	39 f2                	cmp    %esi,%edx
80103fd5:	73 3a                	jae    80104011 <memmove+0x50>
80103fd7:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103fda:	39 f1                	cmp    %esi,%ecx
80103fdc:	76 37                	jbe    80104015 <memmove+0x54>
    s += n;
    d += n;
80103fde:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80103fe1:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103fe4:	85 c0                	test   %eax,%eax
80103fe6:	74 23                	je     8010400b <memmove+0x4a>
      *--d = *--s;
80103fe8:	83 e9 01             	sub    $0x1,%ecx
80103feb:	83 ea 01             	sub    $0x1,%edx
80103fee:	0f b6 01             	movzbl (%ecx),%eax
80103ff1:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80103ff3:	89 d8                	mov    %ebx,%eax
80103ff5:	eb ea                	jmp    80103fe1 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103ff7:	0f b6 02             	movzbl (%edx),%eax
80103ffa:	88 01                	mov    %al,(%ecx)
80103ffc:	8d 49 01             	lea    0x1(%ecx),%ecx
80103fff:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80104002:	89 d8                	mov    %ebx,%eax
80104004:	8d 58 ff             	lea    -0x1(%eax),%ebx
80104007:	85 c0                	test   %eax,%eax
80104009:	75 ec                	jne    80103ff7 <memmove+0x36>

  return dst;
}
8010400b:	89 f0                	mov    %esi,%eax
8010400d:	5b                   	pop    %ebx
8010400e:	5e                   	pop    %esi
8010400f:	5d                   	pop    %ebp
80104010:	c3                   	ret    
80104011:	89 f1                	mov    %esi,%ecx
80104013:	eb ef                	jmp    80104004 <memmove+0x43>
80104015:	89 f1                	mov    %esi,%ecx
80104017:	eb eb                	jmp    80104004 <memmove+0x43>

80104019 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104019:	f3 0f 1e fb          	endbr32 
8010401d:	55                   	push   %ebp
8010401e:	89 e5                	mov    %esp,%ebp
80104020:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80104023:	ff 75 10             	pushl  0x10(%ebp)
80104026:	ff 75 0c             	pushl  0xc(%ebp)
80104029:	ff 75 08             	pushl  0x8(%ebp)
8010402c:	e8 90 ff ff ff       	call   80103fc1 <memmove>
}
80104031:	c9                   	leave  
80104032:	c3                   	ret    

80104033 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104033:	f3 0f 1e fb          	endbr32 
80104037:	55                   	push   %ebp
80104038:	89 e5                	mov    %esp,%ebp
8010403a:	53                   	push   %ebx
8010403b:	8b 55 08             	mov    0x8(%ebp),%edx
8010403e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104041:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80104044:	eb 09                	jmp    8010404f <strncmp+0x1c>
    n--, p++, q++;
80104046:	83 e8 01             	sub    $0x1,%eax
80104049:	83 c2 01             	add    $0x1,%edx
8010404c:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
8010404f:	85 c0                	test   %eax,%eax
80104051:	74 0b                	je     8010405e <strncmp+0x2b>
80104053:	0f b6 1a             	movzbl (%edx),%ebx
80104056:	84 db                	test   %bl,%bl
80104058:	74 04                	je     8010405e <strncmp+0x2b>
8010405a:	3a 19                	cmp    (%ecx),%bl
8010405c:	74 e8                	je     80104046 <strncmp+0x13>
  if(n == 0)
8010405e:	85 c0                	test   %eax,%eax
80104060:	74 0b                	je     8010406d <strncmp+0x3a>
    return 0;
  return (uchar)*p - (uchar)*q;
80104062:	0f b6 02             	movzbl (%edx),%eax
80104065:	0f b6 11             	movzbl (%ecx),%edx
80104068:	29 d0                	sub    %edx,%eax
}
8010406a:	5b                   	pop    %ebx
8010406b:	5d                   	pop    %ebp
8010406c:	c3                   	ret    
    return 0;
8010406d:	b8 00 00 00 00       	mov    $0x0,%eax
80104072:	eb f6                	jmp    8010406a <strncmp+0x37>

80104074 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104074:	f3 0f 1e fb          	endbr32 
80104078:	55                   	push   %ebp
80104079:	89 e5                	mov    %esp,%ebp
8010407b:	57                   	push   %edi
8010407c:	56                   	push   %esi
8010407d:	53                   	push   %ebx
8010407e:	8b 7d 08             	mov    0x8(%ebp),%edi
80104081:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104084:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104087:	89 fa                	mov    %edi,%edx
80104089:	eb 04                	jmp    8010408f <strncpy+0x1b>
8010408b:	89 f1                	mov    %esi,%ecx
8010408d:	89 da                	mov    %ebx,%edx
8010408f:	89 c3                	mov    %eax,%ebx
80104091:	83 e8 01             	sub    $0x1,%eax
80104094:	85 db                	test   %ebx,%ebx
80104096:	7e 1b                	jle    801040b3 <strncpy+0x3f>
80104098:	8d 71 01             	lea    0x1(%ecx),%esi
8010409b:	8d 5a 01             	lea    0x1(%edx),%ebx
8010409e:	0f b6 09             	movzbl (%ecx),%ecx
801040a1:	88 0a                	mov    %cl,(%edx)
801040a3:	84 c9                	test   %cl,%cl
801040a5:	75 e4                	jne    8010408b <strncpy+0x17>
801040a7:	89 da                	mov    %ebx,%edx
801040a9:	eb 08                	jmp    801040b3 <strncpy+0x3f>
    ;
  while(n-- > 0)
    *s++ = 0;
801040ab:	c6 02 00             	movb   $0x0,(%edx)
  while(n-- > 0)
801040ae:	89 c8                	mov    %ecx,%eax
    *s++ = 0;
801040b0:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
801040b3:	8d 48 ff             	lea    -0x1(%eax),%ecx
801040b6:	85 c0                	test   %eax,%eax
801040b8:	7f f1                	jg     801040ab <strncpy+0x37>
  return os;
}
801040ba:	89 f8                	mov    %edi,%eax
801040bc:	5b                   	pop    %ebx
801040bd:	5e                   	pop    %esi
801040be:	5f                   	pop    %edi
801040bf:	5d                   	pop    %ebp
801040c0:	c3                   	ret    

801040c1 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801040c1:	f3 0f 1e fb          	endbr32 
801040c5:	55                   	push   %ebp
801040c6:	89 e5                	mov    %esp,%ebp
801040c8:	57                   	push   %edi
801040c9:	56                   	push   %esi
801040ca:	53                   	push   %ebx
801040cb:	8b 7d 08             	mov    0x8(%ebp),%edi
801040ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801040d1:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
801040d4:	85 c0                	test   %eax,%eax
801040d6:	7e 23                	jle    801040fb <safestrcpy+0x3a>
801040d8:	89 fa                	mov    %edi,%edx
801040da:	eb 04                	jmp    801040e0 <safestrcpy+0x1f>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
801040dc:	89 f1                	mov    %esi,%ecx
801040de:	89 da                	mov    %ebx,%edx
801040e0:	83 e8 01             	sub    $0x1,%eax
801040e3:	85 c0                	test   %eax,%eax
801040e5:	7e 11                	jle    801040f8 <safestrcpy+0x37>
801040e7:	8d 71 01             	lea    0x1(%ecx),%esi
801040ea:	8d 5a 01             	lea    0x1(%edx),%ebx
801040ed:	0f b6 09             	movzbl (%ecx),%ecx
801040f0:	88 0a                	mov    %cl,(%edx)
801040f2:	84 c9                	test   %cl,%cl
801040f4:	75 e6                	jne    801040dc <safestrcpy+0x1b>
801040f6:	89 da                	mov    %ebx,%edx
    ;
  *s = 0;
801040f8:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
801040fb:	89 f8                	mov    %edi,%eax
801040fd:	5b                   	pop    %ebx
801040fe:	5e                   	pop    %esi
801040ff:	5f                   	pop    %edi
80104100:	5d                   	pop    %ebp
80104101:	c3                   	ret    

80104102 <strlen>:

int
strlen(const char *s)
{
80104102:	f3 0f 1e fb          	endbr32 
80104106:	55                   	push   %ebp
80104107:	89 e5                	mov    %esp,%ebp
80104109:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
8010410c:	b8 00 00 00 00       	mov    $0x0,%eax
80104111:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104115:	74 05                	je     8010411c <strlen+0x1a>
80104117:	83 c0 01             	add    $0x1,%eax
8010411a:	eb f5                	jmp    80104111 <strlen+0xf>
    ;
  return n;
}
8010411c:	5d                   	pop    %ebp
8010411d:	c3                   	ret    

8010411e <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010411e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104122:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104126:	55                   	push   %ebp
  pushl %ebx
80104127:	53                   	push   %ebx
  pushl %esi
80104128:	56                   	push   %esi
  pushl %edi
80104129:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010412a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010412c:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010412e:	5f                   	pop    %edi
  popl %esi
8010412f:	5e                   	pop    %esi
  popl %ebx
80104130:	5b                   	pop    %ebx
  popl %ebp
80104131:	5d                   	pop    %ebp
  ret
80104132:	c3                   	ret    

80104133 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104133:	f3 0f 1e fb          	endbr32 
80104137:	55                   	push   %ebp
80104138:	89 e5                	mov    %esp,%ebp
8010413a:	53                   	push   %ebx
8010413b:	83 ec 04             	sub    $0x4,%esp
8010413e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104141:	e8 35 f2 ff ff       	call   8010337b <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104146:	8b 00                	mov    (%eax),%eax
80104148:	39 d8                	cmp    %ebx,%eax
8010414a:	76 19                	jbe    80104165 <fetchint+0x32>
8010414c:	8d 53 04             	lea    0x4(%ebx),%edx
8010414f:	39 d0                	cmp    %edx,%eax
80104151:	72 19                	jb     8010416c <fetchint+0x39>
    return -1;
  *ip = *(int*)(addr);
80104153:	8b 13                	mov    (%ebx),%edx
80104155:	8b 45 0c             	mov    0xc(%ebp),%eax
80104158:	89 10                	mov    %edx,(%eax)
  return 0;
8010415a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010415f:	83 c4 04             	add    $0x4,%esp
80104162:	5b                   	pop    %ebx
80104163:	5d                   	pop    %ebp
80104164:	c3                   	ret    
    return -1;
80104165:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010416a:	eb f3                	jmp    8010415f <fetchint+0x2c>
8010416c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104171:	eb ec                	jmp    8010415f <fetchint+0x2c>

80104173 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104173:	f3 0f 1e fb          	endbr32 
80104177:	55                   	push   %ebp
80104178:	89 e5                	mov    %esp,%ebp
8010417a:	53                   	push   %ebx
8010417b:	83 ec 04             	sub    $0x4,%esp
8010417e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104181:	e8 f5 f1 ff ff       	call   8010337b <myproc>

  if(addr >= curproc->sz)
80104186:	39 18                	cmp    %ebx,(%eax)
80104188:	76 26                	jbe    801041b0 <fetchstr+0x3d>
    return -1;
  *pp = (char*)addr;
8010418a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010418d:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010418f:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104191:	89 d8                	mov    %ebx,%eax
80104193:	39 d0                	cmp    %edx,%eax
80104195:	73 0e                	jae    801041a5 <fetchstr+0x32>
    if(*s == 0)
80104197:	80 38 00             	cmpb   $0x0,(%eax)
8010419a:	74 05                	je     801041a1 <fetchstr+0x2e>
  for(s = *pp; s < ep; s++){
8010419c:	83 c0 01             	add    $0x1,%eax
8010419f:	eb f2                	jmp    80104193 <fetchstr+0x20>
      return s - *pp;
801041a1:	29 d8                	sub    %ebx,%eax
801041a3:	eb 05                	jmp    801041aa <fetchstr+0x37>
  }
  return -1;
801041a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041aa:	83 c4 04             	add    $0x4,%esp
801041ad:	5b                   	pop    %ebx
801041ae:	5d                   	pop    %ebp
801041af:	c3                   	ret    
    return -1;
801041b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041b5:	eb f3                	jmp    801041aa <fetchstr+0x37>

801041b7 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801041b7:	f3 0f 1e fb          	endbr32 
801041bb:	55                   	push   %ebp
801041bc:	89 e5                	mov    %esp,%ebp
801041be:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801041c1:	e8 b5 f1 ff ff       	call   8010337b <myproc>
801041c6:	8b 50 18             	mov    0x18(%eax),%edx
801041c9:	8b 45 08             	mov    0x8(%ebp),%eax
801041cc:	c1 e0 02             	shl    $0x2,%eax
801041cf:	03 42 44             	add    0x44(%edx),%eax
801041d2:	83 ec 08             	sub    $0x8,%esp
801041d5:	ff 75 0c             	pushl  0xc(%ebp)
801041d8:	83 c0 04             	add    $0x4,%eax
801041db:	50                   	push   %eax
801041dc:	e8 52 ff ff ff       	call   80104133 <fetchint>
}
801041e1:	c9                   	leave  
801041e2:	c3                   	ret    

801041e3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801041e3:	f3 0f 1e fb          	endbr32 
801041e7:	55                   	push   %ebp
801041e8:	89 e5                	mov    %esp,%ebp
801041ea:	56                   	push   %esi
801041eb:	53                   	push   %ebx
801041ec:	83 ec 10             	sub    $0x10,%esp
801041ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
801041f2:	e8 84 f1 ff ff       	call   8010337b <myproc>
801041f7:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
801041f9:	83 ec 08             	sub    $0x8,%esp
801041fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801041ff:	50                   	push   %eax
80104200:	ff 75 08             	pushl  0x8(%ebp)
80104203:	e8 af ff ff ff       	call   801041b7 <argint>
80104208:	83 c4 10             	add    $0x10,%esp
8010420b:	85 c0                	test   %eax,%eax
8010420d:	78 24                	js     80104233 <argptr+0x50>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010420f:	85 db                	test   %ebx,%ebx
80104211:	78 27                	js     8010423a <argptr+0x57>
80104213:	8b 16                	mov    (%esi),%edx
80104215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104218:	39 c2                	cmp    %eax,%edx
8010421a:	76 25                	jbe    80104241 <argptr+0x5e>
8010421c:	01 c3                	add    %eax,%ebx
8010421e:	39 da                	cmp    %ebx,%edx
80104220:	72 26                	jb     80104248 <argptr+0x65>
    return -1;
  *pp = (char*)i;
80104222:	8b 55 0c             	mov    0xc(%ebp),%edx
80104225:	89 02                	mov    %eax,(%edx)
  return 0;
80104227:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010422c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010422f:	5b                   	pop    %ebx
80104230:	5e                   	pop    %esi
80104231:	5d                   	pop    %ebp
80104232:	c3                   	ret    
    return -1;
80104233:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104238:	eb f2                	jmp    8010422c <argptr+0x49>
    return -1;
8010423a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010423f:	eb eb                	jmp    8010422c <argptr+0x49>
80104241:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104246:	eb e4                	jmp    8010422c <argptr+0x49>
80104248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010424d:	eb dd                	jmp    8010422c <argptr+0x49>

8010424f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010424f:	f3 0f 1e fb          	endbr32 
80104253:	55                   	push   %ebp
80104254:	89 e5                	mov    %esp,%ebp
80104256:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104259:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010425c:	50                   	push   %eax
8010425d:	ff 75 08             	pushl  0x8(%ebp)
80104260:	e8 52 ff ff ff       	call   801041b7 <argint>
80104265:	83 c4 10             	add    $0x10,%esp
80104268:	85 c0                	test   %eax,%eax
8010426a:	78 13                	js     8010427f <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
8010426c:	83 ec 08             	sub    $0x8,%esp
8010426f:	ff 75 0c             	pushl  0xc(%ebp)
80104272:	ff 75 f4             	pushl  -0xc(%ebp)
80104275:	e8 f9 fe ff ff       	call   80104173 <fetchstr>
8010427a:	83 c4 10             	add    $0x10,%esp
}
8010427d:	c9                   	leave  
8010427e:	c3                   	ret    
    return -1;
8010427f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104284:	eb f7                	jmp    8010427d <argstr+0x2e>

80104286 <syscall>:
[SYS_cps] sys_cps
};

void
syscall(void)
{
80104286:	f3 0f 1e fb          	endbr32 
8010428a:	55                   	push   %ebp
8010428b:	89 e5                	mov    %esp,%ebp
8010428d:	53                   	push   %ebx
8010428e:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104291:	e8 e5 f0 ff ff       	call   8010337b <myproc>
80104296:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104298:	8b 40 18             	mov    0x18(%eax),%eax
8010429b:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010429e:	8d 50 ff             	lea    -0x1(%eax),%edx
801042a1:	83 fa 18             	cmp    $0x18,%edx
801042a4:	77 17                	ja     801042bd <syscall+0x37>
801042a6:	8b 14 85 40 76 10 80 	mov    -0x7fef89c0(,%eax,4),%edx
801042ad:	85 d2                	test   %edx,%edx
801042af:	74 0c                	je     801042bd <syscall+0x37>
    curproc->tf->eax = syscalls[num]();
801042b1:	ff d2                	call   *%edx
801042b3:	89 c2                	mov    %eax,%edx
801042b5:	8b 43 18             	mov    0x18(%ebx),%eax
801042b8:	89 50 1c             	mov    %edx,0x1c(%eax)
801042bb:	eb 1f                	jmp    801042dc <syscall+0x56>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801042bd:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
801042c0:	50                   	push   %eax
801042c1:	52                   	push   %edx
801042c2:	ff 73 10             	pushl  0x10(%ebx)
801042c5:	68 05 76 10 80       	push   $0x80107605
801042ca:	e8 5a c3 ff ff       	call   80100629 <cprintf>
    curproc->tf->eax = -1;
801042cf:	8b 43 18             	mov    0x18(%ebx),%eax
801042d2:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
801042d9:	83 c4 10             	add    $0x10,%esp
  }
}
801042dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042df:	c9                   	leave  
801042e0:	c3                   	ret    

801042e1 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801042e1:	55                   	push   %ebp
801042e2:	89 e5                	mov    %esp,%ebp
801042e4:	56                   	push   %esi
801042e5:	53                   	push   %ebx
801042e6:	83 ec 18             	sub    $0x18,%esp
801042e9:	89 d6                	mov    %edx,%esi
801042eb:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801042ed:	8d 55 f4             	lea    -0xc(%ebp),%edx
801042f0:	52                   	push   %edx
801042f1:	50                   	push   %eax
801042f2:	e8 c0 fe ff ff       	call   801041b7 <argint>
801042f7:	83 c4 10             	add    $0x10,%esp
801042fa:	85 c0                	test   %eax,%eax
801042fc:	78 35                	js     80104333 <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801042fe:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104302:	77 28                	ja     8010432c <argfd+0x4b>
80104304:	e8 72 f0 ff ff       	call   8010337b <myproc>
80104309:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010430c:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104310:	85 c0                	test   %eax,%eax
80104312:	74 18                	je     8010432c <argfd+0x4b>
    return -1;
  if(pfd)
80104314:	85 f6                	test   %esi,%esi
80104316:	74 02                	je     8010431a <argfd+0x39>
    *pfd = fd;
80104318:	89 16                	mov    %edx,(%esi)
  if(pf)
8010431a:	85 db                	test   %ebx,%ebx
8010431c:	74 1c                	je     8010433a <argfd+0x59>
    *pf = f;
8010431e:	89 03                	mov    %eax,(%ebx)
  return 0;
80104320:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104325:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104328:	5b                   	pop    %ebx
80104329:	5e                   	pop    %esi
8010432a:	5d                   	pop    %ebp
8010432b:	c3                   	ret    
    return -1;
8010432c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104331:	eb f2                	jmp    80104325 <argfd+0x44>
    return -1;
80104333:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104338:	eb eb                	jmp    80104325 <argfd+0x44>
  return 0;
8010433a:	b8 00 00 00 00       	mov    $0x0,%eax
8010433f:	eb e4                	jmp    80104325 <argfd+0x44>

80104341 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104341:	55                   	push   %ebp
80104342:	89 e5                	mov    %esp,%ebp
80104344:	53                   	push   %ebx
80104345:	83 ec 04             	sub    $0x4,%esp
80104348:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
8010434a:	e8 2c f0 ff ff       	call   8010337b <myproc>
8010434f:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
80104351:	b8 00 00 00 00       	mov    $0x0,%eax
80104356:	83 f8 0f             	cmp    $0xf,%eax
80104359:	7f 12                	jg     8010436d <fdalloc+0x2c>
    if(curproc->ofile[fd] == 0){
8010435b:	83 7c 82 28 00       	cmpl   $0x0,0x28(%edx,%eax,4)
80104360:	74 05                	je     80104367 <fdalloc+0x26>
  for(fd = 0; fd < NOFILE; fd++){
80104362:	83 c0 01             	add    $0x1,%eax
80104365:	eb ef                	jmp    80104356 <fdalloc+0x15>
      curproc->ofile[fd] = f;
80104367:	89 5c 82 28          	mov    %ebx,0x28(%edx,%eax,4)
      return fd;
8010436b:	eb 05                	jmp    80104372 <fdalloc+0x31>
    }
  }
  return -1;
8010436d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104372:	83 c4 04             	add    $0x4,%esp
80104375:	5b                   	pop    %ebx
80104376:	5d                   	pop    %ebp
80104377:	c3                   	ret    

80104378 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104378:	55                   	push   %ebp
80104379:	89 e5                	mov    %esp,%ebp
8010437b:	56                   	push   %esi
8010437c:	53                   	push   %ebx
8010437d:	83 ec 10             	sub    $0x10,%esp
80104380:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104382:	b8 20 00 00 00       	mov    $0x20,%eax
80104387:	89 c6                	mov    %eax,%esi
80104389:	39 43 58             	cmp    %eax,0x58(%ebx)
8010438c:	76 2e                	jbe    801043bc <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010438e:	6a 10                	push   $0x10
80104390:	50                   	push   %eax
80104391:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104394:	50                   	push   %eax
80104395:	53                   	push   %ebx
80104396:	e8 3c d4 ff ff       	call   801017d7 <readi>
8010439b:	83 c4 10             	add    $0x10,%esp
8010439e:	83 f8 10             	cmp    $0x10,%eax
801043a1:	75 0c                	jne    801043af <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801043a3:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
801043a8:	75 1e                	jne    801043c8 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801043aa:	8d 46 10             	lea    0x10(%esi),%eax
801043ad:	eb d8                	jmp    80104387 <isdirempty+0xf>
      panic("isdirempty: readi");
801043af:	83 ec 0c             	sub    $0xc,%esp
801043b2:	68 a8 76 10 80       	push   $0x801076a8
801043b7:	e8 a0 bf ff ff       	call   8010035c <panic>
      return 0;
  }
  return 1;
801043bc:	b8 01 00 00 00       	mov    $0x1,%eax
}
801043c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801043c4:	5b                   	pop    %ebx
801043c5:	5e                   	pop    %esi
801043c6:	5d                   	pop    %ebp
801043c7:	c3                   	ret    
      return 0;
801043c8:	b8 00 00 00 00       	mov    $0x0,%eax
801043cd:	eb f2                	jmp    801043c1 <isdirempty+0x49>

801043cf <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801043cf:	55                   	push   %ebp
801043d0:	89 e5                	mov    %esp,%ebp
801043d2:	57                   	push   %edi
801043d3:	56                   	push   %esi
801043d4:	53                   	push   %ebx
801043d5:	83 ec 34             	sub    $0x34,%esp
801043d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801043db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801043de:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801043e1:	8d 55 da             	lea    -0x26(%ebp),%edx
801043e4:	52                   	push   %edx
801043e5:	50                   	push   %eax
801043e6:	e8 87 d8 ff ff       	call   80101c72 <nameiparent>
801043eb:	89 c6                	mov    %eax,%esi
801043ed:	83 c4 10             	add    $0x10,%esp
801043f0:	85 c0                	test   %eax,%eax
801043f2:	0f 84 33 01 00 00    	je     8010452b <create+0x15c>
    return 0;
  ilock(dp);
801043f8:	83 ec 0c             	sub    $0xc,%esp
801043fb:	50                   	push   %eax
801043fc:	e8 d0 d1 ff ff       	call   801015d1 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104401:	83 c4 0c             	add    $0xc,%esp
80104404:	6a 00                	push   $0x0
80104406:	8d 45 da             	lea    -0x26(%ebp),%eax
80104409:	50                   	push   %eax
8010440a:	56                   	push   %esi
8010440b:	e8 10 d6 ff ff       	call   80101a20 <dirlookup>
80104410:	89 c3                	mov    %eax,%ebx
80104412:	83 c4 10             	add    $0x10,%esp
80104415:	85 c0                	test   %eax,%eax
80104417:	74 3d                	je     80104456 <create+0x87>
    iunlockput(dp);
80104419:	83 ec 0c             	sub    $0xc,%esp
8010441c:	56                   	push   %esi
8010441d:	e8 62 d3 ff ff       	call   80101784 <iunlockput>
    ilock(ip);
80104422:	89 1c 24             	mov    %ebx,(%esp)
80104425:	e8 a7 d1 ff ff       	call   801015d1 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010442a:	83 c4 10             	add    $0x10,%esp
8010442d:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104432:	75 07                	jne    8010443b <create+0x6c>
80104434:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104439:	74 11                	je     8010444c <create+0x7d>
      return ip;
    iunlockput(ip);
8010443b:	83 ec 0c             	sub    $0xc,%esp
8010443e:	53                   	push   %ebx
8010443f:	e8 40 d3 ff ff       	call   80101784 <iunlockput>
    return 0;
80104444:	83 c4 10             	add    $0x10,%esp
80104447:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010444c:	89 d8                	mov    %ebx,%eax
8010444e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104451:	5b                   	pop    %ebx
80104452:	5e                   	pop    %esi
80104453:	5f                   	pop    %edi
80104454:	5d                   	pop    %ebp
80104455:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104456:	83 ec 08             	sub    $0x8,%esp
80104459:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
8010445d:	50                   	push   %eax
8010445e:	ff 36                	pushl  (%esi)
80104460:	e8 5d cf ff ff       	call   801013c2 <ialloc>
80104465:	89 c3                	mov    %eax,%ebx
80104467:	83 c4 10             	add    $0x10,%esp
8010446a:	85 c0                	test   %eax,%eax
8010446c:	74 52                	je     801044c0 <create+0xf1>
  ilock(ip);
8010446e:	83 ec 0c             	sub    $0xc,%esp
80104471:	50                   	push   %eax
80104472:	e8 5a d1 ff ff       	call   801015d1 <ilock>
  ip->major = major;
80104477:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
8010447b:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
8010447f:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
80104483:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104489:	89 1c 24             	mov    %ebx,(%esp)
8010448c:	e8 d7 cf ff ff       	call   80101468 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104491:	83 c4 10             	add    $0x10,%esp
80104494:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104499:	74 32                	je     801044cd <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
8010449b:	83 ec 04             	sub    $0x4,%esp
8010449e:	ff 73 04             	pushl  0x4(%ebx)
801044a1:	8d 45 da             	lea    -0x26(%ebp),%eax
801044a4:	50                   	push   %eax
801044a5:	56                   	push   %esi
801044a6:	e8 f6 d6 ff ff       	call   80101ba1 <dirlink>
801044ab:	83 c4 10             	add    $0x10,%esp
801044ae:	85 c0                	test   %eax,%eax
801044b0:	78 6c                	js     8010451e <create+0x14f>
  iunlockput(dp);
801044b2:	83 ec 0c             	sub    $0xc,%esp
801044b5:	56                   	push   %esi
801044b6:	e8 c9 d2 ff ff       	call   80101784 <iunlockput>
  return ip;
801044bb:	83 c4 10             	add    $0x10,%esp
801044be:	eb 8c                	jmp    8010444c <create+0x7d>
    panic("create: ialloc");
801044c0:	83 ec 0c             	sub    $0xc,%esp
801044c3:	68 ba 76 10 80       	push   $0x801076ba
801044c8:	e8 8f be ff ff       	call   8010035c <panic>
    dp->nlink++;  // for ".."
801044cd:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801044d1:	83 c0 01             	add    $0x1,%eax
801044d4:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801044d8:	83 ec 0c             	sub    $0xc,%esp
801044db:	56                   	push   %esi
801044dc:	e8 87 cf ff ff       	call   80101468 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801044e1:	83 c4 0c             	add    $0xc,%esp
801044e4:	ff 73 04             	pushl  0x4(%ebx)
801044e7:	68 ca 76 10 80       	push   $0x801076ca
801044ec:	53                   	push   %ebx
801044ed:	e8 af d6 ff ff       	call   80101ba1 <dirlink>
801044f2:	83 c4 10             	add    $0x10,%esp
801044f5:	85 c0                	test   %eax,%eax
801044f7:	78 18                	js     80104511 <create+0x142>
801044f9:	83 ec 04             	sub    $0x4,%esp
801044fc:	ff 76 04             	pushl  0x4(%esi)
801044ff:	68 c9 76 10 80       	push   $0x801076c9
80104504:	53                   	push   %ebx
80104505:	e8 97 d6 ff ff       	call   80101ba1 <dirlink>
8010450a:	83 c4 10             	add    $0x10,%esp
8010450d:	85 c0                	test   %eax,%eax
8010450f:	79 8a                	jns    8010449b <create+0xcc>
      panic("create dots");
80104511:	83 ec 0c             	sub    $0xc,%esp
80104514:	68 cc 76 10 80       	push   $0x801076cc
80104519:	e8 3e be ff ff       	call   8010035c <panic>
    panic("create: dirlink");
8010451e:	83 ec 0c             	sub    $0xc,%esp
80104521:	68 d8 76 10 80       	push   $0x801076d8
80104526:	e8 31 be ff ff       	call   8010035c <panic>
    return 0;
8010452b:	89 c3                	mov    %eax,%ebx
8010452d:	e9 1a ff ff ff       	jmp    8010444c <create+0x7d>

80104532 <sys_dup>:
{
80104532:	f3 0f 1e fb          	endbr32 
80104536:	55                   	push   %ebp
80104537:	89 e5                	mov    %esp,%ebp
80104539:	53                   	push   %ebx
8010453a:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010453d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104540:	ba 00 00 00 00       	mov    $0x0,%edx
80104545:	b8 00 00 00 00       	mov    $0x0,%eax
8010454a:	e8 92 fd ff ff       	call   801042e1 <argfd>
8010454f:	85 c0                	test   %eax,%eax
80104551:	78 23                	js     80104576 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
80104553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104556:	e8 e6 fd ff ff       	call   80104341 <fdalloc>
8010455b:	89 c3                	mov    %eax,%ebx
8010455d:	85 c0                	test   %eax,%eax
8010455f:	78 1c                	js     8010457d <sys_dup+0x4b>
  filedup(f);
80104561:	83 ec 0c             	sub    $0xc,%esp
80104564:	ff 75 f4             	pushl  -0xc(%ebp)
80104567:	e8 57 c7 ff ff       	call   80100cc3 <filedup>
  return fd;
8010456c:	83 c4 10             	add    $0x10,%esp
}
8010456f:	89 d8                	mov    %ebx,%eax
80104571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104574:	c9                   	leave  
80104575:	c3                   	ret    
    return -1;
80104576:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010457b:	eb f2                	jmp    8010456f <sys_dup+0x3d>
    return -1;
8010457d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104582:	eb eb                	jmp    8010456f <sys_dup+0x3d>

80104584 <sys_read>:
{
80104584:	f3 0f 1e fb          	endbr32 
80104588:	55                   	push   %ebp
80104589:	89 e5                	mov    %esp,%ebp
8010458b:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010458e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104591:	ba 00 00 00 00       	mov    $0x0,%edx
80104596:	b8 00 00 00 00       	mov    $0x0,%eax
8010459b:	e8 41 fd ff ff       	call   801042e1 <argfd>
801045a0:	85 c0                	test   %eax,%eax
801045a2:	78 43                	js     801045e7 <sys_read+0x63>
801045a4:	83 ec 08             	sub    $0x8,%esp
801045a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801045aa:	50                   	push   %eax
801045ab:	6a 02                	push   $0x2
801045ad:	e8 05 fc ff ff       	call   801041b7 <argint>
801045b2:	83 c4 10             	add    $0x10,%esp
801045b5:	85 c0                	test   %eax,%eax
801045b7:	78 2e                	js     801045e7 <sys_read+0x63>
801045b9:	83 ec 04             	sub    $0x4,%esp
801045bc:	ff 75 f0             	pushl  -0x10(%ebp)
801045bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801045c2:	50                   	push   %eax
801045c3:	6a 01                	push   $0x1
801045c5:	e8 19 fc ff ff       	call   801041e3 <argptr>
801045ca:	83 c4 10             	add    $0x10,%esp
801045cd:	85 c0                	test   %eax,%eax
801045cf:	78 16                	js     801045e7 <sys_read+0x63>
  return fileread(f, p, n);
801045d1:	83 ec 04             	sub    $0x4,%esp
801045d4:	ff 75 f0             	pushl  -0x10(%ebp)
801045d7:	ff 75 ec             	pushl  -0x14(%ebp)
801045da:	ff 75 f4             	pushl  -0xc(%ebp)
801045dd:	e8 33 c8 ff ff       	call   80100e15 <fileread>
801045e2:	83 c4 10             	add    $0x10,%esp
}
801045e5:	c9                   	leave  
801045e6:	c3                   	ret    
    return -1;
801045e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ec:	eb f7                	jmp    801045e5 <sys_read+0x61>

801045ee <sys_write>:
{
801045ee:	f3 0f 1e fb          	endbr32 
801045f2:	55                   	push   %ebp
801045f3:	89 e5                	mov    %esp,%ebp
801045f5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801045f8:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801045fb:	ba 00 00 00 00       	mov    $0x0,%edx
80104600:	b8 00 00 00 00       	mov    $0x0,%eax
80104605:	e8 d7 fc ff ff       	call   801042e1 <argfd>
8010460a:	85 c0                	test   %eax,%eax
8010460c:	78 43                	js     80104651 <sys_write+0x63>
8010460e:	83 ec 08             	sub    $0x8,%esp
80104611:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104614:	50                   	push   %eax
80104615:	6a 02                	push   $0x2
80104617:	e8 9b fb ff ff       	call   801041b7 <argint>
8010461c:	83 c4 10             	add    $0x10,%esp
8010461f:	85 c0                	test   %eax,%eax
80104621:	78 2e                	js     80104651 <sys_write+0x63>
80104623:	83 ec 04             	sub    $0x4,%esp
80104626:	ff 75 f0             	pushl  -0x10(%ebp)
80104629:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010462c:	50                   	push   %eax
8010462d:	6a 01                	push   $0x1
8010462f:	e8 af fb ff ff       	call   801041e3 <argptr>
80104634:	83 c4 10             	add    $0x10,%esp
80104637:	85 c0                	test   %eax,%eax
80104639:	78 16                	js     80104651 <sys_write+0x63>
  return filewrite(f, p, n);
8010463b:	83 ec 04             	sub    $0x4,%esp
8010463e:	ff 75 f0             	pushl  -0x10(%ebp)
80104641:	ff 75 ec             	pushl  -0x14(%ebp)
80104644:	ff 75 f4             	pushl  -0xc(%ebp)
80104647:	e8 52 c8 ff ff       	call   80100e9e <filewrite>
8010464c:	83 c4 10             	add    $0x10,%esp
}
8010464f:	c9                   	leave  
80104650:	c3                   	ret    
    return -1;
80104651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104656:	eb f7                	jmp    8010464f <sys_write+0x61>

80104658 <sys_close>:
{
80104658:	f3 0f 1e fb          	endbr32 
8010465c:	55                   	push   %ebp
8010465d:	89 e5                	mov    %esp,%ebp
8010465f:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104662:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104665:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104668:	b8 00 00 00 00       	mov    $0x0,%eax
8010466d:	e8 6f fc ff ff       	call   801042e1 <argfd>
80104672:	85 c0                	test   %eax,%eax
80104674:	78 25                	js     8010469b <sys_close+0x43>
  myproc()->ofile[fd] = 0;
80104676:	e8 00 ed ff ff       	call   8010337b <myproc>
8010467b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010467e:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104685:	00 
  fileclose(f);
80104686:	83 ec 0c             	sub    $0xc,%esp
80104689:	ff 75 f0             	pushl  -0x10(%ebp)
8010468c:	e8 7b c6 ff ff       	call   80100d0c <fileclose>
  return 0;
80104691:	83 c4 10             	add    $0x10,%esp
80104694:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104699:	c9                   	leave  
8010469a:	c3                   	ret    
    return -1;
8010469b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a0:	eb f7                	jmp    80104699 <sys_close+0x41>

801046a2 <sys_fstat>:
{
801046a2:	f3 0f 1e fb          	endbr32 
801046a6:	55                   	push   %ebp
801046a7:	89 e5                	mov    %esp,%ebp
801046a9:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801046ac:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801046af:	ba 00 00 00 00       	mov    $0x0,%edx
801046b4:	b8 00 00 00 00       	mov    $0x0,%eax
801046b9:	e8 23 fc ff ff       	call   801042e1 <argfd>
801046be:	85 c0                	test   %eax,%eax
801046c0:	78 2a                	js     801046ec <sys_fstat+0x4a>
801046c2:	83 ec 04             	sub    $0x4,%esp
801046c5:	6a 14                	push   $0x14
801046c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801046ca:	50                   	push   %eax
801046cb:	6a 01                	push   $0x1
801046cd:	e8 11 fb ff ff       	call   801041e3 <argptr>
801046d2:	83 c4 10             	add    $0x10,%esp
801046d5:	85 c0                	test   %eax,%eax
801046d7:	78 13                	js     801046ec <sys_fstat+0x4a>
  return filestat(f, st);
801046d9:	83 ec 08             	sub    $0x8,%esp
801046dc:	ff 75 f0             	pushl  -0x10(%ebp)
801046df:	ff 75 f4             	pushl  -0xc(%ebp)
801046e2:	e8 e3 c6 ff ff       	call   80100dca <filestat>
801046e7:	83 c4 10             	add    $0x10,%esp
}
801046ea:	c9                   	leave  
801046eb:	c3                   	ret    
    return -1;
801046ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f1:	eb f7                	jmp    801046ea <sys_fstat+0x48>

801046f3 <sys_link>:
{
801046f3:	f3 0f 1e fb          	endbr32 
801046f7:	55                   	push   %ebp
801046f8:	89 e5                	mov    %esp,%ebp
801046fa:	56                   	push   %esi
801046fb:	53                   	push   %ebx
801046fc:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801046ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104702:	50                   	push   %eax
80104703:	6a 00                	push   $0x0
80104705:	e8 45 fb ff ff       	call   8010424f <argstr>
8010470a:	83 c4 10             	add    $0x10,%esp
8010470d:	85 c0                	test   %eax,%eax
8010470f:	0f 88 d3 00 00 00    	js     801047e8 <sys_link+0xf5>
80104715:	83 ec 08             	sub    $0x8,%esp
80104718:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010471b:	50                   	push   %eax
8010471c:	6a 01                	push   $0x1
8010471e:	e8 2c fb ff ff       	call   8010424f <argstr>
80104723:	83 c4 10             	add    $0x10,%esp
80104726:	85 c0                	test   %eax,%eax
80104728:	0f 88 ba 00 00 00    	js     801047e8 <sys_link+0xf5>
  begin_op();
8010472e:	e8 59 e1 ff ff       	call   8010288c <begin_op>
  if((ip = namei(old)) == 0){
80104733:	83 ec 0c             	sub    $0xc,%esp
80104736:	ff 75 e0             	pushl  -0x20(%ebp)
80104739:	e8 18 d5 ff ff       	call   80101c56 <namei>
8010473e:	89 c3                	mov    %eax,%ebx
80104740:	83 c4 10             	add    $0x10,%esp
80104743:	85 c0                	test   %eax,%eax
80104745:	0f 84 a4 00 00 00    	je     801047ef <sys_link+0xfc>
  ilock(ip);
8010474b:	83 ec 0c             	sub    $0xc,%esp
8010474e:	50                   	push   %eax
8010474f:	e8 7d ce ff ff       	call   801015d1 <ilock>
  if(ip->type == T_DIR){
80104754:	83 c4 10             	add    $0x10,%esp
80104757:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010475c:	0f 84 99 00 00 00    	je     801047fb <sys_link+0x108>
  ip->nlink++;
80104762:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104766:	83 c0 01             	add    $0x1,%eax
80104769:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010476d:	83 ec 0c             	sub    $0xc,%esp
80104770:	53                   	push   %ebx
80104771:	e8 f2 cc ff ff       	call   80101468 <iupdate>
  iunlock(ip);
80104776:	89 1c 24             	mov    %ebx,(%esp)
80104779:	e8 19 cf ff ff       	call   80101697 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
8010477e:	83 c4 08             	add    $0x8,%esp
80104781:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104784:	50                   	push   %eax
80104785:	ff 75 e4             	pushl  -0x1c(%ebp)
80104788:	e8 e5 d4 ff ff       	call   80101c72 <nameiparent>
8010478d:	89 c6                	mov    %eax,%esi
8010478f:	83 c4 10             	add    $0x10,%esp
80104792:	85 c0                	test   %eax,%eax
80104794:	0f 84 85 00 00 00    	je     8010481f <sys_link+0x12c>
  ilock(dp);
8010479a:	83 ec 0c             	sub    $0xc,%esp
8010479d:	50                   	push   %eax
8010479e:	e8 2e ce ff ff       	call   801015d1 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801047a3:	83 c4 10             	add    $0x10,%esp
801047a6:	8b 03                	mov    (%ebx),%eax
801047a8:	39 06                	cmp    %eax,(%esi)
801047aa:	75 67                	jne    80104813 <sys_link+0x120>
801047ac:	83 ec 04             	sub    $0x4,%esp
801047af:	ff 73 04             	pushl  0x4(%ebx)
801047b2:	8d 45 ea             	lea    -0x16(%ebp),%eax
801047b5:	50                   	push   %eax
801047b6:	56                   	push   %esi
801047b7:	e8 e5 d3 ff ff       	call   80101ba1 <dirlink>
801047bc:	83 c4 10             	add    $0x10,%esp
801047bf:	85 c0                	test   %eax,%eax
801047c1:	78 50                	js     80104813 <sys_link+0x120>
  iunlockput(dp);
801047c3:	83 ec 0c             	sub    $0xc,%esp
801047c6:	56                   	push   %esi
801047c7:	e8 b8 cf ff ff       	call   80101784 <iunlockput>
  iput(ip);
801047cc:	89 1c 24             	mov    %ebx,(%esp)
801047cf:	e8 0c cf ff ff       	call   801016e0 <iput>
  end_op();
801047d4:	e8 31 e1 ff ff       	call   8010290a <end_op>
  return 0;
801047d9:	83 c4 10             	add    $0x10,%esp
801047dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801047e4:	5b                   	pop    %ebx
801047e5:	5e                   	pop    %esi
801047e6:	5d                   	pop    %ebp
801047e7:	c3                   	ret    
    return -1;
801047e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ed:	eb f2                	jmp    801047e1 <sys_link+0xee>
    end_op();
801047ef:	e8 16 e1 ff ff       	call   8010290a <end_op>
    return -1;
801047f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f9:	eb e6                	jmp    801047e1 <sys_link+0xee>
    iunlockput(ip);
801047fb:	83 ec 0c             	sub    $0xc,%esp
801047fe:	53                   	push   %ebx
801047ff:	e8 80 cf ff ff       	call   80101784 <iunlockput>
    end_op();
80104804:	e8 01 e1 ff ff       	call   8010290a <end_op>
    return -1;
80104809:	83 c4 10             	add    $0x10,%esp
8010480c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104811:	eb ce                	jmp    801047e1 <sys_link+0xee>
    iunlockput(dp);
80104813:	83 ec 0c             	sub    $0xc,%esp
80104816:	56                   	push   %esi
80104817:	e8 68 cf ff ff       	call   80101784 <iunlockput>
    goto bad;
8010481c:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010481f:	83 ec 0c             	sub    $0xc,%esp
80104822:	53                   	push   %ebx
80104823:	e8 a9 cd ff ff       	call   801015d1 <ilock>
  ip->nlink--;
80104828:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010482c:	83 e8 01             	sub    $0x1,%eax
8010482f:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104833:	89 1c 24             	mov    %ebx,(%esp)
80104836:	e8 2d cc ff ff       	call   80101468 <iupdate>
  iunlockput(ip);
8010483b:	89 1c 24             	mov    %ebx,(%esp)
8010483e:	e8 41 cf ff ff       	call   80101784 <iunlockput>
  end_op();
80104843:	e8 c2 e0 ff ff       	call   8010290a <end_op>
  return -1;
80104848:	83 c4 10             	add    $0x10,%esp
8010484b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104850:	eb 8f                	jmp    801047e1 <sys_link+0xee>

80104852 <sys_unlink>:
{
80104852:	f3 0f 1e fb          	endbr32 
80104856:	55                   	push   %ebp
80104857:	89 e5                	mov    %esp,%ebp
80104859:	57                   	push   %edi
8010485a:	56                   	push   %esi
8010485b:	53                   	push   %ebx
8010485c:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
8010485f:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104862:	50                   	push   %eax
80104863:	6a 00                	push   $0x0
80104865:	e8 e5 f9 ff ff       	call   8010424f <argstr>
8010486a:	83 c4 10             	add    $0x10,%esp
8010486d:	85 c0                	test   %eax,%eax
8010486f:	0f 88 83 01 00 00    	js     801049f8 <sys_unlink+0x1a6>
  begin_op();
80104875:	e8 12 e0 ff ff       	call   8010288c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010487a:	83 ec 08             	sub    $0x8,%esp
8010487d:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104880:	50                   	push   %eax
80104881:	ff 75 c4             	pushl  -0x3c(%ebp)
80104884:	e8 e9 d3 ff ff       	call   80101c72 <nameiparent>
80104889:	89 c6                	mov    %eax,%esi
8010488b:	83 c4 10             	add    $0x10,%esp
8010488e:	85 c0                	test   %eax,%eax
80104890:	0f 84 ed 00 00 00    	je     80104983 <sys_unlink+0x131>
  ilock(dp);
80104896:	83 ec 0c             	sub    $0xc,%esp
80104899:	50                   	push   %eax
8010489a:	e8 32 cd ff ff       	call   801015d1 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010489f:	83 c4 08             	add    $0x8,%esp
801048a2:	68 ca 76 10 80       	push   $0x801076ca
801048a7:	8d 45 ca             	lea    -0x36(%ebp),%eax
801048aa:	50                   	push   %eax
801048ab:	e8 57 d1 ff ff       	call   80101a07 <namecmp>
801048b0:	83 c4 10             	add    $0x10,%esp
801048b3:	85 c0                	test   %eax,%eax
801048b5:	0f 84 fc 00 00 00    	je     801049b7 <sys_unlink+0x165>
801048bb:	83 ec 08             	sub    $0x8,%esp
801048be:	68 c9 76 10 80       	push   $0x801076c9
801048c3:	8d 45 ca             	lea    -0x36(%ebp),%eax
801048c6:	50                   	push   %eax
801048c7:	e8 3b d1 ff ff       	call   80101a07 <namecmp>
801048cc:	83 c4 10             	add    $0x10,%esp
801048cf:	85 c0                	test   %eax,%eax
801048d1:	0f 84 e0 00 00 00    	je     801049b7 <sys_unlink+0x165>
  if((ip = dirlookup(dp, name, &off)) == 0)
801048d7:	83 ec 04             	sub    $0x4,%esp
801048da:	8d 45 c0             	lea    -0x40(%ebp),%eax
801048dd:	50                   	push   %eax
801048de:	8d 45 ca             	lea    -0x36(%ebp),%eax
801048e1:	50                   	push   %eax
801048e2:	56                   	push   %esi
801048e3:	e8 38 d1 ff ff       	call   80101a20 <dirlookup>
801048e8:	89 c3                	mov    %eax,%ebx
801048ea:	83 c4 10             	add    $0x10,%esp
801048ed:	85 c0                	test   %eax,%eax
801048ef:	0f 84 c2 00 00 00    	je     801049b7 <sys_unlink+0x165>
  ilock(ip);
801048f5:	83 ec 0c             	sub    $0xc,%esp
801048f8:	50                   	push   %eax
801048f9:	e8 d3 cc ff ff       	call   801015d1 <ilock>
  if(ip->nlink < 1)
801048fe:	83 c4 10             	add    $0x10,%esp
80104901:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104906:	0f 8e 83 00 00 00    	jle    8010498f <sys_unlink+0x13d>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010490c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104911:	0f 84 85 00 00 00    	je     8010499c <sys_unlink+0x14a>
  memset(&de, 0, sizeof(de));
80104917:	83 ec 04             	sub    $0x4,%esp
8010491a:	6a 10                	push   $0x10
8010491c:	6a 00                	push   $0x0
8010491e:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104921:	57                   	push   %edi
80104922:	e8 1a f6 ff ff       	call   80103f41 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104927:	6a 10                	push   $0x10
80104929:	ff 75 c0             	pushl  -0x40(%ebp)
8010492c:	57                   	push   %edi
8010492d:	56                   	push   %esi
8010492e:	e8 a5 cf ff ff       	call   801018d8 <writei>
80104933:	83 c4 20             	add    $0x20,%esp
80104936:	83 f8 10             	cmp    $0x10,%eax
80104939:	0f 85 90 00 00 00    	jne    801049cf <sys_unlink+0x17d>
  if(ip->type == T_DIR){
8010493f:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104944:	0f 84 92 00 00 00    	je     801049dc <sys_unlink+0x18a>
  iunlockput(dp);
8010494a:	83 ec 0c             	sub    $0xc,%esp
8010494d:	56                   	push   %esi
8010494e:	e8 31 ce ff ff       	call   80101784 <iunlockput>
  ip->nlink--;
80104953:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104957:	83 e8 01             	sub    $0x1,%eax
8010495a:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010495e:	89 1c 24             	mov    %ebx,(%esp)
80104961:	e8 02 cb ff ff       	call   80101468 <iupdate>
  iunlockput(ip);
80104966:	89 1c 24             	mov    %ebx,(%esp)
80104969:	e8 16 ce ff ff       	call   80101784 <iunlockput>
  end_op();
8010496e:	e8 97 df ff ff       	call   8010290a <end_op>
  return 0;
80104973:	83 c4 10             	add    $0x10,%esp
80104976:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010497b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010497e:	5b                   	pop    %ebx
8010497f:	5e                   	pop    %esi
80104980:	5f                   	pop    %edi
80104981:	5d                   	pop    %ebp
80104982:	c3                   	ret    
    end_op();
80104983:	e8 82 df ff ff       	call   8010290a <end_op>
    return -1;
80104988:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010498d:	eb ec                	jmp    8010497b <sys_unlink+0x129>
    panic("unlink: nlink < 1");
8010498f:	83 ec 0c             	sub    $0xc,%esp
80104992:	68 e8 76 10 80       	push   $0x801076e8
80104997:	e8 c0 b9 ff ff       	call   8010035c <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010499c:	89 d8                	mov    %ebx,%eax
8010499e:	e8 d5 f9 ff ff       	call   80104378 <isdirempty>
801049a3:	85 c0                	test   %eax,%eax
801049a5:	0f 85 6c ff ff ff    	jne    80104917 <sys_unlink+0xc5>
    iunlockput(ip);
801049ab:	83 ec 0c             	sub    $0xc,%esp
801049ae:	53                   	push   %ebx
801049af:	e8 d0 cd ff ff       	call   80101784 <iunlockput>
    goto bad;
801049b4:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
801049b7:	83 ec 0c             	sub    $0xc,%esp
801049ba:	56                   	push   %esi
801049bb:	e8 c4 cd ff ff       	call   80101784 <iunlockput>
  end_op();
801049c0:	e8 45 df ff ff       	call   8010290a <end_op>
  return -1;
801049c5:	83 c4 10             	add    $0x10,%esp
801049c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049cd:	eb ac                	jmp    8010497b <sys_unlink+0x129>
    panic("unlink: writei");
801049cf:	83 ec 0c             	sub    $0xc,%esp
801049d2:	68 fa 76 10 80       	push   $0x801076fa
801049d7:	e8 80 b9 ff ff       	call   8010035c <panic>
    dp->nlink--;
801049dc:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801049e0:	83 e8 01             	sub    $0x1,%eax
801049e3:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801049e7:	83 ec 0c             	sub    $0xc,%esp
801049ea:	56                   	push   %esi
801049eb:	e8 78 ca ff ff       	call   80101468 <iupdate>
801049f0:	83 c4 10             	add    $0x10,%esp
801049f3:	e9 52 ff ff ff       	jmp    8010494a <sys_unlink+0xf8>
    return -1;
801049f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049fd:	e9 79 ff ff ff       	jmp    8010497b <sys_unlink+0x129>

80104a02 <sys_open>:

int
sys_open(void)
{
80104a02:	f3 0f 1e fb          	endbr32 
80104a06:	55                   	push   %ebp
80104a07:	89 e5                	mov    %esp,%ebp
80104a09:	57                   	push   %edi
80104a0a:	56                   	push   %esi
80104a0b:	53                   	push   %ebx
80104a0c:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104a0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104a12:	50                   	push   %eax
80104a13:	6a 00                	push   $0x0
80104a15:	e8 35 f8 ff ff       	call   8010424f <argstr>
80104a1a:	83 c4 10             	add    $0x10,%esp
80104a1d:	85 c0                	test   %eax,%eax
80104a1f:	0f 88 a0 00 00 00    	js     80104ac5 <sys_open+0xc3>
80104a25:	83 ec 08             	sub    $0x8,%esp
80104a28:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104a2b:	50                   	push   %eax
80104a2c:	6a 01                	push   $0x1
80104a2e:	e8 84 f7 ff ff       	call   801041b7 <argint>
80104a33:	83 c4 10             	add    $0x10,%esp
80104a36:	85 c0                	test   %eax,%eax
80104a38:	0f 88 87 00 00 00    	js     80104ac5 <sys_open+0xc3>
    return -1;

  begin_op();
80104a3e:	e8 49 de ff ff       	call   8010288c <begin_op>

  if(omode & O_CREATE){
80104a43:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104a47:	0f 84 8b 00 00 00    	je     80104ad8 <sys_open+0xd6>
    ip = create(path, T_FILE, 0, 0);
80104a4d:	83 ec 0c             	sub    $0xc,%esp
80104a50:	6a 00                	push   $0x0
80104a52:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a57:	ba 02 00 00 00       	mov    $0x2,%edx
80104a5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104a5f:	e8 6b f9 ff ff       	call   801043cf <create>
80104a64:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104a66:	83 c4 10             	add    $0x10,%esp
80104a69:	85 c0                	test   %eax,%eax
80104a6b:	74 5f                	je     80104acc <sys_open+0xca>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104a6d:	e8 ec c1 ff ff       	call   80100c5e <filealloc>
80104a72:	89 c3                	mov    %eax,%ebx
80104a74:	85 c0                	test   %eax,%eax
80104a76:	0f 84 b5 00 00 00    	je     80104b31 <sys_open+0x12f>
80104a7c:	e8 c0 f8 ff ff       	call   80104341 <fdalloc>
80104a81:	89 c7                	mov    %eax,%edi
80104a83:	85 c0                	test   %eax,%eax
80104a85:	0f 88 a6 00 00 00    	js     80104b31 <sys_open+0x12f>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a8b:	83 ec 0c             	sub    $0xc,%esp
80104a8e:	56                   	push   %esi
80104a8f:	e8 03 cc ff ff       	call   80101697 <iunlock>
  end_op();
80104a94:	e8 71 de ff ff       	call   8010290a <end_op>

  f->type = FD_INODE;
80104a99:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104a9f:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104aa2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104aa9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aac:	83 c4 10             	add    $0x10,%esp
80104aaf:	a8 01                	test   $0x1,%al
80104ab1:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104ab5:	a8 03                	test   $0x3,%al
80104ab7:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104abb:	89 f8                	mov    %edi,%eax
80104abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ac0:	5b                   	pop    %ebx
80104ac1:	5e                   	pop    %esi
80104ac2:	5f                   	pop    %edi
80104ac3:	5d                   	pop    %ebp
80104ac4:	c3                   	ret    
    return -1;
80104ac5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104aca:	eb ef                	jmp    80104abb <sys_open+0xb9>
      end_op();
80104acc:	e8 39 de ff ff       	call   8010290a <end_op>
      return -1;
80104ad1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104ad6:	eb e3                	jmp    80104abb <sys_open+0xb9>
    if((ip = namei(path)) == 0){
80104ad8:	83 ec 0c             	sub    $0xc,%esp
80104adb:	ff 75 e4             	pushl  -0x1c(%ebp)
80104ade:	e8 73 d1 ff ff       	call   80101c56 <namei>
80104ae3:	89 c6                	mov    %eax,%esi
80104ae5:	83 c4 10             	add    $0x10,%esp
80104ae8:	85 c0                	test   %eax,%eax
80104aea:	74 39                	je     80104b25 <sys_open+0x123>
    ilock(ip);
80104aec:	83 ec 0c             	sub    $0xc,%esp
80104aef:	50                   	push   %eax
80104af0:	e8 dc ca ff ff       	call   801015d1 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104af5:	83 c4 10             	add    $0x10,%esp
80104af8:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104afd:	0f 85 6a ff ff ff    	jne    80104a6d <sys_open+0x6b>
80104b03:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104b07:	0f 84 60 ff ff ff    	je     80104a6d <sys_open+0x6b>
      iunlockput(ip);
80104b0d:	83 ec 0c             	sub    $0xc,%esp
80104b10:	56                   	push   %esi
80104b11:	e8 6e cc ff ff       	call   80101784 <iunlockput>
      end_op();
80104b16:	e8 ef dd ff ff       	call   8010290a <end_op>
      return -1;
80104b1b:	83 c4 10             	add    $0x10,%esp
80104b1e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104b23:	eb 96                	jmp    80104abb <sys_open+0xb9>
      end_op();
80104b25:	e8 e0 dd ff ff       	call   8010290a <end_op>
      return -1;
80104b2a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104b2f:	eb 8a                	jmp    80104abb <sys_open+0xb9>
    if(f)
80104b31:	85 db                	test   %ebx,%ebx
80104b33:	74 0c                	je     80104b41 <sys_open+0x13f>
      fileclose(f);
80104b35:	83 ec 0c             	sub    $0xc,%esp
80104b38:	53                   	push   %ebx
80104b39:	e8 ce c1 ff ff       	call   80100d0c <fileclose>
80104b3e:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104b41:	83 ec 0c             	sub    $0xc,%esp
80104b44:	56                   	push   %esi
80104b45:	e8 3a cc ff ff       	call   80101784 <iunlockput>
    end_op();
80104b4a:	e8 bb dd ff ff       	call   8010290a <end_op>
    return -1;
80104b4f:	83 c4 10             	add    $0x10,%esp
80104b52:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104b57:	e9 5f ff ff ff       	jmp    80104abb <sys_open+0xb9>

80104b5c <sys_mkdir>:

int
sys_mkdir(void)
{
80104b5c:	f3 0f 1e fb          	endbr32 
80104b60:	55                   	push   %ebp
80104b61:	89 e5                	mov    %esp,%ebp
80104b63:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104b66:	e8 21 dd ff ff       	call   8010288c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104b6b:	83 ec 08             	sub    $0x8,%esp
80104b6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b71:	50                   	push   %eax
80104b72:	6a 00                	push   $0x0
80104b74:	e8 d6 f6 ff ff       	call   8010424f <argstr>
80104b79:	83 c4 10             	add    $0x10,%esp
80104b7c:	85 c0                	test   %eax,%eax
80104b7e:	78 36                	js     80104bb6 <sys_mkdir+0x5a>
80104b80:	83 ec 0c             	sub    $0xc,%esp
80104b83:	6a 00                	push   $0x0
80104b85:	b9 00 00 00 00       	mov    $0x0,%ecx
80104b8a:	ba 01 00 00 00       	mov    $0x1,%edx
80104b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b92:	e8 38 f8 ff ff       	call   801043cf <create>
80104b97:	83 c4 10             	add    $0x10,%esp
80104b9a:	85 c0                	test   %eax,%eax
80104b9c:	74 18                	je     80104bb6 <sys_mkdir+0x5a>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104b9e:	83 ec 0c             	sub    $0xc,%esp
80104ba1:	50                   	push   %eax
80104ba2:	e8 dd cb ff ff       	call   80101784 <iunlockput>
  end_op();
80104ba7:	e8 5e dd ff ff       	call   8010290a <end_op>
  return 0;
80104bac:	83 c4 10             	add    $0x10,%esp
80104baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bb4:	c9                   	leave  
80104bb5:	c3                   	ret    
    end_op();
80104bb6:	e8 4f dd ff ff       	call   8010290a <end_op>
    return -1;
80104bbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bc0:	eb f2                	jmp    80104bb4 <sys_mkdir+0x58>

80104bc2 <sys_mknod>:

int
sys_mknod(void)
{
80104bc2:	f3 0f 1e fb          	endbr32 
80104bc6:	55                   	push   %ebp
80104bc7:	89 e5                	mov    %esp,%ebp
80104bc9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104bcc:	e8 bb dc ff ff       	call   8010288c <begin_op>
  if((argstr(0, &path)) < 0 ||
80104bd1:	83 ec 08             	sub    $0x8,%esp
80104bd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bd7:	50                   	push   %eax
80104bd8:	6a 00                	push   $0x0
80104bda:	e8 70 f6 ff ff       	call   8010424f <argstr>
80104bdf:	83 c4 10             	add    $0x10,%esp
80104be2:	85 c0                	test   %eax,%eax
80104be4:	78 62                	js     80104c48 <sys_mknod+0x86>
     argint(1, &major) < 0 ||
80104be6:	83 ec 08             	sub    $0x8,%esp
80104be9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104bec:	50                   	push   %eax
80104bed:	6a 01                	push   $0x1
80104bef:	e8 c3 f5 ff ff       	call   801041b7 <argint>
  if((argstr(0, &path)) < 0 ||
80104bf4:	83 c4 10             	add    $0x10,%esp
80104bf7:	85 c0                	test   %eax,%eax
80104bf9:	78 4d                	js     80104c48 <sys_mknod+0x86>
     argint(2, &minor) < 0 ||
80104bfb:	83 ec 08             	sub    $0x8,%esp
80104bfe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c01:	50                   	push   %eax
80104c02:	6a 02                	push   $0x2
80104c04:	e8 ae f5 ff ff       	call   801041b7 <argint>
     argint(1, &major) < 0 ||
80104c09:	83 c4 10             	add    $0x10,%esp
80104c0c:	85 c0                	test   %eax,%eax
80104c0e:	78 38                	js     80104c48 <sys_mknod+0x86>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104c10:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104c14:	83 ec 0c             	sub    $0xc,%esp
80104c17:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104c1b:	50                   	push   %eax
80104c1c:	ba 03 00 00 00       	mov    $0x3,%edx
80104c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c24:	e8 a6 f7 ff ff       	call   801043cf <create>
     argint(2, &minor) < 0 ||
80104c29:	83 c4 10             	add    $0x10,%esp
80104c2c:	85 c0                	test   %eax,%eax
80104c2e:	74 18                	je     80104c48 <sys_mknod+0x86>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104c30:	83 ec 0c             	sub    $0xc,%esp
80104c33:	50                   	push   %eax
80104c34:	e8 4b cb ff ff       	call   80101784 <iunlockput>
  end_op();
80104c39:	e8 cc dc ff ff       	call   8010290a <end_op>
  return 0;
80104c3e:	83 c4 10             	add    $0x10,%esp
80104c41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c46:	c9                   	leave  
80104c47:	c3                   	ret    
    end_op();
80104c48:	e8 bd dc ff ff       	call   8010290a <end_op>
    return -1;
80104c4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c52:	eb f2                	jmp    80104c46 <sys_mknod+0x84>

80104c54 <sys_chdir>:

int
sys_chdir(void)
{
80104c54:	f3 0f 1e fb          	endbr32 
80104c58:	55                   	push   %ebp
80104c59:	89 e5                	mov    %esp,%ebp
80104c5b:	56                   	push   %esi
80104c5c:	53                   	push   %ebx
80104c5d:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104c60:	e8 16 e7 ff ff       	call   8010337b <myproc>
80104c65:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104c67:	e8 20 dc ff ff       	call   8010288c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104c6c:	83 ec 08             	sub    $0x8,%esp
80104c6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c72:	50                   	push   %eax
80104c73:	6a 00                	push   $0x0
80104c75:	e8 d5 f5 ff ff       	call   8010424f <argstr>
80104c7a:	83 c4 10             	add    $0x10,%esp
80104c7d:	85 c0                	test   %eax,%eax
80104c7f:	78 52                	js     80104cd3 <sys_chdir+0x7f>
80104c81:	83 ec 0c             	sub    $0xc,%esp
80104c84:	ff 75 f4             	pushl  -0xc(%ebp)
80104c87:	e8 ca cf ff ff       	call   80101c56 <namei>
80104c8c:	89 c3                	mov    %eax,%ebx
80104c8e:	83 c4 10             	add    $0x10,%esp
80104c91:	85 c0                	test   %eax,%eax
80104c93:	74 3e                	je     80104cd3 <sys_chdir+0x7f>
    end_op();
    return -1;
  }
  ilock(ip);
80104c95:	83 ec 0c             	sub    $0xc,%esp
80104c98:	50                   	push   %eax
80104c99:	e8 33 c9 ff ff       	call   801015d1 <ilock>
  if(ip->type != T_DIR){
80104c9e:	83 c4 10             	add    $0x10,%esp
80104ca1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104ca6:	75 37                	jne    80104cdf <sys_chdir+0x8b>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104ca8:	83 ec 0c             	sub    $0xc,%esp
80104cab:	53                   	push   %ebx
80104cac:	e8 e6 c9 ff ff       	call   80101697 <iunlock>
  iput(curproc->cwd);
80104cb1:	83 c4 04             	add    $0x4,%esp
80104cb4:	ff 76 68             	pushl  0x68(%esi)
80104cb7:	e8 24 ca ff ff       	call   801016e0 <iput>
  end_op();
80104cbc:	e8 49 dc ff ff       	call   8010290a <end_op>
  curproc->cwd = ip;
80104cc1:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104cc4:	83 c4 10             	add    $0x10,%esp
80104cc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ccc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104ccf:	5b                   	pop    %ebx
80104cd0:	5e                   	pop    %esi
80104cd1:	5d                   	pop    %ebp
80104cd2:	c3                   	ret    
    end_op();
80104cd3:	e8 32 dc ff ff       	call   8010290a <end_op>
    return -1;
80104cd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cdd:	eb ed                	jmp    80104ccc <sys_chdir+0x78>
    iunlockput(ip);
80104cdf:	83 ec 0c             	sub    $0xc,%esp
80104ce2:	53                   	push   %ebx
80104ce3:	e8 9c ca ff ff       	call   80101784 <iunlockput>
    end_op();
80104ce8:	e8 1d dc ff ff       	call   8010290a <end_op>
    return -1;
80104ced:	83 c4 10             	add    $0x10,%esp
80104cf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cf5:	eb d5                	jmp    80104ccc <sys_chdir+0x78>

80104cf7 <sys_exec>:

int
sys_exec(void)
{
80104cf7:	f3 0f 1e fb          	endbr32 
80104cfb:	55                   	push   %ebp
80104cfc:	89 e5                	mov    %esp,%ebp
80104cfe:	53                   	push   %ebx
80104cff:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104d05:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d08:	50                   	push   %eax
80104d09:	6a 00                	push   $0x0
80104d0b:	e8 3f f5 ff ff       	call   8010424f <argstr>
80104d10:	83 c4 10             	add    $0x10,%esp
80104d13:	85 c0                	test   %eax,%eax
80104d15:	78 38                	js     80104d4f <sys_exec+0x58>
80104d17:	83 ec 08             	sub    $0x8,%esp
80104d1a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104d20:	50                   	push   %eax
80104d21:	6a 01                	push   $0x1
80104d23:	e8 8f f4 ff ff       	call   801041b7 <argint>
80104d28:	83 c4 10             	add    $0x10,%esp
80104d2b:	85 c0                	test   %eax,%eax
80104d2d:	78 20                	js     80104d4f <sys_exec+0x58>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104d2f:	83 ec 04             	sub    $0x4,%esp
80104d32:	68 80 00 00 00       	push   $0x80
80104d37:	6a 00                	push   $0x0
80104d39:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104d3f:	50                   	push   %eax
80104d40:	e8 fc f1 ff ff       	call   80103f41 <memset>
80104d45:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104d48:	bb 00 00 00 00       	mov    $0x0,%ebx
80104d4d:	eb 2c                	jmp    80104d7b <sys_exec+0x84>
    return -1;
80104d4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d54:	eb 78                	jmp    80104dce <sys_exec+0xd7>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104d56:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104d5d:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104d61:	83 ec 08             	sub    $0x8,%esp
80104d64:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104d6a:	50                   	push   %eax
80104d6b:	ff 75 f4             	pushl  -0xc(%ebp)
80104d6e:	e8 89 bb ff ff       	call   801008fc <exec>
80104d73:	83 c4 10             	add    $0x10,%esp
80104d76:	eb 56                	jmp    80104dce <sys_exec+0xd7>
  for(i=0;; i++){
80104d78:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104d7b:	83 fb 1f             	cmp    $0x1f,%ebx
80104d7e:	77 49                	ja     80104dc9 <sys_exec+0xd2>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104d80:	83 ec 08             	sub    $0x8,%esp
80104d83:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104d89:	50                   	push   %eax
80104d8a:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104d90:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104d93:	50                   	push   %eax
80104d94:	e8 9a f3 ff ff       	call   80104133 <fetchint>
80104d99:	83 c4 10             	add    $0x10,%esp
80104d9c:	85 c0                	test   %eax,%eax
80104d9e:	78 33                	js     80104dd3 <sys_exec+0xdc>
    if(uarg == 0){
80104da0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104da6:	85 c0                	test   %eax,%eax
80104da8:	74 ac                	je     80104d56 <sys_exec+0x5f>
    if(fetchstr(uarg, &argv[i]) < 0)
80104daa:	83 ec 08             	sub    $0x8,%esp
80104dad:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104db4:	52                   	push   %edx
80104db5:	50                   	push   %eax
80104db6:	e8 b8 f3 ff ff       	call   80104173 <fetchstr>
80104dbb:	83 c4 10             	add    $0x10,%esp
80104dbe:	85 c0                	test   %eax,%eax
80104dc0:	79 b6                	jns    80104d78 <sys_exec+0x81>
      return -1;
80104dc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dc7:	eb 05                	jmp    80104dce <sys_exec+0xd7>
      return -1;
80104dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104dd1:	c9                   	leave  
80104dd2:	c3                   	ret    
      return -1;
80104dd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd8:	eb f4                	jmp    80104dce <sys_exec+0xd7>

80104dda <sys_pipe>:

int
sys_pipe(void)
{
80104dda:	f3 0f 1e fb          	endbr32 
80104dde:	55                   	push   %ebp
80104ddf:	89 e5                	mov    %esp,%ebp
80104de1:	53                   	push   %ebx
80104de2:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104de5:	6a 08                	push   $0x8
80104de7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dea:	50                   	push   %eax
80104deb:	6a 00                	push   $0x0
80104ded:	e8 f1 f3 ff ff       	call   801041e3 <argptr>
80104df2:	83 c4 10             	add    $0x10,%esp
80104df5:	85 c0                	test   %eax,%eax
80104df7:	78 79                	js     80104e72 <sys_pipe+0x98>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104df9:	83 ec 08             	sub    $0x8,%esp
80104dfc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104dff:	50                   	push   %eax
80104e00:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e03:	50                   	push   %eax
80104e04:	e8 6f e0 ff ff       	call   80102e78 <pipealloc>
80104e09:	83 c4 10             	add    $0x10,%esp
80104e0c:	85 c0                	test   %eax,%eax
80104e0e:	78 69                	js     80104e79 <sys_pipe+0x9f>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e13:	e8 29 f5 ff ff       	call   80104341 <fdalloc>
80104e18:	89 c3                	mov    %eax,%ebx
80104e1a:	85 c0                	test   %eax,%eax
80104e1c:	78 21                	js     80104e3f <sys_pipe+0x65>
80104e1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e21:	e8 1b f5 ff ff       	call   80104341 <fdalloc>
80104e26:	85 c0                	test   %eax,%eax
80104e28:	78 15                	js     80104e3f <sys_pipe+0x65>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e2d:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104e2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e32:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104e35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e3d:	c9                   	leave  
80104e3e:	c3                   	ret    
    if(fd0 >= 0)
80104e3f:	85 db                	test   %ebx,%ebx
80104e41:	79 20                	jns    80104e63 <sys_pipe+0x89>
    fileclose(rf);
80104e43:	83 ec 0c             	sub    $0xc,%esp
80104e46:	ff 75 f0             	pushl  -0x10(%ebp)
80104e49:	e8 be be ff ff       	call   80100d0c <fileclose>
    fileclose(wf);
80104e4e:	83 c4 04             	add    $0x4,%esp
80104e51:	ff 75 ec             	pushl  -0x14(%ebp)
80104e54:	e8 b3 be ff ff       	call   80100d0c <fileclose>
    return -1;
80104e59:	83 c4 10             	add    $0x10,%esp
80104e5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e61:	eb d7                	jmp    80104e3a <sys_pipe+0x60>
      myproc()->ofile[fd0] = 0;
80104e63:	e8 13 e5 ff ff       	call   8010337b <myproc>
80104e68:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104e6f:	00 
80104e70:	eb d1                	jmp    80104e43 <sys_pipe+0x69>
    return -1;
80104e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e77:	eb c1                	jmp    80104e3a <sys_pipe+0x60>
    return -1;
80104e79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e7e:	eb ba                	jmp    80104e3a <sys_pipe+0x60>

80104e80 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104e80:	f3 0f 1e fb          	endbr32 
80104e84:	55                   	push   %ebp
80104e85:	89 e5                	mov    %esp,%ebp
80104e87:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104e8a:	e8 6f e6 ff ff       	call   801034fe <fork>
}
80104e8f:	c9                   	leave  
80104e90:	c3                   	ret    

80104e91 <sys_exit>:

int
sys_exit(void)
{
80104e91:	f3 0f 1e fb          	endbr32 
80104e95:	55                   	push   %ebp
80104e96:	89 e5                	mov    %esp,%ebp
80104e98:	83 ec 08             	sub    $0x8,%esp
  exit();
80104e9b:	e8 c6 e8 ff ff       	call   80103766 <exit>
  return 0;  // not reached
}
80104ea0:	b8 00 00 00 00       	mov    $0x0,%eax
80104ea5:	c9                   	leave  
80104ea6:	c3                   	ret    

80104ea7 <sys_wait>:

int
sys_wait(void)
{
80104ea7:	f3 0f 1e fb          	endbr32 
80104eab:	55                   	push   %ebp
80104eac:	89 e5                	mov    %esp,%ebp
80104eae:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104eb1:	e8 45 ea ff ff       	call   801038fb <wait>
}
80104eb6:	c9                   	leave  
80104eb7:	c3                   	ret    

80104eb8 <sys_kill>:

int
sys_kill(void)
{
80104eb8:	f3 0f 1e fb          	endbr32 
80104ebc:	55                   	push   %ebp
80104ebd:	89 e5                	mov    %esp,%ebp
80104ebf:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104ec2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ec5:	50                   	push   %eax
80104ec6:	6a 00                	push   $0x0
80104ec8:	e8 ea f2 ff ff       	call   801041b7 <argint>
80104ecd:	83 c4 10             	add    $0x10,%esp
80104ed0:	85 c0                	test   %eax,%eax
80104ed2:	78 10                	js     80104ee4 <sys_kill+0x2c>
    return -1;
  return kill(pid);
80104ed4:	83 ec 0c             	sub    $0xc,%esp
80104ed7:	ff 75 f4             	pushl  -0xc(%ebp)
80104eda:	e8 21 eb ff ff       	call   80103a00 <kill>
80104edf:	83 c4 10             	add    $0x10,%esp
}
80104ee2:	c9                   	leave  
80104ee3:	c3                   	ret    
    return -1;
80104ee4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee9:	eb f7                	jmp    80104ee2 <sys_kill+0x2a>

80104eeb <sys_getpid>:

int
sys_getpid(void)
{
80104eeb:	f3 0f 1e fb          	endbr32 
80104eef:	55                   	push   %ebp
80104ef0:	89 e5                	mov    %esp,%ebp
80104ef2:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104ef5:	e8 81 e4 ff ff       	call   8010337b <myproc>
80104efa:	8b 40 10             	mov    0x10(%eax),%eax
}
80104efd:	c9                   	leave  
80104efe:	c3                   	ret    

80104eff <sys_sbrk>:

int
sys_sbrk(void)
{
80104eff:	f3 0f 1e fb          	endbr32 
80104f03:	55                   	push   %ebp
80104f04:	89 e5                	mov    %esp,%ebp
80104f06:	53                   	push   %ebx
80104f07:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f0d:	50                   	push   %eax
80104f0e:	6a 00                	push   $0x0
80104f10:	e8 a2 f2 ff ff       	call   801041b7 <argint>
80104f15:	83 c4 10             	add    $0x10,%esp
80104f18:	85 c0                	test   %eax,%eax
80104f1a:	78 20                	js     80104f3c <sys_sbrk+0x3d>
    return -1;
  addr = myproc()->sz;
80104f1c:	e8 5a e4 ff ff       	call   8010337b <myproc>
80104f21:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104f23:	83 ec 0c             	sub    $0xc,%esp
80104f26:	ff 75 f4             	pushl  -0xc(%ebp)
80104f29:	e8 61 e5 ff ff       	call   8010348f <growproc>
80104f2e:	83 c4 10             	add    $0x10,%esp
80104f31:	85 c0                	test   %eax,%eax
80104f33:	78 0e                	js     80104f43 <sys_sbrk+0x44>
    return -1;
  return addr;
}
80104f35:	89 d8                	mov    %ebx,%eax
80104f37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f3a:	c9                   	leave  
80104f3b:	c3                   	ret    
    return -1;
80104f3c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104f41:	eb f2                	jmp    80104f35 <sys_sbrk+0x36>
    return -1;
80104f43:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104f48:	eb eb                	jmp    80104f35 <sys_sbrk+0x36>

80104f4a <sys_sleep>:

int
sys_sleep(void)
{
80104f4a:	f3 0f 1e fb          	endbr32 
80104f4e:	55                   	push   %ebp
80104f4f:	89 e5                	mov    %esp,%ebp
80104f51:	53                   	push   %ebx
80104f52:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104f55:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f58:	50                   	push   %eax
80104f59:	6a 00                	push   $0x0
80104f5b:	e8 57 f2 ff ff       	call   801041b7 <argint>
80104f60:	83 c4 10             	add    $0x10,%esp
80104f63:	85 c0                	test   %eax,%eax
80104f65:	78 75                	js     80104fdc <sys_sleep+0x92>
    return -1;
  acquire(&tickslock);
80104f67:	83 ec 0c             	sub    $0xc,%esp
80104f6a:	68 60 4d 11 80       	push   $0x80114d60
80104f6f:	e8 19 ef ff ff       	call   80103e8d <acquire>
  ticks0 = ticks;
80104f74:	8b 1d a0 55 11 80    	mov    0x801155a0,%ebx
  while(ticks - ticks0 < n){
80104f7a:	83 c4 10             	add    $0x10,%esp
80104f7d:	a1 a0 55 11 80       	mov    0x801155a0,%eax
80104f82:	29 d8                	sub    %ebx,%eax
80104f84:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104f87:	73 39                	jae    80104fc2 <sys_sleep+0x78>
    if(myproc()->killed){
80104f89:	e8 ed e3 ff ff       	call   8010337b <myproc>
80104f8e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f92:	75 17                	jne    80104fab <sys_sleep+0x61>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104f94:	83 ec 08             	sub    $0x8,%esp
80104f97:	68 60 4d 11 80       	push   $0x80114d60
80104f9c:	68 a0 55 11 80       	push   $0x801155a0
80104fa1:	e8 c0 e8 ff ff       	call   80103866 <sleep>
80104fa6:	83 c4 10             	add    $0x10,%esp
80104fa9:	eb d2                	jmp    80104f7d <sys_sleep+0x33>
      release(&tickslock);
80104fab:	83 ec 0c             	sub    $0xc,%esp
80104fae:	68 60 4d 11 80       	push   $0x80114d60
80104fb3:	e8 3e ef ff ff       	call   80103ef6 <release>
      return -1;
80104fb8:	83 c4 10             	add    $0x10,%esp
80104fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc0:	eb 15                	jmp    80104fd7 <sys_sleep+0x8d>
  }
  release(&tickslock);
80104fc2:	83 ec 0c             	sub    $0xc,%esp
80104fc5:	68 60 4d 11 80       	push   $0x80114d60
80104fca:	e8 27 ef ff ff       	call   80103ef6 <release>
  return 0;
80104fcf:	83 c4 10             	add    $0x10,%esp
80104fd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104fda:	c9                   	leave  
80104fdb:	c3                   	ret    
    return -1;
80104fdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fe1:	eb f4                	jmp    80104fd7 <sys_sleep+0x8d>

80104fe3 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104fe3:	f3 0f 1e fb          	endbr32 
80104fe7:	55                   	push   %ebp
80104fe8:	89 e5                	mov    %esp,%ebp
80104fea:	53                   	push   %ebx
80104feb:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104fee:	68 60 4d 11 80       	push   $0x80114d60
80104ff3:	e8 95 ee ff ff       	call   80103e8d <acquire>
  xticks = ticks;
80104ff8:	8b 1d a0 55 11 80    	mov    0x801155a0,%ebx
  release(&tickslock);
80104ffe:	c7 04 24 60 4d 11 80 	movl   $0x80114d60,(%esp)
80105005:	e8 ec ee ff ff       	call   80103ef6 <release>
  return xticks;
}
8010500a:	89 d8                	mov    %ebx,%eax
8010500c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010500f:	c9                   	leave  
80105010:	c3                   	ret    

80105011 <sys_yield>:

int
sys_yield(void)
{
80105011:	f3 0f 1e fb          	endbr32 
80105015:	55                   	push   %ebp
80105016:	89 e5                	mov    %esp,%ebp
80105018:	83 ec 08             	sub    $0x8,%esp
  yield();
8010501b:	e8 10 e8 ff ff       	call   80103830 <yield>
  return 0;
}
80105020:	b8 00 00 00 00       	mov    $0x0,%eax
80105025:	c9                   	leave  
80105026:	c3                   	ret    

80105027 <sys_shutdown>:

int sys_shutdown(void)
{
80105027:	f3 0f 1e fb          	endbr32 
8010502b:	55                   	push   %ebp
8010502c:	89 e5                	mov    %esp,%ebp
8010502e:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80105031:	e8 80 d2 ff ff       	call   801022b6 <shutdown>
  return 0;
}
80105036:	b8 00 00 00 00       	mov    $0x0,%eax
8010503b:	c9                   	leave  
8010503c:	c3                   	ret    

8010503d <sys_nice>:

int sys_nice(void)
{
8010503d:	f3 0f 1e fb          	endbr32 
80105041:	55                   	push   %ebp
80105042:	89 e5                	mov    %esp,%ebp
80105044:	83 ec 20             	sub    $0x20,%esp
  int pid;
  int prio;
  if(argint(0, &pid) < 0)
80105047:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010504a:	50                   	push   %eax
8010504b:	6a 00                	push   $0x0
8010504d:	e8 65 f1 ff ff       	call   801041b7 <argint>
80105052:	83 c4 10             	add    $0x10,%esp
80105055:	85 c0                	test   %eax,%eax
80105057:	78 28                	js     80105081 <sys_nice+0x44>
  {
    return -1;
  }
  if(argint(1, &prio) < 0)
80105059:	83 ec 08             	sub    $0x8,%esp
8010505c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010505f:	50                   	push   %eax
80105060:	6a 01                	push   $0x1
80105062:	e8 50 f1 ff ff       	call   801041b7 <argint>
80105067:	83 c4 10             	add    $0x10,%esp
8010506a:	85 c0                	test   %eax,%eax
8010506c:	78 1a                	js     80105088 <sys_nice+0x4b>
  {
    return -1;
  }

  return nice(pid, prio);
8010506e:	83 ec 08             	sub    $0x8,%esp
80105071:	ff 75 f0             	pushl  -0x10(%ebp)
80105074:	ff 75 f4             	pushl  -0xc(%ebp)
80105077:	e8 b2 ea ff ff       	call   80103b2e <nice>
8010507c:	83 c4 10             	add    $0x10,%esp
}
8010507f:	c9                   	leave  
80105080:	c3                   	ret    
    return -1;
80105081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105086:	eb f7                	jmp    8010507f <sys_nice+0x42>
    return -1;
80105088:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010508d:	eb f0                	jmp    8010507f <sys_nice+0x42>

8010508f <sys_cps>:

int sys_cps(void)
{
8010508f:	f3 0f 1e fb          	endbr32 
80105093:	55                   	push   %ebp
80105094:	89 e5                	mov    %esp,%ebp
80105096:	83 ec 08             	sub    $0x8,%esp
  return cps();
80105099:	e8 db ea ff ff       	call   80103b79 <cps>
8010509e:	c9                   	leave  
8010509f:	c3                   	ret    

801050a0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801050a0:	1e                   	push   %ds
  pushl %es
801050a1:	06                   	push   %es
  pushl %fs
801050a2:	0f a0                	push   %fs
  pushl %gs
801050a4:	0f a8                	push   %gs
  pushal
801050a6:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801050a7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801050ab:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801050ad:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801050af:	54                   	push   %esp
  call trap
801050b0:	e8 eb 00 00 00       	call   801051a0 <trap>
  addl $4, %esp
801050b5:	83 c4 04             	add    $0x4,%esp

801050b8 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801050b8:	61                   	popa   
  popl %gs
801050b9:	0f a9                	pop    %gs
  popl %fs
801050bb:	0f a1                	pop    %fs
  popl %es
801050bd:	07                   	pop    %es
  popl %ds
801050be:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801050bf:	83 c4 08             	add    $0x8,%esp
  iret
801050c2:	cf                   	iret   

801050c3 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801050c3:	f3 0f 1e fb          	endbr32 
801050c7:	55                   	push   %ebp
801050c8:	89 e5                	mov    %esp,%ebp
801050ca:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
801050cd:	b8 00 00 00 00       	mov    $0x0,%eax
801050d2:	3d ff 00 00 00       	cmp    $0xff,%eax
801050d7:	7f 4c                	jg     80105125 <tvinit+0x62>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801050d9:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
801050e0:	66 89 0c c5 a0 4d 11 	mov    %cx,-0x7feeb260(,%eax,8)
801050e7:	80 
801050e8:	66 c7 04 c5 a2 4d 11 	movw   $0x8,-0x7feeb25e(,%eax,8)
801050ef:	80 08 00 
801050f2:	c6 04 c5 a4 4d 11 80 	movb   $0x0,-0x7feeb25c(,%eax,8)
801050f9:	00 
801050fa:	0f b6 14 c5 a5 4d 11 	movzbl -0x7feeb25b(,%eax,8),%edx
80105101:	80 
80105102:	83 e2 f0             	and    $0xfffffff0,%edx
80105105:	83 ca 0e             	or     $0xe,%edx
80105108:	83 e2 8f             	and    $0xffffff8f,%edx
8010510b:	83 ca 80             	or     $0xffffff80,%edx
8010510e:	88 14 c5 a5 4d 11 80 	mov    %dl,-0x7feeb25b(,%eax,8)
80105115:	c1 e9 10             	shr    $0x10,%ecx
80105118:	66 89 0c c5 a6 4d 11 	mov    %cx,-0x7feeb25a(,%eax,8)
8010511f:	80 
  for(i = 0; i < 256; i++)
80105120:	83 c0 01             	add    $0x1,%eax
80105123:	eb ad                	jmp    801050d2 <tvinit+0xf>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105125:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
8010512b:	66 89 15 a0 4f 11 80 	mov    %dx,0x80114fa0
80105132:	66 c7 05 a2 4f 11 80 	movw   $0x8,0x80114fa2
80105139:	08 00 
8010513b:	c6 05 a4 4f 11 80 00 	movb   $0x0,0x80114fa4
80105142:	0f b6 05 a5 4f 11 80 	movzbl 0x80114fa5,%eax
80105149:	83 c8 0f             	or     $0xf,%eax
8010514c:	83 e0 ef             	and    $0xffffffef,%eax
8010514f:	83 c8 e0             	or     $0xffffffe0,%eax
80105152:	a2 a5 4f 11 80       	mov    %al,0x80114fa5
80105157:	c1 ea 10             	shr    $0x10,%edx
8010515a:	66 89 15 a6 4f 11 80 	mov    %dx,0x80114fa6

  initlock(&tickslock, "time");
80105161:	83 ec 08             	sub    $0x8,%esp
80105164:	68 09 77 10 80       	push   $0x80107709
80105169:	68 60 4d 11 80       	push   $0x80114d60
8010516e:	e8 ca eb ff ff       	call   80103d3d <initlock>
}
80105173:	83 c4 10             	add    $0x10,%esp
80105176:	c9                   	leave  
80105177:	c3                   	ret    

80105178 <idtinit>:

void
idtinit(void)
{
80105178:	f3 0f 1e fb          	endbr32 
8010517c:	55                   	push   %ebp
8010517d:	89 e5                	mov    %esp,%ebp
8010517f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105182:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105188:	b8 a0 4d 11 80       	mov    $0x80114da0,%eax
8010518d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105191:	c1 e8 10             	shr    $0x10,%eax
80105194:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105198:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010519b:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
8010519e:	c9                   	leave  
8010519f:	c3                   	ret    

801051a0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801051a0:	f3 0f 1e fb          	endbr32 
801051a4:	55                   	push   %ebp
801051a5:	89 e5                	mov    %esp,%ebp
801051a7:	57                   	push   %edi
801051a8:	56                   	push   %esi
801051a9:	53                   	push   %ebx
801051aa:	83 ec 1c             	sub    $0x1c,%esp
801051ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
801051b0:	8b 43 30             	mov    0x30(%ebx),%eax
801051b3:	83 f8 40             	cmp    $0x40,%eax
801051b6:	74 14                	je     801051cc <trap+0x2c>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
801051b8:	83 e8 20             	sub    $0x20,%eax
801051bb:	83 f8 1f             	cmp    $0x1f,%eax
801051be:	0f 87 3b 01 00 00    	ja     801052ff <trap+0x15f>
801051c4:	3e ff 24 85 b0 77 10 	notrack jmp *-0x7fef8850(,%eax,4)
801051cb:	80 
    if(myproc()->killed)
801051cc:	e8 aa e1 ff ff       	call   8010337b <myproc>
801051d1:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801051d5:	75 1f                	jne    801051f6 <trap+0x56>
    myproc()->tf = tf;
801051d7:	e8 9f e1 ff ff       	call   8010337b <myproc>
801051dc:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
801051df:	e8 a2 f0 ff ff       	call   80104286 <syscall>
    if(myproc()->killed)
801051e4:	e8 92 e1 ff ff       	call   8010337b <myproc>
801051e9:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801051ed:	74 7e                	je     8010526d <trap+0xcd>
      exit();
801051ef:	e8 72 e5 ff ff       	call   80103766 <exit>
    return;
801051f4:	eb 77                	jmp    8010526d <trap+0xcd>
      exit();
801051f6:	e8 6b e5 ff ff       	call   80103766 <exit>
801051fb:	eb da                	jmp    801051d7 <trap+0x37>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801051fd:	e8 5a e1 ff ff       	call   8010335c <cpuid>
80105202:	85 c0                	test   %eax,%eax
80105204:	74 6f                	je     80105275 <trap+0xd5>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105206:	e8 65 d2 ff ff       	call   80102470 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010520b:	e8 6b e1 ff ff       	call   8010337b <myproc>
80105210:	85 c0                	test   %eax,%eax
80105212:	74 1c                	je     80105230 <trap+0x90>
80105214:	e8 62 e1 ff ff       	call   8010337b <myproc>
80105219:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010521d:	74 11                	je     80105230 <trap+0x90>
8010521f:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105223:	83 e0 03             	and    $0x3,%eax
80105226:	66 83 f8 03          	cmp    $0x3,%ax
8010522a:	0f 84 62 01 00 00    	je     80105392 <trap+0x1f2>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105230:	e8 46 e1 ff ff       	call   8010337b <myproc>
80105235:	85 c0                	test   %eax,%eax
80105237:	74 0f                	je     80105248 <trap+0xa8>
80105239:	e8 3d e1 ff ff       	call   8010337b <myproc>
8010523e:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105242:	0f 84 54 01 00 00    	je     8010539c <trap+0x1fc>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105248:	e8 2e e1 ff ff       	call   8010337b <myproc>
8010524d:	85 c0                	test   %eax,%eax
8010524f:	74 1c                	je     8010526d <trap+0xcd>
80105251:	e8 25 e1 ff ff       	call   8010337b <myproc>
80105256:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010525a:	74 11                	je     8010526d <trap+0xcd>
8010525c:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105260:	83 e0 03             	and    $0x3,%eax
80105263:	66 83 f8 03          	cmp    $0x3,%ax
80105267:	0f 84 43 01 00 00    	je     801053b0 <trap+0x210>
    exit();
}
8010526d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105270:	5b                   	pop    %ebx
80105271:	5e                   	pop    %esi
80105272:	5f                   	pop    %edi
80105273:	5d                   	pop    %ebp
80105274:	c3                   	ret    
      acquire(&tickslock);
80105275:	83 ec 0c             	sub    $0xc,%esp
80105278:	68 60 4d 11 80       	push   $0x80114d60
8010527d:	e8 0b ec ff ff       	call   80103e8d <acquire>
      ticks++;
80105282:	83 05 a0 55 11 80 01 	addl   $0x1,0x801155a0
      wakeup(&ticks);
80105289:	c7 04 24 a0 55 11 80 	movl   $0x801155a0,(%esp)
80105290:	e8 3e e7 ff ff       	call   801039d3 <wakeup>
      release(&tickslock);
80105295:	c7 04 24 60 4d 11 80 	movl   $0x80114d60,(%esp)
8010529c:	e8 55 ec ff ff       	call   80103ef6 <release>
801052a1:	83 c4 10             	add    $0x10,%esp
801052a4:	e9 5d ff ff ff       	jmp    80105206 <trap+0x66>
    ideintr();
801052a9:	e8 45 cb ff ff       	call   80101df3 <ideintr>
    lapiceoi();
801052ae:	e8 bd d1 ff ff       	call   80102470 <lapiceoi>
    break;
801052b3:	e9 53 ff ff ff       	jmp    8010520b <trap+0x6b>
    kbdintr();
801052b8:	e8 e0 cf ff ff       	call   8010229d <kbdintr>
    lapiceoi();
801052bd:	e8 ae d1 ff ff       	call   80102470 <lapiceoi>
    break;
801052c2:	e9 44 ff ff ff       	jmp    8010520b <trap+0x6b>
    uartintr();
801052c7:	e8 0a 02 00 00       	call   801054d6 <uartintr>
    lapiceoi();
801052cc:	e8 9f d1 ff ff       	call   80102470 <lapiceoi>
    break;
801052d1:	e9 35 ff ff ff       	jmp    8010520b <trap+0x6b>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801052d6:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801052d9:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801052dd:	e8 7a e0 ff ff       	call   8010335c <cpuid>
801052e2:	57                   	push   %edi
801052e3:	0f b7 f6             	movzwl %si,%esi
801052e6:	56                   	push   %esi
801052e7:	50                   	push   %eax
801052e8:	68 14 77 10 80       	push   $0x80107714
801052ed:	e8 37 b3 ff ff       	call   80100629 <cprintf>
    lapiceoi();
801052f2:	e8 79 d1 ff ff       	call   80102470 <lapiceoi>
    break;
801052f7:	83 c4 10             	add    $0x10,%esp
801052fa:	e9 0c ff ff ff       	jmp    8010520b <trap+0x6b>
    if(myproc() == 0 || (tf->cs&3) == 0){
801052ff:	e8 77 e0 ff ff       	call   8010337b <myproc>
80105304:	85 c0                	test   %eax,%eax
80105306:	74 5f                	je     80105367 <trap+0x1c7>
80105308:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010530c:	74 59                	je     80105367 <trap+0x1c7>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010530e:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105311:	8b 43 38             	mov    0x38(%ebx),%eax
80105314:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105317:	e8 40 e0 ff ff       	call   8010335c <cpuid>
8010531c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010531f:	8b 53 34             	mov    0x34(%ebx),%edx
80105322:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105325:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105328:	e8 4e e0 ff ff       	call   8010337b <myproc>
8010532d:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105330:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105333:	e8 43 e0 ff ff       	call   8010337b <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105338:	57                   	push   %edi
80105339:	ff 75 e4             	pushl  -0x1c(%ebp)
8010533c:	ff 75 e0             	pushl  -0x20(%ebp)
8010533f:	ff 75 dc             	pushl  -0x24(%ebp)
80105342:	56                   	push   %esi
80105343:	ff 75 d8             	pushl  -0x28(%ebp)
80105346:	ff 70 10             	pushl  0x10(%eax)
80105349:	68 6c 77 10 80       	push   $0x8010776c
8010534e:	e8 d6 b2 ff ff       	call   80100629 <cprintf>
    myproc()->killed = 1;
80105353:	83 c4 20             	add    $0x20,%esp
80105356:	e8 20 e0 ff ff       	call   8010337b <myproc>
8010535b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105362:	e9 a4 fe ff ff       	jmp    8010520b <trap+0x6b>
80105367:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010536a:	8b 73 38             	mov    0x38(%ebx),%esi
8010536d:	e8 ea df ff ff       	call   8010335c <cpuid>
80105372:	83 ec 0c             	sub    $0xc,%esp
80105375:	57                   	push   %edi
80105376:	56                   	push   %esi
80105377:	50                   	push   %eax
80105378:	ff 73 30             	pushl  0x30(%ebx)
8010537b:	68 38 77 10 80       	push   $0x80107738
80105380:	e8 a4 b2 ff ff       	call   80100629 <cprintf>
      panic("trap");
80105385:	83 c4 14             	add    $0x14,%esp
80105388:	68 0e 77 10 80       	push   $0x8010770e
8010538d:	e8 ca af ff ff       	call   8010035c <panic>
    exit();
80105392:	e8 cf e3 ff ff       	call   80103766 <exit>
80105397:	e9 94 fe ff ff       	jmp    80105230 <trap+0x90>
  if(myproc() && myproc()->state == RUNNING &&
8010539c:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801053a0:	0f 85 a2 fe ff ff    	jne    80105248 <trap+0xa8>
    yield();
801053a6:	e8 85 e4 ff ff       	call   80103830 <yield>
801053ab:	e9 98 fe ff ff       	jmp    80105248 <trap+0xa8>
    exit();
801053b0:	e8 b1 e3 ff ff       	call   80103766 <exit>
801053b5:	e9 b3 fe ff ff       	jmp    8010526d <trap+0xcd>

801053ba <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801053ba:	f3 0f 1e fb          	endbr32 
  if(!uart)
801053be:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801053c5:	74 14                	je     801053db <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801053c7:	ba fd 03 00 00       	mov    $0x3fd,%edx
801053cc:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801053cd:	a8 01                	test   $0x1,%al
801053cf:	74 10                	je     801053e1 <uartgetc+0x27>
801053d1:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053d6:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801053d7:	0f b6 c0             	movzbl %al,%eax
801053da:	c3                   	ret    
    return -1;
801053db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e0:	c3                   	ret    
    return -1;
801053e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053e6:	c3                   	ret    

801053e7 <uartputc>:
{
801053e7:	f3 0f 1e fb          	endbr32 
  if(!uart)
801053eb:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801053f2:	74 3b                	je     8010542f <uartputc+0x48>
{
801053f4:	55                   	push   %ebp
801053f5:	89 e5                	mov    %esp,%ebp
801053f7:	53                   	push   %ebx
801053f8:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801053fb:	bb 00 00 00 00       	mov    $0x0,%ebx
80105400:	83 fb 7f             	cmp    $0x7f,%ebx
80105403:	7f 1c                	jg     80105421 <uartputc+0x3a>
80105405:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010540a:	ec                   	in     (%dx),%al
8010540b:	a8 20                	test   $0x20,%al
8010540d:	75 12                	jne    80105421 <uartputc+0x3a>
    microdelay(10);
8010540f:	83 ec 0c             	sub    $0xc,%esp
80105412:	6a 0a                	push   $0xa
80105414:	e8 7c d0 ff ff       	call   80102495 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105419:	83 c3 01             	add    $0x1,%ebx
8010541c:	83 c4 10             	add    $0x10,%esp
8010541f:	eb df                	jmp    80105400 <uartputc+0x19>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105421:	8b 45 08             	mov    0x8(%ebp),%eax
80105424:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105429:	ee                   	out    %al,(%dx)
}
8010542a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010542d:	c9                   	leave  
8010542e:	c3                   	ret    
8010542f:	c3                   	ret    

80105430 <uartinit>:
{
80105430:	f3 0f 1e fb          	endbr32 
80105434:	55                   	push   %ebp
80105435:	89 e5                	mov    %esp,%ebp
80105437:	56                   	push   %esi
80105438:	53                   	push   %ebx
80105439:	b9 00 00 00 00       	mov    $0x0,%ecx
8010543e:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105443:	89 c8                	mov    %ecx,%eax
80105445:	ee                   	out    %al,(%dx)
80105446:	be fb 03 00 00       	mov    $0x3fb,%esi
8010544b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105450:	89 f2                	mov    %esi,%edx
80105452:	ee                   	out    %al,(%dx)
80105453:	b8 0c 00 00 00       	mov    $0xc,%eax
80105458:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010545d:	ee                   	out    %al,(%dx)
8010545e:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105463:	89 c8                	mov    %ecx,%eax
80105465:	89 da                	mov    %ebx,%edx
80105467:	ee                   	out    %al,(%dx)
80105468:	b8 03 00 00 00       	mov    $0x3,%eax
8010546d:	89 f2                	mov    %esi,%edx
8010546f:	ee                   	out    %al,(%dx)
80105470:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105475:	89 c8                	mov    %ecx,%eax
80105477:	ee                   	out    %al,(%dx)
80105478:	b8 01 00 00 00       	mov    $0x1,%eax
8010547d:	89 da                	mov    %ebx,%edx
8010547f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105480:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105485:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105486:	3c ff                	cmp    $0xff,%al
80105488:	74 45                	je     801054cf <uartinit+0x9f>
  uart = 1;
8010548a:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
80105491:	00 00 00 
80105494:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105499:	ec                   	in     (%dx),%al
8010549a:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010549f:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801054a0:	83 ec 08             	sub    $0x8,%esp
801054a3:	6a 00                	push   $0x0
801054a5:	6a 04                	push   $0x4
801054a7:	e8 56 cb ff ff       	call   80102002 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801054ac:	83 c4 10             	add    $0x10,%esp
801054af:	bb 30 78 10 80       	mov    $0x80107830,%ebx
801054b4:	eb 12                	jmp    801054c8 <uartinit+0x98>
    uartputc(*p);
801054b6:	83 ec 0c             	sub    $0xc,%esp
801054b9:	0f be c0             	movsbl %al,%eax
801054bc:	50                   	push   %eax
801054bd:	e8 25 ff ff ff       	call   801053e7 <uartputc>
  for(p="xv6...\n"; *p; p++)
801054c2:	83 c3 01             	add    $0x1,%ebx
801054c5:	83 c4 10             	add    $0x10,%esp
801054c8:	0f b6 03             	movzbl (%ebx),%eax
801054cb:	84 c0                	test   %al,%al
801054cd:	75 e7                	jne    801054b6 <uartinit+0x86>
}
801054cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801054d2:	5b                   	pop    %ebx
801054d3:	5e                   	pop    %esi
801054d4:	5d                   	pop    %ebp
801054d5:	c3                   	ret    

801054d6 <uartintr>:

void
uartintr(void)
{
801054d6:	f3 0f 1e fb          	endbr32 
801054da:	55                   	push   %ebp
801054db:	89 e5                	mov    %esp,%ebp
801054dd:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801054e0:	68 ba 53 10 80       	push   $0x801053ba
801054e5:	e8 6f b2 ff ff       	call   80100759 <consoleintr>
}
801054ea:	83 c4 10             	add    $0x10,%esp
801054ed:	c9                   	leave  
801054ee:	c3                   	ret    

801054ef <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801054ef:	6a 00                	push   $0x0
  pushl $0
801054f1:	6a 00                	push   $0x0
  jmp alltraps
801054f3:	e9 a8 fb ff ff       	jmp    801050a0 <alltraps>

801054f8 <vector1>:
.globl vector1
vector1:
  pushl $0
801054f8:	6a 00                	push   $0x0
  pushl $1
801054fa:	6a 01                	push   $0x1
  jmp alltraps
801054fc:	e9 9f fb ff ff       	jmp    801050a0 <alltraps>

80105501 <vector2>:
.globl vector2
vector2:
  pushl $0
80105501:	6a 00                	push   $0x0
  pushl $2
80105503:	6a 02                	push   $0x2
  jmp alltraps
80105505:	e9 96 fb ff ff       	jmp    801050a0 <alltraps>

8010550a <vector3>:
.globl vector3
vector3:
  pushl $0
8010550a:	6a 00                	push   $0x0
  pushl $3
8010550c:	6a 03                	push   $0x3
  jmp alltraps
8010550e:	e9 8d fb ff ff       	jmp    801050a0 <alltraps>

80105513 <vector4>:
.globl vector4
vector4:
  pushl $0
80105513:	6a 00                	push   $0x0
  pushl $4
80105515:	6a 04                	push   $0x4
  jmp alltraps
80105517:	e9 84 fb ff ff       	jmp    801050a0 <alltraps>

8010551c <vector5>:
.globl vector5
vector5:
  pushl $0
8010551c:	6a 00                	push   $0x0
  pushl $5
8010551e:	6a 05                	push   $0x5
  jmp alltraps
80105520:	e9 7b fb ff ff       	jmp    801050a0 <alltraps>

80105525 <vector6>:
.globl vector6
vector6:
  pushl $0
80105525:	6a 00                	push   $0x0
  pushl $6
80105527:	6a 06                	push   $0x6
  jmp alltraps
80105529:	e9 72 fb ff ff       	jmp    801050a0 <alltraps>

8010552e <vector7>:
.globl vector7
vector7:
  pushl $0
8010552e:	6a 00                	push   $0x0
  pushl $7
80105530:	6a 07                	push   $0x7
  jmp alltraps
80105532:	e9 69 fb ff ff       	jmp    801050a0 <alltraps>

80105537 <vector8>:
.globl vector8
vector8:
  pushl $8
80105537:	6a 08                	push   $0x8
  jmp alltraps
80105539:	e9 62 fb ff ff       	jmp    801050a0 <alltraps>

8010553e <vector9>:
.globl vector9
vector9:
  pushl $0
8010553e:	6a 00                	push   $0x0
  pushl $9
80105540:	6a 09                	push   $0x9
  jmp alltraps
80105542:	e9 59 fb ff ff       	jmp    801050a0 <alltraps>

80105547 <vector10>:
.globl vector10
vector10:
  pushl $10
80105547:	6a 0a                	push   $0xa
  jmp alltraps
80105549:	e9 52 fb ff ff       	jmp    801050a0 <alltraps>

8010554e <vector11>:
.globl vector11
vector11:
  pushl $11
8010554e:	6a 0b                	push   $0xb
  jmp alltraps
80105550:	e9 4b fb ff ff       	jmp    801050a0 <alltraps>

80105555 <vector12>:
.globl vector12
vector12:
  pushl $12
80105555:	6a 0c                	push   $0xc
  jmp alltraps
80105557:	e9 44 fb ff ff       	jmp    801050a0 <alltraps>

8010555c <vector13>:
.globl vector13
vector13:
  pushl $13
8010555c:	6a 0d                	push   $0xd
  jmp alltraps
8010555e:	e9 3d fb ff ff       	jmp    801050a0 <alltraps>

80105563 <vector14>:
.globl vector14
vector14:
  pushl $14
80105563:	6a 0e                	push   $0xe
  jmp alltraps
80105565:	e9 36 fb ff ff       	jmp    801050a0 <alltraps>

8010556a <vector15>:
.globl vector15
vector15:
  pushl $0
8010556a:	6a 00                	push   $0x0
  pushl $15
8010556c:	6a 0f                	push   $0xf
  jmp alltraps
8010556e:	e9 2d fb ff ff       	jmp    801050a0 <alltraps>

80105573 <vector16>:
.globl vector16
vector16:
  pushl $0
80105573:	6a 00                	push   $0x0
  pushl $16
80105575:	6a 10                	push   $0x10
  jmp alltraps
80105577:	e9 24 fb ff ff       	jmp    801050a0 <alltraps>

8010557c <vector17>:
.globl vector17
vector17:
  pushl $17
8010557c:	6a 11                	push   $0x11
  jmp alltraps
8010557e:	e9 1d fb ff ff       	jmp    801050a0 <alltraps>

80105583 <vector18>:
.globl vector18
vector18:
  pushl $0
80105583:	6a 00                	push   $0x0
  pushl $18
80105585:	6a 12                	push   $0x12
  jmp alltraps
80105587:	e9 14 fb ff ff       	jmp    801050a0 <alltraps>

8010558c <vector19>:
.globl vector19
vector19:
  pushl $0
8010558c:	6a 00                	push   $0x0
  pushl $19
8010558e:	6a 13                	push   $0x13
  jmp alltraps
80105590:	e9 0b fb ff ff       	jmp    801050a0 <alltraps>

80105595 <vector20>:
.globl vector20
vector20:
  pushl $0
80105595:	6a 00                	push   $0x0
  pushl $20
80105597:	6a 14                	push   $0x14
  jmp alltraps
80105599:	e9 02 fb ff ff       	jmp    801050a0 <alltraps>

8010559e <vector21>:
.globl vector21
vector21:
  pushl $0
8010559e:	6a 00                	push   $0x0
  pushl $21
801055a0:	6a 15                	push   $0x15
  jmp alltraps
801055a2:	e9 f9 fa ff ff       	jmp    801050a0 <alltraps>

801055a7 <vector22>:
.globl vector22
vector22:
  pushl $0
801055a7:	6a 00                	push   $0x0
  pushl $22
801055a9:	6a 16                	push   $0x16
  jmp alltraps
801055ab:	e9 f0 fa ff ff       	jmp    801050a0 <alltraps>

801055b0 <vector23>:
.globl vector23
vector23:
  pushl $0
801055b0:	6a 00                	push   $0x0
  pushl $23
801055b2:	6a 17                	push   $0x17
  jmp alltraps
801055b4:	e9 e7 fa ff ff       	jmp    801050a0 <alltraps>

801055b9 <vector24>:
.globl vector24
vector24:
  pushl $0
801055b9:	6a 00                	push   $0x0
  pushl $24
801055bb:	6a 18                	push   $0x18
  jmp alltraps
801055bd:	e9 de fa ff ff       	jmp    801050a0 <alltraps>

801055c2 <vector25>:
.globl vector25
vector25:
  pushl $0
801055c2:	6a 00                	push   $0x0
  pushl $25
801055c4:	6a 19                	push   $0x19
  jmp alltraps
801055c6:	e9 d5 fa ff ff       	jmp    801050a0 <alltraps>

801055cb <vector26>:
.globl vector26
vector26:
  pushl $0
801055cb:	6a 00                	push   $0x0
  pushl $26
801055cd:	6a 1a                	push   $0x1a
  jmp alltraps
801055cf:	e9 cc fa ff ff       	jmp    801050a0 <alltraps>

801055d4 <vector27>:
.globl vector27
vector27:
  pushl $0
801055d4:	6a 00                	push   $0x0
  pushl $27
801055d6:	6a 1b                	push   $0x1b
  jmp alltraps
801055d8:	e9 c3 fa ff ff       	jmp    801050a0 <alltraps>

801055dd <vector28>:
.globl vector28
vector28:
  pushl $0
801055dd:	6a 00                	push   $0x0
  pushl $28
801055df:	6a 1c                	push   $0x1c
  jmp alltraps
801055e1:	e9 ba fa ff ff       	jmp    801050a0 <alltraps>

801055e6 <vector29>:
.globl vector29
vector29:
  pushl $0
801055e6:	6a 00                	push   $0x0
  pushl $29
801055e8:	6a 1d                	push   $0x1d
  jmp alltraps
801055ea:	e9 b1 fa ff ff       	jmp    801050a0 <alltraps>

801055ef <vector30>:
.globl vector30
vector30:
  pushl $0
801055ef:	6a 00                	push   $0x0
  pushl $30
801055f1:	6a 1e                	push   $0x1e
  jmp alltraps
801055f3:	e9 a8 fa ff ff       	jmp    801050a0 <alltraps>

801055f8 <vector31>:
.globl vector31
vector31:
  pushl $0
801055f8:	6a 00                	push   $0x0
  pushl $31
801055fa:	6a 1f                	push   $0x1f
  jmp alltraps
801055fc:	e9 9f fa ff ff       	jmp    801050a0 <alltraps>

80105601 <vector32>:
.globl vector32
vector32:
  pushl $0
80105601:	6a 00                	push   $0x0
  pushl $32
80105603:	6a 20                	push   $0x20
  jmp alltraps
80105605:	e9 96 fa ff ff       	jmp    801050a0 <alltraps>

8010560a <vector33>:
.globl vector33
vector33:
  pushl $0
8010560a:	6a 00                	push   $0x0
  pushl $33
8010560c:	6a 21                	push   $0x21
  jmp alltraps
8010560e:	e9 8d fa ff ff       	jmp    801050a0 <alltraps>

80105613 <vector34>:
.globl vector34
vector34:
  pushl $0
80105613:	6a 00                	push   $0x0
  pushl $34
80105615:	6a 22                	push   $0x22
  jmp alltraps
80105617:	e9 84 fa ff ff       	jmp    801050a0 <alltraps>

8010561c <vector35>:
.globl vector35
vector35:
  pushl $0
8010561c:	6a 00                	push   $0x0
  pushl $35
8010561e:	6a 23                	push   $0x23
  jmp alltraps
80105620:	e9 7b fa ff ff       	jmp    801050a0 <alltraps>

80105625 <vector36>:
.globl vector36
vector36:
  pushl $0
80105625:	6a 00                	push   $0x0
  pushl $36
80105627:	6a 24                	push   $0x24
  jmp alltraps
80105629:	e9 72 fa ff ff       	jmp    801050a0 <alltraps>

8010562e <vector37>:
.globl vector37
vector37:
  pushl $0
8010562e:	6a 00                	push   $0x0
  pushl $37
80105630:	6a 25                	push   $0x25
  jmp alltraps
80105632:	e9 69 fa ff ff       	jmp    801050a0 <alltraps>

80105637 <vector38>:
.globl vector38
vector38:
  pushl $0
80105637:	6a 00                	push   $0x0
  pushl $38
80105639:	6a 26                	push   $0x26
  jmp alltraps
8010563b:	e9 60 fa ff ff       	jmp    801050a0 <alltraps>

80105640 <vector39>:
.globl vector39
vector39:
  pushl $0
80105640:	6a 00                	push   $0x0
  pushl $39
80105642:	6a 27                	push   $0x27
  jmp alltraps
80105644:	e9 57 fa ff ff       	jmp    801050a0 <alltraps>

80105649 <vector40>:
.globl vector40
vector40:
  pushl $0
80105649:	6a 00                	push   $0x0
  pushl $40
8010564b:	6a 28                	push   $0x28
  jmp alltraps
8010564d:	e9 4e fa ff ff       	jmp    801050a0 <alltraps>

80105652 <vector41>:
.globl vector41
vector41:
  pushl $0
80105652:	6a 00                	push   $0x0
  pushl $41
80105654:	6a 29                	push   $0x29
  jmp alltraps
80105656:	e9 45 fa ff ff       	jmp    801050a0 <alltraps>

8010565b <vector42>:
.globl vector42
vector42:
  pushl $0
8010565b:	6a 00                	push   $0x0
  pushl $42
8010565d:	6a 2a                	push   $0x2a
  jmp alltraps
8010565f:	e9 3c fa ff ff       	jmp    801050a0 <alltraps>

80105664 <vector43>:
.globl vector43
vector43:
  pushl $0
80105664:	6a 00                	push   $0x0
  pushl $43
80105666:	6a 2b                	push   $0x2b
  jmp alltraps
80105668:	e9 33 fa ff ff       	jmp    801050a0 <alltraps>

8010566d <vector44>:
.globl vector44
vector44:
  pushl $0
8010566d:	6a 00                	push   $0x0
  pushl $44
8010566f:	6a 2c                	push   $0x2c
  jmp alltraps
80105671:	e9 2a fa ff ff       	jmp    801050a0 <alltraps>

80105676 <vector45>:
.globl vector45
vector45:
  pushl $0
80105676:	6a 00                	push   $0x0
  pushl $45
80105678:	6a 2d                	push   $0x2d
  jmp alltraps
8010567a:	e9 21 fa ff ff       	jmp    801050a0 <alltraps>

8010567f <vector46>:
.globl vector46
vector46:
  pushl $0
8010567f:	6a 00                	push   $0x0
  pushl $46
80105681:	6a 2e                	push   $0x2e
  jmp alltraps
80105683:	e9 18 fa ff ff       	jmp    801050a0 <alltraps>

80105688 <vector47>:
.globl vector47
vector47:
  pushl $0
80105688:	6a 00                	push   $0x0
  pushl $47
8010568a:	6a 2f                	push   $0x2f
  jmp alltraps
8010568c:	e9 0f fa ff ff       	jmp    801050a0 <alltraps>

80105691 <vector48>:
.globl vector48
vector48:
  pushl $0
80105691:	6a 00                	push   $0x0
  pushl $48
80105693:	6a 30                	push   $0x30
  jmp alltraps
80105695:	e9 06 fa ff ff       	jmp    801050a0 <alltraps>

8010569a <vector49>:
.globl vector49
vector49:
  pushl $0
8010569a:	6a 00                	push   $0x0
  pushl $49
8010569c:	6a 31                	push   $0x31
  jmp alltraps
8010569e:	e9 fd f9 ff ff       	jmp    801050a0 <alltraps>

801056a3 <vector50>:
.globl vector50
vector50:
  pushl $0
801056a3:	6a 00                	push   $0x0
  pushl $50
801056a5:	6a 32                	push   $0x32
  jmp alltraps
801056a7:	e9 f4 f9 ff ff       	jmp    801050a0 <alltraps>

801056ac <vector51>:
.globl vector51
vector51:
  pushl $0
801056ac:	6a 00                	push   $0x0
  pushl $51
801056ae:	6a 33                	push   $0x33
  jmp alltraps
801056b0:	e9 eb f9 ff ff       	jmp    801050a0 <alltraps>

801056b5 <vector52>:
.globl vector52
vector52:
  pushl $0
801056b5:	6a 00                	push   $0x0
  pushl $52
801056b7:	6a 34                	push   $0x34
  jmp alltraps
801056b9:	e9 e2 f9 ff ff       	jmp    801050a0 <alltraps>

801056be <vector53>:
.globl vector53
vector53:
  pushl $0
801056be:	6a 00                	push   $0x0
  pushl $53
801056c0:	6a 35                	push   $0x35
  jmp alltraps
801056c2:	e9 d9 f9 ff ff       	jmp    801050a0 <alltraps>

801056c7 <vector54>:
.globl vector54
vector54:
  pushl $0
801056c7:	6a 00                	push   $0x0
  pushl $54
801056c9:	6a 36                	push   $0x36
  jmp alltraps
801056cb:	e9 d0 f9 ff ff       	jmp    801050a0 <alltraps>

801056d0 <vector55>:
.globl vector55
vector55:
  pushl $0
801056d0:	6a 00                	push   $0x0
  pushl $55
801056d2:	6a 37                	push   $0x37
  jmp alltraps
801056d4:	e9 c7 f9 ff ff       	jmp    801050a0 <alltraps>

801056d9 <vector56>:
.globl vector56
vector56:
  pushl $0
801056d9:	6a 00                	push   $0x0
  pushl $56
801056db:	6a 38                	push   $0x38
  jmp alltraps
801056dd:	e9 be f9 ff ff       	jmp    801050a0 <alltraps>

801056e2 <vector57>:
.globl vector57
vector57:
  pushl $0
801056e2:	6a 00                	push   $0x0
  pushl $57
801056e4:	6a 39                	push   $0x39
  jmp alltraps
801056e6:	e9 b5 f9 ff ff       	jmp    801050a0 <alltraps>

801056eb <vector58>:
.globl vector58
vector58:
  pushl $0
801056eb:	6a 00                	push   $0x0
  pushl $58
801056ed:	6a 3a                	push   $0x3a
  jmp alltraps
801056ef:	e9 ac f9 ff ff       	jmp    801050a0 <alltraps>

801056f4 <vector59>:
.globl vector59
vector59:
  pushl $0
801056f4:	6a 00                	push   $0x0
  pushl $59
801056f6:	6a 3b                	push   $0x3b
  jmp alltraps
801056f8:	e9 a3 f9 ff ff       	jmp    801050a0 <alltraps>

801056fd <vector60>:
.globl vector60
vector60:
  pushl $0
801056fd:	6a 00                	push   $0x0
  pushl $60
801056ff:	6a 3c                	push   $0x3c
  jmp alltraps
80105701:	e9 9a f9 ff ff       	jmp    801050a0 <alltraps>

80105706 <vector61>:
.globl vector61
vector61:
  pushl $0
80105706:	6a 00                	push   $0x0
  pushl $61
80105708:	6a 3d                	push   $0x3d
  jmp alltraps
8010570a:	e9 91 f9 ff ff       	jmp    801050a0 <alltraps>

8010570f <vector62>:
.globl vector62
vector62:
  pushl $0
8010570f:	6a 00                	push   $0x0
  pushl $62
80105711:	6a 3e                	push   $0x3e
  jmp alltraps
80105713:	e9 88 f9 ff ff       	jmp    801050a0 <alltraps>

80105718 <vector63>:
.globl vector63
vector63:
  pushl $0
80105718:	6a 00                	push   $0x0
  pushl $63
8010571a:	6a 3f                	push   $0x3f
  jmp alltraps
8010571c:	e9 7f f9 ff ff       	jmp    801050a0 <alltraps>

80105721 <vector64>:
.globl vector64
vector64:
  pushl $0
80105721:	6a 00                	push   $0x0
  pushl $64
80105723:	6a 40                	push   $0x40
  jmp alltraps
80105725:	e9 76 f9 ff ff       	jmp    801050a0 <alltraps>

8010572a <vector65>:
.globl vector65
vector65:
  pushl $0
8010572a:	6a 00                	push   $0x0
  pushl $65
8010572c:	6a 41                	push   $0x41
  jmp alltraps
8010572e:	e9 6d f9 ff ff       	jmp    801050a0 <alltraps>

80105733 <vector66>:
.globl vector66
vector66:
  pushl $0
80105733:	6a 00                	push   $0x0
  pushl $66
80105735:	6a 42                	push   $0x42
  jmp alltraps
80105737:	e9 64 f9 ff ff       	jmp    801050a0 <alltraps>

8010573c <vector67>:
.globl vector67
vector67:
  pushl $0
8010573c:	6a 00                	push   $0x0
  pushl $67
8010573e:	6a 43                	push   $0x43
  jmp alltraps
80105740:	e9 5b f9 ff ff       	jmp    801050a0 <alltraps>

80105745 <vector68>:
.globl vector68
vector68:
  pushl $0
80105745:	6a 00                	push   $0x0
  pushl $68
80105747:	6a 44                	push   $0x44
  jmp alltraps
80105749:	e9 52 f9 ff ff       	jmp    801050a0 <alltraps>

8010574e <vector69>:
.globl vector69
vector69:
  pushl $0
8010574e:	6a 00                	push   $0x0
  pushl $69
80105750:	6a 45                	push   $0x45
  jmp alltraps
80105752:	e9 49 f9 ff ff       	jmp    801050a0 <alltraps>

80105757 <vector70>:
.globl vector70
vector70:
  pushl $0
80105757:	6a 00                	push   $0x0
  pushl $70
80105759:	6a 46                	push   $0x46
  jmp alltraps
8010575b:	e9 40 f9 ff ff       	jmp    801050a0 <alltraps>

80105760 <vector71>:
.globl vector71
vector71:
  pushl $0
80105760:	6a 00                	push   $0x0
  pushl $71
80105762:	6a 47                	push   $0x47
  jmp alltraps
80105764:	e9 37 f9 ff ff       	jmp    801050a0 <alltraps>

80105769 <vector72>:
.globl vector72
vector72:
  pushl $0
80105769:	6a 00                	push   $0x0
  pushl $72
8010576b:	6a 48                	push   $0x48
  jmp alltraps
8010576d:	e9 2e f9 ff ff       	jmp    801050a0 <alltraps>

80105772 <vector73>:
.globl vector73
vector73:
  pushl $0
80105772:	6a 00                	push   $0x0
  pushl $73
80105774:	6a 49                	push   $0x49
  jmp alltraps
80105776:	e9 25 f9 ff ff       	jmp    801050a0 <alltraps>

8010577b <vector74>:
.globl vector74
vector74:
  pushl $0
8010577b:	6a 00                	push   $0x0
  pushl $74
8010577d:	6a 4a                	push   $0x4a
  jmp alltraps
8010577f:	e9 1c f9 ff ff       	jmp    801050a0 <alltraps>

80105784 <vector75>:
.globl vector75
vector75:
  pushl $0
80105784:	6a 00                	push   $0x0
  pushl $75
80105786:	6a 4b                	push   $0x4b
  jmp alltraps
80105788:	e9 13 f9 ff ff       	jmp    801050a0 <alltraps>

8010578d <vector76>:
.globl vector76
vector76:
  pushl $0
8010578d:	6a 00                	push   $0x0
  pushl $76
8010578f:	6a 4c                	push   $0x4c
  jmp alltraps
80105791:	e9 0a f9 ff ff       	jmp    801050a0 <alltraps>

80105796 <vector77>:
.globl vector77
vector77:
  pushl $0
80105796:	6a 00                	push   $0x0
  pushl $77
80105798:	6a 4d                	push   $0x4d
  jmp alltraps
8010579a:	e9 01 f9 ff ff       	jmp    801050a0 <alltraps>

8010579f <vector78>:
.globl vector78
vector78:
  pushl $0
8010579f:	6a 00                	push   $0x0
  pushl $78
801057a1:	6a 4e                	push   $0x4e
  jmp alltraps
801057a3:	e9 f8 f8 ff ff       	jmp    801050a0 <alltraps>

801057a8 <vector79>:
.globl vector79
vector79:
  pushl $0
801057a8:	6a 00                	push   $0x0
  pushl $79
801057aa:	6a 4f                	push   $0x4f
  jmp alltraps
801057ac:	e9 ef f8 ff ff       	jmp    801050a0 <alltraps>

801057b1 <vector80>:
.globl vector80
vector80:
  pushl $0
801057b1:	6a 00                	push   $0x0
  pushl $80
801057b3:	6a 50                	push   $0x50
  jmp alltraps
801057b5:	e9 e6 f8 ff ff       	jmp    801050a0 <alltraps>

801057ba <vector81>:
.globl vector81
vector81:
  pushl $0
801057ba:	6a 00                	push   $0x0
  pushl $81
801057bc:	6a 51                	push   $0x51
  jmp alltraps
801057be:	e9 dd f8 ff ff       	jmp    801050a0 <alltraps>

801057c3 <vector82>:
.globl vector82
vector82:
  pushl $0
801057c3:	6a 00                	push   $0x0
  pushl $82
801057c5:	6a 52                	push   $0x52
  jmp alltraps
801057c7:	e9 d4 f8 ff ff       	jmp    801050a0 <alltraps>

801057cc <vector83>:
.globl vector83
vector83:
  pushl $0
801057cc:	6a 00                	push   $0x0
  pushl $83
801057ce:	6a 53                	push   $0x53
  jmp alltraps
801057d0:	e9 cb f8 ff ff       	jmp    801050a0 <alltraps>

801057d5 <vector84>:
.globl vector84
vector84:
  pushl $0
801057d5:	6a 00                	push   $0x0
  pushl $84
801057d7:	6a 54                	push   $0x54
  jmp alltraps
801057d9:	e9 c2 f8 ff ff       	jmp    801050a0 <alltraps>

801057de <vector85>:
.globl vector85
vector85:
  pushl $0
801057de:	6a 00                	push   $0x0
  pushl $85
801057e0:	6a 55                	push   $0x55
  jmp alltraps
801057e2:	e9 b9 f8 ff ff       	jmp    801050a0 <alltraps>

801057e7 <vector86>:
.globl vector86
vector86:
  pushl $0
801057e7:	6a 00                	push   $0x0
  pushl $86
801057e9:	6a 56                	push   $0x56
  jmp alltraps
801057eb:	e9 b0 f8 ff ff       	jmp    801050a0 <alltraps>

801057f0 <vector87>:
.globl vector87
vector87:
  pushl $0
801057f0:	6a 00                	push   $0x0
  pushl $87
801057f2:	6a 57                	push   $0x57
  jmp alltraps
801057f4:	e9 a7 f8 ff ff       	jmp    801050a0 <alltraps>

801057f9 <vector88>:
.globl vector88
vector88:
  pushl $0
801057f9:	6a 00                	push   $0x0
  pushl $88
801057fb:	6a 58                	push   $0x58
  jmp alltraps
801057fd:	e9 9e f8 ff ff       	jmp    801050a0 <alltraps>

80105802 <vector89>:
.globl vector89
vector89:
  pushl $0
80105802:	6a 00                	push   $0x0
  pushl $89
80105804:	6a 59                	push   $0x59
  jmp alltraps
80105806:	e9 95 f8 ff ff       	jmp    801050a0 <alltraps>

8010580b <vector90>:
.globl vector90
vector90:
  pushl $0
8010580b:	6a 00                	push   $0x0
  pushl $90
8010580d:	6a 5a                	push   $0x5a
  jmp alltraps
8010580f:	e9 8c f8 ff ff       	jmp    801050a0 <alltraps>

80105814 <vector91>:
.globl vector91
vector91:
  pushl $0
80105814:	6a 00                	push   $0x0
  pushl $91
80105816:	6a 5b                	push   $0x5b
  jmp alltraps
80105818:	e9 83 f8 ff ff       	jmp    801050a0 <alltraps>

8010581d <vector92>:
.globl vector92
vector92:
  pushl $0
8010581d:	6a 00                	push   $0x0
  pushl $92
8010581f:	6a 5c                	push   $0x5c
  jmp alltraps
80105821:	e9 7a f8 ff ff       	jmp    801050a0 <alltraps>

80105826 <vector93>:
.globl vector93
vector93:
  pushl $0
80105826:	6a 00                	push   $0x0
  pushl $93
80105828:	6a 5d                	push   $0x5d
  jmp alltraps
8010582a:	e9 71 f8 ff ff       	jmp    801050a0 <alltraps>

8010582f <vector94>:
.globl vector94
vector94:
  pushl $0
8010582f:	6a 00                	push   $0x0
  pushl $94
80105831:	6a 5e                	push   $0x5e
  jmp alltraps
80105833:	e9 68 f8 ff ff       	jmp    801050a0 <alltraps>

80105838 <vector95>:
.globl vector95
vector95:
  pushl $0
80105838:	6a 00                	push   $0x0
  pushl $95
8010583a:	6a 5f                	push   $0x5f
  jmp alltraps
8010583c:	e9 5f f8 ff ff       	jmp    801050a0 <alltraps>

80105841 <vector96>:
.globl vector96
vector96:
  pushl $0
80105841:	6a 00                	push   $0x0
  pushl $96
80105843:	6a 60                	push   $0x60
  jmp alltraps
80105845:	e9 56 f8 ff ff       	jmp    801050a0 <alltraps>

8010584a <vector97>:
.globl vector97
vector97:
  pushl $0
8010584a:	6a 00                	push   $0x0
  pushl $97
8010584c:	6a 61                	push   $0x61
  jmp alltraps
8010584e:	e9 4d f8 ff ff       	jmp    801050a0 <alltraps>

80105853 <vector98>:
.globl vector98
vector98:
  pushl $0
80105853:	6a 00                	push   $0x0
  pushl $98
80105855:	6a 62                	push   $0x62
  jmp alltraps
80105857:	e9 44 f8 ff ff       	jmp    801050a0 <alltraps>

8010585c <vector99>:
.globl vector99
vector99:
  pushl $0
8010585c:	6a 00                	push   $0x0
  pushl $99
8010585e:	6a 63                	push   $0x63
  jmp alltraps
80105860:	e9 3b f8 ff ff       	jmp    801050a0 <alltraps>

80105865 <vector100>:
.globl vector100
vector100:
  pushl $0
80105865:	6a 00                	push   $0x0
  pushl $100
80105867:	6a 64                	push   $0x64
  jmp alltraps
80105869:	e9 32 f8 ff ff       	jmp    801050a0 <alltraps>

8010586e <vector101>:
.globl vector101
vector101:
  pushl $0
8010586e:	6a 00                	push   $0x0
  pushl $101
80105870:	6a 65                	push   $0x65
  jmp alltraps
80105872:	e9 29 f8 ff ff       	jmp    801050a0 <alltraps>

80105877 <vector102>:
.globl vector102
vector102:
  pushl $0
80105877:	6a 00                	push   $0x0
  pushl $102
80105879:	6a 66                	push   $0x66
  jmp alltraps
8010587b:	e9 20 f8 ff ff       	jmp    801050a0 <alltraps>

80105880 <vector103>:
.globl vector103
vector103:
  pushl $0
80105880:	6a 00                	push   $0x0
  pushl $103
80105882:	6a 67                	push   $0x67
  jmp alltraps
80105884:	e9 17 f8 ff ff       	jmp    801050a0 <alltraps>

80105889 <vector104>:
.globl vector104
vector104:
  pushl $0
80105889:	6a 00                	push   $0x0
  pushl $104
8010588b:	6a 68                	push   $0x68
  jmp alltraps
8010588d:	e9 0e f8 ff ff       	jmp    801050a0 <alltraps>

80105892 <vector105>:
.globl vector105
vector105:
  pushl $0
80105892:	6a 00                	push   $0x0
  pushl $105
80105894:	6a 69                	push   $0x69
  jmp alltraps
80105896:	e9 05 f8 ff ff       	jmp    801050a0 <alltraps>

8010589b <vector106>:
.globl vector106
vector106:
  pushl $0
8010589b:	6a 00                	push   $0x0
  pushl $106
8010589d:	6a 6a                	push   $0x6a
  jmp alltraps
8010589f:	e9 fc f7 ff ff       	jmp    801050a0 <alltraps>

801058a4 <vector107>:
.globl vector107
vector107:
  pushl $0
801058a4:	6a 00                	push   $0x0
  pushl $107
801058a6:	6a 6b                	push   $0x6b
  jmp alltraps
801058a8:	e9 f3 f7 ff ff       	jmp    801050a0 <alltraps>

801058ad <vector108>:
.globl vector108
vector108:
  pushl $0
801058ad:	6a 00                	push   $0x0
  pushl $108
801058af:	6a 6c                	push   $0x6c
  jmp alltraps
801058b1:	e9 ea f7 ff ff       	jmp    801050a0 <alltraps>

801058b6 <vector109>:
.globl vector109
vector109:
  pushl $0
801058b6:	6a 00                	push   $0x0
  pushl $109
801058b8:	6a 6d                	push   $0x6d
  jmp alltraps
801058ba:	e9 e1 f7 ff ff       	jmp    801050a0 <alltraps>

801058bf <vector110>:
.globl vector110
vector110:
  pushl $0
801058bf:	6a 00                	push   $0x0
  pushl $110
801058c1:	6a 6e                	push   $0x6e
  jmp alltraps
801058c3:	e9 d8 f7 ff ff       	jmp    801050a0 <alltraps>

801058c8 <vector111>:
.globl vector111
vector111:
  pushl $0
801058c8:	6a 00                	push   $0x0
  pushl $111
801058ca:	6a 6f                	push   $0x6f
  jmp alltraps
801058cc:	e9 cf f7 ff ff       	jmp    801050a0 <alltraps>

801058d1 <vector112>:
.globl vector112
vector112:
  pushl $0
801058d1:	6a 00                	push   $0x0
  pushl $112
801058d3:	6a 70                	push   $0x70
  jmp alltraps
801058d5:	e9 c6 f7 ff ff       	jmp    801050a0 <alltraps>

801058da <vector113>:
.globl vector113
vector113:
  pushl $0
801058da:	6a 00                	push   $0x0
  pushl $113
801058dc:	6a 71                	push   $0x71
  jmp alltraps
801058de:	e9 bd f7 ff ff       	jmp    801050a0 <alltraps>

801058e3 <vector114>:
.globl vector114
vector114:
  pushl $0
801058e3:	6a 00                	push   $0x0
  pushl $114
801058e5:	6a 72                	push   $0x72
  jmp alltraps
801058e7:	e9 b4 f7 ff ff       	jmp    801050a0 <alltraps>

801058ec <vector115>:
.globl vector115
vector115:
  pushl $0
801058ec:	6a 00                	push   $0x0
  pushl $115
801058ee:	6a 73                	push   $0x73
  jmp alltraps
801058f0:	e9 ab f7 ff ff       	jmp    801050a0 <alltraps>

801058f5 <vector116>:
.globl vector116
vector116:
  pushl $0
801058f5:	6a 00                	push   $0x0
  pushl $116
801058f7:	6a 74                	push   $0x74
  jmp alltraps
801058f9:	e9 a2 f7 ff ff       	jmp    801050a0 <alltraps>

801058fe <vector117>:
.globl vector117
vector117:
  pushl $0
801058fe:	6a 00                	push   $0x0
  pushl $117
80105900:	6a 75                	push   $0x75
  jmp alltraps
80105902:	e9 99 f7 ff ff       	jmp    801050a0 <alltraps>

80105907 <vector118>:
.globl vector118
vector118:
  pushl $0
80105907:	6a 00                	push   $0x0
  pushl $118
80105909:	6a 76                	push   $0x76
  jmp alltraps
8010590b:	e9 90 f7 ff ff       	jmp    801050a0 <alltraps>

80105910 <vector119>:
.globl vector119
vector119:
  pushl $0
80105910:	6a 00                	push   $0x0
  pushl $119
80105912:	6a 77                	push   $0x77
  jmp alltraps
80105914:	e9 87 f7 ff ff       	jmp    801050a0 <alltraps>

80105919 <vector120>:
.globl vector120
vector120:
  pushl $0
80105919:	6a 00                	push   $0x0
  pushl $120
8010591b:	6a 78                	push   $0x78
  jmp alltraps
8010591d:	e9 7e f7 ff ff       	jmp    801050a0 <alltraps>

80105922 <vector121>:
.globl vector121
vector121:
  pushl $0
80105922:	6a 00                	push   $0x0
  pushl $121
80105924:	6a 79                	push   $0x79
  jmp alltraps
80105926:	e9 75 f7 ff ff       	jmp    801050a0 <alltraps>

8010592b <vector122>:
.globl vector122
vector122:
  pushl $0
8010592b:	6a 00                	push   $0x0
  pushl $122
8010592d:	6a 7a                	push   $0x7a
  jmp alltraps
8010592f:	e9 6c f7 ff ff       	jmp    801050a0 <alltraps>

80105934 <vector123>:
.globl vector123
vector123:
  pushl $0
80105934:	6a 00                	push   $0x0
  pushl $123
80105936:	6a 7b                	push   $0x7b
  jmp alltraps
80105938:	e9 63 f7 ff ff       	jmp    801050a0 <alltraps>

8010593d <vector124>:
.globl vector124
vector124:
  pushl $0
8010593d:	6a 00                	push   $0x0
  pushl $124
8010593f:	6a 7c                	push   $0x7c
  jmp alltraps
80105941:	e9 5a f7 ff ff       	jmp    801050a0 <alltraps>

80105946 <vector125>:
.globl vector125
vector125:
  pushl $0
80105946:	6a 00                	push   $0x0
  pushl $125
80105948:	6a 7d                	push   $0x7d
  jmp alltraps
8010594a:	e9 51 f7 ff ff       	jmp    801050a0 <alltraps>

8010594f <vector126>:
.globl vector126
vector126:
  pushl $0
8010594f:	6a 00                	push   $0x0
  pushl $126
80105951:	6a 7e                	push   $0x7e
  jmp alltraps
80105953:	e9 48 f7 ff ff       	jmp    801050a0 <alltraps>

80105958 <vector127>:
.globl vector127
vector127:
  pushl $0
80105958:	6a 00                	push   $0x0
  pushl $127
8010595a:	6a 7f                	push   $0x7f
  jmp alltraps
8010595c:	e9 3f f7 ff ff       	jmp    801050a0 <alltraps>

80105961 <vector128>:
.globl vector128
vector128:
  pushl $0
80105961:	6a 00                	push   $0x0
  pushl $128
80105963:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105968:	e9 33 f7 ff ff       	jmp    801050a0 <alltraps>

8010596d <vector129>:
.globl vector129
vector129:
  pushl $0
8010596d:	6a 00                	push   $0x0
  pushl $129
8010596f:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105974:	e9 27 f7 ff ff       	jmp    801050a0 <alltraps>

80105979 <vector130>:
.globl vector130
vector130:
  pushl $0
80105979:	6a 00                	push   $0x0
  pushl $130
8010597b:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105980:	e9 1b f7 ff ff       	jmp    801050a0 <alltraps>

80105985 <vector131>:
.globl vector131
vector131:
  pushl $0
80105985:	6a 00                	push   $0x0
  pushl $131
80105987:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010598c:	e9 0f f7 ff ff       	jmp    801050a0 <alltraps>

80105991 <vector132>:
.globl vector132
vector132:
  pushl $0
80105991:	6a 00                	push   $0x0
  pushl $132
80105993:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105998:	e9 03 f7 ff ff       	jmp    801050a0 <alltraps>

8010599d <vector133>:
.globl vector133
vector133:
  pushl $0
8010599d:	6a 00                	push   $0x0
  pushl $133
8010599f:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801059a4:	e9 f7 f6 ff ff       	jmp    801050a0 <alltraps>

801059a9 <vector134>:
.globl vector134
vector134:
  pushl $0
801059a9:	6a 00                	push   $0x0
  pushl $134
801059ab:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801059b0:	e9 eb f6 ff ff       	jmp    801050a0 <alltraps>

801059b5 <vector135>:
.globl vector135
vector135:
  pushl $0
801059b5:	6a 00                	push   $0x0
  pushl $135
801059b7:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801059bc:	e9 df f6 ff ff       	jmp    801050a0 <alltraps>

801059c1 <vector136>:
.globl vector136
vector136:
  pushl $0
801059c1:	6a 00                	push   $0x0
  pushl $136
801059c3:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801059c8:	e9 d3 f6 ff ff       	jmp    801050a0 <alltraps>

801059cd <vector137>:
.globl vector137
vector137:
  pushl $0
801059cd:	6a 00                	push   $0x0
  pushl $137
801059cf:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801059d4:	e9 c7 f6 ff ff       	jmp    801050a0 <alltraps>

801059d9 <vector138>:
.globl vector138
vector138:
  pushl $0
801059d9:	6a 00                	push   $0x0
  pushl $138
801059db:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801059e0:	e9 bb f6 ff ff       	jmp    801050a0 <alltraps>

801059e5 <vector139>:
.globl vector139
vector139:
  pushl $0
801059e5:	6a 00                	push   $0x0
  pushl $139
801059e7:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801059ec:	e9 af f6 ff ff       	jmp    801050a0 <alltraps>

801059f1 <vector140>:
.globl vector140
vector140:
  pushl $0
801059f1:	6a 00                	push   $0x0
  pushl $140
801059f3:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801059f8:	e9 a3 f6 ff ff       	jmp    801050a0 <alltraps>

801059fd <vector141>:
.globl vector141
vector141:
  pushl $0
801059fd:	6a 00                	push   $0x0
  pushl $141
801059ff:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105a04:	e9 97 f6 ff ff       	jmp    801050a0 <alltraps>

80105a09 <vector142>:
.globl vector142
vector142:
  pushl $0
80105a09:	6a 00                	push   $0x0
  pushl $142
80105a0b:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105a10:	e9 8b f6 ff ff       	jmp    801050a0 <alltraps>

80105a15 <vector143>:
.globl vector143
vector143:
  pushl $0
80105a15:	6a 00                	push   $0x0
  pushl $143
80105a17:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105a1c:	e9 7f f6 ff ff       	jmp    801050a0 <alltraps>

80105a21 <vector144>:
.globl vector144
vector144:
  pushl $0
80105a21:	6a 00                	push   $0x0
  pushl $144
80105a23:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105a28:	e9 73 f6 ff ff       	jmp    801050a0 <alltraps>

80105a2d <vector145>:
.globl vector145
vector145:
  pushl $0
80105a2d:	6a 00                	push   $0x0
  pushl $145
80105a2f:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105a34:	e9 67 f6 ff ff       	jmp    801050a0 <alltraps>

80105a39 <vector146>:
.globl vector146
vector146:
  pushl $0
80105a39:	6a 00                	push   $0x0
  pushl $146
80105a3b:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105a40:	e9 5b f6 ff ff       	jmp    801050a0 <alltraps>

80105a45 <vector147>:
.globl vector147
vector147:
  pushl $0
80105a45:	6a 00                	push   $0x0
  pushl $147
80105a47:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105a4c:	e9 4f f6 ff ff       	jmp    801050a0 <alltraps>

80105a51 <vector148>:
.globl vector148
vector148:
  pushl $0
80105a51:	6a 00                	push   $0x0
  pushl $148
80105a53:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105a58:	e9 43 f6 ff ff       	jmp    801050a0 <alltraps>

80105a5d <vector149>:
.globl vector149
vector149:
  pushl $0
80105a5d:	6a 00                	push   $0x0
  pushl $149
80105a5f:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105a64:	e9 37 f6 ff ff       	jmp    801050a0 <alltraps>

80105a69 <vector150>:
.globl vector150
vector150:
  pushl $0
80105a69:	6a 00                	push   $0x0
  pushl $150
80105a6b:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105a70:	e9 2b f6 ff ff       	jmp    801050a0 <alltraps>

80105a75 <vector151>:
.globl vector151
vector151:
  pushl $0
80105a75:	6a 00                	push   $0x0
  pushl $151
80105a77:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105a7c:	e9 1f f6 ff ff       	jmp    801050a0 <alltraps>

80105a81 <vector152>:
.globl vector152
vector152:
  pushl $0
80105a81:	6a 00                	push   $0x0
  pushl $152
80105a83:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105a88:	e9 13 f6 ff ff       	jmp    801050a0 <alltraps>

80105a8d <vector153>:
.globl vector153
vector153:
  pushl $0
80105a8d:	6a 00                	push   $0x0
  pushl $153
80105a8f:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105a94:	e9 07 f6 ff ff       	jmp    801050a0 <alltraps>

80105a99 <vector154>:
.globl vector154
vector154:
  pushl $0
80105a99:	6a 00                	push   $0x0
  pushl $154
80105a9b:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105aa0:	e9 fb f5 ff ff       	jmp    801050a0 <alltraps>

80105aa5 <vector155>:
.globl vector155
vector155:
  pushl $0
80105aa5:	6a 00                	push   $0x0
  pushl $155
80105aa7:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105aac:	e9 ef f5 ff ff       	jmp    801050a0 <alltraps>

80105ab1 <vector156>:
.globl vector156
vector156:
  pushl $0
80105ab1:	6a 00                	push   $0x0
  pushl $156
80105ab3:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105ab8:	e9 e3 f5 ff ff       	jmp    801050a0 <alltraps>

80105abd <vector157>:
.globl vector157
vector157:
  pushl $0
80105abd:	6a 00                	push   $0x0
  pushl $157
80105abf:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105ac4:	e9 d7 f5 ff ff       	jmp    801050a0 <alltraps>

80105ac9 <vector158>:
.globl vector158
vector158:
  pushl $0
80105ac9:	6a 00                	push   $0x0
  pushl $158
80105acb:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105ad0:	e9 cb f5 ff ff       	jmp    801050a0 <alltraps>

80105ad5 <vector159>:
.globl vector159
vector159:
  pushl $0
80105ad5:	6a 00                	push   $0x0
  pushl $159
80105ad7:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105adc:	e9 bf f5 ff ff       	jmp    801050a0 <alltraps>

80105ae1 <vector160>:
.globl vector160
vector160:
  pushl $0
80105ae1:	6a 00                	push   $0x0
  pushl $160
80105ae3:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105ae8:	e9 b3 f5 ff ff       	jmp    801050a0 <alltraps>

80105aed <vector161>:
.globl vector161
vector161:
  pushl $0
80105aed:	6a 00                	push   $0x0
  pushl $161
80105aef:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105af4:	e9 a7 f5 ff ff       	jmp    801050a0 <alltraps>

80105af9 <vector162>:
.globl vector162
vector162:
  pushl $0
80105af9:	6a 00                	push   $0x0
  pushl $162
80105afb:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105b00:	e9 9b f5 ff ff       	jmp    801050a0 <alltraps>

80105b05 <vector163>:
.globl vector163
vector163:
  pushl $0
80105b05:	6a 00                	push   $0x0
  pushl $163
80105b07:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105b0c:	e9 8f f5 ff ff       	jmp    801050a0 <alltraps>

80105b11 <vector164>:
.globl vector164
vector164:
  pushl $0
80105b11:	6a 00                	push   $0x0
  pushl $164
80105b13:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105b18:	e9 83 f5 ff ff       	jmp    801050a0 <alltraps>

80105b1d <vector165>:
.globl vector165
vector165:
  pushl $0
80105b1d:	6a 00                	push   $0x0
  pushl $165
80105b1f:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105b24:	e9 77 f5 ff ff       	jmp    801050a0 <alltraps>

80105b29 <vector166>:
.globl vector166
vector166:
  pushl $0
80105b29:	6a 00                	push   $0x0
  pushl $166
80105b2b:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105b30:	e9 6b f5 ff ff       	jmp    801050a0 <alltraps>

80105b35 <vector167>:
.globl vector167
vector167:
  pushl $0
80105b35:	6a 00                	push   $0x0
  pushl $167
80105b37:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105b3c:	e9 5f f5 ff ff       	jmp    801050a0 <alltraps>

80105b41 <vector168>:
.globl vector168
vector168:
  pushl $0
80105b41:	6a 00                	push   $0x0
  pushl $168
80105b43:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105b48:	e9 53 f5 ff ff       	jmp    801050a0 <alltraps>

80105b4d <vector169>:
.globl vector169
vector169:
  pushl $0
80105b4d:	6a 00                	push   $0x0
  pushl $169
80105b4f:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105b54:	e9 47 f5 ff ff       	jmp    801050a0 <alltraps>

80105b59 <vector170>:
.globl vector170
vector170:
  pushl $0
80105b59:	6a 00                	push   $0x0
  pushl $170
80105b5b:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105b60:	e9 3b f5 ff ff       	jmp    801050a0 <alltraps>

80105b65 <vector171>:
.globl vector171
vector171:
  pushl $0
80105b65:	6a 00                	push   $0x0
  pushl $171
80105b67:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105b6c:	e9 2f f5 ff ff       	jmp    801050a0 <alltraps>

80105b71 <vector172>:
.globl vector172
vector172:
  pushl $0
80105b71:	6a 00                	push   $0x0
  pushl $172
80105b73:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105b78:	e9 23 f5 ff ff       	jmp    801050a0 <alltraps>

80105b7d <vector173>:
.globl vector173
vector173:
  pushl $0
80105b7d:	6a 00                	push   $0x0
  pushl $173
80105b7f:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105b84:	e9 17 f5 ff ff       	jmp    801050a0 <alltraps>

80105b89 <vector174>:
.globl vector174
vector174:
  pushl $0
80105b89:	6a 00                	push   $0x0
  pushl $174
80105b8b:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105b90:	e9 0b f5 ff ff       	jmp    801050a0 <alltraps>

80105b95 <vector175>:
.globl vector175
vector175:
  pushl $0
80105b95:	6a 00                	push   $0x0
  pushl $175
80105b97:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105b9c:	e9 ff f4 ff ff       	jmp    801050a0 <alltraps>

80105ba1 <vector176>:
.globl vector176
vector176:
  pushl $0
80105ba1:	6a 00                	push   $0x0
  pushl $176
80105ba3:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105ba8:	e9 f3 f4 ff ff       	jmp    801050a0 <alltraps>

80105bad <vector177>:
.globl vector177
vector177:
  pushl $0
80105bad:	6a 00                	push   $0x0
  pushl $177
80105baf:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105bb4:	e9 e7 f4 ff ff       	jmp    801050a0 <alltraps>

80105bb9 <vector178>:
.globl vector178
vector178:
  pushl $0
80105bb9:	6a 00                	push   $0x0
  pushl $178
80105bbb:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105bc0:	e9 db f4 ff ff       	jmp    801050a0 <alltraps>

80105bc5 <vector179>:
.globl vector179
vector179:
  pushl $0
80105bc5:	6a 00                	push   $0x0
  pushl $179
80105bc7:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105bcc:	e9 cf f4 ff ff       	jmp    801050a0 <alltraps>

80105bd1 <vector180>:
.globl vector180
vector180:
  pushl $0
80105bd1:	6a 00                	push   $0x0
  pushl $180
80105bd3:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105bd8:	e9 c3 f4 ff ff       	jmp    801050a0 <alltraps>

80105bdd <vector181>:
.globl vector181
vector181:
  pushl $0
80105bdd:	6a 00                	push   $0x0
  pushl $181
80105bdf:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105be4:	e9 b7 f4 ff ff       	jmp    801050a0 <alltraps>

80105be9 <vector182>:
.globl vector182
vector182:
  pushl $0
80105be9:	6a 00                	push   $0x0
  pushl $182
80105beb:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105bf0:	e9 ab f4 ff ff       	jmp    801050a0 <alltraps>

80105bf5 <vector183>:
.globl vector183
vector183:
  pushl $0
80105bf5:	6a 00                	push   $0x0
  pushl $183
80105bf7:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105bfc:	e9 9f f4 ff ff       	jmp    801050a0 <alltraps>

80105c01 <vector184>:
.globl vector184
vector184:
  pushl $0
80105c01:	6a 00                	push   $0x0
  pushl $184
80105c03:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105c08:	e9 93 f4 ff ff       	jmp    801050a0 <alltraps>

80105c0d <vector185>:
.globl vector185
vector185:
  pushl $0
80105c0d:	6a 00                	push   $0x0
  pushl $185
80105c0f:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105c14:	e9 87 f4 ff ff       	jmp    801050a0 <alltraps>

80105c19 <vector186>:
.globl vector186
vector186:
  pushl $0
80105c19:	6a 00                	push   $0x0
  pushl $186
80105c1b:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105c20:	e9 7b f4 ff ff       	jmp    801050a0 <alltraps>

80105c25 <vector187>:
.globl vector187
vector187:
  pushl $0
80105c25:	6a 00                	push   $0x0
  pushl $187
80105c27:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105c2c:	e9 6f f4 ff ff       	jmp    801050a0 <alltraps>

80105c31 <vector188>:
.globl vector188
vector188:
  pushl $0
80105c31:	6a 00                	push   $0x0
  pushl $188
80105c33:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105c38:	e9 63 f4 ff ff       	jmp    801050a0 <alltraps>

80105c3d <vector189>:
.globl vector189
vector189:
  pushl $0
80105c3d:	6a 00                	push   $0x0
  pushl $189
80105c3f:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105c44:	e9 57 f4 ff ff       	jmp    801050a0 <alltraps>

80105c49 <vector190>:
.globl vector190
vector190:
  pushl $0
80105c49:	6a 00                	push   $0x0
  pushl $190
80105c4b:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105c50:	e9 4b f4 ff ff       	jmp    801050a0 <alltraps>

80105c55 <vector191>:
.globl vector191
vector191:
  pushl $0
80105c55:	6a 00                	push   $0x0
  pushl $191
80105c57:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105c5c:	e9 3f f4 ff ff       	jmp    801050a0 <alltraps>

80105c61 <vector192>:
.globl vector192
vector192:
  pushl $0
80105c61:	6a 00                	push   $0x0
  pushl $192
80105c63:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105c68:	e9 33 f4 ff ff       	jmp    801050a0 <alltraps>

80105c6d <vector193>:
.globl vector193
vector193:
  pushl $0
80105c6d:	6a 00                	push   $0x0
  pushl $193
80105c6f:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105c74:	e9 27 f4 ff ff       	jmp    801050a0 <alltraps>

80105c79 <vector194>:
.globl vector194
vector194:
  pushl $0
80105c79:	6a 00                	push   $0x0
  pushl $194
80105c7b:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105c80:	e9 1b f4 ff ff       	jmp    801050a0 <alltraps>

80105c85 <vector195>:
.globl vector195
vector195:
  pushl $0
80105c85:	6a 00                	push   $0x0
  pushl $195
80105c87:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105c8c:	e9 0f f4 ff ff       	jmp    801050a0 <alltraps>

80105c91 <vector196>:
.globl vector196
vector196:
  pushl $0
80105c91:	6a 00                	push   $0x0
  pushl $196
80105c93:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105c98:	e9 03 f4 ff ff       	jmp    801050a0 <alltraps>

80105c9d <vector197>:
.globl vector197
vector197:
  pushl $0
80105c9d:	6a 00                	push   $0x0
  pushl $197
80105c9f:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105ca4:	e9 f7 f3 ff ff       	jmp    801050a0 <alltraps>

80105ca9 <vector198>:
.globl vector198
vector198:
  pushl $0
80105ca9:	6a 00                	push   $0x0
  pushl $198
80105cab:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105cb0:	e9 eb f3 ff ff       	jmp    801050a0 <alltraps>

80105cb5 <vector199>:
.globl vector199
vector199:
  pushl $0
80105cb5:	6a 00                	push   $0x0
  pushl $199
80105cb7:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105cbc:	e9 df f3 ff ff       	jmp    801050a0 <alltraps>

80105cc1 <vector200>:
.globl vector200
vector200:
  pushl $0
80105cc1:	6a 00                	push   $0x0
  pushl $200
80105cc3:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105cc8:	e9 d3 f3 ff ff       	jmp    801050a0 <alltraps>

80105ccd <vector201>:
.globl vector201
vector201:
  pushl $0
80105ccd:	6a 00                	push   $0x0
  pushl $201
80105ccf:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105cd4:	e9 c7 f3 ff ff       	jmp    801050a0 <alltraps>

80105cd9 <vector202>:
.globl vector202
vector202:
  pushl $0
80105cd9:	6a 00                	push   $0x0
  pushl $202
80105cdb:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105ce0:	e9 bb f3 ff ff       	jmp    801050a0 <alltraps>

80105ce5 <vector203>:
.globl vector203
vector203:
  pushl $0
80105ce5:	6a 00                	push   $0x0
  pushl $203
80105ce7:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105cec:	e9 af f3 ff ff       	jmp    801050a0 <alltraps>

80105cf1 <vector204>:
.globl vector204
vector204:
  pushl $0
80105cf1:	6a 00                	push   $0x0
  pushl $204
80105cf3:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105cf8:	e9 a3 f3 ff ff       	jmp    801050a0 <alltraps>

80105cfd <vector205>:
.globl vector205
vector205:
  pushl $0
80105cfd:	6a 00                	push   $0x0
  pushl $205
80105cff:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105d04:	e9 97 f3 ff ff       	jmp    801050a0 <alltraps>

80105d09 <vector206>:
.globl vector206
vector206:
  pushl $0
80105d09:	6a 00                	push   $0x0
  pushl $206
80105d0b:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105d10:	e9 8b f3 ff ff       	jmp    801050a0 <alltraps>

80105d15 <vector207>:
.globl vector207
vector207:
  pushl $0
80105d15:	6a 00                	push   $0x0
  pushl $207
80105d17:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105d1c:	e9 7f f3 ff ff       	jmp    801050a0 <alltraps>

80105d21 <vector208>:
.globl vector208
vector208:
  pushl $0
80105d21:	6a 00                	push   $0x0
  pushl $208
80105d23:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105d28:	e9 73 f3 ff ff       	jmp    801050a0 <alltraps>

80105d2d <vector209>:
.globl vector209
vector209:
  pushl $0
80105d2d:	6a 00                	push   $0x0
  pushl $209
80105d2f:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105d34:	e9 67 f3 ff ff       	jmp    801050a0 <alltraps>

80105d39 <vector210>:
.globl vector210
vector210:
  pushl $0
80105d39:	6a 00                	push   $0x0
  pushl $210
80105d3b:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105d40:	e9 5b f3 ff ff       	jmp    801050a0 <alltraps>

80105d45 <vector211>:
.globl vector211
vector211:
  pushl $0
80105d45:	6a 00                	push   $0x0
  pushl $211
80105d47:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105d4c:	e9 4f f3 ff ff       	jmp    801050a0 <alltraps>

80105d51 <vector212>:
.globl vector212
vector212:
  pushl $0
80105d51:	6a 00                	push   $0x0
  pushl $212
80105d53:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105d58:	e9 43 f3 ff ff       	jmp    801050a0 <alltraps>

80105d5d <vector213>:
.globl vector213
vector213:
  pushl $0
80105d5d:	6a 00                	push   $0x0
  pushl $213
80105d5f:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105d64:	e9 37 f3 ff ff       	jmp    801050a0 <alltraps>

80105d69 <vector214>:
.globl vector214
vector214:
  pushl $0
80105d69:	6a 00                	push   $0x0
  pushl $214
80105d6b:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105d70:	e9 2b f3 ff ff       	jmp    801050a0 <alltraps>

80105d75 <vector215>:
.globl vector215
vector215:
  pushl $0
80105d75:	6a 00                	push   $0x0
  pushl $215
80105d77:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105d7c:	e9 1f f3 ff ff       	jmp    801050a0 <alltraps>

80105d81 <vector216>:
.globl vector216
vector216:
  pushl $0
80105d81:	6a 00                	push   $0x0
  pushl $216
80105d83:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105d88:	e9 13 f3 ff ff       	jmp    801050a0 <alltraps>

80105d8d <vector217>:
.globl vector217
vector217:
  pushl $0
80105d8d:	6a 00                	push   $0x0
  pushl $217
80105d8f:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105d94:	e9 07 f3 ff ff       	jmp    801050a0 <alltraps>

80105d99 <vector218>:
.globl vector218
vector218:
  pushl $0
80105d99:	6a 00                	push   $0x0
  pushl $218
80105d9b:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105da0:	e9 fb f2 ff ff       	jmp    801050a0 <alltraps>

80105da5 <vector219>:
.globl vector219
vector219:
  pushl $0
80105da5:	6a 00                	push   $0x0
  pushl $219
80105da7:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105dac:	e9 ef f2 ff ff       	jmp    801050a0 <alltraps>

80105db1 <vector220>:
.globl vector220
vector220:
  pushl $0
80105db1:	6a 00                	push   $0x0
  pushl $220
80105db3:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105db8:	e9 e3 f2 ff ff       	jmp    801050a0 <alltraps>

80105dbd <vector221>:
.globl vector221
vector221:
  pushl $0
80105dbd:	6a 00                	push   $0x0
  pushl $221
80105dbf:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105dc4:	e9 d7 f2 ff ff       	jmp    801050a0 <alltraps>

80105dc9 <vector222>:
.globl vector222
vector222:
  pushl $0
80105dc9:	6a 00                	push   $0x0
  pushl $222
80105dcb:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105dd0:	e9 cb f2 ff ff       	jmp    801050a0 <alltraps>

80105dd5 <vector223>:
.globl vector223
vector223:
  pushl $0
80105dd5:	6a 00                	push   $0x0
  pushl $223
80105dd7:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105ddc:	e9 bf f2 ff ff       	jmp    801050a0 <alltraps>

80105de1 <vector224>:
.globl vector224
vector224:
  pushl $0
80105de1:	6a 00                	push   $0x0
  pushl $224
80105de3:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105de8:	e9 b3 f2 ff ff       	jmp    801050a0 <alltraps>

80105ded <vector225>:
.globl vector225
vector225:
  pushl $0
80105ded:	6a 00                	push   $0x0
  pushl $225
80105def:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105df4:	e9 a7 f2 ff ff       	jmp    801050a0 <alltraps>

80105df9 <vector226>:
.globl vector226
vector226:
  pushl $0
80105df9:	6a 00                	push   $0x0
  pushl $226
80105dfb:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105e00:	e9 9b f2 ff ff       	jmp    801050a0 <alltraps>

80105e05 <vector227>:
.globl vector227
vector227:
  pushl $0
80105e05:	6a 00                	push   $0x0
  pushl $227
80105e07:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105e0c:	e9 8f f2 ff ff       	jmp    801050a0 <alltraps>

80105e11 <vector228>:
.globl vector228
vector228:
  pushl $0
80105e11:	6a 00                	push   $0x0
  pushl $228
80105e13:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105e18:	e9 83 f2 ff ff       	jmp    801050a0 <alltraps>

80105e1d <vector229>:
.globl vector229
vector229:
  pushl $0
80105e1d:	6a 00                	push   $0x0
  pushl $229
80105e1f:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105e24:	e9 77 f2 ff ff       	jmp    801050a0 <alltraps>

80105e29 <vector230>:
.globl vector230
vector230:
  pushl $0
80105e29:	6a 00                	push   $0x0
  pushl $230
80105e2b:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105e30:	e9 6b f2 ff ff       	jmp    801050a0 <alltraps>

80105e35 <vector231>:
.globl vector231
vector231:
  pushl $0
80105e35:	6a 00                	push   $0x0
  pushl $231
80105e37:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105e3c:	e9 5f f2 ff ff       	jmp    801050a0 <alltraps>

80105e41 <vector232>:
.globl vector232
vector232:
  pushl $0
80105e41:	6a 00                	push   $0x0
  pushl $232
80105e43:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105e48:	e9 53 f2 ff ff       	jmp    801050a0 <alltraps>

80105e4d <vector233>:
.globl vector233
vector233:
  pushl $0
80105e4d:	6a 00                	push   $0x0
  pushl $233
80105e4f:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105e54:	e9 47 f2 ff ff       	jmp    801050a0 <alltraps>

80105e59 <vector234>:
.globl vector234
vector234:
  pushl $0
80105e59:	6a 00                	push   $0x0
  pushl $234
80105e5b:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105e60:	e9 3b f2 ff ff       	jmp    801050a0 <alltraps>

80105e65 <vector235>:
.globl vector235
vector235:
  pushl $0
80105e65:	6a 00                	push   $0x0
  pushl $235
80105e67:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105e6c:	e9 2f f2 ff ff       	jmp    801050a0 <alltraps>

80105e71 <vector236>:
.globl vector236
vector236:
  pushl $0
80105e71:	6a 00                	push   $0x0
  pushl $236
80105e73:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105e78:	e9 23 f2 ff ff       	jmp    801050a0 <alltraps>

80105e7d <vector237>:
.globl vector237
vector237:
  pushl $0
80105e7d:	6a 00                	push   $0x0
  pushl $237
80105e7f:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105e84:	e9 17 f2 ff ff       	jmp    801050a0 <alltraps>

80105e89 <vector238>:
.globl vector238
vector238:
  pushl $0
80105e89:	6a 00                	push   $0x0
  pushl $238
80105e8b:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105e90:	e9 0b f2 ff ff       	jmp    801050a0 <alltraps>

80105e95 <vector239>:
.globl vector239
vector239:
  pushl $0
80105e95:	6a 00                	push   $0x0
  pushl $239
80105e97:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105e9c:	e9 ff f1 ff ff       	jmp    801050a0 <alltraps>

80105ea1 <vector240>:
.globl vector240
vector240:
  pushl $0
80105ea1:	6a 00                	push   $0x0
  pushl $240
80105ea3:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105ea8:	e9 f3 f1 ff ff       	jmp    801050a0 <alltraps>

80105ead <vector241>:
.globl vector241
vector241:
  pushl $0
80105ead:	6a 00                	push   $0x0
  pushl $241
80105eaf:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105eb4:	e9 e7 f1 ff ff       	jmp    801050a0 <alltraps>

80105eb9 <vector242>:
.globl vector242
vector242:
  pushl $0
80105eb9:	6a 00                	push   $0x0
  pushl $242
80105ebb:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105ec0:	e9 db f1 ff ff       	jmp    801050a0 <alltraps>

80105ec5 <vector243>:
.globl vector243
vector243:
  pushl $0
80105ec5:	6a 00                	push   $0x0
  pushl $243
80105ec7:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105ecc:	e9 cf f1 ff ff       	jmp    801050a0 <alltraps>

80105ed1 <vector244>:
.globl vector244
vector244:
  pushl $0
80105ed1:	6a 00                	push   $0x0
  pushl $244
80105ed3:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105ed8:	e9 c3 f1 ff ff       	jmp    801050a0 <alltraps>

80105edd <vector245>:
.globl vector245
vector245:
  pushl $0
80105edd:	6a 00                	push   $0x0
  pushl $245
80105edf:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105ee4:	e9 b7 f1 ff ff       	jmp    801050a0 <alltraps>

80105ee9 <vector246>:
.globl vector246
vector246:
  pushl $0
80105ee9:	6a 00                	push   $0x0
  pushl $246
80105eeb:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105ef0:	e9 ab f1 ff ff       	jmp    801050a0 <alltraps>

80105ef5 <vector247>:
.globl vector247
vector247:
  pushl $0
80105ef5:	6a 00                	push   $0x0
  pushl $247
80105ef7:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105efc:	e9 9f f1 ff ff       	jmp    801050a0 <alltraps>

80105f01 <vector248>:
.globl vector248
vector248:
  pushl $0
80105f01:	6a 00                	push   $0x0
  pushl $248
80105f03:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105f08:	e9 93 f1 ff ff       	jmp    801050a0 <alltraps>

80105f0d <vector249>:
.globl vector249
vector249:
  pushl $0
80105f0d:	6a 00                	push   $0x0
  pushl $249
80105f0f:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105f14:	e9 87 f1 ff ff       	jmp    801050a0 <alltraps>

80105f19 <vector250>:
.globl vector250
vector250:
  pushl $0
80105f19:	6a 00                	push   $0x0
  pushl $250
80105f1b:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105f20:	e9 7b f1 ff ff       	jmp    801050a0 <alltraps>

80105f25 <vector251>:
.globl vector251
vector251:
  pushl $0
80105f25:	6a 00                	push   $0x0
  pushl $251
80105f27:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105f2c:	e9 6f f1 ff ff       	jmp    801050a0 <alltraps>

80105f31 <vector252>:
.globl vector252
vector252:
  pushl $0
80105f31:	6a 00                	push   $0x0
  pushl $252
80105f33:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105f38:	e9 63 f1 ff ff       	jmp    801050a0 <alltraps>

80105f3d <vector253>:
.globl vector253
vector253:
  pushl $0
80105f3d:	6a 00                	push   $0x0
  pushl $253
80105f3f:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105f44:	e9 57 f1 ff ff       	jmp    801050a0 <alltraps>

80105f49 <vector254>:
.globl vector254
vector254:
  pushl $0
80105f49:	6a 00                	push   $0x0
  pushl $254
80105f4b:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105f50:	e9 4b f1 ff ff       	jmp    801050a0 <alltraps>

80105f55 <vector255>:
.globl vector255
vector255:
  pushl $0
80105f55:	6a 00                	push   $0x0
  pushl $255
80105f57:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105f5c:	e9 3f f1 ff ff       	jmp    801050a0 <alltraps>

80105f61 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105f61:	55                   	push   %ebp
80105f62:	89 e5                	mov    %esp,%ebp
80105f64:	57                   	push   %edi
80105f65:	56                   	push   %esi
80105f66:	53                   	push   %ebx
80105f67:	83 ec 0c             	sub    $0xc,%esp
80105f6a:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105f6c:	c1 ea 16             	shr    $0x16,%edx
80105f6f:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105f72:	8b 37                	mov    (%edi),%esi
80105f74:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105f7a:	74 35                	je     80105fb1 <walkpgdir+0x50>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80105f7c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if (a > KERNBASE)
80105f82:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80105f88:	77 1a                	ja     80105fa4 <walkpgdir+0x43>
    return (char*)a + KERNBASE;
80105f8a:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105f90:	c1 eb 0c             	shr    $0xc,%ebx
80105f93:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
80105f99:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
80105f9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f9f:	5b                   	pop    %ebx
80105fa0:	5e                   	pop    %esi
80105fa1:	5f                   	pop    %edi
80105fa2:	5d                   	pop    %ebp
80105fa3:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80105fa4:	83 ec 0c             	sub    $0xc,%esp
80105fa7:	68 d8 73 10 80       	push   $0x801073d8
80105fac:	e8 ab a3 ff ff       	call   8010035c <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105fb1:	85 c9                	test   %ecx,%ecx
80105fb3:	74 33                	je     80105fe8 <walkpgdir+0x87>
80105fb5:	e8 c5 c1 ff ff       	call   8010217f <kalloc>
80105fba:	89 c6                	mov    %eax,%esi
80105fbc:	85 c0                	test   %eax,%eax
80105fbe:	74 28                	je     80105fe8 <walkpgdir+0x87>
    memset(pgtab, 0, PGSIZE);
80105fc0:	83 ec 04             	sub    $0x4,%esp
80105fc3:	68 00 10 00 00       	push   $0x1000
80105fc8:	6a 00                	push   $0x0
80105fca:	50                   	push   %eax
80105fcb:	e8 71 df ff ff       	call   80103f41 <memset>
    if (a < (void*) KERNBASE)
80105fd0:	83 c4 10             	add    $0x10,%esp
80105fd3:	81 fe ff ff ff 7f    	cmp    $0x7fffffff,%esi
80105fd9:	76 14                	jbe    80105fef <walkpgdir+0x8e>
    return (uint)a - KERNBASE;
80105fdb:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105fe1:	83 c8 07             	or     $0x7,%eax
80105fe4:	89 07                	mov    %eax,(%edi)
80105fe6:	eb a8                	jmp    80105f90 <walkpgdir+0x2f>
      return 0;
80105fe8:	b8 00 00 00 00       	mov    $0x0,%eax
80105fed:	eb ad                	jmp    80105f9c <walkpgdir+0x3b>
        panic("V2P on address < KERNBASE "
80105fef:	83 ec 0c             	sub    $0xc,%esp
80105ff2:	68 a8 70 10 80       	push   $0x801070a8
80105ff7:	e8 60 a3 ff ff       	call   8010035c <panic>

80105ffc <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105ffc:	55                   	push   %ebp
80105ffd:	89 e5                	mov    %esp,%ebp
80105fff:	57                   	push   %edi
80106000:	56                   	push   %esi
80106001:	53                   	push   %ebx
80106002:	83 ec 1c             	sub    $0x1c,%esp
80106005:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106008:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010600b:	89 d3                	mov    %edx,%ebx
8010600d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106013:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80106017:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010601d:	b9 01 00 00 00       	mov    $0x1,%ecx
80106022:	89 da                	mov    %ebx,%edx
80106024:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106027:	e8 35 ff ff ff       	call   80105f61 <walkpgdir>
8010602c:	85 c0                	test   %eax,%eax
8010602e:	74 2e                	je     8010605e <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80106030:	f6 00 01             	testb  $0x1,(%eax)
80106033:	75 1c                	jne    80106051 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80106035:	89 f2                	mov    %esi,%edx
80106037:	0b 55 0c             	or     0xc(%ebp),%edx
8010603a:	83 ca 01             	or     $0x1,%edx
8010603d:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010603f:	39 fb                	cmp    %edi,%ebx
80106041:	74 28                	je     8010606b <mappages+0x6f>
      break;
    a += PGSIZE;
80106043:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80106049:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010604f:	eb cc                	jmp    8010601d <mappages+0x21>
      panic("remap");
80106051:	83 ec 0c             	sub    $0xc,%esp
80106054:	68 38 78 10 80       	push   $0x80107838
80106059:	e8 fe a2 ff ff       	call   8010035c <panic>
      return -1;
8010605e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80106063:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106066:	5b                   	pop    %ebx
80106067:	5e                   	pop    %esi
80106068:	5f                   	pop    %edi
80106069:	5d                   	pop    %ebp
8010606a:	c3                   	ret    
  return 0;
8010606b:	b8 00 00 00 00       	mov    $0x0,%eax
80106070:	eb f1                	jmp    80106063 <mappages+0x67>

80106072 <seginit>:
{
80106072:	f3 0f 1e fb          	endbr32 
80106076:	55                   	push   %ebp
80106077:	89 e5                	mov    %esp,%ebp
80106079:	53                   	push   %ebx
8010607a:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
8010607d:	e8 da d2 ff ff       	call   8010335c <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106082:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106088:	66 c7 80 f8 27 11 80 	movw   $0xffff,-0x7feed808(%eax)
8010608f:	ff ff 
80106091:	66 c7 80 fa 27 11 80 	movw   $0x0,-0x7feed806(%eax)
80106098:	00 00 
8010609a:	c6 80 fc 27 11 80 00 	movb   $0x0,-0x7feed804(%eax)
801060a1:	0f b6 88 fd 27 11 80 	movzbl -0x7feed803(%eax),%ecx
801060a8:	83 e1 f0             	and    $0xfffffff0,%ecx
801060ab:	83 c9 1a             	or     $0x1a,%ecx
801060ae:	83 e1 9f             	and    $0xffffff9f,%ecx
801060b1:	83 c9 80             	or     $0xffffff80,%ecx
801060b4:	88 88 fd 27 11 80    	mov    %cl,-0x7feed803(%eax)
801060ba:	0f b6 88 fe 27 11 80 	movzbl -0x7feed802(%eax),%ecx
801060c1:	83 c9 0f             	or     $0xf,%ecx
801060c4:	83 e1 cf             	and    $0xffffffcf,%ecx
801060c7:	83 c9 c0             	or     $0xffffffc0,%ecx
801060ca:	88 88 fe 27 11 80    	mov    %cl,-0x7feed802(%eax)
801060d0:	c6 80 ff 27 11 80 00 	movb   $0x0,-0x7feed801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801060d7:	66 c7 80 00 28 11 80 	movw   $0xffff,-0x7feed800(%eax)
801060de:	ff ff 
801060e0:	66 c7 80 02 28 11 80 	movw   $0x0,-0x7feed7fe(%eax)
801060e7:	00 00 
801060e9:	c6 80 04 28 11 80 00 	movb   $0x0,-0x7feed7fc(%eax)
801060f0:	0f b6 88 05 28 11 80 	movzbl -0x7feed7fb(%eax),%ecx
801060f7:	83 e1 f0             	and    $0xfffffff0,%ecx
801060fa:	83 c9 12             	or     $0x12,%ecx
801060fd:	83 e1 9f             	and    $0xffffff9f,%ecx
80106100:	83 c9 80             	or     $0xffffff80,%ecx
80106103:	88 88 05 28 11 80    	mov    %cl,-0x7feed7fb(%eax)
80106109:	0f b6 88 06 28 11 80 	movzbl -0x7feed7fa(%eax),%ecx
80106110:	83 c9 0f             	or     $0xf,%ecx
80106113:	83 e1 cf             	and    $0xffffffcf,%ecx
80106116:	83 c9 c0             	or     $0xffffffc0,%ecx
80106119:	88 88 06 28 11 80    	mov    %cl,-0x7feed7fa(%eax)
8010611f:	c6 80 07 28 11 80 00 	movb   $0x0,-0x7feed7f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106126:	66 c7 80 08 28 11 80 	movw   $0xffff,-0x7feed7f8(%eax)
8010612d:	ff ff 
8010612f:	66 c7 80 0a 28 11 80 	movw   $0x0,-0x7feed7f6(%eax)
80106136:	00 00 
80106138:	c6 80 0c 28 11 80 00 	movb   $0x0,-0x7feed7f4(%eax)
8010613f:	c6 80 0d 28 11 80 fa 	movb   $0xfa,-0x7feed7f3(%eax)
80106146:	0f b6 88 0e 28 11 80 	movzbl -0x7feed7f2(%eax),%ecx
8010614d:	83 c9 0f             	or     $0xf,%ecx
80106150:	83 e1 cf             	and    $0xffffffcf,%ecx
80106153:	83 c9 c0             	or     $0xffffffc0,%ecx
80106156:	88 88 0e 28 11 80    	mov    %cl,-0x7feed7f2(%eax)
8010615c:	c6 80 0f 28 11 80 00 	movb   $0x0,-0x7feed7f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106163:	66 c7 80 10 28 11 80 	movw   $0xffff,-0x7feed7f0(%eax)
8010616a:	ff ff 
8010616c:	66 c7 80 12 28 11 80 	movw   $0x0,-0x7feed7ee(%eax)
80106173:	00 00 
80106175:	c6 80 14 28 11 80 00 	movb   $0x0,-0x7feed7ec(%eax)
8010617c:	c6 80 15 28 11 80 f2 	movb   $0xf2,-0x7feed7eb(%eax)
80106183:	0f b6 88 16 28 11 80 	movzbl -0x7feed7ea(%eax),%ecx
8010618a:	83 c9 0f             	or     $0xf,%ecx
8010618d:	83 e1 cf             	and    $0xffffffcf,%ecx
80106190:	83 c9 c0             	or     $0xffffffc0,%ecx
80106193:	88 88 16 28 11 80    	mov    %cl,-0x7feed7ea(%eax)
80106199:	c6 80 17 28 11 80 00 	movb   $0x0,-0x7feed7e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801061a0:	05 f0 27 11 80       	add    $0x801127f0,%eax
  pd[0] = size-1;
801061a5:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
801061ab:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
801061af:	c1 e8 10             	shr    $0x10,%eax
801061b2:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801061b6:	8d 45 f2             	lea    -0xe(%ebp),%eax
801061b9:	0f 01 10             	lgdtl  (%eax)
}
801061bc:	83 c4 14             	add    $0x14,%esp
801061bf:	5b                   	pop    %ebx
801061c0:	5d                   	pop    %ebp
801061c1:	c3                   	ret    

801061c2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801061c2:	f3 0f 1e fb          	endbr32 
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801061c6:	a1 a4 55 11 80       	mov    0x801155a4,%eax
    if (a < (void*) KERNBASE)
801061cb:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801061d0:	76 09                	jbe    801061db <switchkvm+0x19>
    return (uint)a - KERNBASE;
801061d2:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801061d7:	0f 22 d8             	mov    %eax,%cr3
801061da:	c3                   	ret    
{
801061db:	55                   	push   %ebp
801061dc:	89 e5                	mov    %esp,%ebp
801061de:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
801061e1:	68 a8 70 10 80       	push   $0x801070a8
801061e6:	e8 71 a1 ff ff       	call   8010035c <panic>

801061eb <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801061eb:	f3 0f 1e fb          	endbr32 
801061ef:	55                   	push   %ebp
801061f0:	89 e5                	mov    %esp,%ebp
801061f2:	57                   	push   %edi
801061f3:	56                   	push   %esi
801061f4:	53                   	push   %ebx
801061f5:	83 ec 1c             	sub    $0x1c,%esp
801061f8:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801061fb:	85 f6                	test   %esi,%esi
801061fd:	0f 84 e4 00 00 00    	je     801062e7 <switchuvm+0xfc>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106203:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80106207:	0f 84 e7 00 00 00    	je     801062f4 <switchuvm+0x109>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010620d:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80106211:	0f 84 ea 00 00 00    	je     80106301 <switchuvm+0x116>
    panic("switchuvm: no pgdir");

  pushcli();
80106217:	e8 88 db ff ff       	call   80103da4 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010621c:	e8 db d0 ff ff       	call   801032fc <mycpu>
80106221:	89 c3                	mov    %eax,%ebx
80106223:	e8 d4 d0 ff ff       	call   801032fc <mycpu>
80106228:	8d 78 08             	lea    0x8(%eax),%edi
8010622b:	e8 cc d0 ff ff       	call   801032fc <mycpu>
80106230:	83 c0 08             	add    $0x8,%eax
80106233:	c1 e8 10             	shr    $0x10,%eax
80106236:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106239:	e8 be d0 ff ff       	call   801032fc <mycpu>
8010623e:	83 c0 08             	add    $0x8,%eax
80106241:	c1 e8 18             	shr    $0x18,%eax
80106244:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010624b:	67 00 
8010624d:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106254:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106258:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010625e:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106265:	83 e2 f0             	and    $0xfffffff0,%edx
80106268:	83 ca 19             	or     $0x19,%edx
8010626b:	83 e2 9f             	and    $0xffffff9f,%edx
8010626e:	83 ca 80             	or     $0xffffff80,%edx
80106271:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106277:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
8010627e:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106284:	e8 73 d0 ff ff       	call   801032fc <mycpu>
80106289:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106290:	83 e2 ef             	and    $0xffffffef,%edx
80106293:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106299:	e8 5e d0 ff ff       	call   801032fc <mycpu>
8010629e:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801062a4:	8b 5e 08             	mov    0x8(%esi),%ebx
801062a7:	e8 50 d0 ff ff       	call   801032fc <mycpu>
801062ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062b2:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801062b5:	e8 42 d0 ff ff       	call   801032fc <mycpu>
801062ba:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801062c0:	b8 28 00 00 00       	mov    $0x28,%eax
801062c5:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801062c8:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
801062cb:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801062d0:	76 3c                	jbe    8010630e <switchuvm+0x123>
    return (uint)a - KERNBASE;
801062d2:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801062d7:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801062da:	e8 06 db ff ff       	call   80103de5 <popcli>
}
801062df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062e2:	5b                   	pop    %ebx
801062e3:	5e                   	pop    %esi
801062e4:	5f                   	pop    %edi
801062e5:	5d                   	pop    %ebp
801062e6:	c3                   	ret    
    panic("switchuvm: no process");
801062e7:	83 ec 0c             	sub    $0xc,%esp
801062ea:	68 3e 78 10 80       	push   $0x8010783e
801062ef:	e8 68 a0 ff ff       	call   8010035c <panic>
    panic("switchuvm: no kstack");
801062f4:	83 ec 0c             	sub    $0xc,%esp
801062f7:	68 54 78 10 80       	push   $0x80107854
801062fc:	e8 5b a0 ff ff       	call   8010035c <panic>
    panic("switchuvm: no pgdir");
80106301:	83 ec 0c             	sub    $0xc,%esp
80106304:	68 69 78 10 80       	push   $0x80107869
80106309:	e8 4e a0 ff ff       	call   8010035c <panic>
        panic("V2P on address < KERNBASE "
8010630e:	83 ec 0c             	sub    $0xc,%esp
80106311:	68 a8 70 10 80       	push   $0x801070a8
80106316:	e8 41 a0 ff ff       	call   8010035c <panic>

8010631b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010631b:	f3 0f 1e fb          	endbr32 
8010631f:	55                   	push   %ebp
80106320:	89 e5                	mov    %esp,%ebp
80106322:	56                   	push   %esi
80106323:	53                   	push   %ebx
80106324:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106327:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010632d:	77 57                	ja     80106386 <inituvm+0x6b>
    panic("inituvm: more than a page");
  mem = kalloc();
8010632f:	e8 4b be ff ff       	call   8010217f <kalloc>
80106334:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106336:	83 ec 04             	sub    $0x4,%esp
80106339:	68 00 10 00 00       	push   $0x1000
8010633e:	6a 00                	push   $0x0
80106340:	50                   	push   %eax
80106341:	e8 fb db ff ff       	call   80103f41 <memset>
    if (a < (void*) KERNBASE)
80106346:	83 c4 10             	add    $0x10,%esp
80106349:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010634f:	76 42                	jbe    80106393 <inituvm+0x78>
    return (uint)a - KERNBASE;
80106351:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106357:	83 ec 08             	sub    $0x8,%esp
8010635a:	6a 06                	push   $0x6
8010635c:	50                   	push   %eax
8010635d:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106362:	ba 00 00 00 00       	mov    $0x0,%edx
80106367:	8b 45 08             	mov    0x8(%ebp),%eax
8010636a:	e8 8d fc ff ff       	call   80105ffc <mappages>
  memmove(mem, init, sz);
8010636f:	83 c4 0c             	add    $0xc,%esp
80106372:	56                   	push   %esi
80106373:	ff 75 0c             	pushl  0xc(%ebp)
80106376:	53                   	push   %ebx
80106377:	e8 45 dc ff ff       	call   80103fc1 <memmove>
}
8010637c:	83 c4 10             	add    $0x10,%esp
8010637f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106382:	5b                   	pop    %ebx
80106383:	5e                   	pop    %esi
80106384:	5d                   	pop    %ebp
80106385:	c3                   	ret    
    panic("inituvm: more than a page");
80106386:	83 ec 0c             	sub    $0xc,%esp
80106389:	68 7d 78 10 80       	push   $0x8010787d
8010638e:	e8 c9 9f ff ff       	call   8010035c <panic>
        panic("V2P on address < KERNBASE "
80106393:	83 ec 0c             	sub    $0xc,%esp
80106396:	68 a8 70 10 80       	push   $0x801070a8
8010639b:	e8 bc 9f ff ff       	call   8010035c <panic>

801063a0 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801063a0:	f3 0f 1e fb          	endbr32 
801063a4:	55                   	push   %ebp
801063a5:	89 e5                	mov    %esp,%ebp
801063a7:	57                   	push   %edi
801063a8:	56                   	push   %esi
801063a9:	53                   	push   %ebx
801063aa:	83 ec 0c             	sub    $0xc,%esp
801063ad:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801063b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801063b3:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801063b9:	74 43                	je     801063fe <loaduvm+0x5e>
    panic("loaduvm: addr must be page aligned");
801063bb:	83 ec 0c             	sub    $0xc,%esp
801063be:	68 38 79 10 80       	push   $0x80107938
801063c3:	e8 94 9f ff ff       	call   8010035c <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801063c8:	83 ec 0c             	sub    $0xc,%esp
801063cb:	68 97 78 10 80       	push   $0x80107897
801063d0:	e8 87 9f ff ff       	call   8010035c <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801063d5:	89 da                	mov    %ebx,%edx
801063d7:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
801063da:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801063df:	77 51                	ja     80106432 <loaduvm+0x92>
    return (char*)a + KERNBASE;
801063e1:	05 00 00 00 80       	add    $0x80000000,%eax
801063e6:	56                   	push   %esi
801063e7:	52                   	push   %edx
801063e8:	50                   	push   %eax
801063e9:	ff 75 10             	pushl  0x10(%ebp)
801063ec:	e8 e6 b3 ff ff       	call   801017d7 <readi>
801063f1:	83 c4 10             	add    $0x10,%esp
801063f4:	39 f0                	cmp    %esi,%eax
801063f6:	75 54                	jne    8010644c <loaduvm+0xac>
  for(i = 0; i < sz; i += PGSIZE){
801063f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801063fe:	39 fb                	cmp    %edi,%ebx
80106400:	73 3d                	jae    8010643f <loaduvm+0x9f>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106402:	89 da                	mov    %ebx,%edx
80106404:	03 55 0c             	add    0xc(%ebp),%edx
80106407:	b9 00 00 00 00       	mov    $0x0,%ecx
8010640c:	8b 45 08             	mov    0x8(%ebp),%eax
8010640f:	e8 4d fb ff ff       	call   80105f61 <walkpgdir>
80106414:	85 c0                	test   %eax,%eax
80106416:	74 b0                	je     801063c8 <loaduvm+0x28>
    pa = PTE_ADDR(*pte);
80106418:	8b 00                	mov    (%eax),%eax
8010641a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010641f:	89 fe                	mov    %edi,%esi
80106421:	29 de                	sub    %ebx,%esi
80106423:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106429:	76 aa                	jbe    801063d5 <loaduvm+0x35>
      n = PGSIZE;
8010642b:	be 00 10 00 00       	mov    $0x1000,%esi
80106430:	eb a3                	jmp    801063d5 <loaduvm+0x35>
        panic("P2V on address > KERNBASE");
80106432:	83 ec 0c             	sub    $0xc,%esp
80106435:	68 d8 73 10 80       	push   $0x801073d8
8010643a:	e8 1d 9f ff ff       	call   8010035c <panic>
      return -1;
  }
  return 0;
8010643f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106444:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106447:	5b                   	pop    %ebx
80106448:	5e                   	pop    %esi
80106449:	5f                   	pop    %edi
8010644a:	5d                   	pop    %ebp
8010644b:	c3                   	ret    
      return -1;
8010644c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106451:	eb f1                	jmp    80106444 <loaduvm+0xa4>

80106453 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106453:	f3 0f 1e fb          	endbr32 
80106457:	55                   	push   %ebp
80106458:	89 e5                	mov    %esp,%ebp
8010645a:	57                   	push   %edi
8010645b:	56                   	push   %esi
8010645c:	53                   	push   %ebx
8010645d:	83 ec 0c             	sub    $0xc,%esp
80106460:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106463:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106466:	73 11                	jae    80106479 <deallocuvm+0x26>
    return oldsz;

  a = PGROUNDUP(newsz);
80106468:	8b 45 10             	mov    0x10(%ebp),%eax
8010646b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106471:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106477:	eb 19                	jmp    80106492 <deallocuvm+0x3f>
    return oldsz;
80106479:	89 f8                	mov    %edi,%eax
8010647b:	eb 78                	jmp    801064f5 <deallocuvm+0xa2>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010647d:	c1 eb 16             	shr    $0x16,%ebx
80106480:	83 c3 01             	add    $0x1,%ebx
80106483:	c1 e3 16             	shl    $0x16,%ebx
80106486:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010648c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106492:	39 fb                	cmp    %edi,%ebx
80106494:	73 5c                	jae    801064f2 <deallocuvm+0x9f>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106496:	b9 00 00 00 00       	mov    $0x0,%ecx
8010649b:	89 da                	mov    %ebx,%edx
8010649d:	8b 45 08             	mov    0x8(%ebp),%eax
801064a0:	e8 bc fa ff ff       	call   80105f61 <walkpgdir>
801064a5:	89 c6                	mov    %eax,%esi
    if(!pte)
801064a7:	85 c0                	test   %eax,%eax
801064a9:	74 d2                	je     8010647d <deallocuvm+0x2a>
    else if((*pte & PTE_P) != 0){
801064ab:	8b 00                	mov    (%eax),%eax
801064ad:	a8 01                	test   $0x1,%al
801064af:	74 db                	je     8010648c <deallocuvm+0x39>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
801064b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064b6:	74 20                	je     801064d8 <deallocuvm+0x85>
    if (a > KERNBASE)
801064b8:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801064bd:	77 26                	ja     801064e5 <deallocuvm+0x92>
    return (char*)a + KERNBASE;
801064bf:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
801064c4:	83 ec 0c             	sub    $0xc,%esp
801064c7:	50                   	push   %eax
801064c8:	e8 65 bb ff ff       	call   80102032 <kfree>
      *pte = 0;
801064cd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801064d3:	83 c4 10             	add    $0x10,%esp
801064d6:	eb b4                	jmp    8010648c <deallocuvm+0x39>
        panic("kfree");
801064d8:	83 ec 0c             	sub    $0xc,%esp
801064db:	68 36 71 10 80       	push   $0x80107136
801064e0:	e8 77 9e ff ff       	call   8010035c <panic>
        panic("P2V on address > KERNBASE");
801064e5:	83 ec 0c             	sub    $0xc,%esp
801064e8:	68 d8 73 10 80       	push   $0x801073d8
801064ed:	e8 6a 9e ff ff       	call   8010035c <panic>
    }
  }
  return newsz;
801064f2:	8b 45 10             	mov    0x10(%ebp),%eax
}
801064f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064f8:	5b                   	pop    %ebx
801064f9:	5e                   	pop    %esi
801064fa:	5f                   	pop    %edi
801064fb:	5d                   	pop    %ebp
801064fc:	c3                   	ret    

801064fd <allocuvm>:
{
801064fd:	f3 0f 1e fb          	endbr32 
80106501:	55                   	push   %ebp
80106502:	89 e5                	mov    %esp,%ebp
80106504:	57                   	push   %edi
80106505:	56                   	push   %esi
80106506:	53                   	push   %ebx
80106507:	83 ec 1c             	sub    $0x1c,%esp
8010650a:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
8010650d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106510:	85 ff                	test   %edi,%edi
80106512:	0f 88 db 00 00 00    	js     801065f3 <allocuvm+0xf6>
  if(newsz < oldsz)
80106518:	3b 7d 0c             	cmp    0xc(%ebp),%edi
8010651b:	72 11                	jb     8010652e <allocuvm+0x31>
  a = PGROUNDUP(oldsz);
8010651d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106520:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106526:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
8010652c:	eb 49                	jmp    80106577 <allocuvm+0x7a>
    return oldsz;
8010652e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106531:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106534:	e9 c1 00 00 00       	jmp    801065fa <allocuvm+0xfd>
      cprintf("allocuvm out of memory\n");
80106539:	83 ec 0c             	sub    $0xc,%esp
8010653c:	68 b5 78 10 80       	push   $0x801078b5
80106541:	e8 e3 a0 ff ff       	call   80100629 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106546:	83 c4 0c             	add    $0xc,%esp
80106549:	ff 75 0c             	pushl  0xc(%ebp)
8010654c:	57                   	push   %edi
8010654d:	ff 75 08             	pushl  0x8(%ebp)
80106550:	e8 fe fe ff ff       	call   80106453 <deallocuvm>
      return 0;
80106555:	83 c4 10             	add    $0x10,%esp
80106558:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010655f:	e9 96 00 00 00       	jmp    801065fa <allocuvm+0xfd>
        panic("V2P on address < KERNBASE "
80106564:	83 ec 0c             	sub    $0xc,%esp
80106567:	68 a8 70 10 80       	push   $0x801070a8
8010656c:	e8 eb 9d ff ff       	call   8010035c <panic>
  for(; a < newsz; a += PGSIZE){
80106571:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106577:	39 fe                	cmp    %edi,%esi
80106579:	73 7f                	jae    801065fa <allocuvm+0xfd>
    mem = kalloc();
8010657b:	e8 ff bb ff ff       	call   8010217f <kalloc>
80106580:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106582:	85 c0                	test   %eax,%eax
80106584:	74 b3                	je     80106539 <allocuvm+0x3c>
    memset(mem, 0, PGSIZE);
80106586:	83 ec 04             	sub    $0x4,%esp
80106589:	68 00 10 00 00       	push   $0x1000
8010658e:	6a 00                	push   $0x0
80106590:	50                   	push   %eax
80106591:	e8 ab d9 ff ff       	call   80103f41 <memset>
    if (a < (void*) KERNBASE)
80106596:	83 c4 10             	add    $0x10,%esp
80106599:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010659f:	76 c3                	jbe    80106564 <allocuvm+0x67>
    return (uint)a - KERNBASE;
801065a1:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801065a7:	83 ec 08             	sub    $0x8,%esp
801065aa:	6a 06                	push   $0x6
801065ac:	50                   	push   %eax
801065ad:	b9 00 10 00 00       	mov    $0x1000,%ecx
801065b2:	89 f2                	mov    %esi,%edx
801065b4:	8b 45 08             	mov    0x8(%ebp),%eax
801065b7:	e8 40 fa ff ff       	call   80105ffc <mappages>
801065bc:	83 c4 10             	add    $0x10,%esp
801065bf:	85 c0                	test   %eax,%eax
801065c1:	79 ae                	jns    80106571 <allocuvm+0x74>
      cprintf("allocuvm out of memory (2)\n");
801065c3:	83 ec 0c             	sub    $0xc,%esp
801065c6:	68 cd 78 10 80       	push   $0x801078cd
801065cb:	e8 59 a0 ff ff       	call   80100629 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801065d0:	83 c4 0c             	add    $0xc,%esp
801065d3:	ff 75 0c             	pushl  0xc(%ebp)
801065d6:	57                   	push   %edi
801065d7:	ff 75 08             	pushl  0x8(%ebp)
801065da:	e8 74 fe ff ff       	call   80106453 <deallocuvm>
      kfree(mem);
801065df:	89 1c 24             	mov    %ebx,(%esp)
801065e2:	e8 4b ba ff ff       	call   80102032 <kfree>
      return 0;
801065e7:	83 c4 10             	add    $0x10,%esp
801065ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801065f1:	eb 07                	jmp    801065fa <allocuvm+0xfd>
    return 0;
801065f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801065fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106600:	5b                   	pop    %ebx
80106601:	5e                   	pop    %esi
80106602:	5f                   	pop    %edi
80106603:	5d                   	pop    %ebp
80106604:	c3                   	ret    

80106605 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106605:	f3 0f 1e fb          	endbr32 
80106609:	55                   	push   %ebp
8010660a:	89 e5                	mov    %esp,%ebp
8010660c:	56                   	push   %esi
8010660d:	53                   	push   %ebx
8010660e:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106611:	85 f6                	test   %esi,%esi
80106613:	74 1a                	je     8010662f <freevm+0x2a>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106615:	83 ec 04             	sub    $0x4,%esp
80106618:	6a 00                	push   $0x0
8010661a:	68 00 00 00 80       	push   $0x80000000
8010661f:	56                   	push   %esi
80106620:	e8 2e fe ff ff       	call   80106453 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106625:	83 c4 10             	add    $0x10,%esp
80106628:	bb 00 00 00 00       	mov    $0x0,%ebx
8010662d:	eb 1d                	jmp    8010664c <freevm+0x47>
    panic("freevm: no pgdir");
8010662f:	83 ec 0c             	sub    $0xc,%esp
80106632:	68 e9 78 10 80       	push   $0x801078e9
80106637:	e8 20 9d ff ff       	call   8010035c <panic>
        panic("P2V on address > KERNBASE");
8010663c:	83 ec 0c             	sub    $0xc,%esp
8010663f:	68 d8 73 10 80       	push   $0x801073d8
80106644:	e8 13 9d ff ff       	call   8010035c <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106649:	83 c3 01             	add    $0x1,%ebx
8010664c:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106652:	77 26                	ja     8010667a <freevm+0x75>
    if(pgdir[i] & PTE_P){
80106654:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106657:	a8 01                	test   $0x1,%al
80106659:	74 ee                	je     80106649 <freevm+0x44>
8010665b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
80106660:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106665:	77 d5                	ja     8010663c <freevm+0x37>
    return (char*)a + KERNBASE;
80106667:	05 00 00 00 80       	add    $0x80000000,%eax
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
8010666c:	83 ec 0c             	sub    $0xc,%esp
8010666f:	50                   	push   %eax
80106670:	e8 bd b9 ff ff       	call   80102032 <kfree>
80106675:	83 c4 10             	add    $0x10,%esp
80106678:	eb cf                	jmp    80106649 <freevm+0x44>
    }
  }
  kfree((char*)pgdir);
8010667a:	83 ec 0c             	sub    $0xc,%esp
8010667d:	56                   	push   %esi
8010667e:	e8 af b9 ff ff       	call   80102032 <kfree>
}
80106683:	83 c4 10             	add    $0x10,%esp
80106686:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106689:	5b                   	pop    %ebx
8010668a:	5e                   	pop    %esi
8010668b:	5d                   	pop    %ebp
8010668c:	c3                   	ret    

8010668d <setupkvm>:
{
8010668d:	f3 0f 1e fb          	endbr32 
80106691:	55                   	push   %ebp
80106692:	89 e5                	mov    %esp,%ebp
80106694:	56                   	push   %esi
80106695:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106696:	e8 e4 ba ff ff       	call   8010217f <kalloc>
8010669b:	89 c6                	mov    %eax,%esi
8010669d:	85 c0                	test   %eax,%eax
8010669f:	74 55                	je     801066f6 <setupkvm+0x69>
  memset(pgdir, 0, PGSIZE);
801066a1:	83 ec 04             	sub    $0x4,%esp
801066a4:	68 00 10 00 00       	push   $0x1000
801066a9:	6a 00                	push   $0x0
801066ab:	50                   	push   %eax
801066ac:	e8 90 d8 ff ff       	call   80103f41 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801066b1:	83 c4 10             	add    $0x10,%esp
801066b4:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
801066b9:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801066bf:	73 35                	jae    801066f6 <setupkvm+0x69>
                (uint)k->phys_start, k->perm) < 0) {
801066c1:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801066c4:	8b 4b 08             	mov    0x8(%ebx),%ecx
801066c7:	29 c1                	sub    %eax,%ecx
801066c9:	83 ec 08             	sub    $0x8,%esp
801066cc:	ff 73 0c             	pushl  0xc(%ebx)
801066cf:	50                   	push   %eax
801066d0:	8b 13                	mov    (%ebx),%edx
801066d2:	89 f0                	mov    %esi,%eax
801066d4:	e8 23 f9 ff ff       	call   80105ffc <mappages>
801066d9:	83 c4 10             	add    $0x10,%esp
801066dc:	85 c0                	test   %eax,%eax
801066de:	78 05                	js     801066e5 <setupkvm+0x58>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801066e0:	83 c3 10             	add    $0x10,%ebx
801066e3:	eb d4                	jmp    801066b9 <setupkvm+0x2c>
      freevm(pgdir);
801066e5:	83 ec 0c             	sub    $0xc,%esp
801066e8:	56                   	push   %esi
801066e9:	e8 17 ff ff ff       	call   80106605 <freevm>
      return 0;
801066ee:	83 c4 10             	add    $0x10,%esp
801066f1:	be 00 00 00 00       	mov    $0x0,%esi
}
801066f6:	89 f0                	mov    %esi,%eax
801066f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801066fb:	5b                   	pop    %ebx
801066fc:	5e                   	pop    %esi
801066fd:	5d                   	pop    %ebp
801066fe:	c3                   	ret    

801066ff <kvmalloc>:
{
801066ff:	f3 0f 1e fb          	endbr32 
80106703:	55                   	push   %ebp
80106704:	89 e5                	mov    %esp,%ebp
80106706:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106709:	e8 7f ff ff ff       	call   8010668d <setupkvm>
8010670e:	a3 a4 55 11 80       	mov    %eax,0x801155a4
  switchkvm();
80106713:	e8 aa fa ff ff       	call   801061c2 <switchkvm>
}
80106718:	c9                   	leave  
80106719:	c3                   	ret    

8010671a <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010671a:	f3 0f 1e fb          	endbr32 
8010671e:	55                   	push   %ebp
8010671f:	89 e5                	mov    %esp,%ebp
80106721:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106724:	b9 00 00 00 00       	mov    $0x0,%ecx
80106729:	8b 55 0c             	mov    0xc(%ebp),%edx
8010672c:	8b 45 08             	mov    0x8(%ebp),%eax
8010672f:	e8 2d f8 ff ff       	call   80105f61 <walkpgdir>
  if(pte == 0)
80106734:	85 c0                	test   %eax,%eax
80106736:	74 05                	je     8010673d <clearpteu+0x23>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106738:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010673b:	c9                   	leave  
8010673c:	c3                   	ret    
    panic("clearpteu");
8010673d:	83 ec 0c             	sub    $0xc,%esp
80106740:	68 fa 78 10 80       	push   $0x801078fa
80106745:	e8 12 9c ff ff       	call   8010035c <panic>

8010674a <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010674a:	f3 0f 1e fb          	endbr32 
8010674e:	55                   	push   %ebp
8010674f:	89 e5                	mov    %esp,%ebp
80106751:	57                   	push   %edi
80106752:	56                   	push   %esi
80106753:	53                   	push   %ebx
80106754:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106757:	e8 31 ff ff ff       	call   8010668d <setupkvm>
8010675c:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010675f:	85 c0                	test   %eax,%eax
80106761:	0f 84 f2 00 00 00    	je     80106859 <copyuvm+0x10f>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106767:	bf 00 00 00 00       	mov    $0x0,%edi
8010676c:	eb 3a                	jmp    801067a8 <copyuvm+0x5e>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
8010676e:	83 ec 0c             	sub    $0xc,%esp
80106771:	68 04 79 10 80       	push   $0x80107904
80106776:	e8 e1 9b ff ff       	call   8010035c <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
8010677b:	83 ec 0c             	sub    $0xc,%esp
8010677e:	68 1e 79 10 80       	push   $0x8010791e
80106783:	e8 d4 9b ff ff       	call   8010035c <panic>
        panic("P2V on address > KERNBASE");
80106788:	83 ec 0c             	sub    $0xc,%esp
8010678b:	68 d8 73 10 80       	push   $0x801073d8
80106790:	e8 c7 9b ff ff       	call   8010035c <panic>
        panic("V2P on address < KERNBASE "
80106795:	83 ec 0c             	sub    $0xc,%esp
80106798:	68 a8 70 10 80       	push   $0x801070a8
8010679d:	e8 ba 9b ff ff       	call   8010035c <panic>
  for(i = 0; i < sz; i += PGSIZE){
801067a2:	81 c7 00 10 00 00    	add    $0x1000,%edi
801067a8:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801067ab:	0f 83 a8 00 00 00    	jae    80106859 <copyuvm+0x10f>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801067b1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801067b4:	b9 00 00 00 00       	mov    $0x0,%ecx
801067b9:	89 fa                	mov    %edi,%edx
801067bb:	8b 45 08             	mov    0x8(%ebp),%eax
801067be:	e8 9e f7 ff ff       	call   80105f61 <walkpgdir>
801067c3:	85 c0                	test   %eax,%eax
801067c5:	74 a7                	je     8010676e <copyuvm+0x24>
    if(!(*pte & PTE_P))
801067c7:	8b 00                	mov    (%eax),%eax
801067c9:	a8 01                	test   $0x1,%al
801067cb:	74 ae                	je     8010677b <copyuvm+0x31>
801067cd:	89 c6                	mov    %eax,%esi
801067cf:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
801067d5:	25 ff 0f 00 00       	and    $0xfff,%eax
801067da:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
801067dd:	e8 9d b9 ff ff       	call   8010217f <kalloc>
801067e2:	89 c3                	mov    %eax,%ebx
801067e4:	85 c0                	test   %eax,%eax
801067e6:	74 5c                	je     80106844 <copyuvm+0xfa>
    if (a > KERNBASE)
801067e8:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
801067ee:	77 98                	ja     80106788 <copyuvm+0x3e>
    return (char*)a + KERNBASE;
801067f0:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801067f6:	83 ec 04             	sub    $0x4,%esp
801067f9:	68 00 10 00 00       	push   $0x1000
801067fe:	56                   	push   %esi
801067ff:	50                   	push   %eax
80106800:	e8 bc d7 ff ff       	call   80103fc1 <memmove>
    if (a < (void*) KERNBASE)
80106805:	83 c4 10             	add    $0x10,%esp
80106808:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
8010680e:	76 85                	jbe    80106795 <copyuvm+0x4b>
    return (uint)a - KERNBASE;
80106810:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106816:	83 ec 08             	sub    $0x8,%esp
80106819:	ff 75 e0             	pushl  -0x20(%ebp)
8010681c:	50                   	push   %eax
8010681d:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106822:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106825:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106828:	e8 cf f7 ff ff       	call   80105ffc <mappages>
8010682d:	83 c4 10             	add    $0x10,%esp
80106830:	85 c0                	test   %eax,%eax
80106832:	0f 89 6a ff ff ff    	jns    801067a2 <copyuvm+0x58>
      kfree(mem);
80106838:	83 ec 0c             	sub    $0xc,%esp
8010683b:	53                   	push   %ebx
8010683c:	e8 f1 b7 ff ff       	call   80102032 <kfree>
      goto bad;
80106841:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106844:	83 ec 0c             	sub    $0xc,%esp
80106847:	ff 75 dc             	pushl  -0x24(%ebp)
8010684a:	e8 b6 fd ff ff       	call   80106605 <freevm>
  return 0;
8010684f:	83 c4 10             	add    $0x10,%esp
80106852:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106859:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010685c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010685f:	5b                   	pop    %ebx
80106860:	5e                   	pop    %esi
80106861:	5f                   	pop    %edi
80106862:	5d                   	pop    %ebp
80106863:	c3                   	ret    

80106864 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106864:	f3 0f 1e fb          	endbr32 
80106868:	55                   	push   %ebp
80106869:	89 e5                	mov    %esp,%ebp
8010686b:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010686e:	b9 00 00 00 00       	mov    $0x0,%ecx
80106873:	8b 55 0c             	mov    0xc(%ebp),%edx
80106876:	8b 45 08             	mov    0x8(%ebp),%eax
80106879:	e8 e3 f6 ff ff       	call   80105f61 <walkpgdir>
  if((*pte & PTE_P) == 0)
8010687e:	8b 00                	mov    (%eax),%eax
80106880:	a8 01                	test   $0x1,%al
80106882:	74 24                	je     801068a8 <uva2ka+0x44>
    return 0;
  if((*pte & PTE_U) == 0)
80106884:	a8 04                	test   $0x4,%al
80106886:	74 27                	je     801068af <uva2ka+0x4b>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80106888:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
8010688d:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106892:	77 07                	ja     8010689b <uva2ka+0x37>
    return (char*)a + KERNBASE;
80106894:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80106899:	c9                   	leave  
8010689a:	c3                   	ret    
        panic("P2V on address > KERNBASE");
8010689b:	83 ec 0c             	sub    $0xc,%esp
8010689e:	68 d8 73 10 80       	push   $0x801073d8
801068a3:	e8 b4 9a ff ff       	call   8010035c <panic>
    return 0;
801068a8:	b8 00 00 00 00       	mov    $0x0,%eax
801068ad:	eb ea                	jmp    80106899 <uva2ka+0x35>
    return 0;
801068af:	b8 00 00 00 00       	mov    $0x0,%eax
801068b4:	eb e3                	jmp    80106899 <uva2ka+0x35>

801068b6 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801068b6:	f3 0f 1e fb          	endbr32 
801068ba:	55                   	push   %ebp
801068bb:	89 e5                	mov    %esp,%ebp
801068bd:	57                   	push   %edi
801068be:	56                   	push   %esi
801068bf:	53                   	push   %ebx
801068c0:	83 ec 0c             	sub    $0xc,%esp
801068c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801068c6:	eb 25                	jmp    801068ed <copyout+0x37>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801068c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801068cb:	29 f2                	sub    %esi,%edx
801068cd:	01 d0                	add    %edx,%eax
801068cf:	83 ec 04             	sub    $0x4,%esp
801068d2:	53                   	push   %ebx
801068d3:	ff 75 10             	pushl  0x10(%ebp)
801068d6:	50                   	push   %eax
801068d7:	e8 e5 d6 ff ff       	call   80103fc1 <memmove>
    len -= n;
801068dc:	29 df                	sub    %ebx,%edi
    buf += n;
801068de:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801068e1:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801068e7:	89 45 0c             	mov    %eax,0xc(%ebp)
801068ea:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801068ed:	85 ff                	test   %edi,%edi
801068ef:	74 2f                	je     80106920 <copyout+0x6a>
    va0 = (uint)PGROUNDDOWN(va);
801068f1:	8b 75 0c             	mov    0xc(%ebp),%esi
801068f4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801068fa:	83 ec 08             	sub    $0x8,%esp
801068fd:	56                   	push   %esi
801068fe:	ff 75 08             	pushl  0x8(%ebp)
80106901:	e8 5e ff ff ff       	call   80106864 <uva2ka>
    if(pa0 == 0)
80106906:	83 c4 10             	add    $0x10,%esp
80106909:	85 c0                	test   %eax,%eax
8010690b:	74 20                	je     8010692d <copyout+0x77>
    n = PGSIZE - (va - va0);
8010690d:	89 f3                	mov    %esi,%ebx
8010690f:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106912:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106918:	39 df                	cmp    %ebx,%edi
8010691a:	73 ac                	jae    801068c8 <copyout+0x12>
      n = len;
8010691c:	89 fb                	mov    %edi,%ebx
8010691e:	eb a8                	jmp    801068c8 <copyout+0x12>
  }
  return 0;
80106920:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106925:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106928:	5b                   	pop    %ebx
80106929:	5e                   	pop    %esi
8010692a:	5f                   	pop    %edi
8010692b:	5d                   	pop    %ebp
8010692c:	c3                   	ret    
      return -1;
8010692d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106932:	eb f1                	jmp    80106925 <copyout+0x6f>

80106934 <s_cnputs>:
//#include "proc.h"
//#include "x86.h"

// Copy into outbuffer at most n characters of string.
static int s_cnputs(char *outbuffer, int n, const char* string)
{
80106934:	55                   	push   %ebp
80106935:	89 e5                	mov    %esp,%ebp
80106937:	56                   	push   %esi
80106938:	53                   	push   %ebx
80106939:	89 c6                	mov    %eax,%esi
    int count = 0;
8010693b:	b8 00 00 00 00       	mov    $0x0,%eax

    for(; count < n && '\0' != string[count]; ++count)  {
80106940:	39 d0                	cmp    %edx,%eax
80106942:	7d 10                	jge    80106954 <s_cnputs+0x20>
80106944:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
80106948:	84 db                	test   %bl,%bl
8010694a:	74 08                	je     80106954 <s_cnputs+0x20>
        outbuffer[count] = string[count];
8010694c:	88 1c 06             	mov    %bl,(%esi,%eax,1)
    for(; count < n && '\0' != string[count]; ++count)  {
8010694f:	83 c0 01             	add    $0x1,%eax
80106952:	eb ec                	jmp    80106940 <s_cnputs+0xc>
    }
    if(count < n) {
80106954:	39 d0                	cmp    %edx,%eax
80106956:	7d 04                	jge    8010695c <s_cnputs+0x28>
        outbuffer[count] = '\0';
80106958:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
    }
    return count;
}
8010695c:	5b                   	pop    %ebx
8010695d:	5e                   	pop    %esi
8010695e:	5d                   	pop    %ebp
8010695f:	c3                   	ret    

80106960 <nullRead>:

int
nullRead(struct inode *ip, char *dst, int n)
{
80106960:	f3 0f 1e fb          	endbr32 
80106964:	55                   	push   %ebp
80106965:	89 e5                	mov    %esp,%ebp
80106967:	83 ec 08             	sub    $0x8,%esp
    return s_cnputs(dst, n, "NULL");
8010696a:	b9 5b 79 10 80       	mov    $0x8010795b,%ecx
8010696f:	8b 55 10             	mov    0x10(%ebp),%edx
80106972:	8b 45 0c             	mov    0xc(%ebp),%eax
80106975:	e8 ba ff ff ff       	call   80106934 <s_cnputs>
}
8010697a:	c9                   	leave  
8010697b:	c3                   	ret    

8010697c <nullWrite>:

int
nullWrite(struct inode *ip, char *buf, int n)
{
8010697c:	f3 0f 1e fb          	endbr32 
80106980:	55                   	push   %ebp
80106981:	89 e5                	mov    %esp,%ebp
    return n;
}
80106983:	8b 45 10             	mov    0x10(%ebp),%eax
80106986:	5d                   	pop    %ebp
80106987:	c3                   	ret    

80106988 <nullInit>:

void
nullInit(void)
{
80106988:	f3 0f 1e fb          	endbr32 
  devsw[NUL].write = nullWrite;
8010698c:	c7 05 9c 09 11 80 7c 	movl   $0x8010697c,0x8011099c
80106993:	69 10 80 
  devsw[NUL].read = nullRead;
80106996:	c7 05 98 09 11 80 60 	movl   $0x80106960,0x80110998
8010699d:	69 10 80 
801069a0:	c3                   	ret    

801069a1 <s_cnputs>:
//#include "proc.h"
//#include "x86.h"

// Copy into outbuffer at most n characters of string.
static int s_cnputs(char *outbuffer, int n, const char* string)
{
801069a1:	55                   	push   %ebp
801069a2:	89 e5                	mov    %esp,%ebp
801069a4:	56                   	push   %esi
801069a5:	53                   	push   %ebx
801069a6:	89 c6                	mov    %eax,%esi
    int count = 0;
801069a8:	b8 00 00 00 00       	mov    $0x0,%eax

    for(; count < n && '\0' != string[count]; ++count)  {
801069ad:	39 d0                	cmp    %edx,%eax
801069af:	7d 10                	jge    801069c1 <s_cnputs+0x20>
801069b1:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
801069b5:	84 db                	test   %bl,%bl
801069b7:	74 08                	je     801069c1 <s_cnputs+0x20>
        outbuffer[count] = string[count];
801069b9:	88 1c 06             	mov    %bl,(%esi,%eax,1)
    for(; count < n && '\0' != string[count]; ++count)  {
801069bc:	83 c0 01             	add    $0x1,%eax
801069bf:	eb ec                	jmp    801069ad <s_cnputs+0xc>
    }
    if(count < n) {
801069c1:	39 d0                	cmp    %edx,%eax
801069c3:	7d 04                	jge    801069c9 <s_cnputs+0x28>
        outbuffer[count] = '\0';
801069c5:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
    }
    return count;
}
801069c9:	5b                   	pop    %ebx
801069ca:	5e                   	pop    %esi
801069cb:	5d                   	pop    %ebp
801069cc:	c3                   	ret    

801069cd <zeroRead>:

int
zeroRead(struct inode *ip, char *dst, int n)
{
801069cd:	f3 0f 1e fb          	endbr32 
801069d1:	55                   	push   %ebp
801069d2:	89 e5                	mov    %esp,%ebp
801069d4:	83 ec 08             	sub    $0x8,%esp
    return s_cnputs(dst, n, "0");
801069d7:	b9 60 79 10 80       	mov    $0x80107960,%ecx
801069dc:	8b 55 10             	mov    0x10(%ebp),%edx
801069df:	8b 45 0c             	mov    0xc(%ebp),%eax
801069e2:	e8 ba ff ff ff       	call   801069a1 <s_cnputs>
}
801069e7:	c9                   	leave  
801069e8:	c3                   	ret    

801069e9 <zeroWrite>:

int
zeroWrite(struct inode *ip, char *buf, int n)
{
801069e9:	f3 0f 1e fb          	endbr32 
801069ed:	55                   	push   %ebp
801069ee:	89 e5                	mov    %esp,%ebp
    return n;
}
801069f0:	8b 45 10             	mov    0x10(%ebp),%eax
801069f3:	5d                   	pop    %ebp
801069f4:	c3                   	ret    

801069f5 <zeroInit>:

void
zeroInit(void)
{
801069f5:	f3 0f 1e fb          	endbr32 
  devsw[ZERO].write = zeroWrite;
801069f9:	c7 05 a4 09 11 80 e9 	movl   $0x801069e9,0x801109a4
80106a00:	69 10 80 
  devsw[ZERO].read = zeroRead;
80106a03:	c7 05 a0 09 11 80 cd 	movl   $0x801069cd,0x801109a0
80106a0a:	69 10 80 
80106a0d:	c3                   	ret    

80106a0e <s_sputc>:
// file descriptor or a character buffer of at least length characters.
typedef void (*putFunction_t)(int fd, char *outbuffer, uint length, uint index, char c);

// store c at index within outbuffer if index is less than length
void s_sputc(int fd, char *outbuffer, uint length, uint index, char c) 
{
80106a0e:	f3 0f 1e fb          	endbr32 
80106a12:	55                   	push   %ebp
80106a13:	89 e5                	mov    %esp,%ebp
80106a15:	8b 45 14             	mov    0x14(%ebp),%eax
80106a18:	8b 55 18             	mov    0x18(%ebp),%edx
  if(index < length)
80106a1b:	3b 45 10             	cmp    0x10(%ebp),%eax
80106a1e:	73 06                	jae    80106a26 <s_sputc+0x18>
  {
    outbuffer[index] = c;
80106a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106a23:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  }
}
80106a26:	5d                   	pop    %ebp
80106a27:	c3                   	ret    

80106a28 <s_getReverseDigits>:
// "most significant digit on teh left" representation. At most length
// characters are written to outbuf.
// \return the number of characters written to outbuf
static uint 
s_getReverseDigits(char *outbuf, uint length, int xx, int base, int sgn)
{
80106a28:	55                   	push   %ebp
80106a29:	89 e5                	mov    %esp,%ebp
80106a2b:	57                   	push   %edi
80106a2c:	56                   	push   %esi
80106a2d:	53                   	push   %ebx
80106a2e:	83 ec 04             	sub    $0x4,%esp
80106a31:	89 c7                	mov    %eax,%edi
80106a33:	89 d6                	mov    %edx,%esi
80106a35:	89 c8                	mov    %ecx,%eax
  static char digits[] = "0123456789ABCDEF";
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
80106a37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106a3b:	0f 95 c1             	setne  %cl
80106a3e:	89 c2                	mov    %eax,%edx
80106a40:	c1 ea 1f             	shr    $0x1f,%edx
80106a43:	84 d1                	test   %dl,%cl
80106a45:	74 2f                	je     80106a76 <s_getReverseDigits+0x4e>
    neg = 1;
    x = -xx;
80106a47:	f7 d8                	neg    %eax
    neg = 1;
80106a49:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  } else {
    x = xx;
  }

  i = 0;
80106a50:	bb 00 00 00 00       	mov    $0x0,%ebx
  while(i + 1 < length && x != 0) {
80106a55:	8d 4b 01             	lea    0x1(%ebx),%ecx
80106a58:	39 f1                	cmp    %esi,%ecx
80106a5a:	73 23                	jae    80106a7f <s_getReverseDigits+0x57>
80106a5c:	85 c0                	test   %eax,%eax
80106a5e:	74 1f                	je     80106a7f <s_getReverseDigits+0x57>
    outbuf[i++] = digits[x % base];
80106a60:	ba 00 00 00 00       	mov    $0x0,%edx
80106a65:	f7 75 08             	divl   0x8(%ebp)
80106a68:	0f b6 92 68 79 10 80 	movzbl -0x7fef8698(%edx),%edx
80106a6f:	88 14 1f             	mov    %dl,(%edi,%ebx,1)
80106a72:	89 cb                	mov    %ecx,%ebx
80106a74:	eb df                	jmp    80106a55 <s_getReverseDigits+0x2d>
  neg = 0;
80106a76:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106a7d:	eb d1                	jmp    80106a50 <s_getReverseDigits+0x28>
    x /= base;
  }

  if(neg && i < length) {
80106a7f:	39 f3                	cmp    %esi,%ebx
80106a81:	0f 92 c0             	setb   %al
80106a84:	84 45 f0             	test   %al,-0x10(%ebp)
80106a87:	74 06                	je     80106a8f <s_getReverseDigits+0x67>
    outbuf[i++] = '-';
80106a89:	c6 04 1f 2d          	movb   $0x2d,(%edi,%ebx,1)
80106a8d:	89 cb                	mov    %ecx,%ebx
  }

  return i;
}
80106a8f:	89 d8                	mov    %ebx,%eax
80106a91:	83 c4 04             	add    $0x4,%esp
80106a94:	5b                   	pop    %ebx
80106a95:	5e                   	pop    %esi
80106a96:	5f                   	pop    %edi
80106a97:	5d                   	pop    %ebp
80106a98:	c3                   	ret    

80106a99 <s_min>:
  }
  return result;
}

static uint s_min(uint a, uint b) {
  return (a < b) ? a : b;
80106a99:	39 c2                	cmp    %eax,%edx
80106a9b:	0f 46 c2             	cmovbe %edx,%eax
}
80106a9e:	c3                   	ret    

80106a9f <tickswrite>:
//    s_cnputs(dst, n, "Hello, World!");
}

int
tickswrite(struct inode *ip, char *buf, int n)
{
80106a9f:	f3 0f 1e fb          	endbr32 
    return 0;
}
80106aa3:	b8 00 00 00 00       	mov    $0x0,%eax
80106aa8:	c3                   	ret    

80106aa9 <s_printint>:
{
80106aa9:	55                   	push   %ebp
80106aaa:	89 e5                	mov    %esp,%ebp
80106aac:	57                   	push   %edi
80106aad:	56                   	push   %esi
80106aae:	53                   	push   %ebx
80106aaf:	83 ec 2c             	sub    $0x2c,%esp
80106ab2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106ab5:	89 55 d0             	mov    %edx,-0x30(%ebp)
80106ab8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
80106abb:	8b 7d 08             	mov    0x8(%ebp),%edi
  s_getReverseDigits(localBuffer, localBufferLength, xx, base, sgn);
80106abe:	ff 75 14             	pushl  0x14(%ebp)
80106ac1:	ff 75 10             	pushl  0x10(%ebp)
80106ac4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106ac7:	ba 10 00 00 00       	mov    $0x10,%edx
80106acc:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106acf:	e8 54 ff ff ff       	call   80106a28 <s_getReverseDigits>
80106ad4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  int i = result;
80106ad7:	89 c3                	mov    %eax,%ebx
  while(--i >= 0 && j < length) 
80106ad9:	83 c4 08             	add    $0x8,%esp
  int j = 0;
80106adc:	be 00 00 00 00       	mov    $0x0,%esi
  while(--i >= 0 && j < length) 
80106ae1:	83 eb 01             	sub    $0x1,%ebx
80106ae4:	78 22                	js     80106b08 <s_printint+0x5f>
80106ae6:	39 fe                	cmp    %edi,%esi
80106ae8:	73 1e                	jae    80106b08 <s_printint+0x5f>
    putcFunction(fd, outbuf, length, j, localBuffer[i]);
80106aea:	83 ec 0c             	sub    $0xc,%esp
80106aed:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
80106af2:	50                   	push   %eax
80106af3:	56                   	push   %esi
80106af4:	57                   	push   %edi
80106af5:	ff 75 cc             	pushl  -0x34(%ebp)
80106af8:	ff 75 d0             	pushl  -0x30(%ebp)
80106afb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80106afe:	ff d0                	call   *%eax
    j++;
80106b00:	83 c6 01             	add    $0x1,%esi
80106b03:	83 c4 20             	add    $0x20,%esp
80106b06:	eb d9                	jmp    80106ae1 <s_printint+0x38>
}
80106b08:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106b0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b0e:	5b                   	pop    %ebx
80106b0f:	5e                   	pop    %esi
80106b10:	5f                   	pop    %edi
80106b11:	5d                   	pop    %ebp
80106b12:	c3                   	ret    

80106b13 <s_printf>:
{
80106b13:	55                   	push   %ebp
80106b14:	89 e5                	mov    %esp,%ebp
80106b16:	57                   	push   %edi
80106b17:	56                   	push   %esi
80106b18:	53                   	push   %ebx
80106b19:	83 ec 2c             	sub    $0x2c,%esp
80106b1c:	89 45 d8             	mov    %eax,-0x28(%ebp)
80106b1f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80106b22:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  const int length = n -1; // leave room for nul termination
80106b25:	8b 45 08             	mov    0x8(%ebp),%eax
80106b28:	8d 78 ff             	lea    -0x1(%eax),%edi
  state = 0;
80106b2b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(i = 0; fmt[i] && outindex < length; i++) {
80106b32:	bb 00 00 00 00       	mov    $0x0,%ebx
80106b37:	89 f8                	mov    %edi,%eax
80106b39:	89 df                	mov    %ebx,%edi
80106b3b:	89 c6                	mov    %eax,%esi
80106b3d:	eb 20                	jmp    80106b5f <s_printf+0x4c>
        putcFunction(fd, outbuffer, length, outindex++, c);
80106b3f:	8d 43 01             	lea    0x1(%ebx),%eax
80106b42:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106b45:	83 ec 0c             	sub    $0xc,%esp
80106b48:	51                   	push   %ecx
80106b49:	53                   	push   %ebx
80106b4a:	56                   	push   %esi
80106b4b:	ff 75 d0             	pushl  -0x30(%ebp)
80106b4e:	ff 75 d4             	pushl  -0x2c(%ebp)
80106b51:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106b54:	ff d2                	call   *%edx
80106b56:	83 c4 20             	add    $0x20,%esp
80106b59:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  for(i = 0; fmt[i] && outindex < length; i++) {
80106b5c:	83 c7 01             	add    $0x1,%edi
80106b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b62:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80106b66:	84 c0                	test   %al,%al
80106b68:	0f 84 cd 01 00 00    	je     80106d3b <s_printf+0x228>
80106b6e:	89 75 e0             	mov    %esi,-0x20(%ebp)
80106b71:	39 de                	cmp    %ebx,%esi
80106b73:	0f 86 c2 01 00 00    	jbe    80106d3b <s_printf+0x228>
    c = fmt[i] & 0xff;
80106b79:	0f be c8             	movsbl %al,%ecx
80106b7c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80106b7f:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
80106b82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106b86:	75 0a                	jne    80106b92 <s_printf+0x7f>
      if(c == '%') {
80106b88:	83 f8 25             	cmp    $0x25,%eax
80106b8b:	75 b2                	jne    80106b3f <s_printf+0x2c>
        state = '%';
80106b8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b90:	eb ca                	jmp    80106b5c <s_printf+0x49>
    } else if(state == '%'){
80106b92:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80106b96:	75 c4                	jne    80106b5c <s_printf+0x49>
      if(c == 'd'){
80106b98:	83 f8 64             	cmp    $0x64,%eax
80106b9b:	74 6e                	je     80106c0b <s_printf+0xf8>
      } else if(c == 'x' || c == 'p'){
80106b9d:	83 f8 78             	cmp    $0x78,%eax
80106ba0:	0f 94 c1             	sete   %cl
80106ba3:	83 f8 70             	cmp    $0x70,%eax
80106ba6:	0f 94 c2             	sete   %dl
80106ba9:	08 d1                	or     %dl,%cl
80106bab:	0f 85 8e 00 00 00    	jne    80106c3f <s_printf+0x12c>
      } else if(c == 's'){
80106bb1:	83 f8 73             	cmp    $0x73,%eax
80106bb4:	0f 84 b9 00 00 00    	je     80106c73 <s_printf+0x160>
      } else if(c == 'c'){
80106bba:	83 f8 63             	cmp    $0x63,%eax
80106bbd:	0f 84 1a 01 00 00    	je     80106cdd <s_printf+0x1ca>
      } else if(c == '%'){
80106bc3:	83 f8 25             	cmp    $0x25,%eax
80106bc6:	0f 84 44 01 00 00    	je     80106d10 <s_printf+0x1fd>
        putcFunction(fd, outbuffer, length, outindex++, '%');
80106bcc:	8d 43 01             	lea    0x1(%ebx),%eax
80106bcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106bd2:	83 ec 0c             	sub    $0xc,%esp
80106bd5:	6a 25                	push   $0x25
80106bd7:	53                   	push   %ebx
80106bd8:	56                   	push   %esi
80106bd9:	ff 75 d0             	pushl  -0x30(%ebp)
80106bdc:	ff 75 d4             	pushl  -0x2c(%ebp)
80106bdf:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106be2:	ff d0                	call   *%eax
        putcFunction(fd, outbuffer, length, outindex++, c);
80106be4:	83 c3 02             	add    $0x2,%ebx
80106be7:	83 c4 14             	add    $0x14,%esp
80106bea:	ff 75 dc             	pushl  -0x24(%ebp)
80106bed:	ff 75 e4             	pushl  -0x1c(%ebp)
80106bf0:	56                   	push   %esi
80106bf1:	ff 75 d0             	pushl  -0x30(%ebp)
80106bf4:	ff 75 d4             	pushl  -0x2c(%ebp)
80106bf7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106bfa:	ff d0                	call   *%eax
80106bfc:	83 c4 20             	add    $0x20,%esp
      state = 0;
80106bff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106c06:	e9 51 ff ff ff       	jmp    80106b5c <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 10, 1);
80106c0b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106c0e:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
80106c11:	6a 01                	push   $0x1
80106c13:	6a 0a                	push   $0xa
80106c15:	8b 45 10             	mov    0x10(%ebp),%eax
80106c18:	ff 30                	pushl  (%eax)
80106c1a:	89 f0                	mov    %esi,%eax
80106c1c:	29 d8                	sub    %ebx,%eax
80106c1e:	50                   	push   %eax
80106c1f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106c22:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106c25:	e8 7f fe ff ff       	call   80106aa9 <s_printint>
80106c2a:	01 c3                	add    %eax,%ebx
        ap++;
80106c2c:	83 45 10 04          	addl   $0x4,0x10(%ebp)
80106c30:	83 c4 10             	add    $0x10,%esp
      state = 0;
80106c33:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106c3a:	e9 1d ff ff ff       	jmp    80106b5c <s_printf+0x49>
        outindex += s_printint(putcFunction, fd, &outbuffer[outindex], length - outindex, *ap, 16, 0);
80106c3f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106c42:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
80106c45:	6a 00                	push   $0x0
80106c47:	6a 10                	push   $0x10
80106c49:	8b 45 10             	mov    0x10(%ebp),%eax
80106c4c:	ff 30                	pushl  (%eax)
80106c4e:	89 f0                	mov    %esi,%eax
80106c50:	29 d8                	sub    %ebx,%eax
80106c52:	50                   	push   %eax
80106c53:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106c56:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106c59:	e8 4b fe ff ff       	call   80106aa9 <s_printint>
80106c5e:	01 c3                	add    %eax,%ebx
        ap++;
80106c60:	83 45 10 04          	addl   $0x4,0x10(%ebp)
80106c64:	83 c4 10             	add    $0x10,%esp
      state = 0;
80106c67:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106c6e:	e9 e9 fe ff ff       	jmp    80106b5c <s_printf+0x49>
        s = (char*)*ap;
80106c73:	8b 45 10             	mov    0x10(%ebp),%eax
80106c76:	8b 00                	mov    (%eax),%eax
        ap++;
80106c78:	83 45 10 04          	addl   $0x4,0x10(%ebp)
        if(s == 0)
80106c7c:	85 c0                	test   %eax,%eax
80106c7e:	75 4e                	jne    80106cce <s_printf+0x1bb>
          s = "(null)";
80106c80:	b8 98 6e 10 80       	mov    $0x80106e98,%eax
80106c85:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106c88:	89 da                	mov    %ebx,%edx
80106c8a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80106c8d:	89 75 e0             	mov    %esi,-0x20(%ebp)
80106c90:	89 c6                	mov    %eax,%esi
80106c92:	eb 1f                	jmp    80106cb3 <s_printf+0x1a0>
          putcFunction(fd, outbuffer, length, outindex++, *s);
80106c94:	8d 7a 01             	lea    0x1(%edx),%edi
80106c97:	83 ec 0c             	sub    $0xc,%esp
80106c9a:	0f be c0             	movsbl %al,%eax
80106c9d:	50                   	push   %eax
80106c9e:	52                   	push   %edx
80106c9f:	53                   	push   %ebx
80106ca0:	ff 75 d0             	pushl  -0x30(%ebp)
80106ca3:	ff 75 d4             	pushl  -0x2c(%ebp)
80106ca6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106ca9:	ff d0                	call   *%eax
          s++;
80106cab:	83 c6 01             	add    $0x1,%esi
80106cae:	83 c4 20             	add    $0x20,%esp
          putcFunction(fd, outbuffer, length, outindex++, *s);
80106cb1:	89 fa                	mov    %edi,%edx
        while(*s != 0){
80106cb3:	0f b6 06             	movzbl (%esi),%eax
80106cb6:	84 c0                	test   %al,%al
80106cb8:	75 da                	jne    80106c94 <s_printf+0x181>
80106cba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80106cbd:	89 d3                	mov    %edx,%ebx
80106cbf:	8b 75 e0             	mov    -0x20(%ebp),%esi
      state = 0;
80106cc2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106cc9:	e9 8e fe ff ff       	jmp    80106b5c <s_printf+0x49>
80106cce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106cd1:	89 da                	mov    %ebx,%edx
80106cd3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80106cd6:	89 75 e0             	mov    %esi,-0x20(%ebp)
80106cd9:	89 c6                	mov    %eax,%esi
80106cdb:	eb d6                	jmp    80106cb3 <s_printf+0x1a0>
        putcFunction(fd, outbuffer, length, outindex++, *ap);
80106cdd:	8d 43 01             	lea    0x1(%ebx),%eax
80106ce0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106ce3:	83 ec 0c             	sub    $0xc,%esp
80106ce6:	8b 55 10             	mov    0x10(%ebp),%edx
80106ce9:	0f be 02             	movsbl (%edx),%eax
80106cec:	50                   	push   %eax
80106ced:	53                   	push   %ebx
80106cee:	56                   	push   %esi
80106cef:	ff 75 d0             	pushl  -0x30(%ebp)
80106cf2:	ff 75 d4             	pushl  -0x2c(%ebp)
80106cf5:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106cf8:	ff d2                	call   *%edx
        ap++;
80106cfa:	83 45 10 04          	addl   $0x4,0x10(%ebp)
80106cfe:	83 c4 20             	add    $0x20,%esp
        putcFunction(fd, outbuffer, length, outindex++, *ap);
80106d01:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
80106d04:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106d0b:	e9 4c fe ff ff       	jmp    80106b5c <s_printf+0x49>
        putcFunction(fd, outbuffer, length, outindex++, c);
80106d10:	8d 43 01             	lea    0x1(%ebx),%eax
80106d13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106d16:	83 ec 0c             	sub    $0xc,%esp
80106d19:	ff 75 dc             	pushl  -0x24(%ebp)
80106d1c:	53                   	push   %ebx
80106d1d:	56                   	push   %esi
80106d1e:	ff 75 d0             	pushl  -0x30(%ebp)
80106d21:	ff 75 d4             	pushl  -0x2c(%ebp)
80106d24:	8b 55 d8             	mov    -0x28(%ebp),%edx
80106d27:	ff d2                	call   *%edx
80106d29:	83 c4 20             	add    $0x20,%esp
80106d2c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
      state = 0;
80106d2f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106d36:	e9 21 fe ff ff       	jmp    80106b5c <s_printf+0x49>
  return s_min(length, outindex);
80106d3b:	89 da                	mov    %ebx,%edx
80106d3d:	89 f0                	mov    %esi,%eax
80106d3f:	e8 55 fd ff ff       	call   80106a99 <s_min>
}
80106d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106d47:	5b                   	pop    %ebx
80106d48:	5e                   	pop    %esi
80106d49:	5f                   	pop    %edi
80106d4a:	5d                   	pop    %ebp
80106d4b:	c3                   	ret    

80106d4c <snprintf>:
{
80106d4c:	f3 0f 1e fb          	endbr32 
80106d50:	55                   	push   %ebp
80106d51:	89 e5                	mov    %esp,%ebp
80106d53:	56                   	push   %esi
80106d54:	53                   	push   %ebx
80106d55:	8b 75 08             	mov    0x8(%ebp),%esi
80106d58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  const uint count = s_printf(s_sputc, -1, outbuffer, n, fmt, ap);
80106d5b:	83 ec 04             	sub    $0x4,%esp
80106d5e:	8d 45 14             	lea    0x14(%ebp),%eax
80106d61:	50                   	push   %eax
80106d62:	ff 75 10             	pushl  0x10(%ebp)
80106d65:	53                   	push   %ebx
80106d66:	89 f1                	mov    %esi,%ecx
80106d68:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80106d6d:	b8 0e 6a 10 80       	mov    $0x80106a0e,%eax
80106d72:	e8 9c fd ff ff       	call   80106b13 <s_printf>
  if(count < n) {
80106d77:	83 c4 10             	add    $0x10,%esp
80106d7a:	39 c3                	cmp    %eax,%ebx
80106d7c:	76 04                	jbe    80106d82 <snprintf+0x36>
    outbuffer[count] = 0; // Assure nul termination
80106d7e:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
}
80106d82:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106d85:	5b                   	pop    %ebx
80106d86:	5e                   	pop    %esi
80106d87:	5d                   	pop    %ebp
80106d88:	c3                   	ret    

80106d89 <ticksread>:
{
80106d89:	f3 0f 1e fb          	endbr32 
80106d8d:	55                   	push   %ebp
80106d8e:	89 e5                	mov    %esp,%ebp
80106d90:	83 ec 08             	sub    $0x8,%esp
    return snprintf(dst, n, "%d", ticks);
80106d93:	ff 35 a0 55 11 80    	pushl  0x801155a0
80106d99:	68 62 79 10 80       	push   $0x80107962
80106d9e:	ff 75 10             	pushl  0x10(%ebp)
80106da1:	ff 75 0c             	pushl  0xc(%ebp)
80106da4:	e8 a3 ff ff ff       	call   80106d4c <snprintf>
}
80106da9:	c9                   	leave  
80106daa:	c3                   	ret    

80106dab <ticksinit>:

void
ticksinit(void)
{
80106dab:	f3 0f 1e fb          	endbr32 
  devsw[TICKS].write = tickswrite;
80106daf:	c7 05 ac 09 11 80 9f 	movl   $0x80106a9f,0x801109ac
80106db6:	6a 10 80 
  devsw[TICKS].read = ticksread;
80106db9:	c7 05 a8 09 11 80 89 	movl   $0x80106d89,0x801109a8
80106dc0:	6d 10 80 
80106dc3:	c3                   	ret    

80106dc4 <s_cnputs>:
//#include "proc.h"
//#include "x86.h"

// Copy into outbuffer at most n characters of string.
static int s_cnputs(char *outbuffer, int n, const char* string)
{
80106dc4:	55                   	push   %ebp
80106dc5:	89 e5                	mov    %esp,%ebp
80106dc7:	56                   	push   %esi
80106dc8:	53                   	push   %ebx
80106dc9:	89 c6                	mov    %eax,%esi
    int count = 0;
80106dcb:	b8 00 00 00 00       	mov    $0x0,%eax

    for(; count < n && '\0' != string[count]; ++count)  {
80106dd0:	39 d0                	cmp    %edx,%eax
80106dd2:	7d 10                	jge    80106de4 <s_cnputs+0x20>
80106dd4:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
80106dd8:	84 db                	test   %bl,%bl
80106dda:	74 08                	je     80106de4 <s_cnputs+0x20>
        outbuffer[count] = string[count];
80106ddc:	88 1c 06             	mov    %bl,(%esi,%eax,1)
    for(; count < n && '\0' != string[count]; ++count)  {
80106ddf:	83 c0 01             	add    $0x1,%eax
80106de2:	eb ec                	jmp    80106dd0 <s_cnputs+0xc>
    }
    if(count < n) {
80106de4:	39 d0                	cmp    %edx,%eax
80106de6:	7d 04                	jge    80106dec <s_cnputs+0x28>
        outbuffer[count] = '\0';
80106de8:	c6 04 06 00          	movb   $0x0,(%esi,%eax,1)
    }
    return count;
}
80106dec:	5b                   	pop    %ebx
80106ded:	5e                   	pop    %esi
80106dee:	5d                   	pop    %ebp
80106def:	c3                   	ret    

80106df0 <helloread>:

int
helloread(struct inode *ip, char *dst, int n)
{
80106df0:	f3 0f 1e fb          	endbr32 
80106df4:	55                   	push   %ebp
80106df5:	89 e5                	mov    %esp,%ebp
80106df7:	83 ec 08             	sub    $0x8,%esp
    return s_cnputs(dst, n, "Hello, World!");
80106dfa:	b9 79 79 10 80       	mov    $0x80107979,%ecx
80106dff:	8b 55 10             	mov    0x10(%ebp),%edx
80106e02:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e05:	e8 ba ff ff ff       	call   80106dc4 <s_cnputs>
}
80106e0a:	c9                   	leave  
80106e0b:	c3                   	ret    

80106e0c <hellowrite>:

int
hellowrite(struct inode *ip, char *buf, int n)
{
80106e0c:	f3 0f 1e fb          	endbr32 
80106e10:	55                   	push   %ebp
80106e11:	89 e5                	mov    %esp,%ebp
    return n;
}
80106e13:	8b 45 10             	mov    0x10(%ebp),%eax
80106e16:	5d                   	pop    %ebp
80106e17:	c3                   	ret    

80106e18 <helloInit>:

void
helloInit(void)
{
80106e18:	f3 0f 1e fb          	endbr32 
  devsw[HELLO].write = hellowrite;
80106e1c:	c7 05 94 09 11 80 0c 	movl   $0x80106e0c,0x80110994
80106e23:	6e 10 80 
  devsw[HELLO].read = helloread;
80106e26:	c7 05 90 09 11 80 f0 	movl   $0x80106df0,0x80110990
80106e2d:	6d 10 80 
80106e30:	c3                   	ret    
