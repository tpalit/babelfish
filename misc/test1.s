        .global _start
        .text

_start:
        mov    $0x7000c0, %rcx

	mov 	$2, %rax
	neg 	%rax	
	mov	$2, %r8	
	imul	%r8
	mov	%rax,%r9
	imul	%rax
	mov	%rax, %r10
        retq
