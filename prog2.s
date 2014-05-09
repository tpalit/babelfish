
prog2:     file format elf64-x86-64

Disassembly of section .text:

00000000004000c0 <_start>:
  4000c0:	48 31 ed             	xor    %rbp,%rbp
  4000c3:	49 89 d1             	mov    %rdx,%r9
  4000c6:	5e                   	pop    %rsi
  4000c7:	48 89 e2             	mov    %rsp,%rdx
  4000ca:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
  4000ce:	48 bf 84 1a 40 00 00 	mov    $0x401a84,%rdi
  4000d5:	00 00 00 
  4000d8:	e8 e0 0d 00 00       	callq  400ebd <__libc_start_main>
  4000dd:	eb fe                	jmp    4000dd <_start+0x1d>
  4000df:	90                   	nop    

00000000004000e0 <idiv_q>:
  4000e0:	55                   	push   %rbp
  4000e1:	48 89 e5             	mov    %rsp,%rbp
  4000e4:	48 81 ec 60 00 00 00 	sub    $0x60,%rsp
  4000eb:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  4000ef:	48 89 75 f0          	mov    %rsi,0xfffffffffffffff0(%rbp)
  4000f3:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4000fa:	00 00 00 
  4000fd:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  400101:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400105:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  400109:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  40010d:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  400111:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400118:	00 00 00 
  40011b:	48 89 45 d0          	mov    %rax,0xffffffffffffffd0(%rbp)
  40011f:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400123:	48 83 f8 00          	cmp    $0x0,%rax
  400127:	0f 8d 82 00 00 00    	jge    4001af <idiv_q+0xcf>
  40012d:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400134:	00 00 00 
  400137:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  40013b:	48 29 c8             	sub    %rcx,%rax
  40013e:	48 89 45 b8          	mov    %rax,0xffffffffffffffb8(%rbp)
  400142:	48 8b 45 b8          	mov    0xffffffffffffffb8(%rbp),%rax
  400146:	48 89 c6             	mov    %rax,%rsi
  400149:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  40014d:	48 89 c7             	mov    %rax,%rdi
  400150:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400157:	00 00 00 
  40015a:	e8 81 ff ff ff       	callq  4000e0 <idiv_q>
  40015f:	48 89 45 c0          	mov    %rax,0xffffffffffffffc0(%rbp)
  400163:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40016a:	00 00 00 
  40016d:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400171:	48 29 c8             	sub    %rcx,%rax
  400174:	48 89 45 b0          	mov    %rax,0xffffffffffffffb0(%rbp)
  400178:	48 8b 45 b0          	mov    0xffffffffffffffb0(%rbp),%rax
  40017c:	48 89 c6             	mov    %rax,%rsi
  40017f:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400183:	48 89 c7             	mov    %rax,%rdi
  400186:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40018d:	00 00 00 
  400190:	e8 65 01 00 00       	callq  4002fa <idiv_r>
  400195:	48 89 45 c8          	mov    %rax,0xffffffffffffffc8(%rbp)
  400199:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4001a0:	00 00 00 
  4001a3:	48 8b 4d c0          	mov    0xffffffffffffffc0(%rbp),%rcx
  4001a7:	48 29 c8             	sub    %rcx,%rax
  4001aa:	e9 46 01 00 00       	jmpq   4002f5 <idiv_q+0x215>
  4001af:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4001b3:	48 83 f8 00          	cmp    $0x0,%rax
  4001b7:	0f 8d af 00 00 00    	jge    40026c <idiv_q+0x18c>
  4001bd:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4001c4:	00 00 00 
  4001c7:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  4001cb:	48 29 c8             	sub    %rcx,%rax
  4001ce:	48 89 45 a8          	mov    %rax,0xffffffffffffffa8(%rbp)
  4001d2:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4001d6:	48 89 c6             	mov    %rax,%rsi
  4001d9:	48 8b 45 a8          	mov    0xffffffffffffffa8(%rbp),%rax
  4001dd:	48 89 c7             	mov    %rax,%rdi
  4001e0:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4001e7:	00 00 00 
  4001ea:	e8 f1 fe ff ff       	callq  4000e0 <idiv_q>
  4001ef:	48 89 45 c0          	mov    %rax,0xffffffffffffffc0(%rbp)
  4001f3:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4001fa:	00 00 00 
  4001fd:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  400201:	48 29 c8             	sub    %rcx,%rax
  400204:	48 89 45 a0          	mov    %rax,0xffffffffffffffa0(%rbp)
  400208:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  40020c:	48 89 c6             	mov    %rax,%rsi
  40020f:	48 8b 45 a0          	mov    0xffffffffffffffa0(%rbp),%rax
  400213:	48 89 c7             	mov    %rax,%rdi
  400216:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40021d:	00 00 00 
  400220:	e8 d5 00 00 00       	callq  4002fa <idiv_r>
  400225:	48 89 45 c8          	mov    %rax,0xffffffffffffffc8(%rbp)
  400229:	48 8b 45 c8          	mov    0xffffffffffffffc8(%rbp),%rax
  40022d:	48 83 f8 00          	cmp    $0x0,%rax
  400231:	0f 85 1b 00 00 00    	jne    400252 <idiv_q+0x172>
  400237:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40023e:	00 00 00 
  400241:	48 8b 4d c0          	mov    0xffffffffffffffc0(%rbp),%rcx
  400245:	48 29 c8             	sub    %rcx,%rax
  400248:	e9 a8 00 00 00       	jmpq   4002f5 <idiv_q+0x215>
  40024d:	e9 1a 00 00 00       	jmpq   40026c <idiv_q+0x18c>
  400252:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400259:	00 00 00 
  40025c:	48 8b 4d c0          	mov    0xffffffffffffffc0(%rbp),%rcx
  400260:	48 29 c8             	sub    %rcx,%rax
  400263:	48 83 e8 01          	sub    $0x1,%rax
  400267:	e9 89 00 00 00       	jmpq   4002f5 <idiv_q+0x215>
  40026c:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400270:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  400274:	48 39 c8             	cmp    %rcx,%rax
  400277:	0f 8f 6f 00 00 00    	jg     4002ec <idiv_q+0x20c>
  40027d:	48 8b 45 d8          	mov    0xffffffffffffffd8(%rbp),%rax
  400281:	48 c1 e0 01          	shl    $0x1,%rax
  400285:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400289:	48 01 c1             	add    %rax,%rcx
  40028c:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400290:	48 39 c1             	cmp    %rax,%rcx
  400293:	0f 8f 1d 00 00 00    	jg     4002b6 <idiv_q+0x1d6>
  400299:	48 8b 45 d0          	mov    0xffffffffffffffd0(%rbp),%rax
  40029d:	48 c1 e0 01          	shl    $0x1,%rax
  4002a1:	48 89 45 d0          	mov    %rax,0xffffffffffffffd0(%rbp)
  4002a5:	48 8b 45 d8          	mov    0xffffffffffffffd8(%rbp),%rax
  4002a9:	48 c1 e0 01          	shl    $0x1,%rax
  4002ad:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  4002b1:	e9 16 00 00 00       	jmpq   4002cc <idiv_q+0x1ec>
  4002b6:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4002bd:	00 00 00 
  4002c0:	48 89 45 d0          	mov    %rax,0xffffffffffffffd0(%rbp)
  4002c4:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4002c8:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  4002cc:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  4002d0:	48 8b 4d d0          	mov    0xffffffffffffffd0(%rbp),%rcx
  4002d4:	48 01 c8             	add    %rcx,%rax
  4002d7:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  4002db:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4002df:	48 8b 4d d8          	mov    0xffffffffffffffd8(%rbp),%rcx
  4002e3:	48 01 c8             	add    %rcx,%rax
  4002e6:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  4002ea:	eb 80                	jmp    40026c <idiv_q+0x18c>
  4002ec:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  4002f0:	e9 00 00 00 00       	jmpq   4002f5 <idiv_q+0x215>
  4002f5:	48 89 ec             	mov    %rbp,%rsp
  4002f8:	5d                   	pop    %rbp
  4002f9:	c3                   	retq   

00000000004002fa <idiv_r>:
  4002fa:	55                   	push   %rbp
  4002fb:	48 89 e5             	mov    %rsp,%rbp
  4002fe:	48 81 ec 60 00 00 00 	sub    $0x60,%rsp
  400305:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400309:	48 89 75 f0          	mov    %rsi,0xfffffffffffffff0(%rbp)
  40030d:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400311:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  400315:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400319:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  40031d:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400321:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  400325:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400329:	48 83 f8 00          	cmp    $0x0,%rax
  40032d:	0f 8d 75 00 00 00    	jge    4003a8 <idiv_r+0xae>
  400333:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40033a:	00 00 00 
  40033d:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400341:	48 29 c8             	sub    %rcx,%rax
  400344:	48 89 45 c0          	mov    %rax,0xffffffffffffffc0(%rbp)
  400348:	48 8b 45 c0          	mov    0xffffffffffffffc0(%rbp),%rax
  40034c:	48 89 c6             	mov    %rax,%rsi
  40034f:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400353:	48 89 c7             	mov    %rax,%rdi
  400356:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40035d:	00 00 00 
  400360:	e8 7b fd ff ff       	callq  4000e0 <idiv_q>
  400365:	48 89 45 c8          	mov    %rax,0xffffffffffffffc8(%rbp)
  400369:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400370:	00 00 00 
  400373:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400377:	48 29 c8             	sub    %rcx,%rax
  40037a:	48 89 45 b8          	mov    %rax,0xffffffffffffffb8(%rbp)
  40037e:	48 8b 45 b8          	mov    0xffffffffffffffb8(%rbp),%rax
  400382:	48 89 c6             	mov    %rax,%rsi
  400385:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400389:	48 89 c7             	mov    %rax,%rdi
  40038c:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400393:	00 00 00 
  400396:	e8 5f ff ff ff       	callq  4002fa <idiv_r>
  40039b:	48 89 45 d0          	mov    %rax,0xffffffffffffffd0(%rbp)
  40039f:	48 8b 45 d0          	mov    0xffffffffffffffd0(%rbp),%rax
  4003a3:	e9 15 01 00 00       	jmpq   4004bd <idiv_r+0x1c3>
  4003a8:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4003ac:	48 83 f8 00          	cmp    $0x0,%rax
  4003b0:	0f 8d 98 00 00 00    	jge    40044e <idiv_r+0x154>
  4003b6:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4003bd:	00 00 00 
  4003c0:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  4003c4:	48 29 c8             	sub    %rcx,%rax
  4003c7:	48 89 45 b0          	mov    %rax,0xffffffffffffffb0(%rbp)
  4003cb:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4003cf:	48 89 c6             	mov    %rax,%rsi
  4003d2:	48 8b 45 b0          	mov    0xffffffffffffffb0(%rbp),%rax
  4003d6:	48 89 c7             	mov    %rax,%rdi
  4003d9:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4003e0:	00 00 00 
  4003e3:	e8 f8 fc ff ff       	callq  4000e0 <idiv_q>
  4003e8:	48 89 45 c8          	mov    %rax,0xffffffffffffffc8(%rbp)
  4003ec:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4003f3:	00 00 00 
  4003f6:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  4003fa:	48 29 c8             	sub    %rcx,%rax
  4003fd:	48 89 45 a8          	mov    %rax,0xffffffffffffffa8(%rbp)
  400401:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400405:	48 89 c6             	mov    %rax,%rsi
  400408:	48 8b 45 a8          	mov    0xffffffffffffffa8(%rbp),%rax
  40040c:	48 89 c7             	mov    %rax,%rdi
  40040f:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400416:	00 00 00 
  400419:	e8 dc fe ff ff       	callq  4002fa <idiv_r>
  40041e:	48 89 45 d0          	mov    %rax,0xffffffffffffffd0(%rbp)
  400422:	48 8b 45 d0          	mov    0xffffffffffffffd0(%rbp),%rax
  400426:	48 83 f8 00          	cmp    $0x0,%rax
  40042a:	0f 85 0e 00 00 00    	jne    40043e <idiv_r+0x144>
  400430:	48 8b 45 d0          	mov    0xffffffffffffffd0(%rbp),%rax
  400434:	e9 84 00 00 00       	jmpq   4004bd <idiv_r+0x1c3>
  400439:	e9 10 00 00 00       	jmpq   40044e <idiv_r+0x154>
  40043e:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400442:	48 8b 4d d0          	mov    0xffffffffffffffd0(%rbp),%rcx
  400446:	48 29 c8             	sub    %rcx,%rax
  400449:	e9 6f 00 00 00       	jmpq   4004bd <idiv_r+0x1c3>
  40044e:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400452:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  400456:	48 39 c8             	cmp    %rcx,%rax
  400459:	0f 8f 55 00 00 00    	jg     4004b4 <idiv_r+0x1ba>
  40045f:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400463:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400467:	48 29 c8             	sub    %rcx,%rax
  40046a:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  40046e:	48 8b 45 d8          	mov    0xffffffffffffffd8(%rbp),%rax
  400472:	48 c1 e0 01          	shl    $0x1,%rax
  400476:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  40047a:	48 01 c1             	add    %rax,%rcx
  40047d:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400481:	48 39 c1             	cmp    %rax,%rcx
  400484:	0f 8f 11 00 00 00    	jg     40049b <idiv_r+0x1a1>
  40048a:	48 8b 45 d8          	mov    0xffffffffffffffd8(%rbp),%rax
  40048e:	48 c1 e0 01          	shl    $0x1,%rax
  400492:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  400496:	e9 08 00 00 00       	jmpq   4004a3 <idiv_r+0x1a9>
  40049b:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  40049f:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  4004a3:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4004a7:	48 8b 4d d8          	mov    0xffffffffffffffd8(%rbp),%rcx
  4004ab:	48 01 c8             	add    %rcx,%rax
  4004ae:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  4004b2:	eb 9a                	jmp    40044e <idiv_r+0x154>
  4004b4:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  4004b8:	e9 00 00 00 00       	jmpq   4004bd <idiv_r+0x1c3>
  4004bd:	48 89 ec             	mov    %rbp,%rsp
  4004c0:	5d                   	pop    %rbp
  4004c1:	c3                   	retq   

