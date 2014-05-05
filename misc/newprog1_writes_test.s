        .global _start
        .text

_start:
        mov    $0xBBBBBB, %r8
	mov    $0xCCCCCC, %r9
	mov    $0xEEEEEE, %r10
	mov    $0xDDDDDD, %rsp
        mov    $0x7000e8, %rax
	mov    $0x6000f0, %rbx			
	mov    $0x5107f0, %rcx			
	mov    $0x7100f0, %rdx			
        mov    %r8, (%rax)
	mov    %r9, (%rbx)
	mov    %r10, (%rcx)
	mov    %rsp, (%rdx)
	mov    (%rax), %r11
	mov    (%rbx), %r12
	mov    (%rcx), %r13
	mov    (%rdx), %rbp
	nop
	add    $10, (%rax)
	mov    (%rax), %r14
	add    $30, (%rbx)
	mov    (%rbx), %r15
	add    $80, (%rdx)
	mov    (%rdx), %rsi
	mov    %rsp, (%rdx)
	add    $20, (%rdx)
	mov    (%rdx), %rdi
//        mov    %r8, (%rbx)
/*        sub    $3, %rdx
        sub    $3, %rdx
        sub    $3, %rdx
        sub    $3, %rdx
        sub    $3, %rdx
        sub    $3, %rdx
        sub    $3, %rdx
        mov    (%rcx), %rdx*/
        retq
