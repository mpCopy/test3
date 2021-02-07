/* 
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
*/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/ComplexSubset.h,v $ $Revision: 100.14 $ $Date: 2011/08/25 01:47:10 $ */
// A small complex class -- a subset of the cfront and libg++ versions,
// but written from scratch.
// @(#)ComplexSubset.h	1.8 3/2/95


#ifndef COMPLEXSUBSET_H_INCLUDED
#define COMPLEXSUBSET_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include <iostream>
#include "gui_math.h"

/** A complex number.  
  
  Class Complex is a simple subset of functions provided in the Gnu
  and AT&T complex classes.  The standard arithmetic operators are
  implemented, as are the assignment arithmetic operators {\tt +=},
  {\tt -=}, {\tt *=}, and {\tt /=}, and equality and inequality
  operators {\tt ==} and {\tt !=}.  There is also {\tt real()} and
  {\tt imag()} methods for accessing real and imaginary parts.

  It was originally written when libg++ was subject to the GPL.  The
  current licensing for libg++ does not prevent us from using it and
  still distributing Ptolemy the way we want, but having it makes
  ports to other compilers (e.g. cfront) easier.  */
class Complex {
private:
  /// 
  double r;
  /// 
  double i;
public:
  /// Return the real part
  double real() const { return r;}
  /// Return the imaginary part
  double imag() const { return i;}

  /**@name Constructors */
  //@{
  /// 
  Complex() : r(0.0), i(0.0) {}

  /// 
  Complex(double rp, double ip = 0.0) : r(rp), i(ip) {}

  /// Copy constructor
  Complex(const Complex& arg) : r(arg.r), i(arg.i) {}
  //@}

  /// Assignment operator
  Complex& operator = (const Complex& arg) {
    r = arg.r;
    i = arg.i;
    return *this;
  }

  /**@name Op-assign operators */
  //@{
  /// 
  Complex& operator += (const Complex& arg) {
    r += arg.r;
    i += arg.i;
    return *this;
  }

  /// 
  Complex& operator -= (const Complex& arg) {
    r -= arg.r;
    i -= arg.i;
    return *this;
  }

  /// 
  Complex& operator *= (const Complex& arg) {
    double nr = r * arg.r - i * arg.i;
    i = r * arg.i + i * arg.r;
    r = nr;
    return *this;
  }

  // this one is not inline: too big
  /// 
  Complex& operator /= (const Complex& arg);

  // special ones for double args
  /// 
  Complex& operator *= (double arg) {
    r *= arg;
    i *= arg;
    return *this;
  }

  /// 
  Complex& operator /= (double arg) {
    r /= arg;
    i /= arg;
    return *this;
  }
  //@}
};

/// Return TRUE if two complex numbers are not equal
inline int operator != (const Complex& x, const Complex& y) {
  return x.real() != y.real() || x.imag() != y.imag();
}

/// Return TRUE if two complex numbers are equal
inline int operator == (const Complex& x, const Complex& y) {
  return x.real() == y.real() && x.imag() == y.imag();
}

/// Add two complex numbers
inline Complex operator + (const Complex& x, const Complex& y) {
  return Complex(x.real()+y.real(),x.imag()+y.imag());
}

/// Subtract two complex numbers
inline Complex operator - (const Complex& x, const Complex& y) {
  return Complex(x.real()-y.real(),x.imag()-y.imag());
}

/// Negate a complex number
inline Complex operator - (const Complex& y) {
  return Complex(-y.real(),-y.imag());
}

/// Return the conjugate of a complex number
inline Complex conj (const Complex& x) {
  return Complex(x.real(),-x.imag());
}

/// Return the real part of a complex number
inline double real (const Complex& x) { return x.real();}

/// Return the imaginary part of a complex number
inline double imag (const Complex& x) { return x.imag();}

/// Multiply two complex numbers
inline Complex operator * (const Complex& x, const Complex& y) {
  return Complex(x.real()*y.real() - x.imag()*y.imag(), 
		 x.real()*y.imag() + x.imag()*y.real());
}

/// Multiply a double with a complex
inline Complex operator * (double x, const Complex& y) {
  return Complex(x*y.real(),x*y.imag());
}

/// Multiply a complex with a double
inline Complex operator * (const Complex& x, double y) {
  return y*x;
}

/// Divide a complex by a double
inline Complex operator / (const Complex& x, double y) {
  return Complex(x.real()/y, x.imag()/y);
}

/** Return the magnitude of a complex number. The expression:

  {\tt abs(z)*exp(Complex(0.,1.)*arg(z))}

  is in theory always equal to z.*/
inline double abs(const Complex& arg) {
  return hypot(arg.real(), arg.imag());
}

/** Return the angle between the X axis and the vector made by the
  argument.  The expression:

  {\tt abs(z)*exp(Complex(0.,1.)*arg(z))}

  is in theory always equal to z.*/
inline double arg(const Complex& x) {
  if ( ( x.real() == 0 ) && ( x.imag() == 0 ) )
    return 0.0;
  else
    return atan2(x.imag(), x.real());
}

/// Return the absolute value of a complex number squared
inline double norm(const Complex& arg) {
  return arg.real() * arg.real() + arg.imag() * arg.imag();
}

/// Divide two complex numbers
Complex operator / (const Complex&, const Complex&);

/// Return the sine of a complex number
Complex sin(const Complex&);

/// Return the cosine of a complex number
Complex cos(const Complex&);

/// Return the exponential of a complex number
Complex exp(const Complex&);

/// Return the log of a complex number
Complex log(const Complex&);

/// Return the square root of a complex number
Complex sqrt(const Complex&);

/// Return the exponent of a double base raised to a complex power
Complex pow(double base,const Complex& expon);

/// Return the exponent of a complex base raised to a complex power
Complex pow(const Complex& base, const Complex& expon);

/// Operator to print a complex onto a ostream
std::ostream& operator<<(std::ostream&, const Complex&);
#endif   /* COMPLEXSUBSET_H_INCLUDED */
