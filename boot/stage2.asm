    org 0x0					; offset to 0, we will set segments later
    bits 16					; we are still in real mode

    jmp main				; jump to main
    %include 'stdlib16full.asm' 

main:
	cli
	push cs		; Insure DS=CS
	pop ds

    call clear_screen

	mov si, message
	call print_line_16

	cli					; clear interrupts to prevent triple faults
	hlt					; hault the syst

data:
    message	db	"Welcome from Boot loader of stage", 0