        .global _start
        .text

_start:
	mov    	$0x7fffffffffffffff, %rax
        inc	%rax
	mov    	$0xffffffffffffffff, %rax
        inc	%rax
	mov    	$0x8000000000000000, %rax
        inc	%rax
	mov    	$0xffffffffffff, %rax
        inc	%rax
	mov    	$0xfffffffffffffffe, %rax
        inc	%rax
	




	add	$0xffffffffffffffff, %rax
	mov 	$0,%rbx
	dec 	%rbx
	sbb	$2,%rbx
	mov	$0x7fffffffffffffff, %r8
	add	%r8,%r8
	mov	$0,%r9
	adc	$0x5,%r9
	sub	$7,%r9
	adc	$0x8000000, %r9
	inc	%r9
	dec	%r9
	add	%r9,%r9
	mov	$0,%r11
	sbb	$0xf,%r11
	
	retq
