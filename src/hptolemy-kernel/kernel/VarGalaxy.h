/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/VarGalaxy.h,v $ $Revision: 100.4 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef VARGALAXY_H_INCLUDED
#define VARGALAXY_H_INCLUDED
// Copyright 1999 - 2014 Keysight Technologies, Inc  

/*******************************************************************
UCB version identification DynamicGalaxy.h	1.7	3/2/95

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
 Programmer : Soonhoi Ha
 Date : Jan. 14, 1992

********************************************************************/
#ifdef __GNUG__
#pragma interface
#endif

#include "Galaxy.h"

/** A type of Galaxy for all states are allocated on the heap. 
  When destroyed, it destroys all of its states in a clean manner.   
  It also maintains a list of Variables defined at this level of 
  hierarchy. There's not much more to it than that: it provides 
  a destructor, class identification functions {\tt isA} and 
  {\tt className}, and little else.  */
class VarGalaxy : public Galaxy {
protected:
  /// Remove contained objects
  virtual void zero(); 
public:
  /// Destructor
  ~VarGalaxy() { zero();}

  /// Returns an error and a null pointer.
  virtual Block* makeNew() const;

  /// Returns TRUE if the argument is a DynamicGalaxy
  virtual int isA(const char*) const;

};

#endif   /* VARGALAXY_H_INCLUDED */
