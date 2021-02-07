/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/timed/kernel/TSDFParticle.h,v $ $Revision: 100.17 $ $Date: 2011/08/25 01:47:49 $ */

#ifndef TSDFPARTICLE_H_INCLUDED
#define TSDFPARTICLE_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

/**************************************************************************


  @Description 

  @Author Kal Kalbasi

 **************************************************************************/

#include "Particle.h"
#include "dataType.h"
#include "ComplexSubset.h"
#include "tsdfDll.h"



enum TParticleTypE
{
    BaseBand,
    ComplexEnv
}; 

namespace ADSPtolemy {
DllImport extern const DataType TIMED ;
}

/// Timed Particle Class
/** TimedParticle class includes data & functions for simulation of
  discrete time samples. Each particle has data and a "time" stamp as
  well as some characterization (carrier) frequency. The time particle
  has two personalities (representing the same physical quantity). The
  two personalities are "ComplexEnv" and "BaseBand" set by the
  "flavor" field. */
  


class TimedParticle:public ComplexParticle{

    
public:
  
  ADSPtolemy::DataType type() const;

  // clone the Particle, and remove clone
  Particle* clone() const;
  Particle* useNew() const;
  void die();

  
  /*virtual*/ operator int () const;
  /*virtual*/ operator float () const;
  /*virtual*/ operator double () const;
  /*virtual*/ operator Complex () const;
  /*virtual*/ operator Fix () const;	
  /*virtual*/ StringList print () const;
  /*virtual*/ Particle& initialize() ;	
  
  virtual int initParticleStack(Block* parent, ParticleStack& pstack,
				      Plasma* myPlasma, const char* delay = 0);

 
  TimedParticle(const Complex&, const double&, const double&);
  TimedParticle(const double&, const double&);
  TimedParticle(const int&, const double&);
  TimedParticle(const Fix&, const double&); 
  TimedParticle(); 
  
 

  // Load up with data
  /*virtual*/ void operator << (int i);
  /*virtual*/ void operator << (double f);
  /*virtual*/ void operator << (const Complex& c);
  /*virtual*/ void operator << (const Fix& x);
  /*virtual*/ void operator << (const Envelope&);
  /*virtual*/ void operator << (const StringState& string); 
  /*virtual*/ void operator << (Message& m) {
    ((ComplexParticle&)*this) << m;
  }

  //void operator << (const TimedParticle&);

  
  // Copy the Particle
  Particle& operator = (const Particle&);

  // compare particles
  int operator == (const Particle&);

    
  inline void setTimeStamp(double t){time = t;}
  inline void setCarrierFrequency(double carrier){fc = carrier;}
  inline void setFlavor(TParticleTypE type){flavor = type;}
  inline void scaleData(double scale){data = data*scale;}
  
  inline double getTimeStamp(){return time;}
  inline double getCarrierFrequency(){return fc;}
  inline int  getFlavor(){return (int)flavor;}
  inline Complex getIQData(){return data;}

private:
    
  TParticleTypE flavor;
  double time;
  double fc;
};
#endif   /* TSDFPARTICLE_H_INCLUDED */
