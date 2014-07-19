ENTRY(HeadMain)
SECTIONS
{
	.text 0 : AT(1M)
	{
		head.o(.text)
		*(.text)
	}
	_rodata_start = LOADADDR(.text) + SIZEOF(.text);
	.rodata _rodata_start : AT(_rodata_start)
	{
		*(.rodata)
	}
	.data :
	{
		*(.data)
	}
	. = 0x300000;
	.bss : {
		*(.bss)
	}
}
