/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/InvokeInterp.h,v $ $Revision: 100.9 $ $Date: 2011/08/25 01:47:10 $ */


#ifndef INVOKEINTERP_H_INCLUDED
#define INVOKEINTERP_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  



#ifndef _InvokeInterp_h
#define _InvokeInterp_h 1

#ifdef __GNUG__
#pragma interface
#endif

/**************************************************************************
Version identification:
@(#)InvokeInterp.h	1.2	09/27/95

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

 Programmer: B. L. Evans
 Date of creation: 9/26/95
 Revisions:

**************************************************************************/

/** A class to define an external interpreter on which to invoke
  commands and scripts, e.g. in state definitions */
class InvokeInterp {
public:
	/// Constructor
	InvokeInterp();

	/// Destructor
	~InvokeInterp();

	/// Send a string to an external interpreter for evaluation
	const char* interpreter(const char* expression);
};

#endif

#endif   /* INVOKEINTERP_H_INCLUDED */