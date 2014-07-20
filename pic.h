#ifndef _BOOT_PIC_H
#define _BOOT_PIC_H

// master pic ports 
#define PIC0_PORT0	0x20
#define PIC0_PORT1	0x21

// slave pic ports
#define PIC1_PORT0	0xa0
#define PIC1_PORT1	0xa1

#define PIC0_INT_START	0x20
#define PIC1_INT_START	0x28

#define	INT_TIMER		0x20
#define INT_KEYBOARD	0x21

#define INT_RTC			0x28

extern void initialize_pic();

// set the master interrupt mask flags
void set_master_mask(uint8_t mask);

// set the slaver interrupt mask flags
void set_slaver_mask(uint8_t mask);

#endif // _BOOT_PIC_H
