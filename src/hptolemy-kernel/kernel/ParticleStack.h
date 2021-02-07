/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/ParticleStack.h,v $ $Revision: 100.9 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef PARTICLESTACK_H_INCLUDED
#define PARTICLESTACK_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifndef _ParticleStack_h
#define _ParticleStack_h
/***************************************************************
Version identification:
@(#)ParticleStack.h	2.7	8/26/95

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

 Programmer:  J. T. Buck
 Date of creation: 10/31/90
 Revisions:

***************************************************************/
#ifdef __GNUG__
#pragma interface
#endif

#include "Particle.h"




/** An efficient base class for the implementation of
  structures that organize Particles.  As Particles have a link field,
  ParticleStack is simply implemented as a linked list of Particles.

  Strictly speaking, a dequeue is implemented; particles can be
  inserted from either end.  ParticleStack has some odd attributes; it
  is designed for very efficient implementation of Geodesic and Plasma
  to move around large numbers of Particle objects very efficiently.  */
class ParticleStack {
public:
  /// Push {\tt p} onto the top (or head) of the ParticleStack
  inline void put(Particle* p) {
    if (!pHead) pTail = p;
    p->link = pHead; pHead = p;
  }

  /** Pop the particle off the top (or head) of the ParticleStack.
  
    {\bf WARNING}: The get method does NOT check for an empty
    ParticleStack; derived classes of the class must use the empty()
    method to check this.*/
  inline Particle* get() {
    Particle* p = pHead;
    pHead = p->link;
    return p;
  }

  /// Add {\tt p} at the bottom (or tail) of the ParticleStack
  inline void putTail(Particle* p) {
    if (pHead) pTail->link = p;
    else pHead = p;	// first particle
    pTail = p;	// point to new last particle
    p->link = 0;	// terminate the chain
  }

  /// Return TRUE (1) if the ParticleStack is empty, otherwise 0
  inline int empty() const { return pHead ? 0 : 1;}

  /** Return TRUE (1) if the ParticleStack has two or more particles,
    otherwise 0.  This is provided to speed up the derived class
    Plasma a bit.  */
  inline int moreThanOne() const { return (pHead && pHead->link) ? 1 : 0;}

  /** Constructor.  The constructor takes a Particle pointer.  If it
    is a null pointer an empty ParticleStack is created.  Otherwise
    the stack has one particle.  Adding a Particle to a ParticleStack
    modifies that Particle's link field; therefore a Particle can
    belong to only one ParticleStack at a time.  */
  ParticleStack(Particle*h) : pHead(h), pTail(h) {
    // make sure the stack is "terminated"
    if (h) h->link = 0;
  }

  /** Destructor -- delete all particles.  The destructor deletes all
    Particles EXCEPT for the last one; we do not delete the last one
    because it is the ``reference'' particle (for Plasma) and is
    normally not dynamically created (this code may be moved in a
    future release to the Plasma destructor, as this behavior is
    needed for Plasma and not for other types of ParticleStack).  */
  ~ParticleStack ();

  /// Returns all Particles on the stack to their {\tt \Ref{Plasma}}
  void freeup ();

  /// Return a pointer to the head
  inline Particle* head() const { return pHead;}

  /// Return a pointer to the tail
  // note that for an empty stack, pTail may not be 0,
  // hence the following code:
  inline Particle* tail() const { return pHead ? pTail : 0;}
private:
  /// 
  Particle* pHead;
  /// 
  Particle* pTail;
};
#endif

#endif   /* PARTICLESTACK_H_INCLUDED */
