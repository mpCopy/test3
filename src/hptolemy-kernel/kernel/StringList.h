/****************************************************************
SCCS version identification
@(#)StringList.h	2.21	6/21/96

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

StringList stores a list of char* strings, and can then read
them back one-by-one, or can concatinate them into a single
char* string. A StringList can only grow; there is no way to
take something away that has been added to the list.

StringList implements a small subset of the function of the
String class that will someday be an ANSI standard.

Programmer: J. Buck

WARNING: if a function or expression returns a StringList, and
that value is not assigned to a StringList variable or reference,
and the (const char*) cast is used, it is possible (likely under
g++) that the StringList temporary will be destroyed too soon,
leaving the const char* pointer pointing to garbage.  Always
assign temporary StringLists to StringList variables or references
before using the const char* conversion.  This includes code like

strcpy(destBuf,functionReturningStringList());

which uses the const char* conversion implicitly.

*******************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/StringList.h,v $ $Revision: 100.18 $ $Date: 2011/08/25 01:47:10 $ */


#ifndef STRINGLIST_H_INCLUDED
#define STRINGLIST_H_INCLUDED
// Copyright 1996 - 2015 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#include "DataStruct.h"
#include <iostream>
#include <string>

/** An ordered list of char *s that may grow arbitrarily.

  Class StringList provides a mechanism for organizing a list of
  strings.  It can also be used to construct strings of unbounded
  size, but the class InfString is preferred for this (class
  \Ref{InfString}).  It is privately derived from SequentialList
  (class \Ref{SequentialList}).

  Its internal implementation is as a list of {\tt char *} strings,
  each on the heap.  A StringList object can be treated either as a
  single string or as a list of strings; the individual substrings
  retain their separate identity until the conversion operator to type
  {\tt const char *} is invoked.  There are also operators that add
  numeric values to the StringList; there is only one format available
  for such additions.

  {\bf WARNING}: If a function or expression returns a StringList, and
  that value is not assigned to a StringList variable or reference,
  and the {\tt (const char*)} cast is used, it is possible (likely
  under g++) that the StringList temporary will be destroyed too soon,
  leaving the {\tt const char*} pointer pointing to garbage.  Always
  assign a temporary StringList to a StringList variable or reference
  before using the {\tt const char*} conversion.  Thus, instead of

  {\tt strcpy(destBuf,functionReturningStringList());}

  which uses the const char* conversion implicitly, one should use

\begin{verbatim}
StringList temp_name = (const char*)functionReturningStringList();
function_name(xxx, temp_name, yyy);
\end{verbatim}

  This includes code like

  {\tt strcpy(destBuf,functionReturningStringList());}

  which uses the {\tt const char*} conversion implicitly.*/
class StringList : private SequentialList {
  friend class StringListIter;
public:
  /**@name Constructors

    The default constructor makes an empty StringList.  There is
    also a copy constructor and six single-argument constructors that
    can function as conversions from other types to type StringList;
    they take arguments of the types {\tt char}, {\tt const char *},
    {\tt int}, {\tt double}, {\tt unsigned int} and {\tt long}.  */
  //@{
  /// 
  StringList() : totalSize(0) {}
  /// 
  StringList(char c);
  /// 
  StringList(const char* s);
  /// 
  StringList(int i); 
  /// 
  StringList(double d);
  /// 
  StringList(unsigned u);
  /// 
  StringList(const StringList& s);
  /// 
  StringList(const std::string& s);
  ///
  StringList(long l);
  //@}

  /**@name StringList destruction and zeroing */
  //@{
  /// Destructor - calls {\tt initialize()}
  ~StringList();

  /// Deallocate all pieces of the StringList and empty StringList
  void initialize();
  //@}

  /**@name Assignment operators

    There are seven assignment operators corresponding to these
    constructors: one that takes a {\tt const StringList&} argument
    and also one for each of the five standard types: {\tt char}, {\tt
    const char *}, {\tt int}, {\tt double}, {\tt unsigned int} and {\tt
    long}.

    The resulting object has one piece, unless initialized from
    another StringList in which case it has the same number of
    pieces.*/
  //@{
  /// 
  StringList& operator = (const StringList& sl);
  /// 
  StringList& operator = (const std::string& sl);
  /// 
  StringList& operator = (const char* s);
  /// 
  StringList& operator = (char c);
  /// 
  StringList& operator = (int i);
  /// 
  StringList& operator = (double d);
  /// 
  StringList& operator = (unsigned u);
  ///
  StringList& operator = (long l);
  //@}

