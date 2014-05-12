        .global _start
        .text

_start:
	mov    	$0x7000c0, %rax
        mov	$4, %rsi
	lea 	4(%rax), %rdi

	retq
