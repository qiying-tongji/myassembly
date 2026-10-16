
.model small
.stack 100h

.data
    SUM DW 0

.code
START:
    mov ax, @data
    mov ds, ax

    mov si, 0
    mov bx, 1
    mov cx, 100

SUM_LOOP:
    add si, bx
    inc bx
    loop SUM_LOOP

    mov SUM, si

    mov ax, SUM
    mov bx, 10
    xor cx, cx

CONVERT_LOOP:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne CONVERT_LOOP

PRINT_LOOP:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop PRINT_LOOP

    mov ax, 4C00h
    int 21h

END START