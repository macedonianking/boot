#include "screen.h"
#include "test_screen.h"

void HeadMain()
{
	clear_screen();
	move_cursor(0, 0);	
	screen_test();
	_put_int(&HeadMain);
L1:
	_io_hlt();
	goto	L1;
}

