#include <stdio.h>

#include "asm.h"
#include "screen.h"

static void move_up();
static void move_dn();

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

void move_cursor(int x, int y)
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
	move_cursor(0, 0);
}

void _putc(char c)
{
	int cx, cy;
	char *ptr;
	
	read_cursor(&cx, &cy);
	switch(c)
	{
		case '\n':
			++cy;
			cx = 0;
			while (cy >= 25)
			{
				move_up();
				--cy;
			}
			break;
		case '\r':
			cx = 0;
			break;
		case '\b':
			if (cx > 0)
				--cx;
			break;
		default:
			ptr = GET_TEXT_BASE_ADDR() + (SCREEN_W * cy + cx) * BYTES_PER_CHAR;
			*ptr = c;
			if (++cx >= SCREEN_W)
			{
				cx = 0;
				++cy;
				while (cy >= SCREEN_H)
				{
					--cy;
					move_up();
				}
			}
			break;
	}

	move_cursor(cx, cy);
}

void _puts(const char *s)
{
	while (*s != '\0')
		_putc(*s++);
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

	_puts("0x");
	for (int i = 7; i >= 0; --i)
	{
		v = (char)(n >> (i * 4));		
		v &= 0x0f;
		if (v < 0x0a)
			v = '0' + v;
		else
			v = v - 0x0a + 'A';
		_putc(v);
	}
}

void _delete_line()
{
	char *ptr;
	int cx, cy;
	
	read_cursor(&cx, &cy);
	ptr = GET_TEXT_BASE_ADDR() + cy * SCREEN_W * BYTES_PER_CHAR;
	for (int i = 0; i < SCREEN_W; ++i)
	{
		*ptr = ' ';
		ptr += 2;
	}
	move_cursor(0, cy);
}

void print_result(int v)
{
	output_char(v ? 'Y' : 'N');
}


void move_up()
{
	char *dst;
	char *src;
	int  size;

	dst = GET_TEXT_BASE_ADDR();
	src = dst + SCREEN_W * BYTES_PER_CHAR;
	size = SCREEN_W * BYTES_PER_CHAR * (SCREEN_H - 1);
	_memcpy(dst, src, size);

	dst += SCREEN_W * (SCREEN_H - 1) * BYTES_PER_CHAR;
	for (int i = 0; i < SCREEN_W; ++i)
	{
		*dst = ' ';
		dst += 2;
	}
}

void move_dn()
{
	char *base;
	char *dst;
	int n;

	n = SCREEN_W * BYTES_PER_CHAR;
	base = GET_TEXT_BASE_ADDR();
	dst = base + (SCREEN_H - 1) * n;
	while (dst > base)
	{
		_memcpy(dst, dst - n, n);
		dst -= n;
	}
}

void screen_test()
{
	char buf[1024];

	_puts("This is from the kernel!!!");
}
