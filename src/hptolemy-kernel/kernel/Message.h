/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Message.h,v $ $Revision: 100.16 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef MESSAGE_H_INCLUDED
#define MESSAGE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#ifdef __GNUG__
#pragma interface
#endif
/**************************************************************************
Version identification:
@(#)Message.h	2.21	2/29/96

Copyright (c) 1990-1996 The Regents of the University of California.
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

 Programmer:  J. T. Buck
 Date of creation: 2/20/91

 This file defines the Envelope interface of Ptolemy.  A Envelope is
 an Message for passing objects of type Message around.  A
 MessageParticle is a type of Particle that transports Envelopes.

**************************************************************************/
#include "Particle.h"
#include "StringList.h"
#include "Fix.h"
#include "isa.h"
#include "ptolemyDll.h"


/// Message class DataType == MESSAGE
namespace ADSPtolemy {
HPTOLEMY_KERNEL_API extern const DataType MESSAGE;
}

/** A mechanism to transfering data between blocks.

    The heterogeneous message interface is a mechanism to permit
    messages of arbitrary type (objects of some derived type of class
    Message) to be transmitted by blocks.  Unlike Particles, which
    must all be of the same type on a given connection, connections
    that pass Message objects may mix message objects of many types on
    a given connection.  The tradeoff is that blocks that receive
    Message objects must, as a rule, type-check the received objects.

    Because these messages may be very large, facilities are provided
    to permit many references to the same Message; Message objects are
    ``held'' in another class called {\tt \Ref{Envelope}}.  As the
    name suggests, Messages are transferred in Envelopes.  When
    Envelopes are copied, both Envelopes refer to the same Message.  A
    Message will be deleted when the last reference to it disappears;
    this means that Messages must always be on the heap.

    So that Messages may be transmitted by portholes, there is a class
    MessageParticle whose data field is an Envelope.  This permits it
    to hold a Message just like any other Envelope object.
  
    Message objects have reference counts; at any time, the reference
    count equals the number of Envelope objects that contain (refer
    to) the Message object.  When the reference count drops to zero
    (because of execution of a destructor or assignment operator on an
    Envelope object), the Message will be deleted.

    The constructor for Message creates a reference count that lives
    on the heap.  This means that the reference count is non-const
    even when the Message object itself is const.

    @see \Ref{badType}, \Ref{RegisterMessage}*/
class Message {
  /// 
  friend class Envelope;
public:
  /// Constructors
  //@{
  /// Set reference count is zero
  Message() {
    refCount = new int; *refCount = 0;
  }

  /** Copy constructor.
      
      The copy constructor for Message ignores its argument and
      creates a new Message with a new reference count.  This is
      necessary so that no two messages will share the same reference
      count.*/
  Message(const Message&) {
    refCount = new int; *refCount = 0;
  }
  //@}

  /// Destructor - deletes the reference count
  virtual ~Message();

  /**@name Virtual message methods */
  //@{
  /**@name Optional methods to be redefine in a derived class */
  //@{
  /// Specify how to print the Envelope
  /** This method returns a printable representation of the Message.
      The default implementation returns a message like:
  
      {\tt Message class <type>: no print method}
  
      where {\tt type} is the message type as returned by the {\tt
      dataType} function.  */
  virtual StringList print() const;
  //@}

  /**@name Required methods to be redefine in a derived class */
  //@{
  /// Type of the Message, defaults to MESSAGE
  virtual ADSPtolemy::DataType type() const {
    return ADSPtolemy::MESSAGE;
  }

  /** This function produces a duplicate of the object it is called
      one must be ``good enough'' so that applications
      work the same way whether the original Message or one produced
      by {\tt clone()} is received.  A typical strategy is to define
      the copy constructor for each derived Message class and write
      something like:
    
      {\tt Message* clone() const { return new IntMatrix(*this); } }*/
  virtual Message* clone() const = 0;

  /** Returns TRUE if the argument is the string ``Message''.
  
      The {\tt isA} function returns true if given the name of the
      class or the name of any base class.
    
      A macro ISA\_FUNC is defined to automate the generation of
      implementations of derived class {\tt isA} functions; it is the
      same one as that used for the NamedObj class.  */
  virtual int isA(const char*) const;
  //@}
  //@}

  /**@name Virtual casting functions
  
     These functions represent conversions of the Message data to an
     integer, a floating point value, and a complex number,
     respectively.  Usually such conversions do not make sense;
     accordingly, the default implementations generate an error
     message (using the protected member function {\tt errorConvert})
     and return a zero of the appropriate type.  If a conversion does
     make sense, they may be overridden by a method that does the
     appropriate conversion.  These methods will be used by the
     MessageParticle class when an attempt is made to read a
     MessageParticle in a numeric context.  */
  //@{
  /// 
  virtual operator int () const;
  /// 
  virtual operator float () const;
  /// 
  virtual operator double () const;
  /// 
  virtual operator Complex () const;
  /// 
  virtual operator Fix () const;
  //@}

