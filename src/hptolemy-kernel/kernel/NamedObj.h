#ifndef NAMEDOBJ_H_INCLUDED
#define NAMEDOBJ_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2015  

/*@(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/NamedObj.h,v $ $Revision: 100.18 $ $Date: 2011/08/25 01:47:10 $ */

/**************************************************************************
UCB Version identification: NamedObj.h	2.22 6/21/96

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
 Date of creation: 1/28/90
 Revisions:

**************************************************************************/

#ifdef __GNUG__
#pragma interface
#endif

#include "StringList.h"
#include "isa.h"
#include "FlagArray.h"
#include "Attribute.h"




class Block;
class ErrorHelper;

/** An object with a name, a descriptor, and a parent Block.

  NamedObj is the baseclass for most of the common
  Ptolemy objects.  A NamedObj is, simply put, a named
  object; in addition to a name, a NamedObj has a pointer
  to a parent object, which is always a Block (a type of
  NamedObj). This pointer can be null. A NamedObj also
  has a descriptor.

  {\bf Warning!} NamedObj assumes that the name and
  descriptor "live" as long as the NamedObj does.  They
  are not deleted by the destructor, so that they can be
  compile-time strings.
  */
class NamedObj {
public:

  /** Constructor. NamedObj has a default constructor, which sets the name and
    descriptor to empty strings and the parent pointer to null.  */
  NamedObj () : errorHelper(0), nm(""),prnt(0), myDescriptor(""),
    attributeBits(0) {}

  /// Construct an object with a given name, parent and descriptor
  NamedObj (const char* name, Block* parent,const char* descriptor)
    : errorHelper(0), nm(name), prnt(parent), myDescriptor(descriptor), attributeBits(0) {}

  /** Return the string ``NamedObj''.  This method returns the name of
    the class.  It should have a new implementation supplied for every
    derived class (except for abstract classes, where this is not
    necessary).  */
  virtual const char* className() const;

  /// Return just the the local portion of the name of the class 
  inline const char* name() const { return nm; }

  /// Return the descriptor
  inline const char* descriptor() const { return myDescriptor; }

  /// Return a pointer to the parent block
  inline Block* parent() const { return prnt;}
 
  /** Return the full name of the object.  

    The {\tt fullName()} method returns the full name of the object.
    This has no relation to the class name; it specifies the specific
    instance's place in the universe-galaxy-star hierarchy.  The
    default implementation returns names that might look like

    {\tt universe.galaxy.star.port}

    for a porthole; the output is the fullName of the parent, plus a period,
    plus the name of the NamedObj it is called on.  */
  virtual StringList fullName() const;

  /// Set the name of this object
  inline void setName(const char* my_name) {
    nm = my_name;
  }

  /// Set the parent of this object
  inline void setParent(Block* my_parent) {
    prnt = my_parent;
  }

  /// Set the name and parent of this object
  void setNameParent (const char* my_name,Block* my_parent) {
    setName(my_name);
    setParent(my_parent);
  }

  /// Prepare the object for system execution.
  virtual void initialize() = 0;
  
  /** Return a string describing this object; if verbose is 0, a
    somewhat more compact form is printed than if verbose is 1 */
  virtual StringList print (int verbose) const;

  /** Returns TRUE if the argument is a {\tt NamedObj}.

    The {\tt isA} method should be redefined for all classed derived
    from {\tt NamedObj}.  Its function is to return TRUE if the
    argument is the name either of the class or of one of the base
    classes.  To make this easy to implement, a macro {\tt ISA\_FUNC}
    is provided; for example, in the file {\tt Block.cc} we see the
    line:

    {\tt ISA\_FUNC(Block,NamedObj);}

    since {\tt NamedObj} is the base class from which {\tt Block} is
    derived. This macro creates the function definition

    \begin{verbatim}
    int Block::isA(const char* cname) const {
        if (strcmp(cname,"Block") == 0) return TRUE;
	else return NamedObj::isA(cname);
    }
    \end{verbatim} */
  virtual int isA(const char* cname) const;

  /** Declare destructors for all NamedObjs virtual, does nothing by
    default */
  virtual ~NamedObj();

  /// Return attribute bits
  inline bitWord attributes() const { return attributeBits;}
  
  /// Set the attribute bits
  inline bitWord setAttributes(const Attribute& attr) {
    return attributeBits = attr.eval(attributeBits);
  }
  
  /// Clear the attribute bits
  inline bitWord clearAttributes(const Attribute& attr) {
    return attributeBits = attr.clearAttribs(attributeBits);
  }
  
