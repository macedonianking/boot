#include "screen.h"
#include "test_screen.h"

void HeadMain()
{
	int x;

	clear_screen();
	write_cursor(0, 0);	
	test_screen();
L1:
	_io_hlt();
	goto	L1;
}

