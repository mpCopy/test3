// Copyright Keysight Technologies 2001 - 2014  
#ifndef PTOLEMYDATA_H_INCLUDED
#define PTOLEMYDATA_H_INCLUDED

#ifdef __GNUG__
#pragma interface
#endif

#include "SimData.h"

class simdataT {
public:
  union {
    int integer;
    double real;
  } indepdata;
  union {
    int integer;
    struct {
      double real;
      double imag;
    } cmplx;
    double real;
  } depdata;
  simdataT& operator()( const int& x ) { indepdata.integer = x; return *this; }
  simdataT& operator()( const double& x ) { indepdata.real = x; return *this; }
  simdataT& operator=( const int& y ) { depdata.integer = y; return *this; }
  simdataT& operator=( const double& y ) { depdata.real = y; return *this; }
  simdataT& operator=( const Complex& y ) { 
    depdata.cmplx.real = y.real(); depdata.cmplx.imag = y.imag(); return *this; 
  }
  simdataT& operator=( simdataT& s ) { 
    depdata = s.depdata;
    indepdata = s.indepdata;
    return *this; 
  }
};

class PtData: public SimData {

public:

  // Constructor
  PtData( Block *starP );

  // Destructor
  ~PtData();

  simdataT* getData() { return simdata; }
  int getSize() { return datasize; }

  // send data
  void sendData( const int& x, const int& y );
  void sendData( const int& x, const double& y );
  void sendData( const int& x, const Complex& y );
  void sendData( const double& x, const int& y );
  void sendData( const double& x, const double& y );
  void sendData( const double& x, const Complex& y );

  // busses and matrices will not be supported for PtData but the functions 
  // must be defined since the base class defines them as pure virtual
  void sendData( const int& x, const int *y, const int& length ) { }
  void sendData( const int& x, const double *y, const int& length ) { }
  void sendData( const int& x, const Complex *y, const int& length ) { }

  void initialize();
  char *getAlias();
  void cleanUp() { };

private:
  simdataT * simdata;
  int datasize, databufsize;
};

#endif  // PTOLEMYDATA_H_INCLUDED
