/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Star.h,v $ $Revision: 100.28 $ $Date: 2012/03/08 18:10:56 $ */

#ifndef STAR_H_INCLUDED
#define STAR_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

/*@(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Star.h,v $ $Revision: 100.28 $ $Date: 2012/03/08 18:10:56 $ */

/******************************************************************
UCB Version identification: Star.h	2.25	1/12/96

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

 Programmer:  E. A. Lee and D. G. Messerschmitt
 Date of creation: 12/15/89

 Star is a Block that implements an atomic function...the
 Scheduler calls Stars at runtime to execute the simulation

*******************************************************************/

#include "Block.h"
#include "ptolemyDll.h"

class Galaxy;
class Target;
class Wormhole;

/// Name for default location
HPTOLEMY_KERNEL_API extern const char* DEFAULT_LOCATION;  

/** A basic executable atomic version of Block.  It is derived from
  {\tt \Ref{Block}}.

  Stars have an associated {\tt \Ref{Target}}, an index value, and an
  indication of whether or not there is internal state.

  The default constructor sets the target pointer to null, sets the
  internal state flag to TRUE, and sets the index value to -1.  */
class Star : public Block  {
public:
  // The writer of a Star code has the option to
  // provide the methods setup, begin, go, and wrapup.
  // Any Block, however, may have setup and wrapup.

  /// Constructor
  Star() : indexValue(-1), 
    inStateFlag(TRUE) {}

  /// Destructor
  ~Star();
  
  /// Initialization that is called after Scheduler::setup()
  virtual void begin () {}

  /** Execute the Star.  This method also interfaces to the SimControl
    class to provide for control over simulations.  All derived
    classes that override this method must invoke {\tt Star::run}.*/
  /*virtual*/ int run();

  /// Return a StringList with a description
  /*virtual*/ StringList print (int verbose = 0) const;

  /// Return myself as a Star
  /*virtual*/ Star& asStar();

  /// Return myself as a Star, const version
  /*virtual*/ const Star& asStar() const;

  /** Return the index value for this star.  Index values are a
    feature that assists with certain schedulers; the idea is to
    assign a numeric index to each star at any level of a particular
    Universe or Galaxy.

    The index is set by the {\tt \Ref{setStarIndices}} function.*/
  int index() const { return indexValue;}

  /// Declare that this star has no internal state
  void noInternalState() { inStateFlag = FALSE; }

  /** Return TRUE if this star has internal state, false if it doesn't.
    Useful in parallel scheduling.*/
  int hasInternalState() { return inStateFlag; }

  /// Return TRUE if the argument is a Star
  /*virtual*/ int isA(const char*) const;
  
  /// Return the string ``Star''
  /*virtual*/ const char* className() const;

  /// Return a pointer to myself as a wormhole, NULL if I am not
  virtual Wormhole* asWormhole();

  /** Make a duplicate Star.  This will call Block::clone and then set
    Star specific data members such as the target pointer.

    @see Block::clone*/
  /*virtual*/ Block* clone () const;

  /// Set the target associated with this star
  /*virtual*/ int setTarget(Target*);

  // Provides support for updating parameters during simulation run time.  
  enum CallingMethod { PREINIT, SETUP, BEGIN, TUNE, GO, WRAPUP };
  virtual void updateState(CallingMethod calledFrom) 
  { 
      calledFrom; //unused.
  }

  PortHole* createPort(const char* pName, PortDirectionE eDirection);
  MultiPortHole* createMultiPort(const char* pName, PortDirectionE eDirection);

protected:
  /** Provides the principal action of executing this block.
  
    This is a method that is intended to be overridden to provide
    the principal action of executing this block.  It is protected and
    is intended to be called from the {\tt run()} member function.
    The separation is so that actions common to a domain can be
    provided in the run function, leaving the writer of a functional
    block to only implement {\tt go()}.*/
  virtual void go();

  virtual MultiPortHole* newMultiPort(PortDirectionE) 
  { 
	  // NOT SUPPORTED
	  return 0;
  };

  virtual PortHole* newPort(PortDirectionE)  
  { 
	  // NOT SUPPORTED
	  return 0;
  };

private:

	PortList portsToDelete;
	MPHList multiportsToDelete;

  int indexValue;
  int inStateFlag; // indicate there are internal states (default)
  friend int setStarIndices(Galaxy&);
};

/** Attribute to declare that a star needs to be used in conjunction
  with external analog components to model its behavior*/
HPTOLEMY_KERNEL_API extern const Attribute S_ANALOG; 

/// Attribute to declare that a star should be hidden from the outside world
HPTOLEMY_KERNEL_API extern const Attribute S_HIDDEN;

// attribute bit definitions.  The kernel reserves the next two bits
// (8, 16) for future expansion; domains may use higher-order bits
// for their own purposes

/** Attribute bit to declare that a star needs to be used in
  conjunction with external analog components to model its behavior*/
const bitWord SB_ANALOG = 2;

/// Attribute bit to declare that a star should be hidden from the outside world
const bitWord SB_HIDDEN = 4;

/** Set the indicies for all of the stars in a galaxy.  A {\tt
  \Ref{Star}} can have index for use in table-driven schedulers.  To
  access the index, use the method {\tt \Ref{Star::index}}.

  Returns the total number of stars.*/
int setStarIndices(Galaxy&);

#endif   /* STAR_H_INCLUDED */
