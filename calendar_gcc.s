	.file	"calendar.c"
	.intel_syntax noprefix
	.text
	.globl	"is_leap_year"
	.def	"is_leap_year";	.scl	2;	.type	32;	.endef
	.seh_proc	"is_leap_year"
"is_leap_year":
	push	rbp
	.seh_pushreg	rbp
	mov	rbp, rsp
	.seh_setframe	rbp, 0
	.seh_endprologue
	mov	DWORD PTR 16[rbp], ecx
	mov	edx, DWORD PTR 16[rbp]
	movsxd	rax, edx
	imul	rax, rax, 1374389535
	shr	rax, 32
	sar	eax, 7
	mov	ecx, edx
	sar	ecx, 31
	sub	eax, ecx
	imul	ecx, eax, 400
	mov	eax, edx
	sub	eax, ecx
	test	eax, eax
	jne	.L2
	mov	eax, 1
	jmp	.L3
.L2:
	mov	edx, DWORD PTR 16[rbp]
	movsxd	rax, edx
	imul	rax, rax, 1374389535
	shr	rax, 32
	sar	eax, 5
	mov	ecx, edx
	sar	ecx, 31
	sub	eax, ecx
	imul	ecx, eax, 100
	mov	eax, edx
	sub	eax, ecx
	test	eax, eax
	jne	.L4
	mov	eax, 0
	jmp	.L3
.L4:
	mov	eax, DWORD PTR 16[rbp]
	and	eax, 3
	test	eax, eax
	jne	.L5
	mov	eax, 1
	jmp	.L3
.L5:
	mov	eax, 0
.L3:
	pop	rbp
	ret
	.seh_endproc
	.globl	"days_in_month"
	.def	"days_in_month";	.scl	2;	.type	32;	.endef
	.seh_proc	"days_in_month"
"days_in_month":
	push	rbp
	.seh_pushreg	rbp
	mov	rbp, rsp
	.seh_setframe	rbp, 0
	sub	rsp, 80
	.seh_stackalloc	80
	.seh_endprologue
	mov	DWORD PTR 16[rbp], ecx
	mov	DWORD PTR 24[rbp], edx
	mov	DWORD PTR -48[rbp], 31
	mov	DWORD PTR -44[rbp], 28
	mov	DWORD PTR -40[rbp], 31
	mov	DWORD PTR -36[rbp], 30
	mov	DWORD PTR -32[rbp], 31
	mov	DWORD PTR -28[rbp], 30
	mov	DWORD PTR -24[rbp], 31
	mov	DWORD PTR -20[rbp], 31
	mov	DWORD PTR -16[rbp], 30
	mov	DWORD PTR -12[rbp], 31
	mov	DWORD PTR -8[rbp], 30
	mov	DWORD PTR -4[rbp], 31
	cmp	DWORD PTR 24[rbp], 2
	jne	.L7
	mov	eax, DWORD PTR 16[rbp]
	mov	ecx, eax
	call	"is_leap_year"
	test	eax, eax
	je	.L7
	mov	eax, 29
	jmp	.L9
.L7:
	mov	eax, DWORD PTR 24[rbp]
	sub	eax, 1
	cdqe
	mov	eax, DWORD PTR -48[rbp+rax*4]
.L9:
	add	rsp, 80
	pop	rbp
	ret
	.seh_endproc
	.globl	"first_weekday"
	.def	"first_weekday";	.scl	2;	.type	32;	.endef
	.seh_proc	"first_weekday"
"first_weekday":
	push	rbp
	.seh_pushreg	rbp
	mov	rbp, rsp
	.seh_setframe	rbp, 0
	sub	rsp, 48
	.seh_stackalloc	48
	.seh_endprologue
	mov	DWORD PTR 16[rbp], ecx
	mov	DWORD PTR 24[rbp], edx
	mov	DWORD PTR -4[rbp], 0
	mov	DWORD PTR -8[rbp], 1900
	jmp	.L11
.L14:
	mov	eax, DWORD PTR -8[rbp]
	mov	ecx, eax
	call	"is_leap_year"
	test	eax, eax
	je	.L12
	add	DWORD PTR -4[rbp], 366
	jmp	.L13
.L12:
	add	DWORD PTR -4[rbp], 365
.L13:
	add	DWORD PTR -8[rbp], 1
.L11:
	mov	eax, DWORD PTR -8[rbp]
	cmp	eax, DWORD PTR 16[rbp]
	jl	.L14
	mov	DWORD PTR -12[rbp], 1
	jmp	.L15
