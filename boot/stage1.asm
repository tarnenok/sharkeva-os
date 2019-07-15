    bits 16
    org 0x7c00

    jmp start
    %include 'fat12.asm'
    %include 'stdlib16.asm' 

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

    ; mov si, process
    ; call print_line_16

load_root:
    ; compute size of root directory and store in "cx"
    xor cx, cx
    xor dx, dx
    mov ax, 0x0020   ; 32 byte directory entry
    mul word [bpbRootEntries]    ; total size of directory
    div word [bpbBytesPerSector] ; sectors used by directory
    xchg ax, cx

    ; compute location of root directory and store in "ax"
    mov al, byte [bpbNumberOfFATs]    ; number of FATs
    mul word [bpbSectorsPerFAT]   ; sectors used by FATs
    add ax, word [bpbReservedSectors] ; adjust for bootsector
    mov word [datasector], ax ; base of root directory
    add word [datasector], cx
    
    ; read root directory into memory (7C00:0200)
    mov bx, 0x0200    ; copy root dir above bootcode
    call read_sectors

    ; browse root directory for binary image
    mov cx, word [bpbRootEntries]     ; load loop counter
    mov di, 0x0200        ; locate first root entry
    .loop:
        push cx
        mov cx, 0x000B        ; eleven character name
        mov si, stage2_name     ; image name to find
        push di
        rep cmpsb         ; test for entry match
        pop di
        je load_fat
        pop cx
        add di, 0x0020        ; queue next directory entry
        loop .loop
        jmp failure

load_fat:
    ; save starting cluster of boot image

    mov     dx, word [es:(di + 0x001A)]
    mov     word [cluster], dx                  ; file's first cluster

    ; compute size of FAT and store in "cx"
    xor     ax, ax
    mov     al, byte [bpbNumberOfFATs]          ; number of FATs
    mul     word [bpbSectorsPerFAT]             ; sectors used by FATs
    mov     cx, ax

    ; compute location of FAT and store in "ax"
    mov     ax, word [bpbReservedSectors]       ; adjust for bootsector
    
    mov     bx, 0x0200                          ; copy FAT above bootcode
    call    read_sectors

    ; read image file into memory (0050:0000)
    mov     ax, 0x7c40
    mov     es, ax                              ; destination for image
    mov     bx, 0x0000                          ; destination for image
    ; mov     bx, 0x0200
    push    bx

load_image:
    mov     ax, word [cluster]                  ; cluster to read
    pop     bx                                  ; buffer to read into
    call    chs_to_lba                          ; convert cluster to LBA
    xor     cx, cx
    mov     cl, byte [bpbSectorsPerCluster]     ; sectors to read
    call    read_sectors
    push    bx
    
    ; compute next cluster
    mov     ax, word [cluster]                  ; identify current cluster
    mov     cx, ax                              ; copy current cluster
    mov     dx, ax                              ; copy current cluster
    shr     dx, 0x0001                          ; divide by two
    add     cx, dx                              ; sum for (3/2)
    mov     bx, 0x0200                          ; location of FAT in memory
    add     bx, cx                              ; index into FAT
    mov     dx, word [gs:bx]                    ; read two bytes from FAT
    test    ax, 0x0001
    jnz .odd_cluster
        .even_cluster:
            and     dx, 0000111111111111b               ; take low twelve bits
            jmp     .done
        .odd_cluster:
            shr     dx, 0x0004                          ; take high twelve bits
        .done:  
            mov     WORD [cluster], dx                  ; store new cluster
            cmp     dx, 0x0FF0                          ; test for end of file
            jb      load_image
done:
    ; push    WORD 0x0050
    ; push    WORD 0x0000
    ; retf
    jmp 0x7c40:0x0000
        
failure:
    mov si, fail
    call print_line_16
     
    mov     ah, 0x00
    int     0x16                                ; await keypress
    int     0x19                                ; warm boot computer
    
data:
    fail db 'Failed', 0
    header db 'Welcome from Boot loader of stage 1', 0
    stage2_name db 'KERNEL  SYS'

    times 510 - ($-$$) db 0
    dw 0xAA55