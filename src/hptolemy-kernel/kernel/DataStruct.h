/**************************************************************************
Version identification:
@(#)DataStruct.h	2.16	1/12/96

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

 Programmer:  D. G. Messerschmitt, J. Buck and Jose Luis Pino
 Date of creation: 1/17/89

This header file contains basic container class data structures
used widely. Each container class stores a set of void*'s,
with different ways of accessing them. Normally, a data structure
is derived from one of these classes by adding conversion from
the type of interest to and from the void*, allocating and
deallocating memory for the objects, etc.

**************************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/DataStruct.h,v $ $Revision: 100.17 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef DATASTRUCT_H_INCLUDED
#define DATASTRUCT_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2015  

#ifdef WIN32
#pragma warning(disable:4512)
#pragma warning(disable:4514)
#pragma warning(disable:4516)
#pragma warning(disable:4706)
#pragma warning(disable:4710)
#endif

#ifdef __GNUG__
#pragma interface
#endif

#include "type.h"

/// A helper class for \Ref{SequentialList}
class SingleLink {
  friend class SequentialList;
  friend class ListIter;
  friend class FastListIter;
 protected:
  /// 
  SingleLink *next,*previous;

  /// 
  Pointer e;

  /** Construct a new link for a SequentialList - a optional
      argument is provided to declare the next link in the list. */
  SingleLink(Pointer newItem,SingleLink* nextLink = NULL);

  /// 
  void remove();
};

/** A single linked list.  This class implements a single linked list
  with a count of the number of elements.  The constructor produces a
  properly initialized empty list, and the destructor deletes the
  links.  However, the destructor does not delete the items that have
  been added to the list; this is not possible because it has only
  {\tt void *} pointers and would not know how to delete the items.

  SequentialList::deleteAll which is present in UCB Ptolemy, was
  removed from HP Ptolemy because it may lead to memory leaks and
  possible core dumps.  The UCB Ptolemy code would delete a void
  pointer from the list.  This delete call does not call the
  destructor of the element.  deleteAll is now defined in
  NamedObjList.

  There is an associated iterator class for SequentialList called
  \Ref{ListIter}.  */
class SequentialList
{
  friend class ListIter;
  friend class FastListIter;
public:
  /**@name Constructors */
  //@{
  /// Default
  SequentialList() : lastNode(0), dimen(0) {}

  /// Constructor, with an initial pointer for list
  SequentialList(Pointer a);

  //@}

  /// Destructor
  ~SequentialList()  { initialize(); }

  /**@name SequentialList information functions
  
    These methods return information about the SequentialList but do
    not modify it.  */
  
  //@{

  /// Return the size of the list
  inline int size() const { return dimen;}
	
  /// Return the last item from the list (0 if the list is empty)
  inline Pointer head() const  // Return head, do not remove
  {
    return lastNode ? lastNode->next->e : 0;
  }
	
  /// Return the last item from the list (0 if the list is empty)
  inline Pointer tail() const {	// return tail, do not remove
    return lastNode ? lastNode->e : 0;
  }

  /** Return the {\tt n}th item on the list (0 if there are
  fewer than {\tt n} items)*/
  Pointer elem(int) const;

  /// Return TRUE if this list is empty
  inline int empty() const { return (lastNode == 0);}

  /// Return TRUE if the list has a Pointer that is equal to {\tt arg}
  int member(Pointer arg) const;

  //@}
       
  /**@name Other SequentialList methods

    These methods modify the list they are applied to.  */
  //@{

  /// Add an item at the beginning of the list
  void prepend(Pointer a);

  /// Add an item at the end of the list
  void append(Pointer a);	    

  /// Add an item at the end of the list
  void put(Pointer a) {append(a);}

  /** Put a new item before an existing item.  If the existing
      item is not on the list or NULL, prepend new item to the list. */
  void putBefore(Pointer newItem, Pointer existingItem);
  
  /** Put a new item after an existing item.  If the existing
      item is not on the list or NULL, append new item to the list. */
  void putAfter(Pointer newItem, Pointer existingItem);

  /** Remove the pointer {\tt a } from the list if present - return
      TRUE if present*/
  int remove(Pointer a);

  /// Return and remove the head of the list - return NULL if list is empty
  Pointer getAndRemove();	

  /// Return and remove the tail of the list - return NULL if list is empty
  Pointer getTailAndRemove();

