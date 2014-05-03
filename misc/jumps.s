        .global _start
        .text

_start:
	/*
	movq	$0x10, %rax
	movq	$0x10, %rbx
	addq	%rax, %rbx
	subq	$0x20, %rbx
	jz	.here
	movq	$0x40, %rcx
.here:	addq	$0x30, %rdx
        retq
	*/
	movq	$0x10, %rax
	movq	$0x10, %rbx
	addq	%rax, %rbx
	subq	$0x2, %rbx
	jz 	.here
	jz	.there
.there: movq $0x11, %rcx

.here:	movq $0x54, %rdx
	addq %rdx, %rax
	jz .everywhere
	movq $0x06, %rax
	movq $0x07, %rbx

.everywhere:
	movq $0x11, %rbx
	retq
	
