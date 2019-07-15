    org 0x0500		
    bits 16	

    jmp main				; jump to main
    %include 'gdt.asm'
    %include 'stdlib16full.asm' 

data:
    message	db	"Welcome from Boot loader of stage 2", 0

main:
    cli
	xor ax, ax
    mov ds, ax
    mov es, ax
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xffff
    sti

    call clear_screen
    call move_cursor_to_beginig

	mov si, message
	call print_line_16

    ; load global descripter table pointer
	cli
    pusha
    lgdt [gdt_pointer]
    sti
    popa

    cli
    mov	eax, cr0		; set bit 0 in cr0--enter pmode
	or	eax, 1
	mov	cr0, eax

    jmp 0x8:main_stage_3

    bits 32
main_stage_3:
	mov		eax, 0x10		; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h		; stack begins from 90000h

    cli
	hlt ; hault the syst