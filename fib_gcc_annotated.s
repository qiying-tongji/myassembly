
.file   "fib.c"                      # 对应的C语言源文件名称
.intel_syntax noprefix               # 使用Intel汇编语法，不需要在寄存器前加%
.text                                # 进入代码段

.globl  "fib"                        # 声明fib函数为全局函数
.def    "fib"; .scl 2; .type 32; .endef
.seh_proc "fib"                      # 标记fib函数的异常处理信息区域

# ==========================================
# 第一部分：fib函数
# 功能：使用递归计算斐波那契数列
# 参数：n、a的地址、b的地址
# ==========================================

"fib":
    push    rbp                      # 保存调用者的基址指针
    .seh_pushreg rbp                 # 记录RBP寄存器的保存信息
    push    rbx                      # 保存RBX寄存器
    .seh_pushreg rbx                 # 记录RBX寄存器的保存信息

    sub     rsp, 56                  # 在堆栈中分配56字节局部空间
    .seh_stackalloc 56               # 记录堆栈空间分配信息

    lea     rbp, 48[rsp]             # 设置当前函数的基址指针
    .seh_setframe rbp, 48            # 记录基址指针信息
    .seh_endprologue                 # 函数序言结束

    # Windows x64调用约定：
    # 第一个参数通过ECX传递，即n
    # 第二个参数通过RDX传递，即a的地址
    # 第三个参数通过R8传递，即b的地址

    mov     DWORD PTR 32[rbp], ecx   # 将参数n保存到局部堆栈
    mov     QWORD PTR 40[rbp], rdx   # 将a的地址保存到堆栈
    mov     QWORD PTR 48[rbp], r8    # 将b的地址保存到堆栈

    cmp     DWORD PTR 32[rbp], 0     # 比较n与0，判断是否达到递归终止条件
    jne     .L2                      # 如果n不等于0，跳转到递归计算部分

    # 递归终止条件：n=0
    # 此时F(0)=0，F(1)=1

    mov     rax, QWORD PTR 40[rbp]   # 读取a的地址
    mov     QWORD PTR [rax], 0       # 将a的低64位设置为0
    mov     QWORD PTR 8[rax], 0      # 将a的高64位设置为0

    mov     rax, QWORD PTR 48[rbp]   # 读取b的地址
    mov     QWORD PTR [rax], 1       # 将b的低64位设置为1
    mov     QWORD PTR 8[rax], 0      # 将b的高64位设置为0

    jmp     .L1                      # 跳转到函数结束部分

.L2:
    # 递归计算：fib(n-1)

    mov     eax, DWORD PTR 32[rbp]   # 读取当前参数n
    lea     ecx, -1[rax]             # 计算n-1，并将结果放入ECX

    mov     rdx, QWORD PTR 48[rbp]   # 读取b的地址
    mov     rax, QWORD PTR 40[rbp]   # 读取a的地址

    mov     r8, rdx                  # 将b的地址作为第三个参数
    mov     rdx, rax                 # 将a的地址作为第二个参数

    call    "fib"                    # 递归调用fib函数自身，计算fib(n-1)

    # 递归调用返回后，保存原来的a值
    # 因为后续需要使用原来的a与b进行相加

    mov     rax, QWORD PTR 40[rbp]   # 读取a的地址
    mov     rdx, QWORD PTR 8[rax]    # 读取a的高64位
    mov     rax, QWORD PTR [rax]     # 读取a的低64位

    mov     QWORD PTR -16[rbp], rax  # 将a的低64位保存到局部变量
    mov     QWORD PTR -8[rbp], rdx   # 将a的高64位保存到局部变量

    # 执行a=b，将b的值复制给a

    mov     rax, QWORD PTR 48[rbp]   # 读取b的地址
    mov     rdx, QWORD PTR 8[rax]    # 读取b的高64位
    mov     rax, QWORD PTR [rax]     # 读取b的低64位

    mov     rcx, QWORD PTR 40[rbp]   # 读取a的地址
    mov     QWORD PTR [rcx], rax     # 将b的低64位写入a
    mov     QWORD PTR 8[rcx], rdx    # 将b的高64位写入a

    # 执行b=原来的a+b
    # 由于使用128位整数，需要分成高低64位进行计算

    mov     rax, QWORD PTR 48[rbp]   # 读取b的地址
    mov     rcx, QWORD PTR [rax]     # 读取b的低64位
    mov     rbx, QWORD PTR 8[rax]    # 读取b的高64位

    mov     rax, QWORD PTR -16[rbp]  # 读取原来a的低64位
    mov     rdx, QWORD PTR -8[rbp]   # 读取原来a的高64位

    add     rax, rcx                 # 低64位相加
    adc     rdx, rbx                 # 高64位相加，并加上低64位产生的进位

    mov     rcx, QWORD PTR 48[rbp]   # 读取b的地址
    mov     QWORD PTR [rcx], rax     # 保存计算结果的低64位
    mov     QWORD PTR 8[rcx], rdx    # 保存计算结果的高64位

