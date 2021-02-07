/**************************************************************************
Version identification:
@(#)Target.h	2.36	7/30/96

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
 Date of creation: 9/25/91

 A Target is an object that controls execution.  It contains a Scheduler,
 for determining order of execution.

**************************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Target.h,v $ $Revision: 100.27 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef TARGET_H_INCLUDED
#define TARGET_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#include "StringList.h"
#include "IntState.h"
#include "StringArrayState.h"
#include "Block.h"
#include "HashTable.h"

class TargetTask;
class HPPlotHandler;
class Scheduler;
class Galaxy;
class EventHorizon;

/** An object that controls execution of the simulation. Class Target
    is derived from class Block (class \Ref{Block}); as such, it can
    have states and a parent (the fact that it can also have portholes
    is not currently used).  A Target is capable of supervising the
    execution of only certain types of Stars; the {\tt starClass}
    argument in its constructor specifies what type.  A Universe or
    InterpUniverse is run by executing its Target.  Targets have
    Schedulers, which as a rule control order of execution, but it is
    the Target that is ``in control''.

    A Target can have children that are other Targets; this is used,
    for example, to represent multi-processor systems for which code
    is being generated (the parent target represents the system as a
    whole, and child targets represent each processor).  */
class Target : public Block {
public:
  /** Constructor.  This is the signature of the Target
      constructor. {\tt name} specifies the name of the Target and
      {\tt desc} specifies its descriptor (these fields end up filling
      in the corresponding NamedObj fields).

      The {\tt starClass} argument specifies the class of stars that
      can be executed by the Target.  For example, specifying {\tt
      DataFlowStar} for this argument means that the Target can run
      any type of star of this class or a class derived from it.  The
      {\tt isA} function is used to perform the check.

      See the description of {\tt \Ref{starTypes}} below.*/
  Target(const char* name, const char* starClass, const char* desc = "",
	 const char* assocDom = 0);

  /// Destructor
  ~Target();

  /// Print the full name, descriptor, and state names and values
  /*virtual*/ StringList print(int verbose = 0) const;

  /// Return the domain of the galaxy if it exists 
  /*virtual*/ const char* domain() const;

  /// Invoke the begin methods of the constituent stars
  virtual void begin();

  /// Invoke the go methods of the constituent stars
  virtual int run();

  /// Invoke the wrapup methods of the constituent stars
  virtual void wrapup();

  /** Return the supported star class (the {\tt starClass}
    argument from the constructor).*/
  const char* starType() const { return starTypes.head(); }

  /// Return the scheduler currently associated with this target
  Scheduler* scheduler() const { return sched; }

  /// Halt iteration after TaskList empty?
  virtual int haltOnEmpty() const;

  /** Return the result of the {\tt clone} function as a Target.  It
      is used by the KnownTarget class, for example to create a Target
      object corresponding to a name specified from a user interface.

      This function makes for cleaner code: clone() is derived from
      Block and returns a duplicate obj so this cast is always safe.
      Redefine clone(), not cloneTarget!*/
  Target* cloneTarget() const { return (Target*)clone(); }

  /// Ask the scheduler to display its schedule
  virtual StringList displaySchedule();

  /**@name HP Plot*/
  //@{
  /** Return the HPPlotHandler associated with the target.  This
      pointer is set by PtolemyEngineDoAnalysis in the ptgem library.

      {\bf WARNING}: This pointer will be null, unless Ptolemy is
      running inside of gemini.*/
  HPPlotHandler* plotHandler();
  
  /// Set the HPPlotHandler
  void setPlotHandler(HPPlotHandler* p);

  //@}

  /**@name Pragmas*/
  //@{
  /** Return list of supported pragmas (annotations).  A Target may
      understand certain annotations associated with Blocks called
      ``Pragmas''.  For example, an annotation may specify how many
      times a particular Star should fire.  Or it could specify that a
      particular Block should be mapped onto a particular processor.
      Or it could specify that a particular State of a particular
      Block should be settable on the command line that invokes a
      generated program.

      The above method returns the list of names pragmas that a
      particular target understands (e.g. ``firingsPerIteration'' or
      ``processorNumber'').  In derived classes, each item in the list
      is a three part string, ``name type value'', separated by
      spaces.  The ``value'' will be a default value.  The
      implementation in class Target returns a StringList with only a
      single zero-length string in it.  The ``type'' can be any type
      used in states.*/
  virtual StringList pragma () const { return ""; }

  /** Return the value of all pragmas for a given block.  In derived
      classes, it returns a list of ``name value'' pairs, separated by
      spaces.  In the base class, it returns an empty string.  The
      {\tt parentname} is the name of the parent class (universe or
      galaxy master name).*/
  virtual StringList pragma (const char* /*parentname*/,
			     const char* /*blockname*/) const {
    return "";
  }

