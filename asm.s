	.text
	.globl	_io_in8	
	.globl	_io_out8	
	.globl	_io_in16	
	.globl	_io_out16	
	.globl	_io_hlt
	.globl	read_hard_disk
	.globl	reset_cursor	
	.globl	output_char
	.globl	_memcpy
	.globl	_put_int
	.equ	VGA_PORT_MODE, 0x3d4
	.equ	VGA_PORT_DATA, 0x3d5
	.equ	VGA_MODE_CURSOR_HIGH, 0x0e
	.equ	VGA_MODE_CURSOR_LOW,  0x0f
_io_in8: # char _io_in8(short port)
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

_io_in16: # short _io_in16(short port)
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

_io_out8: # void _io_out8(short port, char n)
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

_io_out16: # _io_out16(short port, short n)
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
# function: _io_hlt()
############################################################################
_io_hlt:	# void _io_hlt()
	hlt
	ret

############################################################################
# function: _memcpy(void *dst, void *src, int size)
############################################################################
_memcpy: # _memcpy(void *dst, void *src, int size) 
	push	%ebp
	mov		%esp, %ebp

	push	%ecx
	push	%esi
	push	%edi

	mov		16(%ebp), %ecx
	mov		12(%ebp), %esi	
	mov		8(%ebp),  %edi
	rep		movsb

	pop		%ecx
	pop		%esi
	pop		%edi

	mov		%ebp, %esp
	pop		%ebp
	ret
