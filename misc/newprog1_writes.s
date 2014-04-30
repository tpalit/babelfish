        .global _start
        .text

_start:
        mov    $0x7000c0, %rax
	mov    $0x6000c0, %rbx
        mov    $0xBBBBBB, %r8
	mov    $0xCCCCCC, %r9
	and    %r11, %r11
	and    %r11, %r11
	and    %r11, %r11
	and    %r11, %r11
	and    %r11, %r11
	and    %r11, %r11
	and    %r11, %r11	
        mov    %r8, (%rax)
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
