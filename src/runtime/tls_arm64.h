// Copyright 2015 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#ifdef GOOS_linux
#define TPIDR TPIDR_EL0
#endif

// Define something that will break the build if
// the GOOS is unknown.
#ifndef TPIDR
#define TPIDR TPIDR_UNKNOWN
#endif
