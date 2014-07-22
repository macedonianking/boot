#include "asm.h"
#include "screen.h"
#include "test_screen.h"
#include "idt.h"
#include "pic.h"

void HeadMain()
{
	clear_screen();
	move_cursor(0, 0);	
	screen_test();
	initialize_idt();
	_test_asm();
L1:
	_io_hlt();
	goto	L1;
}

