/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Fraction.h,v $ $Revision: 100.14 $ $Date: 2011/08/25 01:47:10 $ */


#ifndef FRACTION_H_INCLUDED
#define FRACTION_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  



#ifndef _Fraction_h
#define _Fraction_h 1

// SCCS version identification
// @(#)Fraction.h	1.20	4/24/95

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
 Programmer:  Edward A. Lee and J. Buck
 Date: 12/7/89

 This class represents fractions using integers for the myNum
 and myDen.

 Thoroughly rewritten by Joe Buck to be more efficient, implement
 assignment operators, and to work around some g++ bugs.

 Definitions of "gcd" and "lcm" are here too, since fraction code
 uses them.

 All operations keep the fraction relatively prime, with positive
 denominator.
*/
#ifdef __GNUG__
#pragma interface
#endif

#include <iostream>

/** Return the greatest common divisor.  The gcd function has the
  property that:

  {\tt gcd(0,n) = gcd(n,0) = n}*/
int gcd(int a,int b);

/** Return the least common multiple.  

  The order of the multiplication and division is chosen to avoid
  overflow in cases where a*b > MAXINT but lcm(a,b) < MAXINT.  The
  division always goes evenly.*/
inline int lcm(int a,int b) { return a == b ? a : a * (b / gcd(a,b));}

/** A fraction.  Class Fraction implements the basic binary math
  operators {\tt +}, {\tt -}, {\tt *}, {\tt /}; the assignment
  operators {\tt =}, {\tt +=}, {\tt -=}, {\tt *=}, and {\tt /=}, and
  the equality test operators {\tt ==} and {\tt !=}.*/
class Fraction {
public:
  /// Return the numerator
  int num() const {return myNum;}
  /// Return the denominator
  int den() const {return myDen;}

  /**@name Constructors */
  //@{
  /// 
  Fraction () : myNum(0), myDen(1) { }

  /// 
  Fraction (int i, int j=1) : myNum(i), myDen(j) {}

  /// 
  Fraction (const Fraction& a) : myNum(a.myNum), myDen(a.myDen) {}
  //@}

  /// 
  Fraction& operator= (const Fraction& a) {
    myNum = a.myNum;
    myDen = a.myDen;
    return *this;
  }

  /// 
  Fraction& operator= (int a) {
    myNum = a;
    myDen = 1;
    return *this;
  }

  /// Return the value of the fraction as a double
  operator double() const {
    return double(myNum)/double(myDen);
  }

  /// Return the value of the fraction rounded to the nearest integer
  operator int() const {
    return myDen == 1 ? myNum : myNum/myDen;
  }

  /**@name Assignment operators */
  //@{
  /// 
  Fraction& operator += (const Fraction& f);
  /// 
  Fraction& operator -= (const Fraction& f);

  /// 
  Fraction& operator *= (const Fraction& a) {
    myNum *= a.myNum;
    myDen *= a.myDen;
    return *this;
  }
  /// 
  Fraction& operator /= (const Fraction& a) {
    myNum *= a.myDen;
    myDen *= a.myNum;
    return *this;
  }
  //@}

  // binary operators that need friendship

  friend inline int operator == (const Fraction&,const Fraction&);
  //
  friend inline int operator != (const Fraction&,const Fraction&);
  //
  friend inline Fraction operator * (const Fraction&,const Fraction&);
  //
  friend inline Fraction operator / (const Fraction&,const Fraction&);

  /** Simplify the fraction. This is done by omputing an equivalent
    fraction with myNum and myDen relatively prime.  The simplified
    fraction replaces the original.*/
  Fraction& simplify();
private:
  /// 
  int myNum;
  /// 
  int myDen;
};

/// Print a Fraction on an ostream
std::ostream& operator<<(std::ostream&,const Fraction&);

// Notice: these functions don't have to be friends!
// Design based on Andrew Koenig's method -- the temporaries
// (res in the functions below) can almost always be optimized away

/// Add two fractions
inline Fraction operator+ (const Fraction& a,const Fraction& b) {
  /// 
  Fraction res(a);
  /// 
  res += b;
  /// 
  return res;
}

/// Subtract a fraction from another
inline Fraction operator- (const Fraction& a,const Fraction& b) {
  Fraction res(a);
  res -= b;
  return res;
}

/// Multiply two fractions
inline Fraction operator* (const Fraction& a,const Fraction& b) {
  return Fraction(a.myNum*b.myNum,a.myDen*b.myDen);
}

/// Divide two fractions
inline Fraction operator/ (const Fraction& a,const Fraction& b) {
  return Fraction(a.myNum*b.myDen,a.myDen*b.myNum);
}

/// Return TRUE if two fractions are equal (works for 2/3, 4/6)
inline int operator == (const Fraction& i, const Fraction& j)
{
  return i.myNum*j.myDen == i.myDen*j.myNum;
}

/// Return TRUE if two fractions are not equal
inline int operator != (const Fraction& i, const Fraction& j)
{
  return i.myNum*j.myDen != i.myDen*j.myNum;
}

#endif


#endif   /* FRACTION_H_INCLUDED */
