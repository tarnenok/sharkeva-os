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
    jmp main_stage3_body
    
    %include 'stdlib32.asm'

wait_input:
    in      al, 0x64		; read status register
    test    al, 2		; test bit 2 (Input buffer status)
    jnz     wait_input	; jump if its not 0 (not empty) to continue waiting
    ret

wait_output:
    in      al, 0x64		; read status register
    test    al, 1		; test bit 1 (Input buffer status)
    jz     wait_output	; jump if its 0 (not empty) to continue waiting
    ret

main_stage3_body:
	mov		eax, 0x10		; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h		; stack begins from 90000h

enable_A20:
    ; send read output port command
    mov     al,0xD0
    out     0x64,al
    call    wait_output
    
    ; read input buffer and store on stack. This is the data read from the output port
    in      al, 0x60
    push    eax
    call    wait_input
    
    ; send write output port command
    mov     al, 0xD1
    out     0x64, al
    call    wait_input
    
    ; pop the output port data from stack and set bit 1 (A20) to enable
    pop     eax
    or      al, 2
    out     0x60, al

    call clear_screen_32

    mov ebx, message_32_mode
    call print_line_32

    cli
	hlt ; hault the syst

data_32:
    message_32_mode db "You are in 32 mode!", 0