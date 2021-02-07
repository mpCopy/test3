/******************************************************************
Version identification:
@(#)KnownBlock.h	2.14	9/5/96

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

 Programmer:  J. T. Buck
 Date of creation: 3/16/90

*******************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/KnownBlock.h,v $ $Revision: 100.24 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef KNOWNBLOCK_H_INCLUDED
#define KNOWNBLOCK_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#ifdef __GNUG__
#pragma interface
#endif

#include "Block.h"
#include "StringList.h"
#include "NetlistName.h"
#include "ptolemyDll.h"

// private class for entries on known lists

/// 
class KnownListEntry {
  friend class KnownBlock;
  friend class KnownBlockIter;
  /// 
  Block* b;
  ///
  int onHeap;
  /// 
  int dynLinked;
  /// true while trying to clone this block
  int cloneInProgress;	
  /// 
  KnownListEntry *next;
public:
  /// 
  KnownListEntry(Block*, int, KnownListEntry*);
  /// 
  ~KnownListEntry ();
};

/** 
    This class provides a list of all known blocks.  There is a
    separate list for each domain (corresponding to blocks that may be
    run by a specific scheduler).

    The idea is that each star or galaxy that is "known to the system"
    should add an instance of itself to the known list by code
    something like

    \code
    static MyType proto;
    static KnownBlock entry(proto);
    \endcode

    The reason for using a constructor is that constructors for global
    objects are called before execution of the main program;
    constructors therefore serve as a mechanism for execution of
    arbitrary initialization code for a module (as used here,
    ``module'' is an object file).  Hence \em hpeesoflang, the Ptolemy
    star preprocessor, generates code as shown above in the .cc file.

    The static method \Ref KnownBlock::clone(name, dom) can produce a
    new instance of the named class in the named domain.  As for
    blocks, clone copies everything, makeNew just makes a new one.

    \Ref KnownBlock::defaultDomain() returns the default domain name.
    This is not used internally for anything; it is just set to the
    first domain seen during the building of known lists.

    \Ref KnownBlock::validDomain() returns TRUE if the argument is a
    valid domain.

    We no longer have the concept of the "current domain".  We used to
    use the "current domain" and repeatedly changed it; this is now
    going away since it is troublesome, especially with multiple
    threads or with an X interface where the flow of control is hard
    to follow.
    
*/
class KnownBlock {
  friend class KnownBlockIter;
public:
  /// Constructor adds a block to a the correct known list.
  KnownBlock (Block &block) {
    addEntry (block, 0);
  }
  
  /** Add a block to the list.  If \em onHeap is true, the block
    will be destroyed when the entry is removed or replaced from the
    list.  Separate lists are maintained for each domain; the block is
    added to the list corresponding to \em block.domain(). */

  static KnownListEntry* addEntry (Block &block, int onHeap);
  
  /** The find method returns a pointer to a block matching the given
      name.  You may leave fields of NetlistName unspecified by
      setting them to NetlistName::matchAnything(). */
  static const Block* find (const NetlistName &);

  /** The \em clone method finds the appropriate block and returns a
    clone of that block (the \em clone} method is called on the
    block.  This method, as a rule, generates a duplicate of the
    block.

    An error message is generated (with \Ref Error::abortRun)
    and a null pointer is returned if there is no match.*/
  static Block* clone (const NetlistName &);

  /** Make a parameterized instantiation of a Block known.  More
      efficient than just cloning */

  /** The \em makeNew function is similar except that \em makeNew
    is called on the found block.  As a rule, \em makeNew returns an
    object of the same class, but with default initializations (for
    example, with default state values).  

    An error message is generated (with \Ref Error::abortRun)
    and a null pointer is returned if there is no match.*/
  static Block* makeNew (const NetlistName &);

  /** Return the names of known blocks in the given domain (second
    form).  Names are separated by newline characters.  */
  static StringList nameList (const char* domain);

  /** Returns the default domain name.  This is not used internally
    for anything; it is just set to the first domain seen during the
    building of known lists.  */
  static const char* defaultDomain();

  /** Set the default domain name.  Return FALSE if the specified
    value is not a valid domain.  */
  static int setDefaultDomain(const char* newval);

  /// Return TRUE if the given name is a valid domain
  static int validDomain(const char* dom);

  /** Look up a KnownBlock definition by name and return its
      definition source.  Returns TRUE if found, FALSE if no matching
      definition exists.

      Note: We do NOT consider blocks in subdomains.*/
  static int isDefined (const NetlistName &, const char* &definitionSource);

  /// Return true if the named block is dynamically linked
  static int isDynamic (const NetlistName &);

  /* Obsolete functions.  They call the above functions with 
     unspecified vendors and libraries */
  static const Block* find (const char* name, const char* dom);
  static Block* clone (const char* name, const char* dom);
  static Block* makeNew (const char* name, const char* dom);
  static int isDefined (const char *type, const char *dom,
			const char* &definitionSource);
  static int isDynamic (const char* type, const char* dom);
	
  /** Call to determine if the given library is supported.  If the
      library is not supported, \Ref Error::abortRun will be called
      with the approriate message.
 
      \param libname a string with the library name to be tested
      \return TRUE if library is supported, FALSE otherwise
  */
  static bool isSupported(const char* libname,const char* designName=NULL);

private:

  /// code for default domain
  HPTOLEMY_KERNEL_API static int defaultDomainCode;

  /// \# of domains
  HPTOLEMY_KERNEL_API static int numDomains;

  /// 
  static int domainIndex (const char* dom, int addIfNotFound = 0);
  /// 
  static int domainIndex (const Block& block);
  /// 
  static KnownListEntry* findEntry (const NetlistName &, int);
  static KnownListEntry* findMasterEntry (const NetlistName &, int);
  static KnownListEntry* findEntry (const NetlistName &, KnownListEntry *);
  /// 
  static void noMatch(const NetlistName &);
  /// 
  static void recursiveClone(const NetlistName &);
  ///
  static void setNameParams(Block *, const NetlistName &);
};

/** An iterator that steps through all blocks that match a given name.
    Construct a NetlistName with NetlistName::matchAnything() for the
    fields you wish to iterate over.  A more powerful matching
    mechanism may be implemented at some point.  A second ctor is
    provided for backward compatibility to iterate over a domain.
 */
class KnownBlockIter {
private:
  /// 
  KnownListEntry* pos;
  NetlistName *name;
public:
  /// Iterate over any matching names.
  KnownBlockIter(const NetlistName &);
  /// Iterate over the given domain's knownlist
  KnownBlockIter(const char *dom);
  /// Iterate over every block
  KnownBlockIter();
  /// 
  ~KnownBlockIter();
  /// Step to the next matching block.
  Block* next();
  inline Block* operator++(POSTFIX_OP) { return next();}
  /// Reset to the beginning
  void reset();
};

#endif   /* KNOWNBLOCK_H_INCLUDED */
