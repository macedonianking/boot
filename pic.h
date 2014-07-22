#ifndef _BOOT_PIC_H
#define _BOOT_PIC_H

#define PIC0_INT_START	0x20
#define PIC1_INT_START	0x28

#define	INT_TIMER		0x20
#define INT_KEYBOARD	0x21

#define INT_RTC			0x28

#define PIC0_ICW1		0x0020
#define PIC0_OCW2		0x0020
#define PIC0_IMR		0x0021
#define PIC0_ICW2		0x0021
#define PIC0_ICW3		0x0021
#define PIC0_ICW4		0x0021
#define PIC1_ICW1		0x00a0
#define PIC1_OCW2		0x00a0
#define PIC1_IMR		0x00a1
#define PIC1_ICW2		0x00a1
#define PIC1_ICW3		0x00a1
#define PIC1_ICW4		0x00a1

#define PORT_KEYDATA	0x0060

#define MASTER_TIMER_FLAG	(1 << 0)
#define MASTER_KEYBD_FLAG	(1 << 1)
#define MASTER_SLAVE_FLAG	(1 << 2)

#define SLAVER_RTC_FLAG		(1 << 0)

extern void initialize_pic();
extern void set_pic_mask(uint16_t port, uint8_t mask);
extern uint8_t get_pic_mask(uint16_t port);

extern void		timer();
extern void		do_timer(uint32_t error_code, const char *ptr);

extern void		_inthandler21();
extern void		do_inthandler21(uint32_t error_code, const char *ptr);
#endif // _BOOT_PIC_H
