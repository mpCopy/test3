#ifndef FLAGMANAGER_H_INCLUDED
#define FLAGMANAGER_H_INCLUDED
// Copyright Keysight Technologies 1999 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include "type.h"
#include "FlagArray.h"
#include "HPtolemyError.h"
#include "gui_stdlib.h"
#include <iostream>

/** A class to manage the flags of a class.  

    In UCB Ptolemy, there is FlagArray in class NamedObj which is
    intended to be used for Schedulers and Targets.  Unfortunately, it
    is too easy to corrupt these flags by having two independent
    pieces of code accidently changing the same flag locations.

    For HP Ptolemy, we have developed the class {\tt
    FlagManager} and {\tt Flag} to give the programmer 
    access to more robust flags. The runtime overhead is negligible 
    while greatly increasing the robustness of the code.

    @author Jose Luis Pino
    @see \Ref{Flag}, \Ref{FlagArray}, \Ref{FlagArray} */
class FlagManager {
  friend class Flag;
  friend std::ostream& operator << (std::ostream& o, const FlagManager& a);

public:
  /// Default constructor
  FlagManager();

protected:
  /// return location
  int reserve(int location=-1);

private:
  ///
  void release(int location);

  /// Contains the total number of references
  FlagArray reservations;

  ///
  int firstEmpty;

};

/** A class to reserve a flag.
    
    @author Jose Luis Pino*/
class Flag {
  friend std::ostream& operator << (std::ostream& o, const Flag& a);
public:
  /// Constructors
  //@{
  /// Default
  Flag();

  /// Construct a Flag to point to the same location as another
  Flag(const Flag&);
  //@}

  /// Destructor
  ~Flag();
  
  /// Set this Flag to point to the same flag as another.
  Flag& operator = (const Flag&);

protected:

  /// 
  inline int& flag(FlagArray& r) {
    return r[location];
  }

  /// 
  inline const int flag(const FlagArray& r) const {
    return r[location];
  }

  void initialize(FlagManager *);

private:

  ///
  FlagManager* flagManager;

  ///
  int location;
};

/** Operator to output a FlagArray to an ostream. */
std::ostream& operator << (std::ostream& o, const FlagArray& a);

/** Operator to output a Flag to an ostream. */
std::ostream& operator << (std::ostream& o, const Flag& a);

/** Operator to output a FlagManager to an ostream. */
std::ostream& operator << (std::ostream& o, const FlagManager& a);

#endif   /* FLAGMANAGER_H_INCLUDED */
