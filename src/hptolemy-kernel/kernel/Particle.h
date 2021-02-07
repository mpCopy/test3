/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Particle.h,v $ $Revision: 100.14 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef PARTICLE_H_INCLUDED
#define PARTICLE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include "StringList.h"
#include "DataStruct.h"
#include "dataType.h"
#include "Fix.h"
#include "ComplexSubset.h"

class ComplexSubMatrix;
class FixSubMatrix;
class FloatSubMatrix;
class IntSubMatrix;
class ParticleStack;
class Plasma;
class Block;
class Envelope;
class Message;
class StringState;
class State;

/**************************************************************************
Version identification:
@(#)Particle.h	2.23	3/19/96

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

 Programmer:  E. A. Lee and D. G. Messerschmitt, J. Buck
 Date of creation: 1/17/90
 Revisions:

 Particles are the envelope that carry data between Stars
***************************************************************/

/** A little package that contains data.

    Particle is a little package that contains data; they represent
    the principal communication technique that blocks use to pass
    results around.  They move through PortHoles and Geodesics; they are
    allocated in pools called Plasmas.  The class Particle is an
    abstract base class; all real Particle objects are really of some
    derived type.
    
    All Particles contain a link field that allows queues and stacks of
    Particles to be manipulated efficiently (class ParticleStack is a
    base class for everything that does this).
    
    Particles also contain virtual operators for loading and accessing
    the data in various forms; these functions permit automatic type
    conversion to be easily performed.  
    
    {\bf Arithmetic Particle classes}

    There are three standard arithmetic Particle classes: IntParticle,
    FloatParticle, and ComplexParticle.  As their names suggest, each
    class adds to Particle a private data member of type int, double
    (not float!), and class Complex, respectively.
    
    When a casting operator or ``<<'' operator is used on a particle of
    one of these types, a type conversion may take place.  If the type
    of the argument of cast matches the type of the particle's data, the
    data is simply copied.  If the requested operation involves a
    ``widening'' conversion (int to float, double, or Complex; float to
    double or Complex; double to Complex), the ``obvious'' thing
    happens.  Conversion from double to int rounds to the nearest
    integer; conversion from Complex to double returns the absolute
    value (not the real part!), and Complex to int returns the absolute
    value, rounded to the nearest integer.

    {\tt initialize} for each of these classes sets the data value to
    zero (for the appropriate domain).

    The DataTypes returned by these Particle types are the global
    symbols INT, FLOAT, and COMPLEX, respectively.  They have the string
    values ``INT'', ``FLOAT'', and ``COMPLEX''.*/
class Particle {
public:
  /** Return the type of the particle.  DataType is actually just a
    typedef for {\tt const char*}, but when we use DataType, we treat
    it as an abstract type.  Furthermore, two DataType values are
    considered the same if they compare equal, which means that we
    must assure that the same string is always used to represent a
    given type.  */
  virtual ADSPtolemy::DataType type() const = 0;

  /**@name Virtual casting functions
    
    These are the virtual casting functions, which convert the data
    in the Particle into the desired form.  The arithmetic Particles
    support the first five cleanly.  Message particles may return
    errors for some of these functions (they must return a value, but
    may also call {\tt \Ref{Error::abortRun}}.*/
  //@{
  /// 
  virtual operator int () const = 0;
  /// 
  virtual operator float () const = 0;
  /// 
  virtual operator double () const = 0;
  /// 
  virtual operator Complex () const = 0;
  /// 
  virtual operator Fix () const =  0;
  /// 
  virtual operator ComplexSubMatrix* () const;
  /// 
  virtual operator FixSubMatrix* () const;  
  /// 
  virtual operator FloatSubMatrix* () const;
  /// 
  virtual operator IntSubMatrix* () const; 
  //@}

  /// Return a printable representation of the Particle's data
  virtual StringList print () const = 0;

  /** This function zeros the Particle (where this makes sense), or
    initializes it to some default value.  */
 virtual Particle& initialize() = 0;

  /**@name Loading operators

     These functions are, in a sense, the inverses of the virtual
     casting operators.  They load the particle with data from {\tt
     arg}, performing the appropriate type conversion.  */
  //@{
  /// 
  virtual void operator << (int) = 0;
  /// 
  virtual void operator << (double) = 0;
  /// 
  virtual void operator << (const Complex&) = 0;
  /// 
  virtual void operator << (const Fix&) = 0;

