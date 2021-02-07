/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/ptklib/ptk.h,v $ $Revision: 100.12 $ $Date: 2012/03/28 20:49:38 $ */

#ifndef PTK_H_INCLUDED
#define PTK_H_INCLUDED
// Copyright 1997 - 2014 Keysight Technologies, Inc  

/* 
Copyright (c) 1990-1996 The Regents of the University of California.
All rights reserved.

Permission is hereby granted, without written agreement and without
license or royalty fees, to use, copy, modify, and distribute this
software and its documentation for any purpose, provided that the
above copyright notice and the following two paragraphs appear in all
copies of this software.

IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.

						PT_COPYRIGHT_VERSION_2
						COPYRIGHTENDKEY
*/

/*
    ptk.h  aok
    Version: @(#)ptk.h	1.8 11/18/95
*/

/* Header files of Pigi TkCalls */

/* the following fixes permit the "DECwindows" version of Xlib.h to work with
   C++ */

// The following forward declarations issue an error when building
// on xp 64, so I changed this section for ads 2006a update release 2.
// - doomer
#if defined(_WIN32) && defined(CEDA_64_BIT)

#else
#if _MSC_VER < 1700
struct XSizeHints;
struct XStandardColormap;
struct XTextProperty;
struct XWMHints;
struct XClassHint;
#endif // if _MSC_VER < 1700
#endif

#include "tcl.h"

/* Note that if we are including ptk.h in a C++ file, we must include
 * ptk.h last because ptk.h includes tk.h which eventually includes
 * X11/X.h, which on Solaris2.4 there is a #define Complex 0, which
 * causes no end of trouble.
 */
#include "tk.h"
#include "ptkDll.h"

#ifdef __cplusplus
extern "C" {
#endif

DllImport extern Tcl_Interp *ptkInterp;
DllImport extern Tk_Window ptkW;

#ifdef __cplusplus
}
#endif

#endif   /* PTK_H_INCLUDED */
