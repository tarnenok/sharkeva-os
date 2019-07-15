    bits 16

new_line_16:
	mov ah, 0Eh

    mov al, 0Ah
    int 10h

    mov al, 0Dh
    int 10h

    ret

print_line_16:
    mov ah, 0Eh
    
    .repeat:
        lodsb
        test al, al
        je .done
        int 10h
        jmp .repeat

    .done:
        call new_line_16

        ret

; disable due to file size requirments of 512 bytes
clear_screen:
    ; mov ah, 06h
    ; xor al, al
    ; xor bx, bx
    ; mov bh, 07h
    ; xor cx, cx
    ; mov dh, 24
    ; mov dl, 79
    ; int 0x10

    ret
