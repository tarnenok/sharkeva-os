.PHONY: bootloader build clean kernel

default: build

bootloader:
	cd boot; $(MAKE)

kernel:
	cd kernel; $(MAKE)

build: clean bootloader kernel
	fat_imgen -c -f floppy.img
	dd if=boot/stage1.bin of=floppy.img seek=0 conv=notrunc
	fat_imgen -m -f floppy.img -i boot/stage2.bin
	fat_imgen -m -f floppy.img -i kernel/kernel.sys

clean:
	rm -f floppy.img