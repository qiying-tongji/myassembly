; ==================================================
; INPUT.ASM
; Input conversion module
; ParseNumber is in the same PUBLIC code segment as
; MAIN.ASM, so the call from MAIN.ASM is a cross-file
; NEAR call.
; MASM 5.0 / 8086
; ==================================================

PUBLIC ParseNumber

; IMPORTANT:
; This segment name and its attributes must match the
; MAINCODE segment declaration in MAIN.ASM.
MAINCODE SEGMENT PARA PUBLIC 'CODE'
ASSUME CS:MAINCODE

; --------------------------------------------------
; ParseNumber
;
; Input:
;   DS:SI = address of the ASCII digit string
;   CX    = number of characters
;
; Output:
;   AX = converted unsigned decimal number
;   CF = 0, conversion successful
;   CF = 1, invalid character or empty input
;
; Registers BX, CX, DX and SI are preserved.
; --------------------------------------------------
ParseNumber PROC NEAR

    PUSH BX
    PUSH DX
    PUSH SI
    PUSH CX

    XOR BX, BX

    CMP CX, 0
    JE PN_ERROR

PN_LOOP:

    MOV AL, [SI]

    ; Check that the character is >= '0'.
    CMP AL, '0'
    JB PN_ERROR

    ; Check that the character is <= '9'.
    CMP AL, '9'
    JA PN_ERROR

    ; Convert ASCII digit to numeric value.
    SUB AL, '0'
    XOR AH, AH

    ; BX = BX * 10 + digit.
    PUSH AX

    MOV AX, BX
    MOV DX, 10
    MUL DX

    MOV BX, AX

    POP AX

    ADD BX, AX

    INC SI

    LOOP PN_LOOP

    MOV AX, BX

    POP CX
    POP SI
    POP DX
    POP BX

    CLC
    RET

PN_ERROR:

    POP CX
    POP SI
    POP DX
    POP BX

    STC
    RET

ParseNumber ENDP

MAINCODE ENDS

END
