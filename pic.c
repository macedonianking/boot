#include "asm.h"
#include "pic.h"
#include "idt.h"

#define PIC_PORT(pic)	((pic) == PIC_MASTER ? PIC0_IMR : PIC1_IMR)

void initialize_pic()
{
	uint8_t mask;
	
	// disable all pic interrupt
	_io_out8(PIC0_IMR, 0xff);
	_io_out8(PIC1_IMR, 0xff);

	_io_out8(PIC0_ICW1, 0x11);
	_io_out8(PIC0_ICW2, PIC0_INT_START); // setting master start int number
	_io_out8(PIC0_ICW3, 1 << 2);
	_io_out8(PIC0_ICW4, 0x01);

	_io_out8(PIC1_ICW1, 0x11);
	_io_out8(PIC1_ICW2, PIC1_INT_START);
	_io_out8(PIC1_ICW3, 2); 
	_io_out8(PIC1_ICW4, 0x01);

	_io_out8(PIC0_IMR, 0xfb);
	_io_out8(PIC1_IMR, 0xff);

	set_idt_entry(INT_TIMER, (uint32_t)&timer);
	set_idt_entry(INT_KEYBOARD, (uint32_t)&_inthandler21);

	mask = get_pic_mask(PIC0_IMR);
	mask &= ~(MASTER_KEYBD_FLAG);
	set_pic_mask(PIC0_IMR, mask);
	
	_printf("pic0_imr:%02x, pic1.imr:%02x\n", 
			get_pic_mask(PIC0_IMR), 
			get_pic_mask(PIC1_IMR));
	_sti();
}

void set_pic_mask(uint16_t port, uint8_t mask)
{
	_io_out8(port, mask);
}

uint8_t get_pic_mask(uint16_t port)
{
	return _io_in8(port);
}

void do_timer(uint32_t error_code, const char *ptr)
{
	_printf("do_timer:%p\n", ptr);
	_io_out8(PIC0_OCW2, 0x60);
}

void do_inthandler21(uint32_t error_code, const char *ptr)
{
	uint8_t key;

	key = _io_in8(PORT_KEYDATA);
	_io_out8(PIC0_OCW2, 0x61);
	if (key & 0x80)
	{
		// up
		_printf("key up:%02X\n", key);
	}
	else
	{
		// down	
		_printf("key down:%02X\n", key);
	}
}

