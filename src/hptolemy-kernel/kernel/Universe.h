/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Universe.h,v $ $Revision: 100.19 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef UNIVERSE_H_INCLUDED
#define UNIVERSE_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

/*******************************************************************
SCCS version identification
@(#)Universe.h	2.17	5/5/95

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

********************************************************************/

#include "DynamicGalaxy.h"
#include "Target.h"
#include "StringList.h"
#include "ptolemyDll.h"
#include "ProfileTimer.h"
#include "HashTable.h"

class Scheduler;
class Target;

/** Class used with multiple inheritance to create runnable universes
  and wormholes. */
class Runnable {
public:
  /// Construct a runnable object with a target specified
  Runnable(Target* , const char* domain, Galaxy*);

  /// Construct a runnable object and it's associated target
  Runnable(const char* targetname, const char* domain, Galaxy*);

  /// Initialize target and/or generates the schedule
  virtual void initTarget();

  /// Sets the stop time.
  virtual void setStopTime(double stamp);

  /// Display a static or pseudo-static schedule if possible
  StringList displaySchedule();

  /// Destructor - Delete the target
  virtual ~Runnable() { 
    if(pTarget) {
      INC_LOG_DEL; delete pTarget;
    }
  }

  /** Return the target pointer.  We call this {\tt myTarget} so that
    it will not conflict with the {\tt target()} method in the Block
    classes */
  Target* myTarget() const { return pTarget; }

  /// Set the target pointer
  void setMyTarget(Target* t) { pTarget = t; }


  /** Elapsed CPU time in seconds of the run.  The time is
      equal to the time the Ptolemy process is executing plus the time
      of the UNIX system calls run on behalf of Ptolemy.*/
  TimeVal elapsedCPUTime() const {
    return timer.elapsedCPUTime();
  }

  /** Elapsed CPU time in seconds of the run.  The time is
      equal to the time the Ptolemy process is executing plus the time
      of the UNIX system calls run on behalf of Ptolemy.*/
  TimeVal elapsedClockTime() const {
    return timer.elapsedClockTime();
  }

protected:
  /// Run until the stopping condition is reached
  int run();
  
  /// Domain name
  const char* type;

  /** Points to the galaxy provided by the other half of a multiply
    derived object.*/
  Galaxy* galP;

  /// Timer to collect run statistics
  ProfileTimer timer;

private:
  Target* pTarget;

};

/** A runnable galaxy.

  Class {\tt Universe} is inherited from both {\tt Galaxy} and {\tt
  Runnable}.  It is intended for use in standalone Ptolemy
  applications.  For applications that use a user interface to
  dynamically build universes, class {\tt InterpUniverse} is used
  instead.  */
class Universe : public DynamicGalaxy, public Runnable {
public:
  /// Construct a universe with a given target and domain
  Universe(Target* s,const char* domain);

  /// Construct a universe with a given target and domain
  Universe(const char* targetName,const char* domain);

  /// Destructor
  ~Universe() {
     remove(this->fullName());
  }

  /// Return a StringList describing the universe
  StringList print(int verbose = 0) const;

  /// Return the scheduler belonging to the universe's target
  Scheduler* scheduler() const;

  /// Return Runnable::run
  int run() { return Runnable::run();}

  /// Invokes wrapup on the target
  void wrapup();

  /// Initialize the target and invoke it's begin methods
  void initTarget();

  /// Return TRUE if the argument is a Universe 
  int isA(const char*) const;

  /// Return the string ``Universe''
  const char* className() const {return "Universe";}

  /// Splice in type conversion blocks after universe initialization
  /*virtual*/ void initialize();

  /** Return the current Universe, this method may be removed in a
      HP Ptolemy release. */
  inline static Universe* current() {
    return lookup("");
  }

  inline static Universe* lookup(const char* univName) {
    return (Universe*) univTable.lookup(univName);
  }

  inline static void insert(const char* univName, Universe* univ) {
    univTable.insert(univName, univ);
  }

  inline static void remove(const char* univName) {
    univTable.remove(univName);
  }

private:
  HPTOLEMY_KERNEL_API static HashTable univTable;
};

#endif   /* UNIVERSE_H_INCLUDED */
