/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/ArrayState.hP,v $ $Revision: 100.10 $ $Date: 2004/03/25 20:34:04 $ */
#ifndef _FloatArrayState_h

#define _FloatArrayState_h 1

#ifdef __GNUG__
#pragma interface
#endif

// This file was originally auto-generated, but that magic is gone.  Just edit it directly if you need to change it.

#include "State.h"

/**************************************************************************
Version identification:
ArrayState.hP	2.8	2/2/94

Copyright (c) 1990-1994 The Regents of the University of California.
All rights reserved.

Permission is hereby granted, without written agreement and without
license or royalty fees, to use, copy, modify, and distribute this
software and its documentation for any purpose, provided that the above
copyright notice and the following two paragraphs appear in all copies
of this software.

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
                                                        COPYRIGHTENDKEY


 Programmer:  I. Kuroda and J. T. Buck
 Date of creation: 6/8/90
 Revisions:

**************************************************************************/

/** Array state with Float type.
 
  Classes {\tt IntArrayState} and {\tt FloatArrayState} are produced
  from the same pseudo-template.  Class {\tt ComplexArrayState} has a
  very similar design.

  The expression parser for {\tt FloatArrayState} accepts a series of
  {\em subarray expressions}, which are concatenated together to get
  the current value when {\tt initialize()} is called.  Subarray
  expressions may specify a single element, some number of copies of a
  single element, or a galaxy array state of the same type (another
  {\tt FloatArrayState}).  A single element specifier may either be a
  Float, or a Float galaxy state name, or a general Float expression
  enclosed in parentheses.  A number of copies of this single element
  can be specified by appending an integer expression enclosed in
  square brackets.

  @author   I. Kuroda and J. T. Buck*/
class FloatArrayState : public State {
public:

  /// Constructor an empty array
  FloatArrayState () {nElements = 0; val = 0;}
  
  /// Construct an array with a specified size
  FloatArrayState (int size) { val = new double [nElements = size];}

  /// Construct an array with a specified fill value
  FloatArrayState (int size, double& fill_value) ;

  /// Destruct the array
  ~FloatArrayState () ;

  /// Copy an array into this array
  FloatArrayState &	operator = (const FloatArrayState & v) ;

  /// Return the size of the array
  int size() const;

  /// Return the n{\em th} element
  double & operator [] (int n) {
    return val[n];
  }

  /// Return the current value double array
  operator double* () { return val; }

  /// Return the string ``FloatARRAY''
  const char* type() const;

  /// Return the current value of the state as a string
  StringList currentValue() const;

  /// Return TRUE when the argument is a ``FloatArrayState''
  int isA(const char*) const;

  /// Return the string ``FloatArrayState''
  const char* className() const;

  /// Return TRUE
  int isArray() const;

  /// Extend or truncate the array to a specified size
  void resize(int);

  /// Parse the initial value string to set the current value
  void initialize();

  /// Parse an element of the array
  ParseToken evalExpression(Tokenizer&);

  /// Return a new FloatArrayState
  State* clone() const;

protected:

  /// The number of elements in the array
  int	nElements;

  /// The current value array 
  double	*val;
};

MULTISTATE(FloatArrayState,FloatArrayMultiState)
#endif

