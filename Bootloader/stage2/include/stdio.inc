%ifndef __STDIO_INC_INCLUDED__
%define __STDIO_INC_INCLUDED__

[BITS 16]

Puts16:
    lodsb           ; load next byte from string from SI to AL
    or al, al       ; Does AL=0?
    jz Done         ; Yep, null terminator found-bail out
    mov ah, 0eh     ; Nope-Print the character
    int 10h
    jmp Puts16       ; Repeat until null terminator found
Done:
    ret             ; we are done, so return

%endif