  /** An array of flags for use by targets and schedulers.

    Many schedulers and targets need to be able to mark blocks
    in various ways, to count invocations, or flag that the block has
    been visited, or to classify it as a particular type of block.  To
    support this, we provide an array of flags that are not used by
    class Block, and may be used in any way by a Target or scheduler.
    The array can be of any size, and the size will be increased
    automatically as elements are referenced.  For readability and
    consistency, the user should define an enum in the Target class to
    give the indices, so that mnemonic names can be associated with
    flags, and so that multiple schedulers for the same target are
    consistent.
    
    For instance, if {\tt b} is a pointer to a {\tt Block}, a target
    might contain the following:

    \begin{verbatim}
    private:
        enum {
	    visited = 0,
	    fired = 1
	}
    \end{verbatim}

    which can then be used in code to set and read flags in a readable
    way,

    \begin{verbatim}
    b->flags[visited] = TRUE;
    ...
    if (b->flags[visited]) { ... }
    \end{verbatim}

    {\bf WARNING:} For efficiency, there is no checking to prevent two
    different pieces of code (say a target and scheduler) from using
    the same flags (which are indexed only by non-negative integers)
    for different purposes.  The policy, therefore, is that the target
    is in charge.  It is incumbent upon the writer of the target to
    know what flags are used by schedulers invoked by that target, and
    to avoid corrupting those flags if the scheduler needs them
    preserved.  We weighed a more modular, more robust solution, but
    ruled in out in favor of something very lightweight and fast.  */
  FlagArray flags;

  /** The descriptor is set to the given argument.  The string pointed
    to by argument must live as long as the NamedObj does.  */
  void setDescriptor(const char* d) { myDescriptor = d;}

  /** Optional ErrorHelper associated to this NamedObj.  Currently
      used to report objects connected to an automatically inserted
      Star.

      @see ErrorHelper*/
  ErrorHelper* errorHelper;

private:
  // name of the object
  const char* nm;

  // pointer to this object's parent Block
  Block* prnt;

  // descriptor of the object
  const char* myDescriptor;

  // attributes
  bitWord attributeBits;

};

/** A sequential list of NamedObjs.

  Class NamedObjList is simply a list of objects of class
  NamedObj. It is privately inherited from class SequentialList, and,
  as a rule, other classes privately inherit from it. It supports only
  a subset of the operations provided by SequentialList; in
  particular, objects are added only to the end of the list. It
  provides extra operations, like searching for an object by name and
  deleting objects.

  This object enforces the rule that only const pointers to members
  can be obtained if the list is itself const; hence, two versions of
  some functions are provided.*/
class NamedObjList : private SequentialList {
  friend class NamedObjListIter;
  friend class CNamedObjListIter;
  friend class FastNamedObjListIter;
public:
  /// 
  NamedObjList();

  /// Add an object to the end of the list
  void put(NamedObj& s) {SequentialList::put(&s);}

  /** Put a new object before an existing object.  If the existing
      object is not on the list, prepend new object to the list. */
  inline void putBefore(NamedObj& newObj, NamedObj& existingObj) {
    SequentialList::putBefore(&newObj,&existingObj);
  }
  
  /** Put a new object after an existing object.  If the existing
      object is not on the list, append new object to the list. */
  inline void putAfter(NamedObj& newObj, NamedObj& existingObj) {
    SequentialList::putAfter(&newObj,&existingObj);
  }

  /// Remove only the links to the objects, do not delete the objects
  using SequentialList::initialize;

  /// 
  using SequentialList::size;

  ///
  using SequentialList::sort;

  /// Delete all NamedObjs and reset the list
  void deleteAll();

  /** Find the first NamedObj on the list whose name is equal to
    {\tt name}, and return a pointer to it.  Return 0 if it is not
    found.  */
  NamedObj* objWithName(const char* name) { return findObj(name); }

  /// Return the first object with the given name, const version
  const NamedObj* objWithName(const char* name) const {
    return findObj(name);
  }

  /// Apply the {\tt initialize} method to each NamedObj on the list
  void initElements();

  /** Return a pointer to the first object on the list (0 if none).
    There are two forms, one of which can be applied to const
    NamedObjList objects.*/
  inline NamedObj* head() {return (NamedObj*)SequentialList::head();}

  /// Return the first object on the list, const version
  inline const NamedObj* head() const {
    return (const NamedObj*)SequentialList::head();
  }

  /// Remove the object from the list, do not delete object
  int remove(NamedObj* o) { return SequentialList::remove(o);}

private:
  /// 
  NamedObj* findObj(const char* name) const;
};

/// An iterator for {\tt \Ref{NamedObjList}} (see \Ref{Iterators})
class NamedObjListIter : private ListIter {
public:
  /// 
  NamedObjListIter(NamedObjList& sl);
  /// 
  inline NamedObj* next() { return (NamedObj*)ListIter::next();}
  /// 
  inline NamedObj* operator++(POSTFIX_OP) { return next();}
  /// 
  using ListIter::reset;
  /// 
  using ListIter::remove;
};

/// An iterator for a constant {\tt \Ref{NamedObjList}} (see \Ref{Iterators})
class CNamedObjListIter : private ListIter {
public:
  /// 
  CNamedObjListIter(const NamedObjList& sl);
  /// 
  inline const NamedObj* next() { return (const NamedObj*)ListIter::next();}
  /// 
  inline const NamedObj* operator++(POSTFIX_OP) { return next();}
  /// 
  using ListIter::reset;
};

/// An iterator for a constant {\tt \Ref{NamedObjList}} (see \Ref{Iterators})
class FastNamedObjListIter : private FastListIter {
public:
  inline FastNamedObjListIter(const NamedObjList &l) : FastListIter(l) {}
  inline NamedObj* head() { return (NamedObj*)FastListIter::head(); }
  inline NamedObj* next() { return (NamedObj*)FastListIter::next(); }
};
#endif   /* NAMEDOBJ_H_INCLUDED */
