/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Geodesic.h,v $ $Revision: 100.12 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef GEODESIC_H_INCLUDED
#define GEODESIC_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifndef _Geodesic_h
#define _Geodesic_h 1

#ifdef __GNUG__
#pragma interface
#endif

/****************************************************************
Version identification:
@(#)Geodesic.h	2.21	8/26/95

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

 Programmer: J. T. Buck
 (original version of Geodesic was in Connect, by E. A. Lee and
  D. G. Messerschmitt -- this one is quite different)

*****************************************************************/

#include "NamedObj.h"
#include "ParticleStack.h"




class GenericPort;
class PortHole;
class PtGate;
class Plasma;

/** A connection between a set of PortHoles.

  A Geodesic implements the connection between a pair, or a larger
  collection, of PortHoles.  A Geodesic may be temporary, in which
  case it is deleted when the connection it implements is broken, or
  it can be permanent, in which case it can live in disconnected form.
  As a rule, temporary geodesics are used for point-to-point
  connections and permanent geodesics are used for netlist
  connections.  In the latter case, the Geodesic has a name and is a
  member of a galaxy; hence, Geodesic is derived from NamedObj (class
  \Ref{NamedObj}).

  The base class Geodesic, which is temporary, suffices for most
  simulation and code generation domains.  In fact, in a number of
  these domains it contains unused features, so it is perhaps too
  ``heavyweight'' an object.  A Geodesic contains a ParticleStack
  member which is used as a queue for movement of Particles between
  two portholes; it also has an originating port and a destination
  port.

  A Geodesic can be asked to have a specific number of initial
  particles.  When initialized, it creates that number of particles in
  its ParticleStack; these particles are obtained from the Plasma of
  the originating port (so they will be of the correct type).  */
class Geodesic : public NamedObj {
  friend class AutoFork;	// used to make auto-forking geodesics
public:
  /** Set the source port and the number of initial particles.  The
    actual source port is determined by calling {\tt newConnection} on
    {\tt src}; thus if {\tt src} is a MultiPortHole, the connection
    will be made to some port within that MultiPortHole, and aliases
    will be resolved.  The return value is the ``real porthole'' used.

    In the default implementation, if there is already a destination
    port, any preexisting connection is broken and a new connection is
    completed.  */
  virtual PortHole* setSourcePort (GenericPort &, int numDelays = 0,
				   const char* initDelayValues = 0);

  /** Set the destination port. The
    return value is the ``real porthole'' used.

    In the default implementation, if there is already a source port,
    any preexisting connection is broken and a new connection is
    completed.  */
  virtual PortHole* setDestPort (GenericPort &);

  /** Disconnect from porthole.
  
    In the default implementation, if {\tt p} is either the source
    port or the destination port, both the source port and destination
    port are set to null.  This is not enough to break a connection;
    as a rule, {\tt disconnect} should be called on the porthole, and
    that method will call this one as part of its work.  */
  virtual int disconnect (PortHole & p);

  /** Modify the delay (number of initial tokens) of a connection.
    The default implementation simply changes a count.  */
  virtual void setDelay (int numDelays, const char* initDelayValues = 0);

  /** Return true if the Geodesic is persistent (may exist in a
    disconnected state) and false otherwise.  The default
    implementation returns false.*/
  virtual int isItPersistent() const;

  /// Return my source port
  inline PortHole* sourcePort () const { return originatingPort;}
 
  /// Return my destination port
  inline PortHole* destPort () const   { return destinationPort;}

  /// Constructor
  Geodesic();

  /// Class identification
  int isA(const char*) const;

  /// Destructor -- virtual since we have subclasses
  virtual ~Geodesic();

  /** Initialize the buffer with numInitialParticles.

    In the default implementation, this function initializes the
    number of Particles to that given by the numInitialParticles field
    (the value returned by {\tt numInit()}; these Particles are
    obtained from the Plasma (allocation pool) for the source port.
    The particles will have zero value for numeric particles, and will
    hold the ``empty message'' for message Particles.*/
  virtual void initialize();

  /** initialize the buffer with unrolling factor */
  virtual void initialize(int);

  /** Return the plasma associated with this Geodesic. */
  Plasma* plasma();

  /** Put a particle into the Geodesic (using a FIFO discipline). Note
    that this is not virtual but \Ref{slowPut} is virtual.*/
  inline void put(Particle* p) {
    if (gate == 0) { 
      pstack.putTail(p); sz++;
    }
    else slowPut(p);
  }

  /** Retrieve a particle from the Geodesic (using a FIFO discipline).
    Return a null pointer if the Geodesic is empty. Note that this is
    not virtual but \Ref{slowGet} is virtual.*/
  inline Particle* get() {
    return (sz > 0 && gate == 0)
      ? (sz--, pstack.get()) : slowGet();
  }

  /** Push a Particle back into the Geodesic (onto the front of the
    queue, instead of onto the back of the queue as {\tt put} does).*/
  virtual void pushBack(Particle* p);

  /// Return the number of Particles in the Geodesic
  inline int size() const {return sz;}

  /** Return the number of initial particles.  This call is valid at
    any time.  Immediately after {\tt initialize}, {\tt size} and {\tt
    numInit} return the same value (and this should be true for any
    derived Geodesic as well), but this will not be true during
    execution (where {\tt numInit} stays the same and {\tt size}
    changes).*/
  inline int numInit() const {return numInitialParticles;}

  /// Access head of queue
  Particle* head() const;

  /// Access tail of queue
  Particle* tail() const;

  /// Print information on the Geodesic
  StringList print(int verbose = 0) const;

  /**@name Methods are available for schedulers
   
    These methods are available for schedulers such as the SDF
    scheduler to simulate a run and keep track of the number of
    particles on the geodesic.  They are virtual to allow additional
    bookkeeping in derived classes.*/
  //@{
  /// Increases the count
  virtual void incCount(int);
  /// Decreases the count
  virtual void decCount(int);
  /// Asserts that the maximum length the buffer
  virtual void setMaxArcCount(int);
  //@}
  
  /// Return the maximum numberof particles
  inline int maxNumParticles() const { return maxBufLength;}


  /**@name Locking functions */
  //@{
  /** Create a lock for the Geodesic, because it crosses thead
    boundaries*/
  virtual void makeLock(const PtGate& master);

  /// Delete lock for the Geodesic
  virtual void delLock();

  /// 
  inline int isLockEnabled() const { return gate != 0;}

  //@}

  /// Return the initValues string
  const char * initDelayValues();

protected:
  /** This function completes a connection if the originating and
    destination ports are set up.*/
  void portHoleConnect();

  /// Slow (virtual) version of {\tt \Ref{get}}
  virtual Particle* slowGet();
  /// Slow (virtual) version of {\tt \Ref{put}}
  virtual void slowPut(Particle*);

  /**@name My neighbors */
  //@{
  /// 
  PortHole *originatingPort;
  /// 
  PortHole *destinationPort;
  //@}

  /** Maximum number of particles ever on geodesic.  By default, only
    affected by incCount, decCount, and setMaxArcCount.*/
  int maxBufLength;

  /// Lock for the Geodesic
  PtGate* gate;

  /// Where the particles live
  ParticleStack pstack;

  /// Number of particles
  int sz;

  /// The number of initial particles.
  int numInitialParticles;

  /** String specifing the values of the initial particles.
    The string is kept in InterpGalaxy's initList.*/
  const char *initValues;
};
#endif

#endif   /* GEODESIC_H_INCLUDED */