00000000004004c2 <llexit>:
  4004c2:	55                   	push   %rbp
  4004c3:	48 89 e5             	mov    %rsp,%rbp
  4004c6:	48 81 ec 10 00 00 00 	sub    $0x10,%rsp
  4004cd:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  4004d1:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4004d5:	48 89 c6             	mov    %rax,%rsi
  4004d8:	48 b8 3c 00 00 00 00 	mov    $0x3c,%rax
  4004df:	00 00 00 
  4004e2:	48 89 c7             	mov    %rax,%rdi
  4004e5:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4004ec:	00 00 00 
  4004ef:	e8 93 0a 00 00       	callq  400f87 <__syscall1>
  4004f4:	48 89 ec             	mov    %rbp,%rsp
  4004f7:	5d                   	pop    %rbp
  4004f8:	c3                   	retq   

00000000004004f9 <llstrlen>:
  4004f9:	55                   	push   %rbp
  4004fa:	48 89 e5             	mov    %rsp,%rbp
  4004fd:	48 81 ec 20 00 00 00 	sub    $0x20,%rsp
  400504:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400508:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  40050c:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  400510:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400514:	48 83 e0 f8          	and    $0xfffffffffffffff8,%rax
  400518:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  40051c:	48 b8 08 00 00 00 00 	mov    $0x8,%rax
  400523:	00 00 00 
  400526:	48 89 c6             	mov    %rax,%rsi
  400529:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  40052d:	48 89 c7             	mov    %rax,%rdi
  400530:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400537:	00 00 00 
  40053a:	e8 bb fd ff ff       	callq  4002fa <idiv_r>
  40053f:	48 b9 00 00 00 00 00 	mov    $0x0,%rcx
  400546:	00 00 00 
  400549:	48 29 c1             	sub    %rax,%rcx
  40054c:	48 89 4d f0          	mov    %rcx,0xfffffffffffffff0(%rbp)
  400550:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400557:	00 00 00 
  40055a:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  40055e:	48 29 c8             	sub    %rcx,%rax
  400561:	48 83 f8 00          	cmp    $0x0,%rax
  400565:	0f 85 0a 00 00 00    	jne    400575 <llstrlen+0x7c>
  40056b:	e9 03 01 00 00       	jmpq   400673 <llstrlen+0x17a>
  400570:	e9 fe 00 00 00       	jmpq   400673 <llstrlen+0x17a>
  400575:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40057c:	00 00 00 
  40057f:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400583:	48 29 c8             	sub    %rcx,%rax
  400586:	48 83 f8 01          	cmp    $0x1,%rax
  40058a:	0f 85 0a 00 00 00    	jne    40059a <llstrlen+0xa1>
  400590:	e9 ff 00 00 00       	jmpq   400694 <llstrlen+0x19b>
  400595:	e9 d9 00 00 00       	jmpq   400673 <llstrlen+0x17a>
  40059a:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4005a1:	00 00 00 
  4005a4:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  4005a8:	48 29 c8             	sub    %rcx,%rax
  4005ab:	48 83 f8 02          	cmp    $0x2,%rax
  4005af:	0f 85 0a 00 00 00    	jne    4005bf <llstrlen+0xc6>
  4005b5:	e9 ff 00 00 00       	jmpq   4006b9 <llstrlen+0x1c0>
  4005ba:	e9 b4 00 00 00       	jmpq   400673 <llstrlen+0x17a>
  4005bf:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4005c6:	00 00 00 
  4005c9:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  4005cd:	48 29 c8             	sub    %rcx,%rax
  4005d0:	48 83 f8 03          	cmp    $0x3,%rax
  4005d4:	0f 85 0a 00 00 00    	jne    4005e4 <llstrlen+0xeb>
  4005da:	e9 ff 00 00 00       	jmpq   4006de <llstrlen+0x1e5>
  4005df:	e9 8f 00 00 00       	jmpq   400673 <llstrlen+0x17a>
  4005e4:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4005eb:	00 00 00 
  4005ee:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  4005f2:	48 29 c8             	sub    %rcx,%rax
  4005f5:	48 83 f8 04          	cmp    $0x4,%rax
  4005f9:	0f 85 0a 00 00 00    	jne    400609 <llstrlen+0x110>
  4005ff:	e9 05 01 00 00       	jmpq   400709 <llstrlen+0x210>
  400604:	e9 6a 00 00 00       	jmpq   400673 <llstrlen+0x17a>
  400609:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400610:	00 00 00 
  400613:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400617:	48 29 c8             	sub    %rcx,%rax
  40061a:	48 83 f8 05          	cmp    $0x5,%rax
  40061e:	0f 85 0a 00 00 00    	jne    40062e <llstrlen+0x135>
  400624:	e9 0b 01 00 00       	jmpq   400734 <llstrlen+0x23b>
  400629:	e9 45 00 00 00       	jmpq   400673 <llstrlen+0x17a>
  40062e:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400635:	00 00 00 
  400638:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  40063c:	48 29 c8             	sub    %rcx,%rax
  40063f:	48 83 f8 06          	cmp    $0x6,%rax
  400643:	0f 85 0a 00 00 00    	jne    400653 <llstrlen+0x15a>
  400649:	e9 11 01 00 00       	jmpq   40075f <llstrlen+0x266>
  40064e:	e9 20 00 00 00       	jmpq   400673 <llstrlen+0x17a>
  400653:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40065a:	00 00 00 
  40065d:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400661:	48 29 c8             	sub    %rcx,%rax
  400664:	48 83 f8 07          	cmp    $0x7,%rax
  400668:	0f 85 05 00 00 00    	jne    400673 <llstrlen+0x17a>
  40066e:	e9 17 01 00 00       	jmpq   40078a <llstrlen+0x291>
  400673:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400677:	48 8b 08             	mov    (%rax),%rcx
  40067a:	48 81 e1 ff 00 00 00 	and    $0xff,%rcx
  400681:	48 83 f9 00          	cmp    $0x0,%rcx
  400685:	0f 85 09 00 00 00    	jne    400694 <llstrlen+0x19b>
  40068b:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  40068f:	e9 3e 01 00 00       	jmpq   4007d2 <llstrlen+0x2d9>
  400694:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400698:	48 8b 08             	mov    (%rax),%rcx
  40069b:	48 81 e1 00 ff 00 00 	and    $0xff00,%rcx
  4006a2:	48 83 f9 00          	cmp    $0x0,%rcx
  4006a6:	0f 85 0d 00 00 00    	jne    4006b9 <llstrlen+0x1c0>
  4006ac:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4006b0:	48 83 c0 01          	add    $0x1,%rax
  4006b4:	e9 19 01 00 00       	jmpq   4007d2 <llstrlen+0x2d9>
  4006b9:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4006bd:	48 8b 08             	mov    (%rax),%rcx
  4006c0:	48 81 e1 00 00 ff 00 	and    $0xff0000,%rcx
  4006c7:	48 83 f9 00          	cmp    $0x0,%rcx
  4006cb:	0f 85 0d 00 00 00    	jne    4006de <llstrlen+0x1e5>
  4006d1:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4006d5:	48 83 c0 02          	add    $0x2,%rax
  4006d9:	e9 f4 00 00 00       	jmpq   4007d2 <llstrlen+0x2d9>
  4006de:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4006e2:	48 8b 08             	mov    (%rax),%rcx
  4006e5:	48 b8 00 00 00 ff 00 	mov    $0xff000000,%rax
  4006ec:	00 00 00 
  4006ef:	48 21 c1             	and    %rax,%rcx
  4006f2:	48 83 f9 00          	cmp    $0x0,%rcx
  4006f6:	0f 85 0d 00 00 00    	jne    400709 <llstrlen+0x210>
  4006fc:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400700:	48 83 c0 03          	add    $0x3,%rax
  400704:	e9 c9 00 00 00       	jmpq   4007d2 <llstrlen+0x2d9>
  400709:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  40070d:	48 8b 08             	mov    (%rax),%rcx
  400710:	48 b8 00 00 00 00 ff 	mov    $0xff00000000,%rax
  400717:	00 00 00 
  40071a:	48 21 c1             	and    %rax,%rcx
  40071d:	48 83 f9 00          	cmp    $0x0,%rcx
  400721:	0f 85 0d 00 00 00    	jne    400734 <llstrlen+0x23b>
  400727:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  40072b:	48 83 c0 04          	add    $0x4,%rax
  40072f:	e9 9e 00 00 00       	jmpq   4007d2 <llstrlen+0x2d9>
  400734:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400738:	48 8b 08             	mov    (%rax),%rcx
  40073b:	48 b8 00 00 00 00 00 	mov    $0xff0000000000,%rax
  400742:	ff 00 00 
  400745:	48 21 c1             	and    %rax,%rcx
  400748:	48 83 f9 00          	cmp    $0x0,%rcx
  40074c:	0f 85 0d 00 00 00    	jne    40075f <llstrlen+0x266>
  400752:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400756:	48 83 c0 05          	add    $0x5,%rax
  40075a:	e9 73 00 00 00       	jmpq   4007d2 <llstrlen+0x2d9>
  40075f:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400763:	48 8b 08             	mov    (%rax),%rcx
  400766:	48 b8 00 00 00 00 00 	mov    $0xff000000000000,%rax
  40076d:	00 ff 00 
  400770:	48 21 c1             	and    %rax,%rcx
  400773:	48 83 f9 00          	cmp    $0x0,%rcx
  400777:	0f 85 0d 00 00 00    	jne    40078a <llstrlen+0x291>
  40077d:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400781:	48 83 c0 06          	add    $0x6,%rax
  400785:	e9 48 00 00 00       	jmpq   4007d2 <llstrlen+0x2d9>
  40078a:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  40078e:	48 8b 08             	mov    (%rax),%rcx
  400791:	48 b8 00 00 00 00 00 	mov    $0xff00000000000000,%rax
  400798:	00 00 ff 
  40079b:	48 21 c1             	and    %rax,%rcx
  40079e:	48 83 f9 00          	cmp    $0x0,%rcx
  4007a2:	0f 85 0d 00 00 00    	jne    4007b5 <llstrlen+0x2bc>
  4007a8:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4007ac:	48 83 c0 07          	add    $0x7,%rax
  4007b0:	e9 1d 00 00 00       	jmpq   4007d2 <llstrlen+0x2d9>
  4007b5:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4007b9:	48 83 c0 08          	add    $0x8,%rax
  4007bd:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  4007c1:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4007c5:	48 83 c0 08          	add    $0x8,%rax
  4007c9:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  4007cd:	e9 a1 fe ff ff       	jmpq   400673 <llstrlen+0x17a>
  4007d2:	48 89 ec             	mov    %rbp,%rsp
  4007d5:	5d                   	pop    %rbp
  4007d6:	c3                   	retq   

00000000004007d7 <puts>:
  4007d7:	55                   	push   %rbp
  4007d8:	48 89 e5             	mov    %rsp,%rbp
  4007db:	48 81 ec 30 00 00 00 	sub    $0x30,%rsp
  4007e2:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  4007e6:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4007ea:	48 89 c7             	mov    %rax,%rdi
  4007ed:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4007f4:	00 00 00 
  4007f7:	e8 fd fc ff ff       	callq  4004f9 <llstrlen>
  4007fc:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400800:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400807:	00 00 00 
  40080a:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  40080e:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400812:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400816:	48 39 c8             	cmp    %rcx,%rax
  400819:	0f 8f 2b 00 00 00    	jg     40084a <puts+0x73>
  40081f:	e9 0e 00 00 00       	jmpq   400832 <puts+0x5b>
  400824:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400828:	48 83 c0 08          	add    $0x8,%rax
  40082c:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  400830:	eb dc                	jmp    40080e <puts+0x37>
  400832:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400836:	48 8b 4d e8          	mov    0xffffffffffffffe8(%rbp),%rcx
  40083a:	48 01 c8             	add    %rcx,%rax
  40083d:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  400841:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400845:	0f ae 38             	clflush (%rax)
  400848:	eb da                	jmp    400824 <puts+0x4d>
  40084a:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  40084e:	48 89 c7             	mov    %rax,%rdi
  400851:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400858:	00 00 00 
  40085b:	e8 99 fc ff ff       	callq  4004f9 <llstrlen>
  400860:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  400864:	48 8b 45 d8          	mov    0xffffffffffffffd8(%rbp),%rax
  400868:	49 89 c3             	mov    %rax,%r11
  40086b:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  40086f:	49 89 c2             	mov    %rax,%r10
  400872:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400879:	00 00 00 
  40087c:	48 89 c6             	mov    %rax,%rsi
  40087f:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400886:	00 00 00 
  400889:	48 89 c7             	mov    %rax,%rdi
  40088c:	4c 89 d2             	mov    %r10,%rdx
  40088f:	4c 89 d9             	mov    %r11,%rcx
  400892:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400899:	00 00 00 
  40089c:	e8 52 07 00 00       	callq  400ff3 <__syscall3>
  4008a1:	e9 00 00 00 00       	jmpq   4008a6 <puts+0xcf>
  4008a6:	48 89 ec             	mov    %rbp,%rsp
  4008a9:	5d                   	pop    %rbp
  4008aa:	c3                   	retq   

