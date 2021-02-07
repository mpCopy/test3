/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/dataType.h,v $ $Revision: 100.19 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef DATATYPE_H_INCLUDED
#define DATATYPE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2017  

#include "ptolemyDll.h"

/**************************************************************************
Version identification:
@(#)dataType.h	1.6	3/2/95

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
 Date of creation: 8/13/90
 Revisions:

define the pseudo-class DataType and the "standard" particle types.

**************************************************************************/


/** The type of data stored that a porthole transmits.  The data type
  for a \Ref PortHole is stored as a global const char*.
  The string contained in each variable matches the variable's name.
  The datatypes that are supported in the kernel are:

  - INT
  - FLOAT
  - STRING
  - COMPLEX
  - FIX
  - ANYTYPE
  - COMPLEX_MATRIX
  - FIX_MATRIX
  - FLOAT_MATRIX
  - INT_MATRIX
  - FILEMSG

  The use of a global string enables fast type comparisons, such as:

  \code
  if (port->resolvedType == COMPLEX) {
    cout << port->name() << " is a complex port\n";
  }
  \endcode

  The code above could be made more modular by:
  
  \code
  cout << port->name() << " is a " << port->resolvedType() << "\n";}
  \endcode
*/
namespace ADSPtolemy 
{
  typedef const char* DataType;

  // build in standard types, user may add others
  // ANYTYPE is provided for the benefit of Stars like Fork
  // and Printer that operate independently of Particle type
  
  HPTOLEMY_KERNEL_API extern const DataType INT, FLOAT, STRING, COMPLEX, FIX, ANYTYPE;

	enum DataTypeE
	{
		eInt, eDouble, eComplex, eFloat, eComplexFloat
	};

	/// DataTypeByEnum to map the enum to a data type
	HPTOLEMY_KERNEL_API extern const DataType* DataTypeByEnum[];
}

#endif   /* DATATYPE_H_INCLUDED */
