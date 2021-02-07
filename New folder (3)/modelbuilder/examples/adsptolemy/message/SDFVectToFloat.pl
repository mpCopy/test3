typeconversion {
  name { VectToFloat }
  domain { SDF }
  location { Vector }
 copyright { Copyright  1998 - 2017 Keysight Technologies, Inc   }
  desc { Output norm of input vector. }
  explanation {
    An example of a message to scalar type conversion.

    This star outputs the norm of the input vector.  Note that this
    star is logged in as a type conversion star by the use of the
    'typeconversion' ptlang keyword above.  

    This type conversion star is not compiled into the Vector example
    because the Vector message class directly supports float type
    conversion.  See the Vector.cc file.
  }
  version { @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/sp-modelbuilder/examples/message/SDFVectToFloat.pl,v $ $Revision: 100.6 $ $Date: 2011/08/28 20:27:29 $ }
  input {
    name { input }
    type { vector }
  }
  output {
    name { output }
    type { float }
  }
  ccinclude { "Vector.h" }
  go {
    // Get a reference to the input message using an envelope
    Envelope envelope;
    (input%0).getMessage(envelope);
    const Vector* vector = (const Vector*) envelope.myData();

    // Compute the norm, note the const form of the Vector [] operator
    // is used here
    int i;
    double normOfVector = 0;
    for (i=0; i<vector->size(); i++)
      normOfVector += (*vector)[i]*(*vector)[i];
    normOfVector = sqrt(normOfVector);

    // Output the norm of the vector to the output.
    output%0 << normOfVector;
  }
}
