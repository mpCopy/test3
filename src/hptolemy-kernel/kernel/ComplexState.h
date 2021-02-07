/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/ComplexState.h,v $ $Revision: 100.12 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef COMPLEXSTATE_H_INCLUDED
#define COMPLEXSTATE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#include "State.h"
#include <complex>

/**************************************************************************
UCB Version identification: ComplexState.h	2.11	3/2/95

Copyright (c) 1990-1995 The Regents of the University of California.
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

 Programmer:  I. Kuroda and J. T. Buck
 Date of creation: 6/15/90
 Revisions:

 State with Complex type

**************************************************************************/

/** A State with complex type.
 
  ComplexState is much like FloatState and IntState, except in the
  expressions it accepts for initial values.  Its data member is
  Complex and it accordingly defines an assignment operator that takes a
  complex value and a conversion operator that returns one.

  The initial value string for a ComplexState takes one of three forms:
  it may be the name of a galaxy ComplexState, a floating expression
  (of the form accepted by {\tt State::evalFloatExpression}), or a
  string of the form

  {\tt ( floatexp1 , floatexp2 )}

  where both {\tt floatexp1} and {\tt floatexp2} are floating expressions.
  For the second form, the imaginary part will always be zero.  For the
  third form, the first expression gives the real part and the second
  gives the imaginary part.
*/
class ComplexState : public State {
public:
  /// Constructor
  ComplexState() { val = 0;}

  /// Parse the initial value string to set the current value
  void initialize();

  /// Return the string ``COMPLEX''
  const char* type() const; // { return "COMPLEX";}

  /// Return the current value of the state as a string
  StringList currentValue() const;

  /// Assign the current value from a given complex number
  Complex& operator=(const Complex& rvalue) { return val = rvalue;}

  /// Assign the current value from another ComplexState
  ComplexState& operator=(const ComplexState& arg) {
    val = arg.val; return *this;
  }

  /// Return the current value when cast to a xomplex
  operator Complex() { return val;}

  operator std::complex<double>() { return std::complex<double>(val.real(),val.imag()); }

	  /// Set the initial value string from a complex
  void setInitValue(const Complex& arg);

  /// Set the initial value string from a const char*
  //We must redeclare this because of the {\em c++ hiding rule}
  void setInitValue(const char* s) { State::setInitValue(s);}

  /// Return TRUE when the argument is ``ComplexState''
  int isA(const char*) const;

  /// Return the string ``ComplexState''
  const char* className() const {return "ComplexState";}

  /// Return a new ComplexState
  State* clone () const;

 protected:
  /// Storage location for the current value
  Complex val;
};
MULTISTATE(ComplexState,ComplexMultiState)
#endif   /* COMPLEXSTATE_H_INCLUDED */
