/* 
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

   Version: @(#)ProfileTimer.h	1.3 08/21/95
   Programmer:  Jose Luis Pino
   Date of creation:  3/27/95

*/

/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/ProfileTimer.h,v $ $Revision: 100.13 $ $Date: 2011/08/25 01:47:10 $ */


#ifndef PROFILETIMER_H_INCLUDED
#define PROFILETIMER_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#ifdef __GNUG__
#pragma interface
#endif

#include "TimeVal.h"
#include "ptolemyDll.h"

/// A class to collect program timing statistics
class ProfileTimer {
public:
  /// 
  ProfileTimer();

  /// Reset startTime
  void reset();

  /** Elapsed CPU time in seconds since the last reset.  The time is
      equal to the time the Ptolemy process is executing plus the time
      of the system calls run on behalf of Ptolemy.*/
  TimeVal elapsedCPUTime() const;

  /** Elapsed wall clock time in seconds since the last reset.*/
  TimeVal elapsedClockTime() const;

private:
  /// The CPU time when the ProfileTimer was reset
  TimeVal startCPUTime;

  /// The wall clock time when the ProfileTimer was reset
  TimeVal startClockTime;

  /** Have we setup the profile timer?  We only do this once for an
      entire Ptolemy simulation.  Things might have to change if we ever
      allow multithreading.*/
  HPTOLEMY_KERNEL_API static int setupFlag;

  /// Return the current CPU time
  TimeVal timeOfProfileCPU() const;

  /// Return the current wall clock time
  TimeVal timeOfProfileClock() const;

};

/// A class to collect timing statistics over a number of runs
class AvgProfileTimer: private ProfileTimer {
public:
  /// 
  AvgProfileTimer(): ProfileTimer() {
    count = 0;
    time = 0;
  }

  /// Each time start is called, an invocation is started
  inline void start() { reset(); }

  /** Each time stop is called, an invocation time is added to the
      total elapsed time. */
  inline void stop() {
    count++;
    time += elapsedCPUTime();
  }

  /// Return average time in cpu seconds
  inline double avgTime() const { 
    return count? double(time)/double(count):-1; 
  }

  /// Return total number of invocations
  inline int invocations() const { return count; } 
private:
  /// Number of invocations
  int count;

  /// Total elapsed time
  TimeVal time;
};

#endif   /* PROFILETIMER_H_INCLUDED */
