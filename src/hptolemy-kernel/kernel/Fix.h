/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Fix.h,v $ $Revision: 100.34 $ $Date: 2011/08/25 01:47:10 $ */


#ifndef FIX_H_INCLUDED
#define FIX_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  



/**************************************************************************
UCB Version identification: Fix.h	1.13	3/15/96

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

 Programmer:  A. Khazeni, J. Buck, Victor Soon

This header file declares the class type Fix and its supporting 
functions. 


**************************************************************************/

#ifdef __GNUG__
#pragma interface
#endif

#include <iostream>
#include <iomanip>

class Precision;
typedef unsigned short uint16;

typedef unsigned char  uchar;

const int WORDS_PER_FIX = 16;
const int FIX_BITS_PER_WORD = 16;   // HP\_MODIFIED - changed from 4 to 16 for 256 bits. memory wasteage?
const int FIX_MAX_LENGTH = WORDS_PER_FIX * FIX_BITS_PER_WORD;

// HP\_MODIFIED - added this enum for arithType data member in Fix class
/// The type of fix - FIXME, shouldn't this be a member of Fix class?
enum arith_type 
{
 twos_comp = 0, 
 un_signed = 1
};

/** A fixed point precision number.

  Fix type variables allow users to specify the number of bits and
  position of the binary point for the fixed-point representation of
  the variable.  There are a number of ways to specify the precision:

  \begin{enumerate}

  \item a pair of integer arguments, specifying the length in bits and
  "intBits", the number of bits to the left of the binary point.  The
  sign bit counts as one of the intBits, so this number must be at
  least one.

  \item As a string like "3.2", or more generally "m.n", where m is
  intBits and n is the number to the right of the binary point.  Thus
  length is m+n.

  \item A string like "24/32" which means 24 fraction bits from a
  total length of 32.  This format is more convenient when using
  precision states, because the word length often remains constant
  while the number of fraction bits changes with the normalization
  being used.

  \end{enumerate}

  Arithmetic is done in such a way that operations like + do not
  overflow, as a rule, unless the result cannot be represented with
  all FIX\_MAX\_LENGTH bits left of the binary point.  Overflow occurs
  on assignment to a Fix that has its format set, if the new result
  cannot fit.

  The binary point must occur somewhere within the bits, or just to
  the right of it.

  By default, the effect of overflow is to saturate the result (use
  the largest or smallest representable number) and set the overflow
  flag.  Overflow flags are passed along by the arithmetic operations
  + - * and / to results, so you can keep track of whether any
  overflows have occured anywhere by checking only the final result.
  If either argument has overflow set, the result has it set as well.
  The ovf\_occurred() method gives access to the flag.  */
class Fix { 
public:
  /// Enumeration of overflow types
  enum overflowEnum { ovf_wrapped = 0,
	 ovf_saturate = 1,
	 ovf_zero_saturate = 2,
	 ovf_warning = 3,
	 ovf_n_types = 4
  };

  /// Enumeration of  error fields
  enum errorcode { err_ovf = 1, err_dbz = 2, err_invalid = 4 };

  /// Enumeration of truncation-rounding codes, for backward compatibility
  enum mask { mask_truncate = 0, mask_truncate_round = 1 };

  /// Return length in bits
  int len() const { return length; }

  /// Set the length for Bits
  void set_len(int value) { length = (uint16) value;}

  /// Return number of bits to LEFT of binary point
  int intb() const { return intBits; }

  /// Set number of bits to LEFT of binary point
  void set_intb(int value) { intBits = (uint16) value;}

  /// Return bits to RIGHT of binary point
  int fracb() const { return length - intBits;}

  /// Obsolete
  int precision() const { return fracb(); }

  /// Return overflow type (one of the codes above)
  int overflow() const { return ovf_type;}

  /// Set the overflow type
  void set_overflow(int value) { ovf_type = (uchar) value;}

  /// Set the rounding type: true for rounding, false for truncation
  void set_rounding(int value) { roundFlag = (value != 0);}

  /// Set the rounding type: synonym for backward compatibility
  void Set_MASK(int value) { set_rounding(value);}

  /// Return rounding mode (1 for rounding, 0 for truncation)
  int roundMode() const { return roundFlag;}

  /// HP MODIFIED: Set the arithmetic type: 1 for UNSIGNED, 0 for TWOS-COMPLEMENT
  void set_ArithType(int value) { arithType = (arith_type) value;}

  /// HP MODIFIED: Return the arithmetic type (1 for UNSIGNED, 0 for TWOS-COMPLEMENT
  int arithTypeMode() const { return arithType;}

