// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM__DESCRIPTOR__INCLUDE__FILE__
#define __TDCM__DESCRIPTOR__INCLUDE__FILE__

#include "TDCM_String.h"
#include "TDCM_Vector.h"
#include "TDCM_Data.h"

namespace TDCM{
  class Package;
  class Parameter;
  class Measurement;
   
  class BaseDescriptor{
  public:
    BaseDescriptor(const char* _name);
    virtual ~BaseDescriptor();
    String& getName();
  protected:
    String name;
  };

  class SignalDescriptor:public BaseDescriptor{
  public:
    SignalDescriptor(const char* _name,SignalType _signalType);
    virtual ~SignalDescriptor();
    SignalType getSignalType();
    void setSignalType(SignalType s);
  protected:
    SignalType signalType;
  };

  class MeasurementDescriptor:public BaseDescriptor{
  public:
    MeasurementDescriptor(const char* _name);
    virtual ~MeasurementDescriptor();
    void defineSignal(const char* _name);
    Vector<SignalDescriptor*>& getSignalDescriptors();
    virtual Measurement* createInstance() = 0;
  protected:
    Vector<SignalDescriptor*> signalDescriptors;
  };

  #define MAX_NUMBER_OF_SIGNALS 1024
  class PackageDescriptor:public BaseDescriptor{
  public:
    PackageDescriptor(const char* _name);
    virtual ~PackageDescriptor();

    void init();

    virtual Package* createInstance() = 0;

    
    void setNumberOfParameters(int numberOfParameters);
    void defineParameter(int parameterID,Parameter* parameter);
    Parameter** getParameters();
    int getNumberOfParameters();

    void defineSignalType(const char* _name);
    SignalType  getSignalType(const char* _name);
    const char* getSignalName(SignalType signalType);
   
    void defineMeasurement(MeasurementDescriptor* measurementDescriptor);
    MeasurementDescriptor* getMeasurementDescriptor(const char* _name);

   protected:
    SignalType currentSignalTypeID;
    String* signalTypeNames[MAX_NUMBER_OF_SIGNALS];

    int numberOfParameters;
    Parameter** parameters;

    Vector<MeasurementDescriptor*> measurements;
  };
}

#endif
