/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/FixState.h,v $ $Revision: 100.10 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef FIXSTATE_H_INCLUDED
#define FIXSTATE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifndef _FixState_h
#define _FixState_h 1

#ifdef __GNUG__
#pragma interface
#endif

#include "State.h"
#include "Fix.h"
#include "PrecisionState.h"




/**************************************************************************
Version identification:
@(#)FixState.h	2.12	3/2/95

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

 Programmer:  A. Khazeni (replaces old version)
 Revisions:

 State with Fix type

**************************************************************************/

/// A state with Fix type
class FixState : public State
{
public:
  /// Constructor
  FixState();

  /// Parses initValue to set value
  void initialize();

  /// Return the string ``FIX''
  const char* type() const; // { return "FIX";}

  /// The value as a string
  StringList currentValue() const;

  /// Assignment from a Fix
  Fix& operator=(const Fix& rvalue) { return val = rvalue;}

  /// Assignment from a FixState
  FixState& operator=(const FixState& arg) {
    val = arg.val; return *this;
  }

  /// Casting to a Fix
  operator Fix() { return val;}
  /// Convert to double (not done as cast because of ambiguity)
  double asDouble() const { return double(val);}

  /** Return the precision of the Fix values.  The precision may
    contain symbolic expressions if it has been set by the
    setPrecision() method; otherwise it will only consist of integer
    constants.*/
  Precision precision() const;

  /** Explicitly set the precision.  If overrideable is FALSE the
    symbolic expressions can not be redefined in the future.*/
  void setPrecision(const Precision&, int overrideable=TRUE);

  /// Cet init value
  void setInitValue(const Fix& arg);

  /// This redeclaration is required by the "hiding rule".  Yuk!
  void setInitValue(const char* s) { State::setInitValue(s);}

  /**@name Class identification */
  //@{
  /// 
  int isA(const char*) const;
  /// 
  const char* className() const {return "FixState";}
  //@}

  /// Return a new FixState
  State* clone () const;//  {return new FixState;}

private:
  /// the actual data
  Fix val;

  /// symbolic representation of the fixed-point precision
  char *symbolic_length, *symbolic_intBits;
  /// flag that indicates whether the symbolic representation is changeable
  int overrideablePrecision;
};
MULTISTATE(FixState,FixMultiState)
#endif

#endif   /* FIXSTATE_H_INCLUDED */
