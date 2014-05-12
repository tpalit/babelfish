        .global _start
        .text

_start:
	mov    	$0xffffffffffffffff, %rax
	mov	$0xffffffffffffffff, %rbx
       	add	%rbx,%rax
	
	mov	$0, %r8
	mov 	$0x7fffffffffffffff,%r9
	adc 	%r9,%r8

	mov    	$0xffffffffffffffff, %rax
	mov	$0xffffffffffffffff, %rbx
       	add	%rbx,%rax
	
	mov	$0x8000000000000001, %r8
	sbb 	$1, %r8
	
	mov	$0x7fffffffffffffff, %r8
	adc 	$0, %r8
	
	mov	$0, %rax
	sbb	$0, %rax

	retq
