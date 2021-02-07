/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/DataFlowStar.h,v $ $Revision: 100.18 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef DATAFLOWSTAR_H_INCLUDED
#define DATAFLOWSTAR_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifdef __GNUG__
#pragma interface
#endif
/******************************************************************
Version identification:
@(#)DataFlowStar.h	1.7	8/17/95

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

 DataFlowStar is the base class for a variety of types of stars that
 obey dataflow semantics.

 DynDFStar (dynamic dataflow star) is the base class for dataflow stars
 that have dynamic behavior.

*******************************************************************/

#include "Star.h"
#include "Fraction.h"


class EGNode;
class DFPortHole;
class StarTree;

/** Abstract base class for a variety of types of stars that obey
    dataflow semantics.

    DynDFStar (dynamic dataflow star) is the base class for dataflow
    stars that have dynamic behavior.*/
class DataFlowStar : public Star {
public:
  /// Constructor
  DataFlowStar();

  /** The number of repetitions of the star in a periodic schedule.
      Initialized to 0 by constructor.  Set to correct value by an SDF
      scheduler.  It is represented as a fraction for the convenience
      of the scheduler. */
  Fraction repetitions;

  /** Return 0 if the star can be run now, 1 if it can't be run now
      but should be runnable later, and 2 if it has been run as often
      as it needs to be.*/
  virtual int notRunnable();

  /// Returns TRUE if we can defer the star, FALSE if we cannot
  virtual int deferrable();

  /** Cost of executing the star.  Can be used in deciding which
      eligible star to run.*/
  virtual unsigned runCost();

  /// Execution time, for schedulers that use it
  virtual int myExecTime();

  /// Initialize -- prepare for scheduling
  /*virtual*/ void initialize();

  /// Number of times this star is executed in the schedule
  inline int reps() const {
    return repetitions.den() == 1 ? repetitions.num() : \
      repetitions.num()/repetitions.den();
  }

  /// Get the components firing statistics
  virtual int getStatistics() {return 0;}

  /// turn off the stars which are done
  virtual void shutDown();
  virtual int getDisable(){return disable;}

  /// 
  int isA(const char*) const;

  /// Return TRUE if star is SDF in all contexts - FALSE by default
  virtual int isSDF() const;

  /** Return TRUE if star is SDF in the current context (e.g. it is
    BDF but conditions on all intra-cluster arcs match) FALSE by
    default.*/
  virtual int isSDFinContext() const;

  /// Return TRUE if star is a source
  inline int isSource() const { return nInP == 0;}
  /// Return TRUE if star is a sink
  inline int isSink() const { return nInP == numberPorts();}

  /// Return the number of inputs
  inline int numInputs() const { return nInP;}
  /// Return the number of outputs
  inline int numOutputs() const { return numberPorts()-nInP;}

  /**@name Functions for use by scheduler

    These functions are for use in SDF scheduling, e.g. when the stars
    are SDF or can be treated as SDF for scheduling purposes.  */
  //@{
  /** Simulate execution of the star, as part of schedule computation.
  
    Returns 0 if the star was run successfully; 1 if it cannot be run
    at present; 2 if has already been run as often as it needs to be;
    3 if its execution is to be deferred (only if deferFiring is
    true)*/
  virtual int simRunStar(int deferFiring);

  /// Move data and execute the go function.  OVERRIDE IF NOT SDF!
  int run();

  /**@name Functions for use with the loop scheduler.  Default no-op */
  //@{
  /// 
  virtual void beginLoop(int reps,DFPortHole* cond=0,int relation=0);
  /// 
  virtual void endLoop();
  //@}
  //@}

  /**@name Functions for dynamic execution */
  //@{
  /// default returns TRUE
  virtual int setDynamicExecution(int); 
  /// default returns 0
  virtual DFPortHole* waitPort() const;
  /// default: return 0
  virtual int waitTokens() const; 
  //@}

  /** Make a duplicate DataFlowStar.  This will call Star::clone and
    then set DataFlowStar specific data members such as repetitions.*/
  /*virtual*/ Block* clone () const;

  /** Methods to access the expanded graph node.  These facilities are
      used by the loop scheduler and the parallel schedulers. */
  //@{
  /// Return the expanded graph master
  inline EGNode *myMaster() { return master;}

  /// Set the expanded graph master
  inline void setMaster(EGNode *m) {master = m;}
  //@}

  StarTree* treeNode;

protected:
  /// Initialize the port counts used by isSource, isSink, etc.
  void initPortCounts();

  /// Check that SDF scheduling can be used.
  int okSDF() const {
    int status = isSDFinContext();
    if (!status) schedError();
    return status;
  }
  /// Generate error msg -- can't use SDF scheduling
  void schedError() const;

  /** The number of times the star has been scheduled.  During
    scheduling, the scheduler must keep track of how many times it has
    scheduled a star.  This is a convenient place to do that.*/
  unsigned noTimes;

private:
  /// number of ports that are inputs
  int nInP;

  /// pointer to master of instances for an expanded graph
  EGNode *master;

  int disable;

};

/// An iterator of the dataflow star's ports
class DFStarPortIter : public BlockPortIter {
public:
  /// 
  DFStarPortIter(DataFlowStar& s) : BlockPortIter(s) {}
  /// 
  DFPortHole* next();
  /// 
  DFPortHole* operator++(POSTFIX_OP) { return next();}
};

#endif   /* DATAFLOWSTAR_H_INCLUDED */
