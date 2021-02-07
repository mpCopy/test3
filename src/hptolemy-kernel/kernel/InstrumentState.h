#ifndef INSTRUMENTSTATE_H_INCLUDED
#define INSTRUMENTSTATE_H_INCLUDED
// Copyright Keysight Technologies 2002 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include "StringState.h"

//* A state with instrument type.
  
class InstrumentState : public StringState
{
public:
  ///
  InstrumentState();
  ///
  InstrumentState(const InstrumentState &);
  ///
  InstrumentState& operator=(const char *);
  ///
  InstrumentState& operator=(const InstrumentState &);

  /// return the string "INSTRUMENT"
  const char* type() const { return "INSTRUMENT"; }

  ///@name Class identification
  //@{
  /// 
  int isA(const char*) const;
  /// 
  const char* className() const {return "InstrumentState";}
  //@}

};
MULTISTATE(InstrumentState,InstrumentMultiState)
#endif


