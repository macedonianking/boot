ENTRY(HeadMain)
SECTIONS
{
	. = 0x100000;
	.text : {
		*(.text)
	}
	.data : {
		*(.rodata)
		*(.data)
	}
	. = 0x300000;
	.bss : {
		*(.bss)
	}
}