  /// 
  virtual void operator << (int);
  /// 
  virtual void operator << (double);
  /// 
  virtual void operator << (const Complex&);
  /// 
  virtual void operator << (const Fix&);

  /** To support initializable delays, redefine the following
    operator.  The method should parse the string and set the value of
    the message accordingly.  If there a state that can parse the
    string (see the Vector modelbuilder example), use the utility
    function Particle::parseStringWithState. */
  virtual void operator << (const StringState&);
  //@}

  /** Return FALSE.  Derived classes should redefine if initializable
      delays are required.
      
      @see \Ref{Particle::requiresInitDelay} */
  virtual int requiresInitDelay() const {
    return FALSE;
  }

protected:
  /** Invokes {\tt \Ref{Error::abortRun}} on conversion error. The
      message is of the form

      {\tt Message class <msgtype>: invalid conversion to cvttype}

      where {\tt msgtype} is the type of the Message, and {\tt
      cvttype} is the argument.  */
  void errorConvert(const char*) const;

private:
  // we use indirection for the reference count so it can be
  // manipulated even for a const Message object.
  int* refCount;
};

/**  A way of making a single {\tt \Ref{Message}} look like
  multiple objects*/
class Envelope {
  friend class MessageParticle;
private:
  /** Functions to manipulate the reference count.  These MUST be used
      properly.  They are first so they can be included by other
      inline functions and still be inlined correctly.*/
  //@{
  ///
  inline void incCount() const { 
    if (d) 
      (*d->refCount)++;
    else
      noDataAbortRun();
  }

  /// Returns the new count as its value
  inline int decCount() const {
    int count = 0;
    if (d)
      count = --(*d->refCount);
    else
      noDataAbortRun();
    return count;
  }
  //@}

public:
  /// Constructors
  //@{
  /** Construct an ``empty'' Envelope. In reality, the envelope is not
      empty but contains a special ``dummy message'' -- more on this
      later.*/
  Envelope() : d(NULL) {}

  /** Construct a envelope with that contains the Message {\tt data}.
      This data which MUST have been allocated with {\tt new}.*/
  Envelope(Message& dat) : d(&dat) {
    incCount();
  }

  /// Copy constructor
  Envelope(const Envelope& p) {
    d = p.d;
    incCount();
  }
  //@}

  /// Destructor
  ~Envelope();

  /** Assignment operator.  Adjusts reference counts; possibly deletes
      the old Message I pointed to.*/
  Envelope& operator=(const Envelope& p);

  /** Return TRUE if the Envelope is ``empty'' (points to the dummy
      message), FALSE otherwise.*/
  int empty() const { return (d == NULL);}

  /** Return TRUE this is a {\tt type} message.

      This member function asks the question ``is the contained
      Message of class {\tt type}, or derived from {\tt type}''?  It
      is implemented by calling {\tt isA} on the Message.  Either TRUE
      or FALSE is returned.*/
  inline int typeCheck(const char* type) const {
    return (d?d->isA(type):FALSE);
  }

  /** This member function may be used to format error messages for
      when one type of Message was expected and another was received.
      The return value points to a static buffer that is wiped out by
      subsequent calls.
      
      WARNING: the pointer points to a static buffer!*/
  const char* typeError(const char* expected) const;

  /// Return type() of enclosed particle or NULL_MESSAGE if no enclosed message
  inline ADSPtolemy::DataType type() const { 
    ADSPtolemy::DataType type = ADSPtolemy::MESSAGE;
    if (d) type = d->type();
    return type;
  }

  /// Print the message
  StringList print() const;

  /** Return a pointer to the contained Message.  This pointer must
      not be used to modify the Message object, since other Envelopes
      may refer to the same message.  */
  inline const Message* myData() const { return d;}

  /// Alias to myData() method
  inline operator const Message* () const { return myData(); }

  /** This method produces a writable copy of the contained Message,
      and also zeros the Envelope (sets it to the empty message).  If
      this Envelope is the only Envelope that refers to the message,
      the return value is simply the contained message.  If there are
      multiple references to the message, the {\tt clone} method is
      called on the Message, making a duplicate, and the duplicate is
      returned.

      The user is now responsible for memory management of the
      resulting Message.  If it is put into another Envelope, that
      Envelope will take over the responsibility, deleting the message
      when there is no more need for it.  If it is not put into
      another Envelope, the user must make sure it is deleted somehow,
      or else there will be a memory leak.*/
  Message* writableCopy();

  /** Print an error message if d is NULL. */
  void noDataAbortRun() const;
protected:
  /// Return the reference count of the Message.
  inline int refCount() const { 
    int count = 0;
    if (d)
      count = *d->refCount;
    else
      noDataAbortRun();
    return count;
  }
private:
  /// bookkeeping function to zap the Message when done
  void unlinkData() {
    if (!empty() && decCount() == 0) {
      INC_LOG_DEL; delete d;
    }
    d = NULL;
  }

