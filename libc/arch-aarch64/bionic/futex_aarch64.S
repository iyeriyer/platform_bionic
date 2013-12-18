/*
 * Copyright (C) 2013 The Android Open Source Project
 * All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <asm/unistd.h>
#include <linux/err.h>
#include <machine/asm.h>

#define FUTEX_WAIT 0
#define FUTEX_WAKE 1

/*
 * Syscall interface for fast userspace locks
 *
 * int __futex_wait(volatile void *ftx, int val, const struct timespec *timeout);
 * int __futex_wake(volatile void *ftx, int count);
 * int __futex_syscall3(volatile void *ftx, int op, int val);
 * int __futex_syscall4(volatile void *ftx, int op, int val, const struct timespec *timeout);
 */

ENTRY(__futex_syscall4)
    /* create AArch64 PCS frame pointer */
    stp    x29, x30, [sp, #-16]!
    mov    x29,  sp

    /* store x8 */
    str    x8,       [sp, #-16]!

    /* syscall No. in x8 */
    mov     x8, __NR_futex
    svc     #0

    /* restore x8 */
    ldr     x8,       [sp], #16
    ldp     x29, x30, [sp], #16

    /* check if syscall returned successfully */
    cmn     x0, #(MAX_ERRNO + 1)
    cneg    x0, x0, hi
    b.hi    __set_errno

    ret
END(__futex_syscall4)

ENTRY(__futex_syscall3)
    /* __futex_syscall4 but with fewer arguments */
    b __futex_syscall4
END(__futex_syscall3)

ENTRY(__futex_wait)
    /* create AArch64 PCS frame pointer */
    stp    x29, x30, [sp, #-16]!
    mov    x29,  sp

    /* store x8 */
    str    x8,       [sp, #-16]!

    /* arange arguments as expected in the kernel side */
    mov x3, x2
    mov w2, w1
    mov w1, #FUTEX_WAIT

    /* syscall No. in X8 */
    mov     x8, __NR_futex
    svc     #0

    /* restore x8 */
    ldr     x8,       [sp], #16
    ldp     x29, x30, [sp], #16

    /* check if syscall returned successfully */
    cmn     x0, #(MAX_ERRNO + 1)
    cneg    x0, x0, hi
    b.hi    __set_errno

    ret
END(__futex_wait)

ENTRY(__futex_wake)
    /* create AArch64 PCS frame pointer */
    stp    x29, x30, [sp, #-16]!
    mov    x29,  sp

    /* store x8 */
    str    x8,       [sp, #-16]!

    /* arange arguments as expected in the kernel side */
    mov w2, w1
    mov w1, #FUTEX_WAIT

    /* syscall No. in X8 */
    mov     x8, __NR_futex
    svc     #0

    /* restore x8 */
    ldr     x8,       [sp], #16
    ldp     x29, x30, [sp], #16

    /* check if syscall returned successfully */
    cmn     x0, #(MAX_ERRNO + 1)
    cneg    x0, x0, hi
    b.hi    __set_errno

    ret
END(__futex_wake)