.L1:
    add     rsp, 56                  # 释放当前函数分配的56字节堆栈空间
    pop     rbx                      # 恢复调用者原来的RBX寄存器
    pop     rbp                      # 恢复调用者原来的RBP寄存器
    ret                              # 返回上一级递归调用位置

.seh_endproc                        # fib函数异常处理信息结束


# ==========================================
# 第二部分：printBigInt函数
# 功能：将128位整数转换为十进制字符并输出
# ==========================================

.globl  "printBigInt"                # 声明printBigInt为全局函数
.def    "printBigInt"; .scl 2; .type 32; .endef
.seh_proc "printBigInt"              # 开始printBigInt函数

"printBigInt":
    push    rbp                      # 保存原来的基址指针
    .seh_pushreg rbp
    push    rbx                      # 保存RBX寄存器
    .seh_pushreg rbx

    sub     rsp, 152                 # 分配152字节局部堆栈空间
    .seh_stackalloc 152

    lea     rbp, 144[rsp]            # 设置当前函数的基址指针
    .seh_setframe rbp, 144
    .seh_endprologue

    mov     rbx, rcx                 # 保存传入的128位整数地址

    # 读取128位整数的高低64位

    mov     rax, QWORD PTR [rbx]     # 读取低64位
    mov     rdx, QWORD PTR 8[rbx]    # 读取高64位

    mov     QWORD PTR -64[rbp], rax  # 保存低64位
    mov     QWORD PTR -56[rbp], rdx  # 保存高64位

    mov     DWORD PTR -4[rbp], 0     # 初始化数字字符计数器

    # 判断输入的整数是否为0

    mov     rax, QWORD PTR -64[rbp]  # 读取低64位
    or      rax, QWORD PTR -56[rbp]  # 将高64位与低64位进行或运算
    jne     .L7                      # 如果不为0，跳转到数字转换部分

    mov     ecx, 48                  # ASCII码48对应字符'0'
    call    "putchar"                # 输出字符0
    jmp     .L4                      # 跳转到函数结束位置

