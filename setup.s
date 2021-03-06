	.code16
	.text
	.globl	main
	.org	0x0000
	.equ 	SETUPLEN, 4
main:
	mov		%cs, %ax
	mov		%ax, %ss
	mov		%ax, %ds
	mov		%ax, %es
	mov		$0xff00, %bp
	mov		%bp, %sp

# load driver paramters
	mov		$0x08, %ah
	mov		$0x80, %dl
	int		$0x13
	jnc		LOAD_STATE_FINISH
	jmp		FAILURE

# move driver parameters to memories
LOAD_STATE_FINISH:
	xor		%bx, %bx
	mov		%dl, %bl
	mov		%bx, driver_count
	mov		%dh, %bl
	mov		%bx, tracker_count
	mov		%cl, %bl
	and		$0x3f, %bl
	mov		%bx, sector_count
	mov		%ch, %bl
	mov		%cl, %bh
	rol		$2, %bh
	and		$0x3ff, %bx
	mov		%bx, clinder_count
	
# output load system message
	push	$MSG
	call	Print
	add		$2, %sp
	
	push	driver_count
	call	PrintHex
	add		$2, %sp

	push	clinder_count
	call	PrintHex
	add		$2, %sp

	push	tracker_count	
	call	PrintHex
	add		$2, %sp

	push	sector_count
	call	PrintHex
	add		$2, %sp

	push	$NEWLINE
	call	Print
	add		$2, %sp

# initialize variables
	movw	$0x0, current_tracker
	movw	$(2 + SETUPLEN), current_sector
	movw	$0x0000, current_clinder
	movw	$0x1000, current_segment 
	movw	$0x0000, current_offset
	movw	$0x0000, loop_count
MAIN_LOAD:
	mov		current_segment, %ax
	cmp		$0x9000, %ax
	jae		SUCCESS
	jmp		BEGIN_SECTORS
END_SECTORS:
	call	OUTPUT_CURRENT_STATE
	mov		read_sectors, %ax
	shl		$9, %ax
	add		current_offset, %ax
	jnc		END_L1
	mov		current_segment, %ax
	add		$0x1000, %ax
	mov		%ax, current_segment
	mov		$0x0000, %ax
END_L1:
	mov		%ax, current_offset
	mov		current_sector, %ax
	add		read_sectors, %ax	
	cmp		sector_count, %ax
	jg		END_L2
	mov		%ax, current_sector
	jmp		MAIN_END_ONE_LOOP
END_L2:
	mov		$0x01, %ax
	mov		%ax, current_sector
	mov		current_tracker, %ax
	inc		%ax
	mov		%ax, current_tracker
	cmp		tracker_count, %ax
	jle		MAIN_END_ONE_LOOP
	mov		$0x00, %ax
	mov		%ax, current_tracker
	mov		current_clinder, %ax
	inc		%ax
	mov		%ax, current_clinder
	cmp		clinder_count, %ax
	jle		MAIN_END_ONE_LOOP
	mov		$0x00, %ax
	mov		%ax, current_clinder
MAIN_END_ONE_LOOP:
	jmp		MAIN_LOAD

finish:
	hlt
	jmp		finish

# print n character to screen
FAILURE:
	push	$'n'
	call	PrintChar
	add		$2, %sp
	jmp		finish
SUCCESS:
	push	$'y'
	call	PrintChar
	add		$2, %sp
	jmp		finish

# computer read sectors
BEGIN_SECTORS:
	mov		sector_count, %ax
	sub		current_sector, %ax
	inc		%ax
	mov		%ax, %dx
	shl		$9, %dx
	add		current_offset, %dx
	jnc		BEGIN_SECTORS_L1	
	mov		current_offset, %dx
	not		%dx
	inc		%dx
	shr		$9, %dx
	mov		%dx, %ax
BEGIN_SECTORS_L1:
	mov		%ax, read_sectors
	jmp		END_SECTORS	

OUTPUT_CURRENT_STATE:
	push	%bp
	mov		%sp, %bp

# current segment
	push	current_segment
	call	PrintHex
	add		$2, %sp

# current offset
	push	current_offset
	call	PrintHex
	add		$2, %sp

# current clinder
	push	current_clinder
	call	PrintHex
	add		$2, %sp

# current tracker
	push	current_tracker
	call	PrintHex
	add		$2, %sp

# current first sector
	mov		current_sector, %ax
	push	%ax
	call	PrintHex
	add	$2, %sp

# current read sectors
	push	read_sectors
	call	PrintHex
	add		$2, %sp

# output new line
	push	$'\r'
	call	PrintChar
	add		$2, %sp
	push	$'\n'
	call	PrintChar
	add		$2, %sp

	mov		%bp, %sp
	pop		%bp
	ret

PrintHex:
	push	%bp
	mov		%sp, %bp
	
	push	$'0'
	call	PrintChar
	add		$2, %sp
	push	$'x'
	call	PrintChar
	add		$2, %sp
	push	4(%bp)
	call	PrintInt
	add		$2, %sp
	push	$' '
	call	PrintChar
	add		$2, %sp

PrintHex_L1:
	mov		%bp, %sp
	pop		%bp
	ret

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
	
	mov		$.LC0, %di
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

Print:
	push	%bp
	mov		%sp, %bp

	movw	4(%bp), %si
Print_L2:
	lodsb
	cmp		$0x00, %al
	je		Print_L1
	mov		$0x0e, %ah
	mov		$0xff, %bx
	int		$0x10
	jmp		Print_L2	

Print_L1:
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
loop_count:
	.short	0x0000
.LC0:
	.string	"0123456789abcdef"
MSG:
	.string "Load system...\r\n"
NEWLINE:
	.string	"\r\n"
	.org	0x7fe
	.short	0xaa55
