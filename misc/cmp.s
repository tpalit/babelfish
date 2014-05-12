        .global _start
        .text

_start:
	mov    	$0x7fffffffffffffff, %rax
	mov    	$0xffffffffffffffff, %rbx
        cmp	%rbx, %rax
	
	mov    	$0x8000000000000000, %rax
	mov    	$1, %rbx
        cmp	%rbx, %rax

	mov    	$0x8000000000000000, %rax
	mov    	$0xffffffffffffffff, %rbx
        cmp	%rbx, %rax
	
	mov    	$0x7fffffffffffffff, %rax
	mov    	$1, %rbx
        cmp	%rbx, %rax

	mov    	$0x8000000000000001, %rax
	mov    	$1, %rbx
        cmp	%rbx, %rax

	mov    	$0x7ffffffffffffffe, %rax
	mov    	$0xffffffffffffffff, %rbx
        cmp	%rbx, %rax

	mov    	$0x7fffffffffffffff, %rax
        cmp	%rax, %rax

	mov    	$0x8000000000000000, %rax
        cmp	%rax, %rax

	mov    	$0x7fffffffffffffff, %rax
        cmp	$0, %rax

	mov    	$0x8000000000000000, %rax
        cmp	$0, %rax
	
        mov	$0xfffffffffffffffe, %rax
	cmp 	$10, %rax
	
	mov 	$2, %rax
	mov	$0xfffffffffffffffa, %rbx
	cmp 	%rbx, %rax
	
	mov 	$2, %rax
	mov	$0xa, %rbx
	cmp 	%rbx, %rax
	
	mov 	$0xfffffffffffffff2, %rax
	mov	$0xfffffffffffffffa, %rbx
	cmp 	%rbx, %rax
	
	mov    	$0x100, %rax
        cmp	$0xfa, %rax
	


	retq
