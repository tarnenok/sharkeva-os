; Stage 1 bootloader with restriction in size 512B 
;
; 1. Set data segmets to 0x7c00:0x0000
; 2. Load file stage2 from disk by FAT12 file system to 0x0050:0x0000
;   - Load root directory
;   - Load information from root directory by filename
;   - Load FAT info from file system
;   - Load file infot by reading cluster info
; 3. Jump to 0x0050:0x0000

    bits 16
    org 0x7c00

    jmp start
    %include 'fat12.asm'
    %include 'stdlib16.asm'

    %define ROOT_DIR_OFFSET 0x0200
    %define FAT_INFO_OFFSET 0x0200

    %define STAGE2_SEGMENT_BASE 0x0050
    %define STAGE2_SEGMENT_OFFSET 0x0000 

start:
    mov si, header
    call print_line_16

    cli
    mov ax, 0x7c00
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ax, 0x0000
    mov ss, ax
    mov sp, 0xFFFF
    sti

    mov bx, ROOT_DIR_OFFSET ; copy root dir above bootcode
    call load_root ; read root directory into memory

    ; browse root directory for binary image
    mov si, stage2_name
    mov di, ROOT_DIR_OFFSET ; locate first root entry
    call load_file_info
    cmp ax, 0
    jne failure

    mov bx, FAT_INFO_OFFSET
    call load_fat

    ; read image file into memory
    mov ax, es
    mov gs, ax
    mov ax, STAGE2_SEGMENT_BASE                          ; destination for image
    mov es, ax
    mov bx, STAGE2_SEGMENT_OFFSET                          ; destination for image
    call load_file
    jmp STAGE2_SEGMENT_BASE:STAGE2_SEGMENT_OFFSET
        
failure:
    mov si, fail
    call print_line_16
     
    mov     ah, 0x00
    int     0x16                                ; await keypress
    int     0x19                                ; warm boot computer
    
data:
    fail db 'Failed', 0
    header db 'Welcome from Boot loader of stage 1', 0
    stage2_name db 'STAGE2  BIN'

    times 510 - ($-$$) db 0
    dw 0xAA55