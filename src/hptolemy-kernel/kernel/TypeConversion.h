/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/TypeConversion.h,v $ $Revision: 100.15 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef TYPECONVERSION_H_INCLUDED
#define TYPECONVERSION_H_INCLUDED
// Copyright 1996 - 2014 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#include "dataType.h"
#include "type.h" 
#include "PortHole.h"

class Block;

/** Class used to declare automatic type conversions.  The {\tt
  TypeConversion} class is used to declare automatic type conversions.
  These type conversions are {\em scoped} by domain; where the domain
  scoping hierarchy is defined by the {\tt Domain::subDomains} list.

  All of the type conversions natively supported by the Ptolemy kernel
  are declared to be in the ``HOF'' scope.  This is because every
  domain has HOF as a valid sub-domain.

  A {\tt TypeConversion} once declared should never be deallocated.
  Thus, they should be declared as a file global variable in a .cc
  file.  

  As a side effect of running the {\tt TypeConversion} constructor,
  the new {\tt TypeConversion} is added to a domain's type conversion
  database.  This database is consulted by the {\tt
  PortHole::setResolvedType} method.

  If a type conversion is legal,
  the type conversion must be either supported by the associated
  particle or the {\tt TypeConversion} instance needs to supply a type
  conversion star.

  Here is an example of declaring a valid type conversion for a
  conversion supported for all domains which does not require 
  a spliced type conversion star:
\begin{verbatim}
static TypeConversion floatToComplex(FLOAT,COMPLEX,"HOF");
\end{verbatim}

  Here is an example of declaring a valid type conversion for a
  conversion supported for the XXX domain which does require a
  spliced type conversion star:
\begin{verbatim}
static SDFFloatToCx floatToCxStar;
static TypeConversion timedToComplex(floatToCxStar);
\end{verbatim}

  An easier way of declaring a type conversion star is to use the
  ptlang keyword 'typeconversion' in place of 'defstar' in the star
  ptlang file definition.  Then all of the necessary initialization
  will be generated for you automatically.

  This type conversion star is required to only two ports, one
  named input, the other named output.  For the above example:
\begin{verbatim}
	input {
		name { input }
		type { timed }
	}
	output {
		name { output }
		type { complex }
	}
\end{verbatim}

  @author Jose Luis Pino, Hewlett Packard*/
class TypeConversion {
public:
  /**@name Constructors */
  //@{
  /// Declare a valid type conversion for a given domain
  TypeConversion(ADSPtolemy::DataType from, ADSPtolemy::DataType to, 
		 const char* domain);
 
  /** Declare a valid type conversion which needs a type conversion
    star.  This form is automatically generated when a star writer
    uses the 'typeconversion' ptlang keyword in place of 'defstar'. */    
  TypeConversion(const Block& master);
  //@}

  /** Splice in a type conversion star if needed.  Return the type
    conversion block that was spliced in.  This method is used by the 
    {\tt PortHole::setResolvedType} method.*/
  static Block* convert(ADSPtolemy::DataType from, ADSPtolemy::DataType to, PortHole& port);
  static Block* SDFconvert(ADSPtolemy::DataType from, ADSPtolemy::DataType to, PortHole& port);
  /// Return the DataType of what we are converting from
  inline ADSPtolemy::DataType from() const { return fromType; }

  /// Return the DataType of what we are converting to
  inline ADSPtolemy::DataType to() const { return toType; }

  /// Return a pointer to the master type conversion star
  inline const Block* conversionBlock() const { return master; }

private:
  /** Return a TypeConversion for a given domain if legal, NULL
    otherwise.  If a specified type conversion is legal for a given
    domain or any of it's sub-domains, return a pointer to the {\tt
    TypeConversion} instance that defines the type conversion.  If the
    specified type conversion is illegal, return NULL.

    This method is called by {\tt PortHole::setResolvedType}.*/
  static TypeConversion* find(ADSPtolemy::DataType from, ADSPtolemy::DataType to, 
			      const char* domain);

  /// Find the type conversion in a given domain
  static TypeConversion* findInOneDomain(ADSPtolemy::DataType from, ADSPtolemy::DataType to, 
			       const char* domain);

  /// Add a type conversion in the database of the specified domain
  void addTypeConversion(const char* domain);

  /// Propigate the types to all type ports
  static void setResolvedType(PortHole& port,ADSPtolemy::DataType type);

  /// Data types of what we are mapping from and to 
  ADSPtolemy::DataType fromType, toType;

  /** Pointer to an optional type conversion star. If this is NULL
    the type conversion is assumed to be taken care of automatically
    by the fromType particle.*/
  const Block* master;
};

#endif   /* TYPECONVERSION_H_INCLUDED */
