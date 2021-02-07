#ifndef _SDFGeodesic_h
#define _SDFGeodesic_h
// Copyright  2001 - 2017 Keysight Technologies, Inc  

#ifdef __GNUG__
#pragma interface
#endif

#include "Geodesic.h"

class GeoCircularBuffer;

class SDFGeodesic : public Geodesic
{
friend class SDFPortHole;
public:
  /*virtual*/ int isA(const char*) const;
  
  // Constructor
  SDFGeodesic();

  // Destructor
  ~SDFGeodesic();
  
  // limit the number of particles on the geodesic.
  /*  int capacity() const { return cap; }
      void setcapacity(int c);*/
  
  GeoCircularBuffer * getBuffer() { return myBuffer;}
  void initialize(int repetitions = 1);
  void finalize(int repetitions = 1);
  void incCount(int);
  void decCount(int);
  void setMaxArcCount(int);
  void setDelay(int, const char*);
  void setLateDelay(int, int);
  void setCommonBuffer(int,int);
  void resize(int);
  void repsResize(int, PortHole *);
 
protected:
  GeoCircularBuffer* myBuffer;
  int virtualDelay;
};

#endif
