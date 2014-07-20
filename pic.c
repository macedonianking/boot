#include "asm.h"
#include "pic.h"

void initialize_pic()
{
	// disable all pic interrupt
	_io_out8(PIC0_PORT0, 0xff);
	_io_out8(PIC0_PORT1, 0xff);

	_io_out8(PIC0_PORT0, 0x11);
	_io_out8(PIC0_PORT1, PIC0_INT_START); // setting master start int number
	_io_out8(PIC0_PORT1, 1 << 2);
	_io_out8(PIC0_PORT1, 0x01);

	_io_out8(PIC1_PORT0, 0x11);
	_io_out8(PIC1_PORT1, PIC1_INT_START);
	_io_out8(PIC1_PORT1, 2); 
	_io_out8(PIC1_PORT1, 0x01);

	_io_out8(PIC0_PORT0, 0xfb);
	_io_out8(PIC1_PORT0, 0xff);
}

void set_master_mask(uint8_t mask)
{
	mask &= (1 << 2);	
	_io_out8(PIC0_PORT0, mask);
}

void set_slaver_mask(uint8_t mask)
{
	_io_out8(PIC1_PORT0, mask);
}