.L16:
	mov	edx, DWORD PTR -12[rbp]
	mov	eax, DWORD PTR 16[rbp]
	mov	ecx, eax
	call	"days_in_month"
	add	DWORD PTR -4[rbp], eax
	add	DWORD PTR -12[rbp], 1
.L15:
	mov	eax, DWORD PTR -12[rbp]
	cmp	eax, DWORD PTR 24[rbp]
	jl	.L16
	mov	eax, DWORD PTR -4[rbp]
	add	eax, 1
	movsxd	rdx, eax
	imul	rdx, rdx, -1840700269
	shr	rdx, 32
	add	edx, eax
	mov	ecx, edx
	sar	ecx, 2
	cdq
	sub	ecx, edx
	mov	edx, ecx
	sal	edx, 3
	sub	edx, ecx
	sub	eax, edx
	mov	ecx, eax
	mov	eax, ecx
	add	rsp, 48
	pop	rbp
	ret
	.seh_endproc
	.section .rdata,"dr"
.LC0:
	.ascii "January\0"
.LC1:
	.ascii "February\0"
.LC2:
	.ascii "March\0"
.LC3:
	.ascii "April\0"
.LC4:
	.ascii "May\0"
.LC5:
	.ascii "June\0"
.LC6:
	.ascii "July\0"
.LC7:
	.ascii "August\0"
.LC8:
	.ascii "September\0"
.LC9:
	.ascii "October\0"
.LC10:
	.ascii "November\0"
.LC11:
	.ascii "December\0"
.LC12:
	.ascii "\12%d %s\12\0"
.LC13:
	.ascii "Su Mo Tu We Th Fr Sa\0"
.LC14:
	.ascii "   \0"
.LC15:
	.ascii "%2d \0"
	.text
	.globl	"print_calendar"
	.def	"print_calendar";	.scl	2;	.type	32;	.endef
	.seh_proc	"print_calendar"
"print_calendar":
	push	rbp
	.seh_pushreg	rbp
	mov	rbp, rsp
	.seh_setframe	rbp, 0
	sub	rsp, 144
	.seh_stackalloc	144
	.seh_endprologue
	mov	DWORD PTR 16[rbp], ecx
	mov	DWORD PTR 24[rbp], edx
	lea	rax, .LC0[rip]
	mov	QWORD PTR -112[rbp], rax
	lea	rax, .LC1[rip]
	mov	QWORD PTR -104[rbp], rax
	lea	rax, .LC2[rip]
	mov	QWORD PTR -96[rbp], rax
	lea	rax, .LC3[rip]
	mov	QWORD PTR -88[rbp], rax
	lea	rax, .LC4[rip]
	mov	QWORD PTR -80[rbp], rax
	lea	rax, .LC5[rip]
	mov	QWORD PTR -72[rbp], rax
	lea	rax, .LC6[rip]
	mov	QWORD PTR -64[rbp], rax
	lea	rax, .LC7[rip]
	mov	QWORD PTR -56[rbp], rax
	lea	rax, .LC8[rip]
	mov	QWORD PTR -48[rbp], rax
	lea	rax, .LC9[rip]
	mov	QWORD PTR -40[rbp], rax
	lea	rax, .LC10[rip]
	mov	QWORD PTR -32[rbp], rax
	lea	rax, .LC11[rip]
	mov	QWORD PTR -24[rbp], rax
	mov	edx, DWORD PTR 24[rbp]
	mov	eax, DWORD PTR 16[rbp]
	mov	ecx, eax
	call	"first_weekday"
	mov	DWORD PTR -12[rbp], eax
	mov	edx, DWORD PTR 24[rbp]
	mov	eax, DWORD PTR 16[rbp]
	mov	ecx, eax
	call	"days_in_month"
	mov	DWORD PTR -16[rbp], eax
	mov	eax, DWORD PTR 24[rbp]
	sub	eax, 1
	cdqe
	mov	rdx, QWORD PTR -112[rbp+rax*8]
	mov	eax, DWORD PTR 16[rbp]
	lea	rcx, .LC12[rip]
	mov	r8, rdx
	mov	edx, eax
	call	"printf"
	lea	rax, .LC13[rip]
	mov	rcx, rax
	call	"puts"
	mov	DWORD PTR -8[rbp], 0
	jmp	.L19
.L20:
	lea	rax, .LC14[rip]
	mov	rcx, rax
	call	"printf"
	add	DWORD PTR -8[rbp], 1
