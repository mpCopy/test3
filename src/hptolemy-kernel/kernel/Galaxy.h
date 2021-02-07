/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Galaxy.h,v $ $Revision: 100.19 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef GALAXY_H_INCLUDED
#define GALAXY_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2015  

#ifdef __GNUG__
#pragma interface
#endif

#include "Star.h"

/**************************************************************************
Version identification:
@(#)Galaxy.h	2.32	2/29/96

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

 Programmer:  E. A. Lee, D. G. Messerschmitt, J. Buck
 Date of creation: 1/17/90

Definition of the Galaxy class, together with the BlockList class.

**************************************************************************/

class Target;

/// A list of Geodesics (or nodes)
class NodeList : private NamedObjList {
  friend class NodeListIter;
public:
  /// 
  NodeList() {}
  /// 
  ~NodeList() { deleteAll();}
  /// 
  void put(Geodesic& g);
  /// 
  inline Geodesic* nodeWithName (const char* name) {
    return (Geodesic*)NamedObjList::objWithName(name);
  }
  /// 
  int remove(Geodesic* g);
  /// pass along baseclass methods.
  using NamedObjList::size;
  /// 
  using NamedObjList::deleteAll;
  /// 
  using NamedObjList::initialize;
};

/// An iterator for a NodeList (see \Ref{Iterators})
class NodeListIter : private NamedObjListIter {
public:
  /// 
  NodeListIter(NodeList& n) : NamedObjListIter(n) {}
  /// 
  Geodesic* next();
  /// 
  inline Geodesic* operator++(POSTFIX_OP) { return next();}
  /// 
  using NamedObjListIter::reset;
};

/// A list of blocks
class BlockList : private NamedObjList {
  friend class BlockListIter;
  friend class CBlockListIter;
public:
  /// Constructors
  //@{
  /// Constructs an empty BlockList
  BlockList():NamedObjList() {};

  /// Constructs a BlockList by copying the contents on another.
  BlockList(BlockList&);

  /** Constructs a BlockList from a Galaxy of either the atomic blocks
      (by default) or the top blocks (if atomicBlocks=FALSE).
      
      @see \Ref{GalStarIter} and \Ref{GalTopBlockIter}*/
  BlockList(Galaxy&,int atomicBlocks=TRUE);
  //@}

  /// Operations that alter the list
  //@{

  /// Add Block to list
  inline void put(Block& b) {NamedObjList::put(b);}

  /// Add all of the Blocks to list
  void put(BlockList&);

  /// Remove a Block from the list.  Note: block is not deleted
  inline int remove (Block* b) { return NamedObjList::remove(b);}

  /// Copy the contents of the given block list into this one
  BlockList& operator=(BlockList&);

  /// Reverse the order of the Blocks in the BlockList
  BlockList& reverse();

  /// Delete all of the Blocks in the list
  using NamedObjList::deleteAll;

  /// Call initialize on all of the Blocks in the list
  using NamedObjList::initialize;

  /// Sort items using comparison function
  using NamedObjList::sort;

  //@}


  /// Methods that query the list properties
  //@{

  /// Return first Block on list (const, non-const forms)
  inline Block* head () {return (Block*) NamedObjList::head();}

  /// 
  inline const Block* head () const {
    return (const Block*) NamedObjList::head();
  }

  /// See if Block is present in list
  int isInList (const Block& b) const;

  /// Find Block with given name
  inline Block* blockWithName(const char* name) {
    return (Block*)objWithName(name);
  }

  /// Find Block with given name, const version
  inline const Block* blockWithName(const char* name) const {
    return (const Block*)objWithName(name);
  }

  /// Return the number of blocks in the list
  using NamedObjList::size;
  
  /** Return a StringList that contains a list of all of the Blocks
      names.  The seperator defaults to '\n'. */
  StringList print(char seperator = '\n');

  //@}

};

/// An iterator for BlockList, (see \Ref{Iterators})
class BlockListIter : private NamedObjListIter {
public:
  /// 
  BlockListIter(BlockList& sl) : NamedObjListIter (sl) {}
  /// 
  inline Block* next() { return (Block*)NamedObjListIter::next();}
  /// 
  inline Block* operator++(POSTFIX_OP) { return next();}
  /// 
  using NamedObjListIter::reset;
  /// 
  using NamedObjListIter::remove;
};

/** A Block that has an internal hierarchical structure.  In
  particular, it contains other Blocks (some of which may also be
  galaxies).  It is possible to access only the top-level blocks or to
  flatten the hierarchy and step through all the blocks, by means of
  the various iterator classes associated with Galaxy.

  While we generally define a different derived type of Star for each
  domain, the same kinds of Galaxy (and derived classes such as
  InterpGalaxy --- class \Ref{InterpGalaxy}) are used in each domain.
  Accordingly, a Galaxy has a data member containing its associated
  domain (which is set to null by the constructor).

  PortHoles belonging to a Galaxy are, as a rule, aliased so that they
  refer to PortHoles of an interior Block, although this is not a
  requirement.  */
