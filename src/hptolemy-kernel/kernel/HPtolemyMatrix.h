/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/HPtolemyMatrix.h,v $ $Revision: 100.20 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef HPTOLEMYMATRIX_H_INCLUDED
#define HPTOLEMYMATRIX_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#ifdef __GNUG__
#pragma interface
#endif
/**************************************************************************
Version identification:
Matrix.h	1.15	4/1/96

Copyright (c) 1990-1995 The Regents of the University of California.
All rights reserved.

Permission is hereby granted, without written agreement and without
license or royalty fees, to use, copy, modify, and distribute this
software and its documentation for any purpose, provided that the
above copyright notice and the following two paragraphs appear in all
copies of this software.

IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.

						PT_COPYRIGHT_VERSION_2
						COPYRIGHTENDKEY

 Programmer:  Mike J. Chen
 Date of creation: 9/27/93

 This file defines the implementation of the Matrix Message classes and
 the Matrix Envelope classes that hold them.  Matrices store data in
 a one dimensional array, in row major form (ie. first row, then second
 row, etc).

**************************************************************************/
#include "Message.h"
#include "ComplexSubset.h"
#include "Fix.h"
#include "Message.h"
#include "StringState.h"
#include "ptolemyDll.h"

namespace ADSPtolemy {
HPTOLEMY_KERNEL_API extern const DataType COMPLEX_MATRIX;
HPTOLEMY_KERNEL_API extern const DataType FIX_MATRIX;
HPTOLEMY_KERNEL_API extern const DataType FLOAT_MATRIX;
HPTOLEMY_KERNEL_API extern const DataType INT_MATRIX;
}

class ComplexArrayState;
class FixArrayState;
class FloatArrayState;
class IntArrayState;
class PortHole;
class StringState;
class ComplexMatrix;
class FixMatrix;
class FloatMatrix;
class IntMatrix;
class Galaxy;
class ArrayState;

/// Common base for derived Matrix Message classes
class PtMatrix : public Message {
  friend class SubMatrix;
public:
  /// Constructor: makes an un-initialized matrix with no data
  PtMatrix();

  /// Return the number of columns
  int numCols() const { return nCols; }

  /// Return the number of rows
  int numRows() const { return nRows; }

  /// Return the total data size
  int dataSize() const {return totalDataSize;}
  /// Set this matrix equal to another
  virtual PtMatrix& operator = (const PtMatrix &) = 0;

  /// Return TRUE if this matrix is equal to another
  virtual int operator == (const PtMatrix &) const = 0;

  /// Return TRUE if this matrix is not equal to another
  virtual int operator != (const PtMatrix &) const = 0;

  /** Return TRUE if the type of this matrix is equal to that
    of the argument. */
  int typesEqual(const PtMatrix& m) const {
    return (type() == m.type());
  }

  /** Return TRUE if the type of this matrix is equal to that
    of the argument.  If unequal, calls Error::abortRun. */ 
  int compareType(const PtMatrix& m) const;

  /// Return a StringList describing the matrix
  StringList print() const;

protected:
  /// Number of elements
  int totalDataSize;  

  /// Number of rows
  int nRows;

  /// Number of columns
  int nCols;

  ///
  virtual StringList printElement(int row,int column) const = 0;
};

/// A complex matrix message class
class ComplexMatrix: public PtMatrix {
public:
  /// Return data entry
  virtual Complex& entry(int element) const { return data[element]; }

  /// Return COMPLEX_MATRIX
  ADSPtolemy::DataType type() const { return ADSPtolemy::COMPLEX_MATRIX; }

  /// Return TRUE if the argument is a ComplexMatrix
  int isA(const char* typ) const {
    if(strcmp(typ,"ComplexMatrix") == 0) return TRUE;
    else return Message::isA(typ);
  }

  /// Constructor: makes an un-initialized matrix with no data
  ComplexMatrix();

  /// Constructor: makes an un-initialized matrix with the given dimensions
  ComplexMatrix(int numRow, int numCol);

  /** Constructor: initialized with the data given in the Particles of
    the PortHole */
  ComplexMatrix(int numRow, int numCol, PortHole& ph);

