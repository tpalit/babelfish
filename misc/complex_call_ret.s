        .global _start
        .text

_start:
	xor    %rbp,%rbp
	mov    %rdx,%r9
	pop    %rsi
	mov    %rsp,%rdx
	and    $0xfffffffffffffff0,%rsp
	mov    $0x401a84,%rdi
	callq  _start_main
	callq  exit
	nop    

_start_main:
	push 	%rbp
	mov 	%rsp, %rbp
	mov 	%rbp, %rsp
	pop	%rbp
	retq

exit:
	movq 	$0x3C, %rax
	movq $0x0, %rdi
	syscall
	retq
	