  /** Return the value of a pragma for a given block.  In derived
      classes, it returns a value.  In the base class, it returns a
      zero-length string.*/
  virtual StringList pragma (const char* /*parentname*/,
			     const char* /*blockname*/,
			     const char* /*pragmaname*/) const {
    return "";
  }

  /** Specify a pragma to a target.  The implementation in the base
      class ``Target'' does nothing.  In derived classes, the pragma
      will be registered in some way.  The return value is always a
      zero-length string.  */
  virtual StringList pragma (const char* /*parentname*/,
			     const char* /*blockname*/,
			     const char* /*name*/,
			     const char* /*value*/) {
    return "";
  }
  //@}

  /** Return the {\tt n}th child Target. NULL if no children or if
      {\tt n} exceeds the number of children.  */
  virtual Target* child(int n);

  /** Return the {\tt n}th child Target.  This is the same as {\tt
      child} if there are children.  If there are no children, an
      argument of 0 will return a pointer to the object on which it is
      called, otherwise a null pointer is returned.

      @see child*/
  Target* proc(int n) {
    if (n == 0 && nChildren == 0) return this;
    else return child(n);
  }

  /** Return number of processors. Return 1 if no children, otherwise
      the number of children.*/
  int nProcs() const { return children ? nChildren : 1; }

  /** Return TRUE if this target have the necessary resources to run
      the star.  Determine whether this target has the necessary
      resources to run the given star.  It is virtual in case later
      necessary.  The default implementation uses ``resources'' states
      of the target and the star.  */
  virtual int hasResourcesFor(Star& s, const char* extra = 0);

  /** Return TRUE if the child target have the necessary resource to
      run the star.  Determine whether a particular child target has
      resources to run the given star.  It is virtual in case later
      necessary.  */
  virtual int childHasResources(Star& s, int childNum);

  /** Initialize the target, given a galaxy.  Associate a Galaxy with
      the Target.  The default implementation just sets its galaxy
      pointer {\tt gal} to point to {\tt g}.  */
  virtual void setGalaxy(Galaxy& g);

  /// Zero the pointer to the current galaxy
  void clearGalaxy() { gal = 0; }

  /** Set the stopping condition.  The default implementation just
      passes this on to the scheduler.  */
  virtual void setStopTime(double);

  /** Reset the stopping condition for the wormhole containing this
      Target.  The default implementation just passes this on to the
      scheduler.  In addition to the action performed by {\tt
      setStopTime}, this function also does any synchronization
      required by wormholes.  */
  virtual void resetStopTime(double);

  /// Set the current time
  virtual void setCurrentTime(double);

  /**@name Code generation methods 

     The following methods are provided for code generation;
     schedulers may call these.  They may move to class CGTarget in a
     future Ptolemy release.*/
  //@{

  /// Generate code to begin an iteration 
  virtual void beginIteration(int repetitions, int depth);

  /// Generate code to end an iteration
  virtual void endIteration(int repetitions, int depth);

  /** Generate code for the star the way this target wants.  Function
      called to generate code for the star, with any modifications
      required by this particular Target (the default version does
      nothing).*/
  virtual void writeFiring(Star& s, int depth);

  /// Generate code to initialize loops
  virtual void genLoopInit(Star& s, int reps);

  /// Generate code to terminate loops
  virtual void genLoopEnd(Star& s);

  /**@name Code generation of conditionals */
  //@{
  /// Generate code to begin an if/then/else conditional construct
  virtual void beginIf(PortHole& cond, int truthdir, int depth,
		       int haveElsePart);

  /// Generate code to continue an if/then/else conditional construct
  virtual void beginElse(int depth);

  /// Generate code to end an if/then/else conditional construct
  virtual void endIf(int depth);

  /// Generate code to begin a while conditional construct
  virtual void beginDoWhile(int depth);

  /// Generate code to end a while conditional construct
  virtual void endDoWhile(PortHole& cond,int truthdir,int depth);
  //@}

  /** Return the communication cost.  The communication cost is the
      number of time units required to send {\tt nUnits} units of data
      whose type is the code indicated by {\tt type} from the child
      Target numbered {\tt sender} to the child target numbered {\tt
      receiver}.  The default implementation returns 0 regardless of
      the parameters.  No meaning is specified at this level for the
      type codes, as different languages have different types; all
      that is required is that different types supported by a
      particular target map into distinct type codes.  */
  virtual int commTime(int sender,int receiver,int nUnits, int type);

  //@}

  /// Return TRUE if the argument is a Target
  int isA(const char*) const;

  /// Class identification
  const char* className() const;

  /// Is the string a name of an ancestor of a child of the current target?
  virtual int childIsA(const char*) const;

  /// Return the pointer to the current galaxy
  Galaxy* galaxy() const { return gal; }
    
