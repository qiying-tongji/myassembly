.file   "multable.c"                # 源文件名为 multable.c
.intel_syntax noprefix              # 使用 Intel 汇编语法
.text                               # 进入代码段

.section .rdata,"dr"                # 定义只读数据段
.LC0:
    .ascii "%d*%d=%d  \0"            # printf 的格式字符串：输出 i*j=结果，末尾有两个空格和结束符

.text                               # 切换到代码段
.globl "print_item"                 # 声明 print_item 为全局符号
.def "print_item"; .scl 2; .type 32; .endef  # 定义函数符号信息
.seh_proc "print_item"              # 开始记录函数的异常处理信息

"print_item":
    push rbp                        # 保存调用者的栈帧指针
    .seh_pushreg rbp                # 记录保存 rbp 的操作
    mov rbp, rsp                    # 建立当前函数的栈帧
    .seh_setframe rbp, 0             # 记录栈帧基址
    sub rsp, 32                     # 分配 32 字节局部栈空间
    .seh_stackalloc 32              # 记录栈空间分配信息
    .seh_endprologue                # 函数序言结束

    mov DWORD PTR 16[rbp], ecx      # 将第一个参数 i 保存到栈中
    mov DWORD PTR 24[rbp], edx      # 将第二个参数 j 保存到栈中

    mov eax, DWORD PTR 16[rbp]      # 取出 i，存入 eax
    imul eax, DWORD PTR 24[rbp]     # eax = i * j，计算乘积
    mov r8d, eax                    # 暂存乘积，作为 printf 的第三个数据参数

    mov edx, DWORD PTR 24[rbp]      # 取出 j，存入 edx
    mov eax, DWORD PTR 16[rbp]      # 取出 i，存入 eax
    lea rcx, .LC0[rip]              # 将格式字符串地址放入 rcx，作为 printf 的第一个参数

    mov r9d, r8d                    # 将乘积放入 r9d，作为 printf 的第四个参数
    mov r8d, edx                    # 将 j 放入 r8d，作为 printf 的第三个参数
    mov edx, eax                    # 将 i 放入 edx，作为 printf 的第二个参数
    call "printf"                   # 调用 printf，输出 i*j=乘积

    nop                             # 空操作指令，不改变程序状态
    add rsp, 32                     # 释放局部栈空间
    pop rbp                         # 恢复调用者的栈帧指针
    ret                             # 返回调用位置
.seh_endproc                        # print_item 的异常处理信息结束


.section .rdata,"dr"                # 定义只读数据段
.LC1:
    .ascii "The 9 multiplication table:\0"  # 九九乘法表标题字符串

.text                               # 进入代码段
.globl "main"                       # 声明 main 为全局符号
.def "main"; .scl 2; .type 32; .endef  # 定义 main 函数符号信息
.seh_proc "main"                    # 开始记录 main 的异常处理信息

"main":
    push rbp                        # 保存调用者的栈帧指针
    .seh_pushreg rbp                # 记录保存 rbp 的操作
    mov rbp, rsp                    # 建立 main 函数的栈帧
    .seh_setframe rbp, 0             # 记录栈帧基址
    sub rsp, 48                     # 分配 48 字节栈空间
    .seh_stackalloc 48              # 记录栈空间分配信息
    .seh_endprologue                # 函数序言结束

    call "__main"                   # 调用 GCC 运行时初始化函数

    lea rax, .LC1[rip]              # 获取标题字符串的地址
    mov rcx, rax                    # 将字符串地址放入 rcx，作为 puts 的参数
    call "puts"                     # 输出标题，并自动换行

    mov DWORD PTR -4[rbp], 9        # 将外层循环变量 i 初始化为 9
    jmp .L3                         # 跳转到外层循环条件判断

.L6:                                # 外层循环体开始
    mov DWORD PTR -8[rbp], 1        # 将内层循环变量 j 初始化为 1
    jmp .L4                         # 跳转到内层循环条件判断

.L5:                                # 内层循环体开始
    mov edx, DWORD PTR -8[rbp]      # 将 j 放入 edx，作为 print_item 的第二个参数
    mov eax, DWORD PTR -4[rbp]      # 将 i 放入 eax
    mov ecx, eax                    # 将 i 放入 ecx，作为 print_item 的第一个参数
    call "print_item"               # 调用 print_item，输出当前乘法表达式

    add DWORD PTR -8[rbp], 1        # j = j + 1，内层循环变量递增

.L4:                                # 内层循环条件判断处
    mov eax, DWORD PTR -8[rbp]      # 取出 j
    cmp eax, DWORD PTR -4[rbp]      # 比较 j 和 i
    jle .L5                         # 如果 j <= i，继续执行内层循环

    mov ecx, 10                     # 将换行符的 ASCII 码 10 放入 ecx
    call "putchar"                  # 调用 putchar 输出换行符

    sub DWORD PTR -4[rbp], 1        # i = i - 1，外层循环变量递减

.L3:                                # 外层循环条件判断处
    cmp DWORD PTR -4[rbp], 0        # 比较 i 和 0
    jg .L6                          # 如果 i > 0，继续执行外层循环

    mov eax, 0                      # 设置 main 的返回值为 0
    add rsp, 48                     # 释放 main 分配的栈空间
    pop rbp                         # 恢复调用者的栈帧指针
    ret                             # 返回操作系统
.seh_endproc                        # main 的异常处理信息结束


.def "__main"; .scl 2; .type 32; .endef  # 定义 GCC 运行时初始化函数的符号信息
.ident "GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r1) 16.2.0"
                                    # 记录 GCC 编译器版本信息
.def "printf"; .scl 2; .type 32; .endef   # 声明 printf 函数的符号信息
.def "puts"; .scl 2; .type 32; .endef     # 声明 puts 函数的符号信息
.def "putchar"; .scl 2; .type 32; .endef  # 声明 putchar 函数的符号信息