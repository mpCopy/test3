/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/kernel/TSDFPortHole.h,v $ $Revision: 1.12 $ $Date: 2011/08/25 01:47:49 $ */

/******************************************************************
Copyright (c) 1996 Hewlett Packard
All rights reserved.

Programmer:  Jose Luis Pino
Date of creation: 10/16/96

This file contains definitions of TSDF-specific PortHole classes.
******************************************************************/


#ifndef TSDFPORTHOLE_H_INCLUDED
#define TSDFPORTHOLE_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

#include "TSDFParticle.h"
#include "TSDFGeodesic.h"
#include "SDFPortHole.h"
#include "SimControl.h"

/*****************************************************************
TSDF: Timed Synchronous Data Flow
****************************************************************/

    

        //////////////////////////////////////////
        // class TSDFPortHole
        //////////////////////////////////////////

// Contains all the special features required for
//   timed synchronous dataflow (TSDF)

class TSDFPortHole : public SDFPortHole {
public:
  
  /*virtual*/ int isA(const char*) const;

  inline void setTimeStep(double tstep) {
    if ( tstep > 0 ) {
       TSDFGeodesic* geodesic = tsdfGeo();
       geodesic->setTimeStep(tstep);
    }
  }

  inline double getTimeStep() {
    TSDFGeodesic* geodesic = tsdfGeo();
    return geodesic->getTimeStep();
  }

 
  inline void setTimeStamp(double initTime) {
      TSDFGeodesic* geodesic = tsdfGeo();
      geodesic->setTimeStamp(initTime);
  }


  inline void updateTimeStamp() {
    TSDFGeodesic* geodesic = tsdfGeo();
    geodesic->updateTimeStamp();
  }

  inline double getTimeStamp() {
    TSDFGeodesic* geodesic = tsdfGeo();
    return geodesic->getTimeStamp();
  }

  
  inline void setCarrierFrequency(double fc) {
    TSDFGeodesic* geodesic = tsdfGeo();
    geodesic->setCarrierFrequency(fc);
  }

  inline double getCarrierFrequency() {
    TSDFGeodesic* geodesic = tsdfGeo();
    return geodesic->getCarrierFrequency();
  }

    	

  // Services of PortHole that are often used:
  // setPort(DataType d);
  // Particle& operator % (int);
private:
  inline TSDFGeodesic* tsdfGeo() {
    if (!geo()) {
      Error::abortRun(*this," is not connected");
    }
    return (TSDFGeodesic*)geo();
  }
};

	///////////////////////////////////////////
	// class InTSDFPort
	//////////////////////////////////////////

class InTSDFPort : public TSDFPortHole {
public:
    int isItInput () const ; // {return TRUE; }
  
  // Get Particles from input Geodesic
    virtual void receiveData();

    Complex getIQData(int);
    int     getFlavor(int);
    double  getTimeStamp(int);
    

  // Services of PortHole that are often used: 
  // setPort(DataType d); 
  // Particle& operator % (int);
};

	////////////////////////////////////////////
	// class OutTSDFPort
	////////////////////////////////////////////

class OutTSDFPort : public TSDFPortHole {
public:
  int isItOutput () const; // {return TRUE; }
  
  void increment();
  
  // Move the current Particle in the input buffer -- this
  // method is invoked by the TSDFScheduler before go()
  virtual void receiveData();

  // Put the Particles that were generated into the
  // output Geodesic -- this method is invoked by the
  // TSDFScheduler after go()
  virtual void sendData();
  
  // Services of PortHole that are often used: 
  // setPort(DataType d); 
  // Particle& operator % (int);
};

        //////////////////////////////////////////
        // class MultiTSDFPort
        //////////////////////////////////////////
 
// Timed synchronous dataflow MultiPortHole: same as DFPortHole

typedef MultiDFPort MultiTSDFPort;

        //////////////////////////////////////////
        // class MultiInTSDFPort
        //////////////////////////////////////////
        
// MultiInTSDFPort is an TSDF input MultiPortHole
 
class MultiInTSDFPort : public MultiTSDFPort {
public:
  int isItInput () const; // {return TRUE; }
  
  // Add a new physical port to the MultiPortHole list
  PortHole& newPort();
};
 
 
        //////////////////////////////////////////
        // class MultiOutTSDFPort
        //////////////////////////////////////////

// MultiOutTSDFPort is an TSDF output MultiPortHole  

class MultiOutTSDFPort : public MultiTSDFPort {     
public:
  int isItOutput () const; // {return TRUE; }
  
  // Add a new physical port to the MultiPortHole list
  PortHole& newPort();
};

#endif   /* TSDFPORTHOLE_H_INCLUDED */
