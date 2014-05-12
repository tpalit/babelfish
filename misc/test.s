        .global _start
        .text

_start:
	mov    	$0x7fffffffffffffff, %rax
	mov    	$0xffffffffffffffff, %rbx
        test	%rbx, %rax
	
	mov    	$0x8000000000000000, %rax
        test	$1, %rax

	mov    	$0xffffffffffffffff, %rax
	mov    	$0xffffffffffffffff, %rbx
        test	%rbx, %rax
	
	mov    	$0, %rax
	mov    	$0, %rbx
        test	%rbx, %rax

	mov    	$0x8000000000000000, %rax
	mov    	$0x7fffffffffffffff, %rbx
        test	%rbx, %rax

	retq