  /** Required to support initializable delays.
      
      @see \Ref{Particle::parseStringWithState} and  \Ref{Particle::requiresInitDelay}
      */
  virtual void operator << (const StringState&) = 0;
  //@}

  /** Copy a Particle.  As a rule, we permit this only for Particles
    of the same type, and otherwise assert an error.  */
  virtual Particle& operator = (const Particle&) = 0;

  /** Compare two particles.  As a rule, Particles will be equal only
    if they have the same type, and, in a sense that is separately
    determined for each type, the same value.  */
  virtual int operator == (const Particle&) = 0;

  /** Produce a second, identical particle.  As a rule, one is
    obtained from the Plasma for the particle if possible.  */
  virtual Particle* clone() const = 0;

  /** This is similar to {\tt clone}, except that the particle is
      allocated from the heap rather than from the Plasma.

    @see clone*/
  virtual Particle* useNew() const = 0;

  /// Return the Particle to its Plasma
  virtual void die() = 0;

  /**@name Message interface
  
    These functions are used to implement the Message interface.
    The default implementation returns errors for them; it is only if
    the Particle is really a MessageParticle that they successfully
    send or receive a Message from the Particle.*/
  //@{
  /// 
  virtual void getMessage (Envelope&);
  /// 
  virtual void accessMessage (Envelope&) const;
  /// 
  virtual void operator << (const Envelope&);
  /// 
  virtual void operator << (Message&);
  /// Return FALSE
  virtual int isMessage() const { return FALSE; }
  //@}

  /// Support for initializable delays
  //@{
  /** Return TRUE if this particle only supports initializable
      delays.  FALSE by default. */  
  virtual int requiresInitDelay() const {
    return FALSE;
  }

  /** Helper method for operator << (StringState&).  Given a
      StringState which contains an initialValue, initialize another
      state.  For example, you could parse a StringState containing a
      integer, with an IntState.

      Here is the definition for the IntParticle:
      \begin{verbatim}
      int IntParticle::operator << (const StringState& initValue) {
        IntState state;
        parseStringWithState(initValue,state);
        (*this) << state;
      }
      \end{verbatim}

      Although it is not required to use this method to support
      initializable delays, it is encouraged.  It will lead to
      consistent error handling and parsing of global symbols.*/
  static void parseStringWithState(const StringState& initValue,
				   State& stateToInitialize);
  //@}

protected:
  /// Return TRUE if types are equal
  inline int typesEqual(const Particle& p) const {
    return (type() == p.type());
  }

  /** Return TRUE if paricles are of the same type.  Before copying
    Particles, always compare their types Otherwise the user could
    always copy Particles of incompatible types between an input and
    output PortHole.*/
  int compareType(const Particle& p) const;

  /// 
  Particle* link;

  friend class ParticleStack;
};

/***************************************************************
* Types of Particles
*
* Different Particle types carry different types of data
*
* To add a new Particle type, define one analogously to the ones
* below.
* PROBLEM:
* we still have built-in preferences for certain datatypes;
* you'd need to say something like
*
* myport%0 = StringParticle("hello") to use other types.
***************************************************************/


/// An integer particle, see \Ref{Particle} for full documentation
class IntParticle : public Particle
{
public:
  /// Return INT
  ADSPtolemy::DataType type() const;

  /**@name Casting functions */
  //@{
  /// 
  operator int () const;
  /// 
  operator double () const;
  /// 
  operator float () const;
  /// 
  operator Complex () const;
  /// 
  operator Fix () const;
  //@}

  /// 
  StringList print() const;

  /// 
  IntParticle(int i) { data = i;}
  /// 
  IntParticle() {data=0;}

  /// 
  Particle& initialize();

  /**@name Loading operators */
  //@{
  /// 
  void operator << (int i);
  /// 
  void operator << (double f);
  /// 
  void operator << (const Complex& c);
  /// 
  void operator << (const Fix& x);
  /// 
  void operator << (const StringState&);
  /// 
  void operator << (const Envelope& i) {
    ((Particle&)*this) << i;
  }
  /// 
  void operator << (Message& i) {
    ((Particle&)*this) << i;
  }
  //@}

  /// 
  Particle& operator = (const Particle&);

  /// 
  int operator == (const Particle&);

  /// 
  Particle* clone() const;
  /// 
  Particle* useNew() const;
  /// 
  void die();

private:
  /// 
  int data;
};


