        .global _start
        .text

_start:
	mov    	$0xfffffffffffffffe,%rax
	mov	$0xfffffffffffffffe,%rbx
	add	%rbx,%rax
	

	mov    	$0x8,%rax
	mov	$0x7f,%rbx
	add	%rbx,%rax

	mov    	$0x8000000000000000,%rax
	mov	$0x7fffffffffffffff,%rbx
	add	%rbx,%rax
	
	mov    	$0x8000000000000000,%rax
	mov	$0xffffffffffffffff,%rbx
	add	%rbx,%rax
	
	mov    	$0x8000000000000000,%rax
	mov	$0xffffffffffffff00,%rbx
	add	%rbx,%rax
	
	mov    	$0x8000000000000000,%rax
	mov	$0x8000000000000000,%rbx
	add	%rbx,%rax
	
	mov    	$0x7fffffffffffffff,%rax
	mov	$0x7fffffffffffffff,%rbx
	add	%rbx,%rax
	
	mov    	$0x1,%rax
	mov	$0x7fffffffffffffff,%rbx
	add	%rbx,%rax
	
	mov    	$0xffffffffffffffff,%rax
	mov	$0x7fffffffffffffff,%rbx
	add	%rbx,%rax
	
	mov    	$0x1,%rax
	mov	$0x8000000000000000,%rbx
	add	%rbx,%rax
	

	retq
