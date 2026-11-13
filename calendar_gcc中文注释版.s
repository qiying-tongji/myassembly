.file	"calendar.c"
	.intel_syntax noprefix             # 使用 Intel 汇编语法（目的操作数在前）
	.text                              # 进入代码段

	.globl	"is_leap_year"               # 声明函数为全局符号，供其他文件调用
	.def	"is_leap_year";	.scl	2;	.type	32;	.endef
	.seh_proc	"is_leap_year"             # Windows x64 异常处理/栈展开信息开始
"is_leap_year":
	push	rbp                          # 保存调用者的栈帧指针
	.seh_pushreg	rbp
	mov	rbp, rsp                       # 建立当前函数的栈帧
	.seh_setframe	rbp, 0
	.seh_endprologue
	mov	DWORD PTR 16[rbp], ecx         # 保存第一个参数 year（Windows x64 下由 ECX 传入）
	mov	edx, DWORD PTR 16[rbp]         # EDX = year
	movsxd	rax, edx                      # 将 year 符号扩展为 64 位
	imul	rax, rax, 1374389535           # 乘以常数，用于编译器优化的除法运算
	shr	rax, 32                        # 取乘积高 32 位
	sar	eax, 7                         # 算术右移，得到 year / 400 的商（优化形式）
	mov	ecx, edx                       # ECX = year
	sar	ecx, 31                        # 根据符号位生成符号修正值
	sub	eax, ecx                       # 修正除法结果
	imul	ecx, eax, 400                  # ECX = (year / 400) * 400
	mov	eax, edx                       # EAX = year
	sub	eax, ecx                       # EAX = year % 400
	test	eax, eax                       # 检查余数是否为 0
	jne	.L2                            # 不为 0，继续判断是否能被 100 整除
	mov	eax, 1                         # 能被 400 整除，是闰年，返回 1
	jmp	.L3                            # 跳到函数统一返回位置
.L2:
	mov	edx, DWORD PTR 16[rbp]         # 重新取出 year
	movsxd	rax, edx                      # 符号扩展为 64 位
	imul	rax, rax, 1374389535           # 乘以除法优化常数
	shr	rax, 32                        # 取乘积高 32 位
	sar	eax, 5                         # 得到 year / 100 的商（优化形式）
	mov	ecx, edx                       # 保存 year
	sar	ecx, 31                        # 生成符号修正值
	sub	eax, ecx                       # 修正商
	imul	ecx, eax, 100                  # ECX = (year / 100) * 100
	mov	eax, edx                       # EAX = year
	sub	eax, ecx                       # EAX = year % 100
	test	eax, eax                       # 检查是否能被 100 整除
	jne	.L4                            # 不能被 100 整除，继续判断能否被 4 整除
	mov	eax, 0                         # 能被 100 整除但不能被 400 整除，不是闰年
	jmp	.L3                            # 跳到统一返回位置
.L4:
	mov	eax, DWORD PTR 16[rbp]         # 取出 year
	and	eax, 3                         # year & 3，等价于检查 year 除以 4 的余数
	test	eax, eax                       # 检查结果是否为 0
	jne	.L5                            # 不为 0，不能被 4 整除
	mov	eax, 1                         # 能被 4 整除且不能被 100 整除，是闰年
	jmp	.L3                            # 跳到统一返回位置
.L5:
	mov	eax, 0                         # 不能被 4 整除，不是闰年
.L3:
	pop	rbp                            # 恢复调用者的栈帧指针
	ret                                  # 返回，EAX 中保存函数返回值
	.seh_endproc                         # 函数异常处理信息结束

	.globl	"days_in_month"                # 声明 days_in_month 为全局函数
	.def	"days_in_month";	.scl	2;	.type	32;	.endef
	.seh_proc	"days_in_month"
