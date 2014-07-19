#ifndef TESTMAIN_SCREEN_H_
#define TESTMAIN_SCREEN_H_

#define VGA_PORT_MODE	0x3d4
#define VGA_PORT_DATA	0x3d5

#define VGA_PORT_MODE_CURSOR_HIGH	0x0e
#define VGA_PORT_MODE_CURSOR_LOW	0x0f

#define SCREEN_W		80
#define SCREEN_H		25
#define BYTES_PER_CHAR	2

#define TEXT_BASE_ADDR	0xb8000
#define GET_TEXT_BASE_ADDR()	((char*) 0xb8000)

#ifndef MAX_BUFFER_SIZE	
#define MAX_BUFFER_SIZE		1024
#endif

// read current position
extern void read_cursor(int *px, int *py);

// write current cursor position
extern void move_cursor(int x, int y);

extern void reset_cursor_impl();

extern void clear_screen();

extern void _putc(char c);
extern void _puts(const char *s);
extern void _putn(char n);
extern void _put_int(int n);
extern void _delete_line();
extern void _printf(const char *format, ...);

extern void screen_test();

#endif //TESTMAIN_SCREEN_H_
