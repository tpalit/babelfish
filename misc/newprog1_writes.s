        .global _start
        .text

_start:
        mov    $0xBBBBBB, %r8
	mov    $0xCCCCCC, %r9
        mov    $0x7000c0, %rax
	mov    $0x6000c0, %rbx			
        mov    %r8, (%rax)
	mov    %r9, (%rbx)
	mov    (%rax), %r10
	mov    (%rbx), %r11
	nop
<<<<<<< HEAD
	addq   $10, (%rax)
	movq   (%rax), %r12
=======
	add    $10, (%rax)
	mov    (%rax), %r14
>>>>>>> 4551093a08ef71ea3a30acfa428ec45e00069773
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
