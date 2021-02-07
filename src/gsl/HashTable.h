/* @(#) $Source: /cvs/wlv/src/linker/source/HashTable.h,v $ $Revision: 1.5 $ $Date: 2012/01/06 01:04:24 $ */

#ifndef HASHTABLE_H_INCLUDED
#define HASHTABLE_H_INCLUDED
// Copyright Keysight Technologies 2001 - 2017  

#ifndef _HashTable_h
#define _HashTable_h 1
/**************************************************************************
Version identification:
@(#)HashTable.h	1.7	3/7/96

Ported from John Ousterhout's Tcl implementation by Joe Buck

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


**************************************************************************/

#ifdef __GNUG__
#pragma interface
#endif


#ifndef POSTFIX_OP

#define POSTFIX_OP int

#endif


typedef void* Pointer;

// Certain compilers need to have destructors protected
#if defined(aix_xlC) || (defined(hpux) || defined(__hpux) && !defined(__GNUC__))
#define NEED_PROTECT_HASHENTRY_DESTRUCTOR
#endif

class HashTable;		// defined below

/// HashEntry is used for each entry in the table.
class HashEntry {
  friend class HashTable;
  friend class HashTableIter;
public:
  /// To most clients, a HashEntry is just a key-value pair
  const char* key() const { return stringkey;}
  /// 
  Pointer value() const { return clientData;}

  /// Ptr to containing hash table.
  HashTable* table() const { return tablePtr;}

  /** Modify the value in the cell, using the table cleanup function
    to discard the old data, if any.*/
  HashEntry& setData(Pointer);

  /**@name Functions for use with array-notation on HashTable */
  //@{
  /** {\tt value = table[key]}.

    Pointer is void * -- prefer to write this one as the underlying
    type.*/
  operator void * () const { return value();}

  /// {\tt table[key] = newvalue}
  HashEntry& operator=(Pointer newVal) {
    return setData(newVal);
  }

  /** Assignment operator copies only the value (so table["a"] =
    table["b"] works right)*/
  HashEntry& operator=(const HashEntry& arg) {
    return setData(arg.value());
  }
  //@}

#ifndef NEED_PROTECT_HASHENTRY_DESTRUCTOR
  ~HashEntry();
#endif

protected:
  /// Dummy default constructor so derived classes can be made.
  HashEntry() {}
#ifdef NEED_PROTECT_HASHENTRY_DESTRUCTOR
  /** Destructor frees the stringkey string.  Only HashTable may
    delete a HashEntry.*/
  ~HashEntry();
#endif

private:
  /// Constructor can be invoked only by HashTable class
  HashEntry(HashTable* t,HashEntry** b,const char* k);

  /// Pointer to next entry in this hash bucket, or NULL for end of chain
  HashEntry *nextPtr;
  /// Pointer to table containing entry
  HashTable *tablePtr;	
  /** Pointer to bucket that points to first entry in this entry's
    chain: used for deleting the entry*/
  HashEntry **bucketPtr;	
  /// Data associated with this HashEntry
  Pointer clientData;	
  /// string-valued key.  Stored on heap.
  char* stringkey;	
};

// Here is the main hash table class.
const int SMALL_HASH_TABLE = 4;

/** A hash table.  This code is derived from the hash table
  implementation in Tcl version 7.0.

  It differs in that the key is always a character string, and is on
  the heap; we don't use the trick of using a variable-sized array at
  the end of a struct since it isn't legal C++ and would lead to
  problems for derived classes.

  We support array-style notation, as in table["a string"].  Referring
  to an array entry creates the entry with a null pointer as value.
  The return value of HashTable::operator[](const char* key) is a
  reference to the corresponding HashEntry.  Using this method means
  that [] notation cannot be used on a const HashTable (use "lookup"
  instead).

  Further, a mechanism is added to automatically clean up entries on
  deletion, and to correctly copy entries when the assignment operator
  or copy constructor are used.  Finally, "const" is used where
  appropriate.  */
class HashTable {
  friend class HashTableIter;
public:
  /// 
  HashTable() { init();}
  /// 
  virtual ~HashTable() { destroy();}

  /** Copy constructor.  This is a deep copy of the HashEntry objects.
    the copyData function determines how the clientData fields of
    HashEntry objects are copied.*/
  HashTable(const HashTable& arg) {
    init();
    addAllElements(arg);
  }

  /** Assignment operator.  This is effectively a combination of the
    destructor and the copy constructor.*/
  HashTable& operator=(const HashTable& arg);

  /// Delete all entries in a hashtable
  void clear() {
    destroy();
    init();
  }

  /// Number of entries
  int size() const { return numEntries;}

  /// Lookup data in hash table
  Pointer lookup(const char* key) const {
    HashEntry* h = findEntry(key);
    return h ? h->clientData : 0;
  }

  /// See if entry exists
  int hasKey(const char* key) const {
    return (findEntry(key) != 0);
  }

  /** Insert new item.  If there was a previous item its data are
    cleaned up with the cleanup function.*/
  void insert(const char* key, Pointer data);

  /// Remove entry
  int remove(const char* key) {
    HashEntry* h = findEntry(key);
    return h ? removeEntry(h) : 0;
  }

  /** Return statistics on hash table.  Returned string is on heap and
    must be deleted by the caller.*/
  char * stats() const;

  /// Support array notation.  Return value is a reference to an entry.
  HashEntry& operator[](const char* key) {
    return *createEntry(key);
  }

