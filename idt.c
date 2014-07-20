#include "asm.h"
#include "kernel.h"
#include "screen.h"
#include "idt.h"

static void do_default_isr();

void set_idt_entry(uint32_t n, uint32_t function)
{
	struct IDT_DESC *ptr;

	ptr = idt_table + n;
	ptr->offset_low = (uint16_t) (function);
	ptr->offset_high= (uint16_t) (function >> 16); 
	ptr->control	= DEFAULT_IDT_CONTROL;
	ptr->segment	= KERNEL_CODE_SELECTOR;
}

void get_idt_entry(uint32_t n, struct IDT_DESC *ptr)
{
	if (ptr)
	{
		_memcpy(ptr, idt_table + n, sizeof(struct IDT_DESC));
	}
}

void initialize_idt()
{
	struct LIDT_DESC lidt;
	struct IDT_DESC  item;

	for (uint32_t n = 0; n < IDT_TABLE_SIZE; ++n)
	{
		set_idt_entry(n, (uint32_t)&do_default_isr);
	}
	get_idt_entry(0x80, &item);

	lidt.length = IDT_TABLE_SIZE * sizeof(struct IDT_DESC) - 1;
	lidt.offset = (uint32_t)idt_table;

	_printf("length=0x%x, offset=0x%x\n", lidt.length, lidt.offset);
	_printf("low=%x, high=%x, segment=%x, control=%x, do=%p\n",
			item.offset_low, item.offset_high, item.segment, item.control, 
			&do_default_isr);
	__asm__("lidt %0"::"m"(lidt));
	_sti();
	__asm__("int $0x80");
}

void do_default_isr()
{
	_puts("hello idt\n");
L1:
	_io_hlt();
	goto	L1;
}


