/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFSlidWinAvg.pl,v $ $Revision: 100.4 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFSlidWinAvg_h
#define _SDFSlidWinAvg_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFSlidWinAvg.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  2001 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFSlidWinAvg:public SDFStar
{
public:
	SDFSlidWinAvg();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ void begin();
	InSDFPort input;
	OutSDFPort output;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState WindowSize;
#line 33 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFSlidWinAvg.pl"
double sum;

};
#endif
