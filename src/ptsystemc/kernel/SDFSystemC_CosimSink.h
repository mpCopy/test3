#ifndef _SDFSystemC_CosimSink_h
#define _SDFSystemC_CosimSink_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy/ptsystemc/kernel/SDFSystemC_CosimSink.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright 2007 - 2014 Keysight Technologies, Inc
 */
#include "SDFSystemC_Cosim.h"
#include "CommonEnums.h"
#include "ptsystemcDll.h"

  /**
  @class SDFSystemC_CosimSink Base class for a ptolemy star that will cosimulate with SystemC Sink.

  @var SDFSystemC_CosimSink::ControlSimulation Defines  this sink controls simulation or not.
  **/

class SDFSystemC_CosimSink:public SDFSystemC_Cosim
{
public:
	SDFSystemC_CosimSink();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
protected:
	QueryState ControlSimulation;
	             /**
              @brief Returns 1 if there is no output, otherwise aborts the simulation. A sink cannot have outputs. 
             **/
int isASink (void);
	                /**
                @brief Returns 1 if controlling simulation otherwise returns 0.
                **/
int isAControllingSink (void);

};
#endif
