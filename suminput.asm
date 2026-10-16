
.model small
.stack 100h

.data
    prompt  db 'Please input a number (1-100): $'
    result  db 0Dh,0Ah,'The sum is: $'
    errorMsg db 0Dh,0Ah,'Invalid input!$'
    newline db 0Dh,0Ah,'$'

.code
START:
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    lea dx, prompt
    int 21h

    xor di, di

READ_INPUT:
    mov ah, 01h
    int 21h

    cmp al, 0Dh
    je INPUT_DONE

    cmp al, '0'
    jb INVALID
    cmp al, '9'
    ja INVALID

    sub al, '0'
    xor ah, ah
    push ax

    mov ax, di
    mov bx, 10
    mul bx
    mov di, ax

    pop ax
    add di, ax
    cmp di, 100
    ja INVALID

    jmp READ_INPUT

INPUT_DONE:
    cmp di, 1
    jb INVALID

    xor si, si
    mov bx, 1

SUM_LOOP:
    add si, bx
    inc bx
    cmp bx, di
    jbe SUM_LOOP

    mov ah, 09h
    lea dx, result
    int 21h

    mov ax, si
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

    mov ah, 09h
    lea dx, newline
    int 21h

    mov ax, 4C00h
    int 21h

INVALID:
    mov ah, 09h
    lea dx, errorMsg
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h

    mov ax, 4C01h
    int 21h

END START