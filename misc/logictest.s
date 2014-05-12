        .global _start
        .text

_start:
        mov    $0x7000c0, %rax
        
	mov    $0xAAAAAAAA, %r8
        mov    %r8, (%rax)	
	xorq    $0xAA, (%rax)
	mov    (%rax), %r9
	
	mov    %r9, (%rax)
	orq     $0xAA, (%rax)
	mov    (%rax), %r10
	
	mov    %r10, (%rax)
	andq    $0x03, (%rax)
	mov    (%rax), %r11
	
	mov    %r11, (%rax)
	addq   $13, (%rax)
	mov    (%rax), %r12
        
	mov    $0x7000e0, %rbx
        
	mov    $0xffffffff, %r13
	mov	%r13, (%rbx)
	notq    (%rbx)
	mov 	(%rbx), %r13
	
	mov 	$1, %r14
	neg 	%r14
	mov 	%r14, %r15
	
	adc	$1, %r15
	
	mov 	%r15, %rcx 
	sbb 	$1, %rcx
	
	mov	%rcx, %rdx
	sub	$1, %rdx
	
	retq
