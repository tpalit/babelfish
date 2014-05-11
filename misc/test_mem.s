	.global _start
	.text

_start:
	xor    %rbp,%rbp
	mov    %rdx,%r9
	mov    %rsp,%rdx
	mov    $m,%rdi
	callq  *%rdi
	movq   	$0x7c10, %r10
	movq    (%r10), %rbx
	movq	(%rbx), %rcx
	mov    $0x3c,%rax
	xor %rdi, %rdi
	syscall



m:
	mov    $0x1,%rax
	mov    $0x1,%rdi
	mov    $message,%rsi
	mov    $0xd,%rdx
	syscall 
	xor    %rax,%rax
	retq   
	
message:
	.ascii "Hi!\n"