00000000004008ab <putchar>:
  4008ab:	55                   	push   %rbp
  4008ac:	48 89 e5             	mov    %rsp,%rbp
  4008af:	48 81 ec 10 00 00 00 	sub    $0x10,%rsp
  4008b6:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  4008ba:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4008be:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  4008c2:	48 8d 45 f0          	lea    0xfffffffffffffff0(%rbp),%rax
  4008c6:	0f ae 38             	clflush (%rax)
  4008c9:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4008d0:	00 00 00 
  4008d3:	49 89 c3             	mov    %rax,%r11
  4008d6:	48 8d 45 f0          	lea    0xfffffffffffffff0(%rbp),%rax
  4008da:	49 89 c2             	mov    %rax,%r10
  4008dd:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4008e4:	00 00 00 
  4008e7:	48 89 c6             	mov    %rax,%rsi
  4008ea:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4008f1:	00 00 00 
  4008f4:	48 89 c7             	mov    %rax,%rdi
  4008f7:	4c 89 d2             	mov    %r10,%rdx
  4008fa:	4c 89 d9             	mov    %r11,%rcx
  4008fd:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400904:	00 00 00 
  400907:	e8 e7 06 00 00       	callq  400ff3 <__syscall3>
  40090c:	e9 00 00 00 00       	jmpq   400911 <putchar+0x66>
  400911:	48 89 ec             	mov    %rbp,%rsp
  400914:	5d                   	pop    %rbp
  400915:	c3                   	retq   

0000000000400916 <malloc>:
  400916:	55                   	push   %rbp
  400917:	48 89 e5             	mov    %rsp,%rbp
  40091a:	48 81 ec 10 00 00 00 	sub    $0x10,%rsp
  400921:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400925:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400929:	48 83 e8 01          	sub    $0x1,%rax
  40092d:	48 c1 e8 03          	shr    $0x3,%rax
  400931:	48 83 c0 01          	add    $0x1,%rax
  400935:	48 c1 e0 03          	shl    $0x3,%rax
  400939:	48 89 45 f8          	mov    %rax,0xfffffffffffffff8(%rbp)
  40093d:	48 8b 05 1c 15 20 00 	mov    2102556(%rip),%rax        # 601e60 <_main+0x2003dc>
  400944:	48 8b 00             	mov    (%rax),%rax
  400947:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  40094b:	48 01 c8             	add    %rcx,%rax
  40094e:	4c 8b 1d 0b 15 20 00 	mov    2102539(%rip),%r11        # 601e60 <_main+0x2003dc>
  400955:	49 89 03             	mov    %rax,(%r11)
  400958:	48 8b 05 01 15 20 00 	mov    2102529(%rip),%rax        # 601e60 <_main+0x2003dc>
  40095f:	48 8b 00             	mov    (%rax),%rax
  400962:	48 89 c6             	mov    %rax,%rsi
  400965:	48 b8 0c 00 00 00 00 	mov    $0xc,%rax
  40096c:	00 00 00 
  40096f:	48 89 c7             	mov    %rax,%rdi
  400972:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400979:	00 00 00 
  40097c:	e8 06 06 00 00       	callq  400f87 <__syscall1>
  400981:	48 8b 05 d8 14 20 00 	mov    2102488(%rip),%rax        # 601e60 <_main+0x2003dc>
  400988:	48 8b 00             	mov    (%rax),%rax
  40098b:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  40098f:	48 29 c8             	sub    %rcx,%rax
  400992:	e9 00 00 00 00       	jmpq   400997 <malloc+0x81>
  400997:	48 89 ec             	mov    %rbp,%rsp
  40099a:	5d                   	pop    %rbp
  40099b:	c3                   	retq   

000000000040099c <isspace>:
  40099c:	55                   	push   %rbp
  40099d:	48 89 e5             	mov    %rsp,%rbp
  4009a0:	48 81 ec 10 00 00 00 	sub    $0x10,%rsp
  4009a7:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  4009ab:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4009af:	48 83 e8 09          	sub    $0x9,%rax
  4009b3:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  4009b7:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4009bb:	48 83 f8 20          	cmp    $0x20,%rax
  4009bf:	0f 85 0f 00 00 00    	jne    4009d4 <isspace+0x38>
  4009c5:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4009cc:	00 00 00 
  4009cf:	e9 31 00 00 00       	jmpq   400a05 <isspace+0x69>
  4009d4:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4009d8:	48 83 f8 05          	cmp    $0x5,%rax
  4009dc:	0f 83 14 00 00 00    	jae    4009f6 <isspace+0x5a>
  4009e2:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4009e9:	00 00 00 
  4009ec:	e9 14 00 00 00       	jmpq   400a05 <isspace+0x69>
  4009f1:	e9 0f 00 00 00       	jmpq   400a05 <isspace+0x69>
  4009f6:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4009fd:	00 00 00 
  400a00:	e9 00 00 00 00       	jmpq   400a05 <isspace+0x69>
  400a05:	48 89 ec             	mov    %rbp,%rsp
  400a08:	5d                   	pop    %rbp
  400a09:	c3                   	retq   

0000000000400a0a <isdigit>:
  400a0a:	55                   	push   %rbp
  400a0b:	48 89 e5             	mov    %rsp,%rbp
  400a0e:	48 81 ec 10 00 00 00 	sub    $0x10,%rsp
  400a15:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400a19:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400a1d:	48 83 e8 30          	sub    $0x30,%rax
  400a21:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400a25:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400a29:	48 83 f8 00          	cmp    $0x0,%rax
  400a2d:	0f 83 14 00 00 00    	jae    400a47 <isdigit+0x3d>
  400a33:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400a3a:	00 00 00 
  400a3d:	e9 36 00 00 00       	jmpq   400a78 <isdigit+0x6e>
  400a42:	e9 31 00 00 00       	jmpq   400a78 <isdigit+0x6e>
  400a47:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400a4b:	48 83 f8 0a          	cmp    $0xa,%rax
  400a4f:	0f 83 14 00 00 00    	jae    400a69 <isdigit+0x5f>
  400a55:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400a5c:	00 00 00 
  400a5f:	e9 14 00 00 00       	jmpq   400a78 <isdigit+0x6e>
  400a64:	e9 0f 00 00 00       	jmpq   400a78 <isdigit+0x6e>
  400a69:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400a70:	00 00 00 
  400a73:	e9 00 00 00 00       	jmpq   400a78 <isdigit+0x6e>
  400a78:	48 89 ec             	mov    %rbp,%rsp
  400a7b:	5d                   	pop    %rbp
  400a7c:	c3                   	retq   

0000000000400a7d <LLreadchar>:
  400a7d:	55                   	push   %rbp
  400a7e:	48 89 e5             	mov    %rsp,%rbp
  400a81:	48 81 ec 20 00 00 00 	sub    $0x20,%rsp
  400a88:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400a8c:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400a90:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  400a94:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400a98:	48 83 e0 f8          	and    $0xfffffffffffffff8,%rax
  400a9c:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  400aa0:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400aa4:	48 8b 08             	mov    (%rax),%rcx
  400aa7:	48 89 4d f0          	mov    %rcx,0xfffffffffffffff0(%rbp)
  400aab:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400aaf:	48 83 e0 07          	and    $0x7,%rax
  400ab3:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  400ab7:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400abb:	48 83 f8 00          	cmp    $0x0,%rax
  400abf:	0f 85 0d 00 00 00    	jne    400ad2 <LLreadchar+0x55>
  400ac5:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400ac9:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400acd:	e9 d4 00 00 00       	jmpq   400ba6 <LLreadchar+0x129>
  400ad2:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400ad6:	48 83 f8 01          	cmp    $0x1,%rax
  400ada:	0f 85 11 00 00 00    	jne    400af1 <LLreadchar+0x74>
  400ae0:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400ae4:	48 c1 e8 08          	shr    $0x8,%rax
  400ae8:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400aec:	e9 b5 00 00 00       	jmpq   400ba6 <LLreadchar+0x129>
  400af1:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400af5:	48 83 f8 02          	cmp    $0x2,%rax
  400af9:	0f 85 11 00 00 00    	jne    400b10 <LLreadchar+0x93>
  400aff:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400b03:	48 c1 e8 10          	shr    $0x10,%rax
  400b07:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400b0b:	e9 96 00 00 00       	jmpq   400ba6 <LLreadchar+0x129>
  400b10:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400b14:	48 83 f8 03          	cmp    $0x3,%rax
  400b18:	0f 85 11 00 00 00    	jne    400b2f <LLreadchar+0xb2>
  400b1e:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400b22:	48 c1 e8 18          	shr    $0x18,%rax
  400b26:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400b2a:	e9 77 00 00 00       	jmpq   400ba6 <LLreadchar+0x129>
  400b2f:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400b33:	48 83 f8 04          	cmp    $0x4,%rax
  400b37:	0f 85 11 00 00 00    	jne    400b4e <LLreadchar+0xd1>
  400b3d:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400b41:	48 c1 e8 20          	shr    $0x20,%rax
  400b45:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400b49:	e9 58 00 00 00       	jmpq   400ba6 <LLreadchar+0x129>
  400b4e:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400b52:	48 83 f8 05          	cmp    $0x5,%rax
  400b56:	0f 85 11 00 00 00    	jne    400b6d <LLreadchar+0xf0>
  400b5c:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400b60:	48 c1 e8 28          	shr    $0x28,%rax
  400b64:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400b68:	e9 39 00 00 00       	jmpq   400ba6 <LLreadchar+0x129>
  400b6d:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400b71:	48 83 f8 06          	cmp    $0x6,%rax
  400b75:	0f 85 11 00 00 00    	jne    400b8c <LLreadchar+0x10f>
  400b7b:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400b7f:	48 c1 e8 30          	shr    $0x30,%rax
  400b83:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400b87:	e9 1a 00 00 00       	jmpq   400ba6 <LLreadchar+0x129>
  400b8c:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400b90:	48 83 f8 07          	cmp    $0x7,%rax
  400b94:	0f 85 0c 00 00 00    	jne    400ba6 <LLreadchar+0x129>
  400b9a:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400b9e:	48 c1 e8 38          	shr    $0x38,%rax
  400ba2:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400ba6:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400baa:	48 81 e0 ff 00 00 00 	and    $0xff,%rax
  400bb1:	e9 00 00 00 00       	jmpq   400bb6 <LLreadchar+0x139>
  400bb6:	48 89 ec             	mov    %rbp,%rsp
  400bb9:	5d                   	pop    %rbp
  400bba:	c3                   	retq   

