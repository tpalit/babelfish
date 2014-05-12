        .global _start
        .text

_start:
	mov    	$0xc000000000000000, %rax
	shr	$1,%rax
        
	mov	$0xfffffffffffffff0, %rbx
	sar 	$1,%rbx
	
	mov    	$0xc000000000000000, %rcx
	sar	$4,%rcx
	retq
