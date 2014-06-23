	.code16
	.text
	.globl	main
.equ	SETUPLEN,4
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

	mov		$0x0002, %dh
	mov		$0x0002, %cx
	mov		$0x0200, %bx
	mov		$(0x0200 + SETUPLEN), %ax
	int		$0x13
	jnc		LOAD_SETUP_FINISH
LOAD_SETUP_FINISH:
	mov		$0x08, %ah
	mov		$0x80, %dl
	int		$0x13
	jnc		LOAD_STATE_FINISH
	jmp		PRINT_FAILURE

LOAD_STATE_FINISH:
	xor		%bx, %bx
	mov		%dl, %bl
	mov		%bx, driver_count - main
	mov		%dh, %bl
	mov		%bx, tracker_count - main
	mov		%cl, %bl
	and		$0x3f, %bl
	mov		%bx, sector_count - main
	mov		%ch, %bl
	mov		%cl, %bh
	rol		$2, %bh
	and		$0x3ff, %bx
	mov		%bx, clinder_count - main

	mov		$0x80, %dl
	mov		$0x00, %dh
	mov		$0x01, %cl
	mov		$0x00, %ch
	mov		$0x0200, %bx
	mov		$(0x0200 + SETUPLEN),%ax
	int		$0x13
	jc		PRINT_FAILURE

	jmp		PRINT_SUCCESS

PRINT_FAILURE:
	push	$'n'
	call	PrintChar
	add		$2, %sp
	jmp		finish
PRINT_SUCCESS:
	push	$'y'
	call	PrintChar
	add		$2, %sp
	jmp		finish

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
driver_count:
	.short	0x0000
tracker_count:
	.short	0x0000
sector_count:
	.short	0x0000
clinder_count:
	.short	0x0000
.LC0:
	.string	"0123456789abcdef"
	.org 0x1fe
	.short 0xaa55