0000000000400bbb <atol>:
  400bbb:	55                   	push   %rbp
  400bbc:	48 89 e5             	mov    %rsp,%rbp
  400bbf:	48 81 ec 60 00 00 00 	sub    $0x60,%rsp
  400bc6:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400bca:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400bd1:	00 00 00 
  400bd4:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400bd8:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400bdf:	00 00 00 
  400be2:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  400be6:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400bea:	48 89 c7             	mov    %rax,%rdi
  400bed:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400bf4:	00 00 00 
  400bf7:	e8 81 fe ff ff       	callq  400a7d <LLreadchar>
  400bfc:	48 89 45 d0          	mov    %rax,0xffffffffffffffd0(%rbp)
  400c00:	48 8b 45 d0          	mov    0xffffffffffffffd0(%rbp),%rax
  400c04:	48 89 c7             	mov    %rax,%rdi
  400c07:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400c0e:	00 00 00 
  400c11:	e8 86 fd ff ff       	callq  40099c <isspace>
  400c16:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  400c1a:	48 8b 45 d8          	mov    0xffffffffffffffd8(%rbp),%rax
  400c1e:	48 83 f8 00          	cmp    $0x0,%rax
  400c22:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400c29:	00 00 00 
  400c2c:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400c33:	00 00 00 
  400c36:	0f 85 0a 00 00 00    	jne    400c46 <atol+0x8b>
  400c3c:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400c43:	00 00 00 
  400c46:	48 85 c0             	test   %rax,%rax
  400c49:	0f 84 45 00 00 00    	je     400c94 <atol+0xd9>
  400c4f:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400c53:	48 89 c1             	mov    %rax,%rcx
  400c56:	48 83 c0 01          	add    $0x1,%rax
  400c5a:	48 89 45 f8          	mov    %rax,0xfffffffffffffff8(%rbp)
  400c5e:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400c62:	48 89 c7             	mov    %rax,%rdi
  400c65:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400c6c:	00 00 00 
  400c6f:	e8 09 fe ff ff       	callq  400a7d <LLreadchar>
  400c74:	48 89 45 c8          	mov    %rax,0xffffffffffffffc8(%rbp)
  400c78:	48 8b 45 c8          	mov    0xffffffffffffffc8(%rbp),%rax
  400c7c:	48 89 c7             	mov    %rax,%rdi
  400c7f:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400c86:	00 00 00 
  400c89:	e8 0e fd ff ff       	callq  40099c <isspace>
  400c8e:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  400c92:	eb 86                	jmp    400c1a <atol+0x5f>
  400c94:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400c98:	48 89 c7             	mov    %rax,%rdi
  400c9b:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400ca2:	00 00 00 
  400ca5:	e8 d3 fd ff ff       	callq  400a7d <LLreadchar>
  400caa:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  400cae:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400cb2:	48 83 f8 2d          	cmp    $0x2d,%rax
  400cb6:	0f 85 1d 00 00 00    	jne    400cd9 <atol+0x11e>
  400cbc:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400cc3:	00 00 00 
  400cc6:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  400cca:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400cce:	48 89 c1             	mov    %rax,%rcx
  400cd1:	48 83 c0 01          	add    $0x1,%rax
  400cd5:	48 89 45 f8          	mov    %rax,0xfffffffffffffff8(%rbp)
  400cd9:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400cdd:	48 83 f8 2b          	cmp    $0x2b,%rax
  400ce1:	0f 85 0f 00 00 00    	jne    400cf6 <atol+0x13b>
  400ce7:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400ceb:	48 89 c1             	mov    %rax,%rcx
  400cee:	48 83 c0 01          	add    $0x1,%rax
  400cf2:	48 89 45 f8          	mov    %rax,0xfffffffffffffff8(%rbp)
  400cf6:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400cfa:	48 89 c7             	mov    %rax,%rdi
  400cfd:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400d04:	00 00 00 
  400d07:	e8 71 fd ff ff       	callq  400a7d <LLreadchar>
  400d0c:	48 89 45 c0          	mov    %rax,0xffffffffffffffc0(%rbp)
  400d10:	48 8b 45 c0          	mov    0xffffffffffffffc0(%rbp),%rax
  400d14:	48 89 c7             	mov    %rax,%rdi
  400d17:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400d1e:	00 00 00 
  400d21:	e8 e4 fc ff ff       	callq  400a0a <isdigit>
  400d26:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  400d2a:	48 8b 45 d8          	mov    0xffffffffffffffd8(%rbp),%rax
  400d2e:	48 83 f8 00          	cmp    $0x0,%rax
  400d32:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400d39:	00 00 00 
  400d3c:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400d43:	00 00 00 
  400d46:	0f 85 0a 00 00 00    	jne    400d56 <atol+0x19b>
  400d4c:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400d53:	00 00 00 
  400d56:	48 85 c0             	test   %rax,%rax
  400d59:	0f 84 87 00 00 00    	je     400de6 <atol+0x22b>
  400d5f:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400d63:	48 b9 0a 00 00 00 00 	mov    $0xa,%rcx
  400d6a:	00 00 00 
  400d6d:	48 0f af c1          	imul   %rcx,%rax
  400d71:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  400d75:	48 89 ca             	mov    %rcx,%rdx
  400d78:	48 83 c1 01          	add    $0x1,%rcx
  400d7c:	48 89 4d f8          	mov    %rcx,0xfffffffffffffff8(%rbp)
  400d80:	48 89 45 b8          	mov    %rax,0xffffffffffffffb8(%rbp)
  400d84:	48 89 55 b0          	mov    %rdx,0xffffffffffffffb0(%rbp)
  400d88:	48 8b 45 b0          	mov    0xffffffffffffffb0(%rbp),%rax
  400d8c:	48 89 c7             	mov    %rax,%rdi
  400d8f:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400d96:	00 00 00 
  400d99:	e8 df fc ff ff       	callq  400a7d <LLreadchar>
  400d9e:	48 83 e8 30          	sub    $0x30,%rax
  400da2:	48 8b 4d b8          	mov    0xffffffffffffffb8(%rbp),%rcx
  400da6:	48 29 c1             	sub    %rax,%rcx
  400da9:	48 89 4d f0          	mov    %rcx,0xfffffffffffffff0(%rbp)
  400dad:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400db1:	48 89 c7             	mov    %rax,%rdi
  400db4:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400dbb:	00 00 00 
  400dbe:	e8 ba fc ff ff       	callq  400a7d <LLreadchar>
  400dc3:	48 89 45 a8          	mov    %rax,0xffffffffffffffa8(%rbp)
  400dc7:	48 8b 45 a8          	mov    0xffffffffffffffa8(%rbp),%rax
  400dcb:	48 89 c7             	mov    %rax,%rdi
  400dce:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400dd5:	00 00 00 
  400dd8:	e8 2d fc ff ff       	callq  400a0a <isdigit>
  400ddd:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  400de1:	e9 44 ff ff ff       	jmpq   400d2a <atol+0x16f>
  400de6:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400dea:	48 83 f8 00          	cmp    $0x0,%rax
  400dee:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400df5:	00 00 00 
  400df8:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  400dff:	00 00 00 
  400e02:	0f 85 0a 00 00 00    	jne    400e12 <atol+0x257>
  400e08:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400e0f:	00 00 00 
  400e12:	48 85 c0             	test   %rax,%rax
  400e15:	0f 84 05 00 00 00    	je     400e20 <atol+0x265>
  400e1b:	e9 15 00 00 00       	jmpq   400e35 <atol+0x27a>
  400e20:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400e27:	00 00 00 
  400e2a:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  400e2e:	48 29 c8             	sub    %rcx,%rax
  400e31:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  400e35:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400e39:	e9 00 00 00 00       	jmpq   400e3e <atol+0x283>
  400e3e:	48 89 ec             	mov    %rbp,%rsp
  400e41:	5d                   	pop    %rbp
  400e42:	c3                   	retq   

0000000000400e43 <time>:
  400e43:	55                   	push   %rbp
  400e44:	48 89 e5             	mov    %rsp,%rbp
  400e47:	48 81 ec 20 00 00 00 	sub    $0x20,%rsp
  400e4e:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400e52:	48 8d 45 e8          	lea    0xffffffffffffffe8(%rbp),%rax
  400e56:	0f ae 38             	clflush (%rax)
  400e59:	48 8d 45 f0          	lea    0xfffffffffffffff0(%rbp),%rax
  400e5d:	0f ae 38             	clflush (%rax)
  400e60:	48 8d 45 e8          	lea    0xffffffffffffffe8(%rbp),%rax
  400e64:	49 89 c2             	mov    %rax,%r10
  400e67:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400e6e:	00 00 00 
  400e71:	48 89 c6             	mov    %rax,%rsi
  400e74:	48 b8 e4 00 00 00 00 	mov    $0xe4,%rax
  400e7b:	00 00 00 
  400e7e:	48 89 c7             	mov    %rax,%rdi
  400e81:	4c 89 d2             	mov    %r10,%rdx
  400e84:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400e8b:	00 00 00 
  400e8e:	e8 25 01 00 00       	callq  400fb8 <__syscall2>
  400e93:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  400e97:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400e9b:	48 85 c0             	test   %rax,%rax
  400e9e:	0f 84 0b 00 00 00    	je     400eaf <time+0x6c>
  400ea4:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400ea8:	48 8b 4d e0          	mov    0xffffffffffffffe0(%rbp),%rcx
  400eac:	48 89 08             	mov    %rcx,(%rax)
  400eaf:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400eb3:	e9 00 00 00 00       	jmpq   400eb8 <time+0x75>
  400eb8:	48 89 ec             	mov    %rbp,%rsp
  400ebb:	5d                   	pop    %rbp
  400ebc:	c3                   	retq   

0000000000400ebd <__libc_start_main>:
  400ebd:	55                   	push   %rbp
  400ebe:	48 89 e5             	mov    %rsp,%rbp
  400ec1:	48 81 ec 40 00 00 00 	sub    $0x40,%rsp
  400ec8:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400ecc:	48 89 75 f0          	mov    %rsi,0xfffffffffffffff0(%rbp)
  400ed0:	48 89 55 e8          	mov    %rdx,0xffffffffffffffe8(%rbp)
  400ed4:	48 89 4d e0          	mov    %rcx,0xffffffffffffffe0(%rbp)
  400ed8:	4c 89 45 d8          	mov    %r8,0xffffffffffffffd8(%rbp)
  400edc:	4c 89 4d d0          	mov    %r9,0xffffffffffffffd0(%rbp)
  400ee0:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400ee4:	48 c1 e0 03          	shl    $0x3,%rax
  400ee8:	48 8b 4d e8          	mov    0xffffffffffffffe8(%rbp),%rcx
  400eec:	48 01 c1             	add    %rax,%rcx
  400eef:	48 83 c1 08          	add    $0x8,%rcx
  400ef3:	48 89 4d c8          	mov    %rcx,0xffffffffffffffc8(%rbp)
  400ef7:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400efe:	00 00 00 
  400f01:	48 89 c6             	mov    %rax,%rsi
  400f04:	48 b8 0c 00 00 00 00 	mov    $0xc,%rax
  400f0b:	00 00 00 
  400f0e:	48 89 c7             	mov    %rax,%rdi
  400f11:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400f18:	00 00 00 
  400f1b:	e8 67 00 00 00       	callq  400f87 <__syscall1>
  400f20:	4c 8b 1d 39 0f 20 00 	mov    2101049(%rip),%r11        # 601e60 <_main+0x2003dc>
  400f27:	49 89 03             	mov    %rax,(%r11)
  400f2a:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400f31:	00 00 00 
  400f34:	49 89 c2             	mov    %rax,%r10
  400f37:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400f3b:	48 89 c6             	mov    %rax,%rsi
        
  400f3e:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  400f42:	48 89 c7             	mov    %rax,%rdi
  400f45:	4c 89 d2             	mov    %r10,%rdx
  400f48:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400f4f:	00 00 00 
  400f52:	4c 8b 5d f8          	mov    0xfffffffffffffff8(%rbp),%r11
  400f56:	41 ff d3             	callq  *%r11
  400f59:	48 89 45 c0          	mov    %rax,0xffffffffffffffc0(%rbp)
  400f5d:	48 8b 45 c0          	mov    0xffffffffffffffc0(%rbp),%rax
  400f61:	48 89 c7             	mov    %rax,%rdi
  400f64:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400f6b:	00 00 00 
  400f6e:	e8 4f f5 ff ff       	callq  4004c2 <llexit>
  400f73:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  400f7a:	00 00 00 
  400f7d:	e9 00 00 00 00       	jmpq   400f82 <__libc_start_main+0xc5>
  400f82:	48 89 ec             	mov    %rbp,%rsp
  400f85:	5d                   	pop    %rbp
  400f86:	c3                   	retq   

0000000000400f87 <__syscall1>:
  400f87:	55                   	push   %rbp
  400f88:	48 89 e5             	mov    %rsp,%rbp
  400f8b:	48 81 ec 20 00 00 00 	sub    $0x20,%rsp
  400f92:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400f96:	48 89 75 f0          	mov    %rsi,0xfffffffffffffff0(%rbp)
  400f9a:	57                   	push   %rdi
  400f9b:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400f9f:	48 8b 7d f0          	mov    0xfffffffffffffff0(%rbp),%rdi
  400fa3:	0f 05                	syscall 
  400fa5:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  400fa9:	5f                   	pop    %rdi
  400faa:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  400fae:	e9 00 00 00 00       	jmpq   400fb3 <__syscall1+0x2c>
  400fb3:	48 89 ec             	mov    %rbp,%rsp
  400fb6:	5d                   	pop    %rbp
  400fb7:	c3                   	retq   

0000000000400fb8 <__syscall2>:
  400fb8:	55                   	push   %rbp
  400fb9:	48 89 e5             	mov    %rsp,%rbp
  400fbc:	48 81 ec 20 00 00 00 	sub    $0x20,%rsp
  400fc3:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  400fc7:	48 89 75 f0          	mov    %rsi,0xfffffffffffffff0(%rbp)
  400fcb:	48 89 55 e8          	mov    %rdx,0xffffffffffffffe8(%rbp)
  400fcf:	56                   	push   %rsi
  400fd0:	57                   	push   %rdi
  400fd1:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  400fd5:	48 8b 7d f0          	mov    0xfffffffffffffff0(%rbp),%rdi
  400fd9:	48 8b 75 e8          	mov    0xffffffffffffffe8(%rbp),%rsi
  400fdd:	0f 05                	syscall 
  400fdf:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  400fe3:	5f                   	pop    %rdi
  400fe4:	5e                   	pop    %rsi
  400fe5:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  400fe9:	e9 00 00 00 00       	jmpq   400fee <__syscall2+0x36>
  400fee:	48 89 ec             	mov    %rbp,%rsp
  400ff1:	5d                   	pop    %rbp
  400ff2:	c3                   	retq   

0000000000400ff3 <__syscall3>:
  400ff3:	55                   	push   %rbp
  400ff4:	48 89 e5             	mov    %rsp,%rbp
  400ff7:	48 81 ec 30 00 00 00 	sub    $0x30,%rsp
  400ffe:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  401002:	48 89 75 f0          	mov    %rsi,0xfffffffffffffff0(%rbp)
  401006:	48 89 55 e8          	mov    %rdx,0xffffffffffffffe8(%rbp)
  40100a:	48 89 4d e0          	mov    %rcx,0xffffffffffffffe0(%rbp)
  40100e:	56                   	push   %rsi
  40100f:	57                   	push   %rdi
  401010:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  401014:	48 8b 7d f0          	mov    0xfffffffffffffff0(%rbp),%rdi
  401018:	48 8b 75 e8          	mov    0xffffffffffffffe8(%rbp),%rsi
  40101c:	48 8b 55 e0          	mov    0xffffffffffffffe0(%rbp),%rdx
  401020:	0f 05                	syscall 
  401022:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  401026:	5f                   	pop    %rdi
  401027:	5e                   	pop    %rsi
  401028:	48 8b 45 d8          	mov    0xffffffffffffffd8(%rbp),%rax
  40102c:	e9 00 00 00 00       	jmpq   401031 <__syscall3+0x3e>
  401031:	48 89 ec             	mov    %rbp,%rsp
  401034:	5d                   	pop    %rbp
  401035:	c3                   	retq   
  401036:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  40103d:	00 00 00 

0000000000401040 <OutDig>:
  401040:	55                   	push   %rbp
  401041:	48 89 e5             	mov    %rsp,%rbp
  401044:	48 81 ec 10 00 00 00 	sub    $0x10,%rsp
  40104b:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  40104f:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  401053:	48 83 c0 30          	add    $0x30,%rax
  401057:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  40105b:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  40105f:	48 89 c7             	mov    %rax,%rdi
  401062:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401069:	00 00 00 
  40106c:	e8 3a f8 ff ff       	callq  4008ab <putchar>
  401071:	48 89 ec             	mov    %rbp,%rsp
  401074:	5d                   	pop    %rbp
  401075:	c3                   	retq   