  /** Remove all links from the list, do not delete items pointed to
    by the pointers that were on the list*/
  void initialize();	

  /** Sort the elements in a SequentialList using the given comparison 
      function.  See qsort. */
  void sort(int(*compare)(const void*,const void*));

  //@}
private:
  // Remove a link from the list
  SingleLink* removeLink(SingleLink&);

  // Store head of list, so that there is a notion of 
  // first node on the list, lastNode->next is head of list 
  SingleLink *lastNode;
  int dimen;
};


/** A queue of pointers.

  This class implements a queue, which may be used to implement FIFO
  or LIFO or a mixture.  The methods needed to implement these
  specialized types of queues are {\tt \Ref{putTail}} (or {\tt
  \Ref{put}}), {\tt \Ref{putHead}}, {\tt \Ref{getTail}}, and {\tt
  \Ref{getHead}} (or {\tt \Ref{get}}).*/
class Queue : private SequentialList
{
public:
  /// Build an empty queue
  Queue() {}

  /**@name Methods to move pointers into or out of the queue

    These methods move pointers into or out of the queue.  All of them
    are implemented on top of the (hidden) {\tt \Ref{SequentialList}}
    functions. */
  //@{

  /// Synonym for {\tt \Ref{putTail}}
  void put(Pointer p) {append(p);}

  /// Synonym for {\tt \Ref{getHead}}
  Pointer get() {return getAndRemove();}

  /// Add an element to the end of queue
  void putTail(Pointer p) {append(p);}

  /// Add an element to the beginning of queue
  void putHead(Pointer p) {prepend(p);}

  /// Remove and return the element at the beginning of the queue
  Pointer getHead() {return get();}

  /// Remove and return the element at the end of the queue
  Pointer getTail() {return getTailAndRemove();}

  //@}

  /// Return the number of elements in the queue
  using SequentialList::size;

  /// Empty the queue
  using SequentialList::initialize;

  /// Return the queue length
  inline int length() const { return size();} // TEMPORARY

  /// Destructor
  ~Queue() {}
};

/// An iterator for {\tt \Ref{SequentialList}}(see \Ref{Iterators})
class ListIter { 
public: 
  /// Construct an ListIter attached to a SequentialList 
  inline ListIter(const SequentialList& l) : list(&l) { reset(); }

  /// Reset to the beginning of a list
  void reset();

  /// Return the next element
  Pointer next();
    
  /// Return the next element
  inline Pointer operator++ (POSTFIX_OP) { return next();}

  /// Attach the ListIter to a different {\tt SequentialList}
  void reconnect(const SequentialList&);

  // remove the currently pointed to ref and update the
  // the ref pointer - if next hasn't been called, the lastNode
  /// will be removed
  void remove();
private:
  const SequentialList* list;
  SingleLink *ref;
  int startAtHead;
};

/// A faster, less featured, iterator
class FastListIter {
public:
  inline FastListIter(const SequentialList& l) : list(&l)
    { ref = l.lastNode ? l.lastNode->next : 0; }

  /// Return the current element
  inline Pointer head()
    { return ref ? ref->e : 0; }

  /// Return the next element
  inline Pointer next()
    { if (ref==list->lastNode) return 0; else ref=ref->next; return ref->e; }
private:
  const SequentialList *list;
  SingleLink *ref;
};    

/** Class implements a stack, where elements are added (pushed) to the
top of the stack or removed (pop'ed) from the top of the stack. In
addition, we allow elements to be added to the bottom of the stack.  */
class Stack : private SequentialList
{
public:
  /// Construct an empty stack
  Stack() {}

  /**@name Methods to move pointers onto or off of the stack */
  //@{

  /// Add element at the top of the stack
  void pushTop(Pointer p) {prepend(p);}

  /// Remove and return element from the top of the stack
  Pointer popTop() {return getAndRemove();}

  /// Add element to the bottom of the stack
  void pushBottom(Pointer p) {append(p);}
  
  //@}

  /// Access but do not remove element from top of stack
  Pointer accessTop() const {return head();}

  /// Empty the stack
  using SequentialList::initialize;

  /// Return the number of elements in the stack
  using SequentialList::size;

  /// Need destructor since baseclass is private, so others can destroy
  ~Stack() {}
};

#endif   /* DATASTRUCT_H_INCLUDED */
