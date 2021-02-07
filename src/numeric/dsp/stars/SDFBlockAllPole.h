/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFBlockAllPole.pl,v $ $Revision: 100.23 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFBlockAllPole_h
#define _SDFBlockAllPole_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFBlockAllPole.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFBlockAllPole:public SDFStar
{
public:
	SDFBlockAllPole();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFBlockAllPole();
	InSDFPort signalIn;
	OutSDFPort signalOut;
	InSDFPort coefs;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState BlockSize;
	IntState Order;
#line 47 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFBlockAllPole.pl"
double *taps;
		double *fdbkDelayLine;
		int M;
		int writeIndex;

};
#endif