0000000000401076 <PrintVal>:
  401076:	55                   	push   %rbp
  401077:	48 89 e5             	mov    %rsp,%rbp
  40107a:	48 81 ec 20 00 00 00 	sub    $0x20,%rsp
  401081:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  401085:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  401089:	48 83 f8 09          	cmp    $0x9,%rax
  40108d:	0f 8e 3d 00 00 00    	jle    4010d0 <PrintVal+0x5a>
  401093:	48 b8 0a 00 00 00 00 	mov    $0xa,%rax
  40109a:	00 00 00 
  40109d:	48 89 c6             	mov    %rax,%rsi
  4010a0:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4010a4:	48 89 c7             	mov    %rax,%rdi
  4010a7:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4010ae:	00 00 00 
  4010b1:	e8 2a f0 ff ff       	callq  4000e0 <idiv_q>
  4010b6:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  4010ba:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4010be:	48 89 c7             	mov    %rax,%rdi
  4010c1:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4010c8:	00 00 00 
  4010cb:	e8 a6 ff ff ff       	callq  401076 <PrintVal>
  4010d0:	48 b8 0a 00 00 00 00 	mov    $0xa,%rax
  4010d7:	00 00 00 
  4010da:	48 89 c6             	mov    %rax,%rsi
  4010dd:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4010e1:	48 89 c7             	mov    %rax,%rdi
  4010e4:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4010eb:	00 00 00 
  4010ee:	e8 07 f2 ff ff       	callq  4002fa <idiv_r>
  4010f3:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  4010f7:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  4010fb:	48 89 c7             	mov    %rax,%rdi
  4010fe:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401105:	00 00 00 
  401108:	e8 33 ff ff ff       	callq  401040 <OutDig>
  40110d:	48 89 ec             	mov    %rbp,%rsp
  401110:	5d                   	pop    %rbp
  401111:	c3                   	retq   

0000000000401112 <PrintShort>:
  401112:	55                   	push   %rbp
  401113:	48 89 e5             	mov    %rsp,%rbp
  401116:	48 81 ec 70 00 00 00 	sub    $0x70,%rsp
  40111d:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  401121:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401128:	00 00 00 
  40112b:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  40112f:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  401133:	48 83 f8 02          	cmp    $0x2,%rax
  401137:	0f 8d a0 00 00 00    	jge    4011dd <PrintShort+0xcb>
  40113d:	e9 32 00 00 00       	jmpq   401174 <PrintShort+0x62>
  401142:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  401146:	48 b9 f0 ff ff ff ff 	mov    $0xfffffffffffffff0,%rcx
  40114d:	ff ff ff 
  401150:	48 89 ca             	mov    %rcx,%rdx
  401153:	48 89 55 d0          	mov    %rdx,0xffffffffffffffd0(%rbp)
  401157:	48 89 c2             	mov    %rax,%rdx
  40115a:	48 89 4d c8          	mov    %rcx,0xffffffffffffffc8(%rbp)
  40115e:	48 8b 4d d0          	mov    0xffffffffffffffd0(%rbp),%rcx
  401162:	48 89 55 c0          	mov    %rdx,0xffffffffffffffc0(%rbp)
  401166:	48 8b 4d c8          	mov    0xffffffffffffffc8(%rbp),%rcx
  40116a:	48 83 c0 01          	add    $0x1,%rax
  40116e:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  401172:	eb bb                	jmp    40112f <PrintShort+0x1d>
  401174:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  401178:	48 c1 e0 03          	shl    $0x3,%rax
  40117c:	48 8d 4d d8          	lea    0xffffffffffffffd8(%rbp),%rcx
  401180:	48 01 c1             	add    %rax,%rcx
  401183:	48 89 4d b8          	mov    %rcx,0xffffffffffffffb8(%rbp)
  401187:	48 b8 0a 00 00 00 00 	mov    $0xa,%rax
  40118e:	00 00 00 
  401191:	48 89 c6             	mov    %rax,%rsi
  401194:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  401198:	48 89 c7             	mov    %rax,%rdi
  40119b:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4011a2:	00 00 00 
  4011a5:	e8 50 f1 ff ff       	callq  4002fa <idiv_r>
  4011aa:	48 8b 4d b8          	mov    0xffffffffffffffb8(%rbp),%rcx
  4011ae:	48 89 01             	mov    %rax,(%rcx)
  4011b1:	48 b8 0a 00 00 00 00 	mov    $0xa,%rax
  4011b8:	00 00 00 
  4011bb:	48 89 c6             	mov    %rax,%rsi
  4011be:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  4011c2:	48 89 c7             	mov    %rax,%rdi
  4011c5:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4011cc:	00 00 00 
  4011cf:	e8 0c ef ff ff       	callq  4000e0 <idiv_q>
  4011d4:	48 89 45 f8          	mov    %rax,0xfffffffffffffff8(%rbp)
  4011d8:	e9 65 ff ff ff       	jmpq   401142 <PrintShort+0x30>
  4011dd:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4011e4:	00 00 00 
  4011e7:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  4011eb:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4011ef:	48 83 f8 00          	cmp    $0x0,%rax
  4011f3:	0f 8c 65 00 00 00    	jl     40125e <PrintShort+0x14c>
  4011f9:	e9 32 00 00 00       	jmpq   401230 <PrintShort+0x11e>
  4011fe:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  401202:	48 b9 f0 ff ff ff ff 	mov    $0xfffffffffffffff0,%rcx
  401209:	ff ff ff 
  40120c:	48 89 ca             	mov    %rcx,%rdx
  40120f:	48 89 55 b0          	mov    %rdx,0xffffffffffffffb0(%rbp)
  401213:	48 89 c2             	mov    %rax,%rdx
  401216:	48 89 4d a8          	mov    %rcx,0xffffffffffffffa8(%rbp)
  40121a:	48 8b 4d b0          	mov    0xffffffffffffffb0(%rbp),%rcx
  40121e:	48 89 55 a0          	mov    %rdx,0xffffffffffffffa0(%rbp)
  401222:	48 8b 4d a8          	mov    0xffffffffffffffa8(%rbp),%rcx
  401226:	48 83 c0 ff          	add    $0xffffffffffffffff,%rax
  40122a:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  40122e:	eb bb                	jmp    4011eb <PrintShort+0xd9>
  401230:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  401234:	48 c1 e0 03          	shl    $0x3,%rax
  401238:	48 8d 4d d8          	lea    0xffffffffffffffd8(%rbp),%rcx
  40123c:	48 01 c1             	add    %rax,%rcx
  40123f:	48 89 4d 98          	mov    %rcx,0xffffffffffffff98(%rbp)
  401243:	48 8b 45 98          	mov    0xffffffffffffff98(%rbp),%rax
  401247:	48 8b 00             	mov    (%rax),%rax
  40124a:	48 89 c7             	mov    %rax,%rdi
  40124d:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401254:	00 00 00 
  401257:	e8 e4 fd ff ff       	callq  401040 <OutDig>
  40125c:	eb a0                	jmp    4011fe <PrintShort+0xec>
  40125e:	48 89 ec             	mov    %rbp,%rsp
  401261:	5d                   	pop    %rbp
  401262:	c3                   	retq   

0000000000401263 <Print>:
  401263:	55                   	push   %rbp
  401264:	48 89 e5             	mov    %rsp,%rbp
  401267:	48 81 ec 30 00 00 00 	sub    $0x30,%rsp
  40126e:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  401272:	48 b8 33 00 00 00 00 	mov    $0x33,%rax
  401279:	00 00 00 
  40127c:	48 89 c7             	mov    %rax,%rdi
  40127f:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401286:	00 00 00 
  401289:	e8 1d f6 ff ff       	callq  4008ab <putchar>
  40128e:	48 b8 2e 00 00 00 00 	mov    $0x2e,%rax
  401295:	00 00 00 
  401298:	48 89 c7             	mov    %rax,%rdi
  40129b:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4012a2:	00 00 00 
  4012a5:	e8 01 f6 ff ff       	callq  4008ab <putchar>
  4012aa:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4012b1:	00 00 00 
  4012b4:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  4012b8:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4012bc:	48 8b 0d b5 0b 20 00 	mov    2100149(%rip),%rcx        # 601e78 <_main+0x2003f4>
  4012c3:	48 8b 09             	mov    (%rcx),%rcx
  4012c6:	48 39 c8             	cmp    %rcx,%rax
  4012c9:	0f 8d 65 00 00 00    	jge    401334 <Print+0xd1>
  4012cf:	e9 32 00 00 00       	jmpq   401306 <Print+0xa3>
  4012d4:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  4012d8:	48 b9 f0 ff ff ff ff 	mov    $0xfffffffffffffff0,%rcx
  4012df:	ff ff ff 
  4012e2:	48 89 ca             	mov    %rcx,%rdx
  4012e5:	48 89 55 e8          	mov    %rdx,0xffffffffffffffe8(%rbp)
  4012e9:	48 89 c2             	mov    %rax,%rdx
  4012ec:	48 89 4d e0          	mov    %rcx,0xffffffffffffffe0(%rbp)
  4012f0:	48 8b 4d e8          	mov    0xffffffffffffffe8(%rbp),%rcx
  4012f4:	48 89 55 d8          	mov    %rdx,0xffffffffffffffd8(%rbp)
  4012f8:	48 8b 4d e0          	mov    0xffffffffffffffe0(%rbp),%rcx
  4012fc:	48 83 c0 01          	add    $0x1,%rax
  401300:	48 89 45 f0          	mov    %rax,0xfffffffffffffff0(%rbp)
  401304:	eb b2                	jmp    4012b8 <Print+0x55>
  401306:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  40130a:	48 c1 e0 03          	shl    $0x3,%rax
  40130e:	48 8b 4d f8          	mov    0xfffffffffffffff8(%rbp),%rcx
  401312:	48 01 c1             	add    %rax,%rcx
  401315:	48 89 4d d0          	mov    %rcx,0xffffffffffffffd0(%rbp)
  401319:	48 8b 45 d0          	mov    0xffffffffffffffd0(%rbp),%rax
  40131d:	48 8b 00             	mov    (%rax),%rax
  401320:	48 89 c7             	mov    %rax,%rdi
  401323:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40132a:	00 00 00 
  40132d:	e8 e0 fd ff ff       	callq  401112 <PrintShort>
  401332:	eb a0                	jmp    4012d4 <Print+0x71>
  401334:	48 b8 0a 00 00 00 00 	mov    $0xa,%rax
  40133b:	00 00 00 
  40133e:	48 89 c7             	mov    %rax,%rdi
  401341:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401348:	00 00 00 
  40134b:	e8 5b f5 ff ff       	callq  4008ab <putchar>
  401350:	48 89 ec             	mov    %rbp,%rsp
  401353:	5d                   	pop    %rbp
  401354:	c3                   	retq   

