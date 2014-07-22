/**************************************************************************/
// asm help methods. Use c call asm methods
/**************************************************************************/

#ifndef TESTMAIN_HELP_H_
#define TESTMAIN_HELP_H_

#include "bootint.h"

#define EFLAGS_AC_FLAG		(1 << 18)
#define CRO_CACHE_DISABLEi	0x60000000

extern uint8_t	_io_in8(uint16_t port);
extern void		_io_out8(uint16_t port, uint8_t n);

extern uint16_t	_io_in16(uint16_t port);
extern void		_io_out16(uint16_t port, uint16_t n);

extern void		reset_cursor();
extern void		output_char(char c);

extern void		_io_hlt();
extern void		_memcpy(void *dst, void *src, int size);

extern void		_sti();
extern void		_cli();

extern uint32_t	_load_eflags();
extern void		_store_eflags();

extern uint32_t _load_cr0();
extern void		_store_cr0();

extern void		_test_asm();

#endif //TESTMAIN_HELP_H_
