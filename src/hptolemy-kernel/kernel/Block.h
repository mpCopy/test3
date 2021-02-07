/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Block.h,v $ $Revision: 100.27 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef BLOCK_H_INCLUDED
#define BLOCK_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#ifdef __GNUG__
#pragma interface
#endif

/****************************************************************
UCB Version identification: 2.28	6/21/96

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

Programmer:  E. A. Lee, D. G. Messerschmitt, J. Buck
Date of creation: 1/17/90

*********************************************************************/

#include "NamedObj.h"
#include "PortHole.h"
#include "State.h"
#include "FlagManager.h"
#include "NetlistName.h"
#include "ptolemyDll.h"


class Star;
class Galaxy;
class Scheduler;
class Target;
class Scope;

/// A reserved flag for class Block
class BlockFlag:public Flag {
public:
  /// Constructors
  //@{
  ///
  BlockFlag();
  ///
  BlockFlag(BlockFlag&);
  //@}

  /// 
  inline int& flag(Block& b);
  /// 
  inline const int flag(const Block& b) const;

private:
  FlagManager* myFlagManager();
  HPTOLEMY_KERNEL_API static FlagManager* blockFlagManager;
};

/** The basic object for representing an actor in Ptolemy.

  Important derived types of Block are \Ref{Star}, representing an
  atomic actor; \Ref{Galaxy}, representing a collection of actors that
  can be thought of as one actor, and \Ref{Universe}, representing an
  entire runnable system.

  A Block has \Ref{PortHole}s (connections to other blocks)
  \Ref{State}s (parameters and internal states, and
  \Ref{MultiPortHole}s (organized collections of portholes.

  While the exact data structure used to represent each is a secret of
  class Block, it is visible that there is an order to each list, in
  that iterators return the contained states, portholes, and
  multiportholes in this order.  Iterators (see \Ref{Iterators}) are a
  set of helper classes that step through the states, portholes, or
  multiportholes that belong to the Block, see the menu entry.

  Furthermore, Blocks can be cloned, an operation that produces a
  duplicate block.  There are two cloning functions: \Ref{makeNew},
  which resembles making a new block of the same class, and
  \Ref{clone}, which makes a more exact duplicate (with the same
  values for states, for example).  This feature is used by the
  \Ref{KnownBlock} class to create blocks on demand.*/
class Block : public NamedObj 
{

  // Give iterator classes special access.
  friend class BlockInputIter;
  friend class BlockOutputIter;
  friend class FastBlockInputIter;
  friend class FastBlockOutputIter;
  friend class BlockPortIter;
  friend class BlockStateIter;
  friend class BlockMPHIter;
  
  // These are defined in ConstIters.h.
  friend class CBlockInputIter;
  friend class CBlockOutputIter;
  friend class CBlockPortIter;
  friend class CBlockStateIter;
  friend class CBlockMPHIter;
  
  // Scope is defined Scope.h.  Scope needs
  // access to the block state list to clone it.
  friend class Scope;

  friend class BlockFlag;

  // setNameParams needs access to netlistNm
  friend class KnownBlock;
    
public:
  /**@name Constructors and destructors */
  //@{
  /** Constructor - sets the name and descriptor to empty
    strings and the parent pointer to null*/
  Block();
  
  /// Constructor - sets the name, descriptor and parent
  Block(const char* name, Block* parent, const char* desc);

  /// Destructor
  ~Block();
  //@}

  /**@name Virtual constructors */
  //@{
  /** Make a new object of the same type.

    This is a very important function.  It is intended to be
    overloaded in such a way that calling it produces a newly
    constructed object of the same type.  The default implementation
    causes an error.  Every derived type should redefine this
    function.  Here is an example implementation of an override for
    this function:

    \begin{verbatim}
    Block* MyClass::makeNew () const {return new MyClass;} 
    \end{verbatim} */
  virtual Block* makeNew () const;

  /** Make a duplicate object.  The distinction between {\tt clone}
    and {\tt makeNew} is that the former does some extra copying.  The
    default implementation calls {\tt makeNew} and then {\tt
    copyStates}, and also copies additional members like {\tt flags};
    it may be overridden in derived classes to copy more information.
    The intent is that {\tt clone} should produce an identical
    object.*/
  virtual Block* clone () const;
  //@}