  /** All the supported stars for a given target.  To add support for
      a another class of star, just append to the starTypes
      StringList:
   
      {\tt starTypes += "NewStarClass";}*/
  StringList starTypes;
	
  /// Do I support the given star type?
  virtual int support(Star* s); 

  /**@name Reset the target and galaxy
  
     Resetting is occasionally necessary to undo certain operations
     done on a universe by a Scheduler or Target. An example is in
     parallel scheduling, where the original stars in the
     InterpUniverse are moved to the subGalaxies for the child Targets
     (see {\tt
     $PTOLEMY/src/domains/cg/parScheduler/ParProcessors.cc}). To
     signal that a the {\tt \Ref{InterpUniverse}} needs to be rebuilt
     upon the next run, the scheduler writer should invoke {\tt
     Target::\Ref{requestReset}()}.*/
  //@{
  /// 
  void requestReset();

  /// 
  int resetRequested();
  //@}

  inline SequentialList * getTaskList() {
	return &taskList;
  }

  /// Add a task to be completed to the task list 
  inline void addTask(TargetTask* task) {
    if (task && !taskList.member(task)) 
      taskList.append(task);
  }

  /// Remove a task from the task list. return TRUE if removed
  inline int removeTask(TargetTask* task) {
    return task? taskList.remove(task):FALSE;
  }

  /// Remove a task from the task list. return TRUE if removed
  inline int numberOfTasks() const {
    return taskList.size();
  }

  /** Display the status of the current simulation and return the
      percentage run complete for Sinks.

      @see SinkControl*/
  virtual double status();

  /** Return the number of non-visual tasks in TaskList */
  int nonVisualTasks() const;

  /// Populate the simulation data hash table
  void addPtData(const char* tnm, void* data) {
    if(!ptDataTable.lookup(tnm))
      ptDataTable.insert(tnm, data);
  }

  /// Get simulation data from hash table
  void* getPtData(const char* tnm) {
    return(ptDataTable.lookup(tnm));
  }
  void setDirectory(void* directoryArg){this->directory = directoryArg;}
  void* getDirectory(){return this->directory;}
protected:
  /** Run galaxySetup and schedulerSetup. This is the main
      initialization function for the target.  It is called by the
      {\tt initialize} function, which by default initializes the
      Target states.  The default implementation calls {\tt
      galaxySetup()}, and if it returns a nonzero value, then calls
      {\tt schedulerSetup()}.  */
  virtual void setup();

  /** Setup the galaxy, i.e. check star types and set target pointers.
      This method (and overloaded versions of it) is responsible for
      checking the galaxy belonging to the target.  In the default
      implementation, each star is checked to see if its type is
      supported by the target (because the {\tt isA} function reports
      that it is one of the supported star classes).  If a star does
      not match this condition an error is reported.  In addition,
      {\tt setTarget()} is called for each star with a pointer to the
      Target as an argument.  If there are errors, 0 is returned,
      otherwise 1.  */
  virtual int galaxySetup();

  /** Call setSched and compute the schedule.  This method (and
      overloaded versions of it) are responsible for initializing an
      execution of the universe.  The default implementation
      initializes the scheduler and calls {\tt setup()} on it.  */
  virtual int schedulerSetup();

  /** The following sets the scheduler and tells it which target
      belongs. The target's scheduler is set to {\tt sch}, which must
      either point to a scheduler on the heap or be a null pointer.
      Any preexisting scheduler is deleted.  Also, the scheduler's
      {\tt setTarget} member is called, associating the Target with
      the Scheduler.*/
  void setSched(Scheduler* sch);

  /// Delete the target's scheduler and sets the scheduler pointer to null
  void delSched();

  /// Add a child target
  void addChild(Target&);

  /// Remove the ``children'' list (no effect on children)
  void remChildren() { nChildren = 0; children = 0;}

  /** Delete all the ``children''.  This assumes that the child
    Targets were created with {\tt new}.*/
  void deleteChildren();

  /// Return the domain associated with the target
  const char* getAssociatedDomain() const { return associatedDomain; }

  StringArrayState OutVar; //TO BE OBSOLETED
  StringArrayState OutputPlan;
  IntState DefaultPartition;

private:
  ///
  HPPlotHandler* hpPlotHandler;

  /// reset target/galaxy flag
  int resetFlag;

  /// points to a linked list of children
  Target* children;

  /// points to the next sibling (child of same parent)
  Target* link;

  /// number of children
  int nChildren;

  /// scheduler for the target
  Scheduler* sched;

  /// galaxy of stars to be run on the target
  Galaxy* gal;

  /// domain associated with the parent target
  const char* associatedDomain;

  /// tasks to be completed
  SequentialList taskList;

  /// Simulation data
  HashTable ptDataTable;

  void* directory;

};
#endif   /* TARGET_H_INCLUDED */
