
.model small
.stack 100h

.data
    prompt db 'Please input a Hex number: $'
    result db 0Dh,0Ah,'The Dec number:',0Dh,0Ah,'$'

.code
START:
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    lea dx, prompt
    int 21h

    xor bx, bx
    mov cx, 2

READ_HEX:
    mov ah, 01h
    int 21h

    cmp al, 0Dh
    je CONVERT_DONE

    cmp al, '0'
    jb INVALID
    cmp al, '9'
    jbe NUMERIC

    and al, 0DFh
    cmp al, 'A'
    jb INVALID
    cmp al, 'F'
    ja INVALID
    sub al, 'A'-10
    jmp ADD_DIGIT

NUMERIC:
    sub al, '0'

ADD_DIGIT:
    shl bx, 1
    shl bx, 1
    shl bx, 1
    shl bx, 1
    xor ah, ah
    add bx, ax
    loop READ_HEX

CONVERT_DONE:
    mov ah, 09h
    lea dx, result
    int 21h

    mov ax, bx
    mov bx, 10
    xor cx, cx

    cmp ax, 0
    jne DIV_LOOP

    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp EXIT

DIV_LOOP:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne DIV_LOOP

PRINT_LOOP:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop PRINT_LOOP

    jmp EXIT

INVALID:
    mov dx, offset result
    mov ah, 09h
    int 21h

EXIT:
    mov ax, 4C00h
    int 21h

END START
