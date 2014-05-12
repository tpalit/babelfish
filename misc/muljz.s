        .global _start
        .text

_start:
	mov    	$0xffffffffffffffef, %rax
        inc	%rax
	mov	$0xc000000000000000, %rbx
	mul 	%rbx
	mov 	$1, %r8
	jz	.change
	mov	$3, %r8

.change:mov	$1, %rax
	retq
