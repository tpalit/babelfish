        .global _start
        .text

_start:
	mov    	$0xc000000000000000, %rax
        mov	$0xfffffffffffffff0, %rbx
	shr 	$1,%rax
	shr	$63,%rbx
	
	mov    	$0x4000000000000000, %rcx
        mov	$0x7fffffffffffffff, %rdx
	shr 	$1,%rcx
	shr	$63,%rdx
	
	mov    	$0xc000000000000000, %r8
        mov	$0xfffffffffffffff0, %r9
	sar 	$1,%r8
	sar	$63,%r9
	
	mov    	$0x4000000000000000, %rcx
        mov	$0x7fffffffffffffff, %rdx
	shr 	$1,%rcx
	shr	$63,%rdx

retq
