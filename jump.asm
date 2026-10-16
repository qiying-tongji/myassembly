.model small
.stack 100h

.code
START:
    mov bl, 'a'
    mov di, 2

L1:
    mov si, 13

L2:
    cmp si, 0
    je NEXT_LINE

    mov dl, bl
    mov ah, 02h
    int 21h

    mov dl, ' '
    mov ah, 02h
    int 21h

    inc bl
    dec si
    jmp L2

NEXT_LINE:
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    mov ah, 02h
    int 21h

    dec di
    jnz L1

    mov ax, 4C00h
    int 21h

END START