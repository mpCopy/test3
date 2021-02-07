/*******************************************************************************
********************            BEGIN gslexprt.h            ********************
*******************************************************************************/

#ifndef GSLEXPRT_H_INCLUDED
#define GSLEXPRT_H_INCLUDED
// Copyright Keysight Technologies 2008 - 2017  

/*
   The following ifdef block is the standard way of creating macros which make exporting 
   from a DLL simpler. All files within this DLL are compiled with the api_DLL_BUILD
   symbol defined on the command line. This symbol should not be defined on any project
   that uses this DLL. This way any other project whose source files include this file see 
   GSL_API functions as being imported from a DLL, whereas this DLL sees symbols
   defined with this macro as being exported.

  Optionally, to use a static version of API, the library and the application should both be compiled
  with GSL_STATIC.
*/

#ifdef ALL_LIBS_STATIC
    #ifndef GSL_STATIC
        #define GSL_STATIC
    #endif
#endif

#if defined(_WIN32)
    #if defined(GSL_STATIC)
	    #define GSL_API
    #elif defined(gsl_DLL_BUILD) || defined(gsl_qt_DLL_BUILD)
	    #define GSL_API __declspec(dllexport)
    #else
	    #define GSL_API __declspec(dllimport)
    #endif
#elif defined(linux)
	    #define GSL_API __attribute__ ((visibility("default")))
#else
    #define GSL_API
#endif

/*
// This class is exported from the dll
class GSL_API CMyClass {
public:
	CMyClass(void);
	// TODO: add your methods here.
};

extern GSL_API int nMyInt;

GSL_API int MyFunction(void);
*/


#endif

/*******************************************************************************
********************             END gslexprt.h             ********************
*******************************************************************************/
