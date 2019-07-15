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

move_cursor_to_beginig:
    mov ah, 2
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 0x10

    ret