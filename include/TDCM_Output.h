// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM__OUTPUT_INCLUDE_FILE__
#define __TDCM__OUTPUT_INCLUDE_FILE__

#include "TDCM_String.h"
#include "TDCM_Data.h"

namespace TDCM{
  class Package;
  class Output;
  class Measurement;
  class Sweep{
  public:
    Sweep(const char* _name,Output* _output);
    virtual ~Sweep();
    void set(double value);
    void set(int value);
    void set(char* value);
    virtual void open();
    virtual void close();
  protected:
    void* object;
    Output* output;
  };
  
  class Output{
  public:
    Output(Package* _package,Measurement* measurement,const char* _title);
    Output(Package* _package,const char* _title);
    virtual ~Output();
    Package* getPackage();

    void define(const char*   _iName,DataType _iDataType,
		const char** _dNames,DataType _dDataType,
		int _size);
    void setAttributes(const char** _attributes,int _attributeSize);
    virtual Sweep* createSweep(const char* _iName);
    virtual void   start();
    virtual void   end();
    virtual void   output(double _iValue,double* _dValue);
    virtual void   output(char*  _iValue,double* _dValue);
    
  private:
    Package* package;
    void* object;
  
  };
}

#endif
