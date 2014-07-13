#include "screen.h"

#include "bootint.h"
#include "test_screen.h"
extern void print_result(int n);

void test_screen()
{
	int cursorX, cursorY;

	write_cursor(SCREEN_W - 1, SCREEN_H - 1);
	read_cursor(&cursorX, &cursorY);
}