"days_in_month":
	push	rbp                            # 保存旧栈帧指针
	.seh_pushreg	rbp
	mov	rbp, rsp                         # 建立栈帧
	.seh_setframe	rbp, 0
	sub	rsp, 80                          # 为局部变量和调用预留 80 字节栈空间
	.seh_stackalloc	80
	.seh_endprologue
	mov	DWORD PTR 16[rbp], ecx           # 保存第一个参数 year
	mov	DWORD PTR 24[rbp], edx           # 保存第二个参数 month
	mov	DWORD PTR -48[rbp], 31           # monthDays[0]：1 月有 31 天
	mov	DWORD PTR -44[rbp], 28           # monthDays[1]：2 月平年有 28 天
	mov	DWORD PTR -40[rbp], 31           # 3 月有 31 天
	mov	DWORD PTR -36[rbp], 30           # 4 月有 30 天
	mov	DWORD PTR -32[rbp], 31           # 5 月有 31 天
	mov	DWORD PTR -28[rbp], 30           # 6 月有 30 天
	mov	DWORD PTR -24[rbp], 31           # 7 月有 31 天
	mov	DWORD PTR -20[rbp], 31           # 8 月有 31 天
	mov	DWORD PTR -16[rbp], 30           # 9 月有 30 天
	mov	DWORD PTR -12[rbp], 31           # 10 月有 31 天
	mov	DWORD PTR -8[rbp], 30            # 11 月有 30 天
	mov	DWORD PTR -4[rbp], 31            # 12 月有 31 天
	cmp	DWORD PTR 24[rbp], 2             # 判断月份是否为 2 月
	jne	.L7                              # 不是 2 月，直接从数组取天数
	mov	eax, DWORD PTR 16[rbp]           # EAX = year
	mov	ecx, eax                         # 将 year 作为参数传入 ECX
	call	"is_leap_year"                   # 调用闰年判断函数
	test	eax, eax                         # 检查返回值
	je	.L7                              # 返回 0，说明不是闰年
	mov	eax, 29                          # 2 月且为闰年，返回 29 天
	jmp	.L9                              # 跳到函数结尾
.L7:
	mov	eax, DWORD PTR 24[rbp]           # EAX = month
	sub	eax, 1                           # 月份从 1 开始，数组下标从 0 开始，因此减 1
	cdqe                                  # 将 EAX 符号扩展到 RAX，作为 64 位数组索引
	mov	eax, DWORD PTR -48[rbp+rax*4]    # 从 monthDays 数组取出对应月份的天数
.L9:
	add	rsp, 80                          # 释放局部变量栈空间
	pop	rbp                              # 恢复栈帧指针
	ret                                    # 返回天数（EAX）
	.seh_endproc

	.globl	"first_weekday"                  # 声明 first_weekday 为全局函数
	.def	"first_weekday";	.scl	2;	.type	32;	.endef
	.seh_proc	"first_weekday"
"first_weekday":
	push	rbp                              # 保存旧栈帧指针
	.seh_pushreg	rbp
	mov	rbp, rsp                           # 建立栈帧
	.seh_setframe	rbp, 0
	sub	rsp, 48                            # 为局部变量预留栈空间
	.seh_stackalloc	48
	.seh_endprologue
	mov	DWORD PTR 16[rbp], ecx             # 保存 year 参数
	mov	DWORD PTR 24[rbp], edx             # 保存 month 参数
	mov	DWORD PTR -4[rbp], 0               # totalDays = 0，累计目标日期之前的天数
	mov	DWORD PTR -8[rbp], 1900            # 当前年份从 1900 年开始
	jmp	.L11                               # 先跳到循环条件判断
.L14:
	mov	eax, DWORD PTR -8[rbp]             # EAX = 当前年份
	mov	ecx, eax                           # 将当前年份作为参数
	call	"is_leap_year"                     # 判断当前年份是否为闰年
	test	eax, eax                           # 检查返回值
	je	.L12                               # 不是闰年，累计 365 天
	add	DWORD PTR -4[rbp], 366             # 闰年累计 366 天
	jmp	.L13                               # 跳过平年分支
.L12:
	add	DWORD PTR -4[rbp], 365             # 平年累计 365 天
.L13:
	add	DWORD PTR -8[rbp], 1               # year++，处理下一年
.L11:
	mov	eax, DWORD PTR -8[rbp]             # EAX = 当前年份
	cmp	eax, DWORD PTR 16[rbp]             # 比较当前年份和目标年份
	jl	.L14                               # 当前年份小于目标年份，继续累计
	mov	DWORD PTR -12[rbp], 1              # monthIndex = 1，从 1 月开始
	jmp	.L15                               # 跳到月份循环条件
