; ==================================================
; CALC.ASM
; Calendar calculation module
; MASM 5.0 / 8086
;
; This module contains GetMonthDays.
; It is placed in CALCODE, a separate code segment.
; MAIN.ASM calls it with a FAR CALL.
; ==================================================

; Variables defined in MAIN.ASM's DATA segment.
EXTRN yearValue:WORD
EXTRN monthValue:WORD
EXTRN isLeap:WORD
EXTRN daysInMonth:WORD

PUBLIC GetMonthDays

; Match the DATA segment attributes in MAIN.ASM.
DATA SEGMENT PARA PUBLIC 'DATA'
DATA ENDS

CALCODE SEGMENT PARA PUBLIC 'CODE'
ASSUME CS:CALCODE, DS:DATA

; --------------------------------------------------
; GetMonthDays
;
; Determine whether the selected year is a leap year
; and calculate the number of days in the selected month.
;
; Output:
;   isLeap      = 1 for leap year, 0 for common year
;   daysInMonth = 28, 29, 30 or 31
;
; This is a FAR procedure because MAIN.ASM calls it
; from the separate MAINCODE segment.
; --------------------------------------------------
GetMonthDays PROC FAR

    PUSH AX
    PUSH BX
    PUSH DX

    MOV isLeap, 0

    ; A year divisible by 400 is a leap year.
    MOV AX, yearValue
    XOR DX, DX
    MOV BX, 400
    DIV BX

    CMP DX, 0
    JE GM_LEAP

    ; A year divisible by 100 but not by 400
    ; is a common year.
    MOV AX, yearValue
    XOR DX, DX
    MOV BX, 100
    DIV BX

    CMP DX, 0
    JE GM_NORMAL

    ; Otherwise, a year divisible by 4 is a leap year.
    MOV AX, yearValue
    XOR DX, DX
    MOV BX, 4
    DIV BX

    CMP DX, 0
    JE GM_LEAP

    JMP GM_NORMAL

GM_LEAP:

    MOV isLeap, 1
    JMP GM_CHECK_MONTH

GM_NORMAL:

    MOV isLeap, 0

GM_CHECK_MONTH:

    MOV AX, monthValue

    CMP AX, 2
    JE GM_FEBRUARY

    CMP AX, 4
    JE GM_30

    CMP AX, 6
    JE GM_30

    CMP AX, 9
    JE GM_30

    CMP AX, 11
    JE GM_30

    ; All remaining months have 31 days.
    MOV daysInMonth, 31
    JMP GM_DONE

GM_30:

    MOV daysInMonth, 30
    JMP GM_DONE

GM_FEBRUARY:

    MOV daysInMonth, 28

    CMP isLeap, 1
    JNE GM_DONE

    MOV daysInMonth, 29

GM_DONE:

    POP DX
    POP BX
    POP AX

    RETF

GetMonthDays ENDP

CALCODE ENDS

END
