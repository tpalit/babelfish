        .global _start
        .text

_start:
	mov $1, %rax # system call 1 is write
	mov $1, %rdi # file handle 1 is stdout
	mov $message, %rsi # address of string to output
	mov $13, %rdx # number of bytes
	callq print
	mov $0x100, %r10
	callq exit
	retq
exit:
	movq 	$0x3C, %rax
	movq $0x0, %rdi
	syscall
	retq

print:
	# write(1, message, 13)
	syscall # invoke operating system to do the write
	retq

message:
	.ascii "Hello, world\n"
	