.L19:
	mov	eax, DWORD PTR -8[rbp]
	cmp	eax, DWORD PTR -12[rbp]
	jl	.L20
	mov	DWORD PTR -4[rbp], 1
	jmp	.L21
.L23:
	mov	eax, DWORD PTR -4[rbp]
	lea	rcx, .LC15[rip]
	mov	edx, eax
	call	"printf"
	mov	edx, DWORD PTR -12[rbp]
	mov	eax, DWORD PTR -4[rbp]
	add	eax, edx
	movsxd	rdx, eax
	imul	rdx, rdx, -1840700269
	shr	rdx, 32
	add	edx, eax
	sar	edx, 2
	mov	ecx, eax
	sar	ecx, 31
	sub	edx, ecx
	mov	ecx, edx
	sal	ecx, 3
	sub	ecx, edx
	sub	eax, ecx
	mov	edx, eax
	test	edx, edx
	jne	.L22
	mov	ecx, 10
	call	"putchar"
.L22:
	add	DWORD PTR -4[rbp], 1
.L21:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -16[rbp]
	jle	.L23
	mov	edx, DWORD PTR -12[rbp]
	mov	eax, DWORD PTR -16[rbp]
	add	eax, edx
	movsxd	rdx, eax
	imul	rdx, rdx, -1840700269
	shr	rdx, 32
	add	edx, eax
	sar	edx, 2
	mov	ecx, eax
	sar	ecx, 31
	sub	edx, ecx
	mov	ecx, edx
	sal	ecx, 3
	sub	ecx, edx
	sub	eax, ecx
	mov	edx, eax
	test	edx, edx
	je	.L25
	mov	ecx, 10
	call	"putchar"
.L25:
	nop
	add	rsp, 144
	pop	rbp
	ret
	.seh_endproc
	.section .rdata,"dr"
	.align 8
.LC16:
	.ascii "Please input year (1900-2099): \0"
.LC17:
	.ascii "%d\0"
.LC18:
	.ascii "Invalid input!\0"
.LC19:
	.ascii "Please input month (1-12): \0"
	.text
	.globl	"main"
	.def	"main";	.scl	2;	.type	32;	.endef
	.seh_proc	"main"
"main":
	push	rbp
	.seh_pushreg	rbp
	mov	rbp, rsp
	.seh_setframe	rbp, 0
	sub	rsp, 48
	.seh_stackalloc	48
	.seh_endprologue
	call	"__main"
	lea	rax, .LC16[rip]
	mov	rcx, rax
	call	"printf"
	lea	rax, -4[rbp]
	lea	rcx, .LC17[rip]
	mov	rdx, rax
	call	"scanf"
	cmp	eax, 1
	je	.L27
	lea	rax, .LC18[rip]
	mov	rcx, rax
	call	"puts"
	mov	eax, 1
	jmp	.L34
.L27:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, 1899
	jle	.L29
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, 2099
	jle	.L30
.L29:
	lea	rax, .LC18[rip]
	mov	rcx, rax
	call	"puts"
	mov	eax, 1
	jmp	.L34
.L30:
	lea	rax, .LC19[rip]
	mov	rcx, rax
	call	"printf"
	lea	rax, -8[rbp]
	lea	rcx, .LC17[rip]
	mov	rdx, rax
	call	"scanf"
	cmp	eax, 1
	je	.L31
	lea	rax, .LC18[rip]
	mov	rcx, rax
	call	"puts"
	mov	eax, 1
	jmp	.L34
.L31:
	mov	eax, DWORD PTR -8[rbp]
	test	eax, eax
	jle	.L32
	mov	eax, DWORD PTR -8[rbp]
	cmp	eax, 12
	jle	.L33
.L32:
	lea	rax, .LC18[rip]
	mov	rcx, rax
	call	"puts"
	mov	eax, 1
	jmp	.L34
.L33:
	mov	edx, DWORD PTR -8[rbp]
	mov	eax, DWORD PTR -4[rbp]
	mov	ecx, eax
	call	"print_calendar"
	mov	eax, 0
.L34:
	add	rsp, 48
	pop	rbp
	ret
	.seh_endproc
	.def	"__main";	.scl	2;	.type	32;	.endef
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r1) 16.2.0"
	.def	"printf";	.scl	2;	.type	32;	.endef
	.def	"puts";	.scl	2;	.type	32;	.endef
	.def	"putchar";	.scl	2;	.type	32;	.endef
	.def	"scanf";	.scl	2;	.type	32;	.endef
