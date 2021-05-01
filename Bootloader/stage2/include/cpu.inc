%include "include/stdio.inc"

DetectCPUID:
    pushfd
    pop eax 

    ; Copy to ECX as well for comparing later on
    mov ecx, eax    

    ; Flip the ID bit
    xor eax, 1 << 21    

    ; Copy EAX to FLAGS via the stack
    push eax
    popfd  

    ; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
    pushfd
    pop eax

    ; Restore FLAGS from the old version stored in ECX (i.e. flipping the ID bit
    ; back if it was ever flipped).
    push ecx
    popfd   
    
    ; Compare EAX and ECX. If they are equal then that means the bit wasn't
    ; flipped, and CPUID isn't supported.
    xor eax, ecx
    jz .NoCPUID
    ret

    .NoCPUID:
        mov si, nocpuid_msg 
        call Puts16
        jmp $ 

DetectLongMode:
    mov eax, 0x80000000
    cpuid 
    cmp eax, 0x80000001
    jb .NoLongMode
    mov eax, 0x80000001
    cpuid 
    test edx, 1 << 29
    jz .NoLongMode
    ret

    .NoLongMode:
        mov si, noLongMode_msg 
        call Puts16
        jmp $ 