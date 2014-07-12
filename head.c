#include "screen.h"

void HeadMain()
{
	clear_screen();
	write_cursor(0, 0);
L1:
	goto	L1;
}