.L8:
    # 使用128位整数除以10，获取当前最低位数字

    mov     rax, QWORD PTR -64[rbp]  # 读取整数低64位
    mov     rdx, QWORD PTR -56[rbp]  # 读取整数高64位

    lea     rcx, -80[rbp]            # 获取128位被除数的存储地址
    lea     r8, -96[rbp]             # 获取除数的存储地址

    mov     QWORD PTR -80[rbp], rax  # 保存被除数低64位
    mov     QWORD PTR -72[rbp], rdx  # 保存被除数高64位

    mov     QWORD PTR -96[rbp], 10   # 设置除数低64位为10
    mov     QWORD PTR -88[rbp], 0    # 设置除数高64位为0

    mov     rdx, r8                  # 设置辅助函数的参数
    call    "__umodti3"              # 调用128位无符号取模函数，计算余数

    movaps  XMMWORD PTR -112[rbp], xmm0 # 保存128位取模结果

    mov     rax, QWORD PTR -112[rbp] # 读取余数低64位
    mov     rdx, QWORD PTR -104[rbp] # 读取余数高64位

    lea     ecx, 48[rax]             # 将数字余数转换为ASCII字符

    mov     eax, DWORD PTR -4[rbp]   # 读取当前字符数量
    lea     edx, 1[rax]              # 字符数量加1
    mov     DWORD PTR -4[rbp], edx   # 保存更新后的字符数量

    mov     edx, ecx                 # 将ASCII字符放入EDX
    cdqe                             # 将EAX中的索引符号扩展到RAX

    mov     BYTE PTR -48[rbp+rax], dl # 将当前数字字符保存到字符数组

    # 计算128位整数除以10的商

    mov     rax, QWORD PTR -64[rbp]  # 读取当前整数低64位
    mov     rdx, QWORD PTR -56[rbp]  # 读取当前整数高64位

    lea     rcx, -80[rbp]            # 获取被除数地址
    lea     r8, -96[rbp]             # 获取除数地址

    mov     QWORD PTR -80[rbp], rax  # 保存被除数低64位
    mov     QWORD PTR -72[rbp], rdx  # 保存被除数高64位

    mov     QWORD PTR -96[rbp], 10   # 设置除数为10
    mov     QWORD PTR -88[rbp], 0    # 除数高64位为0

    mov     rdx, r8                  # 设置辅助函数参数
    call    "__udivti3"              # 调用128位无符号除法函数，计算商

    movaps  XMMWORD PTR -64[rbp], xmm0 # 保存128位除法结果

.L7:
    # 检查除法得到的商是否为0

    mov     rax, QWORD PTR -64[rbp]  # 读取商的低64位
    or      rax, QWORD PTR -56[rbp]  # 检查高低64位是否都为0
    jne     .L8                      # 如果不为0，继续提取下一位数字

    jmp     .L9                      # 如果为0，说明转换完成，准备输出

.L10:
    # 从字符数组中倒序取出数字并输出

    sub     DWORD PTR -4[rbp], 1     # 字符计数器减1
    mov     eax, DWORD PTR -4[rbp]   # 获取当前字符索引

    cdqe                             # 将索引扩展为64位
    movzx   eax, BYTE PTR -48[rbp+rax] # 读取对应的数字字符

    movsx   eax, al                  # 对字符进行符号扩展
    mov     ecx, eax                 # 将字符作为putchar的参数

    call    "putchar"                # 输出当前数字字符

.L9:
    cmp     DWORD PTR -4[rbp], 0     # 判断是否还有数字字符没有输出
    jg      .L10                     # 如果还有字符，继续循环输出

.L4:
    add     rsp, 152                 # 释放局部堆栈空间
    pop     rbx                      # 恢复RBX寄存器
    pop     rbp                      # 恢复RBP寄存器
    ret                              # 返回调用位置

.seh_endproc                        # printBigInt函数结束


# ==========================================
# 第三部分：main函数
# 功能：程序入口，负责输入、判断、调用递归函数和输出结果
# ==========================================

.section .rdata,"dr"                # 进入只读数据段，保存字符串常量

.LC0:
    .ascii "Please input n (1-100): \0" # 输入提示字符串

.LC1:
    .ascii "%d\0"                   # scanf使用的整数输入格式

.LC2:
    .ascii "Invalid input!\0"       # 输入错误提示字符串

.LC3:
    .ascii "Fibonacci number: \0"   # 斐波那契结果提示字符串

.text                                # 重新进入代码段

.globl  "main"                       # 声明main函数为全局函数
.def    "main"; .scl 2; .type 32; .endef
.seh_proc "main"                     # 开始main函数

