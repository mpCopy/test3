/******************************************************************
Version identification:
@(#)KnownState.h	2.7	3/2/95

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

 Programmer:  I. Kuroda 
 Date of creation: 5/26/90

The KnownState class.

This class provides a list of all known states.
The data structure used to reference the list may be
changed.

The idea is that each star or galaxy that is "known to the system"
should add an instance of itself to the known list by code something
like

static const MyType proto;
static KnownState entry(proto,"MyType");

Then the static method KnownBlock::clone(name) can produce a new
instance of class name.
*******************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/KnownState.h,v $ $Revision: 100.10 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef KNOWNSTATE_H_INCLUDED
#define KNOWNSTATE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#ifndef _KnownState
#define _KnownState 1

#ifdef __GNUG__
#pragma interface
#endif

#include "StringList.h"
#include "State.h"
#include "Block.h"
#include "ptolemyDll.h"



/** A global state.

  KnownState manages two lists of states, one to represent the types
  of states known to the system (integer, string, complex, array of
  floating, etc), and one to represent certain predeclared global
  states.

  It is very much like KnownBlock (class \Ref{KnownBlock}) in internal
  structure.  Since it manages two lists, there are two kinds of
  constructors.  */
class KnownState {
  friend class KnownStateOwner;

  // The known state list.  It's a pointer only so we can control when
  // the constructor is called.

  HPTOLEMY_KERNEL_API static StateList *allStates;
  HPTOLEMY_KERNEL_API static StateList *allGlobals;
  HPTOLEMY_KERNEL_API static int numStates;
  HPTOLEMY_KERNEL_API static int numGlobals;
public:

  /**@name Constructors */
  //@{
  /// Add an entry to the state type list
  /* This constructor adds an entry to the state type list.  For example,

  \begin{verbatim}
  static IntState proto;
  static KnownState entry(proto,"INT");
  \end{verbatim}

  permits IntStates to be produced by cloning.  The {\tt type}
  argument must be in upper case, because of the way {\tt find} works
  (see below).*/
  KnownState (State &state, const char* name);

  /** Add a global state (such as PI).
  
    This constructor permits names to be added to the global state
    symbol list, for use in state expressions.  For example, we have

  \begin{verbatim}
  static FloatState pi;
  KnownState k_pi(pi,"PI","3.14159265358979323846");
  \end{verbatim}*/
  KnownState (State& state, const char* name, const char* value);
  //@}

  /** Return a pointer the appropriate prototype state in the state
    type list.  The argument is always changed to upper case.  A null
    pointer is returned if there is no match.  */
  static const State* find (const char* type);

  /** Return a pointer to the appropriate state in the global state
    list, or null if there is no match.  */
  static const State* lookup (const char* name);

  /** Find the appropriate state using {\tt find}, and return a clone
    of that block.  A null pointer is returned if there is no match,
    and {\tt \Ref{Error::error}} is also called.  */
  static State* clone (const char* type);

  /// Return the names of all the known state types, separated by newlines
  static StringList nameList();

  /// Return the number of known states.
  static int nKnown() { return numStates;}
};
#endif

#endif   /* KNOWNSTATE_H_INCLUDED */
