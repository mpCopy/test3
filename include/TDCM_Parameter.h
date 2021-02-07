// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM_PARAMETER_INCLUDE_FILE__
#define __TDCM_PARAMETER_INCLUDE_FILE__
// Copyright Keysight Technologies 2009 - 2011  

#include "TDCM_Range.h"
#include "TDCM_Data.h"
#include "TDCM_String.h"

namespace TDCM{
  class Parameter{
  public:
    Parameter(const char* name,DataType _dataType,bool _hasDefault){
      this->set(name,_dataType,_hasDefault);
      this->range = 0;
      this->isCopy = false;
    }
    ~Parameter(){
      if(!this->isCopy){
	if(this->range)
	  delete this->range;
      }
    }
    bool check(double value){
      if(this->range)
	return this->range->check(value);
      return true;
    }
    bool check(int value){
      if(this->range)
	return this->range->check(value);
      return true;
    }
    bool aCopy(){return this->isCopy;}
    String* name(){return &(this->_name);}
    DataType dataType(){return this->_dataType;}
    bool hasDefault(){return this->_hasDefault;}
  protected:
    void set(const char* name,DataType _dataType,bool _hasDefault){
      this->_name = name;
      this->_dataType = _dataType;
      this->_hasDefault = _hasDefault;
    }
  protected:
    Range* range;
    String _name;
    DataType _dataType;
    bool _hasDefault;
    bool isCopy;
  };
  
  template <class T>
  class __Parameter:public Parameter{
  public:
    __Parameter(const char* name,DataType dataType,Range* range,
		T _defaultValue):
      Parameter(name,dataType,true){
      this->_defaultValue = _defaultValue;
      this->range = range;
    }
    __Parameter(const char* name,DataType dataType,Range* range):
      Parameter(name,dataType,false){
      this->range = range;
    }
    T defaultValue(){
      return this->_defaultValue;
    }
  private:
    T _defaultValue;
  };

  typedef __Parameter<double> __RealParameter;
  typedef __Parameter<int> __IntegerParameter;
  typedef __Parameter<String> __StringParameter;

  class ParameterUtility{
  public:
    static Parameter* RealParameter(const char* name,
				    Range* range,double defaultValue);
    static Parameter* RealParameter(const char* name,Range* range);
    static Parameter* IntegerParameter(const char* name,
				Range* range,int defaultValue);
    static Parameter* IntegerParameter(const char* name,Range* range);
    static Parameter* StringParameter(const char* name,const char* defaultValue);
    static Parameter* StringParameter(const char* name);
  };
}

#endif
