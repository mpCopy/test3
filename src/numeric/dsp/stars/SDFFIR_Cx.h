/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/numeric/dsp/stars/SDFFIR_Cx.pl,v $ $Revision: 100.26 $ $Date: 2011/08/25 01:09:10 $ */
#ifndef _SDFFIR_Cx_h
#define _SDFFIR_Cx_h 1
// header file generated from S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFFIR_Cx.pl by ptlang

#ifdef __GNUG__
#pragma interface
#endif

/*
Copyright  1997 - 2017 Keysight Technologies, Inc
 */
#include "SDFStar.h"
#include "IntState.h"
#include "ComplexArrayState.h"
#include "sdfdspstarsDll.h"

class SDFFIR_Cx:public SDFStar
{
public:
	SDFFIR_Cx();
	/* virtual */ Block* makeNew() const;
	/* virtual */ const char* className() const;
	/* virtual */ int isA(const char*) const;
	InSDFPort signalIn;
	OutSDFPort signalOut;

protected:
	/* virtual */ void setup();
	/* virtual */ void go();
	ComplexArrayState Taps;
	IntState Decimation;
	IntState DecimationPhase;
	IntState Interpolation;
#line 63 "S:/hped/builds/sr/devXXX/rgcandidate/build/cmake/projects/ptolemy-kernel/numeric/dsp/stars/SDFFIR_Cx.pl"
int phaseLength;

};
#endif
