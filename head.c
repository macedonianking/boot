#include "screen.h"

void HeadMain()
{
	clear_screen();
	write_cursor(0, 0);
	output_char('A');
L1:
	io_hlt();
	goto	L1;
}

