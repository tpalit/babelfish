        .global _start
        .text

_start:
	mov    	$0x7fffffffffffffff, %rax
	mov    	$0xffffffffffffffff, %rbx
        sub	%rbx, %rax
	
	mov    	$0x8000000000000000, %rax
	mov    	$1, %rbx
        sub	%rbx, %rax

	mov    	$0x8000000000000000, %rax
	mov    	$0xffffffffffffffff, %rbx
        sub	%rbx, %rax
	
	mov    	$0x7fffffffffffffff, %rax
	mov    	$1, %rbx
        sub	%rbx, %rax

	mov    	$0x8000000000000001, %rax
	mov    	$1, %rbx
        sub	%rbx, %rax

	mov    	$0x7ffffffffffffffe, %rax
	mov    	$0xffffffffffffffff, %rbx
        sub	%rbx, %rax

	mov    	$0x7fffffffffffffff, %rax
        sub	%rax, %rax

	mov    	$0x8000000000000000, %rax
        sub	%rax, %rax

	mov    	$0x7fffffffffffffff, %rax
        sub	$0, %rax

	mov    	$0x8000000000000000, %rax
        sub	$0, %rax
	
        mov	$0xfffffffffffffffe, %rax
	sub 	$10, %rax
	
	mov 	$2, %rax
	mov	$0xfffffffffffffffa, %rbx
	sub 	%rbx, %rax
	
	mov 	$2, %rax
	mov	$0xa, %rbx
	sub 	%rbx, %rax
	
	mov 	$0xfffffffffffffff2, %rax
	mov	$0xfffffffffffffffa, %rbx
	sub 	%rbx, %rax
	
	mov    	$0x100, %rax
        sub	$0xfa, %rax
	


	retq
