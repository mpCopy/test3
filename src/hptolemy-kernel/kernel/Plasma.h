/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Plasma.h,v $ $Revision: 100.11 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef PLASMA_H_INCLUDED
#define PLASMA_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifndef _Plasma_h
#define _Plasma_h 1

#ifdef __GNUG__
#pragma interface
#endif
/**************************************************************************
Version identification:
@(#)Plasma.h	1.12	8/26/95

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

 Programmer:  J. Buck
 Date of creation: 10/31/90
 Revisions:
	The original version of Plasma was by D. Messerschmitt and
	E. A. Lee.  This version has been modified considerably; it
	is derived from ParticleStack, which uses members of the
	Particles themselves to form a stack.

A Plasma is a collection of currently unused Particles

Particles no longer needed are added to the Plasma; any
OutPortHoles needing a Particle gets it from the Plasma

There is precisely one global instance of Plasma for each
Particle type needed -- this common pool makes more
efficient use of memory.  The static member plasmaList
is a list of all global Plasmas.  Each global Plasma is a
node on the linked list plasmaList.

There may also be any number of local Plasmas of each type, which
permit separate pools to be used for a given subsystem.  When a
local Plasma runs out of particles, it obtains them from the
corresponding global Plasma.  The advantage of local Plasmas
is for multithreading: if both ends of the local Plasma are in
the same thread, no lock is needed.

***************************************************************/

#include "ParticleStack.h"
#include "PtGate.h"




/** A pool for particles of a particular type.  It is derived from
  ParticleStack (class \Ref{ParticleStack}).  Rather than allocating
  Particles as needed with {\tt new} and freeing them with {\tt
  delete}, we instead provide an allocation pool for each type of
  particle, so that very little dynamic memory allocation activity
  will take place during simulation runs.

  There is precisely one global instance of Plasma for each Particle
  type needed -- this common pool makes more efficient use of memory.
  The static member plasmaList is a list of all global Plasmas.  Each
  global Plasma is a node on the linked list plasmaList.

  There may also be any number of local Plasmas of each type, which
  permit separate pools to be used for a given subsystem.  When a
  local Plasma runs out of particles, it obtains them from the
  corresponding global Plasma.  The advantage of local Plasmas is for
  multithreading: if both ends of the local Plasma are in the same
  thread, no lock is needed.

  At all times, a Plasma has at least one Particle in it; that
  Particle's virtual functions are used to clone other particles as
  needed, determine the type, etc.

  The constructor takes one argument, a reference to a Particle.  It
  creates a one-element ParticleStack, and links the Plasma into a
  linked list of all Plasma objects.

  The {\tt put} function (for putting a particle into the Plasma) adds
  a particle to the Plasma's ParticleStack.  As a rule, it should not
  be used directly; the Particle's {\tt die} method will automatically
  add it to the right Plasma (future releases may protect this method
  to prevent its general use).*/
class Plasma : public ParticleStack {
    friend class PlasmaGate;
public:
  /** Constructor.  By default, we make global Plasmas.  If globalP is
    non-null, we are making a local Plasma and globalP is the
    corresponding global Plasma.*/
  Plasma(Particle& p,Plasma* globalP = 0);

  /// Destructor
  virtual ~Plasma() {};

  /// Put a Particle into the Plasma
  inline void put(Particle* p) {
    if (gate == 0)
      ParticleStack::put(&(p->initialize()));
    else slowPut(p);
  }

  /** Get a Particle from the Plasma.  This function will create a new
    one if the Plasma has only one Particle on it (we never give away
    the last Particle).  We do it inline for the fastest case.*/
  inline Particle* get() {
    return (moreThanOne() && gate == 0) ? ParticleStack::get()
      : slowGet();
  }

  /** Returns the type of the particles on the list (obtained by
    asking the head Particle).  */
  inline ADSPtolemy::DataType type() const { return head()->type();}

  /// Return TRUE if Plasma local
  inline int isLocal() const { return localFlag;}

  /** Get the appropriate global Plasma object given a type.  Searches
    the list of Plasmas for one whose type matches the argument, and
    returns a pointer to it.  A null pointer is returned if there is
    no match.*/
  static Plasma* getPlasma (ADSPtolemy::DataType t);

  /// Create a local Plasma object given a type
  static Plasma* makeNew (ADSPtolemy::DataType t);

  /** Create a lock for the Plasma, because it crosses thead
    boundaries.  A do-nothing for global plasmas.*/
  void makeLock(const PtGate& master);

  /// Delete lock for the Plasma.  No effect on global plasmas.
  void delLock();

  /** Increment reference count, when adding reference from PortHole
    to a local Plasma.  New count is returned.  Global Plasmas pretend
    their count is always 1.*/
  inline short incCount() { return localFlag ? ++refCount : 1;}

  /** Decrement reference count, when removing reference from PortHole
    to a local Plasma.  New count is returned.  Idea is we can delete
    it if it drops to zero.  Global Plasmas pretend their count is
    always 1.*/
  inline short decCount() { return localFlag ? --refCount : 1;}
	
protected:
  /// General implementation of "get"
  virtual Particle* slowGet();
  /// General implementation of "put"
  virtual void slowPut(Particle*);

private:
  /// The global list of Plasmas (points to head of chain of Plasmas)
  static Plasma* plasmaList;
  /// pointer to next Plasma on the list
  Plasma* nextPlasma;
  /// gate for locking
  PtGate* gate;
  /// flag, true if local
  short localFlag;
  /// reference count for local Plasmas.
  short refCount;
};

/** A {\tt \Ref{GateKeeper}} that can read a {\tt \Ref{Plasma}} gate.  */
class PlasmaGate : public GateKeeper {
public:
  /// 
  PlasmaGate(Plasma& plas) : GateKeeper(plas.gate) {}
};

#endif

#endif   /* PLASMA_H_INCLUDED */
