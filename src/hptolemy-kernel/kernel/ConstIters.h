/**************************************************************************
Version identification:
@(#)ConstIters.h	2.9	8/26/95

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
 Date of creation: 10/30/91

Iterators that work on const container objects, returning const
pointers to inside objects.

The more commonly used non-const iterators are defined in files
Block.h, PortHole.h, State.h, or Galaxy.h.

**************************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/ConstIters.h,v $ $Revision: 100.10 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef CONSTITERS_H_INCLUDED
#define CONSTITERS_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2015  

#ifdef __GNUG__
#pragma interface
#endif

#include "Block.h"
#include "PortHole.h"
#include "State.h"
#include "Galaxy.h"




/// Iterator to step through PortHoles in a constant PortList
class CPortListIter : private CNamedObjListIter {
public:
  /// 
  CPortListIter(const PortList& plist) : CNamedObjListIter (plist) {}
  /// 
  inline const PortHole* next() {
    return (const PortHole*)CNamedObjListIter::next();
  }
  /// 
  inline const PortHole* operator++(POSTFIX_OP) {
    return next();
  }
  /// 
  using CNamedObjListIter::reset;
};

/// Iterator to step through States in a constant StateList
class CStateListIter : private CNamedObjListIter {
public:
  /// 
  CStateListIter(const StateList& sl) : CNamedObjListIter (sl) {}
  /// 
  inline const State* next() {
    return (const State*)CNamedObjListIter::next();
  }
  /// 
  inline const State* operator++(POSTFIX_OP) {
    return next();
  }
  /// 
  using CNamedObjListIter::reset;
};

/// An iterator over a block's inputs (see \Ref{Iterators}).
class CBlockInputIter: public CPortListIter {
public:
  /// 
  inline CBlockInputIter(const Block& b):CPortListIter(b.inputPorts) {};
};

/// An iterator over a block's outputs (see \Ref{Iterators}).
class CBlockOutputIter: public CPortListIter {
public:
  /// 
  inline CBlockOutputIter(const Block& b):CPortListIter(b.outputPorts) {};
};

/// An iterator over a block's ports (see \Ref{Iterators})
class CBlockPortIter {
public:
  /// 
  CBlockPortIter(const Block& b): nextInput(b), nextOutput(b) {
    reset();
  }
  
  /// Methods to return the next porthole
  //@{
  /// Return the next porthole
  inline const PortHole* operator++(POSTFIX_OP) { return next();}

  /// Return the next porthole
  inline const PortHole* next() { 
    const PortHole* port = nextPort->next();
    if (!testIterator(port))
      port = nextPort->next();
    return port;
  }

  ///
  void reset() {
    nextInput.reset();
    nextOutput.reset();
    nextPort = &nextInput;
  }

private:
  ///
  CBlockInputIter nextInput;
  ///
  CBlockOutputIter nextOutput;
  ///
  CPortListIter* nextPort;
  ///
  inline int testIterator(const PortHole* p) {
    if (!p && (nextPort != &nextOutput)) {
      nextPort = &nextOutput;
      return FALSE;
    }
    else
      return TRUE;
  }
};

/// Iterator to step through States in a constant Block
class CBlockStateIter : public CStateListIter {
public:
  /// 
  CBlockStateIter(const Block& b) : CStateListIter (b.states) {}
};

/// Iterator to step through PortHoles in a constant MPHList
class CMPHListIter : private CNamedObjListIter {
public:
  /// 
  CMPHListIter(const MPHList& plist) : CNamedObjListIter (plist) {}
  /// 
  inline const MultiPortHole* next() {
    return (const MultiPortHole*)CNamedObjListIter::next();}
  /// 
  inline const MultiPortHole* operator++(POSTFIX_OP) { return next();}
  /// 
  using CNamedObjListIter::reset;
};

/// Iterator to step through MultiPortHoles in a constant Block
class CBlockMPHIter : public CMPHListIter {
public:
  /// 
  CBlockMPHIter(const Block& b) : CMPHListIter (b.multiports) {}
};

/// Iterator to step through PortHoles in a constant MultiPortHole
class CMPHIter : public CPortListIter {
public:
  /// 
  CMPHIter(const MultiPortHole& mph) : CPortListIter (mph.ports) {}
};

/// Iterator to step through Blocks in a constant BlockList
class CBlockListIter : private CNamedObjListIter {
public:
  /// 
  CBlockListIter(const BlockList& sl) : CNamedObjListIter (sl) {}
  /// 
  inline const Block* next() {
    return (const Block*)CNamedObjListIter::next();
  }
  /// 
  inline const Block* operator++(POSTFIX_OP) { return next();}
  /// 
  using CNamedObjListIter::reset;
};

/// Iterator to step through Blockss in a constant Galaxy
class CGalTopBlockIter : public CBlockListIter {
public:
  /// 
  CGalTopBlockIter(const Galaxy& g) : CBlockListIter(g.blocks) {}
};

#endif   /* CONSTITERS_H_INCLUDED */
