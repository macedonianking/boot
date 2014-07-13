	.text
	.globl	io8_in
	.globl	io8_out
	.globl	io16_in
	.globl	io16_out
	.globl	io_hlt
	.globl	read_hard_disk
	.globl	reset_cursor	
	.globl	output_char
	.equ	VGA_PORT_MODE, 0x3d4
	.equ	VGA_PORT_DATA, 0x3d5
	.equ	VGA_MODE_CURSOR_HIGH, 0x0e
	.equ	VGA_MODE_CURSOR_LOW,  0x0f
io8_in:
	push	%ebp
	mov		%esp, %ebp
	push	%edx
	
	xor		%eax, %eax
	mov		8(%ebp), %dx
	in		%dx, %al

	pop		%edx	
	mov		%ebp, %esp
	pop		%ebp
	ret

io16_in:
	push	%ebp
	mov		%esp, %ebp
	push	%edx
	
	xor		%eax, %eax
	mov		8(%ebp), %dx
	in		%dx, %ax

	pop		%edx	
	mov		%ebp, %esp
	pop		%ebp
	ret

io8_out:
	push	%ebp
	mov		%esp, %ebp
	push	%edx
	push	%eax
	
	mov		8(%ebp), %dx
	mov		12(%ebp), %al
	out		%al, %dx

	pop		%eax
	pop		%edx
	mov		%ebp, %esp
	pop		%ebp
	ret

io16_out:
	push	%ebp
	mov		%esp, %ebp
	push	%edx
	push	%eax

	mov		8(%ebp), %dx
	mov		12(%ebp), %al
	out		%ax, %dx

	pop		%eax
	pop		%edx
	mov		%ebp, %esp
	pop		%ebp
	ret

reset_cursor:
	push	%ebp
	mov		%esp, %ebp
	push	%edx
	
	mov		$VGA_MODE_CURSOR_HIGH, %al
	mov		$VGA_PORT_MODE, %dx
	out		%al, %dx
	mov		$0x00, %al
	mov		$VGA_PORT_DATA, %dx
	out		%al, %dx

	mov		$VGA_MODE_CURSOR_LOW, %al
	mov		$VGA_PORT_MODE, %dx
	out		%al, %dx
	mov		$0x00, %al
	mov		$VGA_PORT_DATA, %dx
	out		%al, %dx

	pop		%edx

	mov		%ebp, %esp
	pop		%ebp
	ret
############################################################################
# read hard disk
############################################################################
read_hard_disk:
	push	%ebp
	mov		%esp, %ebp

	push	%ecx
	push	%edx
	push	%edi

# set read sector count 1
	mov		$0x01, %al
	mov		$0x1f2, %dx
	out		%al, %dx 

# set read sector index
	mov		8(%ebp), %al
	mov		$0x1f3, %dx
	out		%al, %dx 

	mov		9(%ebp), %al
	mov		$0x1f4, %dx
	out		%al, %dx 

	mov		10(%ebp), %al
	mov		$0x1f5, %dx
	out		%al, %dx 

	mov		11(%ebp), %al
	and		$0x0f, %al
	or		$0xe0, %al
	mov		$0x1f6, %dx
	out		%al, %dx 
	
# output read command
	mov		$0x20, %al
	mov		$0x1f7, %dx
	out		%al, %dx 
	
# wait hard disk read finish
wait_hard_disk_read_finish:
	in		%dx, %al
	and		$0x88, %al
	cmp		$0x08, %al
	jnz		wait_hard_disk_read_finish	

	mov		$0x100, %ecx
	mov		12(%ebp), %edi
	mov		$0x1f0, %dx
wait_read_sector_finish:
	in		%dx, %ax
	mov		%ax, (%edi)
	add		$2, %edi
	loop	wait_read_sector_finish

read_hard_disk_finish:
	pop		%edi
	pop		%edx
	pop		%ecx

	leave
	ret


############################################################################
# function: output a char to 0xb8000
############################################################################
output_char:
	push	%ebp
	mov		%esp, %ebp

	mov		8(%ebp), %al
	mov		%al, (0xb8000)

	mov		%ebp, %esp
	pop		%ebp
	ret


############################################################################
# function: io_hlt()
############################################################################
io_hlt:	# void io_hlt()
	hlt
	ret
