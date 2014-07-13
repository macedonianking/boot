	.file	"main.s"
	.code16
	.text
	.globl	main
	.equ	TEXT_BASE, 0xb8000
	.equ	KERNEL_START_ADDR, 0x100000
	.equ	KERNEL_END_ADDR, 0x200000
	.equ	KERNEL_GDT_ADDR, 0x5000
	.equ	KERNEL_IDT_ADDR, 0x6000
	.org	0x0000
main:
	mov		$0x0000, %ax
	mov		%ax, %es
	mov		$0x07c0, %ax
	mov		%ax, %ds

	cld
	mov		$20, %cx
	mov		$gdt_base, %si
	mov		$KERNEL_GDT_ADDR, %di
	rep		movsw

	lgdt	gdt_entry
	in		$0x92, %al
	or		$0x02, %al
	out		%al, $0x92
	cli

	mov		%cr0, %eax
	or		$0x01, %eax
	mov		%eax, %cr0
	jmp		$0x20, $flush
flush:
	.code32
# set data segment
	mov		$0x10, %ax	
	mov		%ax, %ds
	mov		%ax, %es
	mov		%ax, %fs
	mov		%ax, %gs

# set stack segment
	mov		$0x18, %ax
	mov		%ax, %ss
	xor		%esp, %esp
	mov		%esp, %ebp

	call	load_kernel

	movb	$'P', (TEXT_BASE)
	jmp		$0x08, $0x0000

finish:
	jmp		finish
PRINT_Y:
	call	printY
	jmp		finish

PRINT_N:
	call	printN
	jmp		finish

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

load_kernel:
	push	%ebp
	mov		%esp, %ebp

	sub		$8, %esp
	movl	$0x0001, -4(%ebp)
	movl	$KERNEL_START_ADDR, -8(%ebp)

load_kernel_L1:
	cmpl	$KERNEL_END_ADDR, -8(%ebp)
	jae		load_kernel_L2
	push	-8(%ebp)
	push	-4(%ebp)
	mov		4(%esp), %eax
	call	read_hard_disk
	add		$8, %esp

	mov		-4(%ebp), %eax
	inc		%eax
	mov		%eax, -4(%ebp)

	mov		-8(%ebp), %eax
	add		$0x200, %eax
	mov		%eax, -8(%ebp)
	jmp		load_kernel_L1
	
load_kernel_L2:
	mov		%ebp, %esp
	pop		%ebp
	ret

printY:
	movb	$'Y', (TEXT_BASE)
	ret

printN:
	movb	$'N', (TEXT_BASE)
	ret

gdt_base:
	.short	0x0000, 0x0000, 0x0000, 0x0000
	.short	0x00ff, 0x0000, 0x9a10, 0x00c0	# kernel code segment
	.short	0xffff, 0x0000, 0x9200, 0x004f	# kernel data segment
	.short	0xfeff, 0x0000, 0x9630, 0x00cf	# kernel stack segment
	.short	0x01ff, 0x7c00, 0x9800, 0x0040	# boot code segment
gdt_entry:
	.short	0x0fff	
	.short	KERNEL_GDT_ADDR, 0x0000
	.org	0x1fe
	.short	0xaa55
