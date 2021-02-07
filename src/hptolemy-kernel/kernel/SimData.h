#ifndef SIMDATA_H_INCLUDED
#define SIMDATA_H_INCLUDED
// Copyright 2001 - 2014 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#include "ComplexSubset.h"
#include "StringList.h"
#include "State.h"
#include "dataType.h"
#include "miscFuncs.h"
#include "HashTable.h"

class Block;

class SimData {

public:

  // Constructor
  SimData( Block *starP );

  // Destructor
  virtual ~SimData();

  // set independent variable name, type, and unit
  // only INT and FLOAT are supported for type
  // only UNITLESS_UNIT, FREQUENCY_UNIT, and TIME_UNIT are supported for unit
  void setIndepVar( const char *name, ADSPtolemy::DataType type, State::unitsE unit );

  // set dependent variable name, type, and unit
  // only INT, FLOAT, and COMPLEX are supported for type
  // only UNITLESS_UNIT and VOLTAGE_UNIT are supported for unit
  void setDepVar( const char *name, ADSPtolemy::DataType type, State::unitsE unit );
  void setDepVar( const char *baseName, const char *suffix, ADSPtolemy::DataType type, State::unitsE unit );

  // functions to support busses and matrices
  void setBusSize( int n );
  void setMatrixDimensions( int r, int c );

  // set autoPlotType
  void setAutoPlotType( const int& type );

  // add attributes to the plot
  void addAttribute( const char *name, const int& value );
  void addAttribute( const char *name, const double& value );

  ADSPtolemy::DataType getDepType() { 
    return depVarType; 
  }

  ADSPtolemy::DataType getIndepType() { 
    return indepVarType; 
  }

  const char* getIndepName() { 
    return savestring(stateP->name()); 
  }

  // send data
  virtual void sendData( const int& x, const int& y )=0;
  virtual void sendData( const int& x, const double& y )=0;
  virtual void sendData( const int& x, const Complex& y )=0;
  virtual void sendData( const double& x, const int& y )=0;
  virtual void sendData( const double& x, const double& y )=0;
  virtual void sendData( const double& x, const Complex& y )=0;

  // functions to support busses and matrices; in the matrix case length 
  // must be set to ( rows x columns ) and y is a pointer to a one-dimensional 
  // array that stores the two-dimensional matrix elements row-wise.
  virtual void sendData( const int& x, const int *y, const int& length )=0;
  virtual void sendData( const int& x, const double *y, const int& length )=0;
  virtual void sendData( const int& x, const Complex *y, const int& length )=0;

  virtual void initialize()=0;
  virtual char *getAlias()=0;
  virtual void cleanUp()=0;

protected:
  State *stateP;
  Block *parentStarP;
  StringList depVarName;
  ADSPtolemy::DataType depVarType;
  ADSPtolemy::DataType indepVarType;
  State::unitsE depVarUnit;
  StringList attributes;
  int autoPlotType, initializeFlag, busFlag, matrixFlag;
  int busSize, rows, columns;   // to support busses and matrices
};

#endif  // SIMDATA_H_INCLUDED
