#ifndef TARGETTASK_H_INCLUDE
#define TARGETTASK_H_INCLUDE
// Copyright 1998 - 2014 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#include "Block.h"

/* A target task, to be completed before terminating the simulator.
   By default, this class will not display status messages.  It is
   recommended however, to use both the setParent() and numFirings()
   methods.

   @author Jose Luis Pino*/
class TargetTask {
public:
  /// Constructor
  TargetTask() { 
    prnt=NULL;
    index=0; 
  }

  /// Destructor
  virtual ~TargetTask() {};

  /** Returns the percentage of the task complete. If unknown, this
      method must return -1. If the parent has been set, a status
      message stating that the block is collecting data will be
      displayed.  If numFirings()!=0 has been called, the the number
      of invocations will also be displayed.*/
  virtual double status();

  virtual int onList() {return 1;};

  /// 
  inline void setParent(Block* b) {
    prnt = b;
  }

  ///
  inline Block* parent() const {
    return prnt;
  }

  /** This method should be called in begin and go routines of the
      parent block:
      
      begin {
        // Initialize the number of firings.
	targetTask.numFirings() = 0;
	targetTask.setParent(this);
      }

      go {
        // Increment the number of firings.
	targetTask.numFirings()++;

	// User code here.
      }

   */
  inline int& numFirings() {
    return index;
  }

  /// Return TRUE if Task is Visual
  virtual int isVisual() const {
    return FALSE;
  }

protected:
  Block* prnt;
  int index;
};

/** A task that will not display a status message (such as a Tcl/Tk
    star). */
class VisualTargetTask: public TargetTask {
public:
  /// Do not display status message
  /*virtual*/ double status() {
    return -1;
  }

  /// Return TRUE if Task is Visual
  /*virtual*/ int isVisual() const {
    return TRUE;
  }
};

/* Controller for sink.  All sinks that collect data should declare 
   a private SinkControl data member.  The sink should call the 
   initialize method in begin and the collectData method in go. The 
   collectData method should be called only once in go.

   @author Jose Luis Pino */

class SinkControl: public TargetTask {
public:

  /// Constructor
  SinkControl();

  /** Initialize the controller.  This method should be called in the 
      begin method of the sink star.  If the first of the two initialize 
      functions is used the sink will control the simulation.  If the 
      second one is used the sink will not control the simulation.
  */

  void initialize( Block& master, double start_value, double stop_value, double step_value );
  void initialize( Block& master, double start_value, double step_value );

  /** Check if we have collected enough data.  This method should be
      called in the go method of the sink star.  The syntax should be:
      
      go {
        if (controller.collectData()) {
	  // All of the sink go code should be inside this if statement
        }
      }

      Note: It is assumed the collectData is called only once for each 
      invocation of go.*/

  int collectData();

  /// Return true if all the data has been collected
  inline int done() const { return doneFlag; }

  /// Remove sink from task list
  void stopControl();

  /// Returns the percentage of run complete for a given Sink
  double status();

  int onList() { return taskOnList; }

  /// return the current time
  inline double time() const { return last; }

  /// return the current index
  inline int index() const { return int( last ); }

  /// return the start value
  inline double start_value() const { return start; }

  /// return the stop value
  inline double stop_value() const { return stop; }

private:
  int taskOnList, doneFlag;
  double start, stop, current, last, increment;
};

/* Controller for source.  Sources which control the simulator should
   declare a private SourceControl member and call initialize and
   collectData  */
class SourceControl: public TargetTask {
public:
  /// Constructor
  SourceControl();

  /** Initialize the controller.  Call this method from the begin
      method of the source star.  The star should have a
      ControlSimulation query state with default NO.  Initialize the
      SourceControl only if ControlSimulation is YES.

      Call initialize with this and the number of particles that will
      be output, if known.  If unknown, you won't get % complete
      messages obviously.  */
  void initialize(Block& master, int particles = -1);

  /** Call this from go so the SourceControl can keep track of %
      complete.  It's harmless to call collectData on an uninitialized
      SourceControl, so no ControlSimulation check need to be done in
      go. */
  void collectData();

  /** Call this to manually stop control, ie - remove the
      SourceControl from the task list.  This need only be called when
      you called initialize with the default particles at -1.  Like
      collectData, it's harmless to call this on an uninitilized
      SourceControl, so no ControlSimulation check need be done. */
  void stopControl();

  /** Returns the % of a run complete, or -1 if unknown */
  /*virtual*/ double status();

  int onList() { return taskOnList; }

private:
  int taskOnList, stop;
};

class DynamicSink: public TargetTask {
public:
  /// Constructor
  DynamicSink();
  void initialize(Block& master);
  void removeTask();
  int onList();
  void setPort(PortHole& p);
private:
  int taskOnList;
  PortHole * port;
};

class DynamicSource: public TargetTask {
public:
  /// Constructor
  DynamicSource();
  void initialize(Block& master);
  void removeTask();
  int onList();
  void setPort(PortHole& p);
private:
  int taskOnList;
  PortHole * port;
};

#endif
