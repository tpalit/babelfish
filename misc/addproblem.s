        .global _start
        .text

_start:
	mov    	$0xc000000000000000,%rax
	mov	$0xffffffffffffffff,%rbx
	add	%rbx,%rax
	retq
