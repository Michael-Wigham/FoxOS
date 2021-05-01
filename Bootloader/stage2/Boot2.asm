[BITS 16]

jmp main                    ; jump to main

%include "include/stdio.inc"
%include "include/A20.inc"
%include "include/cpu.inc"
%include "include/paging.inc"
%include "include/GDT.inc"

main:
    cli                     ; clear interrupts
    push cs                 ; Insure DS=CS
    pop ds

	; Clear registers (Not EDX, it contains stuff!)
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor esi, esi
    xor edi, edi

    ; setup segments
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ;setup stack
    mov ss, ax
    mov ax, 0x7C00
    mov sp, ax
    sti 

    ;save data from the d register
    mov byte [DriveNumber], dl
    ; now we can clear it
    xor edi, edi

    mov si, hello
    call Puts16

    ;call load_kernal
    ;mov si, kernal_loaded
    ;call Puts16

    call Enable_A20
    mov si, A20_enabled
    call Puts16

    call DetectCPUID
    mov si, CPUIDDetected
    call Puts16

    call DetectLongMode
    mov si, longmodeDetected
    call Puts16

    call setup_paging
    mov si, paging_setup
    call Puts16

    mov si, bitmode64
    call Puts16
    ;switch to long mode
    call enable64BitMode

    lgdt [GDT64.Pointer]         ; Load the 64-bit global descriptor table.
    jmp GDT64.Code:Main64       ; Set the code segment and enter 64-bit sub mode.

    cli                     ; clear interrupts to prevent triple faults
    hlt                     ; hault the system
    
enable64BitMode:
    mov ecx, 0xC0000080          ; Set the C-register to 0xC0000080, which is the EFER MSR.
    rdmsr                        ; Read from the model-specific register.
    or eax, (1 << 8) | (1 << 0)      ; Set the LM-bit which is the 9th bit (bit 8).
    wrmsr                        ; Write to the model-specific register.

    mov eax, cr0                 ; Set the A-register to control register 0.
    or eax, (1 << 31) | (1 << 0)     ; Set the PG-bit, which is the 31nd bit, and the PM-bit, which is the 0th bit.
    mov cr0, eax                 ; Set control register 0 to the A-register.

    ; Enable global pages
    mov eax, cr4
    or eax, (1 << 7)    ; CR4.PGE
    mov cr4, eax
    ret



[BITS 64]
[extern _startKernal]
%include "include/IDT.inc"
Main64:
    mov edi, 0xB8000
	mov rax, 0x1F201F201F201F20
	mov ecx, 500
	rep stosq
	call ActivateSSE
	call _startKernal

    cli                           ; Clear the interrupt flag.
    hlt                           ; Halt the processor.

ActivateSSE:
	mov rax, cr0
	and ax, 0b11111101
	or ax, 0b00000001
	mov cr0, rax

	mov rax, cr4
	or ax, 0b1100000000
	mov cr4, rax

	ret

[BITS 16]

hello db "Welcome Stage 2",13,10,0

kernal_loaded db "Kernal Loaded at 0x07E00"

A20_enabled db "A20 Enabled",13,10,0
A20_failed db "a20 failed",13,10,0

CPUIDDetected db "CPUID Detected",13,10,0
nocpuid_msg db "No CPUID Detected",13,10,0

longmodeDetected db "long Mode Detected",13,10,0
noLongMode_msg db "No Long Mode Detected. This is a 64-bit OS",13,10,0

paging_setup db "paging setup",13,10,0

bitmode64 db "Entering 64bit mode",13,10,0

DriveNumber db 0
;sector align
times 2048-($-$$) db 0
