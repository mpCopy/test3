// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM_INTERFACE_INCLUDE_FILE__
#define __TDCM_INTERFACE_INCLUDE_FILE__
// Copyright Keysight Technologies 2009 - 2011  

typedef void* TDCM_Package;

typedef int (*TDCM_SetSignalFP)(TDCM_Package,int,int,int,const char*);
typedef int (*TDCM_SetIntergerParameterFP)(TDCM_Package,int,int);
typedef int (*TDCM_SetRealParameterFP)(TDCM_Package,int,double);
typedef int (*TDCM_SetStringParameterFP)(TDCM_Package,int,char*);

typedef int (*TDCM_AddMeasurementFP)(TDCM_Package,const char*);
typedef char* (*TDCM_GetConstraintsFileNameFP)(TDCM_Package);
typedef void (*TDCM_SetTestLimitFP)(TDCM_Package,char*,double,double);

typedef void (*TDCM_InitializeFP)(TDCM_Package);
typedef void (*TDCM_EvaluateFP)(TDCM_Package,double,double*,int);
typedef void (*TDCM_FinalizeFP)(TDCM_Package);

typedef void (*TDCM_PrintFatalError)(const char*,const char*);
typedef void (*TDCM_PrintError)(const char*,const char*);
typedef void (*TDCM_PrintWarning)(const char*,const char*);
typedef void (*TDCM_PrintStatus)(const char*,const char*);

typedef void  (*TDCM_Sweep_open)(void*);
typedef void  (*TDCM_Sweep_close)(void*);
typedef void  (*TDCM_Sweep_setInteger)(void*,int);
typedef void  (*TDCM_Sweep_setReal)(void*,double);
typedef void  (*TDCM_Sweep_setString)(void*,char*);


typedef void* (*TDCM_Output_new)(const char*,const char*);
typedef void  (*TDCM_Output_delete)(void*);
typedef void* (*TDCM_Output_newSweep)(void*,const char*);
typedef void  (*TDCM_Output_define)(void*,const char*,int,
				    const char**,int,int);

typedef void (*TDCM_Output_setAttributes)(void*,const char**,int);
typedef void (*TDCM_Output_start)(void*);
typedef void (*TDCM_Output_end)(void*);
typedef void (*TDCM_Output_outputReal)(void*,double,double*);
typedef void (*TDCM_Output_outputString)(void*,char*,double*);

typedef const char*(*TDCM_GetNodeName)(int);

struct TDCM_Interface{
  TDCM_SetSignalFP setSignal;

  TDCM_SetIntergerParameterFP setIntegerParameter;
  TDCM_SetRealParameterFP setRealParameter;
  TDCM_SetStringParameterFP setStringParameter;

  TDCM_AddMeasurementFP addMeasurement;
  TDCM_InitializeFP initialize;
  TDCM_EvaluateFP evaluate;
  TDCM_FinalizeFP finalize;
  
  TDCM_GetConstraintsFileNameFP getConstraintsFileName;
  TDCM_SetTestLimitFP setTestLimit;

  TDCM_PrintFatalError printFatalError;
  TDCM_PrintError printError;
  TDCM_PrintWarning printWarning;
  TDCM_PrintStatus printStatus;

  TDCM_Sweep_open SweepOpen;
  TDCM_Sweep_close SweepClose;
  TDCM_Sweep_setInteger SweepSetInteger;
  TDCM_Sweep_setReal SweepSetReal;
  TDCM_Sweep_setString SweepSetString;

  TDCM_Output_new OutputNew;
  TDCM_Output_delete OutputDelete;
  TDCM_Output_newSweep OutputNewSweep;
  TDCM_Output_define OutputDefine;
				    
  TDCM_Output_setAttributes OutputSetAttribute;
  TDCM_Output_start OutputStart;
  TDCM_Output_end OutputEnd;
  TDCM_Output_outputReal OutputReal;
  TDCM_Output_outputString OutputString;
  TDCM_GetNodeName GetNodeName;

  TDCM_Package object;
};

typedef int(*TDCM_LoadPackageFP)(const char*,const char*,struct TDCM_Interface*,int);



#if defined __cplusplus

#ifndef _WIN32
#define TDCM_EXPORT extern "C" 
#else
#define TDCM_EXPORT extern "C" __declspec(dllexport)
#endif
#else
#define TDCM_EXPORT extern 
#endif

#endif
