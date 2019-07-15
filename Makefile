boot:
	cd boot
	$(MAKE) build

build: clean boot
	fat_imgen -c -f floppy.img
	dd if=boot/stage1.bin of=floppy.img seek=0 conv=notrunc
	fat_imgen -m -f floppy.img -i boot/kernel.sys

clean:
	rm -f floppy.img