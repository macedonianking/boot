#include "asm.h"
#include "screen.h"


void read_cursor(int *x, int *y)
{
	uint8_t c;
	uint16_t n;

	_io_out8(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_HIGH);		
	c = _io_in8(VGA_PORT_DATA);
	n = c << 8;

	_io_out8(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_LOW);
	c = _io_in8(VGA_PORT_DATA);
	n |= c;

	*x = (int)(n % SCREEN_W);
	*y = (int)(n / SCREEN_W);
}

void write_cursor(int x, int y)
{
	uint16_t n;

	n = (uint16_t)(x + y * SCREEN_W);

	_io_out8(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_HIGH);
	_io_out8(VGA_PORT_DATA, (uint8_t)(n >> 8));
	_io_out8(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_LOW);
	_io_out8(VGA_PORT_DATA, (uint8_t)(n));
}

void reset_cursor_impl()
{
	_io_out8(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_HIGH);
	_io_out8(VGA_PORT_DATA, 0x00);
	_io_out8(VGA_PORT_MODE, VGA_PORT_MODE_CURSOR_LOW);
	_io_out8(VGA_PORT_DATA, 0x00);
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

void _putc(char c)
{
}

void _puts(const char *s)
{

}


void _putn(char n)
{
	n &= (char)0x0f;
	if (n < 0x0a)
	{
		output_char('0' + n);
	}
	else
	{
		output_char('A' + n - 0x0a);
	}
}

void _put_int(int n)
{
	char *ptr;
	int i;
	char v;

	ptr = GET_TEXT_BASE_ADDR();
	for (int i = 7; i >= 0; --i)
	{
		v = (char)(n >> (i * 4));		
		v &= 0x0f;
		if (v < 0x0a)
			v = '0' + v;
		else
			v = v - 0x0a + 'A';
		*ptr = v;
		ptr += 2;
	}
}

void print_result(int v)
{
	output_char(v ? 'Y' : 'N');
}

