/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/PtMatrixHelper.h,v $ $Revision: 100.7 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef PTMATRIXHELPER_H_INCLUDED
#define PTMATRIXHELPER_H_INCLUDED
// Copyright Keysight Technologies 1997 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include "type.h"
#include "HPtolemyMatrix.h"



class PortHole;
class Message;
class Envelope;

/** Helper class for Message constants.  This class enables constant
    messages to be declared once in the begin method and reused many
    times in the Star::go method.

    The memory for the message that is used as an argument to both the
    constructor and operator= will be managed by the Envelope class.
    The Message is assumed to be allocated using the new C++ operator.

    An example of this class use are the Matrix source stars.

    @see Star::go
    @see Envelope
    @author Jose Luis Pino*/
class MessageConstant {
public:
  /// Constructors
  //@{
  ///
  MessageConstant(Message*);
  ///
  MessageConstant();
  //@}

  /// Destructor
  ~MessageConstant();

  /// Set the constant message.
  MessageConstant& operator = (Message&);

  /// Return a pointer to the constant message
  inline Message* message() { return msg; }

private:
  Envelope* envelope;
  Message* msg;
};
    

/** Helper class for PtMatrix flowing through multirate AnyType ports.
    
    @author Jose Luis Pino*/
class PtMatrixHelper {
public:
  /// Constructor
  PtMatrixHelper() { myMatrix=NULL; messageConstant = NULL; }

  /// Destructor
  ~PtMatrixHelper();
  
  /** Delete the PtMatrixHelper matrix.  This should always be called
      in the begin method to ensure a new matrix is constructed if the
      matrix size has changed from one run to the next.*/
  void reset(PortHole& port);
   
  /** Return TRUE if port has been resolved to be a MATRIX. */
  inline int isMatrixPort() {
    return myMatrix!=NULL;
  }

  /** Return the filled matrix associated to a give port.  If
      necessary, construct a new matrix associated to a port with the
      same size as port%0.*/
  inline PtMatrix* matrix(PortHole& port, double fill=0) {
    if ((myMatrix!=NULL) && (myMatrix->numRows() == 0))
      initialize(port,fill);
    return myMatrix;
  }

private:
  void initialize(PortHole&,double);
  MessageConstant* messageConstant;
  PtMatrix* myMatrix;
};

#endif   /* PTMATRIXHELPER_H_INCLUDED */
