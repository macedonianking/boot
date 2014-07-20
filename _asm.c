#include "asm.h"

void _sti()
{
	__asm__("sti");
}

void _cli()
{
	__asm__("cli");
}