  /** Constructor: Initialized with the data given in a data
    ComplexArrayState*/
  ComplexMatrix(int numRow, int numCol, ComplexArrayState& dataArray);

  /// Copy constructor
  ComplexMatrix(const ComplexMatrix& src);

  /** Copy submatrix constructor.

    Copy constructor, copies only a submatrix of the original, as
    specified by the starting row and col, and the number of rows and
    cols of the submatrix.  Result is undefined if the dimensions of the
    submatrix go beyond the dimensions of the original matrix.
    */
  ComplexMatrix(const ComplexMatrix&, int sRow, int sCol, int nRow, int nCol);

  /// Copy
  Message* clone() const { LOG_NEW; return new ComplexMatrix(*this); }
 
  /// Return a given row
  virtual Complex* operator [] (int row) { return &data[row*nCols]; }

  /// Return a given row, const version
  virtual const Complex* operator[] (int row) const {return &data[row*nCols]; }

  /// Return TRUE if this matrix is equal to another
  virtual int operator == (const PtMatrix& src) const;

  /// Return TRUE if this matrix is not equal to another
  virtual int operator != (const PtMatrix& src) const {return !(*this == src); }

  /// Convert to a FixMatrix
  operator FixMatrix () const;

  /// Convert to a FloatMatrix
  operator FloatMatrix () const;

  /// Convert to a IntMatrix
  operator IntMatrix () const;

