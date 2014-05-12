        .global _start
        .text

_start:
        mov	$0x7fffffffffffffff, %rax
	neg 	%rax
	mov	$0x7fffffffffffffff, %r8
	neg	%r8
	imul	%r8
	mov	%rax,%r9
	mov	%rdx, %r10
	retq
