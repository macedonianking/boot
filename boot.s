	.code16
	.text
	.globl	main
	.org	0x0000
main:
	mov		$0x07c0, %ax
	mov		%ax, %ds
	mov		$0x9000, %ax
	mov		%ax, %es
	xor		%si, %si
	mov		%di, %di
	mov		$512, %cx
	rep		movsb

	ljmp	$0x9000, $(go - main)
go:
	mov		%cs, %ax
	mov		%ax, %ss
	mov		%ax, %ds
	mov		%ax, %es
	mov		$0xff00, %bp
	mov		%bp, %sp

finish:
	hlt
	jmp		finish

PrintInt:
	push	%bp
	mov		%sp, %bp
	mov		$4, %cx
PrintInt_L1:
	push	%cx
	mov		4(%bp), %ax
	rol		$4, %ax
	mov		%ax, 4(%bp)
	and		$0xf, %ax
	cmp		$0xa, %al
	jge		PrintInt_L2
	add		$'0', %al
	jmp		PrintInt_L3	
PrintInt_L2:	
	sub		$0xa, %al
	add		$'a', %al
PrintInt_L3:
	mov		$0x0e, %ah
	mov		$0xff, %bx
	int		$0x10
	
	pop		%cx
	loop	PrintInt_L1
	mov		%bp, %sp
	pop		%bp
	ret
PrintInt_L4:
	push	%bp
	mov		%sp, %bp
	mov		$4, %cx
	
	mov		$(.LC0 - main), %di
	mov		(%di), %al
	mov		$0x0e, %ah
	mov		$0xff, %bx
	int		$0x10

	mov		%bp, %sp
	pop		%bp
	ret
PrintChar:
	push	%bp
	mov		%sp, %bp

	mov		4(%bp), %ax
	mov		$0x0e, %ah
	mov		$0xff, %bx
	int		$0x10

	mov		%bp, %sp
	pop		%bp
	ret
.LC0:
	.string	"0123456789abcdef"
	.org 0x1fe
	.short 0xaa55
