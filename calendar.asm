
; ==================================================
; Calendar Program
; Stage 4 - Complete Version
; MASM 5.0 / 8086
; Year: 1900-2099
; Month: 1-12
; ==================================================


; ==================================================
; DATA SEGMENT
; ==================================================

DATA SEGMENT

    promptYear  DB 'Please input year (1900-2099): $'
    promptMonth DB 0DH,0AH,'Please input month (1-12): $'

    errorMsg    DB 0DH,0AH,'Invalid input!$'
    newline     DB 0DH,0AH,'$'

    weekdayTitle DB 'Su Mo Tu We Th Fr Sa',0DH,0AH,'$'

    ; Keyboard input buffers
    yearBuffer  DB 5,0,5 DUP(?)
    monthBuffer DB 3,0,3 DUP(?)

    ; Input values
    yearValue   DW 0
    monthValue  DW 0

    ; Calendar calculation values
    daysInMonth  DW 0
    isLeap       DW 0
    firstWeekday DW 0

    ; Days of each month
    monthDaysTable DB 31,28,31,30,31,30
                   DB 31,31,30,31,30,31

    ; Month name address table
    monthNames DW OFFSET JanName
               DW OFFSET FebName
               DW OFFSET MarName
               DW OFFSET AprName
               DW OFFSET MayName
               DW OFFSET JunName
               DW OFFSET JulName
               DW OFFSET AugName
               DW OFFSET SepName
               DW OFFSET OctName
               DW OFFSET NovName
               DW OFFSET DecName

    ; Month names
    JanName DB 'January$'
    FebName DB 'February$'
    MarName DB 'March$'
    AprName DB 'April$'
    MayName DB 'May$'
    JunName DB 'June$'
    JulName DB 'July$'
    AugName DB 'August$'
    SepName DB 'September$'
    OctName DB 'October$'
    NovName DB 'November$'
    DecName DB 'December$'

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
; STEP 1: INPUT YEAR
; ==================================================

    MOV AH, 09H
    LEA DX, promptYear
    INT 21H

    LEA DX, yearBuffer
    MOV AH, 0AH
    INT 21H

    ; Year must contain exactly 4 digits
    CMP BYTE PTR yearBuffer+1, 4
    JE YEAR_LENGTH_OK
    JMP INPUT_ERROR


YEAR_LENGTH_OK:

    LEA SI, yearBuffer+2

    XOR CX, CX
    MOV CL, yearBuffer+1

    CALL ParseNumber

    JNC YEAR_PARSE_OK
    JMP INPUT_ERROR


YEAR_PARSE_OK:

    CMP AX, 1900
    JAE YEAR_MIN_OK
    JMP INPUT_ERROR


YEAR_MIN_OK:

    CMP AX, 2099
    JBE YEAR_MAX_OK
    JMP INPUT_ERROR


YEAR_MAX_OK:

    MOV yearValue, AX


; ==================================================
; STEP 2: INPUT MONTH
; ==================================================

    MOV AH, 09H
    LEA DX, promptMonth
    INT 21H

    LEA DX, monthBuffer
    MOV AH, 0AH
    INT 21H

    ; Month must contain 1 or 2 digits
    CMP BYTE PTR monthBuffer+1, 1
    JAE MONTH_LENGTH_MIN_OK
    JMP INPUT_ERROR


MONTH_LENGTH_MIN_OK:

    CMP BYTE PTR monthBuffer+1, 2
    JBE MONTH_LENGTH_MAX_OK
    JMP INPUT_ERROR


MONTH_LENGTH_MAX_OK:

    LEA SI, monthBuffer+2

    XOR CX, CX
    MOV CL, monthBuffer+1

    CALL ParseNumber

    JNC MONTH_PARSE_OK
    JMP INPUT_ERROR


MONTH_PARSE_OK:

    CMP AX, 1
    JAE MONTH_MIN_OK
    JMP INPUT_ERROR


MONTH_MIN_OK:

    CMP AX, 12
    JBE MONTH_MAX_OK
    JMP INPUT_ERROR


MONTH_MAX_OK:

    MOV monthValue, AX


    ; IMPORTANT:
    ; Move to the next line after buffered input.
    MOV AH, 09H
    LEA DX, newline
    INT 21H


; ==================================================
; STEP 3: CALCULATE MONTH DAYS
; ==================================================

    CALL FAR PTR GetMonthDays


; ==================================================
; STEP 4: PRINT CALENDAR
; ==================================================

    CALL FAR PTR PrintCalendar

    JMP PROGRAM_EXIT


; ==================================================
; INPUT ERROR
; ==================================================

INPUT_ERROR:

    MOV AH, 09H
    LEA DX, errorMsg
    INT 21H

    MOV AH, 09H
    LEA DX, newline
    INT 21H


PROGRAM_EXIT:

    MOV AX, 4C00H
    INT 21H


; ==================================================
; ParseNumber Procedure
;
; Input:
;   DS:SI = input string address
;   CX    = number of characters
;
; Output:
;   AX = converted decimal number
;   CF = 0 success
;   CF = 1 error
; ==================================================

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

    ; Check lower boundary
    CMP AL, '0'
    JB PN_ERROR

    ; Check upper boundary
    CMP AL, '9'
    JA PN_ERROR

    ; ASCII to number
    SUB AL, '0'
    XOR AH, AH

    ; BX = BX * 10 + digit
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


; ==================================================
; CALENDAR CODE SEGMENT
; ==================================================

CALCODE SEGMENT PARA PUBLIC 'CODE'

