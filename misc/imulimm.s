        .global _start
        .text

_start:
        mov	$0x8000000000000001, %rcx
	imul	$0x8000001, %rcx
	mov	%rdx, %r10
	retq
