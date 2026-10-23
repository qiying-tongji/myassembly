
.MODEL SMALL
.STACK 100H

.DATA
msg DB 'The 9 multiplication table:', 13, 10, '$'
row DB 9
col DB 1

.CODE
main PROC
    mov ax, @data
    mov ds, ax

    lea dx, msg
    mov ah, 09H
    int 21H

    mov row, 9

OuterLoop:
    cmp row, 0
    je Done

    mov col, 1

InnerLoop:
    mov al, col
    cmp al, row
    ja NextRow

    ; Output row
    mov dl, row
    add dl, '0'
    call PrintChar

    ; Output *
    mov dl, '*'
    call PrintChar

    ; Output col
    mov dl, col
    add dl, '0'
    call PrintChar

    ; Output =
    mov dl, '='
    call PrintChar

    ; Calculate row * col
    mov al, row
    mul col
    call PrintNumber

    ; Output two spaces
    mov dl, ' '
    call PrintChar
    call PrintChar

    inc col
    jmp InnerLoop

NextRow:
    mov dl, 13
    call PrintChar
    mov dl, 10
    call PrintChar

    dec row
    jmp OuterLoop

Done:
    mov ax, 4C00H
    int 21H
main ENDP

; Output the character in DL
PrintChar PROC NEAR
    push ax
    push dx

    mov ah, 02H
    int 21H

    pop dx
    pop ax
    ret
PrintChar ENDP

; Output the unsigned integer in AX
PrintNumber PROC NEAR
    push ax
    push bx
    push dx

    cmp ax, 10
    jb SingleDigit

    mov bx, 10
    xor dx, dx
    div bx

    push dx

    mov dl, al
    add dl, '0'
    call PrintChar

    pop dx
    add dl, '0'
    call PrintChar
    jmp NumberDone

SingleDigit:
    mov dl, al
    add dl, '0'
    call PrintChar

NumberDone:
    pop dx
    pop bx
    pop ax
    ret
PrintNumber ENDP

END main