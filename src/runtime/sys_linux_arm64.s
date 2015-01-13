// Copyright 2014 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//
// System calls and other sys.stuff for arm64, Linux
//

#include "go_asm.h"
#include "go_tls.h"
#include "textflag.h"

#define SYS_exit		  93
#define SYS_read		  63
#define SYS_write		  64
#define SYS_open		  1024
#define SYS_close		  57
#define SYS_fcntl		 1052
#define SYS_gettimeofday	 169
#define SYS_select		 1067
#define SYS_mmap		 1058
#define SYS_munmap		 215
#define SYS_setitimer		103
#define SYS_clone		220
#define SYS_sched_yield		124
#define SYS_rt_sigreturn	139
#define SYS_rt_sigaction	134
#define SYS_rt_sigprocmask	135
#define SYS_sigaltstack		132
#define SYS_getrlimit		163
#define SYS_madvise		233
#define SYS_mincore		132
#define SYS_gettid		178
#define SYS_tkill		130
#define SYS_futex		98
#define SYS_sched_getaffinity	123
#define SYS_exit_group		94
#define SYS_epoll_create	1042
#define SYS_epoll_ctl		21
#define SYS_epoll_wait		1069
#define SYS_clock_gettime	113
#define SYS_epoll_create1	20

TEXT runtime·exit(SB),NOSPLIT,$-8-4
	MOVW	code+0(FP), R0
	MOV	$SYS_exit_group, R8
	SVC	
	RETURN

TEXT runtime·exit1(SB),NOSPLIT,$-8-4
	MOVW	code+0(FP), R0
	MOV	$SYS_exit, R8
	SVC
	RETURN

TEXT runtime·open(SB),NOSPLIT,$-8-20
	MOV	name+0(FP), R0
	MOVW	mode+8(FP), R1
	MOVW	perm+12(FP), R2
	MOV	$SYS_open, R8
	SVC
	MOVW	R0, ret+16(FP)
	RETURN

TEXT runtime·close(SB),NOSPLIT,$-8-12
	MOVW	fd+0(FP), R0 
	MOV	$SYS_close, R8
	SVC
	MOVW	R0, ret+8(FP)
	RETURN

TEXT runtime·write(SB),NOSPLIT,$-8-28
	MOV	fd+0(FP), R0
	MOV	p+8(FP), R1
	MOVW	n+16(FP), R2
	MOV	$SYS_write, R8
	SVC
	MOVW	R0, ret+24(FP)
	RETURN

TEXT runtime·read(SB),NOSPLIT,$-8-28
	MOVW	fd+0(FP), R0
	MOV	p+8(FP), R1
	MOVW	n+16(FP), R2
	MOV	$SYS_read, R8
	SVC
	MOVW	R0, ret+24(FP)
	RETURN

TEXT runtime·getrlimit(SB),NOSPLIT,$-8-20
	MOVW	kind+0(FP), R0
	MOV	limit+8(FP), R1
	MOV	$SYS_getrlimit, R8
	SVC
	MOVW	R0, ret+16(FP)
	RETURN
/*
// TODO(dfc) not done yet, looks hard
TEXT runtime·usleep(SB),NOSPLIT,$16-4
	MOVW	usec+0(FP), R3
	MOVD	R3, R5
	MOVW	$1000000, R4
	DIVD	R4, R3
	MOVD	R3, 8(R1)
	MULLD	R3, R4
	SUB	R4, R5
	MOVD	R5, 16(R1)

	// select(0, 0, 0, 0, &tv)
	MOVW	$0, R3
	MOVW	$0, R4
	MOVW	$0, R5
	MOVW	$0, R6
	ADD	$8, R1, R7
	SYSCALL	$SYS_newselect
	RETURN
*/

TEXT runtime·raise(SB),NOSPLIT,$-8
	MOV	$SYS_gettid, R8
	SVC
	MOVW	R0, R0	// arg 1 tid
	MOVW	sig+0(FP), R1	// arg 2
	MOV	$SYS_tkill, R8
	SVC
	RETURN

TEXT runtime·setitimer(SB),NOSPLIT,$-8-24
	MOVW	mode+0(FP), R0
	MOV	new+8(FP), R1
	MOV	old+16(FP), R2
	MOV	$SYS_setitimer, R8
	SVC
	RETURN

TEXT runtime·mincore(SB),NOSPLIT,$-8-28
	MOV	addr+0(FP), R0
	MOV	n+8(FP), R1
	MOV	dst+16(FP), R2
	MOV	$SYS_mincore, R8
	SVC
	MOVW	R0, ret+24(FP)
	RETURN

