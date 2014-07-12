#include "asm.h"
#include "screen.h"


void read_cursor(int *x, int *y)
{
	io8_out(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_HIGH);		
	*x = (int) io8_in(VGA_PORT_DATA);

	io8_out(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_LOW);
	*y = (int) io8_in(VGA_PORT_DATA);
}

void write_cursor(int x, int y)
{
	unsigned short n;

	n = (unsigned short)(x + y * SCREEN_W);

	io8_out(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_HIGH);
	io8_out(VGA_PORT_DATA, (char)(n >> 8));
	io8_out(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_LOW);
	io8_out(VGA_PORT_DATA, (char)(n));
}

void reset_cursor_impl()
{
	io8_out(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_HIGH);
	io8_out(VGA_PORT_DATA, 0x00);
	io8_out(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_LOW);
	io8_out(VGA_PORT_DATA, 0x00);
}

void clear_screen()
{
	char *ptr;

	ptr = GET_TEXT_BASE_ADDR();
	for (int i = 0; i < SCREEN_W * SCREEN_H; ++i)
	{
		*ptr = ' ';
		ptr += 2;
	}
	write_cursor(0, 0);
}
