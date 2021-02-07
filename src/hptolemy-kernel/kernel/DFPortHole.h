/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/DFPortHole.h,v $ $Revision: 100.13 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef DFPORTHOLE_H_INCLUDED
#define DFPORTHOLE_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifndef _DFPortHole_h
#define _DFPortHole_h 1
#ifdef __GNUG__
#pragma interface
#endif
#include "PortHole.h"



/**************************************************************************
Version identification:
@(#)DFPortHole.h	1.6	8/26/95

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

 Programmer:  J. Buck, E. A. Lee and D. G. Messerschmitt

DFPortHole is the base class for portholes in the various dataflow
domains.

******************************************************************/

/** A dataflow porthole.

  A DFPortHole is a porthole that moves a number of tokens in a
  somewhat predictable way.  If {\tt isDynamic()} is FALSE, the number
  of tokens transferred is fixed and known at {\em compile time};
  otherwise, it varies according to a set of rules determined
  by the assocPort and assocRelation (not described here; see
  DynDFPortHole for more).
  */
class DFPortHole : public PortHole
{
public:
	/// Constructor
	DFPortHole();

        /** Set a ports properties - redefined to add optional
	  argument of the number particles produced/consumed */
	PortHole& setPort(const char* portName, Block* parent,
		ADSPtolemy::DataType type = ADSPtolemy::FLOAT, unsigned numTokens = 1);

	/** Return the DFPorthole that this one is connected to.

	  Return the DFPorthole that this one is connected to.
	  The {\tt farSidePort} is always DFPortHole or derived.  This
	  overrides PortHole::far.
	  */
	DFPortHole* far() const { return (DFPortHole*)farSidePort;}

	/// Return TRUE if the port uses old values
	int usesOldValues() const { return maxBackValue >= numberTokens;}

	/// Return the maximum delay
	int maxDelay() const { return maxBackValue;}

	/** Modify simulated decrement count on geodesic, for scheduling.

	  Modify simulated decrement count on geodesic, for
	  scheduling. This is not virtual because the virtual 
	  behavior is in the Geodesic. */
	void decCount(int n);

	/** Modify simulated increment count on geodesic, for scheduling.

	  Modify simulated decrement count on geodesic, for
	  scheduling. This is not virtual because the virtual behavior
	  is in the Geodesic. */
	void incCount(int n);

	/** Set geodesic's maximum buffer size, where this can be
	  determined directly.  */
	void setMaxArcCount(int n);

	/// Return TRUE if the argument is a DFPortHole
	int isA(const char*) const;

	/// Return the associated control port (default: none)
	virtual PortHole* assocPort();

	/// Assign a relation to associated port (default: none)
	virtual int assocRelation() const;

	/** Modify the SDF parameters, numTokens and delay.  The
	  numTokens variable represents the number of tokens
	  produced/consumed; the maxPctValue is the number of old
	  samples that need to be accessible.
	  
	  Typically, {\tt maxPctValue = numTokens - 1}, for most SDF
	  ports unless the associated star needs to implement a buffer
	  (such as an SDFFIR).

	  We re-do porthole initialization if bufferSize changes.  */
	virtual PortHole& setSDFParams(unsigned numTokens = 1,
				       unsigned maxPctValue=0);

	/** Return TRUE if this port can access a dynamic number of
	  tokens per firing */
	virtual int isDynamic() const;

	/** Return TRUE if this port can have a varying number of
	  tokens*/
	int isVarying() { return varying; }

        /** Return the number of repetitions the parent star will fire per
	  schedule iteration.  This is only available, after a static
	  schedule is computed.  A static schedule can be computed if
	  for only SDF systems.  */
	int parentReps() const;

protected:
	
	/** The maximum % argument allowed.

	  The maximum delay (zero, by default) that past Particles 
	  can be accessed.

	  This value is set by the {\tt DFPortHole::setSDFParams}
	  method.  */
	int maxBackValue;	

	/// Dataflow portholes use local plasma
	/*virtual*/ int allocatePlasma();

	/// Flag to be set if varying
	int varying;		
};

/// A multiporthole that supports dataflow ports
class MultiDFPort : public MultiPortHole {
public:
	/// Constructor
	MultiDFPort();

	/// Destructor
	~MultiDFPort();

	/** Modify the SDF parameters, numTokens and delay.

	  The numTokens variable represents the number of tokens
	  produced/consumed; the maxPctValue is the number of old
	  samples that need to be accesssable.
	  
	  Typically, {\tt maxPctValue = numTokens - 1}, for most SDF
	  ports unless the associated star needs to implement a buffer
	  (such as an SDFFIR).

	  We re-do porthole initialization if bufferSize changes.  */
	MultiPortHole& setSDFParams(unsigned numTokens = 1,
				    unsigned maxPstValue=0);

        /** Set a ports properties - redefined to add optional
	  argument of the number particles produced/consumed */
        MultiPortHole& setPort(const char* portName,
                          Block* parent,
                          ADSPtolemy::DataType type = ADSPtolemy::FLOAT,        // defaults to FLOAT
                          unsigned numTokens = 1);      // defaults to 1

	/// Add a newly created dataflow port to the multiporthole
	/* virtual */ PortHole& installPort(PortHole& p);

protected:
        /// The number of Particles produced/consumed
        unsigned numberTokens;
};

#endif

#endif   /* DFPORTHOLE_H_INCLUDED */
