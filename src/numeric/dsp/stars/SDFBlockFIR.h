/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFBlockFIR.pl,v $ $Revision: 100.22 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFBlockFIR_h
#define _SDFBlockFIR_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFBlockFIR.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "sdfdspstarsDll.h"

class SDFBlockFIR:public SDFStar
{
public:
	SDFBlockFIR();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	/* virtual */ ~SDFBlockFIR();
	InSDFPort signalIn;
	OutSDFPort signalOut;
	InSDFPort coefs;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	IntState BlockSize;
	IntState Order;
	IntState Decimation;
	IntState DecimationPhase;
	IntState Interpolation;
#line 72 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFBlockFIR.pl"
int phaseLength;
		double *taps;
		int lastM;

};
#endif
