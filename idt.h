#ifndef _BOOT_IDT_H
#define _BOOT_IDT_H

#include "bootint.h"

#define IDT_TABLE_SIZE		256
#define DEFAULT_IDT_CONTROL	0x8e00

#define SS_OFFSET		2
#define ESP_OFFSET		1
#define EFLAGS_OFFSET	0
#define CS_OFFSET		-1
#define EIP_OFFSET		-2
#define EAX_OFFSET		-3
#define EBX_OFFSET		-4
#define ECX_OFFSET		-5
#define	EDX_OFFSET		-6
#define	ESI_OFFSET		-7
#define	EDI_OFFSET		-8
#define EBP_OFFSET		-9
#define DS_OFFSET		-10
#define ES_OFFSET		-11
#define FS_OFFSET		-12	
#define GS_OFFSET		-13

typedef struct IDT_DESC
{
	uint16_t	offset_low;
	uint16_t	segment;
	uint16_t	control;	// 0x8e00
	uint16_t	offset_high;
} __attribute__((packed)) IDT_DESC;

typedef struct LIDT_DESC
{
	uint16_t	length; // The idt size - 1
	uint32_t	offset; // The start address of idt
} __attribute__((packed)) LIDT_DESC;

extern struct IDT_DESC idt_table[];

extern void set_idt_entry(uint32_t n, uint32_t function);
extern void get_idt_entry(uint32_t n, struct IDT_DESC *ptr);

extern void initialize_idt();

extern void default_isr();
extern void do_default_isr(uint32_t error_code, const char *ptr);

extern void divide_error();
extern void do_dividedivide_error(uint32_t error_code, const char *ptr);

extern void debug_exception();
extern void do_debug_exception(uint32_t error_code, const char *ptr);

extern void nmi();
extern void do_nmi(uint32_t error_code, const char *ptr);

extern void breakpoint();
extern void do_breakpoint(uint32_t error_code, const char *ptr);

extern void overflow();
extern void do_overflow(uint32_t error_code, const char *ptr);

extern void bound();
extern void do_bound(uint32_t error_code, const char *ptr);

extern void invalid_opcode();
extern void do_invalid_opcode(uint32_t error_code, const char *ptr);

extern void coprocessor_not_available();
extern void do_coprocessor_not_available(uint32_t error_code, const char *ptr);

extern void double_fault();
extern void do_double_fault(uint32_t error_code, const char *ptr);

extern void coprocessor_segment_overrun();
extern void do_coprocessor_not_available(uint32_t error_code, const char *ptr);

extern void invalid_tss();
extern void do_invalid_tss(uint32_t error_code, const char *ptr);

extern void segment_not_pressent();
extern void do_segment_not_pressent(uint32_t, const char *);

extern void stack_exception();
extern void do_stack_exception(uint32_t error_code, const char *ptr);

extern void protection_exception();
extern void do_protection_exception(uint32_t , const char *ptr);

extern void page_fault();
extern void do_page_fault(uint32_t error_code, const char *ptr);

extern void intel_reserved();
extern void do_inter_reserved(uint32_t error_code, const char *ptr);

extern void coprocessor_error();
extern void do_coprocessor_error(uint32_t error_code, const char *ptr);

extern void default_isr();
extern void do_default_isr(uint32_t error_code, const char *ptr);

#endif
