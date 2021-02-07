/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/PtGate.h,v $ $Revision: 100.13 $ $Date: 2011/08/25 01:47:10 $ */


#ifndef PTGATE_H_INCLUDED
#define PTGATE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  



#ifndef _PtGate_h
#define _PtGate_h 1
/**************************************************************************
Version identification:
@(#)PtGate.h	1.4	3/2/95

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

 Programmer:  J. T. Buck and T. M. Parks
 Date of creation: 6/14/93

This file defines classes that support multi-threading in the kernel.

**************************************************************************/

#ifdef __GNUG__
#pragma interface
#endif

#include "ptolemyDll.h"

#ifdef WIN32
#pragma warning(disable:4514)
#endif

/** A semaphore to obtain exclusive access to some resource.  Objects
  of classes derived from PtGate are used as semaphores to obtain
  exclusive access to some resource.  PtGate is an abstract base
  class: it specifies certain functionality but does not provide an
  implementation.  Derived classes typically provide the desired
  semantics for use with a particular threading library.  */
class PtGate {
  friend class CriticalSection;
public:
  /// 
  virtual ~PtGate();

  /** Make a new PtGate.  The {\tt makeNew} method returns a new
    object of the same class as the object it is called for, which is
    created on the heap.  For example, a hypothetical SunLWPGate
    object would return a new SunLWPGate.*/
  virtual PtGate* makeNew() const = 0;
protected:
  /**@name Locking and unlocking a resource
  
    If code in another thread calls {\tt lock()} on the same PtGate
    after {\tt lock()} has already been called on it, the second call
    will block until the first thread does an {\tt unlock()} call.
    Note that two successive calls to {\tt lock()} on the same PtGate
    from the same thread will cause that thread to hang.  It is for
    this reason that these calls are protected, not public.  Access to
    PtGates by user code is accomplished by means of another class,
    {\tt \Ref{CriticalSection}}.  The CriticalSection class is a
    friend of class PtGate.*/
  //@{
  /// Request access to a resource
  virtual void lock() = 0;

  /// Releases access to a resource
  virtual void unlock() = 0;
  //@}
};

class GateKeeper;

/** Provide a convenient way to implement critical sections of code.

  CriticalSection objects exploit the properties of constructors and
  destructors in C++ to provide a convenient way to implement {\em
  critical sections}: sections of code whose execution can be
  guaranteed to be atomic.  Their use ensures that data structures can
  be kept consistent even when accessed from multiple threads.  The
  CriticalSection class implements no methods other than constructors
  and a destructor.

  CriticalSection objects are used only for their side effects.  For
  example:

  \begin{verbatim}
PtGate& MyClass::gate;
...
void MyClass::updateDataStructure() \{
        CriticalSection region(MyClass::gate);
        code;
        ...
\}
\end{verbatim}

  The code between the declaration of the CriticalSection and the end
  of its scope will not be interrupted.  */
class CriticalSection {
public:
  /**@name Constructors - optionally set a lock*/
  //@{
  /// Set the lock on the given PtGate unless it gets a null pointer
  CriticalSection(PtGate* g) : mutex(g) {
    if (mutex) mutex->lock();
  }

  /// Set the lock on the given PtGate
  CriticalSection(PtGate& g) : mutex(&g) { mutex->lock();}

  /// Use the {\tt \Ref{GateKeeper}} to obtain access to the PtGate to lock 
  inline CriticalSection(GateKeeper& gk);

  //@}

  /// Free the lock, if a lock was set
  ~CriticalSection() { if (mutex) mutex->unlock();}
private:
  /// 
  PtGate* mutex;
};

const int GateKeeper_cookie = 0xdeadbeef;

/** A means of registering a number of PtGate pointers in a list.

  The GateKeeper class provides a means of registering a number of
  PtGate pointers in a list, together with a way of creating or
  deleting a series of PtGate objects all at once.  The motivation for
  this is that most Ptolemy applications do not use multithreading,
  and we do not wish to pay the overhead of locking and unlocking
  where it is not needed.  We also want to have the ability to create
  a number of fine-grain locks all at once.

  GateKeeper objects should be declared only at file scope (never as
  automatic variables or on the heap).

  {\bf WARNING}: Do not invoke {\tt GateKeeper::deleteAll} while a
  CriticalSection is alive, or a core dump will occur.*/
class GateKeeper {
  friend class CriticalSection;
public:
  /** Constructor. The argument is a reference to a pointer to a
    GateKeeper, and the function of the constructor is to add this
    reference to a master list.  It will later be possible to
    ``enable'' the pointer, by setting it to point to a newly created
    PtGate of the appropriate type, or ``disable'' it, by deleting the
    PtGate object and setting the pointer to null.  */
  GateKeeper(PtGate*& gateToKeep);

  /** Destructor - delete the reference from the master list.  The
    GateKeeper destructor deletes the reference from the master list
    and also deletes any PtGate object that may be pointed to by the
    PtGate pointer.*/
  virtual ~GateKeeper();

  /// Create a PtGate for each GateKeeper on the list
  static void enableAll(const PtGate& master);

  /** Destroy all the gates in GateKeeper.

    This function destroys all the PtGate objects and sets the
    pointers to be null.  This function must never be called from
    within a block controlled by a CriticalSection, or while
    multithreading operation is in progress.  */
  static void disableAll();

  /// Return TRUE if the GateKeeper is enabled (has a PtGate).
  int enabled() const { return (gate != 0);}
private:
  /// reference to the "kept" PtGate pointer
  PtGate * & gate;

  /// next GateKeeper on the list.
  GateKeeper *next;

  /** flag to indicate that construction is complete.  as a static
    object it will be 0; constructor sets it to GateKeeper_cookie.*/
  int valid;

  /// class-wide list head
  HPTOLEMY_KERNEL_API static GateKeeper *listHead;
};

/** A {\tt \Ref{GateKeeper}} that contains its own {\tt \Ref{PtGate}}
  pointer.  

  A KeptGate object is simply a GateKeeper that contains its own
  PtGate pointer.  It is derived from GateKeeper, has a private PtGate
  pointer member, and a constructor with no arguments.  Like a
  GateKeeper, it should be declared only at file scope and may be used
  as an argument to a CriticalSection constructor call.  */
class KeptGate : public GateKeeper {
public:
  /// 
  KeptGate() : GateKeeper(myGate), myGate(0) {}
private:
  PtGate* myGate;
};

// CriticalSection using GateKeeper.  It is inactive if the GateKeeper
// is not fully constructed, hence the test for "valid" (this solves the
// order-of-constructors problem).
inline CriticalSection::CriticalSection(GateKeeper& gk)
  : mutex(gk.valid == GateKeeper_cookie ? gk.gate : 0)
{
  if (mutex) mutex->lock();
}

#endif

#endif   /* PTGATE_H_INCLUDED */
