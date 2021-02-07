defstar {
  name { Const_V }
  domain { SDF }
  location { Vector }
  desc { Output norm of input vector. }
 copyright { Copyright  1998 - 2017 Keysight Technologies, Inc   }
  explanation {
    An example of a constant message source.
  }
  version { @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/sp-modelbuilder/examples/message/SDFConst_V.pl,v $ $Revision: 100.3 $ $Date: 2011/08/28 20:27:28 $ }
  output {
    name { output }
    type { vector }
  }
  state {
    name { ConstantVector }
    type { floatarray }
    default { "1.1[10]" }
  }
  private {
    Envelope* constant;
  }
  constructor {
    // Set the pointer to the envelope to NULL so that the 
    // 'delete constant;' in the begin method will not fail.  Note, in
    // C++ 'delete NULL' is a valid, do nothing command.
    constant = NULL;
  }
  destructor {
    // Delete the envelope.
    delete constant;
  }
  ccinclude { "Vector.h" }
  begin {
    // The most efficient method to implement a constant message
    // source is to allocate and intialize the constant message only
    // once.  To do this, we allocate this message in the begin method
    // of this star.

    // Make sure that the user specified vector has a non-zero
    // length.  If it is zero in length, output an range error
    // message.  This range error message declares an error during the
    // intialization process.
    if (ConstantVector.size() == 0) {
      ConstantVector.rangeError(".size > 0");
    }

    // Construct a new vector.  Note, HP Ptolemy will
    // manage this memory once it is moved to an output. 
    Vector* vector = new Vector;
    vector->resize(ConstantVector.size());
    int i;
    for (i=0;i<ConstantVector.size(); i++)
      (*vector)[i] = ConstantVector[i];

    // Before constructing a new envelope, we have to delete any that
    // have been previously allocated.  An old evelope may exist if we
    // are doing sweeps or optimization.  On the very first invocation
    // of begin, constant will be equal to NULL.  Note, in C++ 'delete
    // NULL' is a valid, do nothing command.
    delete constant;

    // We must save the message in an envelope so that it will have at
    // least one reference to it.  Thus the message will not be
    // deleted until the contant envelope is deleted.  From now on, HP
    // Ptolemy will manage the memory allocated to vector.
    constant = new Envelope(*vector);
  }
  go {
    // Move a reference to the constant vector to the output port.
    output%0 << *constant;
  }
}
