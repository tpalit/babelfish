        .global _start
        .text

_start:
        mov    $0xBBBBBB, %r8
        mov    $0x7000c0, %rax
        mov    %r8, (%rax)
	add    $10, (%rax)
	mov    (%rax), %r9
        retq
