    bits 16

    %include 'stdlib16.asm'

clear_screen:
    mov ah, 06h
    xor al, al
    xor bx, bx
    mov bh, 07h
    xor cx, cx
    mov dh, 24
    mov dl, 79
    int 0x10

    ret