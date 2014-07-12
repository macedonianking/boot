#ifndef TESTMAIN_SCREEN_H_
#define TESTMAIN_SCREEN_H_

#define VGA_PORT_MODE	0x3d4
#define VGA_PORT_DATA	0x3d5

#define VGA_PORT_MODE_CURSOR_HIGH	0x0e
#define VGA_PORT_MODE_CURSOR_LOW	0x0f

#define SCREEN_W		80
#define SCREEN_H		25

#define TEXT_BASE_ADDR	0xb8000
#define GET_TEXT_BASE_ADDR()	((char*) 0xb8000)

// read current position
extern void read_cursor(int *x, int *y);

// write current cursor position
extern void write_cursor(int x, int y);

extern void reset_cursor_impl();

extern void clear_screen();
#endif //TESTMAIN_SCREEN_H_
