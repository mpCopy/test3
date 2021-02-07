/*@(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/kernel/TSDFGeodesic.h,v $ $Revision: 1.11 $ $Date: 2011/08/25 01:47:49 $ */
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/kernel/TSDFGeodesic.h,v $ $Revision: 1.11 $ $Date: 2011/08/25 01:47:49 $ */
/**********************************************************************

Copyright (c) 1996 Hewlett Packard
All rights reserved.

Programmer:  Jose Luis Pino
Date of creation: 10/16/96

***********************************************************************/


#ifndef TSDFGEODESIC_H_INCLUDED
#define TSDFGEODESIC_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

#ifndef _TSDFGeodesic_h
#define _TSDFGeodesic_h

#ifdef __GNUG__
#pragma interface
#endif

#include "PortHole.h"
#include "SDFGeodesic.h"
#include "HPtolemyError.h"



class TSDFGeodesic : public SDFGeodesic {
public:
  // Class identification.
  /*virtual*/ int isA(const char*) const;

  // Constructor.
  TSDFGeodesic();
  
  inline void setTimeStep(double tstep) {
    timeStep = tstep;
  }

  inline double getTimeStep() const {
    return timeStep;
  }

  inline void updateTimeStamp() {
    ctime += timeStep;
  }

  inline void setTimeStamp(double current) {
    ctime = current;
  }

  inline double getTimeStamp() {
    return ctime;
  }

  inline void setCarrierFrequency(double fc) {
    carrierFreq = fc;
  }

  inline double getCarrierFrequency() const {
    return carrierFreq;
  }

  /*virtual*/ void initialize();
private:

  double timeStep;
  double ctime;
  double carrierFreq;
};

#endif


#endif   /* TSDFGEODESIC_H_INCLUDED */
