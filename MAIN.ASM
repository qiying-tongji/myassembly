
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

INCLUDE COMMON.INC

EXTRN ParseNumber:NEAR
EXTRN GetMonthDays:FAR
EXTRN PrintCalendar:FAR

PUBLIC yearValue
PUBLIC monthValue
PUBLIC daysInMonth
PUBLIC isLeap
PUBLIC firstWeekday
PUBLIC monthDaysTable
PUBLIC monthNames
PUBLIC weekdayTitle
PUBLIC newline

DATA SEGMENT PARA PUBLIC 'DATA'

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

    PRINT_STR promptYear

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

    PRINT_STR promptMonth


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
    PRINT_STR newline


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

    PRINT_STR errorMsg

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



MAINCODE ENDS


; ==================================================
; CALENDAR CODE SEGMENT
; ==================================================



END START
