/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/EnumState.h,v $ $Revision: 100.15 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef ENUMSTATE_H_INCLUDED
#define ENUMSTATE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifndef _EnumState_h
#define _EnumState_h 1
/*@(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/EnumState.h,v $ $Revision: 100.15 $ $Date: 2011/08/25 01:47:10 $ */

// Author: Jose Luis Pino
#ifdef __GNUG__
#pragma interface
#endif

#include "IntState.h"
#include "StringArrayState.h"




/** An enumerated state.

  The class {\tt EnumState} allows the user to have an enumerated
  state.  This class stores it's current value as a interger.

  To declare an {\tt EnumState} in a ptlang file, you must specify a
  new field, {\tt enumlist}, with all entries separated by a comma.
  Unlike C and C++, each enumeration element can have spaces.  The
  default value should be one of the enumeration strings.

  An enumeration can optionally have an abbreviated format for each
  enumeration element.  This abbreviation is used by the GUI to
  display the enumeration value of the block diagram schematic.

  To test a state for a given enumeration in your code, use you
  enumeration string (not the abbreviation) with the spaces
  substituted with ``\_''.

  Here is a simple example:

  {\tt \begin{verbatim}
  defstate {
      name { exampleEnumeration }
      type { enum }
      default { "State 1" }
      desc { A simple enumeration example }
      enumeration { State 1, State 2, State 3 } 
      abbreviations {S1, S2, S3}
      units { UNITLESS_UNIT }
      attributes { A_SETTABLE|A_NONCONSTANT }
  } 
  
  go {
      if (exampleEnumeration == State_1) {
          cout << "The enumeration is State 1\n";
      }
  }
  \end{verbatim}}

  
  If you are not using ptlang to write your star or are writing a
  target, you'll have to do a bit more to define an {\tt EnumState}
  than other types of states.  The easiest way of generating the state
  is to create a dummy ptlang file and the copy and paste the
  enumeration state initialization code.

  This facility has been developed by HP EEsof.  */
class EnumState : public IntState {
public:

  /// Construct an enumerated state, with optional abbreviations
  EnumState(const char* list, const char* = NULL );

  /// Parse the initial value string and check for proper range
  void initialize();

  /// Return the string ``ENUMERATED''
  const char* type() const;

  /// Return the current value as a string
  StringList currentValue() const;

  /// Returns true if argument is an EnumState
  int isA(const char*) const;

  /// Returns the string ``EnumState''
  const char* className() const {return "EnumState";}
  
  /// Assign the current value from another EnumState
  EnumState& operator=(const EnumState&  rhs) { 
    val=rhs.val; 
    enumerations = rhs.enumerations; 
    abbreviations = rhs.abbreviations; 
    return *this;
  }

  /// Assign the current value from a given int
  int operator=(int rvalue) { return val = rvalue;}

  /// Clone the EnumState
  State* clone () const;

  /// Return the enumeration string for a given integer
  inline const char* operator [] (int n) {
    return enumerations[n];
  }

  /// Return the enumeration string for a given integer
  inline const char* enumString ( int n) {
    return enumerations[n];
  }

  /// Return the enumeration abbreviation for a given integer
  inline const char* enumAbbreviation ( int n) {
    return (abbreviations.size()? abbreviations[n]: enumerations[n]);
  }

  /// Return the number of enumeration states
  int size() const { 
    return enumerations.size();
  }

  /** Return the enumeration number of the string, -1 if
    invalid */
  int member(const char* m) const {
    return enumerations.member(m);
  }

  /// Return the current value as an int
    int currentIntValue() { return this->val;}

private:

  // The enumeration states
  StringArrayState enumerations;

  // Abbreviates for each enumeration 
  StringArrayState abbreviations;
};
  
MULTISTATE(EnumState,EnumMultiState)
#endif

#endif   /* ENUMSTATE_H_INCLUDED */
