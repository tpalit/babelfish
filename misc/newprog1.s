        .global _start
        .text

_start:
        mov    $0x42, %rax
        mov    (%rax), %rbx
        nop
        nop
        nop
        nop
        nop
        retq