.L16:
	mov	edx, DWORD PTR -12[rbp]            # EDX = 当前月份
	mov	eax, DWORD PTR 16[rbp]             # EAX = 目标年份
	mov	ecx, eax                           # 第一个参数 year 放入 ECX
	call	"days_in_month"                    # 获取当前月份的天数
	add	DWORD PTR -4[rbp], eax             # 将该月天数累加到 totalDays
	add	DWORD PTR -12[rbp], 1              # monthIndex++，处理下一个月
.L15:
	mov	eax, DWORD PTR -12[rbp]            # EAX = 当前月份
	cmp	eax, DWORD PTR 24[rbp]             # 与目标月份比较
	jl	.L16                               # 当前月份小于目标月份，继续累计
	mov	eax, DWORD PTR -4[rbp]             # EAX = 目标月份之前累计的总天数
	add	eax, 1                             # 加 1，得到目标月份第一天相对基准日的偏移
	movsxd	rdx, eax                          # 符号扩展到 64 位
	imul	rdx, rdx, -1840700269              # 乘以魔数，编译器用乘法优化除以 7
	shr	rdx, 32                            # 取乘积高 32 位
	add	edx, eax                           # 调整中间结果
	mov	ecx, edx                           # 复制中间结果
	sar	ecx, 2                             # 算术右移，继续计算除以 7 的商
	cdq                                    # 将 EAX 符号扩展到 EDX:EAX
	sub	ecx, edx                           # 修正商
	mov	edx, ecx                           # 保存商
	sal	edx, 3                             # 商乘以 8
	sub	edx, ecx                           # 再减去商，得到商乘以 7
	sub	eax, edx                           # EAX = 总天数对 7 取余
	mov	ecx, eax                           # 将星期编号放入 ECX
	mov	eax, ecx                           # 返回值放入 EAX
	add	rsp, 48                            # 释放局部变量栈空间
	pop	rbp                                # 恢复栈帧指针
	ret                                      # 返回星期编号
	.seh_endproc

	.section .rdata,"dr"                     # 进入只读数据段
.LC0:
	.ascii "January\0"                       # 1 月英文名称
.LC1:
	.ascii "February\0"                      # 2 月英文名称
.LC2:
	.ascii "March\0"                         # 3 月英文名称
.LC3:
	.ascii "April\0"                         # 4 月英文名称
.LC4:
	.ascii "May\0"                           # 5 月英文名称
.LC5:
	.ascii "June\0"                          # 6 月英文名称
.LC6:
	.ascii "July\0"                          # 7 月英文名称
.LC7:
	.ascii "August\0"                        # 8 月英文名称
.LC8:
	.ascii "September\0"                     # 9 月英文名称
.LC9:
	.ascii "October\0"                       # 10 月英文名称
.LC10:
	.ascii "November\0"                      # 11 月英文名称
.LC11:
	.ascii "December\0"                      # 12 月英文名称
.LC12:
	.ascii "\12%d %s\12\0"                   # 格式字符串：换行、输出年份和月份名称、再换行
.LC13:
	.ascii "Su Mo Tu We Th Fr Sa\0"           # 星期标题：周日到周六
.LC14:
	.ascii "   \0"                            # 日期前的空白，用于对齐星期
.LC15:
	.ascii "%2d \0"                           # 日期格式：占 2 位，后跟一个空格

	.text                                    # 重新进入代码段
	.globl	"print_calendar"                 # 声明打印日历函数为全局符号
	.def	"print_calendar";	.scl	2;	.type	32;	.endef
	.seh_proc	"print_calendar"