  /**@name Information methods */
  //@{
  
  /// Return the full name, using the scoping block hierarchy
  /*virtual*/ StringList fullName() const;

  /// Return my domain (e.g. SDF, DE, etc.)
  virtual const char* domain() const;

  /// Return the netlist name
  const NetlistName& netlistName() const { return netlistNm; }

  /** Return the controlling \Ref{Scheduler} for this block. The
    default implementation simply recursively calls the {\tt
    scheduler()} function on the parent, or returns 0 if there is no
    parent.  The intent is that eventually a block with a scheduler
    will be reached (the top-level universe has a scheduler, and so do
    wormholes).*/
  virtual Scheduler* scheduler() const;

  /// Return the block which defines the lexical \Ref{Scope} of our states
  Scope* scope() const;
 
  /// Return the target that is in charge of this block
  Target* target() const;

  /**@name Class identification */
  //@{
  /// Returns TRUE if argument is a {\tt Block}
  int isA(const char*) const;

  /// Returns the string ``Block''
  const char* className() const;
  //@}

  /**@name Number */
  //@{
  /// Return the number of ports
  inline int numberPorts() const {return inputPorts.size() + outputPorts.size();}

  /// Return the number of ports
  inline int numberInputs() const {return inputPorts.size(); }

  /// Return the number of ports
  inline int numberOutputs() const {return outputPorts.size();}

  /// Return the number of multiports
  inline int numberMPHs() const {return multiports.size();}

  /// Return number of states 
  inline int numberStates() const {return states.size();}
  //@}

  /**@name Tests */
  //@{
  /// Return TRUE if this a star or wormhole, FALSE for galaxies.
  virtual int isItAtomic () const; // {return TRUE;}

  /// Return TRUE if this is a \Ref{Wormhole}
  virtual int isItWormhole () const; // {return FALSE;}

  /// Return TRUE if this is a \Ref{Cluster}
  virtual int isItCluster () const; // {return FALSE;}
  //@}

  /**@name Return the object with a given name */
  //@{
  /// Retrieve the PortHole or MultiPortHole with the given name
  GenericPort *genPortWithName (const char* name);

  /** Retrieve the PortHole or MultiPortHole with the 
    given name, const version.*/
  const GenericPort *genPortWithName (const char* name) const;

  /// Retrieve the PortHole with the given name
  PortHole *portWithName(const char* name);

  /// Retrieve the PortHole with the given name, const version
  inline const PortHole *portWithName(const char* name) const {
    const PortHole* port = inputPorts.portWithName(name);
    if (!port) 
      port=outputPorts.portWithName(name);
    return port;
  }

  /// Retrieve the MultiPortHole with the given name
  inline MultiPortHole *multiPortWithName(const char* name) {
    return multiports.multiPortWithName(name);
  }

  /** Retrieve the MultiPortHole with the given name, 
    const version.*/
  inline const MultiPortHole *multiPortWithName(const char* name)
    const {
    return multiports.multiPortWithName(name);
  }

  /// Retrieve the State with the given name
  virtual State *stateWithName(const char* name);
  //@}


  /**@name Info-printing methods */
  //@{
  /// Returns a StringList describing this block
  /*virtual*/ StringList print(int verbose) const;

  /// Print portholes as part of the info-printing method
  StringList printPorts(const char* type, int verbose) const;

  /// print states as part of the info-printing method
  StringList printStates(const char* type,int verbose) const;

  /// Get a list of contained PortHole names
  int portNames (const char** names, const char** types,
		 int* io, int nMax) const;

  /// Get a list of contained MultiPortHole names
  int multiPortNames (const char** names, const char** types,
		      int* io, int nMax) const;
  //@}

  /**@name ``As'' methods */
  //@{
  /** Return reference to me as a Star, if I am one.  Warning: it is a
    fatal error (the entire program will halt with an error message)
    if this method is invoked on a Galaxy!  Check with {\tt
    isItAtomic} before calling it.*/
  virtual Star& asStar();

  /// Return reference to Block as a Star, const version
  virtual const Star& asStar() const;

