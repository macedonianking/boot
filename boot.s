	.code16
	.text
	.globl	main
	.org	0x0000
main:
	mov		$0x00, %ax
	mov		%ax, %ss
	mov		%ax, %ds
	mov		%ax, %es
	mov		%ax, %bp
	mov		$main, %sp

	call	PRINT_MSG

FINISH:
	hlt	
	jmp		FINISH

PRINT_MSG:
	push	%bp
	mov		%sp, %bp

	mov		$MSG, %di
PRINT_L1:
	mov		(%di), %al
	cmp		$0x00, %al
	jz		PRINT_L2
	push	%di
	mov		$0x0e, %ah
	mov		$0xff, %bx
	int		$0x10
	pop		%di
	inc		%di
	jmp		PRINT_L1

PRINT_L2:
	mov		%bp, %sp
	pop		%sp
	ret
MSG:
	.string	"I am loading...\r\n"
	.org	0x1fe
	.short	0xaa55

