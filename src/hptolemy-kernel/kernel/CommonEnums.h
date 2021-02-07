/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/CommonEnums.h,v $ $Revision: 100.6 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef COMMONENUMS_H_INCLUDED
#define COMMONENUMS_H_INCLUDED
// Copyright Keysight Technologies 1998 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include "EnumState.h"



/** A Boolean Enumerate State with the enum TRUE=1 and FALSE=0. */
class BooleanState: public EnumState {
public:
  /// Constructor
  BooleanState();

  /// Assign the current value from a given int
  int operator=(int rvalue) { return val = rvalue;}

  /// Assignment from another state
  BooleanState& operator=(const BooleanState& rhs) {
    val = rhs;
    return *this;
  }

  /// Create a new copy
  State* clone() const {
    BooleanState *s = new BooleanState();
    if (s) *s = *this;
    return s;
  }

  /// Class identification
  int isA(const char *) const;
  const char* className() const;
};

/** A Query Enumerate State with the enum YES=1 and NO=0. */
class QueryState: public EnumState {
public:
  /// Constructor
  QueryState();

  /// Assign the current value from a given int
  int operator=(int rvalue) { return val = rvalue;}

  /// Assignment from another state
  QueryState& operator=(const QueryState& rhs) {
    val = rhs;
    return *this;
  }

  /// Create a new copy
  State* clone() const {
    QueryState *s = new QueryState();
    if (s) *s = *this;
    return s;
  }

  /// Class identification
  int isA(const char *) const;
  const char* className() const;
};

/** A Switch Enumerate State with the enum ON=1 and OFF=0. */
class SwitchState: public EnumState {
public:
  /// Constructor
  SwitchState();

  /// Assign the current value from a given int
  int operator=(int rvalue) { return val = rvalue;}

  /// Assignment from another state
  SwitchState& operator=(const SwitchState& rhs) {
    val = rhs;
    return *this;
  }

  /// Create a new copy
  State* clone() const {
    SwitchState *s = new SwitchState();
    if (s) *s = *this;
    return s;
  }

  /// Class identification
  int isA(const char *) const;
  const char* className() const;
};

#endif   /* COMMONENUMS_H_INCLUDED */