  /// a pointer to my real data
  Message* d;

};

/** A Particle class to transmit \Ref{Message} particles.

  MessageParticle is a derived type of Particle (class
  \Ref{Particle}) whose data field is an Envelope; accordingly, it can
  transport Message objects.

  MessageParticle defines no new methods of its own; it only provides
  behaviors for the virtual functions defined in class Particle.*/
class MessageParticle : public Particle {
public:
  /// Constructors
  //@{
  /// 
  MessageParticle(const Envelope& p);
  /// 
  MessageParticle();
  //@}

  /// Destructor
  virtual ~MessageParticle() {};

  /// 
  operator int () const;
  /// 
  operator float () const;
  /// 
  operator double () const;
  /// 
  operator Complex () const;
  /// 
  operator Fix () const;
  /// 
  StringList print() const;

  /** Load the message contained in the MessageParticle into the
    Envelope {\tt env}, and removes the message from the
    MessageParticle (so that it now contains the dummy message).  If
    {\tt env} previously contained the only reference to some other
    Message, that previously contained Message will be deleted.  */
  void getMessage (Envelope& p);

  /** Access a message.

    {\tt accessMessage} is the same as {\tt getMessage} except that
    the message is not removed from the MessageParticle.  It can be
    used in situations where the same Particle will be read again.  We
    recommend that {\tt getMessage} be used where possible, especially
    for very large message objects, so that they are deleted as soon
    as possible.  */
  void accessMessage (Envelope& p) const;

  /// 
  Particle& initialize();

  /** These methods pass through to the Message methods, if Envelope
      empty call Error::abortRun.*/
  //@{
  ///
  void operator << (int i);
  /// 
  void operator << (double f);
  ///
  void operator << (const Complex& c);
  ///
  void operator << (const Fix& c);
  ///
  void operator << (const StringState&);
  //@}

  /** Load the Message contained in {\tt envelope} into the Envelope
      contained in the MessageParticle.  Since the Envelope assignment
      operator is used, after execution of this method both {\tt
      envelope } and the MessageParticle refer to the message, so its
      reference count is at least 2.  */
  void operator << (const Envelope& envelope);

  /// Load a Message
  void operator << (Message&);

  /// Return TRUE
  int isMessage() const { return TRUE; }

  /// particle copy
  Particle& operator = (const Particle& p);

  /// Compare particles, return TRUE only if Message addresses equal
  int operator == (const Particle&);

  ///
  Particle* clone() const;
  ///
  Particle* useNew() const;
  ///
  void die();
  ///
  ADSPtolemy::DataType type() const;

  /** Return TRUE if Envelope is empty and call Error::abortRun;*/
  inline int empty() const {
    int status=data.empty();
    if (status)
      data.noDataAbortRun();
    return status;
  }

  /// Only valid if the message is non-empty, calls writableCopy
  inline Message& message() {
    Message* m = data.writableCopy();
    Envelope e(*m);
    *this << e;
    return *m;
  }

protected:
  /// 
  void errorAssign(const char*) const;
  /// 
  Envelope data;

  /// Return TRUE if 
  /** Clear the data from the message. */
  inline void null() { data.unlinkData(); }
};

class NamedObj;

/** The {\tt badType} function returns TRUE if the given envelope
  contains the data type specified.  If the types do not match, it
  calls {\tt Error::abortRun}.

  The TYPE\_CHECK macro, tests a envelope for a given type.  It
  can be used from within the go method of a star.  This macro calls
  {\tt \Ref{badType}} to check and display error messages.  On an
  error, this macro returns from go.  Here is an example of it's use:

  TYPE\_CHECK(envelope,MATRIX);*/
int badType(NamedObj& n,Envelope& p,ADSPtolemy::DataType);

// Macro to test Message types
#define TYPE_CHECK(pkt,type) if (badType(*this,pkt,type)) return

/** A class used to register a Message in the known lists.  This
    enables HP Ptolemy type resolution, thus guaranteeing that ports
    of the same Message DataType are connected together.  It also
    enables the use of the automatic type conversion mechanisms in HP
    Ptolemy.

    To register a Message class, add the following lines of code to
    the C++ source defining the Message:
   
    \begin{verbatim}
    static <UserMessageClass> proto;
    static RegisterMessage registerMessage(proto);
    \end{verbatim}

    @see \Ref{Message::find} & \Ref{TypeConversion}*/
class RegisterMessage {
public:
  /// Constructor, adds static Message instance to the known lists
  RegisterMessage(Message& prototype);

  /// Find a Message for a give DataType, return NULL on error
  static const Message* find(ADSPtolemy::DataType);

private:
  HPTOLEMY_KERNEL_API static RegisterMessage* head;
  Message& proto;
  RegisterMessage* next;
};

#endif   /* MESSAGE_H_INCLUDED */
