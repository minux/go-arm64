// Copyright 2015 The Go Authors.  All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#include "textflag.h"

/*
 * void crosscall2(void (*fn)(void*, int32), void*, int32)
 * Save registers and call fn with two arguments.
 */
TEXT crosscall2(SB),NOSPLIT,$-8
	/*
	 * We still need to save all callee save register as before, and then
	 *  push 2 args for fn (R1 and R2).
	 * Also note that at procedure entry in 7g world, 8(RSP) will be the
	 *  first arg, so we must push another dummy reg (R0) for 0(RSP).
	 *  Additionally, runtime·load_g will clobber R0, so we need to save R0
	 *  nevertheless.
	 */
	STP	(R19, R20), -16(RSP)!
	STP	(R21, R22), -16(RSP)!
	STP	(R23, R24), -16(RSP)!
	STP	(R25, R26), -16(RSP)!
	STP	(R27, g), -16(RSP)!
	STP	(RFP, R30), -16(RSP)!
	STP	(R2, R3), -16(RSP)!	// save R3 to maintain 16-byte SP alignment
	STP	(R0, R1), -16(RSP)!

	MOV	R0, R19
	BL	runtime·load_g(SB)
	BL	(R19)

	ADD	$32, RSP		// skip R0, R1, R2, R3
	LDP	(RSP)16!, (RFP, R30)
	LDP	(RSP)16!, (R27, g)
	LDP	(RSP)16!, (R25, R26)
	LDP	(RSP)16!, (R23, R24)
	LDP	(RSP)16!, (R21, R22)
	LDP	(RSP)16!, (R19, R20)
	RETURN
