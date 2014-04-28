        .global _start
        .text

_start:
        mov    $0x42, %rax
        mov    (%rax), %rbx
        mov    $0x56, %rcx
        mov    (%rcx), %rdx
        add    $1, %rcx
        sub    $2, %rcx
        sub    $3, %rdx
        mov    (%rcx), %rdx
        retq
