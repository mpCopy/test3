/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/SimControl.h,v $ $Revision: 100.20 $ $Date: 2011/08/25 01:47:10 $ */
#ifndef _SimControl_h
#define _SimControl_h 1
// Copyright  1996 - 2017 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

// Needed as "volatile" not defined for all compilers
// took this out as it has not yet been integrated into Ptolemy for builds
// #include "compat.h" 
#include "ptolemyDll.h"

/**************************************************************************
Version identification:
@(#)SimControl.h	1.12	8/26/95

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

 Programmer: J. Buck  
 Date of creation: 6/23/92


**************************************************************************/
#if ! defined(VOLATILE)
#if (defined(hpux) || defined(__hpux)) && ! defined(__GNUC__)
#define VOLATILE
#else
#define VOLATILE volatile
#endif /* PTHPPA_CFRONT */
#endif /* ! VOLATILE */

class Star;
class SimAction;
class SimActionList;
class PtGate;

typedef void (*SimActionFunction)(Star*,const char*);
typedef int (*SimHandlerFunction)();

/** The SimControl class controls execution of the simulation.  It has
  some global status flags that indicate whether there has been an
  error in the execution or if a halt has been requested.  It also has
  mechanisms for registering functions to be called before or after
  star executions, or in response to a particular star's execution,
  and responding to interrupts.

  This class interacts with the Error class (which sets error and halt
  bits) and the Star class (to permit execution of registered actions
  when stars are fired).  Schedulers and Targets are expected to
  monitor the SimControl halt flag to halt execution when errors are
  signaled and halts are requested.  Once exceptions are commonplace
  in C++ implementations, a cleaner implementation could be produced.

  SimControl can register a function that will be called before or
  after the execution of a particular star, or before or after the
  execution of all stars.  A function that is called before a star is
  a {\em preaction}; on that is called after a star is a {\em
  post-action}.  The Star class makes sure to call doPreActions and
  doPostActions at appropriate times.

  These actions may be unconditional or associated with a particular
  star.

  Other features provided include signal handling and a poll function.
  The low-level interrupt catcher simply sets a flag bit.  A function
  may be registered to provide for an arbitrary action when this bit
  is set.

  The poll function, if enabled, is called between each action
  function and when the flag bits are checked.  It can be used as an X
  event loop, for example.

  @see SimAction */
class SimControl {
  friend class SimControlOwner;
  friend class SimAction;
public:
  /** Read the flag values.  If threading is on, we need a function
    call, otherwise it is inline.*/
  inline static unsigned int flagValues() {
    return gate ? readFlags() : flags;
  }

  /// Function to read flags with a mutual exclusion region.
  static unsigned int readFlags();

private:
  // must appear before functions that use it for g++ 2.2's
  // inlining to work correctly.
  inline static int haltStatus () {
    return (flagValues() & halt) != 0;
  }
  inline static int errorStatus () {
    return (flagValues() & error) != 0;
  }
public:
  
  /// Enumeration of the possible SimControl states simulation
  enum flag_bit {
    halt = 1,
    error = 2,
    interrupt = 4,
    poll = 8,
    initializeError = 16};

  /** Return TRUE if a halt has been requested by the simulator or the
    user.*/
  inline static int haltRequested () {
    if ( flagValues() | getPollFlag() ) processFlags();
    return haltStatus();
  }

  /** Return TRUE if an error has occured during simulation. */
  inline static int errorOccured () {
    if ( flagValues() | getPollFlag() ) processFlags();
    return errorStatus();
  }

  /** Return TRUE if a initialization error has been requested by the
    simulator or the user. FIXME this does not make sense here!!*/
  inline static int initializeErrorOccured() {
    if (flagValues() | getPollFlag() ) processFlags();
    return (flagValues() & initializeError) != 0;
  }

  /// Actions to do before and after firing a star
  //@{
  /** Execute all pre-actions for a particular Star, return TRUE if
    successful.*/
  inline static int doPreActions(Star * which) {
    return (nPre > 0) ? internalDoActions(preList,which)
      : !ihaltRequested();
  }