  /** Return TRUE for negative and FALSE for positive.
    
    For TWOS\_COMP, return TRUE for negative, FALSE for +
    
    For UNSIGNED, return FALSE.

    HP\_MODIFIED: to handle TWOS\_COMP and UNSIGNED */
  inline int signBit() const { 
    if (arithType == twos_comp)
      return ( (Bits[0] & 0x8000) != 0);
    else      // HP\_MODIFIED: default as UNSIGNED
      return 0;
  }

  /// Return TRUE iff zero value
  int is_zero() const;

  /// Set to zero (equivalent to assigning zero)
  void setToZero();

  /// Max value representable in this format
  double maxlv() const;

  /// Min value representable in this format
  double minlv() const;

  /// Value as a double
  double value() const;

  /// Discard precision information and zero
  void initialize(arith_type arithType = twos_comp);

  /// Set overflow using a name
  void set_ovflow (const char*);

  /// Logical shift Bits by offset
  void shift_Bits(const int);

  /// Arithmetic shift Bits by offset
  void ashift_Bits(const int);

  /// Rotates Bits by offset
  void rot_Bits(const int);

  /// Mask out Bits[] to fit within the arg Fix length
  void mask_Bits(const Fix&);

  /// Concate the two Fixes (*this, x) into a "larger" bus returned in *this 
  void concat_Bits(const Fix&);

  /** Rip out a bus segment from x, situated lshift bits away
    from MSB of X.Bits[0] and return it in *this*/
  void rip_bus(const Fix&, const int);

  /// Set to 1s all the bits within x and return in this
  void setToOnes();

  /// Copy the length, intBits, arithType, rounding type, overflow, etc. of x into *this
  void copyAttrib(const Fix&);

  /// copy the uint16 array into Bits[] in this
  void copyIntoBits(const uint16 *, const int);

  /// copy the Bits in this out to a uint16 array
  void copyOutBits(uint16 *, const int);

  /// Return 0 if MSB is 0, else 1
  int msb();

  /// Return 0 if LSB is 0, else 1
  int lsb();

  /// If int arg is 0, then clear MSB, else set it to 1
  void put_msb( const int);

  /// If int arg is 0, then clear LSB, else set it to 1
  void put_lsb( const int);

  /**@name Constructors - HP\_MODIFIED - added arithType parameter to
    all constructors */
  //@{
  /// Create with unspecified precision
  Fix(arith_type aType = twos_comp);

  /// Create a Fix with specified precision and zero value.
  Fix(int length, int intbits, arith_type aType = twos_comp);

  /// 
  Fix(const char * precisionString, arith_type aType = twos_comp);

  /// 
  Fix(const Precision&, arith_type aType = twos_comp);

  /// Create a Fix with default precision
  Fix(double value, arith_type aType = twos_comp);

  /** Create a Fix from the double with specified precision -
    round to the nearest Fix.*/
  Fix(int length, int intbits, double value, arith_type aType = twos_comp);

  /// 
  Fix(const char * precisionString, double value, arith_type aType = twos_comp);

  /// 
  Fix(const Precision&, double value, arith_type aType = twos_comp);

  /** Create a Fix, specifying the bits precisely.  The first word of
    bits is the most significant.  From the "bits" argument:
    Fix("2.14", bits) will only reference bits[0], for example.  */
  Fix(const char * precisionString, uint16* bits, arith_type aType = twos_comp);

  /// Copy constructor: make exact duplicate.
  Fix(const Fix&);

  /// Copy value from Fix arg with new precision
  Fix(int length, int intbits, const Fix&);
  //@}

  /**@name Assignment operators */
  //@{
  /** Assignment operator from fix.  If *this does not have precision
    set, it is copied, otherwise value is converted from existing
    precision.*/
  Fix&          operator =  (const Fix&);

  /** Assignment from double.  HP\_MODIFIED - bug in original
    code. Changed code to call different constructors.*/
  inline Fix&          operator =  (double arg) {
    if (length == 0)
      return *this = Fix(arg);
    else
      return *this = Fix((int)(length), (int)(intBits), arg, arithType);
  }
  //@}

  /**@name Arithmetic operators */
  //@{
  /// 
  friend Fix    operator +  (const Fix&, const Fix&);
  /// 
  friend Fix    operator -  (const Fix&, const Fix&);
  /// 
  friend Fix    operator *  (const Fix&, const Fix&);
  /// 
  friend Fix    operator *  (const Fix&, int);
  /// 
  friend Fix    operator *  (int, const Fix&);
  /// 
  friend Fix    operator /  (const Fix&, const Fix&);

