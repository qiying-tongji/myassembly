
; ==================================================
; Jump Demonstration
; MASM 5.0 / 8086
;
; 1. SHORT JMP
; 2. NEAR JMP
; 3. Conditional SHORT JMP
; 4. FAR JMP
; 5. Conditional FAR JMP workaround
; ==================================================


; ==================================================
; DATA SEGMENT
; ==================================================

DATA SEGMENT

    titleMsg DB 'Jump Demonstration',0DH,0AH,'$'

    shortMsg DB 'SHORT JMP: OK',0DH,0AH,'$'

    nearMsg  DB 'NEAR JMP: OK',0DH,0AH,'$'

    condMsg  DB 'CONDITIONAL SHORT JMP: OK',0DH,0AH,'$'

    skipMsg  DB 'Condition false: FAR JMP skipped',0DH,0AH,'$'

    farMsg   DB 'FAR JMP: OK',0DH,0AH,'$'

    errorMsg DB 'ERROR: Unexpected execution',0DH,0AH,'$'

DATA ENDS


; ==================================================
; STACK SEGMENT
; ==================================================

STACKSEG SEGMENT PARA STACK 'STACK'

    DW 128 DUP(?)

STACKSEG ENDS


; ==================================================
; MAIN CODE SEGMENT
; ==================================================

MAINCODE SEGMENT PARA PUBLIC 'CODE'

ASSUME CS:MAINCODE, DS:DATA, SS:STACKSEG


START:

    ; Initialize data segment
    MOV AX, DATA
    MOV DS, AX


; ==================================================
; Display title
; ==================================================

    MOV AH, 09H
    LEA DX, titleMsg
    INT 21H


; ==================================================
; TEST 1: SHORT JMP
; ==================================================

    JMP SHORT SHORT_TARGET

    ; This code should be skipped
    MOV AH, 09H
    LEA DX, errorMsg
    INT 21H


SHORT_TARGET:

    MOV AH, 09H
    LEA DX, shortMsg
    INT 21H


; ==================================================
; TEST 2: NEAR JMP
; ==================================================

    JMP NEAR PTR NEAR_TARGET

    ; This code should be skipped
    MOV AH, 09H
    LEA DX, errorMsg
    INT 21H


NEAR_TARGET:

    MOV AH, 09H
    LEA DX, nearMsg
    INT 21H


; ==================================================
; TEST 3: CONDITIONAL SHORT JMP
; ==================================================

    MOV AX, 1

    CMP AX, 1

    JE SHORT COND_TARGET

    ; This code should be skipped
    MOV AH, 09H
    LEA DX, errorMsg
    INT 21H


COND_TARGET:

    MOV AH, 09H
    LEA DX, condMsg
    INT 21H


; ==================================================
; TEST 4:
; Conditional jump to a far destination
;
; 8086 conditional jumps only support SHORT.
; We use the opposite condition to skip FAR JMP.
; ==================================================

    MOV AX, 0

    CMP AX, 1

    JNE SHORT FAR_COND_SKIP

    ; If AX equals 1, jump to another segment
    JMP FAR PTR FAR_TARGET


FAR_COND_SKIP:

    ; AX is not equal to 1
    MOV AH, 09H
    LEA DX, skipMsg
    INT 21H


    ; Now make the condition true
    MOV AX, 1

    CMP AX, 1

    JNE SHORT FAR_COND_END

    JMP FAR PTR FAR_TARGET


FAR_COND_END:

    MOV AH, 09H
    LEA DX, errorMsg
    INT 21H


    ; Exit if unexpected path is reached
    MOV AX, 4C00H
    INT 21H


MAINCODE ENDS


; ==================================================
; CALENDAR CODE SEGMENT
; ==================================================

CALCODE SEGMENT PARA PUBLIC 'CODE'

ASSUME CS:CALCODE, DS:DATA


; ==================================================
; TEST 5: FAR JMP TARGET
; ==================================================

FAR_TARGET:

    MOV AH, 09H

    LEA DX, farMsg

    INT 21H


    ; Terminate program
    MOV AX, 4C00H
    INT 21H


CALCODE ENDS


END START