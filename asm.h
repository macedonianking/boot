/**************************************************************************/
// asm help methods. Use c call asm methods
/**************************************************************************/

#ifndef TESTMAIN_HELP_H_
#define TESTMAIN_HELP_H_

extern char		io8_in(short port);
extern void		io8_out(short port, char n);

extern short	io16_in(short port);
extern void		io16_out(short port, short n);

extern void		reset_cursor();
extern void		output_char(char c);

extern void		io_hlt();

#endif //TESTMAIN_HELP_H_
