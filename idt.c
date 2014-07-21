#include "asm.h"
#include "kernel.h"
#include "screen.h"
#include "pic.h"

#include "idt.h"

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
		set_idt_entry(n, (uint32_t)&default_isr);
	}
	get_idt_entry(0x80, &item);

	lidt.length = IDT_TABLE_SIZE * sizeof(struct IDT_DESC) - 1;
	lidt.offset = (uint32_t)idt_table;

	set_idt_entry(0, (uint32_t)&divide_error);
	set_idt_entry(1, (uint32_t)&debug_exception);
	set_idt_entry(2, (uint32_t)&nmi);
	set_idt_entry(3, (uint32_t)&breakpoint);
	set_idt_entry(4, (uint32_t)&overflow);
	set_idt_entry(5, (uint32_t)&bound);
	set_idt_entry(6, (uint32_t)&invalid_opcode);
	set_idt_entry(7, (uint32_t)&coprocessor_not_available);
	set_idt_entry(8, (uint32_t)&double_fault);
	set_idt_entry(9, (uint32_t)&coprocessor_segment_overrun);
	set_idt_entry(10, (uint32_t)&invalid_tss);
	set_idt_entry(11, (uint32_t)&segment_not_pressent);
	set_idt_entry(12, (uint32_t)&stack_exception);
	set_idt_entry(13, (uint32_t)&protection_exception);
	set_idt_entry(14, (uint32_t)&page_fault);
	set_idt_entry(15, (uint32_t)&intel_reserved);
	set_idt_entry(16, (uint32_t)&coprocessor_error);


	__asm__("lidt %0"::"m"(lidt));
	__asm__("int $0x80");
	initialize_pic();
}

static void kprint(uint32_t no, const char *desc)
{
	_printf("interrupt:0x%x, description:%s\n", no, desc);	
}

void do_divide_error(uint32_t error_code, const char *ptr)
{
	kprint(0x00, "do_divide_error");	
}

void do_debug_exception(uint32_t error_code, const char *ptr)
{
	kprint(0x01, "do_debug_exception");
}

void do_nmi(uint32_t error_code, const char *ptr)
{
	kprint(0x02, "do_nmi");
}

void do_breakpoint(uint32_t error_code, const char *ptr)
{
	kprint(0x03, "do_breakpoint");
}

void do_overflow(uint32_t error_code, const char *ptr)
{
	kprint(0x04, "do_overflow");
}

void do_bound(uint32_t error_code, const char *ptr)
{
	kprint(0x05, "do_bound");
}

void do_invalid_opcode(uint32_t error_code, const char *ptr)
{
	kprint(0x06, "do_invalid_opcode");
}

void do_coprocessor_not_available(uint32_t error_code, const char *ptr)
{
	kprint(0x07, "do_coprocessor_not_available");
}

void do_double_fault(uint32_t error_code, const char *ptr)
{
	_puts("double fault");
}

void do_coprocessor_segment_overrun(uint32_t error_code, const char *ptr)
{
	kprint(0x09, "do_coprocessor_segment_overrun");
}

void do_invalid_tss(uint32_t error_code, const char *ptr)
{
	kprint(0x0a, "do_invalid_tss");
}

void do_segment_not_pressent(uint32_t error_code, const char *ptr)
{
	kprint(0x0b, "do_segment_not_pressent");
}

void do_stack_exception(uint32_t error_code, const char *ptr)
{
	kprint(12, "do_stack_exception");
}

void do_protection_exception(uint32_t error_code, const char *ptr)
{
	_printf("do_protection_exception:%p\n", ptr);
}

void do_page_fault(uint32_t error_code, const char *ptr)
{
	kprint(14, "do_page_fault");
}

void do_inter_reserved(uint32_t error_code, const char *ptr)
{
	kprint(15, "do_inter_reserved");
}

void do_coprocessor_error(uint32_t error_code, const char *ptr)
{
	kprint(16, "do_coprocessor_error");
}

void do_default_isr(uint32_t error_code, const char *ptr)
{
	_printf("do_default_isr:error_code=%d, esp=%p\n", 
			error_code, ptr);
}

void do_timer(uint32_t error_code, const char *ptr)
{
	_puts("do_timer\n");
}
