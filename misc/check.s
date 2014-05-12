        .global _start
        .text

_start:
        mov	$0x8000000000000001, %rcx
	imul	$0x8000001, %rcx
	inc	%rdx	
	retq
