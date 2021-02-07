// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM__TRIGGER_INCLUDE_FILE__
#define __TDCM__TRIGGER_INCLUDE_FILE__
#include "TDCM_Vector.h"
#include "TDCM_Package.h"

namespace TDCM{

  enum TriggerType{
    RisingEdge = 0x01,
    FallingEdge = 0x02
  };
  
  enum SignalLocation{
    UnknownLocation = 0x00,
    BelowTrigger = 0x01,
    AboveTrigger = 0x02,
    AtTrigger = 0x04
  };
  
  class Trigger;
  class TriggerCallback{
  public:
    TriggerCallback();
    virtual ~TriggerCallback();
    virtual void event(Trigger* trigger) = 0;
  };

  class Signal;
  class Trigger{
  public:
    Trigger(double _level,TriggerType _triggerType);
    virtual ~Trigger();
    void initialize();
    int hits();
    double level();
    TriggerType triggerType();
    double time();
    void setSignal(Signal* signal,int type=-1);
    void registerCallback(TriggerCallback* triggerCB);
    void evaluate(double time);
    double getPositiveSignalValue();
    double getNegativeSignalValue();
  protected:
    void triggerEvent();
    virtual bool check(double _signal,double _time) = 0;
  protected:
    Vector<TriggerCallback*> triggerCBs;
    Signal* signal;
    Signal signalPrevious;
    bool signalUpdated;
    double previousTime;
    double currentTime;
    SignalLocation _location;
    double _triggerTime;
    double _time;
    long long _N;
    double _v0;
    double _t0;
    int _hits;
    double _level;
    TriggerType _triggerType;
    int nodeType;
  };
  
  
  class RisingEdgeTrigger:public Trigger{
  public:
    RisingEdgeTrigger(double level);			
  protected:
    virtual bool check(double _signal,double _time);
  };
  
  class FallingEdgeTrigger:public Trigger{
  public:
    FallingEdgeTrigger(double level);
  protected:
    virtual bool check(double _signal,double _time);
  };
}

#endif