"print_calendar":
	push	rbp                                # 保存旧栈帧指针
	.seh_pushreg	rbp
	mov	rbp, rsp                             # 建立栈帧
	.seh_setframe	rbp, 0
	sub	rsp, 144                              # 为局部变量、月份名称数组和调用预留空间
	.seh_stackalloc	144
	.seh_endprologue
	mov	DWORD PTR 16[rbp], ecx               # 保存 year 参数
	mov	DWORD PTR 24[rbp], edx               # 保存 month 参数
	lea	rax, .LC0[rip]                       # RAX 指向 January 字符串
	mov	QWORD PTR -112[rbp], rax             # monthNames[0] = January
	lea	rax, .LC1[rip]                       # RAX 指向 February
	mov	QWORD PTR -104[rbp], rax             # monthNames[1] = February
	lea	rax, .LC2[rip]                       # RAX 指向 March
	mov	QWORD PTR -96[rbp], rax              # monthNames[2] = March
	lea	rax, .LC3[rip]                       # RAX 指向 April
	mov	QWORD PTR -88[rbp], rax              # monthNames[3] = April
	lea	rax, .LC4[rip]                       # RAX 指向 May
	mov	QWORD PTR -80[rbp], rax              # monthNames[4] = May
	lea	rax, .LC5[rip]                       # RAX 指向 June
	mov	QWORD PTR -72[rbp], rax              # monthNames[5] = June
	lea	rax, .LC6[rip]                       # RAX 指向 July
	mov	QWORD PTR -64[rbp], rax              # monthNames[6] = July
	lea	rax, .LC7[rip]                       # RAX 指向 August
	mov	QWORD PTR -56[rbp], rax              # monthNames[7] = August
	lea	rax, .LC8[rip]                       # RAX 指向 September
	mov	QWORD PTR -48[rbp], rax              # monthNames[8] = September
	lea	rax, .LC9[rip]                       # RAX 指向 October
	mov	QWORD PTR -40[rbp], rax              # monthNames[9] = October
	lea	rax, .LC10[rip]                      # RAX 指向 November
	mov	QWORD PTR -32[rbp], rax              # monthNames[10] = November
	lea	rax, .LC11[rip]                      # RAX 指向 December
	mov	QWORD PTR -24[rbp], rax              # monthNames[11] = December
	mov	edx, DWORD PTR 24[rbp]               # EDX = month
	mov	eax, DWORD PTR 16[rbp]               # EAX = year
	mov	ecx, eax                             # year 作为第一个参数传入 ECX
	call	"first_weekday"                     # 计算该月第一天是星期几
	mov	DWORD PTR -12[rbp], eax              # firstDay = 返回的星期编号
	mov	edx, DWORD PTR 24[rbp]               # EDX = month
	mov	eax, DWORD PTR 16[rbp]               # EAX = year
	mov	ecx, eax                             # year 作为第一个参数
	call	"days_in_month"                     # 计算该月总天数
	mov	DWORD PTR -16[rbp], eax              # totalDays = 当月天数
	mov	eax, DWORD PTR 24[rbp]               # EAX = month
	sub	eax, 1                               # 转换为从 0 开始的数组下标
	cdqe                                      # 扩展数组下标到 64 位
	mov	rdx, QWORD PTR -112[rbp+rax*8]       # RDX = 对应月份名称字符串地址
	mov	eax, DWORD PTR 16[rbp]               # EAX = year
	lea	rcx, .LC12[rip]                      # RCX = printf 的格式字符串
	mov	r8, rdx                               # 第三个参数：月份名称
	mov	edx, eax                              # 第二个参数：年份
	call	"printf"                             # 输出年份和月份名称
	lea	rax, .LC13[rip]                      # RAX 指向星期标题字符串
	mov	rcx, rax                              # RCX = 字符串参数
	call	"puts"                               # 输出星期标题并换行
	mov	DWORD PTR -8[rbp], 0                 # i = 0，准备输出月初空白
	jmp	.L19                                 # 跳转到空白循环条件
.L20:
	lea	rax, .LC14[rip]                      # RAX 指向三个空格
	mov	rcx, rax                              # RCX = 字符串参数
	call	"printf"                             # 输出空白，为 1 号日期留出星期位置
	add	DWORD PTR -8[rbp], 1                 # i++
.L19:
	mov	eax, DWORD PTR -8[rbp]               # EAX = 当前空白数量
	cmp	eax, DWORD PTR -12[rbp]              # 与当月第一天的星期编号比较
	jl	.L20                                 # 未达到第一天所在列，继续输出空白
	mov	DWORD PTR -4[rbp], 1                 # day = 1，从每月 1 号开始输出
	jmp	.L21                                 # 跳到日期循环条件