  /**@name Adding to StringLists
  
    There are seven functions that can add a printed representation of
    an argument to a StringList: one each for arguments of type {\tt
    const StringList&}, {\tt char}, {\tt const char *}, {\tt int},
    {\tt double}, {\tt unsigned int} and {\tt long}.  In each case, the 
    function can be accessed in either of two equivalent ways:
  
\begin{verbatim}
StringList& operator += (type arg);
StringList& operator << (type arg);
\end{verbatim}

    The second ``stream form'' is considered preferable; the ``+=''
    form is there for backward compatibility.  If a StringList object
    is added, each piece of the added StringList is added separately
    (boundaries between pieces are preserved); for the other six
    forms, a single piece is added.  */
  //@{
  /// 
  StringList& operator << (const char*);
  /// 
  StringList& operator << (char);
  /// 
  StringList& operator << (int);
  /// 
  StringList& operator << (unsigned int);
  /// 
  StringList& operator << (double);
  /// 
  StringList& operator << (const StringList&);
  /// 
  StringList& operator << (const std::string&);
  ///
  StringList& operator << (long);
  /// 
  inline StringList& operator += (const char* arg) { return *this << arg; }
  /// 
  inline StringList& operator += (char arg) { return *this << arg; }
  /// 
  inline StringList& operator += (double arg) { return *this << arg; }  
  /// 
  inline StringList& operator += (int arg) { return *this << arg; }
  /// 
  inline StringList& operator += (const StringList& arg) { return *this << arg; }
  /// 
  inline StringList& operator += (const std::string& arg) { return *this << arg; }
  /// 
  inline StringList& operator += (unsigned int arg) { return *this << arg; }
  ///
  inline StringList& operator += (long arg) { return *this << arg; }
  //@}

  /**@name StringList info functions */
  //@{
  /// Return first string on the list
  /** Return the first substring on the list (the first ``piece'').  A
    null pointer is returned if there are none.  */
  inline const char* head() const {
    return (const char*)SequentialList::head();
  }

  /// Return last string on list
  inline const char* tail() const {
    return (const char*)SequentialList::tail();
  }

  /// Return the length in characters
  inline int length() const { return totalSize;}

  /// Return the number of substrings in the StringList
  inline int numPieces() const { return size();}
  //@}

  /** Convert to const char*.

    {\bf NOTE}: This operation modifies the StringList -- it calls
    the private consolidate method to collect all strings into one
    string and clean up the garbage.  No modification happens if the
    StringList is already in one chunk.  A null pointer is always
    returned if there are no characters, never "".  */
  inline operator const char* () { return consolidate();}

  /** Allow write access to the buffer after consolidation.

    {\bf WARNING}: this is to permit StringLists to be used with
    routines that incorrectly request a char* when a const char* would
    do, or things like Tcl that may temporarily modify the argument
    but that restore it to its original form before returning.  If
    used otherwise, no promises are made.  */
  inline char * chars() { return consolidate();}
 
  /** Make a copy of the StringList's text.  This function makes a
    copy of the StringList's text in a single piece as a {\tt char *}
    in dynamic memory.  The object itself is not modified.  The caller
    is responsible for deletion of the returned text.*/
  char* newCopy() const;

  /// Consolidate the pieces into one string
  char* consolidate();

  /// Alphabetize
  void alphabetize();

private:
  /// 
  void copy(const StringList&);
  /// 
  int totalSize;
};

/** An Iterator for StringList.  Class StringListIter is a standard
  iterator that operates on StringLists.  Its {\tt next()} function
  returns a pointer of type {\tt const char *} to the next substring
  of the StringList.  It is important to know that the operation of
  converting a StringList to a {\tt const char *} string joins all the
  substrings into a single string, so that operation should be avoided
  if extensive use of StringListIter is planned.

  @see Iterators*/
class StringListIter : private ListIter {
public:
  /// 
  StringListIter(const StringList& s) : ListIter(s) {}
  /// 
  inline const char* next() { return (const char*)ListIter::next();}
  /// 
  inline const char* operator++(POSTFIX_OP) { return next();}
  /// 
  using ListIter::reset;
};


/// Print a StringList on a stream
std::ostream& operator << (std::ostream& o,const StringList& sl);

#endif   /* STRINGLIST_H_INCLUDED */
