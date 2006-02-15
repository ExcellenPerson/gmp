dnl  AMD64 mpn_addmul_1 -- Multiply a limb vector with a limb and add the
dnl  result to a second limb vector.

dnl  Copyright 2003, 2004, 2005 Free Software Foundation, Inc.

dnl  This file is part of the GNU MP Library.

dnl  The GNU MP Library is free software; you can redistribute it and/or modify
dnl  it under the terms of the GNU Lesser General Public License as published
dnl  by the Free Software Foundation; either version 2.1 of the License, or (at
dnl  your option) any later version.

dnl  The GNU MP Library is distributed in the hope that it will be useful, but
dnl  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
dnl  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
dnl  License for more details.

dnl  You should have received a copy of the GNU Lesser General Public License
dnl  along with the GNU MP Library; see the file COPYING.LIB.  If not, write to
dnl  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
dnl  MA 02110-1301, USA.

include(`../config.m4')


C		    cycles/limb
C Hammer:		3.25
C Prescott/Nocona:	15.5-17 (fluctuating due to w/c buffer problems)

C TODO
C  * Perhaps make this use the algorithm of mul_1.asm.


C INPUT PARAMETERS
C rp	rdi
C up	rsi
C n	rdx
C vl	rcx

	TEXT
	ALIGN(16)
	.byte	0,0			C this aligns the loop
ASM_START()
PROLOGUE(mpn_addmul_1)
	movq	%rdx, %r11
	leaq	(%rsi,%rdx,8), %rsi
	leaq	(%rdi,%rdx,8), %rdi
	negq	%r11
	xorl	%r8d, %r8d		C clear carry limb
	xorl	%r10d, %r10d		C keep r10 zero
	addq	$3, %r11
	jb	.Ltail			C jump for n = 1, 2, 3

.Loop:	movq	-24(%rsi,%r11,8), %rax
	mulq	%rcx
	addq	-24(%rdi,%r11,8), %rax
	adcq	%r10, %rdx
	addq	%r8, %rax
	movq	%rax, -24(%rdi,%r11,8)
	movq	%r10, %r8
	adcq	%rdx, %r8

	movq	-16(%rsi,%r11,8), %rax
	mulq	%rcx
	addq	-16(%rdi,%r11,8), %rax
	adcq	%r10, %rdx
	addq	%r8, %rax
	movq	%r10, %r8
	movq	%rax, -16(%rdi,%r11,8)
	adcq	%rdx, %r8

	movq	-8(%rsi,%r11,8), %rax
	mulq	%rcx
	addq	-8(%rdi,%r11,8), %rax
	adcq	%r10, %rdx
	addq	%r8, %rax
	movq	%r10, %r8
	movq	%rax, -8(%rdi,%r11,8)
	adcq	%rdx, %r8

	movq	(%rsi,%r11,8), %rax
	mulq	%rcx
	addq	(%rdi,%r11,8), %rax
	adcq	%r10, %rdx
	addq	%r8, %rax
	movq	%r10, %r8
	movq	%rax, (%rdi,%r11,8)
	adcq	%rdx, %r8

	addq	$4, %r11
	jae	.Loop

	cmpl	$3, %r11d
	je	.Lret

.Ltail:	movq	-24(%rsi,%r11,8), %rax
	mulq	%rcx
	addq	-24(%rdi,%r11,8), %rax
	adcq	%r10, %rdx
	addq	%r8, %rax
	movq	%rax, -24(%rdi,%r11,8)
	movq	%r10, %r8
	adcq	%rdx, %r8

	cmpl	$2, %r11d
	je	.Lret

	movq	-16(%rsi,%r11,8), %rax
	mulq	%rcx
	addq	-16(%rdi,%r11,8), %rax
	adcq	%r10, %rdx
	addq	%r8, %rax
	movq	%r10, %r8
	movq	%rax, -16(%rdi,%r11,8)
	adcq	%rdx, %r8

	cmpl	$1, %r11d
	je	.Lret

	movq	-8(%rsi,%r11,8), %rax
	mulq	%rcx
	addq	-8(%rdi,%r11,8), %rax
	adcq	%r10, %rdx
	addq	%r8, %rax
	movq	%r10, %r8
	movq	%rax, -8(%rdi,%r11,8)
	adcq	%rdx, %r8

.Lret:	movq	%r8, %rax
	ret
EPILOGUE()
