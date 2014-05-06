        .global _start
        .text

_start:
	mov $0x7000e0, %rbp
	mov $0x6000e0, %rsp
	push %rbp
	pop  %rdi
	retq
