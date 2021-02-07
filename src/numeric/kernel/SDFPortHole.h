/**************************************************************************
Version identification:

@(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/kernel/SDFPortHole.h,v $ $Revision: 1.13 $ $Date: 2011/08/25 01:47:32 $

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

 Programmer:  E. A. Lee and D. G. Messerschmitt
 Date of creation: 5/29/90, J. Buck

This file contains definitions of SDF-specific PortHole classes.

******************************************************************/

#ifndef SDFPORTHOLE_H_INCLUDED
#define SDFPORTHOLE_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#include "DFPortHole.h"



/*****************************************************************
SDF: Synchronous Data Flow

This is a common special case that is handled differently
from other cases:

	Each PortHole promises to consume or generate a fixed
	number of Particles each time the Star is invoked.
	This number is stored in the PortHole and can be accessed
	by the SDFScheduler

	The incrementing of time is forced by the SDFScheduler,
	and not by the Star itself. Incrementing time is effected
	by consuming or generating Particles
****************************************************************/

class GeoCircularBuffer;

        //////////////////////////////////////////
        // class SDFPortHole
        //////////////////////////////////////////

// Contains all the special features required for
//   synchronous dataflow (SDF)

class SDFPortHole : public DFPortHole {
public:

	// class identification
	int isA(const char*) const;

        inline int numberProducedConsumed() const { return numberTokens; }

	// Services of PortHole that are often used:
	// setPort(ADSPtolemy::DataType d);

	//initialize the geodesic also
	void initialize();
	//	PortHole& setPort(const char* s, Block* parent, ADSPtolemy::DataType t, int nmv);	
	//void connect(GenericPort& destination, int numberDelays, const char* initDelayValues = 0);
	//	PortHole& newConnection();
	
	GeoCircularBuffer* allocateSDFBuffer(int size);
	void initParticle (Particle*);
	int getSize();
	void advance();
	void initGeo(int repetitions=1);
	void finalizeGeo(int repetitions=1);
	ADSPtolemy::DataType setResolvedType(ADSPtolemy::DataType=NULL);
	~SDFPortHole();
};

	///////////////////////////////////////////
	// class InSDFPort
	//////////////////////////////////////////

class InSDFPort : public SDFPortHole
{
public:
	int isItInput () const ; // {return TRUE; }

	// Get Particles from input Geodesic
	virtual void receiveData();

	void initParticle(Particle* p);
        // Services of PortHole that are often used: 
        // setPort(DataType d); 
	// Particle& operator % (int);
};

	////////////////////////////////////////////
	// class OutSDFPort
	////////////////////////////////////////////

class OutSDFPort : public SDFPortHole
{
public:
        int isItOutput () const; // {return TRUE; }

	void increment();

	// Move the current Particle in the input buffer -- this
	// method is invoked by the SDFScheduler before go()
	virtual void receiveData();

	// Put the Particles that were generated into the
	// output Geodesic -- this method is invoked by the
	// SDFScheduler after go()
	virtual void sendData();
	

        // Services of PortHole that are often used: 
        // setPort(DataType d); 
	// Particle& operator % (int);
};

        //////////////////////////////////////////
        // class MultiSDFPort
        //////////////////////////////////////////
 
// Synchronous dataflow MultiPortHole: same as DFPortHole

typedef MultiDFPort MultiSDFPort;

        //////////////////////////////////////////
        // class MultiInSDFPort
        //////////////////////////////////////////
        
// MultiInSDFPort is an SDF input MultiPortHole
 
class MultiInSDFPort : public MultiSDFPort {
public:
        int isItInput () const; // {return TRUE; }
 
        // Add a new physical port to the MultiPortHole list
        PortHole& newPort();
};
 
 
        //////////////////////////////////////////
        // class MultiOutSDFPort
        //////////////////////////////////////////

// MultiOutSDFPort is an SDF output MultiPortHole  

class MultiOutSDFPort : public MultiSDFPort {     
public:
        int isItOutput () const; // {return TRUE; }

        // Add a new physical port to the MultiPortHole list
        PortHole& newPort();
};

	class SDFMultiPort: public MultiDFPort
	{
	public:
	};

#endif   /* SDFPORTHOLE_H_INCLUDED */