ASSUME CS:CALCODE, DS:DATA


; ==================================================
; GetMonthDays Procedure
;
; Determine leap year and days in month.
;
; Output:
;   isLeap      = 1 or 0
;   daysInMonth = 28, 29, 30 or 31
; ==================================================

GetMonthDays PROC FAR

    PUSH AX
    PUSH BX
    PUSH DX

    MOV isLeap, 0

    ; Check divisible by 400
    MOV AX, yearValue
    XOR DX, DX
    MOV BX, 400
    DIV BX

    CMP DX, 0
    JE GM_LEAP

    ; Check divisible by 100
    MOV AX, yearValue
    XOR DX, DX
    MOV BX, 100
    DIV BX

    CMP DX, 0
    JE GM_NORMAL

    ; Check divisible by 4
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

    ; Remaining months have 31 days
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


; ==================================================
; PrintCalendar Procedure
;
; Calculate first weekday and print calendar.
;
; Sunday    = 0
; Monday    = 1
; Tuesday   = 2
; Wednesday = 3
; Thursday  = 4
; Friday    = 5
; Saturday  = 6
; ==================================================

PrintCalendar PROC FAR

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI


; ==================================================
; STEP 1:
; Calculate weekday of January 1
; ==================================================

    MOV SI, 1900

    XOR DI, DI

    ; DI stores elapsed days MOD 7.
    ; This prevents 16-bit overflow.


PC_YEAR_LOOP:

    CMP SI, yearValue
    JAE PC_YEAR_DONE

    ; Check whether current year is leap
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

    ; 366 MOD 7 = 2
    ADD DI, 2

    JMP PC_YEAR_REDUCE


PC_YEAR_NORMAL:

    ; 365 MOD 7 = 1
    INC DI


PC_YEAR_REDUCE:

    CMP DI, 7
    JB PC_YEAR_NEXT

    SUB DI, 7


PC_YEAR_NEXT:

    INC SI

    JMP PC_YEAR_LOOP


PC_YEAR_DONE:


; ==================================================
; STEP 2:
; Add days of previous months
; ==================================================

    MOV SI, 1


PC_MONTH_LOOP:

    CMP SI, monthValue
    JAE PC_MONTH_DONE

    MOV BX, SI
    DEC BX

    MOV AL, monthDaysTable[BX]
    XOR AH, AH

    ; February has 29 days in leap year
    CMP SI, 2
    JNE PC_ADD_MONTH_DAYS

    CMP isLeap, 1
    JNE PC_ADD_MONTH_DAYS

    INC AX


PC_ADD_MONTH_DAYS:

    ADD DI, AX

    ; DI = DI MOD 7
    MOV AX, DI
    XOR DX, DX
    MOV BX, 7
    DIV BX

    MOV DI, DX

    INC SI

    JMP PC_MONTH_LOOP


PC_MONTH_DONE:


; ==================================================
; STEP 3:
; Calculate first weekday
;
; January 1, 1900 was Monday.
; Sunday = 0.
; ==================================================

    MOV AX, DI

    INC AX

    CMP AX, 7
    JB PC_WEEKDAY_READY

    SUB AX, 7


PC_WEEKDAY_READY:

    MOV firstWeekday, AX


; ==================================================
; STEP 4:
; Display year and month
; ==================================================

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

    MOV AH, 09H
    LEA DX, newline
    INT 21H


; ==================================================
; STEP 5:
; Display weekday title
; ==================================================

    MOV AH, 09H
    LEA DX, weekdayTitle
    INT 21H


; ==================================================
; STEP 6:
; Print leading blank spaces
; ==================================================

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


; ==================================================
; STEP 7:
; Print all dates
; ==================================================

PC_DAY_LOOP:

    CMP SI, daysInMonth
    JA PC_DAY_DONE

    MOV AX, SI

    CMP AX, 10
    JAE PC_PRINT_DAY_NUMBER

    ; One-digit number needs one leading space
    MOV DL, ' '
    MOV AH, 02H
    INT 21H


PC_PRINT_DAY_NUMBER:

    ; Reload the day number.
    ; Do not reuse AL after INT 21H.
    MOV AX, SI

    CALL PrintNumber

    ; One space after each date
    MOV DL, ' '
    MOV AH, 02H
    INT 21H


    ; Move to next weekday column
    INC DI

    CMP DI, 7
    JNE PC_NO_NEWLINE

    ; Start a new week
    MOV AH, 09H
    LEA DX, newline
    INT 21H

    MOV DI, 0


PC_NO_NEWLINE:

    INC SI

    JMP PC_DAY_LOOP


PC_DAY_DONE:

    ; Avoid an unnecessary blank line
    ; if the last day already ended a week.
    CMP DI, 0
    JE PC_PRINT_DONE

    MOV AH, 09H
    LEA DX, newline
    INT 21H


PC_PRINT_DONE:

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

    RETF

PrintCalendar ENDP


; ==================================================
; PrintNumber Procedure
;
; Input:
;   AX = unsigned decimal number
;
; Output:
;   Display decimal number
;
; Uses stack to reverse digits.
; ==================================================

PrintNumber PROC NEAR

    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 10

    XOR CX, CX


PN_DIVIDE:

    XOR DX, DX

    DIV BX

    PUSH DX

    INC CX

    CMP AX, 0
    JNE PN_DIVIDE


PN_PRINT:

    POP DX

    ADD DL, '0'

    ; Preserve loop counter across DOS interrupt
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


CALCODE ENDS


END START
