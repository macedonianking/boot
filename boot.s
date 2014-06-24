	.code16
	.text
	.globl	main
.equ	SETUPLEN,4
	.org	0x0000
main:
	mov		$0x9000, %ax
	mov		%ax, %es

# read 4 sectors to 0x90000
	mov		$0x80, %dl
	mov		$0x00, %dh
	mov		$0x02, %cl
	mov		$0x00, %ch
	mov		$0x0000, %bx
	mov		$0x02, %ah
	mov		$0x04, %al
	int		$0x13
	jnc		L1
	push	$'n'
	call	PrintChar
	add		$2, %sp
	jmp		finish
L1:
	push	$'y'
	call	PrintChar
	add		$2, %sp
	jmp		$0x9000, $0x0000

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
current_tracker:
	.short	0x0000
current_clinder:
	.short	0x0000
current_sector:
	.short	0x0000
current_segment:
	.short	0x0000
current_offset:
	.short	0x0000
read_sectors:
	.short	0x0000
.LC0:
	.string	"0123456789abcdef"
	.org 0x1fe
	.short 0xaa55
