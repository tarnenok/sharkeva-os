stage1: stage1.asm
	nasm -f bin -o stage1.bin stage1.asm

stage2: stage2.asm
	nasm -f bin -o kernel.sys stage2.asm

build: stage1 stage2

clean:
	rm -f kernel.sys
	rm -f stage1.bin