/// A double particle, see \Ref{Particle} for full documentation
class FloatParticle : public Particle
{
public:
  /// Return FLOAT
  ADSPtolemy::DataType type() const;
 
  /**@name Casting functions */
  //@{
  /// 
  operator int () const;
  /// 
  operator double () const;
  /// 
  operator float () const;
  /// 
  operator Complex () const;
  /// 
  operator Fix () const;
  //@}

  /// 
  StringList print() const;
 
  /// 
  FloatParticle(double f) {data=f;}
  /// 
  FloatParticle() {data=0.0;}
 
  /// 
  Particle& initialize();
 
  /**@name Loading operators */
  //@{
  /// 
  void operator << (int i);
  /// 
  void operator << (double f);
  /// 
  void operator << (const Complex& c);
  /// 
  void operator << (const Fix& x);
  /// 
  void operator << (const StringState&);
  /// 
  void operator << (const Envelope& i) {
    ((Particle&)*this) << i;
  }
  /// 
  void operator << (Message& i) {
    ((Particle&)*this) << i;
  }
  //@}

  /// 
  Particle& operator = (const Particle&);

  /// 
  int operator == (const Particle&);

  /// 
  Particle* clone() const;
  /// 
  Particle* useNew() const;
  /// 
  void die();

private:
  /// 
  double data;
};

/// A complex particle, see \Ref{Particle} for full documentation
class ComplexParticle : public Particle
{
public:
  /// Return COMPLEX
  ADSPtolemy::DataType type() const;
 
  /**@name Casting functions */
  //@{
  /// 
  operator int () const;
  /// 
  operator double () const;
  /// 
  operator float () const;
  /// 
  operator Complex () const;
  /// 
  operator Fix () const;
  //@}

  /// 
  StringList print() const;
 
  /// 
  ComplexParticle(const Complex& c) : data(c) {}
  /// 
  ComplexParticle(double f);
  /// 
  ComplexParticle(int i);
  /// 
  ComplexParticle();

  /// 
  Particle& initialize();

  /**@name Loading operators */
  //@{
  /// 
  void operator << (int i);
  /// 
  void operator << (double f);
  /// 
  void operator << (const Complex& c);
  /// 
  void operator << (const Fix& x);
  /// 
  void operator << (const StringState&);
  /// 
  void operator << (const Envelope& i) {
    ((Particle&)*this) << i;
  }
  /// 
  void operator << (Message& i) {
    ((Particle&)*this) << i;
  }
  //@}

  /// 
  Particle& operator = (const Particle&);

  /// 
  int operator == (const Particle&);

  /// 
  Particle* clone() const;
  /// 
  Particle* useNew() const;
  /// 
  void die();

protected:
  /// 
  Complex data;
};

/// A fix particle, see \Ref{Particle} for full documentation
class FixParticle : public Particle
{
public:
  /// Return FIX
  ADSPtolemy::DataType type() const;

  /**@name Casting functions */
  //@{
  /// 
  operator int () const;
  /// 
  operator double () const;
  /// 
  operator float () const;
  /// 
  operator Complex () const;
  /// 
  operator Fix () const;
  //@}

  /// 
  StringList print() const;

  /// 
  FixParticle();
  /// 
  FixParticle(int len, int intBits);
  /// 
  FixParticle(double& d);
  /// 
  FixParticle(int len, int intBits, double& d);
  /// 
  FixParticle(FixParticle& x);
  /// 
  FixParticle(int len, int intBits, FixParticle& x);

  /// 
  Particle& initialize();

  /**@name Loading operators */
  //@{
  /// 
  void operator << (int i);
  /// 
  void operator << (double f);
  /// 
  void operator << (const Complex& c);
  /// 
  void operator << (const Fix& x);
  /// 
  void operator << (const StringState&);
  /// 
  void operator << (const Envelope& i) {
    ((Particle&)*this) << i;
  }
  /// 
  void operator << (Message& i) {
    ((Particle&)*this) << i;
  }
  //@}

  /// 
  Particle& operator = (const Particle&);

  /// 
  int operator == (const Particle&);

  /// 
  Particle* clone() const;
  /// 
  Particle* useNew() const;
  /// 
  void die();

private:
  /// 
  Fix data;
};

// inline functions to handle other types correctly

inline void operator << (Particle& p, float d) { p << double(d);}
#endif   /* PARTICLE_H_INCLUDED */
