/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFFIR.pl,v $ $Revision: 100.30 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFFIR_h
#define _SDFFIR_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFFIR.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "FloatArrayState.h"
#include "sdfdspstarsDll.h"

class SDFFIR:public SDFStar
{
public:
	SDFFIR();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort signalIn;
	OutSDFPort signalOut;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatArrayState Taps;
	IntState Decimation;
	IntState DecimationPhase;
	IntState Interpolation;
#line 59 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFFIR.pl"
int phaseLength;

};
#endif