  /** Return reference to me as a Galaxy, if I am one.  Warning: it is
    a fatal error (the entire program will halt) if this method is
    invoked on a Star!  Check with {\tt isItAtomic} before calling
    it.*/
  virtual const Galaxy& asGalaxy() const;

  /// Return reference to Block as a Galaxy, const version
  virtual Galaxy& asGalaxy();
  //@}

  //@}
  
  /**@name Simulation methods */
  //@{
  
  /** Pre-initialization pass.  This methods does nothing in most
  Blocks, but stars that rearrange galaxy connections (such as HOF
  stars) need to run before regular initialization.*/
  virtual void preinitialize();

  /**@name Initialization methods */
  //@{
  /** Initialize the portholes and states belonging to the block and
    calls {\tt \Ref{setup}()}, which is intended to be the
    ``user-supplied'' initialization function.*/
  /*virtual*/ void initialize();
  /// Initialize all of states that are in the state list
  virtual void initState();

  /// Initialize all of the ports that are in the port list
  virtual void initPorts();
  //@}

  /// ``Run'' the block - default implementation does nothing
  virtual int run();

  /** Clean up after the completion of execution of a universe.  This
    function is intended to be run after the completion of execution
    of a universe, and provides a place for wrapup code.  The default
    does nothing.*/
  virtual void wrapup();
  //@}

  /**@name Configuration methods */
  //@{
  /// Set the name and optionally set the parent of a block
  virtual Block& setBlock(const char* s, Block* parent = NULL);

  /// Add a porthole
  inline void addPort(PortHole& p) {
    if (p.isItInput())
      inputPorts.put(p);
    else
      outputPorts.put(p);
  }



  /// Add a multiporthole
  inline void addPort(MultiPortHole& p) {multiports.put(p);}

  /** Remove {\tt port} from the Block's port list, if it is present.
  TRUE is returned if {\tt port} was present and FALSE is returned
  if it was not.  Note that {\tt port} is not deleted.  The
  destructor for class PortHole calls this function on its parent
  block.*/
  int removePort(PortHole& port);

  /** Remove {\tt port} from the Block's multiport list, if it is present.
  TRUE is returned if {\tt port} was present and FALSE is returned
  if it was not.  Note that {\tt port} is not deleted.  The
  destructor for class PortHole calls this function on its parent
  block.*/
  int removeMultiPort(MultiPortHole& port);

  /// Add a state
  inline void addState(State& s) {states.put(s);}

  /** Add a new state before an existing state.  If the existing
      state is not on the list, prepend new state to the list. */
  inline void addStateBefore(State& newState, State& existingState) {
    states.putBefore(newState,existingState);
  }

  /** Add a new state after an existing state.  If the existing
      state is not on the list, append new state to the list. */
  inline void addStateAfter(State& newState, State& existingState) {
    states.putAfter(newState,existingState);
  }

  /** Set the value of a state - returns false if no state named
    stateName.  Search for a state in the block named {\tt stateName}.
    If not found, return 0.  If found, set its initial value to {\tt
    expression} and return 1.*/
  virtual int setState(const char* stateName, const char* expression);

  /// Set the target for this block
  virtual int setTarget(Target*);

  /// Set the lexical scope for our states
  void setScope(Scope*);
 
  /// Set the library location name 
  inline void setLocation(const char* l) {locationString = l;};

  /// Return the location name
  inline const char* location() const { return locationString;};

  /// Set the vendor 
  inline void setVendor(const char* v) {netlistNm.setVendor(v);};

  //@}

  /**  Method for copying states during cloning.  It is designed for
    use by clone methods, and it assumes that the src argument has the
    same state list as the {\tt this} object.*/
  Block* copyStates(const Block&);
protected:
  /** User-specified additional initialization.  By default, it does
    nothing.  It is called by {\tt \Ref{Block::initialize}} (and
    should also be called if initialize is redefined).*/
  virtual void setup();

  /** Delete all states.  This must not be called unless the States
    are on the heap!*/
  inline void deleteAllStates() { states.deleteAll();}

  /** Delete all ports and multiports.  This must not be called unless
    the ports and multiports are on the heap!  Note that multiports
    must be deleted before the ports. */
  inline void deleteAllGenPorts() {
    multiports.deleteAll();
    inputPorts.deleteAll();
    outputPorts.deleteAll();
  }

