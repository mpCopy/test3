/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/StringArrayState.h,v $ $Revision: 100.14 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef STRINGARRAYSTATE_H_INCLUDED
#define STRINGARRAYSTATE_H_INCLUDED
// Copyright 1996 - 2014 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#include "State.h"

/**************************************************************************
Version identification:
@(#)StringArrayState.h	1.8	3/16/96

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

 Programmer: J. Buck
 Date of creation: 9/28/92
 Revisions:

 State with array-of-strings type 

**************************************************************************/


/** State with array-of-strings type.

  As its name suggests, the current value for a StringArrayState is
  an array of strings.  White space in the initial value string
  separates ``words'', and Each word is assigned by {\tt initialize()}
  into a separate array element.  Quotes can be use to permit
  ``words'' to have white space.

  Current values of galaxy states can be converted into single
  elements of the StringArrayState value by surrounding their names
  with curly braces in the initial value.  Galaxy StringArrayState
  names will be translated into a series of values.

  There is currently no provision for modifying the current value of a
  StringArrayState other than calling of {\tt initialize} to parse the
  current value string.  */
class StringArrayState : public State {
public:
  /**@name Constructors and destructor */
  //@{
  /// 
  StringArrayState() : val(0), nElements(0) {}
  /// 
  StringArrayState(const StringArrayState&);
  /// 
  ~StringArrayState();
  //@}

  /// Assignment
  StringArrayState& operator=(const StringArrayState&);

  /// Parses initValue to set value
  void initialize();

  /// Return the parameter type (for use in GUI, interpreter)
  const char* type() const;

  /// The value as a string
  StringList currentValue() const;

  /// Size
  int size() const; // { return nElements;}

  /// Array element 
  const char* operator [] (int n) const {
    return val[n];
  }

  /// Array element 
  const char* operator [] (int n) {
    return val[n];
  }

  /**@name Class identification */
  //@{
  /// 
  int isA(const char*) const;
  /// 
  const char* className() const; /// {return "StringArrayState";}
  /// 
  int isArray() const;
  //@}

  /// Return a new StringArrayState
  State* clone () const; // {return new StringArrayState;}

  /** Return the element number if the string appears in my
    current value, -1 if it does not.*/
  int member(const char*) const;

  /// Resize the array.  All contents lost.
  void resize(int);

private:
  /// destructor body
  void zap();

  /// copy constructor body
  void copy(const StringArrayState&);

  /// 
  char** val;
  /// 
  int nElements;

  /// 
  int repeatItem(Tokenizer& lexer, int& i, int& bufsize);
  /// 
  int expectParameterName(Tokenizer& lexer, int& i, int& bufsize);
  ///

};	

MULTISTATE(StringArrayState,StringArrayMultiState)
#endif   /* STRINGARRAYSTATE_H_INCLUDED */
