
; ==================================================
; Parameter Passing Demonstration
; MASM 5.0 / 8086
;
; Demonstrate three parameter passing methods:
; 1. Data segment
; 2. Registers
; 3. Stack
; ==================================================


; ==================================================
; DATA SEGMENT
; ==================================================

DATA SEGMENT

    titleMsg DB 'Parameter Passing Demonstration',0DH,0AH,'$'

    dataMsg  DB 'Data segment (12+30): $'
    regMsg   DB 0DH,0AH,'Registers (12+30): $'
    stackMsg DB 0DH,0AH,'Stack (12+30): $'

    newline  DB 0DH,0AH,'$'

    ; Two numbers used in the demonstration
    valueA   DW 12
    valueB   DW 30

    ; Store calculation result
    result   DW 0

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
; METHOD 1: DATA SEGMENT
; ==================================================

    MOV AH, 09H
    LEA DX, titleMsg
    INT 21H

    MOV AH, 09H
    LEA DX, dataMsg
    INT 21H

    ; Call procedure in another code segment
    CALL FAR PTR AddByData

    ; Display result
    MOV AX, result
    CALL PrintNumber


; ==================================================
; METHOD 2: REGISTER PASSING
; ==================================================

    MOV AH, 09H
    LEA DX, regMsg
    INT 21H

    ; AX = first parameter
    MOV AX, valueA

    ; BX = second parameter
    MOV BX, valueB

    ; Call procedure
    CALL FAR PTR AddByRegister

    ; Result is returned in AX
    CALL PrintNumber


; ==================================================
; METHOD 3: STACK PASSING
; ==================================================

    MOV AH, 09H
    LEA DX, stackMsg
    INT 21H

    ; Push second parameter first
    MOV AX, valueB
    PUSH AX

    ; Push first parameter
    MOV AX, valueA
    PUSH AX

    ; Call procedure
    CALL FAR PTR AddByStack

    ; Caller cleans up the parameters
    ADD SP, 4

    ; Result is returned in AX
    CALL PrintNumber


; ==================================================
; EXIT PROGRAM
; ==================================================

    MOV AX, 4C00H
    INT 21H


; ==================================================
; PrintNumber Procedure
;
; Input:
;   AX = number to display
;
; Output:
;   Display decimal number
; ==================================================

PrintNumber PROC NEAR

    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 10
    XOR CX, CX


PRINT_DIVIDE:

    XOR DX, DX
    DIV BX

    PUSH DX
    INC CX

    CMP AX, 0
    JNE PRINT_DIVIDE


PRINT_DIGIT:

    POP DX

    ADD DL, '0'

    ; Preserve CX across DOS interrupt
    PUSH CX

    MOV AH, 02H
    INT 21H

    POP CX

    LOOP PRINT_DIGIT


    POP DX
    POP CX
    POP BX

    RET

PrintNumber ENDP


MAINCODE ENDS


; ==================================================
; CALENDAR CODE SEGMENT
; ==================================================

CALCODE SEGMENT PARA PUBLIC 'CODE'

ASSUME CS:CALCODE, DS:DATA, SS:STACKSEG


; ==================================================
; METHOD 1: DATA SEGMENT PASSING
;
; Parameters:
;   valueA and valueB are stored in DATA.
;
; Result:
;   result = valueA + valueB
; ==================================================

AddByData PROC FAR

    MOV AX, valueA

    ADD AX, valueB

    MOV result, AX

    RETF

AddByData ENDP


; ==================================================
; METHOD 2: REGISTER PASSING
;
; Input:
;   AX = first parameter
;   BX = second parameter
;
; Output:
;   AX = sum
; ==================================================

AddByRegister PROC FAR

    ADD AX, BX

    RETF

AddByRegister ENDP


; ==================================================
; METHOD 3: STACK PASSING
;
; Input:
;   [BP+6] = first parameter
;   [BP+8] = second parameter
;
; Output:
;   AX = sum
;
; Caller is responsible for stack cleanup.
; ==================================================

AddByStack PROC FAR

    PUSH BP

    MOV BP, SP

    MOV AX, [BP+6]

    ADD AX, [BP+8]

    POP BP

    RETF

AddByStack ENDP


CALCODE ENDS


END START