  /** Cleanup procedure for clientData of HashEntry objects to be
    deleted. Default implementation does nothing.*/
  virtual void cleanup(Pointer);

  /** Correctly copy a clientData element, returning the new copy.
    Default implementation returns the arg. (so that the assignment
    operator results in identical Pointers for value fields).*/
  virtual Pointer copyData(Pointer) const;

protected:
  /** Rebuild hash table if it gets too large.  factor is by what
    factor to multiply the number of buckets by.  it MUST be a power
    of 2 (and this is not checked).*/
  void rebuild(int factor);

  /// Add all elements of one table to another table
  void addAllElements(const HashTable& arg);

  /// Find entry for key
  HashEntry* findEntry(const char* key) const;

  /// Find or create entry for key
  HashEntry* createEntry(const char* key);

  /// Remove and delete entry
  int removeEntry(HashEntry *);

  /** Destroy all elements (destructor body).  WARNING: hashtable must
    not be used until a subsequent init() call, though multiple
    destroy() calls are safe.*/
  void destroy();

  /** Constructor initialization.  WARNING: calling this on a
    HashTable with entries will cause memory leaks.*/
  void init();

private:
  /// common routine for findEntry and createEntry
  HashEntry* searchBucket(const char* key, int index) const;

  /** Pointer to bucket array.  Each element points to first entry in
    bucket's hash chain, or NULL.*/
  HashEntry **buckets;	      
  /// Bucket array used for small tables (to avoid mallocs and frees).
  HashEntry *staticBuckets[SMALL_HASH_TABLE];
  /// Total number of buckets allocated at **bucketPtr
  int numBuckets; 
  /// Total number of entries present in table
  int numEntries;
  /// Enlarge table when numEntries gets to be this large
  int rebuildSize;
};

/** An iterator for a {\tt \Ref{HashTable}}.

  HashTableIter is a standard Ptolemy-style iterator that steps
  through the entries in the hash table.  Order may be just about
  anything.


  To process all key-value pairs one could say something like

  \begin{verbatim}
  HashTableIter nextEntry(someHashTable);
  HashEntry *e;
  while ((e = nextEntry++) != 0)
    doSomethingWith(e->key(), e->value());
  \end{verbatim}

   @see: Iterators, HashTable*/
class HashTableIter {
public:
  /// 
  HashTableIter(HashTable&);
  /// 
  HashEntry* next();
  /// 
  HashEntry* operator++(POSTFIX_OP) { return next();}
  /// 
  void reset() { nextIndex = 0; }
private:
  /// 
  HashTable* tablePtr;
  /// 
  int nextIndex;
  /// 
  HashEntry* nextEntryPtr;
};

/// A helper class for {\tt \Ref{TextTable}}
class TextEntry : private HashEntry {
public:
  /// 
  using HashEntry::key;
	
  /// Coerce value to a string.
  const char* value() const { return (const char*)HashEntry::value();}

  /// Set a new value: old one is deleted.
  TextEntry& setData(const char* newVal);

  /**@name Functions for use with array-notation on TextTable */
  //@{
  /// value = textTable[string]
  operator const char* () const { return value();}

  /// textTable[string] = value
  TextEntry& operator=(const char* newVal) {
    return setData(newVal);
  }

  /// textTable[string1] = textTable[string2]
  TextEntry& operator=(const TextEntry& arg) {
    return setData(arg.value());
  }
  //@}
};

/** A TextTable is a HashTable in which the data value is a character
  string that is saved on the heap.  We have corresponding classes
  TextEntry and TextTableIter.*/
class TextTable : private HashTable {
  friend class TextTableIter;
public:
  /// Constructor
  TextTable() {}

  /** Destructor. This destructor must call destroy() rather than
    relying on ~HashTable so that the correct cleanup function will be
    used -- the TextTable::cleanup fn will not be used from the
    HashTable destructor.  */
  ~TextTable() { destroy();}

  /// Copy constructor
  TextTable(const TextTable& arg) : HashTable(arg) {}

  /// Assignment
  TextTable& operator=(const TextTable& arg) {
    HashTable::operator=(arg);
    return *this;
  }

  /// Lookup: coerce value back to const char*
  const char* lookup(const char* key) const {
    return (const char*)HashTable::lookup(key);
  }

  /// Insert: save data on heap, then insert.
  void insert(const char* key, const char* data);

  /// Override cleanup method: it deallocates the data field.
  /*virtual*/ void cleanup(Pointer);

  /// Override copyData method: it does a savestring of the data field.
  /*virtual*/ Pointer copyData(Pointer) const;

  /**@name Re-export baseclass fns */
  //@{
  /// 
  using HashTable::remove;
  /// 
  using HashTable::stats;
  /// 
  using HashTable::hasKey;
  /// 
  using HashTable::size;
  /// 
  using HashTable::clear;
  //@}

  /// support array notation.  Return value is a reference to an entry
  TextEntry& operator[](const char* key) {
    return *(TextEntry*)createEntry(key);
  }
};

/** Iterator for {\tt \Ref{TextTable}}
 
  @see Iterators, TextTable */
class TextTableIter : private HashTableIter {
public:
  /// 
  TextTableIter(TextTable& t) : HashTableIter(t) {}
  /// 
  TextEntry* next() { return (TextEntry*)HashTableIter::next();}
  /// 
  TextEntry* operator++(POSTFIX_OP) { return next();}
  /// 
  using HashTableIter::reset;
};
#endif








#endif   /* HASHTABLE_H_INCLUDED */
