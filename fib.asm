
.MODEL SMALL
.STACK 1000H

.DATA
    prompt   DB 'Please input n (1-100): $'
    result   DB 0DH,0AH,'Fibonacci number: $'
    errorMsg DB 0DH,0AH,'Invalid input!$'
    newline  DB 0DH,0AH,'$'

    ; 5个16位字组成80位整数
    A    DW 5 DUP(0)
    B    DW 5 DUP(0)
    TEMP DW 5 DUP(0)
    WORK DW 5 DUP(0)

.CODE

START:
    MOV AX, @DATA
    MOV DS, AX

    ; 显示输入提示
    MOV AH, 09H
    LEA DX, prompt
    INT 21H

    XOR DI, DI

; =========================
; 输入1-100之间的整数
; =========================

READ_INPUT:
    MOV AH, 01H
    INT 21H

    CMP AL, 0DH
    JNE CHECK_INPUT
    JMP INPUT_DONE

CHECK_INPUT:
    CMP AL, '0'
    JAE CHECK_UPPER
    JMP INVALID

CHECK_UPPER:
    CMP AL, '9'
    JBE DIGIT_OK
    JMP INVALID

DIGIT_OK:
    SUB AL, '0'
    XOR AH, AH
    MOV SI, AX

    ; 防止输入溢出
    CMP DI, 10
    JBE INPUT_SAFE
    JMP INVALID

INPUT_SAFE:
    ; DI = DI * 10 + 当前数字
    MOV AX, DI
    MOV BX, 10
    MUL BX
    ADD AX, SI
    MOV DI, AX

    CMP DI, 100
    JBE READ_INPUT
    JMP INVALID

INPUT_DONE:
    CMP DI, 1
    JAE INPUT_VALID
    JMP INVALID

INPUT_VALID:
    ; 调用递归函数
    PUSH DI
    CALL FIB
    ADD SP, 2

    ; 输出提示
    MOV AH, 09H
    LEA DX, result
    INT 21H

    ; 复制A到WORK
    MOV SI, 0
    MOV CX, 5

COPY_RESULT:
    MOV AX, A[SI]
    MOV WORK[SI], AX
    ADD SI, 2
    LOOP COPY_RESULT

    ; =========================
    ; 80位整数转换成十进制
    ; =========================

    MOV CX, 0

CONVERT_LOOP:
    MOV BX, 10
    MOV SI, 8
    XOR DX, DX

DIV_WORD:
    MOV AX, WORK[SI]
    DIV BX
    MOV WORK[SI], AX

    SUB SI, 2
    CMP SI, 0
    JGE DIV_WORD

    ; 保存余数
    PUSH DX
    INC CX

    ; 检查商是否为0
    MOV AX, WORK[0]
    OR AX, WORK[2]
    OR AX, WORK[4]
    OR AX, WORK[6]
    OR AX, WORK[8]

    JNE CONVERT_LOOP

PRINT_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PRINT_LOOP

    MOV AH, 09H
    LEA DX, newline
    INT 21H

    MOV AX, 4C00H
    INT 21H

; =========================
; 输入错误处理
; =========================

INVALID:
    MOV AH, 09H
    LEA DX, errorMsg
    INT 21H

    MOV AX, 4C01H
    INT 21H

; =========================
; 递归函数 FIB
; 参数：[BP+4] = n
; A保存F(n)
; B保存F(n+1)
; =========================

FIB PROC NEAR

    PUSH BP
    MOV BP, SP

    ; 保存寄存器
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV AX, [BP+4]

    CMP AX, 0
    JNE RECURSIVE_CALL

    ; 基本情况：F(0)=0
    MOV A[0], 0
    MOV A[2], 0
    MOV A[4], 0
    MOV A[6], 0
    MOV A[8], 0

    ; B=F(1)=1
    MOV B[0], 1
    MOV B[2], 0
    MOV B[4], 0
    MOV B[6], 0
    MOV B[8], 0

    JMP FIB_EXIT

RECURSIVE_CALL:

    ; 递归调用FIB(n-1)
    DEC AX
    PUSH AX
    CALL FIB
    ADD SP, 2

    ; 保存A到TEMP
    MOV SI, 0
    MOV CX, 5

SAVE_A:
    MOV AX, A[SI]
    MOV TEMP[SI], AX
    ADD SI, 2
    LOOP SAVE_A

    ; A=B
    MOV SI, 0
    MOV CX, 5

COPY_B:
    MOV AX, B[SI]
    MOV A[SI], AX
    ADD SI, 2
    LOOP COPY_B

    ; B=B+TEMP
    ; 使用ADC逐字传递进位
    MOV SI, 0
    MOV CX, 5
    CLC

ADD_WORDS:
    MOV AX, B[SI]
    ADC AX, TEMP[SI]
    MOV B[SI], AX

    INC SI
    INC SI
    LOOP ADD_WORDS

FIB_EXIT:

    ; 恢复寄存器
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    POP BP

    RET

FIB ENDP

END START