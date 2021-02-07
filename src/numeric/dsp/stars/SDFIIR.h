/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFIIR.pl,v $ $Revision: 100.28 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFIIR_h
#define _SDFIIR_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFIIR.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "FloatState.h"
#include "FloatArrayState.h"
#include "sdfdspstarsDll.h"

class SDFIIR:public SDFStar
{
public:
	SDFIIR();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort signalIn;
	OutSDFPort signalOut;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	FloatState Gain;
	FloatArrayState Numerator;
	FloatArrayState Denominator;
	FloatArrayState State;
#line 64 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFIIR.pl"
int numState;
	double* stateEnd;

};
#endif