  /**@name Destructive replacement operators */
  //@{
  /**@name Assignment */
  //@{
  /// 
  PtMatrix& operator = (const PtMatrix& src);
  /// 
  ComplexMatrix& operator = (const ComplexMatrix& src);
  /// 
  ComplexMatrix& operator = (const Complex& value); 
  ///
  void operator << (const StringState&);
  /// 
  void operator << (int i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (double i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (const Complex& i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (const Fix& i) {
    ((Message&)*this) << i;
  }
  //@}
  /**@name Element wise operators */
  //@{
  /// 
  ComplexMatrix& operator += (const ComplexMatrix& src);
  /// 
  ComplexMatrix& operator += (const Complex& value);
  /// 
  ComplexMatrix& operator -= (const ComplexMatrix& src);
  /// 
  ComplexMatrix& operator -= (const Complex& value);
  /// 
  ComplexMatrix& operator *= (const ComplexMatrix& B);
  /// 
  ComplexMatrix& operator *= (const Complex& value);
  /// 
  ComplexMatrix& operator /= (const ComplexMatrix& src);
  /// 
  ComplexMatrix& operator /= (const Complex& value);
  //@}

  /// Make this an identity matrix
  ComplexMatrix& identity();  
  /// make this a diagonal matrix
  ComplexMatrix& diagonal(const Complex elem[]);   
  //@}

  /**@name Non-destructive operators, returns a new PtMatrix */
  //@{

  /**@name Prefix unary operators */
  //@{
  /// 
  ComplexMatrix operator- () const;
  /// 
  ComplexMatrix operator~ () const { return transpose(); }
  /// 
  ComplexMatrix operator! () const { return inverse(); }
  //@}

  /**@name Functions */
  //@{
  /// Raise the matrix to a power
  ComplexMatrix operator^ (int exponent) const;  // matrix to a power
  /// 
  ComplexMatrix transpose() const;
  /// Complex conjugate
  ComplexMatrix conjugate() const;       
  /// Conjugate transpose          
  ComplexMatrix hermitian() const;  
  /// 
  ComplexMatrix inverse() const;
  //@}
  //@}

  friend ComplexMatrix operator + (const ComplexMatrix&, const ComplexMatrix&);
  friend ComplexMatrix operator + (const Complex&, const ComplexMatrix&);
  friend ComplexMatrix operator + (const ComplexMatrix&, const Complex&);
  friend ComplexMatrix operator - (const ComplexMatrix&, const ComplexMatrix&);
  friend ComplexMatrix operator - (const Complex&, const ComplexMatrix&);
  friend ComplexMatrix operator - (const ComplexMatrix&, const Complex&);
  friend ComplexMatrix operator * (const ComplexMatrix&, const ComplexMatrix&);
  friend ComplexMatrix operator * (const Complex&, const ComplexMatrix&);
  friend ComplexMatrix operator * (const ComplexMatrix&, const Complex&);

  // faster ternary function, avoids extra copying step
  friend ComplexMatrix& multiply (const ComplexMatrix& left, 
                                  const ComplexMatrix& right,
                                  ComplexMatrix& result);

  /// Destructor
  ~ComplexMatrix();
protected:
  /// 
  Complex *data;       // made protected for SubMatrix class use

  ///
  StringList printElement(int row,int column) const;
};

/// FixMatrix Message Class
class FixMatrix: public PtMatrix {
public:
  /// return data entry
  virtual Fix& entry(int element) const { return data[element]; } 

  /// Return FIX_MATRIX
  ADSPtolemy::DataType type() const { return ADSPtolemy::FIX_MATRIX; }

  /// Return TRUE if the argument is a FixMatrix
  int isA(const char* typ) const {
    if(strcmp(typ,"FixMatrix") == 0) return TRUE;
    else return Message::isA(typ);
  }


  /**@name Constructors */
  //@{
  /// Construct an un-initialized matrix with no data
  FixMatrix();

  /** Construct an un-initialized matrix with the given dimensions
    using the default Fix precision as specified in the Fix class*/
  FixMatrix(int numRow, int numCol);

  /** Construct an un-initialized matrix with the given dimensions
    using Fix elements of the given length "ln" and integer bits
    "ib"*/
  FixMatrix(int numRow, int numCol, int ln, int ib);

  /** Construct an initialized matrix with the data given in the
    Particles of the PortHole using the default Fix precision as
    specified in the Fix class*/
  FixMatrix(int numRow, int numCol, PortHole& ph);

  /** Construct an initialized matrix with the data given in the
    Particles of the PortHole using Fix elements of the given length
    "ln" and integer bits "ib"*/
  FixMatrix(int numRow, int numCol, int ln, int ib, PortHole& ph);

  /** Construct an initialized matrix with the data given in a data
    FixArrayState using the default Fix precision as specified in the
    Fix class*/
  FixMatrix(int numRow, int numCol, FixArrayState& dataArray);

  /** Construct an initialized matrix with the data given in a data
    FixArrayState using Fix elements of the given length "ln" and
    integer bits "ib"*/
  FixMatrix(int numRow, int numCol, int ln, int ib, FixArrayState& dataArray);

  /**@name Copy constructors */
  //@{
  /// 
  FixMatrix(const FixMatrix& src);
  
  /**@name Special copy constructors with precision and masking */
  //@{
  /// 
  FixMatrix(const ComplexMatrix& src, int ln, int ib, int round);
  /// 
  FixMatrix(const FloatMatrix& src, int ln, int ib, int round);
  /// 
  FixMatrix(const IntMatrix& src, int ln, int ib, int round);

  /** Copies only a submatrix of the original, as specified by the
  starting row and col, and the number of rows and cols of the
  submatrix.  Result is undefined if the dimensions of the submatrix
  go beyond the dimensions of the original matrix.*/
  FixMatrix(const FixMatrix& src, int sRow, int sCol, int nRow, int nCol);

  //@}
  //@}
  //@}

  /// Clone
  Message* clone() const { LOG_NEW; return new FixMatrix(*this); }
 
  /**@name Operators  */
  //@{
  /// 
  virtual Fix* operator [] (int row) { return &data[row*nCols]; }
  /// 
  virtual const Fix* operator [] (int row) const { return &data[row*nCols]; }
  /// 
  virtual int operator == (const PtMatrix& src) const;
  /// 
  virtual int operator != (const PtMatrix& src) const {return !(*this == src); }
  //@}

  /**@name Cast conversion operators */
  //@{
  /// 
  operator ComplexMatrix () const;
  /// 
  operator FloatMatrix () const;
  /// 
  operator IntMatrix () const;
  //@}

  /**@name Destructive replacement operators */
  //@{
  /**@name Assignment */
  //@{
  /// 
  PtMatrix& operator = (const PtMatrix& src);
  /// 
  FixMatrix& operator = (const FixMatrix& src);
  /// 
  FixMatrix& operator = (const Fix& value);
  ///
  void operator << (const StringState&);
  /// 
  void operator << (int i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (double i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (const Complex& i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (const Fix& i) {
    ((Message&)*this) << i;
  }
  //@}
  /**@name Element wise operators */
  //@{
  /// 
  FixMatrix& operator += (const FixMatrix& src);
  /// 
  FixMatrix& operator += (const Fix& value);
  /// 
  FixMatrix& operator -= (const FixMatrix& src);
  /// 
  FixMatrix& operator -= (const Fix& value);
  /// 
  FixMatrix& operator *= (const FixMatrix& B); /// note: element-wise *
  FixMatrix& operator *= (const Fix& value);
  /// 
  FixMatrix& operator /= (const FixMatrix& src);
  /// 
  FixMatrix& operator /= (const Fix& value);
  //@}
  /// make this an identity matrix
  FixMatrix& identity();  
  /// make this a diagonal matrix
  FixMatrix& diagonal(const Fix elem[]);   
  //@}

  /**@name Non-destructive operators, returns a new PtMatrix */
  //@{

  /**@name Prefix unary operators */
  //@{
  /// 
  FixMatrix operator- () const ;
  /// 
  FixMatrix operator~ () const { return transpose(); }
  /// 
  FixMatrix operator! () const { return inverse(); }
  //@}

  /**@name Functions */
  //@{
  /// Raise the matrix to a power
  FixMatrix operator^ (int exponent) const;
  /// 
  FixMatrix transpose() const;
  FixMatrix inverse() const;  
  //@}
  //@}

  // binary operators
  friend FixMatrix operator + (const FixMatrix&, const FixMatrix&);
  friend FixMatrix operator + (const Fix&, const FixMatrix&);
  friend FixMatrix operator + (const FixMatrix&, const Fix&);
  friend FixMatrix operator - (const FixMatrix&, const FixMatrix&);
  friend FixMatrix operator - (const Fix&, const FixMatrix&);
  friend FixMatrix operator - (const FixMatrix&, const Fix&);
  friend FixMatrix operator * (const FixMatrix&, const FixMatrix&);
  friend FixMatrix operator * (const Fix&, const FixMatrix&);
  friend FixMatrix operator * (const FixMatrix&, const Fix&);
  // faster ternary function, avoids extra copying step
  friend FixMatrix& multiply (const FixMatrix& left, const FixMatrix& right,
                              FixMatrix& result);

  /// destructor
  ~FixMatrix();
protected:
  /// 
  Fix *data;             // made protected for SubMatrix class use
  ///
  StringList printElement(int row,int column) const;
};

/// FloatMatrix Message Class  
class FloatMatrix: public PtMatrix {
 public:
  /// Return data entry
  virtual double& entry(int element) const { return data[element]; } 

  /// Return FLOAT_MATRIX
  ADSPtolemy::DataType type() const { return ADSPtolemy::FLOAT_MATRIX; }

  /// Return TRUE if the argument is a FloatMatrix
  int isA(const char* typ) const {
    if(strcmp(typ,"FloatMatrix") == 0) return TRUE;
    else return Message::isA(typ);
  }

  /**@name Constructors */
  //@{
  /// Construct an un-initialized matrix with no data
  FloatMatrix();

  /// Construct an un-initialized matrix with the given dimensions
  FloatMatrix(int numRow, int numCol);

  /// initialized with the data given in the Particles of the PortHole
  FloatMatrix(int numRow, int numCol, PortHole& ph);

  /// Construct an initialized matrix with the data given in a data FloatArrayState
  FloatMatrix(int numRow, int numCol, FloatArrayState& dataArray);

  /// Copy constructor
  FloatMatrix(const FloatMatrix& src);

  /** Copies only a submatrix of the original, as specified by the
    starting row and col, and the number of rows and cols of the
    submatrix.  Result is undefined if the dimensions of the submatrix
    go beyond the dimensions of the original matrix.*/
  FloatMatrix(const FloatMatrix& src, int sRow, int sCol, int nRow, int nCol);
  //@}

  /// Clone  
  Message* clone() const { LOG_NEW; return new FloatMatrix(*this); }
 
  /**@name Operators  */
  //@{
  /// 
  virtual double* operator [] (int row) { return &data[row*nCols]; }
  /// 
  virtual const double* operator[] (int row) const { return &data[row*nCols]; }
  /// 
  virtual int operator == (const PtMatrix& src) const;
  /// 
  virtual int operator != (const PtMatrix& src) const {return !(*this == src); }
  //@}

  /**@name Cast conversion operators */
  //@{
  /// 
  operator ComplexMatrix () const;
  /// 
  operator FixMatrix () const;
  /// 
  operator IntMatrix () const;
  //@}

  /**@name Destructive replacement operators */
  //@{
  /**@name Assignment */
  //@{
  /// 
  PtMatrix& operator = (const PtMatrix& src);
  /// 
  FloatMatrix& operator = (const FloatMatrix& src);
  /// 
  FloatMatrix& operator = (double value);
  ///
  void operator << (const StringState&);
  /// 
  void operator << (int i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (double i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (const Complex& i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (const Fix& i) {
    ((Message&)*this) << i;
  }
  //@}
  /**@name Element wise operators */
  //@{
  /// 
  FloatMatrix& operator += (const FloatMatrix& src);
  /// 
  FloatMatrix& operator += (double value);
  /// 
  FloatMatrix& operator -= (const FloatMatrix& src);
  /// 
  FloatMatrix& operator -= (double value);
  /// 
  FloatMatrix& operator *= (const FloatMatrix& B); /// note: element-wise *
  FloatMatrix& operator *= (double value);
  /// 
  FloatMatrix& operator /= (const FloatMatrix& src);
  /// 
  FloatMatrix& operator /= (double value);
  //@}
  /// make this an identity matrix
  FloatMatrix& identity();
  ///
  /// make this a diagonal matrix
  FloatMatrix& diagonal(const double elem[]);    
  //@}

  /**@name Non-destructive operators, returns a new PtMatrix */
  //@{

  /**@name Prefix unary operators */
  //@{
  /// 
  FloatMatrix operator- () const;
  /// 
  FloatMatrix operator~ () const { return transpose(); }
  /// 
  FloatMatrix operator! () const { return inverse(); }
  //@}

  /**@name Functions */
  //@{
  /// Raise the matrix to a power
  FloatMatrix operator^ (int exponent) const;
  /// 
  FloatMatrix transpose() const; 
  /// 
  FloatMatrix inverse() const;    
  //@}
  //@}

  // binary operators
  friend FloatMatrix operator + (const FloatMatrix&, const FloatMatrix&);
  friend FloatMatrix operator + (double, const FloatMatrix&);
  friend FloatMatrix operator + (const FloatMatrix&, double);
  friend FloatMatrix operator - (const FloatMatrix&, const FloatMatrix&);
  friend FloatMatrix operator - (double, const FloatMatrix&);
  friend FloatMatrix operator - (const FloatMatrix&, double);
  friend FloatMatrix operator * (const FloatMatrix&, const FloatMatrix&);
  friend FloatMatrix operator * (double, const FloatMatrix&);
  friend FloatMatrix operator * (const FloatMatrix&, double);
     // faster ternary function, avoids extra copying step
  friend FloatMatrix& multiply (const FloatMatrix& left, 
                                const FloatMatrix& right, FloatMatrix& result);

  /// Destructor
  ~FloatMatrix();
 protected:
  /// 
  double *data;             // made protected for SubMatrix class use
  ///
  StringList printElement(int row,int column) const;
};


/// IntMatrix Message Class
class IntMatrix: public PtMatrix {
 public:
  /// Return data entry
  virtual int& entry(int element) const { return data[element]; } 

  /// Return INT_MATRIX
  ADSPtolemy::DataType type() const { return ADSPtolemy::INT_MATRIX; }

  /// Return TRUE if the argument is a IntMatrix
  int isA(const char* typ) const {
    if(strcmp(typ,"IntMatrix") == 0) return TRUE;
    else return Message::isA(typ);
  }

  /**@name Constructors */
  //@{
  /// Construct an un-initialized matrix with no data
  IntMatrix();

  /// Construct an un-initialized matrix with the given dimensions
  IntMatrix(int numRow, int numCol);

  /** Construct an initialized matrix with the data given in the
    Particles of the PortHole*/
  IntMatrix(int numRow, int numCol, PortHole& ph);

  /// Construct an initialized matrix with the data given in a data IntArrayState
  IntMatrix(int numRow, int numCol, IntArrayState& dataArray);

  /// Copy constructor
  IntMatrix(const IntMatrix& src);

  /** Copies only a submatrix of the original, as specified by the
    starting row and col, and the number of rows and cols of the
    submatrix.  Result is undefined if the dimensions of the submatrix
    go beyond the dimensions of the original matrix.*/
  IntMatrix(const IntMatrix& src, int sRow, int sCol, int nRow, int nCol);
  //@}

  /// Clone
  Message* clone() const { LOG_NEW; return new IntMatrix(*this); }
 
  /**@name Operators  */
  //@{
  /// 
  virtual int* operator [] (int row) { return &data[row*nCols]; }
  /// 
  virtual const int* operator [] (int row) const { return &data[row*nCols]; }
  /// 
  virtual int operator == (const PtMatrix& src) const;
  /// 
  virtual int operator != (const PtMatrix& src) const {return !(*this == src); }
  //@}

  /**@name Cast conversion operators */
  //@{
  /// 
  operator ComplexMatrix () const;
  /// 
  operator FixMatrix () const;
  /// 
  operator FloatMatrix () const;
  //@}

  /**@name Destructive replacement operators */
  //@{
  /**@name Assignment */
  //@{
  /// 
  PtMatrix& operator = (const PtMatrix& src);
  /// 
  IntMatrix& operator = (const IntMatrix& src);
  /// 
  IntMatrix& operator = (int value);
  ///
  void operator << (const StringState&);
  /// 
  void operator << (int i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (double i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (const Complex& i) {
    ((Message&)*this) << i;
  }
  /// 
  void operator << (const Fix& i) {
    ((Message&)*this) << i;
  }
  //@}
  /**@name Element wise operators */
  //@{
  /// 
  IntMatrix& operator += (const IntMatrix& src);
  /// 
  IntMatrix& operator += (int value);
  /// 
  IntMatrix& operator -= (const IntMatrix& src);
  /// 
  IntMatrix& operator -= (int value);
  /// 
  IntMatrix& operator *= (const IntMatrix& B); /// note: element-wise *
  IntMatrix& operator *= (int value);
  /// 
  IntMatrix& operator /= (const IntMatrix& src);
  /// 
  IntMatrix& operator /= (int value);
  //@}
  /// make this an identity matrix
  IntMatrix& identity();  
  ///
  /// make this a diagonal matrix
  IntMatrix& diagonal(const int a[]);  
  //@}


  /**@name Non-destructive operators, returns a new PtMatrix */
  //@{

  /**@name Prefix unary operators */
  //@{
  /// 
  IntMatrix operator- () const;
  /// 
  IntMatrix operator~ () const { return transpose(); }
  /// 
  IntMatrix operator! () const { return inverse(); }
  //@}

  /**@name Functions */
  //@{
  /// Raise the matrix to a power
  IntMatrix operator^ (int exponent) const; 
  /// 
  IntMatrix transpose() const;    
  /// 
  IntMatrix inverse() const;       
  //@}
  //@}

  // binary operators
  friend IntMatrix operator + (const IntMatrix&, const IntMatrix&);
  friend IntMatrix operator + (int, const IntMatrix&);
  friend IntMatrix operator + (const IntMatrix&, int);
  friend IntMatrix operator - (const IntMatrix&, const IntMatrix&);
  friend IntMatrix operator - (int, const IntMatrix&);
  friend IntMatrix operator - (const IntMatrix&, int);
  friend IntMatrix operator * (const IntMatrix&, const IntMatrix&);
  friend IntMatrix operator * (int, const IntMatrix&);
  friend IntMatrix operator * (const IntMatrix&, int);
     // faster ternary function, avoids extra copying step
  friend IntMatrix& multiply (const IntMatrix& left, const IntMatrix& right,
                              IntMatrix& result);

  /// Destructor
  ~IntMatrix();
 protected:
  /// 
  int *data;             // made protected for SubMatrix class use
  ///
  StringList printElement(int row,int column) const;
};
#endif   /* HPTOLEMYMATRIX_H_INCLUDED */
