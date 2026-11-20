; ==================================================
; PRINT.ASM
; Calendar output module
; MASM 5.0 / 8086
;
; PrintCalendar is a FAR procedure called from MAIN.ASM.
; PrintNumber is a NEAR procedure in the same PRINTCODE
; segment and is called internally by PrintCalendar.
; ==================================================

INCLUDE COMMON.INC

; Variables and tables defined in MAIN.ASM.
EXTRN yearValue:WORD
EXTRN monthValue:WORD
EXTRN daysInMonth:WORD
EXTRN isLeap:WORD
EXTRN firstWeekday:WORD

EXTRN monthDaysTable:BYTE
EXTRN monthNames:WORD
EXTRN weekdayTitle:BYTE
EXTRN newline:BYTE

PUBLIC PrintCalendar

; Match the DATA segment attributes in MAIN.ASM.
DATA SEGMENT PARA PUBLIC 'DATA'
DATA ENDS

PRINTCODE SEGMENT PARA PUBLIC 'CODE'
ASSUME CS:PRINTCODE, DS:DATA

; --------------------------------------------------
; PrintCalendar
;
; Calculate the weekday of the first day of the month
; and print the complete calendar.
;
; Weekday numbering:
;   Sunday=0, Monday=1, Tuesday=2, Wednesday=3,
;   Thursday=4, Friday=5, Saturday=6
;
; January 1, 1900 was Monday.
;
; This is a FAR procedure because MAIN.ASM calls it
; from the separate MAINCODE segment.
; --------------------------------------------------
PrintCalendar PROC FAR

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

; --------------------------------------------------
; STEP 1: Calculate weekday of January 1
; DI stores elapsed days MOD 7 to avoid overflow.
; --------------------------------------------------

    MOV SI, 1900
    XOR DI, DI

PC_YEAR_LOOP:

    CMP SI, yearValue
    JAE PC_YEAR_DONE

    ; Check whether the current year is a leap year.
    MOV AX, SI
    XOR DX, DX
    MOV BX, 400
    DIV BX

    CMP DX, 0
    JE PC_YEAR_LEAP

    MOV AX, SI
    XOR DX, DX
    MOV BX, 100
    DIV BX

    CMP DX, 0
    JE PC_YEAR_NORMAL

    MOV AX, SI
    XOR DX, DX
    MOV BX, 4
    DIV BX

    CMP DX, 0
    JE PC_YEAR_LEAP

    JMP PC_YEAR_NORMAL

PC_YEAR_LEAP:

    ; 366 MOD 7 = 2.
    ADD DI, 2
    JMP PC_YEAR_REDUCE

PC_YEAR_NORMAL:

    ; 365 MOD 7 = 1.
    INC DI

PC_YEAR_REDUCE:

    CMP DI, 7
    JB PC_YEAR_NEXT

    SUB DI, 7

PC_YEAR_NEXT:

    INC SI
    JMP PC_YEAR_LOOP

PC_YEAR_DONE:

; --------------------------------------------------
; STEP 2: Add days of the previous months
; --------------------------------------------------

    MOV SI, 1

PC_MONTH_LOOP:

    CMP SI, monthValue
    JAE PC_MONTH_DONE

    MOV BX, SI
    DEC BX

    MOV AL, monthDaysTable[BX]
    XOR AH, AH

    ; February has 29 days in a leap year.
    CMP SI, 2
    JNE PC_ADD_MONTH_DAYS

    CMP isLeap, 1
    JNE PC_ADD_MONTH_DAYS

    INC AX

PC_ADD_MONTH_DAYS:

    ADD DI, AX

    ; DI = DI MOD 7.
    MOV AX, DI
    XOR DX, DX
    MOV BX, 7
    DIV BX

    MOV DI, DX

    INC SI
    JMP PC_MONTH_LOOP

PC_MONTH_DONE:

; --------------------------------------------------
; STEP 3: Calculate first weekday
; January 1, 1900 was Monday; Sunday is 0.
; --------------------------------------------------

    MOV AX, DI
    INC AX

    CMP AX, 7
    JB PC_WEEKDAY_READY

    SUB AX, 7

PC_WEEKDAY_READY:

    MOV firstWeekday, AX

; --------------------------------------------------
; STEP 4: Display year and month
; --------------------------------------------------

    MOV AX, yearValue
    CALL PrintNumber

    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    MOV BX, monthValue
    DEC BX
    SHL BX, 1

    MOV DX, monthNames[BX]
    MOV AH, 09H
    INT 21H

    PRINT_STR newline

; --------------------------------------------------
; STEP 5: Display weekday title
; --------------------------------------------------

    PRINT_STR weekdayTitle

; --------------------------------------------------
; STEP 6: Print leading blank spaces
; --------------------------------------------------

    MOV CX, firstWeekday

PC_LEADING_LOOP:

    CMP CX, 0
    JE PC_LEADING_DONE

    PUSH CX

    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    POP CX

    DEC CX
    JMP PC_LEADING_LOOP

PC_LEADING_DONE:

    MOV SI, 1
    MOV DI, firstWeekday

; --------------------------------------------------
; STEP 7: Print all dates
; --------------------------------------------------

PC_DAY_LOOP:

    CMP SI, daysInMonth
    JA PC_DAY_DONE

    MOV AX, SI

    CMP AX, 10
    JAE PC_PRINT_DAY_NUMBER

    ; One-digit date needs one leading space.
    MOV DL, ' '
    MOV AH, 02H
    INT 21H

PC_PRINT_DAY_NUMBER:

    ; Reload the date number after INT 21H.
    MOV AX, SI
    CALL PrintNumber

    ; One space after each date.
    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    ; Move to the next weekday column.
    INC DI

    CMP DI, 7
    JNE PC_NO_NEWLINE

    PRINT_STR newline

    MOV DI, 0

PC_NO_NEWLINE:

    INC SI
    JMP PC_DAY_LOOP

PC_DAY_DONE:

    ; Do not print an extra blank line if the final
    ; date already ended a complete week.
    CMP DI, 0
    JE PC_PRINT_DONE

    PRINT_STR newline

PC_PRINT_DONE:

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    RETF

PrintCalendar ENDP


; --------------------------------------------------
; PrintNumber
;
; Input:
;   AX = unsigned decimal number
;
; Output:
;   Display the number in decimal.
;
; This procedure is in PRINTCODE, the same code segment
; as PrintCalendar, so it uses a NEAR CALL and RET.
; --------------------------------------------------
PrintNumber PROC NEAR

    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 10
    XOR CX, CX

    ; Repeated division obtains digits in reverse order.
PN_DIVIDE:

    XOR DX, DX
    DIV BX

    PUSH DX
    INC CX

    CMP AX, 0
    JNE PN_DIVIDE

; Pop digits in reverse order and display them.
PN_PRINT:

    POP DX
    ADD DL, '0'

    ; Preserve the loop counter across DOS interrupt.
    PUSH CX

    MOV AH, 02H
    INT 21H

    POP CX

    LOOP PN_PRINT

    POP DX
    POP CX
    POP BX

    RET

PrintNumber ENDP

PRINTCODE ENDS

END
