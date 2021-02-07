/*******************************************************************
UCB SCCS Version identification : @(#)Error.h	2.6	3/2/95

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
 Date of creation: 4/14/91

This header file defines the interface for error reporting.  It
is designed to support multiple implementations: one for output
on terminals, one that pops up error windows, etc.

*******************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/HPtolemyError.h,v $ $Revision: 100.24 $ $Date: 2011/08/25 01:47:10 $ */


#ifndef HPTOLEMYERROR_H_INCLUDED
#define HPTOLEMYERROR_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#include "ptolemyDll.h"

class NamedObj;
class NamedObjList;
class PRLock;

/** An interface for error reporting.

    Class Error is used for error reporting.  While the interfaces to
    these functions are always the same, different user interfaces
    provide different implementations: {\tt ptcl} connects to the Tcl
    error reporting mechanism, {\tt pigi} pops up windows containing
    error messages, and {\tt interpreter} simply prints messages on
    the standard error stream.  All member functions of Error are
    static.

    All implementations of the Error class need to define the same
    methods are a link error will occur.
 
    There are four ``levels'' of messages that may be produced by the
    error facility: {\tt \Ref{Error::abortRun}} is used to report an
    error and cause execution of the current universe to halt.  {\tt
    \Ref{Error::error}} reports an error.  {\tt \Ref{Error::warn}}
    reports a warning, and {\tt \Ref{Error::message}} prints an
    information message that is not considered an error.

    Each level has three forms.  The first form produces the error
    message by simply concatenating its arguments (the second and
    third arguments may be omitted); no space is added.

    The second form prepends the full name of the {\tt NamedObj}
    argument, a colon, and a space to the text provided by the
    remaining arguments.

    The third form prepends the full names of all of the {\tt
    NamedObj}s argument, a colon, and a space to the text provided by
    the remaining arguments.

    If the implementation provides a marking facility, the objects are
    marked by the user interface (at present, the interface associated
    with {\tt hpeesofde} will highlight the object if its icon appears
    on the screen).*/
class Error {

public:
  HPTOLEMY_KERNEL_API static PRLock* ErrorLock;

  /**@name Halt after initialization, message prefixed with ``ERROR:'' */
  //@{
  /// 
  static void initialization(const char*, const char* = 0, 
			     const char* = 0);
  
  /// 
  static void initialization(const NamedObj&, const char*, 
			     const char* = 0, const char* = 0);
  /// 
  static void initialization(const NamedObjList&, const char*, 
			     const char* = 0, const char* = 0);
  //@}
  
  /**@name Halt the scheduler, message prefixed with ``ERROR:'' */
  //@{
  /// 
  static void abortRun (const char*, const char* = 0, const char* = 0);
  /// 
  static void abortRun (const NamedObj&, const char*, const char* = 0,
			const char* = 0);
  /// 
  static void abortRun (const NamedObjList&, const char*, const char* = 0,
			const char* = 0);
  //@}
  
  /**@name Do not halt the scheduler, message prefixed with ``ERROR:'' */
  //@{
  /// 
  static void error (const char*, const char* = 0, const char* = 0);
  /// 
  static void error (const NamedObj&, const char*, const char* = 0,
		     const char* = 0);
  /// 
  static void error (const NamedObjList&, const char*, const char* = 0,
		     const char* = 0);
  //@}
  
  /**@name Do not halt the scheduler, message prefixed with ``WARNING:'' */
  //@{
  /// 
  static void warn (const char*, const char* = 0, const char* = 0);
  /// 
  static void warn (const NamedObj&, const char*, const char* = 0,
		    const char* = 0);
  /// 
  static void warn (const NamedObjList&, const char*, const char* = 0,
		    const char* = 0);
  //@}
  
  /**@name Do not halt the scheduler, no message prefix */
  //@{
  /// 
  static void message (const char*, const char* = 0, const char* = 0);
  
  /// 
  static void message (const NamedObj&, const char*, const char* = 0,
		       const char* = 0);
  /// 
  static void message (const NamedObjList&, const char*, const char* = 0,
		       const char* = 0);
  //@}

  /**@name Display a progress message - typically used to display scheduler or simulation status. */
  //@{
  /// 
  static void progressMessage (const char*, const char* = 0, const char* = 0);
  
  /// 
  static void progressMessage (const NamedObj&, const char*, const char* = 0,
		       const char* = 0);
  /// 
  static void progressMessage (const NamedObjList&, const char*, const char* = 0,
		       const char* = 0);
  //@}

  /**@name Exit from hpeesofsim.
     
     Unlike the other error methods in this class, this type of error
     is not due to a user error but rather a fatal bug in the code.
     These methods call Error::abortRun. 
     
     The file id should always be the cpp macro__FILE__, the line
     number should always be the cpp macro __LINE__.

     The error message will be formatted as:
     
     An internal error in the simulator has occured in __FILE__ line
     __LINE__.  Please report this bug to your support representative.
     
     The optional strings will be concatenated to the message.*/
  //@{
  ///
  static void internalError(const char* file, int line,
			    const char* =0, const char* =0, const char* =0);
  ///
  static void internalError(const NamedObj&, 
			    const char* file, int line,
			    const char* =0, const char* =0, const char* =0);
  ///
  static void internalError(const NamedObjList&, 
			    const char* file, int line, 
			    const char* =0, const char* =0, const char* =0);
  //@}
  

  /// Will display the linker loading message only if the library is not in HPEESOF_DIR
  static void linkerLoading(const char* message);

  /** Returns TRUE if the interface can mark NamedObj objects.
      
      This function returns TRUE if the interface can mark NamedObj
      objects (generally true for graphic interfaces), and FALSE if it
      cannot (generally true for text interfaces).  */
  static int canMark();
  
  /** This function marks the object {\tt obj}, if marking is
      implemented for this interface.  It is a no-op if marking is not
      implemented.  */
  static void mark (const NamedObj&);

  /** Try to flush any error messages.  Not guaranteed to do anything. */
  static void flush ();
};
#endif   /* HPTOLEMYERROR_H_INCLUDED */
