#include "asm.h"

void _sti()
{
	__asm__("sti");
}

void _cli()
{
	__asm__("cli");
}

uint32_t _load_eflags()
{
	uint32_t n;

	__asm__("pushf\n\t"
			"popl %0":"=a"(n):);
	return n;
}

void _store_eflags(uint32_t eflags)
{
	__asm__("push %0\n\t"
			"popf"::"a"(eflags));
}

uint32_t _load_cr0()
{
	uint32_t n;

	__asm__("mov %%cr0, %0":"=a"(n):);
	return n;
}

void _store_cr0(uint32_t n)
{
	__asm__("mov %0, %%cr0"::"a"(n));
}

uint32_t _memset_test(uint32_t start, uint32_t limit)
{
	uint32_t *base;
	uint32_t *last;
	uint32_t *end;
	uint32_t *r;
	uint32_t n;

	start &= 0xfffff000;
	limit &= 0xfffff000;
	
	base = (uint32_t*) start;
	end  = (uint32_t*) limit;

	r = base;
	while (base != end)
	{
		n = base[0x99];
		base[0x99] = 0xaa55aa55;
		base[0x99] ^= 0xffffffff;
		if (0x55aa55aa != base[0x99])
		{
			base[0x99] = n;
			break;
		}

		base[0x99] = n;
		r = base;
		base += 0x100;
	}

	return (uint32_t)r + 0x3ff;
}

void _test_asm()
{
	char  is_i486;
	uint32_t old_eflags, new_eflags;
	uint32_t old_cr0;
	uint32_t mem_size;
	
	old_eflags = _load_eflags();
	is_i486 = 0;
	if (old_eflags & EFLAGS_AC_FLAG)
	{
		is_i486 = 1;
	}
	else
	{
		_store_eflags(old_eflags | EFLAGS_AC_FLAG);
		new_eflags = _load_eflags();
		if (new_eflags & EFLAGS_AC_FLAG)
		{
			is_i486 = 1;
		}
	}

	if (is_i486)
	{
		old_cr0 = _load_cr0();
		_store_cr0(old_cr0 | CRO_CACHE_DISABLEi);
	}

	mem_size = _memset_test(0x00300000, 0xfffff000);
	_printf("The system memory size:%dM\n", mem_size / 1024 / 1024);	
}