0000000000401355 <arctan>:
  401355:	55                   	push   %rbp
  401356:	48 89 e5             	mov    %rsp,%rbp
  401359:	48 81 ec 30 01 00 00 	sub    $0x130,%rsp
  401360:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  401364:	48 89 75 f0          	mov    %rsi,0xfffffffffffffff0(%rbp)
  401368:	48 89 55 e8          	mov    %rdx,0xffffffffffffffe8(%rbp)
  40136c:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  401373:	00 00 00 
  401376:	48 89 45 b8          	mov    %rax,0xffffffffffffffb8(%rbp)
  40137a:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401381:	00 00 00 
  401384:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  401388:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  40138c:	48 8b 0d e5 0a 20 00 	mov    2099941(%rip),%rcx        # 601e78 <_main+0x2003f4>
  401393:	48 8b 09             	mov    (%rcx),%rcx
  401396:	48 39 c8             	cmp    %rcx,%rax
  401399:	0f 8d 5b 00 00 00    	jge    4013fa <arctan+0xa5>
  40139f:	e9 32 00 00 00       	jmpq   4013d6 <arctan+0x81>
  4013a4:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4013a8:	48 b9 e0 ff ff ff ff 	mov    $0xffffffffffffffe0,%rcx
  4013af:	ff ff ff 
  4013b2:	48 89 ca             	mov    %rcx,%rdx
  4013b5:	48 89 55 a8          	mov    %rdx,0xffffffffffffffa8(%rbp)
  4013b9:	48 89 c2             	mov    %rax,%rdx
  4013bc:	48 89 4d a0          	mov    %rcx,0xffffffffffffffa0(%rbp)
  4013c0:	48 8b 4d a8          	mov    0xffffffffffffffa8(%rbp),%rcx
  4013c4:	48 89 55 98          	mov    %rdx,0xffffffffffffff98(%rbp)
  4013c8:	48 8b 4d a0          	mov    0xffffffffffffffa0(%rbp),%rcx
  4013cc:	48 83 c0 01          	add    $0x1,%rax
  4013d0:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  4013d4:	eb b2                	jmp    401388 <arctan+0x33>
  4013d6:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4013da:	48 c1 e0 03          	shl    $0x3,%rax
  4013de:	48 8b 0d 83 0a 20 00 	mov    2099843(%rip),%rcx        # 601e68 <_main+0x2003e4>
  4013e5:	48 8b 09             	mov    (%rcx),%rcx
  4013e8:	48 01 c1             	add    %rax,%rcx
  4013eb:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4013f2:	00 00 00 
  4013f5:	48 89 01             	mov    %rax,(%rcx)
  4013f8:	eb aa                	jmp    4013a4 <arctan+0x4f>
  4013fa:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  401401:	00 00 00 
  401404:	48 89 45 c8          	mov    %rax,0xffffffffffffffc8(%rbp)
  401408:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  40140c:	48 89 45 c0          	mov    %rax,0xffffffffffffffc0(%rbp)
  401410:	48 8b 45 c0          	mov    0xffffffffffffffc0(%rbp),%rax
  401414:	48 8b 4d c0          	mov    0xffffffffffffffc0(%rbp),%rcx
  401418:	48 0f af c1          	imul   %rcx,%rax
  40141c:	48 89 45 c0          	mov    %rax,0xffffffffffffffc0(%rbp)
  401420:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401427:	00 00 00 
  40142a:	48 89 45 b0          	mov    %rax,0xffffffffffffffb0(%rbp)
  40142e:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  401432:	48 8b 4d f0          	mov    0xfffffffffffffff0(%rbp),%rcx
  401436:	48 0f af c1          	imul   %rcx,%rax
  40143a:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  40143e:	48 8b 45 b8          	mov    0xffffffffffffffb8(%rbp),%rax
  401442:	48 83 f8 00          	cmp    $0x0,%rax
  401446:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  40144d:	00 00 00 
  401450:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  401457:	00 00 00 
  40145a:	0f 85 0a 00 00 00    	jne    40146a <arctan+0x115>
  401460:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401467:	00 00 00 
  40146a:	48 85 c0             	test   %rax,%rax
  40146d:	0f 84 0c 06 00 00    	je     401a7f <arctan+0x72a>
  401473:	48 8b 45 b0          	mov    0xffffffffffffffb0(%rbp),%rax
  401477:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  40147b:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  40147f:	48 8b 0d f2 09 20 00 	mov    2099698(%rip),%rcx        # 601e78 <_main+0x2003f4>
  401486:	48 8b 09             	mov    (%rcx),%rcx
  401489:	48 39 c8             	cmp    %rcx,%rax
  40148c:	0f 8d db 00 00 00    	jge    40156d <arctan+0x218>
  401492:	e9 32 00 00 00       	jmpq   4014c9 <arctan+0x174>
  401497:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  40149b:	48 b9 e0 ff ff ff ff 	mov    $0xffffffffffffffe0,%rcx
  4014a2:	ff ff ff 
  4014a5:	48 89 ca             	mov    %rcx,%rdx
  4014a8:	48 89 55 90          	mov    %rdx,0xffffffffffffff90(%rbp)
  4014ac:	48 89 c2             	mov    %rax,%rdx
  4014af:	48 89 4d 88          	mov    %rcx,0xffffffffffffff88(%rbp)
  4014b3:	48 8b 4d 90          	mov    0xffffffffffffff90(%rbp),%rcx
  4014b7:	48 89 55 80          	mov    %rdx,0xffffffffffffff80(%rbp)
  4014bb:	48 8b 4d 88          	mov    0xffffffffffffff88(%rbp),%rcx
  4014bf:	48 83 c0 01          	add    $0x1,%rax
  4014c3:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  4014c7:	eb b2                	jmp    40147b <arctan+0x126>
  4014c9:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4014cd:	48 c1 e0 03          	shl    $0x3,%rax
  4014d1:	48 8b 0d 90 09 20 00 	mov    2099600(%rip),%rcx        # 601e68 <_main+0x2003e4>
  4014d8:	48 8b 09             	mov    (%rcx),%rcx
  4014db:	48 01 c1             	add    %rax,%rcx
  4014de:	48 8b 01             	mov    (%rcx),%rax
  4014e1:	48 8b 4d d8          	mov    0xffffffffffffffd8(%rbp),%rcx
  4014e5:	48 01 c8             	add    %rcx,%rax
  4014e8:	48 89 45 d0          	mov    %rax,0xffffffffffffffd0(%rbp)
  4014ec:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4014f0:	48 c1 e0 03          	shl    $0x3,%rax
  4014f4:	48 8b 0d 6d 09 20 00 	mov    2099565(%rip),%rcx        # 601e68 <_main+0x2003e4>
  4014fb:	48 8b 09             	mov    (%rcx),%rcx
  4014fe:	48 01 c1             	add    %rax,%rcx
  401501:	48 89 8d 78 ff ff ff 	mov    %rcx,0xffffffffffffff78(%rbp)
  401508:	48 8b 45 c0          	mov    0xffffffffffffffc0(%rbp),%rax
  40150c:	48 89 c6             	mov    %rax,%rsi
  40150f:	48 8b 45 d0          	mov    0xffffffffffffffd0(%rbp),%rax
  401513:	48 89 c7             	mov    %rax,%rdi
  401516:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40151d:	00 00 00 
  401520:	e8 bb eb ff ff       	callq  4000e0 <idiv_q>
  401525:	48 8b 8d 78 ff ff ff 	mov    0xffffffffffffff78(%rbp),%rcx
  40152c:	48 89 01             	mov    %rax,(%rcx)
  40152f:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401533:	48 c1 e0 03          	shl    $0x3,%rax
  401537:	48 8b 0d 2a 09 20 00 	mov    2099498(%rip),%rcx        # 601e68 <_main+0x2003e4>
  40153e:	48 8b 09             	mov    (%rcx),%rcx
  401541:	48 01 c1             	add    %rax,%rcx
  401544:	48 8b 45 c0          	mov    0xffffffffffffffc0(%rbp),%rax
  401548:	48 8b 11             	mov    (%rcx),%rdx
  40154b:	48 0f af c2          	imul   %rdx,%rax
  40154f:	48 8b 4d d0          	mov    0xffffffffffffffd0(%rbp),%rcx
  401553:	48 29 c1             	sub    %rax,%rcx
  401556:	48 b8 64 00 00 00 00 	mov    $0x64,%rax
  40155d:	00 00 00 
  401560:	48 0f af c8          	imul   %rax,%rcx
  401564:	48 89 4d d8          	mov    %rcx,0xffffffffffffffd8(%rbp)
  401568:	e9 2a ff ff ff       	jmpq   401497 <arctan+0x142>
  40156d:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401574:	00 00 00 
  401577:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  40157b:	48 8b 45 b0          	mov    0xffffffffffffffb0(%rbp),%rax
  40157f:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  401583:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401587:	48 8b 0d ea 08 20 00 	mov    2099434(%rip),%rcx        # 601e78 <_main+0x2003f4>
  40158e:	48 8b 09             	mov    (%rcx),%rcx
  401591:	48 39 c8             	cmp    %rcx,%rax
  401594:	0f 8d ea 00 00 00    	jge    401684 <arctan+0x32f>
  40159a:	e9 41 00 00 00       	jmpq   4015e0 <arctan+0x28b>
  40159f:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4015a3:	48 b9 e0 ff ff ff ff 	mov    $0xffffffffffffffe0,%rcx
  4015aa:	ff ff ff 
  4015ad:	48 89 ca             	mov    %rcx,%rdx
  4015b0:	48 89 95 70 ff ff ff 	mov    %rdx,0xffffffffffffff70(%rbp)
  4015b7:	48 89 c2             	mov    %rax,%rdx
  4015ba:	48 89 8d 68 ff ff ff 	mov    %rcx,0xffffffffffffff68(%rbp)
  4015c1:	48 8b 8d 70 ff ff ff 	mov    0xffffffffffffff70(%rbp),%rcx
  4015c8:	48 89 95 60 ff ff ff 	mov    %rdx,0xffffffffffffff60(%rbp)
  4015cf:	48 8b 8d 68 ff ff ff 	mov    0xffffffffffffff68(%rbp),%rcx
  4015d6:	48 83 c0 01          	add    $0x1,%rax
  4015da:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  4015de:	eb a3                	jmp    401583 <arctan+0x22e>
  4015e0:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4015e4:	48 c1 e0 03          	shl    $0x3,%rax
  4015e8:	48 8b 0d 79 08 20 00 	mov    2099321(%rip),%rcx        # 601e68 <_main+0x2003e4>
  4015ef:	48 8b 09             	mov    (%rcx),%rcx
  4015f2:	48 01 c1             	add    %rax,%rcx
  4015f5:	48 8b 01             	mov    (%rcx),%rax
  4015f8:	48 8b 4d d8          	mov    0xffffffffffffffd8(%rbp),%rcx
  4015fc:	48 01 c8             	add    %rcx,%rax
  4015ff:	48 89 45 d0          	mov    %rax,0xffffffffffffffd0(%rbp)
  401603:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401607:	48 c1 e0 03          	shl    $0x3,%rax
  40160b:	48 8b 0d 5e 08 20 00 	mov    2099294(%rip),%rcx        # 601e70 <_main+0x2003ec>
  401612:	48 8b 09             	mov    (%rcx),%rcx
  401615:	48 01 c1             	add    %rax,%rcx
  401618:	48 89 8d 58 ff ff ff 	mov    %rcx,0xffffffffffffff58(%rbp)
  40161f:	48 8b 45 c8          	mov    0xffffffffffffffc8(%rbp),%rax
  401623:	48 89 c6             	mov    %rax,%rsi
  401626:	48 8b 45 d0          	mov    0xffffffffffffffd0(%rbp),%rax
  40162a:	48 89 c7             	mov    %rax,%rdi
  40162d:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401634:	00 00 00 
  401637:	e8 a4 ea ff ff       	callq  4000e0 <idiv_q>
  40163c:	48 8b 8d 58 ff ff ff 	mov    0xffffffffffffff58(%rbp),%rcx
  401643:	48 89 01             	mov    %rax,(%rcx)
  401646:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  40164a:	48 c1 e0 03          	shl    $0x3,%rax
  40164e:	48 8b 0d 1b 08 20 00 	mov    2099227(%rip),%rcx        # 601e70 <_main+0x2003ec>
  401655:	48 8b 09             	mov    (%rcx),%rcx
  401658:	48 01 c1             	add    %rax,%rcx
  40165b:	48 8b 45 c8          	mov    0xffffffffffffffc8(%rbp),%rax
  40165f:	48 8b 11             	mov    (%rcx),%rdx
  401662:	48 0f af c2          	imul   %rdx,%rax
  401666:	48 8b 4d d0          	mov    0xffffffffffffffd0(%rbp),%rcx
  40166a:	48 29 c1             	sub    %rax,%rcx
  40166d:	48 b8 64 00 00 00 00 	mov    $0x64,%rax
  401674:	00 00 00 
  401677:	48 0f af c8          	imul   %rax,%rcx
  40167b:	48 89 4d d8          	mov    %rcx,0xffffffffffffffd8(%rbp)
  40167f:	e9 1b ff ff ff       	jmpq   40159f <arctan+0x24a>
  401684:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40168b:	00 00 00 
  40168e:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  401692:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  401696:	48 83 f8 00          	cmp    $0x0,%rax
  40169a:	0f 8e 29 01 00 00    	jle    4017c9 <arctan+0x474>
  4016a0:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4016a7:	00 00 00 
  4016aa:	48 89 85 50 ff ff ff 	mov    %rax,0xffffffffffffff50(%rbp)
  4016b1:	48 8b 05 c0 07 20 00 	mov    2099136(%rip),%rax        # 601e78 <_main+0x2003f4>
  4016b8:	48 8b 00             	mov    (%rax),%rax
  4016bb:	48 83 e8 01          	sub    $0x1,%rax
  4016bf:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  4016c3:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4016c7:	48 83 f8 00          	cmp    $0x0,%rax
  4016cb:	0f 8c f3 00 00 00    	jl     4017c4 <arctan+0x46f>
  4016d1:	e9 41 00 00 00       	jmpq   401717 <arctan+0x3c2>
  4016d6:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4016da:	48 b9 e0 ff ff ff ff 	mov    $0xffffffffffffffe0,%rcx
  4016e1:	ff ff ff 
  4016e4:	48 89 ca             	mov    %rcx,%rdx
  4016e7:	48 89 95 40 ff ff ff 	mov    %rdx,0xffffffffffffff40(%rbp)
  4016ee:	48 89 c2             	mov    %rax,%rdx
  4016f1:	48 89 8d 38 ff ff ff 	mov    %rcx,0xffffffffffffff38(%rbp)
  4016f8:	48 8b 8d 40 ff ff ff 	mov    0xffffffffffffff40(%rbp),%rcx
  4016ff:	48 89 95 30 ff ff ff 	mov    %rdx,0xffffffffffffff30(%rbp)
  401706:	48 8b 8d 38 ff ff ff 	mov    0xffffffffffffff38(%rbp),%rcx
  40170d:	48 83 c0 ff          	add    $0xffffffffffffffff,%rax
  401711:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  401715:	eb ac                	jmp    4016c3 <arctan+0x36e>
  401717:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  40171b:	48 c1 e0 03          	shl    $0x3,%rax
  40171f:	48 8b 0d 5a 07 20 00 	mov    2099034(%rip),%rcx        # 601e80 <_main+0x2003fc>
  401726:	48 8b 09             	mov    (%rcx),%rcx
  401729:	48 01 c1             	add    %rax,%rcx
  40172c:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401730:	48 c1 e0 03          	shl    $0x3,%rax
  401734:	48 8b 15 35 07 20 00 	mov    2098997(%rip),%rdx        # 601e70 <_main+0x2003ec>
  40173b:	48 8b 12             	mov    (%rdx),%rdx
  40173e:	48 01 c2             	add    %rax,%rdx
  401741:	48 8b 01             	mov    (%rcx),%rax
  401744:	48 8b 0a             	mov    (%rdx),%rcx
  401747:	48 01 c8             	add    %rcx,%rax
  40174a:	48 8b 8d 50 ff ff ff 	mov    0xffffffffffffff50(%rbp),%rcx
  401751:	48 01 c8             	add    %rcx,%rax
  401754:	48 89 85 48 ff ff ff 	mov    %rax,0xffffffffffffff48(%rbp)
  40175b:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401762:	00 00 00 
  401765:	48 89 85 50 ff ff ff 	mov    %rax,0xffffffffffffff50(%rbp)
  40176c:	48 8b 85 48 ff ff ff 	mov    0xffffffffffffff48(%rbp),%rax
  401773:	48 83 f8 64          	cmp    $0x64,%rax
  401777:	0f 8c 23 00 00 00    	jl     4017a0 <arctan+0x44b>
  40177d:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  401784:	00 00 00 
  401787:	48 89 85 50 ff ff ff 	mov    %rax,0xffffffffffffff50(%rbp)
  40178e:	48 8b 85 48 ff ff ff 	mov    0xffffffffffffff48(%rbp),%rax
  401795:	48 83 e8 64          	sub    $0x64,%rax
  401799:	48 89 85 48 ff ff ff 	mov    %rax,0xffffffffffffff48(%rbp)
  4017a0:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4017a4:	48 c1 e0 03          	shl    $0x3,%rax
  4017a8:	48 8b 0d d1 06 20 00 	mov    2098897(%rip),%rcx        # 601e80 <_main+0x2003fc>
  4017af:	48 8b 09             	mov    (%rcx),%rcx
  4017b2:	48 01 c1             	add    %rax,%rcx
  4017b5:	48 8b 85 48 ff ff ff 	mov    0xffffffffffffff48(%rbp),%rax
  4017bc:	48 89 01             	mov    %rax,(%rcx)
  4017bf:	e9 12 ff ff ff       	jmpq   4016d6 <arctan+0x381>
  4017c4:	e9 24 01 00 00       	jmpq   4018ed <arctan+0x598>
  4017c9:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4017d0:	00 00 00 
  4017d3:	48 89 85 28 ff ff ff 	mov    %rax,0xffffffffffffff28(%rbp)
  4017da:	48 8b 05 97 06 20 00 	mov    2098839(%rip),%rax        # 601e78 <_main+0x2003f4>
  4017e1:	48 8b 00             	mov    (%rax),%rax
  4017e4:	48 83 e8 01          	sub    $0x1,%rax
  4017e8:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  4017ec:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4017f0:	48 83 f8 00          	cmp    $0x0,%rax
  4017f4:	0f 8c f3 00 00 00    	jl     4018ed <arctan+0x598>
  4017fa:	e9 41 00 00 00       	jmpq   401840 <arctan+0x4eb>
  4017ff:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401803:	48 b9 e0 ff ff ff ff 	mov    $0xffffffffffffffe0,%rcx
  40180a:	ff ff ff 
  40180d:	48 89 ca             	mov    %rcx,%rdx
  401810:	48 89 95 18 ff ff ff 	mov    %rdx,0xffffffffffffff18(%rbp)
  401817:	48 89 c2             	mov    %rax,%rdx
  40181a:	48 89 8d 10 ff ff ff 	mov    %rcx,0xffffffffffffff10(%rbp)
  401821:	48 8b 8d 18 ff ff ff 	mov    0xffffffffffffff18(%rbp),%rcx
  401828:	48 89 95 08 ff ff ff 	mov    %rdx,0xffffffffffffff08(%rbp)
  40182f:	48 8b 8d 10 ff ff ff 	mov    0xffffffffffffff10(%rbp),%rcx
  401836:	48 83 c0 ff          	add    $0xffffffffffffffff,%rax
  40183a:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  40183e:	eb ac                	jmp    4017ec <arctan+0x497>
  401840:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401844:	48 c1 e0 03          	shl    $0x3,%rax
  401848:	48 8b 0d 31 06 20 00 	mov    2098737(%rip),%rcx        # 601e80 <_main+0x2003fc>
  40184f:	48 8b 09             	mov    (%rcx),%rcx
  401852:	48 01 c1             	add    %rax,%rcx
  401855:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401859:	48 c1 e0 03          	shl    $0x3,%rax
  40185d:	48 8b 15 0c 06 20 00 	mov    2098700(%rip),%rdx        # 601e70 <_main+0x2003ec>
  401864:	48 8b 12             	mov    (%rdx),%rdx
  401867:	48 01 c2             	add    %rax,%rdx
  40186a:	48 8b 01             	mov    (%rcx),%rax
  40186d:	48 8b 0a             	mov    (%rdx),%rcx
  401870:	48 29 c8             	sub    %rcx,%rax
  401873:	48 8b 8d 28 ff ff ff 	mov    0xffffffffffffff28(%rbp),%rcx
  40187a:	48 29 c8             	sub    %rcx,%rax
  40187d:	48 89 85 20 ff ff ff 	mov    %rax,0xffffffffffffff20(%rbp)
  401884:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  40188b:	00 00 00 
  40188e:	48 89 85 28 ff ff ff 	mov    %rax,0xffffffffffffff28(%rbp)
  401895:	48 8b 85 20 ff ff ff 	mov    0xffffffffffffff20(%rbp),%rax
  40189c:	48 83 f8 00          	cmp    $0x0,%rax
  4018a0:	0f 8d 23 00 00 00    	jge    4018c9 <arctan+0x574>
  4018a6:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4018ad:	00 00 00 
  4018b0:	48 89 85 28 ff ff ff 	mov    %rax,0xffffffffffffff28(%rbp)
  4018b7:	48 8b 85 20 ff ff ff 	mov    0xffffffffffffff20(%rbp),%rax
  4018be:	48 83 c0 64          	add    $0x64,%rax
  4018c2:	48 89 85 20 ff ff ff 	mov    %rax,0xffffffffffffff20(%rbp)
  4018c9:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  4018cd:	48 c1 e0 03          	shl    $0x3,%rax
  4018d1:	48 8b 0d a8 05 20 00 	mov    2098600(%rip),%rcx        # 601e80 <_main+0x2003fc>
  4018d8:	48 8b 09             	mov    (%rcx),%rcx
  4018db:	48 01 c1             	add    %rax,%rcx
  4018de:	48 8b 85 20 ff ff ff 	mov    0xffffffffffffff20(%rbp),%rax
  4018e5:	48 89 01             	mov    %rax,(%rcx)
  4018e8:	e9 12 ff ff ff       	jmpq   4017ff <arctan+0x4aa>
  4018ed:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4018f4:	00 00 00 
  4018f7:	48 8b 4d e8          	mov    0xffffffffffffffe8(%rbp),%rcx
  4018fb:	48 29 c8             	sub    %rcx,%rax
  4018fe:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  401902:	48 8b 45 c8          	mov    0xffffffffffffffc8(%rbp),%rax
  401906:	48 83 c0 02          	add    $0x2,%rax
  40190a:	48 89 45 c8          	mov    %rax,0xffffffffffffffc8(%rbp)
  40190e:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401915:	00 00 00 
  401918:	48 89 45 b8          	mov    %rax,0xffffffffffffffb8(%rbp)
  40191c:	48 8b 45 b0          	mov    0xffffffffffffffb0(%rbp),%rax
  401920:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  401924:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401928:	48 8b 0d 49 05 20 00 	mov    2098505(%rip),%rcx        # 601e78 <_main+0x2003f4>
  40192f:	48 8b 09             	mov    (%rcx),%rcx
  401932:	48 39 c8             	cmp    %rcx,%rax
  401935:	0f 8d a7 00 00 00    	jge    4019e2 <arctan+0x68d>
  40193b:	e9 41 00 00 00       	jmpq   401981 <arctan+0x62c>
  401940:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401944:	48 b9 e0 ff ff ff ff 	mov    $0xffffffffffffffe0,%rcx
  40194b:	ff ff ff 
  40194e:	48 89 ca             	mov    %rcx,%rdx
  401951:	48 89 95 00 ff ff ff 	mov    %rdx,0xffffffffffffff00(%rbp)
  401958:	48 89 c2             	mov    %rax,%rdx
  40195b:	48 89 8d f8 fe ff ff 	mov    %rcx,0xfffffffffffffef8(%rbp)
  401962:	48 8b 8d 00 ff ff ff 	mov    0xffffffffffffff00(%rbp),%rcx
  401969:	48 89 95 f0 fe ff ff 	mov    %rdx,0xfffffffffffffef0(%rbp)
  401970:	48 8b 8d f8 fe ff ff 	mov    0xfffffffffffffef8(%rbp),%rcx
  401977:	48 83 c0 01          	add    $0x1,%rax
  40197b:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  40197f:	eb a3                	jmp    401924 <arctan+0x5cf>
  401981:	48 8b 45 e0          	mov    0xffffffffffffffe0(%rbp),%rax
  401985:	48 c1 e0 03          	shl    $0x3,%rax
  401989:	48 8b 0d d8 04 20 00 	mov    2098392(%rip),%rcx        # 601e68 <_main+0x2003e4>
  401990:	48 8b 09             	mov    (%rcx),%rcx
  401993:	48 01 c1             	add    %rax,%rcx
  401996:	48 8b 01             	mov    (%rcx),%rax
  401999:	48 83 f8 00          	cmp    $0x0,%rax
  40199d:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4019a4:	00 00 00 
  4019a7:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4019ae:	00 00 00 
  4019b1:	0f 85 0a 00 00 00    	jne    4019c1 <arctan+0x66c>
  4019b7:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  4019be:	00 00 00 
  4019c1:	48 85 c0             	test   %rax,%rax
  4019c4:	0f 84 13 00 00 00    	je     4019dd <arctan+0x688>
  4019ca:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4019d1:	00 00 00 
  4019d4:	48 89 45 b8          	mov    %rax,0xffffffffffffffb8(%rbp)
  4019d8:	e9 05 00 00 00       	jmpq   4019e2 <arctan+0x68d>
  4019dd:	e9 5e ff ff ff       	jmpq   401940 <arctan+0x5eb>
  4019e2:	48 8b 45 b8          	mov    0xffffffffffffffb8(%rbp),%rax
  4019e6:	48 83 f8 00          	cmp    $0x0,%rax
  4019ea:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4019f1:	00 00 00 
  4019f4:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  4019fb:	00 00 00 
  4019fe:	0f 85 0a 00 00 00    	jne    401a0e <arctan+0x6b9>
  401a04:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401a0b:	00 00 00 
  401a0e:	48 85 c0             	test   %rax,%rax
  401a11:	0f 84 63 00 00 00    	je     401a7a <arctan+0x725>
  401a17:	48 8b 45 b0          	mov    0xffffffffffffffb0(%rbp),%rax
  401a1b:	48 c1 e0 03          	shl    $0x3,%rax
  401a1f:	48 8b 0d 42 04 20 00 	mov    2098242(%rip),%rcx        # 601e68 <_main+0x2003e4>
  401a26:	48 8b 09             	mov    (%rcx),%rcx
  401a29:	48 01 c1             	add    %rax,%rcx
  401a2c:	48 8b 01             	mov    (%rcx),%rax
  401a2f:	48 83 f8 00          	cmp    $0x0,%rax
  401a33:	0f 85 41 00 00 00    	jne    401a7a <arctan+0x725>
  401a39:	48 8b 45 b0          	mov    0xffffffffffffffb0(%rbp),%rax
  401a3d:	48 b9 b0 ff ff ff ff 	mov    $0xffffffffffffffb0,%rcx
  401a44:	ff ff ff 
  401a47:	48 89 ca             	mov    %rcx,%rdx
  401a4a:	48 89 95 e8 fe ff ff 	mov    %rdx,0xfffffffffffffee8(%rbp)
  401a51:	48 89 c2             	mov    %rax,%rdx
  401a54:	48 89 8d e0 fe ff ff 	mov    %rcx,0xfffffffffffffee0(%rbp)
  401a5b:	48 8b 8d e8 fe ff ff 	mov    0xfffffffffffffee8(%rbp),%rcx
  401a62:	48 89 95 d8 fe ff ff 	mov    %rdx,0xfffffffffffffed8(%rbp)
  401a69:	48 8b 8d e0 fe ff ff 	mov    0xfffffffffffffee0(%rbp),%rcx
  401a70:	48 83 c0 01          	add    $0x1,%rax
  401a74:	48 89 45 b0          	mov    %rax,0xffffffffffffffb0(%rbp)
  401a78:	eb 9d                	jmp    401a17 <arctan+0x6c2>
  401a7a:	e9 bf f9 ff ff       	jmpq   40143e <arctan+0xe9>
  401a7f:	48 89 ec             	mov    %rbp,%rsp
  401a82:	5d                   	pop    %rbp
  401a83:	c3                   	retq   

