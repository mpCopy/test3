#ifndef VECTOR_H_INCLUDED
#define VECTOR_H_INCLUDED
// Copyright  1998 - 2017 Keysight Technologies, Inc 

// @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/sp-modelbuilder/examples/message/Vector.h,v $ $Revision: 100.12 $ $Date: 2011/08/29 15:41:51 $

// Not required, unless compiling under g++.  These directives will
// not effect other compilers.
#ifdef __GNUG__
#pragma interface
#endif

#include "Message.h"
#include "ads_vectorDll.h"

/* Data type of the new message type.  This variable name must be in
   all capital letters and placed in the ADSPtolemy namespace.
   The ptlang preprocessor will convert the port type field into all 
   capital letters.*/

namespace ADSPtolemy {
  DllImport extern const ADSPtolemy::DataType VECTOR;
}

// A vector of doubles. Example of a user defined data type in ADS
// Ptolemy.

class Vector:public Message {
public:
  // Default Constructor
  Vector();

  // Copy Constructor
  Vector(const Vector&);

  // Destructor
  ~Vector();

  // Return the data type of the Message
  ADSPtolemy::DataType type() const {
    return ADSPtolemy::VECTOR;
  }
  
  // Dynamically allocate a Vector identical to this one
  Message* clone() const {
    Vector* newMessage = new Vector(*this);
    return newMessage;
  }
  
  // Output the data structure as a string
  StringList print() const;


  /********* Optional Type Conversion to Scalar ********/

  // Return the Norm as float
  operator int() const { return (int)norm(); }

  // Return the Norm as float
  operator Fix() const { return norm(); }

  // Return the Norm as float
  operator float() const { return float(norm()); }

  // Return the Norm as double
  operator double() const { return norm(); }

  // Return the Norm as Complex
  operator Complex() const { return norm(); }

  /********* Optional support for initializable delays  ********/
  // Parse the init delay string
  void operator << (const StringState&);

  // Pass through methods for the other operators, otherwise c++
  // will hide the following methods
  
  //
  void operator << (int i) { ((Message&) *this) << i; }
  //
  void operator << (double i) { ((Message&) *this) << i; }
  //
  void operator << (const Complex& i) { ((Message&) *this) << i; }
  //
  void operator << (const Fix& i) { ((Message&) *this) << i; }

  /********** Vector methods ***********/ 
  // Return the Norm
  double norm() const; 
  
  // Access a member of the vector
  inline double& operator[] (int i) {
    return vector[i];
  }

  // Access a member of the vector, const version
  inline const double& operator[] (int i) const {
    return vector[i];
  }

  // Resize the vector to a given length
  inline void resize(int i) {
    delete [] vector;
    if (i>0) {
      vector = new double[i];
      sz = i;
    }
    else {
      vector = NULL;
      sz = 0;
    }
  }

  // Return the size of this vector
  inline int size() const { return sz; } 

private:
  // Vector data members
  
  // Array containing the data
  double *vector;

  // The size of the array
  int sz;
};

#endif /*VECTOR_H_INCLUDED*/
