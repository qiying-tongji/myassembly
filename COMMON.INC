; ==================================================
; COMMON.INC
; Common macro definitions
; ==================================================

; Display a '$'-terminated string using DOS INT 21H.
PRINT_STR MACRO message
    MOV AH, 09H
    LEA DX, message
    INT 21H
ENDM
