/**************************************************************************
Version identification:
@(#)type.h	1.15	12/31/95

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

 Programmer:  E. A. Lee and D. G. Messerschmitt
 Date of creation: 1/17/89
 Revisions:

 Basic system definitions.

**************************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/type.h,v $ $Revision: 100.18 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef TYPE_H_INCLUDED
#define TYPE_H_INCLUDED
// Copyright 1996 - 2014 Keysight Technologies, Inc  


#include "HPstddefs.h"

#include "logNew.h"

#ifdef WIN32
#pragma warning(disable:4514)
#endif

/*/ The most general type of pointer, for use in generic types. */
typedef void* Pointer;


#ifndef POSTFIX_OP

/** Postfix operator++. Older C++ compilers make no distinction between
  prefix and postfix operator++.  For such compilers, POSTFIX\_OP
  should be defined as the empty string.  Newer C++ compilers use
  operator++() as the prefix form (++obj) and operator++(int) as the
  postfix form.  For these we have POSTFIX\_OP defined to be int.  This
  is the default, except for g++, since newer g++'s accept the prefix
  form for backward compatibility.
  
  @see Iterators*/
#define POSTFIX_OP int

#endif

#endif   /* TYPE_H_INCLUDED */