"main":
    push    rbp                      # 保存原来的基址指针
    .seh_pushreg rbp

    mov     rbp, rsp                 # 设置当前函数的基址指针
    .seh_setframe rbp, 0

    sub     rsp, 96                  # 分配96字节局部堆栈空间
    .seh_stackalloc 96
    .seh_endprologue

    call    "__main"                 # 调用GCC运行环境初始化函数

    # 初始化128位整数a和b
    # a=0，b=1

    mov     QWORD PTR -32[rbp], 0    # a的低64位设置为0
    mov     QWORD PTR -24[rbp], 0    # a的高64位设置为0

    mov     QWORD PTR -48[rbp], 1    # b的低64位设置为1
    mov     QWORD PTR -40[rbp], 0    # b的高64位设置为0

    # 输出输入提示

    lea     rax, .LC0[rip]           # 获取输入提示字符串的地址
    mov     rcx, rax                 # 将字符串地址作为printf参数
    call    "printf"                 # 调用printf输出输入提示

    # 获取用户输入的n

    lea     rax, -4[rbp]             # 获取变量n的地址
    lea     rcx, .LC1[rip]           # 获取输入格式字符串地址

    mov     rdx, rax                 # 将n的地址作为scanf第二个参数
    call    "scanf"                  # 调用scanf读取用户输入

    # 判断用户输入是否小于等于0

    mov     eax, DWORD PTR -4[rbp]   # 读取用户输入的n
    test    eax, eax                 # 检查n是否为0
    jle     .L12                     # 如果n小于等于0，跳转到错误处理

    # 判断用户输入是否大于100

    mov     eax, DWORD PTR -4[rbp]   # 再次读取n
    cmp     eax, 100                 # 比较n与100
    jle     .L13                     # 如果n小于等于100，跳转到正常处理

.L12:
    # 输入错误处理

    lea     rax, .LC2[rip]           # 获取错误提示字符串地址
    mov     rcx, rax                 # 设置puts参数
    call    "puts"                   # 输出输入错误提示

    mov     eax, 1                   # 设置程序返回值为1，表示出现错误
    jmp     .L15                     # 跳转到程序结束部分

.L13:
    # 输入合法，调用递归函数fib

    mov     eax, DWORD PTR -4[rbp]   # 读取用户输入的n

    lea     rcx, -48[rbp]            # 获取b的地址
    lea     rdx, -32[rbp]            # 获取a的地址

    mov     r8, rcx                  # 设置第三个参数为b的地址
    mov     ecx, eax                 # 设置第一个参数为n

    call    "fib"                    # 调用fib函数，递归计算斐波那契数

    # 输出结果提示

    lea     rax, .LC3[rip]           # 获取结果提示字符串地址
    mov     rcx, rax                 # 设置printf参数
    call    "printf"                 # 输出结果提示

    # 将计算结果复制到临时存储空间

    mov     rax, QWORD PTR -32[rbp]  # 读取a的低64位
    mov     rdx, QWORD PTR -24[rbp]  # 读取a的高64位

    mov     QWORD PTR -64[rbp], rax  # 保存结果低64位
    mov     QWORD PTR -56[rbp], rdx  # 保存结果高64位

    lea     rax, -64[rbp]            # 获取结果存储空间的地址
    mov     rcx, rax                 # 将结果地址作为函数参数

    call    "printBigInt"            # 调用大整数输出函数

    mov     ecx, 10                  # 设置换行符的ASCII码
    call    "putchar"                # 输出换行符

    mov     eax, 0                   # 设置程序正常退出的返回值为0

.L15:
    add     rsp, 96                  # 释放main函数分配的96字节堆栈空间
    pop     rbp                      # 恢复调用者的基址指针
    ret                              # 返回操作系统

.seh_endproc                         # main函数异常处理信息结束


# ==========================================
# 第四部分：外部函数声明及编译器信息
# ==========================================

.def    "__main"; .scl 2; .type 32; .endef
# GCC运行环境初始化函数

.def    "__udivti3"; .scl 2; .type 32; .endef
# 128位无符号整数除法辅助函数

.def    "__umodti3"; .scl 2; .type 32; .endef
# 128位无符号整数取模辅助函数

.ident  "GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r1) 16.2.0"
# 记录生成该汇编文件的GCC编译器版本

.def    "putchar"; .scl 2; .type 32; .endef
# 声明putchar字符输出函数

.def    "putchar"; .scl 2; .type 32; .endef
# 原始文件中重复出现的putchar声明，保留不变

.def    "printf"; .scl 2; .type 32; .endef
# 声明printf格式化输出函数

.def    "scanf"; .scl 2; .type 32; .endef
# 声明scanf格式化输入函数

.def    "puts"; .scl 2; .type 32; .endef
# 声明puts字符串输出函数
