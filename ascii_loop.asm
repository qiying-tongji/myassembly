.model small
.stack 100h
.code
START:
    mov bl, 'a'
    mov cx, 2
L1:
    push cx
    mov cx, 13
L2:
    mov dl, bl
    mov ah, 02h
    int 21h
    mov dl, ' '
    mov ah, 02h
    int 21h
    inc bl
    loop L2
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    pop cx
    loop L1
    mov ax, 4C00h
    int 21h
END START