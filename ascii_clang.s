	.def	@feat.00;
	.scl	3;
	.type	0;
	.endef
	.globl	@feat.00
@feat.00 = 0
	.intel_syntax noprefix
	.file	"ascii.c"
	.def	main;
	.scl	2;
	.type	32;
	.endef
	.text
	.globl	main                            # -- Begin function main
	.p2align	4
main:                                   # @main
.seh_proc main
# %bb.0:
	push	rbp
	.seh_pushreg rbp
	sub	rsp, 48
	.seh_stackalloc 48
	lea	rbp, [rsp + 48]
	.seh_setframe rbp, 48
	.seh_endprologue
	call	__main
	mov	dword ptr [rbp - 4], 0
	mov	byte ptr [rbp - 5], 97
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	movsx	eax, byte ptr [rbp - 5]
	cmp	eax, 122
	jg	.LBB0_6
# %bb.2:                                #   in Loop: Header=BB0_1 Depth=1
	movsx	edx, byte ptr [rbp - 5]
	lea	rcx, [rip + .L.str]
	call	printf
	movsx	eax, byte ptr [rbp - 5]
	sub	eax, 97
	add	eax, 1
	mov	ecx, 13
	cdq
	idiv	ecx
	cmp	edx, 0
	jne	.LBB0_4
# %bb.3:                                #   in Loop: Header=BB0_1 Depth=1
	lea	rcx, [rip + .L.str.1]
	call	printf
.LBB0_4:                                #   in Loop: Header=BB0_1 Depth=1
	jmp	.LBB0_5
.LBB0_5:                                #   in Loop: Header=BB0_1 Depth=1
	mov	al, byte ptr [rbp - 5]
	add	al, 1
	mov	byte ptr [rbp - 5], al
	jmp	.LBB0_1
.LBB0_6:
	xor	eax, eax
	.seh_startepilogue
	add	rsp, 48
	pop	rbp
	.seh_endepilogue
	ret
	.seh_endproc
                                        # -- End function
	.section	.rdata,"dr"
.L.str:                                 # @.str
	.asciz	"%c "

.L.str.1:                               # @.str.1
	.asciz	"\n"

	.section	.debug$S,"dr"
	.p2align	2, 0x0
	.long	4                               # Debug section magic
	.long	241
	.long	.Ltmp1-.Ltmp0                   # Subsection size
.Ltmp0:
	.short	.Ltmp3-.Ltmp2                   # Record length
.Ltmp2:
	.short	4353                            # Record kind: S_OBJNAME
	.long	0                               # Signature
	.byte	0                               # Object name
	.p2align	2, 0x0
.Ltmp3:
	.short	.Ltmp5-.Ltmp4                   # Record length
.Ltmp4:
	.short	4412                            # Record kind: S_COMPILE3
	.long	0                               # Flags and language
	.short	208                             # CPUType
	.short	23                              # Frontend version
	.short	1
	.short	3
	.short	0
	.short	23013                           # Backend version
	.short	0
	.short	0
	.short	0
	.asciz	"clang version 23.1.3 (https://github.com/llvm/llvm-project 0d261d1ca552c95a8f007e061c787ac7132fbcbc)" # Null-terminated compiler version string
	.p2align	2, 0x0
.Ltmp5:
.Ltmp1:
	.p2align	2, 0x0
	.addrsig
	.addrsig_sym printf