  /// unary minus
  friend Fix    operator - (const Fix&); 

  /// 
  Fix&          operator += (const Fix&);
  /// 
  Fix&          operator -= (const Fix&);
  /// 
  Fix&          operator *= (const Fix&);
  /// 
  Fix&          operator *= (int);
  /// 
  Fix&          operator /= (const Fix&);
  //@}

  /**@name Logic operators  */
  //@{
  /// 
  friend Fix    operator & (const Fix& x, const Fix& y);
  /// 
  friend Fix    operator | (const Fix& x, const Fix& y);
  /// 
  friend Fix    operator ^ (const Fix& x, const Fix& y);
  //@}

  /// Return -1 if a<b, 0 if a==b, 1 if a>b
  friend int compare (const Fix& a, const Fix& b);

  /**@name Access to errors */
  //@{
  /// 
  int     ovf_occurred() const { return (errors & err_ovf) != 0;}
  /// 
  int     invalid() const { return (errors & (err_dbz|err_invalid)) != 0;}
  /// 
  int     dbz() const { return (errors & err_dbz) != 0;}
  /// 
  void    clear_errors() { errors = 0; }
  //@}


  /**@name Other operators */
  //@{

  /// convert to integer, truncating towards zero.
  operator int () const;

  /// convert to float or double -- exact result where possible
  operator float () const { return float(value());}
  /// 
  operator double () const { return value();}
  //@}
  
  /// Debug-style printer
  friend void	    printFix(const Fix&);

  /// Replace arg by its negative
  void complement();

  /// Print on ostream in form (value, precision)
  friend std::ostream& operator<<(std::ostream&, const Fix&);

  /**@name Utility functions.  Obsolete. */
  //@{
  /// 
  static int  get_intBits(const char *p);
  /// 
  static int  get_length(const char *p);
  //@}

private:
  // Internal representation

  uint16 Bits[WORDS_PER_FIX];   // The bit pattern that stores the value 
  uint16  length;               // # of significant bits (HP\_MODIFIED - changed type to uint16)
  uint16  intBits;              // # of bits to the left of the binary point(HP\_MODIFIED-changed type to unint16)
  uchar  ovf_type;		  // fields specifying overflow type
  uchar  errors;		  // indicates whether overflow or errors have
  /// occurred in computing this value.
  uchar  roundFlag;		  // round on assignment if true
  arith_type  arithType;        // HP\_MODIFIED- type of number representation: 2's compliment, unsigned.

  // create bit pattern from the double value, using existing
  // length and intBits, rounding if round is nonzero.
  void makeBits(double value, int round, arith_type aType = twos_comp);

  // apply truncation or rounding.
  void applyMask(int round, arith_type at = twos_comp);

  // treat types of overflow
  void overflow_handler(int resultSign, int shift, arith_type at = twos_comp);

  // parse a precision argument.  Return TRUE if valid else FALSE.
  int setPrecision(const char* precision);

  /// Error if inBits<=0 for twos_comp and if intBits==0 for un_signed
  void  chk_intBits();

  // # of words in internal representation
  int words() const {
    return (length <= FIX_BITS_PER_WORD ? 1 :
	    (length + FIX_BITS_PER_WORD - 1) / FIX_BITS_PER_WORD);
  }
 
  // # words in internal representation, possibly including an extra
  // bit for use before rounding
  int wordsIncludingRound(int round) const {
    int lpr = length + round;
    return (lpr <= FIX_BITS_PER_WORD ? 1 :
	    (lpr + FIX_BITS_PER_WORD - 1) / FIX_BITS_PER_WORD);
  }

};

// comparision operators are in terms of compare.  compare checks all
// bits if the formats are the same, otherwise it converts to double,
// which only has 53 bits of precision on IEEE machines.

inline int operator == (const Fix& a, const Fix& b) {
  return compare(a, b) == 0;
}

//
inline int operator != (const Fix& a, const Fix& b) {
  return compare(a, b) != 0;
}

//
inline int operator < (const Fix& a, const Fix& b) {
  return compare(a, b) < 0;
}

//
inline int operator <= (const Fix& a, const Fix& b) {
  return compare(a, b) <= 0;
}

//
inline int operator > (const Fix& a, const Fix& b) {
  return compare(a, b) > 0;
}

//
inline int operator >= (const Fix& a, const Fix& b) {
  return compare(a, b) >= 0;
}
#endif   /* FIX_H_INCLUDED */
