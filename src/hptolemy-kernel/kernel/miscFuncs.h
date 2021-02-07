/**************************************************************************
Version identification:
@(#)miscFuncs.h	1.20	11/30/95

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

 Programmer:  J. T. Buck
 Date of creation: 6/10/90

 This header file provides prototypes for miscellaneous
 library functions that are not members, together with some
 commonly used library functions.

*************************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/miscFuncs.h,v $ $Revision: 100.23 $ $Date: 2012/08/23 22:24:11 $ */


#ifndef MISCFUNCS_H_INCLUDED
#define MISCFUNCS_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include <cmath>
#include "logNew.h"
#include "gui_string.h"
#include "StringList.h"

#ifndef linux
extern "C" double pow(double,double);
#endif

/** Return the expanded path name.  This function accepts a string and
  interprets it as a Unix path name.  If the string does not begin
  with a {\tt \~} contain a {\tt \$} character, the string itself is
  returned.  A leading {\tt \~/} is replaced by the user's home
  directory; a leading ``{\tt \~user}'' is replaced by the home
  directory for {\tt user}, unless there is no such user, in which
  case the original string is returned.

  Finally, an embedded environment variable ``{\tt \$ENV}'' is
  replaced by the value of the environment variable {\tt ENU}; if
  there is no such environment variable, the original string is
  returned.

  The returned value points to dynamic storage which should be freed
  using {\tt delete []} when no longer used.  */
char* osiExpandPathName(const char*);

/// Supplied for UCB Ptolemy backward compatablity
#define expandPathName osiExpandPathName

/** Return a unique temporary file name. Caller must deallocate the
  memory using {\tt delete []}.*/
char* tempFileName();

/** Preform a global character substitution on a string. This function
  returns a new string formed by replacing each character ``target''
  in string ``str'' with string ``substr''.  The returned value points
  to dynamic storage which should be freed using {\tt delete []} when
  no longer used.  */
char* subCharByString(const char *str, char target, const char *substr);

/** Preform a global string substitution on a string. This function
  returns a new string formed by replacing each string ``target''
  in string ``str'' with string ``substr''.  The returned value points
  to dynamic storage which should be freed using {\tt delete []} when
  no longer used.  */
char* subStringByString(const char *str, const char *target,
			const char *substr);

/** Allocate memory to store a given string.  The {\tt savestring}
function creates a copy of the argument with {\tt new} and returns a
pointer to it.  It is the caller's responsibility to assure that the
string is eventually deleted by using the {\tt delete []} operator.
The argument must not be a null pointer.*/
inline char* savestring (const char* txt) {
  INC_LOG_NEW; return strcpy (new char[strlen(txt)+1], txt);
}

/** Return a pointer to the given string from the systemwide hash
  table.
 
  This function enters a copy of the argument string into a hash table
  and returns a pointer to the entry.  If two strings compare equal
  when passed to {\tt strcmp}, then if both are passed to {\tt
  hashstring}, the return values will be the same pointer.

  Do not delete strings returned by hashstring.*/
const char* hashstring(const char*);

// I would prefer to make this int pow(int,int), but g++ gets confused
// because the other function is extern "C".

/** Raise the base to exponent power, integer version.*/
int power(int base,int exponent);

/** Raise the base to exponent power, double version.*/
inline double power(double base, double exponent) { return
						      pow(base,exponent);}

/// Check and set the standard HPtolemy environment variables
void hptolemySetEnv();

/// Get the complete file name along with it's path using
/// the ADSPTOLEMY_MODEL_PATH search path and looking for file
/// under each directory's "data" directory
StringList getCompleteFilePath(const char* file);

/// dynamically realloc buf and double it's old size osz.
template <class T> inline T* renew(T* buf, int osz, int& nsz) {
  nsz=(osz)?osz*2:nsz;
  T* newbuf=new T [nsz];
  if(buf && newbuf) {
    int i;
    for(i=0; i<osz; i++)
      newbuf[i]=buf[i];
  }
  delete [] buf;
  return newbuf;
}

///dynamically reallocate, if required, and add s to buffer b => buf[i++]=s
template <class T> inline T* dynAdd(T* b, int& i, T s, int& bufsize) {
  if(i==0 || i==bufsize) {
    b=renew(b, i, bufsize);
  }
  if(b) 
    b[i++]=s;
  return b;
}

class SimData;
SimData* newSimData (void * star);

#endif   /* MISCFUNCS_H_INCLUDED */
