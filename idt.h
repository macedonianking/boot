#ifndef _BOOT_IDT_H
#define _BOOT_IDT_H

#include "bootint.h"

#define IDT_TABLE_SIZE		256
#define DEFAULT_IDT_CONTROL	0x8e00

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

extern void default_isr();
extern void initialize_idt();
#endif
