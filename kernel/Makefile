.PHONY: kernel

default: build

kernel: kernel.asm
	nasm -w+all -f bin -o kernel.sys kernel.asm

build: clean kernel

clean:
	rm -f kernel.sys