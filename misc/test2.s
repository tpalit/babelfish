        .global _start
        .text

_start:
        mov    $0x7000c0, %rcx
	
	mov	$0x7fffffffffffffff, %rax
	mov	$2, %r8
	imul	%r8
	mov	%rax,%r9
	mov	%rdx,%r10

	mov	$0x7fffffffffffffff, %rax
	mov	$2, %r11
	neg	%r11
	imul	%r11
	mov	%rax,%r12
	mov	%rdx, %r13

	mov	$0x7fffffffffffffff, %rax
	neg	%rax
	mov	$2, %r14
	neg	%r14
	imul	%r14
	mov	%rax,%r15
        retq
