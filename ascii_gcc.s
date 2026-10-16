.file   "ascii.c"                   # 源文件名为 ascii.c
.intel_syntax noprefix              # 使用 Intel 汇编语法
.text                               # 代码段

.section .rdata,"dr"                # 定义只读数据段
.LC0:
    .ascii "%c \0"                  # printf 的格式字符串：输出一个字符和一个空格，\0 表示字符串结束

.text                               # 切换回代码段
.globl "main"                       # 声明 main 为全局符号
.def "main"; .scl 2; .type 32; .endef  # 定义 main 函数的符号信息

.seh_proc "main"                    # 开始记录 main 函数的异常处理信息
"main":
    push rbp                        # 保存旧的栈帧指针
    .seh_pushreg rbp                # 记录保存 rbp 的操作
    mov rbp, rsp                    # 建立当前函数的栈帧
    .seh_setframe rbp, 0            # 记录栈帧基址
    sub rsp, 48                     # 在栈上分配 48 字节空间
    .seh_stackalloc 48              # 记录栈空间分配信息
    .seh_endprologue                # 函数序言结束

    call "__main"                   # 调用运行时初始化函数

    mov BYTE PTR -1[rbp], 97        # 将 97（字符 'a' 的 ASCII 码）存入局部变量
    jmp .L2                         # 跳转到循环条件判断处

.L4:                                # 循环体开始
    movsx eax, BYTE PTR -1[rbp]     # 将当前字符取出并进行符号扩展，保存到 eax
    lea rcx, .LC0[rip]              # 将格式字符串 "%c " 的地址放入 rcx（第一个参数）
    mov edx, eax                    # 将当前字符放入 edx（第二个参数）
    call "printf"                   # 调用 printf 输出当前字符和空格

    movsx eax, BYTE PTR -1[rbp]     # 再次读取当前字符，并进行符号扩展
    lea ecx, -96[rax]               # 计算当前字符对应的数值：字符 ASCII 码减去 96
                                    # 例如 'a' 为 97，97 - 96 = 1
    movsxd rax, ecx                 # 将 ecx 中的有符号 32 位整数扩展为 64 位整数
    imul rax, rax, 1321528399       # 乘以编译器生成的常数，用于优化除法计算
    shr rax, 32                     # 逻辑右移 32 位，提取乘法结果的高 32 位
    mov edx, eax                    # 将计算结果复制到 edx
    sar edx, 2                      # 算术右移 2 位，相当于有符号数除以 4 的近似步骤
    mov eax, ecx                    # 将原数值复制到 eax
    sar eax, 31                     # 根据 eax 的符号位生成符号调整值
    sub edx, eax                    # 修正除法结果的符号
    mov eax, edx                    # 将计算结果复制到 eax
    add eax, eax                    # eax = eax * 2
    add eax, edx                    # eax = eax * 3
    sal eax, 2                      # eax 左移 2 位，相当于 eax = eax * 4
    add eax, edx                    # 得到 eax = 原商 * 13
    sub ecx, eax                    # 计算余数：原数值减去商乘以 13
                                    # 这一组指令是编译器生成的常数除法/取余优化代码

    mov edx, ecx                    # 将计算结果复制到 edx
    test edx, edx                   # 检查结果是否为 0
    jne .L3                         # 如果不为 0，跳过换行操作

    mov ecx, 10                     # 将 ASCII 码 10（换行符 '\n'）放入 ecx
    call "putchar"                  # 输出换行符

.L3:                                # 判断之后的继续执行位置
    movzx eax, BYTE PTR -1[rbp]     # 读取当前字符，并进行零扩展
    add eax, 1                      # 字符 ASCII 码加 1，转到下一个字符
    mov BYTE PTR -1[rbp], al        # 将新字符保存回局部变量

.L2:                                # 循环条件判断处
    cmp BYTE PTR -1[rbp], 122       # 比较当前字符与 122（字符 'z' 的 ASCII 码）
    jle .L4                         # 如果当前字符小于或等于 'z'，继续循环

    mov eax, 0                      # 将返回值设为 0，表示程序正常结束
    add rsp, 48                     # 释放之前分配的 48 字节栈空间
    pop rbp                         # 恢复调用前的栈帧指针
    ret                             # 返回调用者
.seh_endproc                        # main 函数的异常处理信息结束

.def "__main"; .scl 2; .type 32; .endef  # 定义运行时初始化函数的符号信息
.ident "GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r1) 16.2.0"
                                    # 记录 GCC 编译器版本信息
.def "printf"; .scl 2; .type 32; .endef   # 声明 printf 函数的符号信息
.def "putchar"; .scl 2; .type 32; .endef  # 声明 putchar 函数的符号信息