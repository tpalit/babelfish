        .global _start
        .text

_start:
	movq	$0x10, %rax
	movq	$0x10, %rbx
	addq	%rax, %rbx
	subq	$0x10, %rbx
	jz	.here # This branch shouldn't be taken
	movq	$0x40, %rcx
.here:	addq	$0x30, %rdx
	subq	$0x30, %rdx
	jz	.there # This branch should be taken
	movq 	$0x50, %r8
	movq	$0x60, %r9
	movq	$0x70, %r10
	movq	$0x80, %r11
.there: movq	$0x100, %r12
	movq	$0xFFFFFFFFFFFFFFFF, %rax
	addq	$0x1, %rax
	jc	.carry_happened_1 # This branch should be taken
	movq 	$0x1, %rcx
	movq 	$0x1, %rdx
.carry_happened_1:
	movq	$0x99, %rax
	/*
	addq	$0x2, %rax
	jc	.carry_happened_2
	movq	$0x99, %rbx
.carry_happened_2:
	*/
	
        retq