/*
// TODO(dfc) blergh, math is hard

// func now() (sec int64, nsec int32)
TEXT time·now(SB),NOSPLIT,$16
	MOVD	$0(R1), R3
	MOVD	$0, R4
	SYSCALL	$SYS_gettimeofday
	MOVD	0(R1), R3	// sec
	MOVD	8(R1), R5	// usec
	MOVD	$1000, R4
	MULLD	R4, R5
	MOVD	R3, sec+0(FP)
	MOVW	R5, nsec+8(FP)
	RETURN

TEXT runtime·nanotime(SB),NOSPLIT,$16
	MOVW	$1, R3 // CLOCK_MONOTONIC
	MOVD	$0(R1), R4
	SYSCALL	$SYS_clock_gettime
	MOVD	0(R1), R3	// sec
	MOVD	8(R1), R5	// nsec
	// sec is in R3, nsec in R5
	// return nsec in R3
	MOVD	$1000000000, R4
	MULLD	R4, R3
	ADD	R5, R3
	MOVD	R3, ret+0(FP)
	RETURN
*/

TEXT runtime·rtsigprocmask(SB),NOSPLIT,$-8-28
	MOVW	sig+0(FP), R0
	MOV	new+8(FP), R1
	MOV	old+16(FP), R2
	MOVW	size+24(FP), R3
	MOV	$SYS_rt_sigprocmask, R8
	SVC
	BVC	done
	MOV	R0, 0xf0(R0)	// crash
done:
	RETURN

TEXT runtime·rt_sigaction(SB),NOSPLIT,$-8-36
	MOV	sig+0(FP), R0
	MOV	new+8(FP), R1
	MOV	old+16(FP), R2
	MOV	size+24(FP), R3
	MOV	$SYS_rt_sigaction, R8
	SVC
	MOVW	R0, ret+32(FP)
	RETURN

/* 
// TODO(dfc) hard
TEXT runtime·sigtramp(SB),NOSPLIT,$64
	// initialize essential registers (just in case)
	BL	runtime·reginit(SB)

	// check that g exists
	CMP	g, $0
	BNE	6(PC)
	MOVD	R3, 8(R1)
	MOVD	$runtime·badsignal(SB), R31
	MOVD	R31, CTR
	BL	(CTR)
	RETURN

	// save g
	MOVD	g, 40(R1)
	MOVD	g, R6

	// g = m->gsignal
	MOVD	g_m(g), R7
	MOVD	m_gsignal(R7), g

	MOVW	R3, 8(R1)
	MOVD	R4, 16(R1)
	MOVD	R5, 24(R1)
	MOVD	R6, 32(R1)

	BL	runtime·sighandler(SB)

	// restore g
	MOVD	40(R1), g

	RETURN
*/

TEXT runtime·mmap(SB),NOSPLIT,$-8
	MOV	addr+0(FP), R0
	MOV	n+8(FP), R1
	MOVW	prot+16(FP), R2
	MOVW	flags+20(FP), R3
	MOVW	fd+24(FP), R4
	MOVW	off+28(FP), R5

	MOV	$SYS_mmap, R8
	SVC
	MOV	R0, ret+32(FP)
	RETURN

TEXT runtime·munmap(SB),NOSPLIT,$-8
	MOV	addr+0(FP), R0
	MOV	n+8(FP), R1
	MOV	$SYS_munmap, R8
	SVC
	BVC	cool
	MOV	R0, 0xf0(R0)
cool:
	RETURN

TEXT runtime·madvise(SB),NOSPLIT,$-8
	MOV	addr+0(FP), R0
	MOV	n+8(FP), R1
	MOVW	flags+16(FP), R2
	MOV	$SYS_madvise, R8
	SVC
	// ignore failure - maybe pages are locked
	RETURN

// int64 futex(int32 *uaddr, int32 op, int32 val,
//	struct timespec *timeout, int32 *uaddr2, int32 val2);
TEXT runtime·futex(SB),NOSPLIT,$-8
	MOV	addr+0(FP), R0
	MOVW	op+8(FP), R1
	MOVW	val+12(FP), R2
	MOV	ts+16(FP), R3
	MOV	addr2+24(FP), R4
	MOVW	val3+32(FP), R5
	MOV	$SYS_futex, R8
	MOVW	R0, ret+40(FP)
	RETURN

