    bits 32
    %define		VIDMEM	0xB8000
    %define		COLS	80
    %define		LINES	25
    %define		CHAR_ATTRIB 14

    cursor_x db 0
    cursor_y db 0

move_cursor_32:
    pusha

    ;-------------------------------;
	;   Get current position        ;
	;-------------------------------;

	xor	eax, eax
	mov	ecx, COLS
	mov	al, bh			; get y pos
	mul	ecx			; multiply y*COLS
	add	al, bl			; Now add x
	mov	ebx, eax
 
	mov	al, 0x0f		; Cursor location low byte index
	mov	dx, 0x03D4		; Write it to the CRT index register
	out	dx, al
 
	mov	al, bl			; The current location is in EBX. BL contains the low byte, BH high byte
	mov	dx, 0x03D5		; Write it to the data register
	out	dx, al			; low byte
 
	xor	eax, eax
 
	mov	al, 0x0e		; Cursor location high byte index
	mov	dx, 0x03D4		; Write to the CRT index register
	out	dx, al
 
	mov	al, bh			; the current location is in EBX. BL contains low byte, BH high byte
	mov	dx, 0x03D5		; Write it to the data register
	out	dx, al			; high byte

    popa
    ret

print_line_32:
    pusha
	mov edi, ebx

    .loop:
        mov bl, byte [edi]
        cmp bl, 0 ; check for termination 0
        je .done
        call print_char_32
    .next:
        inc edi
        jmp .loop
    .done:
        mov bh, byte [cursor_y]
        mov bl, byte [cursor_x]
        call move_cursor_32

        popa
        ret

;**************************************************;
;	BX => address of the string
;**************************************************;
clear_screen_32:
    pusha
	
    cld
	mov	edi, VIDMEM
	mov	cx, COLS*LINES
	mov	ah, CHAR_ATTRIB
	mov	al, ' '	
	rep	stosw
 
	mov	byte [cursor_x], 0
	mov	byte [cursor_y], 0

	popa
	ret

;**************************************************;
;	BL => Character to print
;**************************************************;
print_char_32:
    pusha				; save registers

	mov	edi, VIDMEM		; get pointer to video memory
    
    ; Get current position
    xor eax, eax
    mov ecx, COLS*2
    mov al, byte [cursor_y]
    mul ecx
    push eax

    mov al, byte [cursor_x]
    mov cl, 2
    mul cl
    pop ecx
    add eax, ecx

    ; calcualte VGA address in memory
    xor ecx, ecx
    add edi, eax

    ; handle new line
    cmp bl, 0x0A
    je .row

    ; print symbol
    mov dl, bl
    mov dh, CHAR_ATTRIB
    mov word [edi], dx

    inc byte [cursor_x]
    cmp byte [cursor_x], COLS
    je .row
    jmp .done

    .row:
        inc byte [cursor_y]
        mov byte [cursor_x], 0
    .done:
        popa
        ret