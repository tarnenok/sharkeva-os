.PHONY: stage1 stage2 build default clean 

default: build

stage1: stage1.asm
	nasm -w+all -f bin -o stage1.bin stage1.asm

stage2: stage2.asm
	nasm -w+all -f bin -o kernel.sys stage2.asm

build: clean stage1 stage2

clean:
	rm -f kernel.sys
	rm -f stage1.bin