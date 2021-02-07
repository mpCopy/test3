// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM__PACKAGE__INCLUDE__FILE__
#define __TDCM__PACKAGE__INCLUDE__FILE__

#include "TDCM_Data.h"
#include "TDCM_Interface.h"
#include "TDCM_TestSet.h"
#include "TDCM_Utility.h"
#include "TDCM_String.h"
#include "TDCM_Descriptor.h"

namespace TDCM{
  class PackageDescriptor;
  class Measurement;
  class PackageSignal{
  public:
    PackageSignal();
    ~PackageSignal();
    void setSignals(double* solution);
    int positive;
    int negative;
    SignalType signalType;
    Vector<Signal*> reference;
  };

  class SignalContainer{
  public:
    String signalName;
    Signal* signal;
  };

  class Package{
  public:
    Package();
    virtual ~Package();
    
    void setDescriptor(PackageDescriptor* _descriptor);
    PackageDescriptor* getDescriptor();

    void initParameters();
    void initSignals();

    void setName(const char* _name);
    String& getName();

    void setOptimController(bool status);

    void warn(const char* message);
    void status(const char* message);    
    void error(const char* message);
    void fatalError(const char* message);
    const char* getNodeName(int index);

    void set(int parameterID,int value);
    void set(int parameterID,double value);
    void set(int parameterID,char* value);

    void setSignalSize(int _signalSize);
    bool setSignal(int index,int nodeP,int nodeN,const char* nodeType);
    
    int  getSignalSize();
    PackageSignal* getSignal(int index);
    
    virtual void initialize();
    virtual void evaluate(double time,double* solution,int size);
    virtual void finalize();
   
    bool isTransientOutputDisabled();
    bool getData(const char* dataName,int** dataObject);
    bool getData(const char* dataName,double** dataObject);

    void check(Measurement* measurement,const char* name,
	       DoubleVector& value,const char* outputName);
    void check(Measurement* measurement,const char* name,
	       double value,const char* outputName);


    static int loadPackage(const char* instanceName,
			   TDCM_Interface* interface,
			   int signalSize,PackageDescriptor* _descriptor);

    static int addMeasurement(TDCM_Package object,const char* measurement);
    static int setSignalInterface(TDCM_Package object,
				  int index,int nodeP,
				  int nodeN,const char* type);
    static int setIntegerParameter(TDCM_Package object,
				   int parameterID,int value);
    static int setRealParameter(TDCM_Package object,
				int parameterID,double value);
    static int setStringParameter(TDCM_Package object,
				  int parameterID,char* value);
  
    static void initializeCB(TDCM_Package object);
    static void evaluateCB(TDCM_Package object,double time,
			   double* solution,int size);
    static void finalizeCB(TDCM_Package object);
  
    static char* GetConstraintsFileName(TDCM_Package object);
    static void SetTestLimit(TDCM_Package object,
			     char* name,double min,double max);

    void registerSignal(const char* signalType,Signal* reference);
    Measurement* getMeasurement(const char* name,Signal& signal);
    String& getDataDirectory();
  protected:
    virtual void checkCompliance();
    void registerData(const char* dataName,int* dataObject);
    void registerData(const char* dataName,double* dataObject);
  
    void registerParameter(int parameterID,bool* p);
    void registerParameter(int parameterID,int* p);
    void registerParameter(int parameterID,double* p);
    void registerParameter(int parameterID,String* p);
    
    virtual void registerParameters() = 0;
    virtual void registerSignals();
    
  protected:
    String rootDirectory;
    String dataDirectory;
    bool saveWaveform;
    bool performCompliance;
    double startTime;
    String instanceName;
    void** parameterData;
    DataType* parameterType;
    int parameterSize;
    PackageDescriptor* descriptor;

    int signalSize;
    PackageSignal* signals;

    bool disableTransientOutput;
    bool optimController;
    Vector<Measurement*> measurements;
    PackageSignal** currentSignal;
    int currentSignalSize;
    int currentSignalIndex;
    Measurement* currentMeasurement;
    Vector<MeasurementDescriptor*> addedMeasurements;
    Vector<SignalContainer*> signalContainer;
    bool measurementsCreated;

    TDCM_PrintFatalError printFatalErrorFP;
    TDCM_PrintError printErrorFP;
    TDCM_PrintWarning printWarningFP;
    TDCM_PrintStatus printStatusFP;
    TDCM_GetNodeName getNodeNameFP;

  public:
    TDCM_Sweep_open SweepOpenFP;
    TDCM_Sweep_close SweepCloseFP;
    TDCM_Sweep_setInteger SweepSetIntegerFP;
    TDCM_Sweep_setReal SweepSetRealFP;
    TDCM_Sweep_setString SweepSetStringFP;

    TDCM_Output_new OutputNewFP;
    TDCM_Output_delete OutputDeleteFP;
    TDCM_Output_newSweep OutputNewSweepFP;
    TDCM_Output_define OutputDefineFP;
				    
    TDCM_Output_setAttributes OutputSetAttributeFP;
    TDCM_Output_start OutputStartFP;
    TDCM_Output_end OutputEndFP;
    TDCM_Output_outputReal OutputRealFP;
    TDCM_Output_outputString OutputStringFP;
    
    virtual char* getConstraintsFileName();
    void setTestLimit(const char* name,double min,double max);

  private:
    bool createMeasurements(SignalType* sTypes,int size,
			    MeasurementDescriptor* measurementDescriptor);
    TestSet testSet;
    int add(const char* measurement);
  };
}

#endif




