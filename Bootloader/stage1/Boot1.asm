; *******************************************************
; Fox Stage 1 Bootloader
; Version 0.1
; *******************************************************
; Memory Map:
;low memory < 1miB
; 0x00000000 - 0x000004FF		Reserved
; 0x00000500 - 0x00007AFF		Free
; 0x00007C00 - 0x00007DFF		Bootloader (512 Bytes)
; 0x00007E00 - 0x0007FFFF       Stage 2 then onto kernal (128KiB)
; 0x00080000 - 0x000FFFFF       Bios Data Area (384 KiB)

; High Memory > 1miB
; 0x00100000 - 0x00EFFFFF       Ram Free for use (if it exits)

[BITS 16] ; Tells the assembler that its a 16 bit code in real mode
[ORG 0x7C00] ; loaded by bios at 0x7C00

jmp skip_bpb
nop
; Some bioses can fuck you over and overwrite bytes of code in the section where a 
; FAT Header would be, overwriting some bootsector code.
times 87 db 0

skip_bpb:
    cli
    cld           ; clear the Direction Flag DF=0 because our LODSB requires it
    jmp 0x0000:main

main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ss, ax
    mov sp, 0x7c00
    sti
    mov [BOOT_DRIVE], dl

    mov ax, 0x0003 ; Select 80x25 16-color text video mode
    int 0x10       ; BIOS video Interupt
    mov si, Welcome; Move the string welcome into SI register
    call printstr  
    call load_stage2

    jmp $          ;hang here


load_stage2:
	mov 	bx, 0x0000
	mov 	es, bx
	mov 	bx, 0x8000
  
    call disk_load

    mov dl, [BOOT_DRIVE]
	jmp 	0x8000

	; Safety catch
	cli
	hlt

disk_load:
    .tries:
        mov di, 5
    .read_sectors:
        mov ah, 0x02
        mov al, [sectors]      ;number of sectors to read
        mov ch,0        
        mov cl,0x02     ;starting sector to read from
        mov dh,0x00     ; head number
        mov  dl, [BOOT_DRIVE]  
        int 0x13
        jc .disk_reset
        sub [sectors], al
        jz .ready
        mov cl, 0x01
        xor dh,1 
        jnz .tries
        inc ch
        jmp .tries
    .disk_reset:
        mov ah, 0x00
        int 0x13
        dec di
        jnz .read_sectors
        jmp .disk_error
    .ready:
        ret

    .disk_error:
        mov si, disk_error_msg 
        call printstr
        jmp $ 
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;        PrintFunction      ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printstr:
    mov cx, 1      ; RepetitionCount
    mov bh, 0      ; DisplayPage
    mov bl, 0x07   ; WhiteOnBlack
print:
    lodsb          ; Load one byte at address SI and move into AL then increase the SI pointer
    cmp al, 0      ; Compair AL to 0
    je  done       ; Jump if condition met
    cmp al, 32     ; If space
    jb skip        ; Jump if condition met
    mov ah, 0x09   ; BIOS Write Character With Attribute
    int 0x10       ; BIOS video Interupt
skip:
    mov ah, 0x0E   ; Teletype bios routine
    int 0x10       ; BIOS video Interupt
    jmp print      ; Jump to print
done:
    ret            ; Return to where the function 'GetKeyPressed' was called, in this case Reboot


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;            Data           ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Welcome db 'Welcome to Fox',13,10,0
disk_error_msg db "Disk read error",13,10,0

BOOT_DRIVE     db 0
sectors        db 70

times 510-($-$$) db 0           ; Fill the  file with zeroes until 510 bytes are full
dw 0xAA55                       ; Number that tells the BIOS this is bootable makes the file 512 bytes