  // Netlist name of the object
  NetlistName netlistNm;

private:
  // Library name for stars
  // Obtained from pl file location{} field
  const char* locationString;

  Target* pTarget;

  // The scope our states belong.
  Scope* scp;

  /// Input portholes
  PortList inputPorts;

  /// Output portholes
  PortList outputPorts;
	
  // stateWithName can find a state.
public:
  StateList states;
private:

  // This is a list of multiportholes in the block.
  MPHList multiports;

  // The FlagArray
  FlagArray blockFlags;

};

/// An iterator over a block's inputs (see \Ref{Iterators}).
class BlockInputIter: public PortListIter {
public:
  /// 
  inline BlockInputIter(Block& b):PortListIter(b.inputPorts) {};
};

/// An iterator over a block's outputs (see \Ref{Iterators}).
class BlockOutputIter: public PortListIter {
public:
  /// 
  inline BlockOutputIter(Block& b):PortListIter(b.outputPorts) {};
};

/// A fast iterator over a block's inputs
class FastBlockInputIter : public FastPortListIter {
public:
  inline FastBlockInputIter(Block &b) : FastPortListIter(b.inputPorts) {}
};

/// A fast iterator over a block's outputs
class FastBlockOutputIter : public FastPortListIter {
public:
  inline FastBlockOutputIter(Block &b) : FastPortListIter(b.outputPorts) {}
};


/// An iterator over a block's ports (see \Ref{Iterators})
class BlockPortIter {
public:
  /// 
  BlockPortIter(Block& b): nextInput(b), nextOutput(b) {
    reset();
  }
  
  /// Methods to return the next porthole
  //@{
  /// Return the next porthole
  inline PortHole* operator++(POSTFIX_OP) { return next();}

  /// Return the next porthole
  inline PortHole* next() { 
    PortHole* port = nextPort->next();
    if (!testIterator(port))
      port = nextPort->next();
    return port;
  }

  /** Iterate over ports which are set at the PortFlag to flagValue.
      If test == NULL, this method functionally equivalent to
      next().*/
  inline PortHole* next(PortFlag* test, int flagValue=FALSE) {
    PortHole* port = nextPort->next(test,flagValue);
    if (!testIterator(port))
      port = nextPort->next(test,flagValue);
    return port;
  }

  /** Provided for backward compatibility to UCB Ptolemy, it is
      recommend to upgrade the code to use the {\tt PortFlag} class.*/
  inline PortHole* next(int flagLoc, int flagValue) {
    PortHole* port = nextPort->next(flagLoc,flagValue);
    if (!testIterator(port))
      port = nextPort->next(flagLoc,flagValue);
    return port;
  }
  //@}
  
  ///
  void reset() {
    nextInput.reset();
    nextOutput.reset();
    nextPort = &nextInput;
  }

  /// Remove the current port from the PortList
  void remove() {
    nextPort->remove();
  }

private:
  ///
  BlockInputIter nextInput;
  ///
  BlockOutputIter nextOutput;
  ///
  PortListIter* nextPort;
  ///
  inline int testIterator(const PortHole* p) {
    if (!p && (nextPort != &nextOutput)) {
      nextPort = &nextOutput;
      return FALSE;
    }
    else
      return TRUE;
  }
};

/// An iterator over a block's states  (see \Ref{Iterators})
class BlockStateIter : public StateListIter {
public:
  /// 
  BlockStateIter(Block& b) : StateListIter (b.states) {}
};

/// An iterator over a block's multiportholes (see \Ref{Iterators})
class BlockMPHIter : public MPHListIter {
public:
  /// 
  BlockMPHIter(Block& b) : MPHListIter (b.multiports) {}
};

/// A class used to register a block in the known lists
class RegisterBlock {
public:
  /// 
  RegisterBlock(Block& prototype);
};

inline int& BlockFlag::flag(Block& b) {
  return Flag::flag(b.blockFlags);
}

inline const int BlockFlag::flag(const Block& b) const {
  return Flag::flag(b.blockFlags);
}

#endif   /* BLOCK_H_INCLUDED */
