/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/ptolemyapi/api/PtolemyAPI.h,v $ $Revision: 1.30 $ $Date: 2011/08/25 01:50:07 $ */

#ifndef PTOLEMYAPI_H_INCLUDED
#define PTOLEMYAPI_H_INCLUDED
// Copyright 2000 - 2014 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#include "ptolemyapiDll.h"
#include "compat.h"
#include "HashTable.h"

// We don't include Ptolemy Header files to easily link in other build systems
class Block;
class Universe;
class BlockList;
class StateList;
class Galaxy;
class PtData;
class ptParser;
class APIErrorHelper;
#ifdef THREADED
class ptThreadAPI;
#endif

class PtolemyAPI {
public:
  PtolemyAPI(const char* targetNetlistName, const char* domain);
#if defined(PTLINUX)
  // I had to turn off virtual because on Linux the PtolemyAPI 
  // virtual table symbol was not being found for the shared
  // library that depends on libptolemyapi.so
  ~PtolemyAPI();
#else
  virtual ~PtolemyAPI();
#endif
  int setBlockState(Block* b,const char* name,const char* desc,const char* initValue=0);
  int connect(Block* source, const char* output,
	      Block* sink,   const char* input,
	      int numberDelays=0, const char* initDelayValues = 0);
  void expand(Block* b, const char* name, int size);
  void setBuffer(Block* b, int size, void* buffer, double* index=0);
  void addGalaxyState(Galaxy*,const char* type, const char* name,const char* desc,const char* val=0);
#ifndef PARSESYM
  void evalExpressions(Galaxy*, ptParser&);
#endif
  void getExpressions(Block*, StateList&);
  Universe* universe;

  int init();
#ifdef THREADED
  void createThread();
#endif
  int setParameter(const char* args=0);
  int setParameter(const char* name, int val);
  int setParameter(const char* name, double val);
  int setParameter(const char* name, const char* val);
  void setArgs(const char* direction, const char* name, int size, void** data, double* time, int length );
  void setTStep(const char* name, double tStep);
  int run();
  int wrapup();
  int error() const;
  PtData* getPtData(const char* var);
  int fillSimData(const char * var, long* numPoints, char** indepName, double** indep, double** dep);

  // Set only if there is no gemini
  APIErrorHelper * errorH;
  const char* getError();
  const char* getWarn();
  const char* getMessage();

  HashTable args;
  
#ifdef THREADED
  ptThreadAPI* thread; 
#endif

  static PtolemyAPI* lookup(const char* apiName);

  static void insert(const char* apiName, PtolemyAPI* api);

  static void remove(const char* apiName);

private:
  DllImport static HashTable apiTable;

};

#endif   /* PTOLEMYAPI_H_INCLUDED */
