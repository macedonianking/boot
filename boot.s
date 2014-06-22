	.code16
	.data
	.globl	main
	.org	0x00
main:
	mov		$'a', %al
	mov		$0x0e,%ah
	mov		$15, %bx
	int		$0x10
	hlt	
	jmp		main
	.org	0x1fe
	.short	0xaa55

