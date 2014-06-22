QEMU=qemu-system-i386

.PHONY:all
all: disk.img
	qemu-system-i386 -hda disk.img -boot d

disk.img: boot
	qemu-img create -f qcow $@ 128M
	dd if=boot of=$@ bs=512 count=1 skip=6

boot: boot.o
	ld -s -entry=main -Ttext=0x7c00 -o $@ $^

boot.o: boot.s
	gcc -c boot.s -o $@
