// Copyright  1998 - 2017 Keysight Technologies, Inc  
// @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/sp-modelbuilder/examples/message/Vector.cc,v $ $Revision: 100.6 $ $Date: 2011/08/28 20:27:32 $

// Not required, unless compiling under g++.  These directives will
// not effect other compilers.
#ifdef __GNUG__
#pragma implementation
#endif

#include "FloatArrayState.h"
#include "Vector.h"
#include "TypeConversion.h"

namespace ADSPtolemy  {
  extern const DataType VECTOR =  "VECTOR";
}

/* The next two static declarations register the vector data type
   into HP Ptolemy.*/
static Vector proto;
static RegisterMessage pproto(proto);

/*******************************************************************/
/* IMPLEMENTATION SPECIFIC, REPLACE WITH THE CORRECT CODE FOR YOUR */
/* NEW MESSAGE TYPE.                                               */
/*******************************************************************/

// Default Constructor
Vector::Vector():Message() {
  sz=0;
  vector=0;
}

// Copy Constructor
Vector::Vector(const Vector& m):Message(m) {
  vector=0;
  resize(m.size());
  int i;
  for (i=0;i<size();i++)
    vector[i]=m.vector[i];
}

// Destructor
Vector::~Vector() { 
  delete [] vector;
}

// Output the data structure as a string, enables stars to output data
// structure to file (such as Printer)
StringList Vector::print() const {
  StringList out;
  out << "[";
  int i;
  for (i=0;i<size();i++)
    out << vector[i] << " ";
  out << "]";
  return out;
}

void Vector::operator<< (const StringState& initValue) {
  FloatArrayState state;
  // parse the initValue with a FloatArray parser
  Particle::parseStringWithState(initValue,state);
  //resize vector to match the FloatArray size
  resize(state.size());
  // copy the FloatArray to the vector
  for(int k = 0; k < state.size(); k++)
    vector[k] = state[k];
}

double Vector::norm() const {
  double normOfVector = 0;
  int i;
  for (i=0;i<size();i++)
    normOfVector += (*this)[i]*(*this)[i];
  normOfVector = sqrt(normOfVector);
  return normOfVector;
}

// Declare that from vector to scalar types 
static TypeConversion vectorToFloat(ADSPtolemy::VECTOR,ADSPtolemy::FLOAT,"HOF");
static TypeConversion vectorToFix(ADSPtolemy::VECTOR,ADSPtolemy::FIX,"HOF");
static TypeConversion vectorToInt(ADSPtolemy::VECTOR,ADSPtolemy::INT,"HOF");
static TypeConversion vectorToComplex(ADSPtolemy::VECTOR,ADSPtolemy::COMPLEX,"HOF");
