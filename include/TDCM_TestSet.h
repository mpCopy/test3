// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM__TEST__SET__INCLUDE_FILE__
#define __TDCM__TEST__SET__INCLUDE_FILE__

#include "TDCM_Vector.h"
#include "TDCM_String.h"
#include <string.h>
#include <math.h>

namespace TDCM{
  class TestLimit{
  public:
    String name;
    double min;
    double max;
  };

  class TestSet{
  public:
    TestSet();
    ~TestSet();
    void addTest(const char* name,double min,double max);
    TestLimit* getTest(const char* name);
  protected:
    Vector<TestLimit*> testSet;
  };

  class ComplianceHistogram{
  public:
    ComplianceHistogram(int size,double min,double max){
      this->size = size+1;
      this->min = min;
      this->max = max;
      this->data = new int[this->size];
      double range = (max-min);
      if(range > 0){
	slope = (this->size-1)/range;
	constantBin = false;
      }
      else{
	slope = 1.0;
	constantBin = true;
      }
      this->clear();
    }
    ~ComplianceHistogram(){
      delete[] this->data;
    }
    void clear(){
      this->counter = 0;
      memset(this->data,0,sizeof(int)*size);
    }
    void bin(double value){
      if(!constantBin){
	int bin = int(floor(((value-min)*slope)*(1+1.12e-16)));
	if((bin >= 0) && (bin < size)){
	  this->data[bin]++;
	  this->counter++;
	}
      }
      else{
	this->counter++;
      }
    }
    bool constantBin;
    int counter;
    double slope;
    int size;
    double min;
    double max;
    int* data;
  };

  class MeasurementTestResults{
  public:
    String* outputName;
    int passCounter;
    double lowerMinPass;
    double upperMinPass;
    
    int    upperViolationCounter;
    double upperMaxDiff;
    
    int    lowerViolationCounter;
    double lowerMaxDiff;
    ComplianceHistogram* passHistogram;
    ComplianceHistogram* failHistogram;
    TestLimit* limits;
  };

}

#endif
