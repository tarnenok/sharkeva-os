; Stage 2 bootloader for loading kernel binaries
;
; 1. Configure code and stack segemts
; 2. Load the predefined global descriptor table with code, data and null segment
; 3. Enable Protected mode 
; 4. Switch to the Protected mode and 32bit instructions by jumpinh there
; 5. Enable A20 for 4GB memory addresing
; 6. Load Kernel fyle from FAT12 filesystem

    org 0x0500		
    bits 16	

    jmp main				; jump to main
    %include 'gdt.asm'
    %include 'stdlib16full.asm' 
    %include 'a20.asm'

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

    call enable_A20

    cli
    mov	eax, cr0		; set bit 0 in cr0--enter pmode
	or	eax, 1
	mov	cr0, eax

    jmp 0x8:main_stage_3

    bits 32

main_stage_3:
    jmp main_stage3_body
    
    %include 'stdlib32.asm'

main_stage3_body:
	mov		eax, 0x10		; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h		; stack begins from 90000h

    call clear_screen_32

    mov ebx, message_32_mode
    call print_line_32

    cli
	hlt ; hault the syst

data_32:
    message_32_mode db "You are in 32 mode!", 0