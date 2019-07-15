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