.L23:
	mov	eax, DWORD PTR -4[rbp]               # EAX = 当前日期 day
	lea	rcx, .LC15[rip]                      # RCX = "%2d " 格式字符串
	mov	edx, eax                              # EDX = 要输出的日期
	call	"printf"                             # 输出当前日期
	mov	edx, DWORD PTR -12[rbp]              # EDX = 当月第一天的星期编号
	mov	eax, DWORD PTR -4[rbp]               # EAX = 当前日期
	add	eax, edx                              # 当前日期对应的累计列位置
	movsxd	rdx, eax                             # 扩展为 64 位
	imul	rdx, rdx, -1840700269                # 编译器用乘法优化计算除以 7
	shr	rdx, 32                               # 取乘积高位
	add	edx, eax                              # 调整中间结果
	sar	edx, 2                                # 算术右移，得到商的中间值
	mov	ecx, eax                              # 保存原始值
	sar	ecx, 31                               # 生成符号修正值
	sub	edx, ecx                              # 修正除法商
	mov	ecx, edx                              # ECX = 商
	sal	ecx, 3                                # 商乘以 8
	sub	ecx, edx                              # 减去商，得到商乘以 7
	sub	eax, ecx                              # EAX = 列位置对 7 取余
	mov	edx, eax                              # EDX = 余数
	test	edx, edx                              # 检查余数是否为 0（到达周末行尾）
	jne	.L22                                 # 不是行尾，不换行
	mov	ecx, 10                               # putchar 参数为换行符 ASCII 码 10
	call	"putchar"                             # 输出换行
.L22:
	add	DWORD PTR -4[rbp], 1                 # day++，处理下一天
.L21:
	mov	eax, DWORD PTR -4[rbp]               # EAX = 当前日期
	cmp	eax, DWORD PTR -16[rbp]              # 与当月总天数比较
	jle	.L23                                 # 当前日期不超过月末，继续输出
	mov	edx, DWORD PTR -12[rbp]              # EDX = 当月第一天星期编号
	mov	eax, DWORD PTR -16[rbp]              # EAX = 当月总天数
	add	eax, edx                              # 计算最后一天所在的列位置
	movsxd	rdx, eax                             # 扩展到 64 位
	imul	rdx, rdx, -1840700269                # 乘法优化计算除以 7
	shr	rdx, 32                               # 取乘积高位
	add	edx, eax                              # 调整中间结果
	sar	edx, 2                                # 算术右移
	mov	ecx, eax                              # 保存原始值
	sar	ecx, 31                               # 生成符号修正值
	sub	edx, ecx                              # 修正商
	mov	ecx, edx                              # ECX = 商
	sal	ecx, 3                                # 商乘以 8
	sub	ecx, edx                              # 得到商乘以 7
	sub	eax, ecx                              # EAX = 最后一天列位置对 7 取余
	mov	edx, eax                              # EDX = 余数
	test	edx, edx                              # 余数为 0 表示最后一天正好在周六
	je	.L25                                 # 已经换过行，不需要再换行
	mov	ecx, 10                               # 否则准备输出换行符
	call	"putchar"                             # 输出最后一行的换行
.L25:
	nop                                        # 空操作，仅作为代码位置标记
	add	rsp, 144                              # 释放局部变量栈空间
	pop	rbp                                  # 恢复栈帧指针
	ret                                        # 返回
	.seh_endproc

	.section .rdata,"dr"                       # 只读数据段，存放输入提示和格式字符串
	.align 8
.LC16:
	.ascii "Please input year (1900-2099): \0" # 年份输入提示
.LC17:
	.ascii "%d\0"                              # scanf 的整数输入格式
.LC18:
	.ascii "Invalid input!\0"                  # 输入错误提示
.LC19:
	.ascii "Please input month (1-12): \0"     # 月份输入提示

	.text                                      # 进入代码段
	.globl	"main"                             # 声明主函数
	.def	"main";	.scl	2;	.type	32;	.endef
	.seh_proc	"main"
