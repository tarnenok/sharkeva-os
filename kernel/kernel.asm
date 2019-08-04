	org	0x100000			; Kernel starts at 1 MB
	bits	32				; 32 bit code

	jmp	main				; jump to entry point

    %include 'stdlib32.asm'

message_32_mode db  0x0A, 0x0A, "                       - Make Sharkeva great again"
                db  0x0A, 0x0A, "                     SHARKEVAOS 32 Bit Kernel Executing", 0x0A, 0

main:
	mov	ax, 0x10		; set data segments to data selector (0x10)
	mov	ds, ax
	mov	ss, ax
	mov	es, ax
	mov	esp, 90000h		; stack begins from 90000h

    call clear_screen_32

    mov ebx, message_32_mode
    call print_line_32

	cli
	hlt



