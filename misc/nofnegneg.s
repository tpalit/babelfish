        .global _start
        .text

_start:
        mov	$2, %rax
	neg 	%rax
	mov	$2, %r8
	neg	%r8
	imul	%r8
	mov	%rax,%r9
	mov	%rdx, %r10

	imul	%r8
	mov	%rax,%r11
	mov	%rdx, %r12
	retq
