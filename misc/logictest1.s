        .global _start
        .text

_start:
        mov    $0x7000c0, %rcx
	mov 	$0x6000e0, %rsp
	
	mov    $0, %r8
        mov    %r8, (%rcx)	
	decq   (%rcx)
	mov    (%rcx), %r8
	
	push 	%r8	
	
	incq    (%rcx)
	mov    (%rcx), %r9
	
	push 	%rsp	
	
	mov 	$0xf, %rbx
	mov	$0, %rax 
	mul 	%rbx
	mov	%rax, %r10

	inc 	%rax
	inc 	%rax
	movq	$0xffffffffffffffff, (%rcx)	
	mulq	(%rcx)
	mov	%rax, %r11

	mov 	$0, %rax
	sbb 	$1, %rax	
	
	movq	$2, (%rcx)	
	imulq	(%rcx)
	mov	%rax, %r12
 	
	imul	%r12
	mov	%rax, %r13
	
	pop 	%r14
	pop	%r15	
	
	retq
