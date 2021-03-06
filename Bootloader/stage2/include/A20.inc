%include "include/stdio.inc"

Enable_A20:
    ;first check id a20 already enabled as some BIOSes do that at boot
    pushad
    call check_a20
    cmp ax, 1            ; Does AX=1?
    je .a20_enabled      ; Yes, a20 enabled
    
    ; Nope, try to enable
    call A20BiosMethod

    call check_a20
    or ax, 1            ; Does AX=1?
    je .a20_enabled      ; Yes, a20 enabled

    call Keyboard_Controller

    call check_a20
    or ax, 1            ; Does AX=1?
    je .a20_enabled      ; Yes, a20 enabled
    jmp .a20_Failed

    .a20_enabled:
        popad
        ret

    .a20_Failed:
        mov si, A20_failed
        call Puts16
        jmp $

; Returns: 0 in ax if the a20 line is disabled (memory wraps around)
;          1 in ax if the a20 line is enabled (memory does not wrap around)
check_a20:
    pushf
    push ds
    push es
    push di
    push si
 
    cli
 
    xor ax, ax ; ax = 0
    mov es, ax
 
    not ax ; ax = 0xFFFF
    mov ds, ax
 
    mov di, 0x0500
    mov si, 0x0510
 
    mov al, byte [es:di]
    push ax
 
    mov al, byte [ds:si]
    push ax
 
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
 
    cmp byte [es:di], 0xFF
 
    pop ax
    mov byte [ds:si], al
 
    pop ax
    mov byte [es:di], al
 
    mov ax, 0
    je .check_a20__exit
 
    mov ax, 1
 
    .check_a20__exit:
        pop si
        pop di
        pop es
        pop ds
        popf
    
        ret
        
A20BiosMethod:
	mov 	ax, 0x2401
	int 	0x15
	ret

Keyboard_Controller:
    cli

    call    a20wait
    mov     al,0xAD
    out     0x64,al

    call    a20wait
    mov     al,0xD0
    out     0x64,al

    call    a20wait2
    in      al,0x60
    push    eax

    call    a20wait
    mov     al,0xD1
    out     0x64,al

    call    a20wait
    pop     eax
    or      al,2
    out     0x60,al

    call    a20wait
    mov     al,0xAE
    out     0x64,al

    call    a20wait
    sti
    ret
 
a20wait:
    in      al,0x64
    test    al,2
    jnz     a20wait
    ret
 
 
a20wait2:
    in      al,0x64
    test    al,1
    jz      a20wait2
    ret