/*
// TODO(dfc) hard
// int64 clone(int32 flags, void *stk, M *mp, G *gp, void (*fn)(void));
TEXT runtime·clone(SB),NOSPLIT,$-8
	MOVW	flags+0(FP), R3
	MOVD	stk+8(FP), R4

	// Copy mp, gp, fn off parent stack for use by child.
	// Careful: Linux system call clobbers ???.
	MOVD	mm+16(FP), R7
	MOVD	gg+24(FP), R8
	MOVD	fn+32(FP), R12

	MOVD	R7, -8(R4)
	MOVD	R8, -16(R4)
	MOVD	R12, -24(R4)
	MOVD	$1234, R7
	MOVD	R7, -32(R4)

	SYSCALL $SYS_clone

	// In parent, return.
	CMP	R3, $0
	BEQ	3(PC)
	MOVW	R3, ret+40(FP)
	RETURN

	// In child, on new stack.
	// initialize essential registers
	BL	runtime·reginit(SB)
	MOVD	-32(R1), R7
	CMP	R7, $1234
	BEQ	2(PC)
	MOVD	R0, 0(R0)

	// Initialize m->procid to Linux tid
	SYSCALL $SYS_gettid

	MOVD	-24(R1), R12
	MOVD	-16(R1), R8
	MOVD	-8(R1), R7

	MOVD	R3, m_procid(R7)

	// TODO: setup TLS.

	// In child, set up new stack
	MOVD	R7, g_m(R8)
	MOVD	R8, g
	//CALL	runtime·stackcheck(SB)

	// Call fn
	MOVD	R12, CTR
	BL	(CTR)

	// It shouldn't return.  If it does, exit
	MOVW	$111, R3
	SYSCALL $SYS_exit_group
	BR	-2(PC)	// keep exiting
*/

TEXT runtime·sigaltstack(SB),NOSPLIT,$-8
	MOV	new+0(FP), R0
	MOV	old+8(FP), R1
	MOV	$SYS_sigaltstack, R8
	SVC
	BVC	ok
	MOV	R0, 0xf0(R0)  // crash
ok:
	RETURN

TEXT runtime·osyield(SB),NOSPLIT,$-8
	MOV	$SYS_sched_yield, R8
	SVC
	RETURN

TEXT runtime·sched_getaffinity(SB),NOSPLIT,$-8
	MOV	pid+0(FP), R0
	MOV	len+8(FP), R1
	MOV	buf+16(FP), R2
	MOV	$SYS_sched_getaffinity, R8
	SVC
	MOVW	R0, ret+24(FP)
	RETURN

// int32 runtime·epollcreate(int32 size);
TEXT runtime·epollcreate(SB),NOSPLIT,$-8
	MOVW    size+0(FP), R0
	MOV	$SYS_epoll_create, R8
	SVC
	MOVW	R0, ret+8(FP)
	RETURN

// int32 runtime·epollcreate1(int32 flags);
TEXT runtime·epollcreate1(SB),NOSPLIT,$-8
	MOVW	flags+0(FP), R0
	MOV	$SYS_epoll_create1, R8
	SVC
	MOVW	R0, ret+8(FP)
	RETURN

// func epollctl(epfd, op, fd int32, ev *epollEvent) int
TEXT runtime·epollctl(SB),NOSPLIT,$-8
	MOVW	epfd+0(FP), R0
	MOVW	op+4(FP), R1
	MOVW	fd+8(FP), R2
	MOV	ev+16(FP), R3
	MOV	$SYS_epoll_ctl, R8
	SVC
	MOVW	R0, ret+24(FP)
	RETURN

// int32 runtime·epollwait(int32 epfd, EpollEvent *ev, int32 nev, int32 timeout);
TEXT runtime·epollwait(SB),NOSPLIT,$-8
	MOVW	epfd+0(FP), R0
	MOV	ev+8(FP), R1
	MOVW	nev+16(FP), R2
	MOVW	timeout+20(FP), R3
	MOV	$SYS_epoll_wait, R8
	SVC
	MOVW	R0, ret+24(FP)
	RETURN

// void runtime·closeonexec(int32 fd);
TEXT runtime·closeonexec(SB),NOSPLIT,$-8
	MOVW    fd+0(FP), R0  // fd
	MOV	$2, R1  // F_SETFD
	MOV	$1, R2  // FD_CLOEXEC
	MOV	$SYS_fcntl, R8
	SVC
	RETURN