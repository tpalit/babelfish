        .global _start
        .text

_start:
	movq	$0x10, %rax
	movq	$0x10, %rbx
	addq	%rax, %rbx
	subq	$0x20, %rbx
	jz	.here
	movq	$0x40, %rcx
.here:	movq	$0x30, %rdx
        retq
