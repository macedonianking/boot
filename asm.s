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

	# interrupt program
	.globl	divide_error, do_divide_error
	.globl	debug_exception, do_debug_exception
	.globl	nmi, do_nmi
	.globl	breakpoint, do_breakpoint
	.globl	overflow, do_overflow
	.globl	bound, do_bound
	.globl	invalid_opcode, do_invalid_opcode
	.globl	coprocessor_not_available, do_coprocessor_not_available
	.globl	double_fault, do_double_fault
	.globl	coprocessor_segment_overrun, do_coprocessor_segment_overrun
	.globl	invalid_tss, do_invalid_tss
	.globl	segment_not_pressent, do_segment_not_pressent
	.globl	stack_exception, do_stack_exception
	.globl	protection_exception, do_protection_exception
	.globl	page_fault, do_page_fault
	.globl	intel_reserved, do_inter_reserved
	.globl	coprocessor_error, do_coprocessor_error
	.globl	default_isr, do_default_isr
	.globl	timer, do_timer

	.equ	VGA_PORT_MODE, 0x3d4
	.equ	VGA_PORT_DATA, 0x3d5
	.equ	VGA_MODE_CURSOR_HIGH, 0x0e
	.equ	VGA_MODE_CURSOR_LOW,  0x0f
	.equ	KERNEL_CODE_SEGMENT, (1 << 3)
	.equ	KERNEL_DATA_SEGMENT, (2 << 3)
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

handle_interrupt:	
	xchgl	(%esp), %eax	# &function->%eax
	xchgl	4(%esp), %ebx	# error code->%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%edi
	pushl	%esi
	pushl	%ebp
	pushl	%ds
	pushl	%es
	pushl	%fs
	pushl	%gs

# reset data segment to kernel data segment
	mov		$KERNEL_DATA_SEGMENT, %ecx
	mov		%ecx, %ds
	mov		%ecx, %es
	mov		%ecx, %fs
	mov		%ecx, %gs
	
# call handle(uint32_t error_code, char *esp);
	lea		52(%esp), %ecx
	pushl	%ecx
	pushl	%ebx
	call	*%eax
	add		$8, %esp

	popl	%gs
	popl	%fs
	popl	%es
	popl	%ds
	popl	%ebp
	popl	%esi
	popl	%edi
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	iret	
############################################################################
# interrupt method
############################################################################
divide_error:	
	pushl	$0x0000
	pushl	$do_divide_error
	jmp		handle_interrupt

debug_exception:
	pushl	$0x0000
	pushl	$do_debug_exception
	jmp		handle_interrupt

nmi:
	pushl	$0x0000
	pushl	$do_nmi
	jmp		handle_interrupt

breakpoint:
	pushl	$0x0000
	pushl	$do_breakpoint
	jmp		handle_interrupt

overflow:
	pushl	$0x0000
	pushl	$do_overflow
	jmp		handle_interrupt

bound:
	pushl	$0x0000
	pushl	$do_bound
	jmp		handle_interrupt

invalid_opcode:
	pushl	$0x0000
	pushl	$do_invalid_opcode
	jmp		handle_interrupt

coprocessor_not_available:
	pushl	$0x0000
	pushl	$do_coprocessor_not_available
	jmp		handle_interrupt

double_fault:
	pushl	$do_double_fault
	jmp		handle_interrupt

coprocessor_segment_overrun:
	pushl	$0x0000
	pushl	$do_coprocessor_segment_overrun
	jmp		handle_interrupt

invalid_tss:
	pushl	$do_invalid_tss
	jmp		handle_interrupt

segment_not_pressent:
	pushl	$do_segment_not_pressent
	jmp		handle_interrupt

stack_exception:
	pushl	$do_stack_exception
	jmp		handle_interrupt

protection_exception:
	pushl	$do_protection_exception
	jmp		handle_interrupt

page_fault:
	pushl	$do_page_fault
	jmp		handle_interrupt

intel_reserved:
	pushl	$0x0000
	pushl	$do_inter_reserved
	jmp		handle_interrupt

coprocessor_error:
	pushl	$0x0000	
	pushl	$do_coprocessor_error
	jmp		handle_interrupt

default_isr:
	pushl	$0x0000
	pushl	$do_default_isr
	jmp		handle_interrupt

timer:
	pushl	$0x0000
	pushl	$do_timer
	jmp		handle_interrupt
