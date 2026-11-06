	.file	"fib.c"
	.intel_syntax noprefix
	.text
	.globl	"fib"
	.def	"fib";	.scl	2;	.type	32;	.endef
	.seh_proc	"fib"
"fib":
	push	rbp
	.seh_pushreg	rbp
	push	rbx
	.seh_pushreg	rbx
	sub	rsp, 56
	.seh_stackalloc	56
	lea	rbp, 48[rsp]
	.seh_setframe	rbp, 48
	.seh_endprologue
	mov	DWORD PTR 32[rbp], ecx
	mov	QWORD PTR 40[rbp], rdx
	mov	QWORD PTR 48[rbp], r8
	cmp	DWORD PTR 32[rbp], 0
	jne	.L2
	mov	rax, QWORD PTR 40[rbp]
	mov	QWORD PTR [rax], 0
	mov	QWORD PTR 8[rax], 0
	mov	rax, QWORD PTR 48[rbp]
	mov	QWORD PTR [rax], 1
	mov	QWORD PTR 8[rax], 0
	jmp	.L1
.L2:
	mov	eax, DWORD PTR 32[rbp]
	lea	ecx, -1[rax]
	mov	rdx, QWORD PTR 48[rbp]
	mov	rax, QWORD PTR 40[rbp]
	mov	r8, rdx
	mov	rdx, rax
	call	"fib"
	mov	rax, QWORD PTR 40[rbp]
	mov	rdx, QWORD PTR 8[rax]
	mov	rax, QWORD PTR [rax]
	mov	QWORD PTR -16[rbp], rax
	mov	QWORD PTR -8[rbp], rdx
	mov	rax, QWORD PTR 48[rbp]
	mov	rdx, QWORD PTR 8[rax]
	mov	rax, QWORD PTR [rax]
	mov	rcx, QWORD PTR 40[rbp]
	mov	QWORD PTR [rcx], rax
	mov	QWORD PTR 8[rcx], rdx
	mov	rax, QWORD PTR 48[rbp]
	mov	rcx, QWORD PTR [rax]
	mov	rbx, QWORD PTR 8[rax]
	mov	rax, QWORD PTR -16[rbp]
	mov	rdx, QWORD PTR -8[rbp]
	add	rax, rcx
	adc	rdx, rbx
	mov	rcx, QWORD PTR 48[rbp]
	mov	QWORD PTR [rcx], rax
	mov	QWORD PTR 8[rcx], rdx
.L1:
	add	rsp, 56
	pop	rbx
	pop	rbp
	ret
	.seh_endproc
	.globl	"printBigInt"
	.def	"printBigInt";	.scl	2;	.type	32;	.endef
	.seh_proc	"printBigInt"
"printBigInt":
	push	rbp
	.seh_pushreg	rbp
	push	rbx
	.seh_pushreg	rbx
	sub	rsp, 152
	.seh_stackalloc	152
	lea	rbp, 144[rsp]
	.seh_setframe	rbp, 144
	.seh_endprologue
	mov	rbx, rcx
	mov	rax, QWORD PTR [rbx]
	mov	rdx, QWORD PTR 8[rbx]
	mov	QWORD PTR -64[rbp], rax
	mov	QWORD PTR -56[rbp], rdx
	mov	DWORD PTR -4[rbp], 0
	mov	rax, QWORD PTR -64[rbp]
	or	rax, QWORD PTR -56[rbp]
	jne	.L7
	mov	ecx, 48
	call	"putchar"
	jmp	.L4
