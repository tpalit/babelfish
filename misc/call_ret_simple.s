        .global _start
        .text

_start:
	movq 	$0x10, %rax
	callq fn
	movq 	$0x11, %rcx
	movq 	$0x12, %rdx
	callq fn2
	retq

fn:	addq 	$0x13, %r8
	retq

fn2:	addq	$0x14, %r9
	retq
