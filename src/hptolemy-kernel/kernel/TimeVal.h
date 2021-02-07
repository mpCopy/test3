/* 
@(#)TimeVal.h	1.7 3/7/96

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
*/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/TimeVal.h,v $ $Revision: 100.20 $ $Date: 2012/03/08 18:14:50 $ */
/* 
   Programmer:  T. M. Parks
   Date of creation:  8 Nov 91
*/


#ifndef TIMEVAL_H_INCLUDED
#define TIMEVAL_H_INCLUDED
// Copyright 1996 - 2014 Keysight Technologies, Inc  

#include "compat.h"

#if defined(PTLINUX)
#define __need_timeval
#endif

#ifdef __GNUG__
#pragma interface
#endif

#ifndef EETYPE_H_INCLUDED
#define EETYPE_H_INCLUDED
#define TIMEVAL_EETYPE_DISABLE
#endif

#include "gui_time.h"
#include "gui_timeb.h"
#include "StringList.h"

#ifdef TIMEVAL_EETYPE_DISABLE
#undef EETYPE_H_INCLUDED
#endif

#ifdef WIN32
struct timeval_ptolemy {
  long tv_sec;
  long tv_usec;
};
#else
typedef timeval timeval_ptolemy;
#endif

/** Class used to represent a time interval to microsecond precision.*/
class TimeVal : public timeval_ptolemy {
public:

  /// Construct a TimeVal with an interval of zero
  TimeVal();

  /** Construct a TimeVal where the argument is rounded to the nearest
    microsecond.*/
  TimeVal(double);

  /// Construct a TimeVal with a timeval argument
  TimeVal(timeval_ptolemy);
  
  /// Returns the interval value as seconds
  operator double() const;

  /// Add two TimeVals
  TimeVal operator +(const TimeVal&) const;

  /// Subract a TimeVal from another
  TimeVal operator -(const TimeVal&) const;

  /// Add a TimeVal to this one
  TimeVal& operator +=(const TimeVal&);

  /// Subract a TimeVal from this one
  TimeVal& operator -=(const TimeVal&);

  /// Multiply the time value by a real - can be used to extrapolate a time in the future
  TimeVal& operator *=(double);

  /// Greater than operator
  int operator >(const TimeVal&) const;

  /// Less than operator
  int operator <(const TimeVal&) const;

  /** Express time value as a string (hours, minutes, seconds).   If the time is in hours,
      we will not display the seconds. */
  StringList asString() const;

private:
  ///
  void normalize();
};

#endif   /* TIMEVAL_H_INCLUDED */