class Galaxy : public Block  {
  friend class BlockList;
  friend class GalTopBlockIter;
  friend class CGalTopBlockIter;
public:
  /// Constructor
  Galaxy ();

  /// Destructor
  ~Galaxy ();

  /// Build an identical copy of the Galaxy
  /*virtual*/ Block* clone () const;

  /// Return TRUE if argument is a Galaxy
  /*virtual*/ int isA(const char*) const;
 
  /// Return the string ``Galaxy''
  /*virtual*/ const char* className() const;

  /// System preinitialize method - recursively calls preinitialize in subsystems
  void preinitialize();

  /** System initialize method.  Derived Galaxies should not redefine
    initialize; they should write a {\tt setup()} method to do any
    class-specific startup.*/
  void initialize();

  /// System wrapup method - recursively calls wrapup in subsystems
  void wrapup();

  /// Add block to the galaxy and set its name
  inline void addBlock(Block& b,const char* bname=NULL) {
    if (bname)
      b.setName(bname);
    blocks.put(b);
    b.setParent(this);
  }

  /** Remove the block {\tt b} from the galaxy's list of blocks, if it
    is in the list.  The block is not deleted.  If the block was
    present, 1 is returned; otherwise 0 is returned.  */
  inline int removeBlock(Block& b) { return blocks.remove(&b);}

  /** Get the head of the blocks list.  This is useful when there are
    Clusters with only one star in them.  By default, when a cluster
    hierarchy is created, every star is a Cluster.  For such clusters,
    calling head() will give access to the star immediately rather
    than having to set up an iterator to get it.*/
  inline Block* head() {return blocks.head();}

  /// Initialize states
  virtual void initState();

  /// Initialize PortHoles
  virtual void initPorts();

  /// Return the number of blocks in the galaxy.
  inline int numberBlocks() const {return blocks.size();}

  /// Print a description of the galaxy
  /*virtual*/ StringList print(int verbose) const;

  /// Returns FALSE (galaxies are not atomic blocks)
  /*virtual*/ int isItAtomic () const; // {return FALSE;}

  /// Return myself as a Galaxy
  Galaxy& asGalaxy(); // { return *this;}

  /// Return myself as a Galaxy, const version
  const Galaxy& asGalaxy() const; // { return *this;}

  /// Return my domain
  const char* domain () const;

  /** Set the domain of the galaxy.  This may become a protected member
    in the future.*/
  inline void setDomain(const char* dom) { myDomain = dom;}

  /// Add a block to the list of blocks to be deleted after initialization
  void deleteBlockAfterInit(Block& b);

  /// Set the target for all the stars in the galaxy
  /*virtual*/ int setTarget(Target*);

  /// Empty all the blocks from the galaxy - they are not deallocated 
  void empty();
    
  /** Move blocks to parent(default) or specified galaxy.  We can
  optionally remove and delete the galaxy from the parent list (TRUE
  by default).  We may not want to do this for effeciency purposes -
  instead it is possible to use ListIter::remove.  Be careful, if
  FALSE is specified, we'll be left with a dangling pointer.*/
  virtual int flatten(Galaxy* = NULL, int = TRUE);

  /// Support blockWithName message to access internal block list, const version
  inline const Block* blockWithName (const char* name) const {
    return blocks.blockWithName(name);
  }

  /// Support blockWithName message to access internal block list
  inline Block* blockWithName (const char* name) {
    return blocks.blockWithName(name);
  }

protected:

  /** A list of nodes (or geodesics) of the galaxy.  This list
    will only contain members as class Cluster or InterpGalaxy. */
  NodeList nodes;

  /// Connect sub-blocks with an initial delay
  inline void connect(GenericPort& source, GenericPort& destination,
		      int numberDelays = 0, const char* initDelayValues = 0) {
    source.connect(destination, numberDelays, initDelayValues);
  }

  /// Connect a Galaxy PortHole to a PortHole of a sub-block
  inline void alias(PortHole& galPort, PortHole& blockPort) {
    galPort.setAlias(blockPort);
  }

  /// Connect a Galaxy MultiPortHole to a MultiPortHole of a sub-block
  inline void alias(MultiPortHole& galPort, MultiPortHole& blockPort) {
    galPort.setAlias(blockPort);
  }

  /// Initialize subblocks
  void initSubblocks();

  /// Initialize states in subblocks
  void initStateSubblocks();

  /// Initialize portholes in subblocks
  void initPortsSubblocks();

  /// Delete sub-blocks
  inline void deleteAllBlocks() { blocks.deleteAll();}
    
private:
  /// Keep a list of component Blocks
  BlockList	blocks;

  /// List of blocks to delete after initialization
  BlockList blocksToDelete;

  /// my domain
  const char* myDomain;

  /// helper for clone
  GenericPort& aliasGalPort(Galaxy *, const GenericPort *) const;
};

/// An iterator class over the top blocks in a galaxy (see \Ref{Iterators})
class GalTopBlockIter : public BlockListIter {
public:
  /// 
  GalTopBlockIter(Galaxy& g) : BlockListIter(g.blocks) {}
};
#endif   /* GALAXY_H_INCLUDED */
