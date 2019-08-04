.PHONY: stage1 stage2 build default clean 

default: build

stage1: stage1.asm
	nasm -w+all -f bin -o stage1.bin stage1.asm

stage2: stage2.asm
	nasm -w+all -f bin -o stage2.bin stage2.asm

build: clean stage1 stage2

clean:
	rm -f stage2.bin
	rm -f stage1.bin