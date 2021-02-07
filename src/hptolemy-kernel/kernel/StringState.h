/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/StringState.h,v $ $Revision: 100.12 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef STRINGSTATE_H_INCLUDED
#define STRINGSTATE_H_INCLUDED
// Copyright 1996 - 2014 Keysight Technologies, Inc  

#ifndef _StringState_h
#define _StringState_h 1

#ifdef __GNUG__
#pragma interface
#endif

#include "State.h"



/**************************************************************************
Version identification:
@(#)StringState.h	2.14	3/2/95

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

 Programmer: I. Kuroda
 Date of creation: 5/19/90
 Revisions:

 State with String type 

**************************************************************************/

/** A state with String type.

  A StringState's current value is a string (more correctly, of type
  {\tt const char*}).  The current value is created by the {\tt
  initialize()} function by scanning the initial value string.  This
  string is copied literally, except that curly braces are special.
  If a pair of curly braces surrounds the name of a galaxy state, the
  printed representation of that state's current value (returned by
  the {\tt currentValue} function) is substituted.  To get a literal
  curly brace in the current value, prefix it with a backslash.

  Class StringState defines assignment operators so that different
  string values can be copied to the current value; the value is
  copied with {\tt savestring} (\pxref{utility functions}) and deleted
  by the destructor.*/
class StringState : public State
{
public:
  /// Constructor
  StringState();

  /// Parses initValue to set value
  void initialize();

  // don't redefine type(), baseclass version returns "STRING"

  /// Get the value as a string
  StringList currentValue() const;

  /// For use as a string in stars
  operator const char* () { return val;}

  /**@name Initializing the current value */
  //@{
  /// 
  StringState& operator=(const char* newStr);
  /// The StringList arg is nonconst because it calls consolidate()
  StringState& operator=(StringList& newStrList);
  /// 
  StringState& operator=(const State& newState);
  //@}

  /// Return TRUE if the argment is a StringState
  int isA(const char*) const;

  /// Return the string ``StringState''
  const char* className() const; /// {return "StringState";}

  /// 
  const char* type() const;

  /// Return a new StringState
  State* clone () const; // {return new StringState;}

  /// Test for empty string
  int null() const { return val == 0 || *val == 0;}

  /// Destructor
  ~StringState ();

protected:
  /// Flag to enable escape code parsing (default on).
  int escape_enabled;

private:
  /// 
  char* val;
};	


MULTISTATE(StringState,StringMultiState)
#endif

#endif   /* STRINGSTATE_H_INCLUDED */
