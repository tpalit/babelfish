        .global _start
        .text

_start:
	mov    	$0x7fffffffffffffff, %rax
        neg	%rax
	
	mov    	$0x8000000000000000, %rax
        neg	%rax

	mov    	$0, %rax
        neg	%rax
	
	mov    	$1, %rax
        neg	%rax

	mov    	$0xffffffffffffffff, %rax
        neg	%rax

	mov    	$0x7f, %rax
        neg	%rax

	mov    	$0xfffffffffffffff0, %rax
        neg	%rax

	retq