"main":
	push	rbp                                  # 保存旧栈帧指针
	.seh_pushreg	rbp
	mov	rbp, rsp                               # 建立主函数栈帧
	.seh_setframe	rbp, 0
	sub	rsp, 48                                # 分配栈空间，存放局部变量并满足调用约定
	.seh_stackalloc	48
	.seh_endprologue
	call	"__main"                              # MinGW/GCC 运行时初始化
	lea	rax, .LC16[rip]                        # RAX 指向年份输入提示
	mov	rcx, rax                                # RCX = 提示字符串
	call	"printf"                               # 输出年份输入提示
	lea	rax, -4[rbp]                           # RAX 指向局部变量 year 的地址
	lea	rcx, .LC17[rip]                        # RCX 指向 "%d"
	mov	rdx, rax                                # scanf 第二个参数：year 地址
	call	"scanf"                                # 读取年份
	cmp	eax, 1                                 # scanf 成功读取的项目数是否为 1
	je	.L27                                   # 成功则继续检查范围
	lea	rax, .LC18[rip]                        # RAX 指向错误提示
	mov	rcx, rax                                # RCX = 错误提示字符串
	call	"puts"                                 # 输出错误提示
	mov	eax, 1                                 # 设置 main 返回值为 1，表示失败
	jmp	.L34                                   # 跳到主函数结尾
.L27:
	mov	eax, DWORD PTR -4[rbp]                 # EAX = 输入的年份
	cmp	eax, 1899                              # 比较年份是否小于等于 1899
	jle	.L29                                   # 小于等于 1899，输入非法
	mov	eax, DWORD PTR -4[rbp]                 # 再次取出年份
	cmp	eax, 2099                              # 比较年份是否不大于 2099
	jle	.L30                                   # 在允许范围内，继续输入月份
.L29:
	lea	rax, .LC18[rip]                        # RAX 指向错误提示
	mov	rcx, rax                                # RCX = 错误提示字符串
	call	"puts"                                 # 输出错误提示
	mov	eax, 1                                 # main 返回 1
	jmp	.L34                                   # 结束程序
.L30:
	lea	rax, .LC19[rip]                        # RAX 指向月份输入提示
	mov	rcx, rax                                # RCX = 提示字符串
	call	"printf"                               # 输出月份输入提示
	lea	rax, -8[rbp]                           # RAX 指向局部变量 month 的地址
	lea	rcx, .LC17[rip]                        # RCX 指向 "%d"
	mov	rdx, rax                                # scanf 第二个参数：month 地址
	call	"scanf"                                # 读取月份
	cmp	eax, 1                                 # 检查是否成功读取一个整数
	je	.L31                                   # 成功则检查月份范围
	lea	rax, .LC18[rip]                        # RAX 指向错误提示
	mov	rcx, rax                                # RCX = 错误提示字符串
	call	"puts"                                 # 输出错误提示
	mov	eax, 1                                 # main 返回 1
	jmp	.L34                                   # 结束程序
.L31:
	mov	eax, DWORD PTR -8[rbp]                 # EAX = 输入的月份
	test	eax, eax                               # 检查月份是否为 0
	jle	.L32                                   # 小于等于 0，输入非法
	mov	eax, DWORD PTR -8[rbp]                 # 再次取出月份
	cmp	eax, 12                                # 检查月份是否大于 12
	jle	.L33                                   # 1～12 范围内，调用日历打印函数
.L32:
	lea	rax, .LC18[rip]                        # RAX 指向错误提示
	mov	rcx, rax                                # RCX = 错误提示字符串
	call	"puts"                                 # 输出错误提示
	mov	eax, 1                                 # main 返回 1
	jmp	.L34                                   # 跳到函数结尾
.L33:
	mov	edx, DWORD PTR -8[rbp]                 # EDX = month，作为第二个参数
	mov	eax, DWORD PTR -4[rbp]                 # EAX = year
	mov	ecx, eax                                # ECX = year，作为第一个参数
	call	"print_calendar"                      # 调用日历输出函数
	mov	eax, 0                                 # 正常结束，main 返回 0
.L34:
	add	rsp, 48                                # 释放主函数栈空间
	pop	rbp                                   # 恢复调用者栈帧指针
	ret                                         # 返回操作系统
	.seh_endproc

	.def	"__main";	.scl	2;	.type	32;	.endef
	.def	"printf";	.scl	2;	.type	32;	.endef
	.def	"puts";	.scl	2;	.type	32;	.endef
	.def	"putchar";	.scl	2;	.type	32;	.endef
	.def	"scanf";	.scl	2;	.type	32;	.endef
