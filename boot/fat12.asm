    bits 16

    bpbOEM:          db "SHARKEVA"
    bpbBytesPerSector:      DW 512
    bpbSectorsPerCluster:   DB 1
    bpbReservedSectors:     DW 1
    bpbNumberOfFATs:    DB 2
    bpbRootEntries:     DW 224
    bpbTotalSectors:    DW 2880
    bpbMedia:       DB 0xf8
    bpbSectorsPerFAT:   DW 9
    bpbSectorsPerTrack:     DW 18
    bpbHeadsPerCylinder:    DW 2
    bpbHiddenSectors:   DD 0
    bpbTotalSectorsBig:     DD 0
    bsDriveNumber:          DB 0
    bsUnused:       DB 0
    bsExtBootSignature:     DB 0x29
    bsSerialNumber:         DD 0xa0a1a2a3
    bsVolumeLabel:          DB "SHARKEVA OS"
    bsFileSystem:           DB "FAT12   "

;************************************************;
; Reads a series of sectors
; CX=>Number of sectors to read
; AX=>Starting sector
; ES:BX=>Buffer to read to
;************************************************;
read_sectors:
     .main:
          mov     di, 0x0005                          ; five retries for error
     .sector_loop:
          push    ax
          push    bx
          push    cx
          call    lba_to_chs                              ; convert starting sector to CHS
          mov     ah, 0x02                            ; BIOS read sector
          mov     al, 0x01                            ; read one sector
          mov     ch, BYTE [absoluteTrack]            ; track
          mov     cl, BYTE [absoluteSector]           ; sector
          mov     dh, BYTE [absoluteHead]             ; head
          mov     dl, BYTE [bsDriveNumber]            ; drive
          int     0x13                                ; invoke BIOS
          jnc     .success                            ; test for read error
          xor     ax, ax                              ; BIOS reset disk
          int     0x13                                ; invoke BIOS
          dec     di                                  ; decrement error counter
          pop     cx
          pop     bx
          pop     ax
          jnz     .sector_loop                         ; attempt to read again
          int     0x18
     .success:
          pop     cx
          pop     bx
          pop     ax
          add     bx, WORD [bpbBytesPerSector]        ; queue next buffer
          inc     ax                                  ; queue next sector
          loop    .main                               ; read next sector
          ret

;************************************************;
; Convert CHS to LBA
; LBA = (cluster - 2) * sectors per cluster
;************************************************;
chs_to_lba:
          sub     ax, 0x0002                          ; zero base cluster number
          xor     cx, cx
          mov     cl, BYTE [bpbSectorsPerCluster]     ; convert byte to word
          mul     cx
          add     ax, WORD [datasector]               ; base data sector
          ret
     
;************************************************;
; Convert LBA to CHS
; AX=>LBA Address to convert
;
; absolute sector = (logical sector / sectors per track) + 1
; absolute head   = (logical sector / sectors per track) MOD number of heads
; absolute track  = logical sector / (sectors per track * number of heads)
;
;************************************************;
lba_to_chs:
          xor     dx, dx                              ; prepare dx:ax for operation
          div     WORD [bpbSectorsPerTrack]           ; calculate
          inc     dl                                  ; adjust for sector 0
          mov     BYTE [absoluteSector], dl
          xor     dx, dx                              ; prepare dx:ax for operation
          div     WORD [bpbHeadsPerCylinder]          ; calculate
          mov     BYTE [absoluteHead], dl
          mov     BYTE [absoluteTrack], al
          ret

;************************************************;
; Loads FAT root to ES:BX
;************************************************;
load_root:
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
    
    call read_sectors

    ret

absoluteSector db 0x00
absoluteHead   db 0x00
absoluteTrack  db 0x00

datasector  dw 0x0000
cluster     dw 0x0000