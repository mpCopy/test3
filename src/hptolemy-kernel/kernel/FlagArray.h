/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/FlagArray.h,v $ $Revision: 100.16 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef FLAGARRAY_H_INCLUDED
#define FLAGARRAY_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

/**************************************************************************
Version identification:
@(#)FlagArray.h	1.2	01/01/96

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


 Programmer:  E. A. Lee
 Date of creation: 8/15/95

**************************************************************************/

#include "HPtolemyError.h"
#include <iostream>

/** A flag array is a lightweight, self-expanding array of integers.
    It is meant to store an array of flags or counters, and its main
    appearance in Ptolemy is as a public member of class {\tt Block}.
    Targets and schedulers use this member to keep track of various
    kinds of data. Many schedulers and targets need to be able to mark
    blocks in various ways, for example to count invocations, or flag
    that the block has been visited, or to classify it as a particular
    type of block. This class provides a simple mechanism for doing
    this.

    A {\tt FlagArray} object is indexed like an array, using square
    brackets.  If {\tt x} is a {\tt FlagArray} and {\tt i} is a
    non-negative integer, then {\tt x[i]} is a reference to an integer
    element of the array. If {\tt i} is out of bounds (beyond the
    currently allocated limits of the array), then the class
    automatically increases the size of the array.  New elements are
    filled with zeros.  Thus, a {\tt FlagArray} may be viewed as an
    infinite dimensional array of integers initialized with zeros.  If
    {\tt i} is a negative integer, then {\tt x[i]} is an error.  For
    efficiency, the class does not test for this error at run time, so
    you could get a core dump if you make this error. */
class FlagArray {
public:
  /// Construct a zero-length flag array
  FlagArray () {nElements = 0; val = 0;}

  /// Construct a flag array of a specified and initialized with zeros
  FlagArray (int size);

  /// Construct a flag array of a specified and initialized with a fill value
  FlagArray (int size, int fill_value) ;

  /// Destructor
  ~FlagArray () ;

  /// Copy the size and data from another flag array
  FlagArray &	operator = (const FlagArray & v) ;

  /// Return the size of the array
  inline int size() const { return nElements;}

  /** Return an array element for assignment or reference.
  
    If {\tt n} is less than the currently allocated size of the array,
    then this returns a reference to the n-th element of the array. If
    {\tt n} is greater than or equal to the currently allocated size
    of the array, then the size of the array is increased, the new
    elements are filled with zeros, and a reference to the n-th
    element is returned.  Indexing of elements begins with zero.  The
    returned reference, of course, can be used on the left-hand side
    of an assignment.  This is how values are written into an array.  */
  int & operator [] (int n);

  /// Const version, don't resize
  inline const int operator [] (int n) const  {
    int value = 0;
    if (n < 0 || n >= size()) {
      Error::internalError(__FILE__,__LINE__,
			   "The index for the flag [] const operator is out of range.");
    }
    else {
      value = val[n];
    }
    return value;
  }
	
protected:
  int	nElements;
  int	*val;
};

/** Operator to output a ReservedFlagArray to an ostream. */
std::ostream& operator << (std::ostream& o, const FlagArray& a);

#endif   /* FLAGARRAY_H_INCLUDED */
