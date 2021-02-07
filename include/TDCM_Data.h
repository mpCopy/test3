// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM_DATA__INCLUDE_FILE__
#define __TDCM_DATA__INCLUDE_FILE__
// Copyright Keysight Technologies 2009 - 2011  

namespace TDCM{
  class Complex{
  public:
    double real;
    double imag;
  };
  enum DataType{
    UnknownType = 0,
    IntegerType = 1,
    RealType   = 2,
    ComplexType = 4,
    StringType  = 8
  };
  union Value{
    int     integer;
    double  real;
    Complex complex;
    char*   string;
    void*   object;
  };
  class Data{
  public:
    Value value;
    DataType type;
  };
 
  typedef int SignalType;
  typedef int ParameterID;
  const SignalType UndefinedSignalType = 0;
  class Signal{
  public:
    Signal(){type = UndefinedSignalType;p=n=0;packageSignal=0;}
    SignalType type;
    void* packageSignal;
    double p;
    double n;
  };
}
#endif
