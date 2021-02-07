// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM_MEASUREMENT_INCLUDE_FILE_
#define __TDCM_MEASUREMENT_INCLUDE_FILE__
// Copyright Keysight Technologies 2009 - 2011  

#include "TDCM_String.h"
#include "TDCM_Trigger.h"
#include "TDCM_Descriptor.h"
#include "TDCM_Utility.h"
#include "TDCM_Vector.h"
#include "TDCM_TestSet.h"

namespace TDCM{
  class Package;

  class Measurement:public TriggerCallback{
  public:
    Measurement();
    virtual ~Measurement();

    void setDescriptor(MeasurementDescriptor* descriptor);
    MeasurementDescriptor* getDescriptor();
    bool getEnableEvaluation();
    Vector<Signal*>* getSignals();
    void clearTriggers();
    void evaluateTriggers(double time);
    void setName(const char* name);
    String& getName();
    virtual void initialize() = 0;
    virtual void event(Trigger* trigger) = 0;
    virtual void evaluate(double time);
    virtual void finalize() = 0;
    virtual void checkCompliance() = 0;
    virtual void setPackage(Package* package) = 0;
    virtual void registerSignals() = 0;
    Vector<MeasurementTestResults*>* getComplianceTestResults();
  protected:
    void check(char* name,DoubleVector& vector,const char* outputName=NULL);
    void check(char* name,double value,const char* outputName=NULL);
    virtual Package* __package__() = 0;
    void save(const char* title,
	      const char* iName,const char* dName,DoubleVector& data);
    void save(Summary& summary);
    Trigger* addRisingEdgeTrigger(Signal* nodeReference,double level);
    Trigger* addFallingEdgeTrigger(Signal* nodeReference,double level);
    Trigger* addPositiveRisingEdgeTrigger(Signal* nodeReference,double level);
    Trigger* addNegativeRisingEdgeTrigger(Signal* nodeReference,double level);

    void setEnableEvaluation(bool state);
  protected:
    String name;
    Vector<Trigger*> triggers;
    Vector<Signal*> signals;
    Vector<MeasurementTestResults*> complianceTestResults;
    MeasurementDescriptor* descriptor;
    bool performEvaluate;
  };
}


#endif