.L8:
	mov	rax, QWORD PTR -64[rbp]
	mov	rdx, QWORD PTR -56[rbp]
	lea	rcx, -80[rbp]
	lea	r8, -96[rbp]
	mov	QWORD PTR -80[rbp], rax
	mov	QWORD PTR -72[rbp], rdx
	mov	QWORD PTR -96[rbp], 10
	mov	QWORD PTR -88[rbp], 0
	mov	rdx, r8
	call	"__umodti3"
	movaps	XMMWORD PTR -112[rbp], xmm0
	mov	rax, QWORD PTR -112[rbp]
	mov	rdx, QWORD PTR -104[rbp]
	lea	ecx, 48[rax]
	mov	eax, DWORD PTR -4[rbp]
	lea	edx, 1[rax]
	mov	DWORD PTR -4[rbp], edx
	mov	edx, ecx
	cdqe
	mov	BYTE PTR -48[rbp+rax], dl
	mov	rax, QWORD PTR -64[rbp]
	mov	rdx, QWORD PTR -56[rbp]
	lea	rcx, -80[rbp]
	lea	r8, -96[rbp]
	mov	QWORD PTR -80[rbp], rax
	mov	QWORD PTR -72[rbp], rdx
	mov	QWORD PTR -96[rbp], 10
	mov	QWORD PTR -88[rbp], 0
	mov	rdx, r8
	call	"__udivti3"
	movaps	XMMWORD PTR -64[rbp], xmm0
.L7:
	mov	rax, QWORD PTR -64[rbp]
	or	rax, QWORD PTR -56[rbp]
	jne	.L8
	jmp	.L9
.L10:
	sub	DWORD PTR -4[rbp], 1
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	movzx	eax, BYTE PTR -48[rbp+rax]
	movsx	eax, al
	mov	ecx, eax
	call	"putchar"
.L9:
	cmp	DWORD PTR -4[rbp], 0
	jg	.L10
.L4:
	add	rsp, 152
	pop	rbx
	pop	rbp
	ret
	.seh_endproc
	.section .rdata,"dr"
.LC0:
	.ascii "Please input n (1-100): \0"
.LC1:
	.ascii "%d\0"
.LC2:
	.ascii "Invalid input!\0"
.LC3:
	.ascii "Fibonacci number: \0"
	.text
	.globl	"main"
	.def	"main";	.scl	2;	.type	32;	.endef
	.seh_proc	"main"
"main":
	push	rbp
	.seh_pushreg	rbp
	mov	rbp, rsp
	.seh_setframe	rbp, 0
	sub	rsp, 96
	.seh_stackalloc	96
	.seh_endprologue
	call	"__main"
	mov	QWORD PTR -32[rbp], 0
	mov	QWORD PTR -24[rbp], 0
	mov	QWORD PTR -48[rbp], 1
	mov	QWORD PTR -40[rbp], 0
	lea	rax, .LC0[rip]
	mov	rcx, rax
	call	"printf"
	lea	rax, -4[rbp]
	lea	rcx, .LC1[rip]
	mov	rdx, rax
	call	"scanf"
	mov	eax, DWORD PTR -4[rbp]
	test	eax, eax
	jle	.L12
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, 100
	jle	.L13
.L12:
	lea	rax, .LC2[rip]
	mov	rcx, rax
	call	"puts"
	mov	eax, 1
	jmp	.L15
.L13:
	mov	eax, DWORD PTR -4[rbp]
	lea	rcx, -48[rbp]
	lea	rdx, -32[rbp]
	mov	r8, rcx
	mov	ecx, eax
	call	"fib"
	lea	rax, .LC3[rip]
	mov	rcx, rax
	call	"printf"
	mov	rax, QWORD PTR -32[rbp]
	mov	rdx, QWORD PTR -24[rbp]
	mov	QWORD PTR -64[rbp], rax
	mov	QWORD PTR -56[rbp], rdx
	lea	rax, -64[rbp]
	mov	rcx, rax
	call	"printBigInt"
	mov	ecx, 10
	call	"putchar"
	mov	eax, 0
.L15:
	add	rsp, 96
	pop	rbp
	ret
	.seh_endproc
	.def	"__main";	.scl	2;	.type	32;	.endef
	.def	"__udivti3";	.scl	2;	.type	32;	.endef
	.def	"__umodti3";	.scl	2;	.type	32;	.endef
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r1) 16.2.0"
	.def	"putchar";	.scl	2;	.type	32;	.endef
	.def	"putchar";	.scl	2;	.type	32;	.endef
	.def	"printf";	.scl	2;	.type	32;	.endef
	.def	"scanf";	.scl	2;	.type	32;	.endef
	.def	"puts";	.scl	2;	.type	32;	.endef
