HEAD_SOURCE := head.c \
	screen.c \
	test_screen.c \
	asm.s 
	

HEAD_OBJECT:= $(patsubst %.s,%.o,$(patsubst %.c,%.o,$(HEAD_SOURCE)))
DISK_SOURCE := boot head

.PHONY: all
all: disk.img
	qemu-system-i386 -hda $< -boot d

disk.img: makefile $(DISK_SOURCE)
	dd if=/dev/zero of=$@ bs=1M count=8
	dd if=boot of=$@ bs=512 count=1 conv=notrunc
	dd if=head of=$@ obs=512 seek=1 conv=notrunc

boot: boot.s
	gcc -c boot.s -o boot.o 
	ld --oformat binary --entry main --Ttext=0x0000 -o $@ boot.o 

head: $(HEAD_OBJECT) kernel.ld
	ld -m elf_i386 -T kernel.ld --oformat binary -o $@ $^
	ld -m elf_i386 -T kernel.ld --oformat elf32-i386 -o head.out $^


%.o: %.c
	gcc -m32 -std=gnu99 -c -o $@ $<

%.o: %.s
	gcc -m32 -c -o $@ $<

.PHONY: clean
clean:
	rm -rf *.o $(DISK_SOURCE) disk.img
