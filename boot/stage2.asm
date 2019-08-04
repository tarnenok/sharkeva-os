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
    %include 'fat12.asm'

    %define ROOT_DIR_OFFSET 0x0200
    %define ROOT_DIR_BASE 0x2e0 
    %define FAT_INFO_OFFSET 0x0200

    %define KERNEL_SEGMENT_BASE 0x3000
    %define KERNEL_SEGMENT_BASE_PM 0x100000
    %define KERNEL_SEGMENT_OFFSET 0x0000 

data:
    message	db	"Welcome from Boot loader of stage 2", 0
    fail_message db "Failure during preparation for Protected mode", 0
    kernel_name db "KERNEL  SYS", 0

main:
    cli
	xor ax, ax
    mov ds, ax
    mov es, ax
    mov gs, ax
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
    popa
    sti

    call enable_A20

    mov ax, ROOT_DIR_BASE
    mov es, ax
    mov bx, ROOT_DIR_OFFSET
    call load_root

    mov si, kernel_name
    mov di, ROOT_DIR_OFFSET ; locate first root entry
    call load_file_info
    cmp ax, 0
    jne failure

    mov bx, FAT_INFO_OFFSET
    call load_fat

    mov ax, es
    mov gs, ax
    mov ax, KERNEL_SEGMENT_BASE
    mov es, ax
    mov bx, KERNEL_SEGMENT_OFFSET
    call load_file
    mov dword [image_size], ecx

    cli
    mov	eax, cr0		; set bit 0 in cr0--enter pmode
	or	eax, 1
	mov	cr0, eax

    jmp 0x8:main_stage_3

failure:
    mov si, fail_message
	call print_line_16

    cli
    hlt

    bits 32

main_stage_3:
	mov		eax, 0x10		; set data segments to data selector (0x10)
	mov		ds, ax
	mov		ss, ax
	mov		es, ax
	mov		esp, 90000h		; stack begins from 90000h

    mov	eax, dword [image_size]
    movzx ebx, word [bpbBytesPerSector]
    mul	ebx
    mov	ebx, 4
    div	ebx
    push eax
    cld
    mov eax, KERNEL_SEGMENT_BASE
    mov ebx, 0x10
    mul ebx
    mov esi, eax
    mov eax, KERNEL_SEGMENT_BASE_PM
    mov edi, eax
    pop eax
    mov	ecx, eax
    rep	movsd                   ; copy image to its protected mode address

	jmp	0x8:KERNEL_SEGMENT_BASE_PM

    cli
	hlt ; hault the syst