  /** Execute all post-actions for a particular Star, return TRUE if
    successful*/
  inline static int doPostActions(Star * which) {
    return (nPost > 0) ? internalDoActions(postList,which)
      : !ihaltRequested();
  }

  /** Register a pre-action or post-action.  If "pre" is TRUE it is a
    preaction.  If {\tt textArg} is given, it is passed as an argument
    when the action function is called.  If {\tt which} is 0, the
    function will be called unconditionally by {\tt doPreActions} (if
    it is a preaction) or {\tt doPostActions} (if it is a post-action;
    otherwise it will only be called if the star being executed has
    the same address as {\tt which}.

    The return value represents the registered action; class SimAction
    is treated as an ``opaque class'' (I'm not telling you what is in
    it) which can be used for {\tt cancel} calls. 

    The functions that can be registered have take two arguments: a
    pointer to a Star (possibly null), and a {\tt const char*} pointer
    that points to a string (possibly null).  The type definition

    {\tt typedef void (*SimActionFunction)(Star*,const char*);}

    gives the name SimActionFunction to functions of this type;
    several SimControl functions take arguments of this form.*/
  static SimAction* registerAction(SimActionFunction action, int pre,
				   const char* textArg = 0, Star* which = 0);

  /// Cancel {\tt action}
  static int cancel(SimAction*);
  //@}

  /** Set the user-specified interrupt handler to {\tt f}, and return
    the old handler, if any.  This function is called in response to
    any signals specified in {\tt catchInt}.  */
  static SimHandlerFunction setInterrupt(SimHandlerFunction f);

  /// Set the Poll Flag true
  static void setPollFlag();

  /// Get the value of the poll flag 
  static int getPollFlag();

  /** Register a function to be called if the poll flag is set.
    Returns old handler*/
  static SimHandlerFunction setPollAction(SimHandlerFunction f);

  /** Use the system timer to set the poll flag at the future time
    specified by the passed parameters.*/
  static void setPollTimer( int seconds, int micro_seconds );

  /// 
  static void requestHalt ();
  /// 
  static void declareErrorHalt ();
  /// 
  static void declareInitializeError();
  /// 
  static void clearHalt ();

  /** Install a simple interrupt handler for the signal with Unix
    signal number {\tt signo}.  If {\tt always} is true, the signal is
    always caught; otherwise the signal is not caught if the current
    status of the signal is that it is ignored (for example, processes
    running in the background ignore interrupt signals from the
    keyboard).  This handler simply sets the SimControl interrupt bit;
    on the next call to {\tt haltRequested}, the user-specified
    interrupt handler is called.  */
  static void catchInt(int signo = -1, int always = 0);

private:
  static void intCatcher(int);
  static void processFlags();
  static int internalDoActions(SimActionList*,Star*);

  /// lists of pre- and post-actions
  HPTOLEMY_KERNEL_API static SimActionList * preList;
  HPTOLEMY_KERNEL_API static SimActionList * postList;

  /// # of pre- and post-actions
  HPTOLEMY_KERNEL_API static int nPre, nPost;

  /// system status flags
  HPTOLEMY_KERNEL_API static VOLATILE unsigned int flags;

  // polling status flag.  NOTE: This is a separate flag from "flags" 
  // to avoid any possible race conditions.  It is int to make sure
  /// that it is atomic.
  HPTOLEMY_KERNEL_API static VOLATILE int pollflag;

  /// id only used by WIN32 timer functions
  HPTOLEMY_KERNEL_API static VOLATILE int TimerID;

  /// PtGate for controlling threaded access to flags
  HPTOLEMY_KERNEL_API static PtGate* gate;

#if defined(PTHPPA) && !defined(HPUX_10)
  static void setPollFlagHP9(int, int, struct sigcontext *);
#endif

  HPTOLEMY_KERNEL_API static SimHandlerFunction onInt, onPoll;

  /** inline version of two methods to reduce Star::run overhead.
      These will disappear in a future version of ADS which will not
      be binary compatible. */
  inline static int igetPollFlag() { return pollflag; }
  inline static int ihaltRequested () {
    if ( flagValues() | igetPollFlag() ) processFlags();
    return haltStatus();
  }
  
};
#endif

