/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/controls-displays/tcltk/ptklib/tclInit.h,v $ $Revision: 100.13 $ $Date: 2011/08/25 01:48:26 $ */

#ifndef TCLINIT_H_INCLUDED
#define TCLINIT_H_INCLUDED
// Copyright 1997 - 2014 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#ifndef _TCL
struct Tcl_Interp;
#endif

/** Initialize tcltk for HPEESOFSIM run, calls HPtolemy_Init*/
Tcl_Interp* initializeTclTk();

/** Start Tcl/Tk return a pointer to the interpreter*/
Tcl_Interp* HPtolemy_Init(Tcl_Interp*);

#endif   /* TCLINIT_H_INCLUDED */
