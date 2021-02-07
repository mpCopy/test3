/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Attribute.h,v $ $Revision: 100.9 $ $Date: 2011/08/25 01:47:10 $ */


#ifndef ATTRIBUTE_H_INCLUDED
#define ATTRIBUTE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  



#ifndef _Attribute_h
#define _Attribute_h 1
/**************************************************************************
Version identification:
@(#)Attribute.h	2.8	3/2/95

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

 Programmer: J. T. Buck 
 Date of creation: 6/12/91
 Revisions:

 Attributes, for use in controlling bitmasks in States and PortHoles.

**************************************************************************/

#ifdef __GNUG__
#pragma interface
#endif

typedef unsigned long bitWord;

/** Attributes represent logical properties that an object may or may
  not have.  A parameter may or may not be settable by the user; an
  assembly-language buffer may be allocated in ROM or RAM, fast memory
  or slow memory, etc.

  The set of attributes of an object is stored in an entity called a
  bitWord.  At present, a bitWord is represented as an unsigned long,
  which restricts the number of distinct attributes to 32; this may be
  changed in future releases.

  An Attribute object represents a request to turn certain attributes
  of an object off, and to turn other attributes on.  As a rule,
  constants of class Attribute are used to represent attributes, and
  users have no need to know whether a given property is represented
  by a true or false bit in the bitWord.

  Although we would prefer to have a constructor for Attribute objects
  of the form

  {\tt Attribute(bitWord bitsOn, bitWord bitsOff);}

  it has turned out that doing so presents severe problems with order
  of construction, since a number of global Attribute objects are used
  and there is no simple, portable way of guaranteeing that these
  objects are constructed before any use.  As a result, the
  {\tt bitsOn} and {\tt bitsOff} members are public, but we forbid
  use of that fact except in one place: constant Attribute objects can
  be initialized by the C ``aggregate form'', as in the following
  example:

  {\tt \begin{verbatim}extern const Attribute P_HIDDEN = {PB_HIDDEN, 0};\end{verbatim}}

  The first word specified is the {\tt bitsOn} field, and the second
  word specified is the {\tt bitsOff} field.  Other than to initialize
  objects, we pretend that these data members are private.  */
struct Attribute {
  // these should be treated as private
  bitWord bitsOn;
  bitWord bitsOff;
public:
  /**@name Combining attributes */
  //@{
  /** Assert that both attributes must be satisfied.  This combination
    means that requirements of both attributes must be satisfied.
    Hence, it really should be called an ``and'' operation.  The name
    reflects what happens to the masks.*/
  Attribute& operator |= (const Attribute& a) {
    bitsOn |= a.bitsOn;
    bitsOff |= a.bitsOff;
    return *this;
  }

  /** Assert that either must be satisfied.  This combination means
    that requirements of either attribute must be satisfied.  Hence,
    it really should be called an ``or'' operation.  The name reflects
    what happens to the masks.*/
  Attribute& operator &= (const Attribute& a) {
    bitsOn &= a.bitsOn;
    bitsOff &= a.bitsOff;
    return *this;
  }
  //@}

  /** Evaluate an attribute given a default value.  Essentially, bits
    corresponding to bitsOn are turned on, and then bits corresponding
    to bitsOff are turned off. */
  bitWord eval(bitWord defaultVal) const {
    return (defaultVal | bitsOn) & ~bitsOff;
  }

  /** Apply the attribute backwards, reversing the roles of bitsOn and
    bitsOff in {\tt eval}.*/
  bitWord clearAttribs(bitWord defaultVal) const {
    return (defaultVal | bitsOff) & ~bitsOn;
  }

  /// Retrieve the bits on
  bitWord on() const { return bitsOn;}

  /// Retrieve the bits off
  bitWord off() const { return bitsOff;}
};

/** Assert that both attributes must be satisfied.  This combination
  means that requirements of both attributes must be satisfied.
  Hence, it really should be called an ``and'' operation.  The name
  reflects what happens to the masks.*/
inline Attribute operator | (const Attribute& a, const Attribute& b) {
  Attribute t = a;
  return t |= b;
}

/** Assert that either attribute must be satisfied. This combination
  means that requirements of either attribute must be satisfied.
  Hence, it really should be called an ``or'' operation.  The name
  reflects what happens to the masks.*/
inline Attribute operator & (const Attribute& a, const Attribute& b) {
  Attribute t = a;
  return t &= b;
}
#endif

#endif   /* ATTRIBUTE_H_INCLUDED */
