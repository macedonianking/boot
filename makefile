QEMU=qemu-system-i386

.PHONY:all
all: disk.img 
	qemu-system-i386 -hda disk.img -boot d

disk.img: boot setup makefile
	rm -f $@
	dd if=/dev/zero of=$@ bs=1M count=8
	dd if=boot of=$@ bs=512 count=1 skip=6 conv=notrunc
	dd if=setup of=$@ bs=512 count=4 skip=8 seek=1 conv=notrunc

boot: boot.o
	ld -s -entry=main -Ttext=0x7c00 -o $@ $^

boot.o: boot.s makefile
	gcc -c boot.s -o $@

setup.o: setup.s
	gcc -c setup.s -o $@

setup: setup.o
	ld -s --entry=main --Ttext=0x0000 -o $@ $^

.PHONY: clean
clean:
	rm -rf *.o setup boot disk.img
