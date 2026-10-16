
	.file	"sum.c"                  # 源文件名称
	.intel_syntax noprefix          # 使用 Intel 汇编语法
	.text                           # 开始代码段
	.section .rdata,"dr"             # 定义只读数据段
.LC0:
	.ascii "%d\12\0"                 # 定义输出格式字符串：整数加换行符
	.text
	.globl	"main"                   # 声明 main 为全局符号
	.def	"main";	.scl	2;	.type	32;	.endef
	.seh_proc	"main"               # 开始定义 main 函数的异常处理信息
"main":
	push	rbp                      # 保存原来的基址指针
	.seh_pushreg	rbp
	mov	rbp, rsp                  # 建立当前函数的栈帧
	.seh_setframe	rbp, 0
	sub	rsp, 48                   # 在栈上分配 48 字节空间
	.seh_stackalloc	48
	.seh_endprologue
	call	"__main"                 # 初始化运行环境
	mov	DWORD PTR -4[rbp], 0      # 将局部变量 sum 初始化为 0
	mov	DWORD PTR -8[rbp], 1      # 将局部变量 i 初始化为 1
	jmp	.L2                       # 跳转到循环条件判断处

.L3:
	mov	eax, DWORD PTR -8[rbp]    # 将变量 i 的值读入 EAX 寄存器
	add	DWORD PTR -4[rbp], eax    # sum = sum + i，将 i 累加到 sum
	add	DWORD PTR -8[rbp], 1      # i = i + 1，循环变量加 1

.L2:
	cmp	DWORD PTR -8[rbp], 100    # 比较 i 和 100
	jle	.L3                       # 如果 i <= 100，则跳转到 .L3 执行循环体

	mov	eax, DWORD PTR -4[rbp]    # 将最终求和结果 sum 读入 EAX
	lea	rcx, .LC0[rip]            # 将格式字符串 "%d\n" 的地址放入 RCX
	mov	edx, eax                  # 将求和结果作为 printf 的第二个参数
	call	"printf"                 # 调用 printf，输出求和结果

	mov	eax, 0                    # 将返回值设为 0，表示程序正常结束
	add	rsp, 48                   # 释放之前分配的 48 字节栈空间
	pop	rbp                       # 恢复原来的基址指针
	ret                            # 返回调用者
	.seh_endproc                    # 结束 main 函数的异常处理信息

	.def	"__main";	.scl	2;	.type	32;	.endef
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r1) 16.2.0"
	.def	"printf";	.scl	2;	.type	32;	.endef