0000000000401a84 <_main>:
  401a84:	55                   	push   %rbp
  401a85:	48 89 e5             	mov    %rsp,%rbp
  401a88:	48 81 ec 70 00 00 00 	sub    $0x70,%rsp
  401a8f:	48 89 7d f8          	mov    %rdi,0xfffffffffffffff8(%rbp)
  401a93:	48 89 75 f0          	mov    %rsi,0xfffffffffffffff0(%rbp)
  401a97:	48 8b 45 f8          	mov    0xfffffffffffffff8(%rbp),%rax
  401a9b:	48 83 f8 02          	cmp    $0x2,%rax
  401a9f:	0f 84 35 00 00 00    	je     401ada <_main+0x56>
  401aa5:	48 8d 05 f4 03 20 00 	lea    2098164(%rip),%rax        # 601ea0 <L.0>
  401aac:	48 89 c7             	mov    %rax,%rdi
  401aaf:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401ab6:	00 00 00 
  401ab9:	e8 19 ed ff ff       	callq  4007d7 <puts>
  401abe:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  401ac5:	00 00 00 
  401ac8:	48 89 c7             	mov    %rax,%rdi
  401acb:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401ad2:	00 00 00 
  401ad5:	e8 e8 e9 ff ff       	callq  4004c2 <llexit>
  401ada:	48 8b 45 f0          	mov    0xfffffffffffffff0(%rbp),%rax
  401ade:	48 83 c0 08          	add    $0x8,%rax
  401ae2:	48 89 45 d0          	mov    %rax,0xffffffffffffffd0(%rbp)
  401ae6:	48 8b 45 d0          	mov    0xffffffffffffffd0(%rbp),%rax
  401aea:	48 8b 00             	mov    (%rax),%rax
  401aed:	48 89 c7             	mov    %rax,%rdi
  401af0:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401af7:	00 00 00 
  401afa:	e8 bc f0 ff ff       	callq  400bbb <atol>
  401aff:	4c 8b 1d 72 03 20 00 	mov    2098034(%rip),%r11        # 601e78 <_main+0x2003f4>
  401b06:	49 89 03             	mov    %rax,(%r11)
  401b09:	48 8b 05 68 03 20 00 	mov    2098024(%rip),%rax        # 601e78 <_main+0x2003f4>
  401b10:	48 8b 00             	mov    (%rax),%rax
  401b13:	48 83 f8 00          	cmp    $0x0,%rax
  401b17:	0f 8f 35 00 00 00    	jg     401b52 <_main+0xce>
  401b1d:	48 8d 05 cd 03 20 00 	lea    2098125(%rip),%rax        # 601ef1 <L.1>
  401b24:	48 89 c7             	mov    %rax,%rdi
  401b27:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401b2e:	00 00 00 
  401b31:	e8 a1 ec ff ff       	callq  4007d7 <puts>
  401b36:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  401b3d:	00 00 00 
  401b40:	48 89 c7             	mov    %rax,%rdi
  401b43:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401b4a:	00 00 00 
  401b4d:	e8 70 e9 ff ff       	callq  4004c2 <llexit>
  401b52:	48 8b 05 1f 03 20 00 	mov    2097951(%rip),%rax        # 601e78 <_main+0x2003f4>
  401b59:	48 8b 00             	mov    (%rax),%rax
  401b5c:	48 83 c0 02          	add    $0x2,%rax
  401b60:	48 83 e8 01          	sub    $0x1,%rax
  401b64:	48 89 45 c8          	mov    %rax,0xffffffffffffffc8(%rbp)
  401b68:	48 b8 02 00 00 00 00 	mov    $0x2,%rax
  401b6f:	00 00 00 
  401b72:	48 89 c6             	mov    %rax,%rsi
  401b75:	48 8b 45 c8          	mov    0xffffffffffffffc8(%rbp),%rax
  401b79:	48 89 c7             	mov    %rax,%rdi
  401b7c:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401b83:	00 00 00 
  401b86:	e8 55 e5 ff ff       	callq  4000e0 <idiv_q>
  401b8b:	48 83 c0 01          	add    $0x1,%rax
  401b8f:	4c 8b 1d e2 02 20 00 	mov    2097890(%rip),%r11        # 601e78 <_main+0x2003f4>
  401b96:	49 89 03             	mov    %rax,(%r11)
  401b99:	48 8b 05 d8 02 20 00 	mov    2097880(%rip),%rax        # 601e78 <_main+0x2003f4>
  401ba0:	48 8b 00             	mov    (%rax),%rax
  401ba3:	48 c1 e0 03          	shl    $0x3,%rax
  401ba7:	48 89 45 c0          	mov    %rax,0xffffffffffffffc0(%rbp)
  401bab:	48 8b 45 c0          	mov    0xffffffffffffffc0(%rbp),%rax
  401baf:	48 89 c7             	mov    %rax,%rdi
  401bb2:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401bb9:	00 00 00 
  401bbc:	e8 55 ed ff ff       	callq  400916 <malloc>
  401bc1:	4c 8b 1d b8 02 20 00 	mov    2097848(%rip),%r11        # 601e80 <_main+0x2003fc>
  401bc8:	49 89 03             	mov    %rax,(%r11)
  401bcb:	48 8b 05 a6 02 20 00 	mov    2097830(%rip),%rax        # 601e78 <_main+0x2003f4>
  401bd2:	48 8b 00             	mov    (%rax),%rax
  401bd5:	48 c1 e0 03          	shl    $0x3,%rax
  401bd9:	48 89 45 b8          	mov    %rax,0xffffffffffffffb8(%rbp)
  401bdd:	48 8b 45 b8          	mov    0xffffffffffffffb8(%rbp),%rax
  401be1:	48 89 c7             	mov    %rax,%rdi
  401be4:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401beb:	00 00 00 
  401bee:	e8 23 ed ff ff       	callq  400916 <malloc>
  401bf3:	4c 8b 1d 6e 02 20 00 	mov    2097774(%rip),%r11        # 601e68 <_main+0x2003e4>
  401bfa:	49 89 03             	mov    %rax,(%r11)
  401bfd:	48 8b 05 74 02 20 00 	mov    2097780(%rip),%rax        # 601e78 <_main+0x2003f4>
  401c04:	48 8b 00             	mov    (%rax),%rax
  401c07:	48 c1 e0 03          	shl    $0x3,%rax
  401c0b:	48 89 45 b0          	mov    %rax,0xffffffffffffffb0(%rbp)
  401c0f:	48 8b 45 b0          	mov    0xffffffffffffffb0(%rbp),%rax
  401c13:	48 89 c7             	mov    %rax,%rdi
  401c16:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401c1d:	00 00 00 
  401c20:	e8 f1 ec ff ff       	callq  400916 <malloc>
  401c25:	4c 8b 1d 44 02 20 00 	mov    2097732(%rip),%r11        # 601e70 <_main+0x2003ec>
  401c2c:	49 89 03             	mov    %rax,(%r11)
  401c2f:	48 8b 05 4a 02 20 00 	mov    2097738(%rip),%rax        # 601e80 <_main+0x2003fc>
  401c36:	48 8b 00             	mov    (%rax),%rax
  401c39:	48 83 f8 00          	cmp    $0x0,%rax
  401c3d:	0f 84 2d 00 00 00    	je     401c70 <_main+0x1ec>
  401c43:	48 8b 05 1e 02 20 00 	mov    2097694(%rip),%rax        # 601e68 <_main+0x2003e4>
  401c4a:	48 8b 00             	mov    (%rax),%rax
  401c4d:	48 83 f8 00          	cmp    $0x0,%rax
  401c51:	0f 84 19 00 00 00    	je     401c70 <_main+0x1ec>
  401c57:	48 8b 05 12 02 20 00 	mov    2097682(%rip),%rax        # 601e70 <_main+0x2003ec>
  401c5e:	48 8b 00             	mov    (%rax),%rax
  401c61:	48 83 f8 00          	cmp    $0x0,%rax
  401c65:	0f 84 05 00 00 00    	je     401c70 <_main+0x1ec>
  401c6b:	e9 35 00 00 00       	jmpq   401ca5 <_main+0x221>
  401c70:	48 8d 05 9c 02 20 00 	lea    2097820(%rip),%rax        # 601f13 <L.2>
  401c77:	48 89 c7             	mov    %rax,%rdi
  401c7a:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401c81:	00 00 00 
  401c84:	e8 4e eb ff ff       	callq  4007d7 <puts>
  401c89:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  401c90:	00 00 00 
  401c93:	48 89 c7             	mov    %rax,%rdi
  401c96:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401c9d:	00 00 00 
  401ca0:	e8 1d e8 ff ff       	callq  4004c2 <llexit>
  401ca5:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401cac:	00 00 00 
  401caf:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  401cb3:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  401cb7:	48 8b 0d ba 01 20 00 	mov    2097594(%rip),%rcx        # 601e78 <_main+0x2003f4>
  401cbe:	48 8b 09             	mov    (%rcx),%rcx
  401cc1:	48 39 c8             	cmp    %rcx,%rax
  401cc4:	0f 8d 5b 00 00 00    	jge    401d25 <_main+0x2a1>
  401cca:	e9 32 00 00 00       	jmpq   401d01 <_main+0x27d>
  401ccf:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  401cd3:	48 b9 e8 ff ff ff ff 	mov    $0xffffffffffffffe8,%rcx
  401cda:	ff ff ff 
  401cdd:	48 89 ca             	mov    %rcx,%rdx
  401ce0:	48 89 55 a8          	mov    %rdx,0xffffffffffffffa8(%rbp)
  401ce4:	48 89 c2             	mov    %rax,%rdx
  401ce7:	48 89 4d a0          	mov    %rcx,0xffffffffffffffa0(%rbp)
  401ceb:	48 8b 4d a8          	mov    0xffffffffffffffa8(%rbp),%rcx
  401cef:	48 89 55 98          	mov    %rdx,0xffffffffffffff98(%rbp)
  401cf3:	48 8b 4d a0          	mov    0xffffffffffffffa0(%rbp),%rcx
  401cf7:	48 83 c0 01          	add    $0x1,%rax
  401cfb:	48 89 45 e8          	mov    %rax,0xffffffffffffffe8(%rbp)
  401cff:	eb b2                	jmp    401cb3 <_main+0x22f>
  401d01:	48 8b 45 e8          	mov    0xffffffffffffffe8(%rbp),%rax
  401d05:	48 c1 e0 03          	shl    $0x3,%rax
  401d09:	48 8b 0d 70 01 20 00 	mov    2097520(%rip),%rcx        # 601e80 <_main+0x2003fc>
  401d10:	48 8b 09             	mov    (%rcx),%rcx
  401d13:	48 01 c1             	add    %rax,%rcx
  401d16:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401d1d:	00 00 00 
  401d20:	48 89 01             	mov    %rax,(%rcx)
  401d23:	eb aa                	jmp    401ccf <_main+0x24b>
  401d25:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401d2c:	00 00 00 
  401d2f:	48 89 c7             	mov    %rax,%rdi
  401d32:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401d39:	00 00 00 
  401d3c:	e8 02 f1 ff ff       	callq  400e43 <time>
  401d41:	48 89 45 e0          	mov    %rax,0xffffffffffffffe0(%rbp)
  401d45:	48 b8 01 00 00 00 00 	mov    $0x1,%rax
  401d4c:	00 00 00 
  401d4f:	49 89 c2             	mov    %rax,%r10
  401d52:	48 b8 05 00 00 00 00 	mov    $0x5,%rax
  401d59:	00 00 00 
  401d5c:	48 89 c6             	mov    %rax,%rsi
  401d5f:	48 b8 10 00 00 00 00 	mov    $0x10,%rax
  401d66:	00 00 00 
  401d69:	48 89 c7             	mov    %rax,%rdi
  401d6c:	4c 89 d2             	mov    %r10,%rdx
  401d6f:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401d76:	00 00 00 
  401d79:	e8 d7 f5 ff ff       	callq  401355 <arctan>
  401d7e:	48 b8 ff ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  401d85:	ff ff ff 
  401d88:	49 89 c2             	mov    %rax,%r10
  401d8b:	48 b8 ef 00 00 00 00 	mov    $0xef,%rax
  401d92:	00 00 00 
  401d95:	48 89 c6             	mov    %rax,%rsi
  401d98:	48 b8 04 00 00 00 00 	mov    $0x4,%rax
  401d9f:	00 00 00 
  401da2:	48 89 c7             	mov    %rax,%rdi
  401da5:	4c 89 d2             	mov    %r10,%rdx
  401da8:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401daf:	00 00 00 
  401db2:	e8 9e f5 ff ff       	callq  401355 <arctan>
  401db7:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401dbe:	00 00 00 
  401dc1:	48 89 c7             	mov    %rax,%rdi
  401dc4:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401dcb:	00 00 00 
  401dce:	e8 70 f0 ff ff       	callq  400e43 <time>
  401dd3:	48 89 45 d8          	mov    %rax,0xffffffffffffffd8(%rbp)
  401dd7:	48 8b 05 a2 00 20 00 	mov    2097314(%rip),%rax        # 601e80 <_main+0x2003fc>
  401dde:	48 8b 00             	mov    (%rax),%rax
  401de1:	48 89 c7             	mov    %rax,%rdi
  401de4:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401deb:	00 00 00 
  401dee:	e8 70 f4 ff ff       	callq  401263 <Print>
  401df3:	48 8d 05 3c 01 20 00 	lea    2097468(%rip),%rax        # 601f36 <L.3>
  401dfa:	48 89 c7             	mov    %rax,%rdi
  401dfd:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401e04:	00 00 00 
  401e07:	e8 cb e9 ff ff       	callq  4007d7 <puts>
  401e0c:	48 8b 45 d8          	mov    0xffffffffffffffd8(%rbp),%rax
  401e10:	48 8b 4d e0          	mov    0xffffffffffffffe0(%rbp),%rcx
  401e14:	48 29 c8             	sub    %rcx,%rax
  401e17:	48 89 45 90          	mov    %rax,0xffffffffffffff90(%rbp)
  401e1b:	48 8b 45 90          	mov    0xffffffffffffff90(%rbp),%rax
  401e1f:	48 89 c7             	mov    %rax,%rdi
  401e22:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401e29:	00 00 00 
  401e2c:	e8 45 f2 ff ff       	callq  401076 <PrintVal>
  401e31:	48 8d 05 10 01 20 00 	lea    2097424(%rip),%rax        # 601f48 <L.4>
  401e38:	48 89 c7             	mov    %rax,%rdi
  401e3b:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401e42:	00 00 00 
  401e45:	e8 8d e9 ff ff       	callq  4007d7 <puts>
  401e4a:	48 b8 00 00 00 00 00 	mov    $0x0,%rax
  401e51:	00 00 00 
  401e54:	e9 00 00 00 00       	jmpq   401e59 <_main+0x3d5>
  401e59:	48 89 ec             	mov    %rbp,%rsp
  401e5c:	5d                   	pop    %rbp
  401e5d:	c3                   	retq   
