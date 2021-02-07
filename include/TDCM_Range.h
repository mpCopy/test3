// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM__RANGE_INCLUDE_FILE__
#define __TDCM__RANGE_INCLUDE_FILE__
#define N_INF -(1e100)
#define P_INF  (1e100)
enum __Comparison{__GT,__GTE,__LT,__LTE};

namespace TDCM{
  class Boundary{
  public:
    Boundary(double value,__Comparison type){
      this->boundary = value;
      this->type = type;
    }
    virtual ~Boundary( )  { }
    virtual bool check(double value){
      bool status = false;
      switch((int)this->type){
      case __GT:
	if(value > this->boundary)
	  status = true;
	break;
      case __GTE:
	if(value >= this->boundary)
	  status = true;
	break;
      case __LT:
	if(value < this->boundary)
	  status = true;
	break;
      case __LTE:
	if(value <= this->boundary)
	  status = true;
	break;
      }
      return status;
    }
  private:
    double boundary;
    __Comparison type;
  };
  
  class Range{
  public:
    Range(Boundary* a,Boundary* b){
      this->a = a;
      this->b = b;
    }
    ~Range(){
      delete this->a;
      delete this->b;
    }
    bool check(double value){
      return (this->a->check(value) && this->b->check(value));
    }
    bool check(int value){
      return (this->a->check((double)value) && this->b->check((double)value));
    }
  private:
    Boundary* a;
    Boundary* b;
  };
  
  class RangeUtility{
  public:
    static Range* RANGE(Boundary* a,Boundary* b);
    static Boundary* LT(double value);
    static Boundary* LTE(double value);
    static Boundary* GT(double value);
    static Boundary* GTE(double value);
  };
}
#endif
