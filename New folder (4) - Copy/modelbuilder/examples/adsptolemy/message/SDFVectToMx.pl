typeconversion {
  name { VectToMx }
  domain { SDF }
  location { Vector }
 copyright { Copyright  1998 - 2017 Keysight Technologies, Inc   }
  desc { Convert a vector into a column matrix. }
  explanation {
    An example of a message to message type conversion.

    This star converts a vector into a column matrix.  Note that this
    star is logged in as a type conversion star by the use of the
    'typeconversion' ptlang keyword above.  Thus, if there is an arc
    with a 'vector' output tied to a 'float_matrix' input, HP Ptolemy
    will automatically insert this star.  
  }
  version { @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/sp-modelbuilder/examples/message/SDFVectToMx.pl,v $ $Revision: 100.5 $ $Date: 2011/08/28 20:27:31 $ }
  input {
    name { input }
    type { vector }
  }
  output {
    name { output }
    type { float_matrix }
  }
  ccinclude { "Vector.h" "HPtolemyMatrix.h" }
  go {
    // Get a reference to the input message using an envelope
    Envelope envelope;
    (input%0).getMessage(envelope);
    const Vector* vector = (const Vector*) envelope.myData();

    // Dynamically allocate a new matrix.  Note, HP Ptolemy will
    // manage this memory once it is moved to an output.
    FloatMatrix* matrix = new FloatMatrix(vector->size(),1);

    // Convert the vector to a matrix
    int i;
    for (i=0; i<vector->size(); i++)
      (*matrix)[i][0] = (*vector)[i];

    // Output the matrix.  Now, HP Ptolemy will manage this memory.
    output%0 << *matrix;
  }
}
