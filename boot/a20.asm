    bits 16

wait_input_A20:
    in      al, 0x64		; read status register
    test    al, 2		; test bit 2 (Input buffer status)
    jnz     wait_input_A20	; jump if its not 0 (not empty) to continue waiting
    ret

wait_output_A20:
    in      al, 0x64		; read status register
    test    al, 1		; test bit 1 (Input buffer status)
    jz     wait_output_A20	; jump if its 0 (not empty) to continue waiting
    ret

enable_A20:
    ; send read output port command
    mov     al,0xD0
    out     0x64,al
    call    wait_output_A20
    
    ; read input buffer and store on stack. This is the data read from the output port
    in      al, 0x60
    push    eax
    call    wait_input_A20
    
    ; send write output port command
    mov     al, 0xD1
    out     0x64, al
    call    wait_input_A20
    
    ; pop the output port data from stack and set bit 1 (A20) to enable
    pop     eax
    or      al, 2
    out     0x60, al

    ret